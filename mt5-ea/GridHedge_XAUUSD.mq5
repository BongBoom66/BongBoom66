//+------------------------------------------------------------------+
//|                                          GridHedge_XAUUSD.mq5    |
//|  Hedge grid EA for Gold (XAUUSD) on Exness Cent accounts.        |
//|                                                                   |
//|  Strategy:                                                        |
//|   - On start (and after every reset) the current market price     |
//|     becomes the "base price" of a new grid.                       |
//|   - 10 Buy levels are placed below the base price, spaced          |
//|     InpGapUSD apart, and 10 Sell levels are placed above it,       |
//|     also spaced InpGapUSD apart.                                   |
//|   - Each level is filled with an immediate market order (not a     |
//|     pending order) the first time price trades through it.         |
//|   - If either side (Buy or Sell) gets all InpLayers levels filled  |
//|     before the other side does, ALL open positions from this EA    |
//|     are closed immediately, and a brand new grid is re-armed       |
//|     centered on the current market price.                         |
//+------------------------------------------------------------------+
#property copyright "Grid Hedge EA"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

input group "=== Grid settings ==="
input double InpLotSize          = 0.01;   // Lot size per layer (same for all layers)
input double InpGapUSD           = 2.0;    // Gap between layers, in price ($)
input int    InpLayers           = 10;     // Number of layers per side (Buy / Sell)
input int    InpSlippagePoints   = 30;     // Max slippage for market orders (points)

input group "=== Optional early exit ==="
input double InpProfitTargetUSD  = 0.0;    // Close all + restart once floating profit >= this (0 = disabled)

input group "=== Identification ==="
input ulong  InpMagicNumber      = 20260802; // Magic number, keeps this EA's trades separate

CTrade trade;

double g_lot;                 // normalized lot size actually sent to broker
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

   g_lot = NormalizeLot(InpLotSize);
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
      double buyLevel  = g_basePrice - (i + 1) * InpGapUSD;
      double sellLevel = g_basePrice + (i + 1) * InpGapUSD;

      if(!g_buyTriggered[i] && bid <= buyLevel)
        {
         if(trade.Buy(g_lot, _Symbol))
           {
            g_buyTriggered[i] = true;
            g_buyFilled++;
            PrintFormat("Buy layer %d filled at level %.2f (bid=%.2f)", i + 1, buyLevel, bid);
           }
         else
            PrintFormat("Buy layer %d failed: %s", i + 1, trade.ResultRetcodeDescription());
        }

      if(!g_sellTriggered[i] && ask >= sellLevel)
        {
         if(trade.Sell(g_lot, _Symbol))
           {
            g_sellTriggered[i] = true;
            g_sellFilled++;
            PrintFormat("Sell layer %d filled at level %.2f (ask=%.2f)", i + 1, sellLevel, ask);
           }
         else
            PrintFormat("Sell layer %d failed: %s", i + 1, trade.ResultRetcodeDescription());
        }
     }

   bool sideCompleted  = (g_buyFilled >= InpLayers) || (g_sellFilled >= InpLayers);
   bool profitReached  = (InpProfitTargetUSD > 0.0) && (GetFloatingProfit() >= InpProfitTargetUSD);

   if(sideCompleted || profitReached)
     {
      PrintFormat("Closing grid (buyFilled=%d sellFilled=%d profit=%.2f) - reason: %s",
                  g_buyFilled, g_sellFilled, GetFloatingProfit(),
                  sideCompleted ? "one side completed all layers" : "profit target reached");
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
   PrintFormat("Grid armed - base price %.2f, %d layers, gap %.2f", g_basePrice, InpLayers, InpGapUSD);
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
      "GridHedge_XAUUSD\nBase: %.2f\nBuy filled: %d/%d\nSell filled: %d/%d\nFloating P/L: %.2f",
      g_basePrice, g_buyFilled, InpLayers, g_sellFilled, InpLayers, GetFloatingProfit()));
  }
//+------------------------------------------------------------------+
