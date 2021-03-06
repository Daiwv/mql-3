//+------------------------------------------------------------------+
//| Sell, calc lot size based upon acct pct risk                                 |
//| Copyright © 2017 Maverus FXT                                     |
//|                                                                  |
//| Sell orders open trades at Bid price and close at Ask price so this   
//| script will open the trade using the Bid price and calc S/L and  |
//| T/P using Bid price as well.                                     |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017 Maverus FXT"
#property link      ""
#property strict
#property script_show_inputs // Show input prompt window.

input double              Risk         = 0.5;              // Order Risk
input int StopLossPoints = 500; // Stop Loss *Points*
input int TakeProfitPoints = 400; // Take Profit *Points*
extern double Entry = 0.0000; // Entry Price (0=Market)
input string orderComment = "Sell Market Risk"; // Order Comment

//string Input = " Buy Price ";
double LotSize = 0;

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start() { 
  int Mode = OP_SELLSTOP;
  double tls = MarketInfo(Symbol(),MODE_LOTSIZE);
  if (Bid > Entry && Entry > 0) Mode = OP_SELLLIMIT; 
  if (Entry == 0) {
    Entry = Bid; 
    Mode = OP_SELL;
  }
  double SLB = Entry + (StopLossPoints * Point); // Point is the nbr of decimal places in the currency
  double TPB = Entry - (TakeProfitPoints * Point);
  LotSize = round(AccountEquity() * (Risk / 100)) * .01;
  if(LotSize > 0) {
   int newOrderNbr = OrderSend(Symbol(),Mode, LotSize, Entry, 2, SLB, TPB, orderComment, 0, NULL, CLR_NONE);
   if (newOrderNbr == -1) {
     MessageBox("Creation of new order failed. " + GetLastError());
   }
  }
  return(0);
}