//+------------------------------------------------------------------+
//|                                          GridHedge_XAUUSD.mq5    |
//|  Hedge grid EA for Gold (XAUUSD) on Exness Cent accounts.        |
//|                                                                   |
//|  Strategy:                                                        |
//|   - On start (and after every reset) the current market price     |
//|     becomes the "base price" of a new grid. This is a TREND-       |
//|     FOLLOWING grid, not mean-reversion: 10 Buy levels are placed    |
//|     ABOVE the base price (buy into strength as price rises) and    |
//|     10 Sell levels are placed BELOW it (sell into weakness as       |
//|     price falls). Layer 1 is InpGapUSD away from base; each         |
//|     further layer's own gap is multiplied by InpGapMultiplier, so   |
//|     with the default >1.0 the layers widen out (layer 2 is farther  |
//|     from layer 1 than layer 1 is from base, etc) instead of being   |
//|     evenly spaced. This changes the SAME risk/reward trade-off as   |
//|     InpLotMultiplier does, just via trade spacing instead of trade  |
//|     size - it does not reduce risk on its own (see README).         |
//|   - Each level is filled with an immediate market order (not a     |
//|     pending order) the first time price trades through it.         |
//|   - Every tick, each OPEN POSITION is checked individually: once    |
//|     its own profit reaches InpLayerTPUSD it is closed on its own,   |
//|     locking in that layer's gain immediately instead of leaving it  |
//|     to ride back down while waiting for the whole basket to close.  |
//|     This is what actually makes the strategy net profitable -       |
//|     without it, a layer that was winning can give the profit back   |
//|     and even end up a large loss by the time the basket-level exit  |
//|     finally fires (see README for a worked example).                |
//|   - Because both sides sit on opposite sides of the base price,     |
//|     a whipsawing market fills layers on BOTH sides over time, so    |
//|     the two baskets net/hedge against each other - g_buyFilled     |
//|     and g_sellFilled are independent running counts of each side's |
//|     total fills, not a "who filled zero" worst case.               |
//|   - Every tick the EA sums the floating profit of every open       |
//|     position from this grid (each position's own real entry        |
//|     price vs the current price). As soon as that total reaches     |
//|     InpProfitTargetUSD, ALL positions are closed and a brand new    |
//|     grid is re-armed immediately, centered on the current market   |
//|     price - this is the primary exit.                               |
//|   - As a fallback, if either side fills all InpLayers levels        |
//|     before the profit target is reached, the grid is also closed    |
//|     and re-armed immediately the same way - a worst-case safety     |
//|     exit for a market that trends hard one way without ever         |
//|     giving back enough for the profit target.                       |
//|   - Lot size grows per layer by InpLotMultiplier (1.0 = fixed lot,  |
//|     same as before), capped at InpMaxLotSize, so a small pullback   |
//|     recovers more of an adverse move. This is a bounded Martingale  |
//|     - it does NOT guarantee profit, and a hard money stop-loss       |
//|     (InpMaxLossUSD) is included specifically because no lot-sizing   |
//|     formula can guarantee recovery: if the market trends hard one    |
//|     way without ever reversing, InpMaxLossUSD forces the grid to     |
//|     close and re-arm before the loss grows unbounded, instead of     |
//|     letting a runaway lot size blow up the account.                  |
//+------------------------------------------------------------------+
#property copyright "Grid Hedge EA"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

input group "=== Grid settings ==="
input double InpLotSize          = 0.01;   // Lot size for every layer (fixed, same size every layer)
input double InpLotMultiplier    = 1.0;    // Lot multiplier per layer (1.0 = fixed lot; >1.0 = bounded Martingale, see README)
input double InpMaxLotSize       = 0.20;   // Maximum lot size for any single layer (hard cap, only matters if InpLotMultiplier > 1.0)
input double InpGapUSD           = 2.0;    // Gap for layer 1, in price ($)
input double InpGapMultiplier    = 1.3;    // Gap multiplier per layer (1.0 = fixed gap; >1.0 = widening; <1.0 = narrowing, see README)
input int    InpLayers           = 10;     // Number of layers per side (Buy / Sell)
input int    InpSlippagePoints   = 30;     // Max slippage for market orders (points)

input group "=== Profit-based exit (primary) ==="
input double InpProfitTargetUSD  = 10.0;   // Close all + restart once total floating profit >= this (0 = disabled, falls back to full-side-fill only)
input double InpLayerTPUSD       = 2.0;    // Close each individual position once ITS OWN profit >= this (0 = disabled)

input group "=== Risk management ==="
input double InpMaxLossUSD       = 50.0;   // Hard stop: close all + restart once total floating LOSS reaches this ($, 0 = disabled - NOT recommended)

input group "=== Identification ==="
input ulong  InpMagicNumber      = 20260802; // Magic number, keeps this EA's trades separate

CTrade trade;

double g_layerLot[];          // g_layerLot[i] = normalized lot size for layer i+1 (both Buy and Sell sides)
double g_layerDistance[];     // g_layerDistance[i] = cumulative distance from base price to layer i+1
double g_basePrice;           // price the current grid is centered on
bool   g_buyTriggered[];      // g_buyTriggered[i] == layer i+1 already filled
bool   g_sellTriggered[];
int    g_buyFilled;
int    g_sellFilled;

