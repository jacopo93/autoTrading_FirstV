//+------------------------------------------------------------------+
//|                                              Rsi_BB_Strategy.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict

#include "Sessions_Format.mq4"

#import "user32.dll"
   int RegisterWindowMessageW(string MessageName);
   int PostMessageW(int hwnd,int msg,int wparam,uchar &Name[]);
   int  FindWindowW(string lpszClass,string lpszWindow);
#import

#define INDICATOR_NAME "RSI"
#define INDICATOR_NAME2 "bollinger bands" //ricordarsi di verificare che nella cartella indicators sia presente il file ex4
#define VK_RETURN 13 //ENTER key



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+


// Definisci le variabili globali che manterranno i valori delle candele e dei prezzi
   double openPrice, highPrice, lowPrice, closePrice;
   double PriceAsk;
   double PriceBid;
   
//parametri delle bollinger bands 
   extern int PERIOD_BOLLINGER=20;
   double upperBand;
   double lowerBand;
   double middleBand;  
   
   double bollingerBandArr[3][3]; 
   
   
//parametri del RSI   
   extern int RSILength = 14;
   extern int BuyThreshold = 70;
   extern int SellThreshold = 30;
   
   
   
   int RSI_val;
   
   
//variabili di sistema per operazioni
   bool flagOperationBBRSI=false;  
   char typeOperation; 
 
//
   extern bool multipleOperations=false; 
   
   datetime currentCheck;
   


int OnInit()
  {
//---
   // In my code where I launch the indicator
   //int hWnd=WindowHandle(Symbol(),0);
   //StartCustomIndicator(hWnd,INDICATOR_NAME);
   //StartCustomIndicator(hWnd,INDICATOR_NAME2);
   
   SessionHoursInit();   

   return(INIT_SUCCEEDED);
  }



//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }



//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  
     //Check hour session, in case do nothing
     if(!SessionCheck()){
      ResetParameters();
      Sleep(10000);
      return ;      
     } 
  
//---
// Get candle values 
    openPrice = iOpen(Symbol(), Period(), 0);
    highPrice = iHigh(Symbol(), Period(), 0);
    lowPrice = iLow(Symbol(), Period(), 0);
    closePrice = iClose(Symbol(), Period(), 0);
    
    PriceAsk = MarketInfo(Symbol(), MODE_ASK);
    PriceBid = MarketInfo(Symbol(), MODE_BID);
    
    
    BollingerCalc();
    RSICalc();
    
    //controllo se si è creata una nuova candela
    static datetime time0; 
    bool isNewBar = (time0 != Time[0]); 
    time0 = Time[0];
    
    
    //PUNTO 1 uscita da BB e RSI
    if(RSI_val>70 && !flagOperationBBRSI){
    Print("1 cazzo" , RSI_val);
      if(bollingerBandArr[0][0] < PriceBid){
      //Print("2 cazzo");
         flagOperationBBRSI=true;
         typeOperation=83;
         currentCheck = TimeCurrent();
         //apri una posizione in sell
                
         Print("Operazione in sell Price Bid: ",PriceBid," Price Ask: ",PriceAsk, " Bollinger alto :",bollingerBandArr[0][0]);
      }   
     } 
         
    if(RSI_val<30 && !flagOperationBBRSI){
    Print("3 cazzo", RSI_val);
      if(bollingerBandArr[0][2] > PriceBid){
      //Print("4 cazzo");
         flagOperationBBRSI=true;
         typeOperation=66;
         currentCheck = TimeCurrent();
         //apri una posizione in buy
         
         Print("Operazione in buy Price Bid: ",PriceBid," Price Ask: ",PriceAsk, " Bollinger basso :",bollingerBandArr[0][2]);
      }
     } 
      
      
      //PUNTO 2 se è una nuova candela controllo che la precedente sia 
      if(isNewBar && flagOperationBBRSI){
         //Print("5 cazzo");
         if(typeOperation==checkCandleBuySell(Open[1],Close[1])){
         //Print("6 cazzo");
            //Print("ENTROOOOOOOOO in ",typeOperation," controllo iniziato alle: ",TimeToString(currentCheck));
            if(multipleOperations || OrdersTotal()==0 ){
            Print("OPERAZIONE ",OrdersTotal());
               customSendOrder();
            }   
         }
      }
      
      
      //PUNTO 3 se il prezzo tocca la middle smettiamo di controllare se è presente un'operazione
      if(flagOperationBBRSI){
         if(typeOperation==83){
            if(PriceBid<bollingerBandArr[0][1]){
               //Print("8 cazzo");
               ResetParameters();  
            }
         }      
         else if(typeOperation==66){
            if(PriceBid>bollingerBandArr[0][1]){
               //Print("9 cazzo");
               ResetParameters();
            }  
        }        
      }  
  }



