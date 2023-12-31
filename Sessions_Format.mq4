//+------------------------------------------------------------------+
//|                                              Sessions_Format.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <WinUser32.mqh>
#include <stdlib.mqh>

#define orarioSize 5
 
 //orario sessioni
   extern bool sessionsFlag = true;
   extern string sessions="08:00-12:00"; //Max 5 sessions hh:mm-hh:mm,hh:mm-hh:mm ..   
   
   
  
   struct Orario {
      int hour1;
      int minute1;
      int hour2;
      int minute2;
      Orario() {
	      hour1 = 99;minute1 = 99;hour2 = 99;minute2 = 99;
      }
   }; 

   Orario orario[orarioSize];
   
   
bool IsValidTimeFormat(string timeStr) {
    int len = StringLen(timeStr);
    int currentIndex = 0;
    int counter = 0;
    
    

    while (currentIndex < len) {
        // Controlla se c'è un blocco "hh:mm-hh:mm"
      if (currentIndex + 11 <= len &&
            timeStr[currentIndex + 2] == ':' && timeStr[currentIndex + 5] == '-' &&
            timeStr[currentIndex + 8] == ':') {
            
            int hour1 = StrToInteger(StringSubstr(timeStr, currentIndex, 2));
            int minute1 = StrToInteger(StringSubstr(timeStr, currentIndex + 3, 2));
            int hour2 = StrToInteger(StringSubstr(timeStr, currentIndex + 6, 2));
            int minute2 = StrToInteger(StringSubstr(timeStr, currentIndex + 9, 2));
                        

            if (hour1 < 0 || hour1 > 23 || minute1 < 0 || minute1 > 59 ||
                hour2 < 0 || hour2 > 23 || minute2 < 0 || minute2 > 59) {
                return false;
            }
            
            orario[counter].hour1=hour1;
            orario[counter].minute1=minute1;
            orario[counter].hour2=hour2;
            orario[counter].minute2=minute2;            

            currentIndex += 12; // Passa al blocco successivo
            counter += 1;
        } else {
            return false; // Formato non valido
        }
    }

    return true;
}

void SessionHoursInit() {
    
    bool isValid = IsValidTimeFormat(sessions);

    if(isValid){
        Print("La stringa ha il formato corretto hh:mm-hh:mm,hh:mm-hh:mm,...");
    }else{
        Print("La stringa NON ha il formato corretto hh:mm-hh:mm,hh:mm-hh:mm,...");
    }
}



bool SessionCheck(){

   datetime currentTime = TimeCurrent();
   int currentHour = Hour();
   int currentMinute = Minute();
   
   int convertedTime=currentHour*100+currentMinute;
   
   if(!sessionsFlag)
      return true;
   else   
      for(int i=0; i<orarioSize ; i++){
         if((orario[i].hour1*100+orario[i].minute1)<=convertedTime && convertedTime<=(orario[i].hour2*100+orario[i].minute2))
            return true;   
      } 
   
   return false;

}