//+------------------------------------------------------------------+
//|                                          GridHedge_XAUUSD.mq5    |
//|  Trend-following SINGLE-ORDER EA for Gold (XAUUSD), Exness Cent. |
//|                                                                   |
//|  Strategy:                                                        |
//|   - While flat (no open position), the current market price is    |
//|     the "base price". The EA waits for price to move              |
//|     InpTriggerGapUSD away from that base, in either direction.    |
//|   - Whichever direction gets there first opens ONE market order:  |
//|     price rising to base+InpTriggerGapUSD opens a Buy, price       |
//|     falling to base-InpTriggerGapUSD opens a Sell.                 |
//|   - The order is placed with a broker-side Take Profit             |
//|     (InpTakeProfitUSD) and Stop Loss (InpStopLossUSD) set          |
//|     directly on it - the broker closes it automatically when       |
//|     either is hit, so the exit does not depend on the EA/terminal  |
//|     staying connected.                                             |
//|   - Only ONE position is open at a time. The instant it closes     |
//|     (TP or SL), the EA re-arms: the base price resets to the       |
//|     current market price and it starts waiting for the next        |
//|     InpTriggerGapUSD move again.                                    |
//+------------------------------------------------------------------+
#property copyright "Trend Single-Order EA"
#property version   "2.00"
#property strict

#include <Trade\Trade.mqh>

input group "=== Trade settings ==="
input double InpLotSize          = 0.01;   // Lot size per order
input double InpTriggerGapUSD    = 2.0;    // Distance from base price that triggers an entry ($)
input double InpTakeProfitUSD    = 0.5;    // Take profit distance from entry price ($)
input double InpStopLossUSD      = 50.0;   // Stop loss distance from entry price ($)
input int    InpSlippagePoints   = 30;     // Max slippage for market orders (points)

input group "=== Identification ==="
input ulong  InpMagicNumber      = 20260802; // Magic number, keeps this EA's trades separate

CTrade trade;

double g_lot;          // normalized lot size actually sent to broker
double g_basePrice;    // reference price the EA is currently waiting from
bool   g_baseArmed;    // true once g_basePrice has been set for this waiting period

//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpSlippagePoints);
   trade.SetTypeFillingBySymbol(_Symbol);

   g_lot = NormalizeLot(InpLotSize);
   g_baseArmed = false;

   double minStopDistance = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(minStopDistance > 0.0 && (InpTakeProfitUSD < minStopDistance || InpStopLossUSD < minStopDistance))
      PrintFormat("WARNING: broker minimum stop distance is %.2f - InpTakeProfitUSD (%.2f) or InpStopLossUSD (%.2f) is tighter than that, orders may be rejected as invalid stops",
                  minStopDistance, InpTakeProfitUSD, InpStopLossUSD);

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

   if(HasOpenPosition())
     {
      g_baseArmed = false; // re-arm a fresh base the moment we go flat again
      Comment("GridHedge_XAUUSD (Single Order)\nPosition open, waiting for TP/SL...");
      return;
     }

   if(!g_baseArmed)
     {
      g_basePrice = GetMidPrice();
      g_baseArmed = true;
      PrintFormat("Armed - base price %.2f, waiting for +-%.2f move", g_basePrice, InpTriggerGapUSD);
     }

   if(ask >= g_basePrice + InpTriggerGapUSD)
      OpenOrder(ORDER_TYPE_BUY, ask);
   else if(bid <= g_basePrice - InpTriggerGapUSD)
      OpenOrder(ORDER_TYPE_SELL, bid);

   Comment(StringFormat("GridHedge_XAUUSD (Single Order)\nBase: %.2f\nWaiting for +-%.2f move...", g_basePrice, InpTriggerGapUSD));
  }

//+------------------------------------------------------------------+
void OpenOrder(ENUM_ORDER_TYPE type, double refPrice)
  {
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double sl, tp;
   bool ok;

   if(type == ORDER_TYPE_BUY)
     {
      sl = NormalizeDouble(refPrice - InpStopLossUSD, digits);
      tp = NormalizeDouble(refPrice + InpTakeProfitUSD, digits);
      ok = trade.Buy(g_lot, _Symbol, 0.0, sl, tp);
     }
   else
     {
      sl = NormalizeDouble(refPrice + InpStopLossUSD, digits);
      tp = NormalizeDouble(refPrice - InpTakeProfitUSD, digits);
      ok = trade.Sell(g_lot, _Symbol, 0.0, sl, tp);
     }

   if(ok)
      PrintFormat("%s order opened near %.2f, SL=%.2f, TP=%.2f, lot=%.2f",
                  type == ORDER_TYPE_BUY ? "Buy" : "Sell", refPrice, sl, tp, g_lot);
   else
      PrintFormat("Order failed: %s", trade.ResultRetcodeDescription());
  }

//+------------------------------------------------------------------+
bool HasOpenPosition()
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

      return true;
     }
   return false;
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
