//+------------------------------------------------------------------+
//|                                          GridHedge_XAUUSD.mq5    |
//|  Straddle EA for Gold (XAUUSD), Exness Cent.                     |
//|                                                                   |
//|  Strategy:                                                        |
//|   - Whenever there is no open position from this EA, it opens     |
//|     BOTH a Buy and a Sell at the current market price, at the      |
//|     same time - each with its own broker-side Take Profit          |
//|     (InpTakeProfitUSD) and Stop Loss (InpStopLossUSD).             |
//|   - The two positions are managed independently after that: if     |
//|     one hits its SL, the other is left open and keeps running       |
//|     toward its own TP or SL - it is NOT force-closed just because   |
//|     its pair closed.                                                |
//|   - Once BOTH positions have closed (each via its own TP or SL),    |
//|     the EA immediately opens a fresh Buy+Sell pair at the current   |
//|     market price and the cycle repeats.                             |
//|   - If one leg of a pair fails to open (e.g. margin rejection),     |
//|     the other leg is closed immediately so a stray single-sided     |
//|     position is never left running unintentionally.                 |
//+------------------------------------------------------------------+
#property copyright "Straddle EA"
#property version   "3.00"
#property strict

#include <Trade\Trade.mqh>

input group "=== Trade settings ==="
input double InpLotSize          = 0.5;    // Lot size per order (Buy and Sell each)
input double InpTakeProfitUSD    = 12.0;   // Take profit distance from entry price ($)
input double InpStopLossUSD      = 10.0;   // Stop loss distance from entry price ($)
input int    InpSlippagePoints   = 30;     // Max slippage for market orders (points)

input group "=== Identification ==="
input ulong  InpMagicNumber      = 20260802; // Magic number, keeps this EA's trades separate

CTrade trade;

double g_lot; // normalized lot size actually sent to broker

//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpSlippagePoints);
   trade.SetTypeFillingBySymbol(_Symbol);

   g_lot = NormalizeLot(InpLotSize);

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

   int openCount = CountOpenPositions();

   if(openCount == 0)
      OpenStraddle();

   Comment(StringFormat("GridHedge_XAUUSD (Straddle)\nOpen legs: %d/2", CountOpenPositions()));
  }

//+------------------------------------------------------------------+
void OpenStraddle()
  {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   double buySL = NormalizeDouble(ask - InpStopLossUSD, digits);
   double buyTP = NormalizeDouble(ask + InpTakeProfitUSD, digits);
   bool buyOk = trade.Buy(g_lot, _Symbol, 0.0, buySL, buyTP);
   if(buyOk)
      PrintFormat("Buy leg opened near %.2f, SL=%.2f, TP=%.2f, lot=%.2f", ask, buySL, buyTP, g_lot);
   else
      PrintFormat("Buy leg failed: %s", trade.ResultRetcodeDescription());

   double sellSL = NormalizeDouble(bid + InpStopLossUSD, digits);
   double sellTP = NormalizeDouble(bid - InpTakeProfitUSD, digits);
   bool sellOk = trade.Sell(g_lot, _Symbol, 0.0, sellSL, sellTP);
   if(sellOk)
      PrintFormat("Sell leg opened near %.2f, SL=%.2f, TP=%.2f, lot=%.2f", bid, sellSL, sellTP, g_lot);
   else
      PrintFormat("Sell leg failed: %s", trade.ResultRetcodeDescription());

   if(buyOk != sellOk)
     {
      Print("Straddle legs mismatched (one side failed to open) - closing the other leg to avoid a stray one-sided position");
      CloseAllPositions();
     }
  }

//+------------------------------------------------------------------+
int CountOpenPositions()
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != (long)InpMagicNumber)
         continue;

      count++;
     }
   return count;
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
