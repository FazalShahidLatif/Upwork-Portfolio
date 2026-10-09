//+------------------------------------------------------------------+
//|                                          RiskManager.mq5         |
//|                        Copyright 2026, Fazal Shahid Latif         |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Fazal Shahid Latif"
#property link      "https://github.com/FazalShahidLatif"
#property version   "1.00"
#property strict

#include <Trade/Trade.mqh>

input double RiskPercent = 1.0;
input int StopLossPips = 50;
input int TakeProfitPips = 100;
input int MaxDrawdownPercent = 20;

CTrade trade;

bool CalculateLotSize(double stopLoss)
{
    double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    double riskAmount = accountEquity * RiskPercent / 100.0;
    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    
    if(tickValue == 0 || tickSize == 0) return false;
    
    double lotSize = riskAmount / (stopLoss * tickValue / tickSize);
    lotSize = MathFloor(lotSize / 0.01) * 0.01;
    lotSize = MathMax(lotSize, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN));
    lotSize = MathMin(lotSize, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX));
    
    return lotSize;
}

void OnTick()
{
    double currentDrawdown = CalculateDrawdown();
    if(currentDrawdown >= MaxDrawdownPercent)
    {
        Print("Max drawdown reached: ", currentDrawdown, "% - Trading suspended");
        return;
    }
}

double CalculateDrawdown()
{
    static double maxEquity = 0;
    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    
    if(currentEquity > maxEquity) maxEquity = currentEquity;
    if(maxEquity == 0) return 0;
    
    return (maxEquity - currentEquity) / maxEquity * 100.0;
}
//+------------------------------------------------------------------+
