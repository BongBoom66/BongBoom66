//+------------------------------------------------------------------+
//|                                          GridHedge_XAUUSD.mq5    |
//|  SR + Wick Rejection + Volume Strength EA for Gold (XAUUSD),      |
//|  Exness Cent.                                                     |
//|                                                                    |
//|  Strategy (evaluated once per closed candle on InpTimeframe,       |
//|  never on the still-forming candle, to avoid repainting):          |
//|   - SUPPORT/RESISTANCE: scans the last InpSRLookbackBars candles    |
//|     for fractal pivots (a bar whose high/low is the most extreme    |
//|     among InpSRFractalWing bars on each side of it) and keeps the   |
//|     nearest fractal-high as resistance, nearest fractal-low as      |
//|     support, relative to the just-closed candle.                    |
//|   - WICK REJECTION: on the just-closed candle, a lower wick at      |
//|     least InpWickRatio times the candle body counts as a bullish     |
//|     rejection (buyers defended that level); an upper wick at least  |
//|     InpWickRatio times the body counts as a bearish rejection.       |
//|   - STRENGTH: the rejection candle's tick volume must be at or       |
//|     above the average of the InpVolumeAvgBars candles before it -    |
//|     used as a proxy for real buy/sell pressure behind the wick       |
//|     (MT5 forex feeds do not carry real traded volume).               |
//|   - ENTRY: a Buy fires only when ALL THREE align - the candle's       |
//|     low is within InpSRToleranceUSD of a support level, it shows a   |
//|     bullish rejection wick, and volume is above average. A Sell       |
//|     fires the mirror case at resistance. Only one position is open   |
//|     at a time; the next candle is not evaluated again until a new    |
//|     bar opens.                                                       |
//+------------------------------------------------------------------+
#property copyright "SR + Wick + Strength EA"
#property version   "4.00"
#property strict

#include <Trade\Trade.mqh>

input group "=== Trade settings ==="
input double InpLotSize          = 0.2;         // Lot size per order
input double InpTakeProfitUSD    = 12.0;        // Take profit distance from entry price ($)
input double InpStopLossUSD      = 10.0;        // Stop loss distance from entry price ($)
input int    InpSlippagePoints   = 30;          // Max slippage for market orders (points)

input group "=== Support / Resistance ==="
input ENUM_TIMEFRAMES InpTimeframe = PERIOD_M15; // Candle timeframe used for analysis
input int    InpSRLookbackBars   = 150;         // How many bars back to scan for SR pivots
input int    InpSRFractalWing    = 3;           // Bars required on each side to confirm a pivot
input double InpSRToleranceUSD   = 1.0;         // Max distance from a SR level to count as "at" it ($)

input group "=== Wick rejection ==="
input double InpWickRatio        = 2.0;         // Wick must be at least this many times the candle body

input group "=== Volume strength ==="
input int    InpVolumeAvgBars    = 20;          // Bars used to compute the average tick volume baseline

input group "=== Identification ==="
input ulong  InpMagicNumber      = 20260802;    // Magic number, keeps this EA's trades separate

CTrade trade;

double   g_lot;             // normalized lot size actually sent to broker
datetime g_lastEvaluatedBar; // opening time of the last closed bar we already evaluated

//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpSlippagePoints);
   trade.SetTypeFillingBySymbol(_Symbol);

   g_lot = NormalizeLot(InpLotSize);
   g_lastEvaluatedBar = 0;

   double minStopDistance = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(minStopDistance > 0.0 && (InpTakeProfitUSD < minStopDistance || InpStopLossUSD < minStopDistance))
      PrintFormat("WARNING: broker minimum stop distance is %.2f - InpTakeProfitUSD (%.2f) or InpStopLossUSD (%.2f) is tighter than that, orders may be rejected as invalid stops",
                  minStopDistance, InpTakeProfitUSD, InpStopLossUSD);

   if(InpSRLookbackBars <= InpSRFractalWing * 2 + 2)
     {
      Print("InpSRLookbackBars must be large enough to hold pivots given InpSRFractalWing");
      return INIT_PARAMETERS_INCORRECT;
     }

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
   if(HasOpenPosition())
     {
      Comment("GridHedge_XAUUSD (SR + Wick + Strength)\nPosition open, waiting for TP/SL...");
      return;
     }

   datetime barTime = iTime(_Symbol, InpTimeframe, 0);
   if(barTime == 0)
      return;
   if(barTime == g_lastEvaluatedBar)
      return; // already evaluated the currently-closed bar, wait for the next one
   g_lastEvaluatedBar = barTime;

   EvaluateSignal();
  }

