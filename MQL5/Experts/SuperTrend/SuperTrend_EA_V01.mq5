#property strict
#property version "1.00"
#property description "SuperTrend closed-bar reversal starter; not performance validated."
#include <Trade/Trade.mqh>

input ENUM_TIMEFRAMES InpTimeframe = PERIOD_CURRENT;
input int    InpATRPeriod = 10;
input double InpMultiplier = 3.0;
input double InpLots = 0.01;
input ulong  InpMagic = 30102601;
input ulong  InpDeviationPoints = 20;
input int    InpWarmupBars = 1000;

CTrade trade;
int atrHandle = INVALID_HANDLE;
datetime lastBar = 0;

int OnInit()
{
   if(InpATRPeriod < 1 || InpMultiplier <= 0 || InpLots <= 0 ||
      InpWarmupBars < InpATRPeriod + 100 || InpMagic == 0)
      return INIT_PARAMETERS_INCORRECT;
   double minimum = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maximum = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(step <= 0 || InpLots < minimum || InpLots > maximum ||
      MathAbs(InpLots / step - MathRound(InpLots / step)) > 1e-7)
   {
      Print("Invalid fixed lot for this broker; volume is not rounded up.");
      return INIT_PARAMETERS_INCORRECT;
   }
   atrHandle = iATR(_Symbol, InpTimeframe, InpATRPeriod);
   if(atrHandle == INVALID_HANDLE) return INIT_FAILED;
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(InpDeviationPoints);
   trade.SetAsyncMode(false);
   trade.SetTypeFillingBySymbol(_Symbol);
   // Do not enter an old signal immediately after attachment/restart.
   lastBar = iTime(_Symbol, InpTimeframe, 0);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   if(atrHandle != INVALID_HANDLE) IndicatorRelease(atrHandle);
}

// Chronological arrays: copy only closed candles, never the forming candle.
bool ReadSignal(int &direction, int &previous, double &stop)
{
   MqlRates rates[];
   double atr[];
   int count = InpWarmupBars;
   if(BarsCalculated(atrHandle) < count + InpATRPeriod + 1) return false;
   if(CopyRates(_Symbol, InpTimeframe, 1, count, rates) != count ||
      CopyBuffer(atrHandle, 0, 1, count, atr) != count) return false;
   double upper = 0, lower = 0;
   direction = 1;
   previous = 1;
   for(int i = 0; i < count; i++)
   {
      if(atr[i] == EMPTY_VALUE || !MathIsValidNumber(atr[i]) || atr[i] <= 0)
         return false;
      double mid = (rates[i].high + rates[i].low) / 2.0;
      double basicUpper = mid + InpMultiplier * atr[i];
      double basicLower = mid - InpMultiplier * atr[i];
      if(i == 0)
      {
         upper = basicUpper;
         lower = basicLower;
         continue;
      }
      double oldUpper = upper, oldLower = lower;
      upper = (basicUpper < oldUpper || rates[i-1].close > oldUpper)
              ? basicUpper : oldUpper;
      lower = (basicLower > oldLower || rates[i-1].close < oldLower)
              ? basicLower : oldLower;
      previous = direction;
      if(previous < 0 && rates[i].close > upper) direction = 1;
      else if(previous > 0 && rates[i].close < lower) direction = -1;
   }
   stop = direction > 0 ? lower : upper;
   return true;
}

bool IsOurs()
{
   return PositionGetString(POSITION_SYMBOL) == _Symbol &&
          (ulong)PositionGetInteger(POSITION_MAGIC) == InpMagic;
}

bool NettingConflict()
{
   if((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE) ==
      ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) return false;
   for(int i = PositionsTotal()-1; i >= 0; i--)
      if(PositionGetTicket(i) != 0 && PositionGetString(POSITION_SYMBOL) == _Symbol &&
         !IsOurs()) return true;
   return false;
}

bool CloseOpposite(const int direction)
{
   bool success = true;
   for(int i = PositionsTotal()-1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !IsOurs()) continue;
      bool buy = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY;
      if(buy == (direction > 0)) continue;
      bool sent = trade.PositionClose(ticket);
      if(!sent || trade.ResultRetcode() != TRADE_RETCODE_DONE || PositionSelectByTicket(ticket))
      {
         PrintFormat("Close incomplete: ticket=%I64u retcode=%u %s", ticket,
                     trade.ResultRetcode(), trade.ResultRetcodeDescription());
         success = false;
      }
   }
   return success;
}

void OnTick()
{
   datetime current = iTime(_Symbol, InpTimeframe, 0);
   if(current == 0 || current == lastBar) return;
   if(lastBar == 0) { lastBar = current; return; }
   int direction, previous;
   double stop;
   if(!ReadSignal(direction, previous, stop)) return; // Retry missing data.
   lastBar = current; // At most one order attempt per candle.
   if(NettingConflict())
   {
      Print("Foreign position on netting symbol: skipping this candle.");
      return;
   }
   // Retry failed opposite exits on later bars, even without a new reversal.
   if(!CloseOpposite(direction) || direction == previous) return;
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick)) return;
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tickSize <= 0) return;
   stop = direction > 0 ? MathFloor(stop / tickSize) * tickSize
                        : MathCeil(stop / tickSize) * tickSize;
   stop = NormalizeDouble(stop, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
   double distance = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
   if(stop <= 0 || (direction > 0 && tick.bid - stop <= distance) ||
      (direction < 0 && stop - tick.ask <= distance))
   {
      Print("SuperTrend stop invalid at current quote; entry skipped.");
      return;
   }
   bool sent = direction > 0
      ? trade.Buy(InpLots, _Symbol, 0, stop, 0, "SuperTrend V01")
      : trade.Sell(InpLots, _Symbol, 0, stop, 0, "SuperTrend V01");
   uint code = trade.ResultRetcode();
   if(!sent || (code != TRADE_RETCODE_DONE && code != TRADE_RETCODE_DONE_PARTIAL))
      PrintFormat("Entry not confirmed: retcode=%u %s", code, trade.ResultRetcodeDescription());
}
