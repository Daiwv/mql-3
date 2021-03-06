//+------------------------------------------------------------------+
//|                                                  GECloseOpen.mq4 |
//|                                  Copyright 2017, Maverus FXT LLC |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Maverus FXT LLC"
#property link      ""
#property version   "1.00"
#property strict
#property script_show_inputs // Show input prompt window.

input double              Risk         = 1.0;              // Account Risk
input string              OrderType    = "AUTO";           // Order Type (AUTO=Opposite of prior trade)
input bool                ClosePrv     = TRUE;             // Close all previous GE Trade(s)?

input string inst00 = NULL; // Instructions:
input string inst10 = NULL; // Risk is the percent of account (1.0%)
input string inst11 = NULL; // based upon Account Equity.
input string inst20 = NULL; // Order Types: Auto, Buy, Sell.
input string inst30 = NULL; // Enable Auto Trading to use this script.
input string inst40 = NULL; // If no Active GE Trades and Order Type
input string inst50 = NULL; // is Auto, a Buy order will be created.
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
int start() {
  int total=OrdersTotal(), Mode = OP_BUY;
  string prvOrderType, chartSymbol;
  double LotSize = 0;

  string ott = OrderType;
  StringToUpper( ott);
   //--- Checks the input parameters
  if(ott != "AUTO" && ott != "BUY" && ott != "SELL") {
    MessageBox("Please select Order Type (AUTO, BUY, SELL)."); 
    return(0);
  }
  if(ott == "AUTO" && ! ClosePrv) {
    MessageBox("If you choose AUTO Order Type, you must also set Close Previous to true."); 
    return(0);
  }
  
  chartSymbol = ChartSymbol();
  
  // loop through the open orders find the previous order(s) to close.
  if ( ClosePrv) {
    for(int pos=0; pos<total; pos++) {
      if ( OrderSelect(pos,SELECT_BY_POS)==false) continue; // didn’t return order so loop again
      string oc = OrderComment();
      if ( OrderComment() != "GE Trade") continue; // Comment didn't match order placed by script
        if ( OrderSymbol() != chartSymbol) continue; // trade doesn't match current chart.
      int ot = OrderType();
      if ( ot == OP_BUY || ot == OP_BUYLIMIT || ot == OP_BUYSTOP) {
        prvOrderType = "Buy";
      }
      if ( ot == OP_SELL || ot == OP_SELLLIMIT || ot == OP_SELLSTOP) {
        prvOrderType = "Sell";
      }
      // For a sell order, we entered at the Bid price and exit at the Ask price
      bool closeSuccess = false;
      if (prvOrderType == "Sell") { 
        closeSuccess = OrderClose( OrderTicket(), OrderLots(), Ask, 2, CLR_NONE);
      }
      // For a buy order, we entered at the ask price and exit at the Bid price
      if (prvOrderType == "Buy") { 
        closeSuccess = OrderClose( OrderTicket(), OrderLots(), Bid, 2, CLR_NONE);
      }
      if ( ! closeSuccess) {
       MessageBox("Close of order failed. " + GetLastError());
      }
      //break;
    } // end search for order(s) to close
  }
  // Prep info for new order.
  if (prvOrderType == "Buy") {
    Mode = OP_SELL;
  } else if (prvOrderType == "Sell") {
    Mode = OP_BUY;
  }
  // Override auto order type with the order type entered in the prompt, if Buy or Sell.
  if (ott == "SELL") { Mode = OP_SELL;}
  if (ott == "BUY") { Mode = OP_BUY;}
  
  LotSize = round(AccountEquity() * (Risk / 100)) * .01; // multiplying by .01 gives two dec places.
  if(LotSize > 0) {
    // For a sell order, we open the trade using the Bid price
    int newOrderNbr = 0;
    if ( Mode == OP_SELL) {
      newOrderNbr = OrderSend( Symbol(), Mode, LotSize, Bid, 2, 0, 0, "GE Trade", 0, NULL, CLR_NONE);
    }
    // For a buy order, we open the trade using the Ask price
    if ( Mode == OP_BUY) {
      newOrderNbr = OrderSend( Symbol(), Mode, LotSize, Ask, 2, 0, 0, "GE Trade", 0, NULL, CLR_NONE);
    }
    if (newOrderNbr == -1) { // order failed
      MessageBox("Creation of new order failed. " + GetLastError());
    }
  }
  return(0);
 }