//+------------------------------------------------------------------+
//|                                              Sessions_Format.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <WinUser32.mqh>
#include <stdlib.mqh>
 
 //orario sessioni
   extern string sessions="08:00-12:00"; //session hh:mm-hh:mm,hh:mm-hh:mm ...
   
   
	bool IsValidTimeFormat(string timeStr) {
    int len = StringLen(timeStr);
    int currentIndex = 0;

    while (currentIndex < len) {
        // Controlla se c'è un blocco "hh:mm-hh:mm"
      if (currentIndex + 11 <= len &&
            timeStr[currentIndex + 2] == ':' && timeStr[currentIndex + 5] == '-' &&
            timeStr[currentIndex + 8] == ':') {
            
            int hour1 = StrToInteger(StringSubstr(timeStr, currentIndex, 2));
            int minute1 = StrToInteger(StringSubstr(timeStr, currentIndex + 3, 2));
            int hour2 = StrToInteger(StringSubstr(timeStr, currentIndex + 6, 2));
            int minute2 = StrToInteger(StringSubstr(timeStr, currentIndex + 9, 2));
            
            Print(hour1," ",minute1," ",hour2," ",minute2);

            if (hour1 < 0 || hour1 > 23 || minute1 < 0 || minute1 > 59 ||
                hour2 < 0 || hour2 > 23 || minute2 < 0 || minute2 > 59) {
                return false;
            }

            currentIndex += 12; // Passa al blocco successivo
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