//+------------------------------------------------------------------+
void EvaluateSignal()
  {
   // Shift 1 = the most recently CLOSED candle (shift 0 is still forming)
   double open1  = iOpen(_Symbol, InpTimeframe, 1);
   double high1  = iHigh(_Symbol, InpTimeframe, 1);
   double low1   = iLow(_Symbol, InpTimeframe, 1);
   double close1 = iClose(_Symbol, InpTimeframe, 1);
   if(high1 <= 0.0 || low1 <= 0.0)
      return;

   double body       = MathAbs(close1 - open1);
   double upperWick   = high1 - MathMax(open1, close1);
   double lowerWick   = low1 <= 0 ? 0 : MathMin(open1, close1) - low1;

   double avgVolume = AverageVolume(2, InpVolumeAvgBars + 1); // bars before the signal candle
   long   signalVolume = iVolume(_Symbol, InpTimeframe, 1);
   bool   strongVolume = avgVolume > 0.0 && signalVolume >= avgVolume;

   bool bullishRejection = body > 0.0 && lowerWick >= InpWickRatio * body && strongVolume;
   bool bearishRejection = body > 0.0 && upperWick >= InpWickRatio * body && strongVolume;

   double support = 0.0, resistance = 0.0;
   bool hasSupport    = FindNearestFractal(true, low1, support);
   bool hasResistance = FindNearestFractal(false, high1, resistance);

   if(bullishRejection && hasSupport && MathAbs(low1 - support) <= InpSRToleranceUSD)
     {
      PrintFormat("BUY signal: support=%.2f, low=%.2f, body=%.2f, lowerWick=%.2f, volume=%d (avg %.1f)",
                  support, low1, body, lowerWick, signalVolume, avgVolume);
      OpenOrder(ORDER_TYPE_BUY);
     }
   else if(bearishRejection && hasResistance && MathAbs(high1 - resistance) <= InpSRToleranceUSD)
     {
      PrintFormat("SELL signal: resistance=%.2f, high=%.2f, body=%.2f, upperWick=%.2f, volume=%d (avg %.1f)",
                  resistance, high1, body, upperWick, signalVolume, avgVolume);
      OpenOrder(ORDER_TYPE_SELL);
     }
  }

//+------------------------------------------------------------------+
// Average tick volume over bars [fromShift, toShift] (inclusive), both measured from the current bar
double AverageVolume(int fromShift, int toShift)
  {
   long total = 0;
   int  count = 0;
   for(int shift = fromShift; shift <= toShift; shift++)
     {
      long vol = iVolume(_Symbol, InpTimeframe, shift);
      if(vol <= 0)
         continue;
      total += vol;
      count++;
     }
   if(count == 0)
      return 0.0;
   return (double)total / count;
  }

//+------------------------------------------------------------------+
// Scans shift 2..InpSRLookbackBars+1 (bars before the signal candle) for fractal pivots and
// returns the one nearest to refPrice. findLow=true looks for fractal lows (support),
// false looks for fractal highs (resistance).
bool FindNearestFractal(bool findLow, double refPrice, double &result)
  {
   int wing = InpSRFractalWing;
   bool found = false;
   double bestDistance = 0.0;

   int firstShift = 2 + wing;
   int lastShift   = 2 + InpSRLookbackBars - wing;

   for(int shift = firstShift; shift <= lastShift; shift++)
     {
      bool isPivot = true;
      double pivotPrice = findLow ? iLow(_Symbol, InpTimeframe, shift) : iHigh(_Symbol, InpTimeframe, shift);

      for(int w = 1; w <= wing && isPivot; w++)
        {
         double left  = findLow ? iLow(_Symbol, InpTimeframe, shift - w) : iHigh(_Symbol, InpTimeframe, shift - w);
         double right = findLow ? iLow(_Symbol, InpTimeframe, shift + w) : iHigh(_Symbol, InpTimeframe, shift + w);

         if(findLow)
           {
            if(left <= pivotPrice || right <= pivotPrice)
               isPivot = false;
           }
         else
           {
            if(left >= pivotPrice || right >= pivotPrice)
               isPivot = false;
           }
        }

      if(!isPivot)
         continue;

      double distance = MathAbs(pivotPrice - refPrice);
      if(!found || distance < bestDistance)
        {
         found = true;
         bestDistance = distance;
         result = pivotPrice;
        }
     }

   return found;
  }

//+------------------------------------------------------------------+
void OpenOrder(ENUM_ORDER_TYPE type)
  {
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double refPrice = (type == ORDER_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
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