//+------------------------------------------------------------------+
//| Add custom indicator on chart                                                                  |
//+------------------------------------------------------------------+
void StartCustomIndicator(int hWnd,string IndicatorName,bool AutomaticallyAcceptDefaults=true)
{
   uchar name2[];
   StringToCharArray(IndicatorName,name2,0,StringLen(IndicatorName));

   int MessageNumber=RegisterWindowMessageW("MetaTrader4_Internal_Message");
   int r=PostMessageW(hWnd,MessageNumber,15,name2);
   
   Sleep(100);
   
   if(AutomaticallyAcceptDefaults) {
      int ind_settings = FindWindowW(NULL, "Custom Indicator - "+IndicatorName);
      PostMessageW(ind_settings,0x100,VK_RETURN,name2);
   }
   
}


//+------------------------------------------------------------------+
//| Calculate bollinger band                                                              |
//+------------------------------------------------------------------+
void BollingerCalc(){

   //BOLLINGER
   
   bollingerBandArr[0][0] = iBands(Symbol(), 0, PERIOD_BOLLINGER, 2, 0, PRICE_CLOSE, MODE_UPPER,0);
   bollingerBandArr[0][1] = iBands(Symbol(), 0, PERIOD_BOLLINGER, 2, 0, PRICE_CLOSE, MODE_MAIN,0);
   bollingerBandArr[0][2] = iBands(Symbol(), 0, PERIOD_BOLLINGER, 2, 0, PRICE_CLOSE, MODE_LOWER,0);

   bollingerBandArr[1][0] = iBands(Symbol(), 0, PERIOD_BOLLINGER, 2, 0, PRICE_CLOSE, MODE_UPPER,1);
   bollingerBandArr[1][1] = iBands(Symbol(), 0, PERIOD_BOLLINGER, 2, 0, PRICE_CLOSE, MODE_MAIN,1);
   bollingerBandArr[1][2] = iBands(Symbol(), 0, PERIOD_BOLLINGER, 2, 0, PRICE_CLOSE, MODE_LOWER,1);
   
   bollingerBandArr[2][0] = iBands(Symbol(), 0, PERIOD_BOLLINGER, 2, 0, PRICE_CLOSE, MODE_UPPER,2);
   bollingerBandArr[2][1] = iBands(Symbol(), 0, PERIOD_BOLLINGER, 2, 0, PRICE_CLOSE, MODE_MAIN,2);
   bollingerBandArr[2][2] = iBands(Symbol(), 0, PERIOD_BOLLINGER, 2, 0, PRICE_CLOSE, MODE_LOWER,2);   


}


//+------------------------------------------------------------------+
//| Calculate RSI parameters                                                             |
//+------------------------------------------------------------------+
void RSICalc(){

   RSI_val = iRSI(NULL, 0 , RSILength, PRICE_CLOSE, 0);

}



//+------------------------------------------------------------------+
//| Return S if candle is sell and B if candle is buy                                                             |
//+------------------------------------------------------------------+
int checkCandleBuySell(double open,double close){
   
   if(close < open)
      return 83;
   else
      return 66;   

}




//+------------------------------------------------------------------+
//| send effective order                                                            |
//+------------------------------------------------------------------+
void customSendOrder(){

   // We define the basic data.
   double StopLoss=5;     // Stop-Loss in pips
   double TakeProfit=10;   // Take-Profit in pips
   double LotSize=0.05;    // Lot size in lots
   double Slippage=1;      // Slippage in pips
   double Command=typeOperation == 66 ? OP_BUY : OP_SELL;  // Type of order, BUY
   
   // The data is prepared to be used in the OrderSend function,
   // so we calculate the SL and TP prices and normalize them.
   // We also normalize the Slippage in case the decimals are 3 or 5.
   double nDigits=CalculateNormalizedDigits();
   double OpenPrice=NormalizeDouble(Ask,Digits);
   
   
   
   double StopLossPrice;
   double TakeProfitPrice;
   
   if(Command == OP_BUY){
      StopLossPrice=NormalizeDouble(Ask-StopLoss*nDigits,Digits);
      TakeProfitPrice=NormalizeDouble(Ask+TakeProfit*nDigits,Digits);
   }
   else{
      StopLossPrice=NormalizeDouble(Ask+StopLoss*nDigits,Digits);
      TakeProfitPrice=NormalizeDouble(Ask-TakeProfit*nDigits,Digits);   
   }
   
   
   
   
   if(Digits==3 || Digits==5){
      Slippage=Slippage*10;
   }
   
   // We define a variable to store and store the result of the function.
   int OrderNumber;
   OrderNumber=OrderSend(Symbol(),Command,LotSize,OpenPrice,Slippage,StopLossPrice,TakeProfitPrice);
   
   // We verify if the order has gone through or not and print the result.
   if(OrderNumber>0){
      Print("Order ",OrderNumber," open");
   }
   else{
      Print("Order failed with error - ",GetLastError());
   }
   
   //resetto i parametri cosi che possa iniziare un altra operazione
   ResetParameters();

}


//+------------------------------------------------------------------+
//|                                                             |
//+------------------------------------------------------------------+
double CalculateNormalizedDigits()
{
   if(Digits<=3){
      return(0.01);
   }
   else if(Digits>=4){
      return(0.0001);
   }
   else return(0);
}


//+------------------------------------------------------------------+
//|Reset checking operation, reset di tutti i parametri e ricomincia controllare                                                          |
//+------------------------------------------------------------------+
void ResetParameters(){

   flagOperationBBRSI=false;

}