//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpSlippagePoints);
   trade.SetTypeFillingBySymbol(_Symbol);

   if(InpLayers <= 0)
     {
      Print("InpLayers must be > 0");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(InpLotMultiplier <= 0.0)
     {
      Print("InpLotMultiplier must be > 0");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(InpGapMultiplier <= 0.0)
     {
      Print("InpGapMultiplier must be > 0");
      return INIT_PARAMETERS_INCORRECT;
     }

   ArrayResize(g_layerLot, InpLayers);
   for(int i = 0; i < InpLayers; i++)
     {
      double lot = InpLotSize * MathPow(InpLotMultiplier, i);
      lot = MathMin(lot, InpMaxLotSize);
      g_layerLot[i] = NormalizeLot(lot);
     }

   ArrayResize(g_layerDistance, InpLayers);
   double cumDistance = 0.0;
   double gap = InpGapUSD;
   for(int i = 0; i < InpLayers; i++)
     {
      cumDistance += gap;
      g_layerDistance[i] = cumDistance;
      gap *= InpGapMultiplier;
     }

   ArrayResize(g_buyTriggered, InpLayers);
   ArrayResize(g_sellTriggered, InpLayers);

   ResetGrid(GetMidPrice());
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  }

//+------------------------------------------------------------------+
void OnTick()
  {
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   if(bid <= 0.0 || ask <= 0.0)
      return;

   for(int i = 0; i < InpLayers; i++)
     {
      double buyLevel  = g_basePrice + g_layerDistance[i];   // above base: buy into an uptrend
      double sellLevel = g_basePrice - g_layerDistance[i];   // below base: sell into a downtrend

      if(!g_buyTriggered[i] && ask >= buyLevel)
        {
         if(trade.Buy(g_layerLot[i], _Symbol))
           {
            g_buyTriggered[i] = true;
            g_buyFilled++;
            PrintFormat("Buy layer %d filled at level %.2f (ask=%.2f, lot=%.2f)", i + 1, buyLevel, ask, g_layerLot[i]);
           }
         else
            PrintFormat("Buy layer %d failed: %s", i + 1, trade.ResultRetcodeDescription());
        }

      if(!g_sellTriggered[i] && bid <= sellLevel)
        {
         if(trade.Sell(g_layerLot[i], _Symbol))
           {
            g_sellTriggered[i] = true;
            g_sellFilled++;
            PrintFormat("Sell layer %d filled at level %.2f (bid=%.2f, lot=%.2f)", i + 1, sellLevel, bid, g_layerLot[i]);
           }
         else
            PrintFormat("Sell layer %d failed: %s", i + 1, trade.ResultRetcodeDescription());
        }
     }

   CloseIndividualLayersAtProfit();

   double floatingProfit = GetFloatingProfit();
   bool sideCompleted  = (g_buyFilled >= InpLayers) || (g_sellFilled >= InpLayers);
   bool profitReached  = (InpProfitTargetUSD > 0.0) && (floatingProfit >= InpProfitTargetUSD);
   bool lossExceeded   = (InpMaxLossUSD > 0.0) && (floatingProfit <= -InpMaxLossUSD);

   if(lossExceeded || sideCompleted || profitReached)
     {
      string reason = lossExceeded ? "hard stop-loss reached" :
                       sideCompleted ? "one side completed all layers" : "profit target reached";
      PrintFormat("Closing grid (buyFilled=%d sellFilled=%d profit=%.2f) - reason: %s",
                  g_buyFilled, g_sellFilled, floatingProfit, reason);
      CloseAllPositions();
      ResetGrid(GetMidPrice());
     }

   UpdateComment();
  }

//+------------------------------------------------------------------+
void ResetGrid(double base)
  {
   g_basePrice = base;
   ArrayInitialize(g_buyTriggered, false);
   ArrayInitialize(g_sellTriggered, false);
   g_buyFilled  = 0;
   g_sellFilled = 0;
   PrintFormat("Grid armed - base price %.2f, %d layers, layer1 gap %.2f, gap multiplier %.2f, last layer distance %.2f",
               g_basePrice, InpLayers, InpGapUSD, InpGapMultiplier, g_layerDistance[InpLayers - 1]);
  }

//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != (long)InpMagicNumber)
         continue;

      if(!trade.PositionClose(ticket))
         PrintFormat("Failed to close position #%I64u: %s", ticket, trade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
void CloseIndividualLayersAtProfit()
  {
   if(InpLayerTPUSD <= 0.0)
      return;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != (long)InpMagicNumber)
         continue;

      double profit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      if(profit < InpLayerTPUSD)
         continue;

      if(trade.PositionClose(ticket))
         PrintFormat("Layer position #%I64u closed individually at profit %.2f", ticket, profit);
      else
         PrintFormat("Failed to close position #%I64u for individual TP: %s", ticket, trade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
double GetFloatingProfit()
  {
   double profit = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != (long)InpMagicNumber)
         continue;

      profit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
     }
   return profit;
  }

//+------------------------------------------------------------------+
double GetMidPrice()
  {
   return (SymbolInfoDouble(_Symbol, SYMBOL_BID) + SymbolInfoDouble(_Symbol, SYMBOL_ASK)) / 2.0;
  }

//+------------------------------------------------------------------+
double NormalizeLot(double lot)
  {
   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(lotStep <= 0.0)
      lotStep = 0.01;

   double normalized = MathRound(lot / lotStep) * lotStep;
   normalized = MathMax(minLot, MathMin(maxLot, normalized));
   return NormalizeDouble(normalized, 2);
  }

//+------------------------------------------------------------------+
void UpdateComment()
  {
   Comment(StringFormat(
      "GridHedge_XAUUSD\nBase: %.2f\nBuy filled: %d/%d\nSell filled: %d/%d\nFloating P/L: %.2f\nMax loss stop: %.2f\nNext layer lot: %.2f",
      g_basePrice, g_buyFilled, InpLayers, g_sellFilled, InpLayers, GetFloatingProfit(),
      InpMaxLossUSD, g_layerLot[MathMin(MathMax(g_buyFilled, g_sellFilled), InpLayers - 1)]));
  }
//+------------------------------------------------------------------+
