//+------------------------------------------------------------------+
//| Sell, calc lot size based upon acct pct risk                                 |
//| Copyright © 2017 Maverus FXT                                     |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017 Maverus FXT"
#property link      ""

#property script_show_inputs // Show input prompt window.

//extern double LotSize = .1; // Lot Size
input double              Risk         = 0.5;              // Order Risk
//extern bool   UseStop = true;
//extern bool   UseTakeProfit = true;
input int StopLossPoints = 500; // Stop Loss Points
input int TakeProfitPoints = 400; // Take Profit Points
//extern string Note="0 in Entry field means Market Order Buy";
extern double Entry = 0.0000;

string Input = " Buy Price ";
double LotSize = 0;

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start() { 
  int Mode = OP_SELLSTOP;
  double tls = MarketInfo(Symbol(),MODE_LOTSIZE);
  if (Ask > Entry && Entry > 0) Mode = OP_SELLLIMIT; 
  if (Entry == 0) {
    Entry = Ask; 
    Mode = OP_SELL;
  }
  double SLB = Entry + (StopLossPoints * Point); // Point is the nbr of decimal places in the currency
  double TPB = Entry - (TakeProfitPoints * Point);
  LotSize = round(AccountFreeMargin() * (Risk / 100)) * .01;
  if(LotSize > 0)
   OrderSend(Symbol(),Mode, LotSize, Entry, 2, SLB, TPB, "Buy Script", 0, NULL, LimeGreen);
   return(0);
  }