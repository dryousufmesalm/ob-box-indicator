//+------------------------------------------------------------------+
//|                                            OB Box.mq5 |
//|                                    Copyright 2025, Yousuf Mesalm. |
//|  www.yousufmesalm.com | WhatsApp +201006179048 | Upwork: https://www.upwork.com/freelancers/youssefmesalm |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Yousuf Mesalm. www.yousufmesalm.com | WhatsApp +201006179048"
#property description "Owner:  Tim Hutter."
#property description "Company:   FXC Signals."

#property link      "https://www.yousufmesalm.com"
#property link      "https://www.yousufmesalm.com"
#property link      "https://www.yousufmesalm.com"
#property description      "Developed by Yousuf Mesalm"
#property description      "https://www.Yousuf-mesalm.com"
#property description      "https://www.upwork.com/freelancers/~0148d869d9334a576e"
#property description      "https://www.mql5.com/en/job/new?prefered=20163440"
//#property icon "logo.ico"
#property version   "1.00"
#property indicator_chart_window   //Indicator in chart window              
#property indicator_buffers 10
#property indicator_plots 5     //Number of graphic plots                
#property indicator_label1 "buy"
#property indicator_label2 "buy sl"
#property indicator_label3 "sell"
#property indicator_label4 "sell sl"
#property indicator_label5 "Open;High;Low;Close"
#property indicator_type5 DRAW_COLOR_CANDLES   //Drawing style color candles
#property indicator_width5 3       //Width of the graphic plot  



#define  Name "OB Boxes"

//Declaration of buffers
double buf_open[],buf_high[],buf_low[],buf_close[];//Buffers for data
double buf_color_line[];  //Buffer for color indexes


double buy[],sell[],BuySL[],SellSl[];

//Inputs
input int InpCandlesTotal                             = 500;   // Total candles to run the calculation on
input double boxMax                                      =40;    // Box Max Height
input double boxMin                                      =10;     // Box Min Height
input string Group1                                   ="========================Chart Customization Candles==========================";
input color bearCandlecolor                           = clrRed;                  // Bearish OB Candle
input color bullcandlecolor                           = clrLimeGreen;            // Bullish OB Candle
//input uchar adtranspCandle                              = 0x65;                      // Candle Transparency
input string Group2                                   ="========================Chart Customization Box==========================";
input color bearboxcolor                              = clrRed;                  // Bearish OB Box
input color bullboxcolor                              = clrLimeGreen ;           // Bullish OB Box
input bool showOBboxes                                = true;                    // Show OB Boxes
//input uchar adtransp                                    = 65;                      // Box Transparency
input int adboxcount                                  = 50;                      //Maximum Box Displayed
bool draw=true;
string boxes[];
//+------------------------------------------------------------------+
//|  www.yousufmesalm.com | WhatsApp +201006179048 | Upwork: https://www.upwork.com/freelancers/youssefmesalm |
//+------------------------------------------------------------------+
void OnTesterInit()
  {
   draw=false;
//---
  }
  void OnTesterDeinit()
  {
//--- optimization duration

  }
//+------------------------------------------------------------------+
//|  www.yousufmesalm.com | WhatsApp +201006179048 | Upwork: https://www.upwork.com/freelancers/youssefmesalm |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//Assign the arrays with the indicator's buffers
   SetIndexBuffer(0,buy,INDICATOR_DATA);
   SetIndexBuffer(1,BuySL,INDICATOR_DATA);
   SetIndexBuffer(2,sell,INDICATOR_DATA);
   SetIndexBuffer(3,SellSl,INDICATOR_DATA);
   SetIndexBuffer(4,buf_open,INDICATOR_DATA);
   SetIndexBuffer(5,buf_high,INDICATOR_DATA);
   SetIndexBuffer(6,buf_low,INDICATOR_DATA);
   SetIndexBuffer(7,buf_close,INDICATOR_DATA);

   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,0);
   SetIndexBuffer(8,buf_color_line,INDICATOR_COLOR_INDEX);

//Assign the array with color indexes with the indicator's color indexes buffer
   PlotIndexSetInteger(4,PLOT_COLOR_INDEXES,4);
//Set color for each index
   PlotIndexSetInteger(4,PLOT_LINE_COLOR,0,bullcandlecolor);  // 0th index Color_Bar_Up_0
   PlotIndexSetInteger(4,PLOT_LINE_COLOR,1,bearCandlecolor); // 1st index Color_Bar_Down_0

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|  www.yousufmesalm.com | WhatsApp +201006179048 | Upwork: https://www.upwork.com/freelancers/youssefmesalm |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectsDeleteAll(0,-1,-1);

  }
//+------------------------------------------------------------------+
//|  www.yousufmesalm.com | WhatsApp +201006179048 | Upwork: https://www.upwork.com/freelancers/youssefmesalm |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(buf_close,true);
   ArraySetAsSeries(buf_high,true);
   ArraySetAsSeries(buf_low,true);
   ArraySetAsSeries(buf_open,true);
   ArraySetAsSeries(buf_color_line,true);
   ArraySetAsSeries(buy,true);
   ArraySetAsSeries(sell,true);
   ArraySetAsSeries(BuySL,true);
   ArraySetAsSeries(SellSl,true);
   int limit = 0;
   if(prev_calculated != rates_total)
      limit=0;
   if(prev_calculated == 0)
     {
      limit = rates_total-3;
      limit = MathMin(limit,InpCandlesTotal);

     }
   for(int i=limit; i>=0; i--)
     {
      //In the loop we fill the data buffers and color indexes buffers for each bar
      double highBarNext = high[i];
      double lowBarNext = low[i];
      double highBarPrevious = high[i+2];
      double lowBarPrevious = low[i+2];
      double openBarPrevious = open[i+2];
      double closeBarPrevious = close[i+2];
      double openBarCurrent = open[i+1];
      double closeBarCurrent = close[i+1];
      int offset = 2;
      //bar_index_ = bar_index[offset]
      //If the Candle in index of 1 (the candle being detected as engulfing and imbalanced) and the next candle does not fill the imbalance, then a signal is generated.
      bool bullishEngulfing = openBarCurrent <= closeBarPrevious && openBarCurrent < openBarPrevious &&
                              closeBarCurrent > openBarPrevious && lowBarNext > highBarPrevious;
      bool bearishEngulfing = openBarCurrent >= closeBarPrevious && openBarCurrent > openBarPrevious &&
                              closeBarCurrent < openBarPrevious && highBarNext < lowBarPrevious;
      int shift=i+offset;

      //Plot OB Candles
      if(bullishEngulfing)
        {
         buf_open[shift]=open[shift];
         buf_high[shift]=high[shift];
         buf_low[shift]=low[shift];
         buf_close[shift]=close[shift];
         buf_color_line[shift]=0;//Assign the bar with color index, equal to 0
        }
      if(bearishEngulfing)
        {
         buf_open[shift]=open[shift];
         buf_high[shift]=high[shift];
         buf_low[shift]=low[shift];
         buf_close[shift]=close[shift];
         buf_color_line[shift]=1;//Assign the bar with color index, equal to 0
        }

      //Box Color Variables
      //color adbearboxcolor       = ColorToARGB(bearboxcolor, adtransp);
      //color adbullboxcolor       = ColorToARGB(bullboxcolor,  adtransp);
      //uint adbearborderboxcolor = ColorToARGB(bearboxcolor, adtransp);
      //uint adbullborderboxcolor = ColorToARGB(bullboxcolor,  adtransp);
      //Bearish OB Box Plotting
      if(bearishEngulfing && showOBboxes)
        {
         double boxhighzone = high[i+2] > high[i+1] ? high[i+2] : high [i+1];
         double boxlowzone  = open[i+2];
         double boxHeight=boxhighzone-boxlowzone;
         if(boxHeight<boxMax*Point()*10&&boxHeight>=boxMin*10*Point())
           {
            string name=Name+"bear"+TimeToString(time[shift])+(string)boxhighzone+(string)boxlowzone;
            if(draw)
               RectangleCreate(0,name,0,time[shift],boxhighzone,time[i],boxlowzone,bearboxcolor,STYLE_DASH,1,true,true,false,false,0);
            sell[i]=boxlowzone;
            SellSl[i]=boxhighzone;
            int size=ArraySize(boxes);
            if(size<adboxcount)
              {
               ArrayResize(boxes,size+1,size+1);
               boxes[size]=name;
              }
            else
              {
               if(draw)
                  RectangleDelete(0,boxes[0]);
               for(int x=0; x<size; x++)
                 {
                  if(x==size-1)
                     boxes[x]=name;
                  else
                     boxes[x]=boxes[x+1];
                 }
              }
           }
        }


      //Bullish OB Box Plotting

      if(bullishEngulfing && showOBboxes)
        {
         double boxlowzone  = low[i+1] < low[i+2] ? low [i+1] : low [i+2];
         double boxhighzone = open[i+2];
         double boxHeight=boxhighzone-boxlowzone;
         if(boxHeight<boxMax*Point()*10&&boxHeight>=boxMin*10*Point())
           {
            string name=Name+"bull"+TimeToString(time[shift])+(string)boxhighzone+(string)boxlowzone;
            if(draw)

               RectangleCreate(0,name,0,time[shift],boxhighzone,time[i],boxlowzone,bullboxcolor,STYLE_DASH,1,true,true,false,false,0);
            buy[i]=boxhighzone;
            BuySL[i]=boxlowzone;
            int size=ArraySize(boxes);
            if(size<adboxcount)
              {
               ArrayResize(boxes,size+1,size+1);
               boxes[size]=name;
              }
            else
              {
               if(draw)

                  RectangleDelete(0,boxes[0]);
               for(int x=0; x<size; x++)
                 {
                  if(x==size-1)
                     boxes[x]=name;
                  else
                     boxes[x]=boxes[x+1];

                 }
              }
           }
        }

      for(int x =ObjectsTotal(0,0,-1)-1; x>=0; x--)
        {
         string name=ObjectName(0,x,0,-1);
         if(StringFind(name,Name+"bear",0)>=0)
           {
            double boxhighzone=ObjectGetDouble(0,name,OBJPROP_PRICE,0);
            double boxlowzone=ObjectGetDouble(0,name,OBJPROP_PRICE,1);
            long boxrightzone=ObjectGetInteger(0,name,OBJPROP_TIME,1);
            long boxleftzone=ObjectGetInteger(0,name,OBJPROP_TIME,0);
            if(time[i+1] == boxrightzone && !((high[i] > boxlowzone && low[i] < boxlowzone) || (high[i] > boxhighzone && low[i] < boxhighzone)))
              {
               if(draw)
                  RectangleDelete(0,name);
               if(draw)
                  RectangleCreate(0,name,0,boxleftzone,boxhighzone,time[i],boxlowzone,bearboxcolor,STYLE_DASH,1,true,true,false,false,0);
              }
           }
         if(StringFind(name,Name+"bull",0)>=0)
           {
            double boxhighzone=ObjectGetDouble(0,name,OBJPROP_PRICE,0);
            double boxlowzone=ObjectGetDouble(0,name,OBJPROP_PRICE,1);
            long boxrightzone=ObjectGetInteger(0,name,OBJPROP_TIME,1);
            long boxleftzone=ObjectGetInteger(0,name,OBJPROP_TIME,0);

            if((time[i + 1 ]== boxrightzone && !((high[i] > boxlowzone && low[i] < boxlowzone) || (high[i] > boxhighzone && low[i] < boxhighzone))))
              {
               if(draw)
                  RectangleDelete(0,name);
               if(draw)
                  RectangleCreate(0,name,0,boxleftzone,boxhighzone,time[i],boxlowzone,bullboxcolor,STYLE_DASH,1,true,true,false,false,0);
              }
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|  www.yousufmesalm.com | WhatsApp +201006179048 | Upwork: https://www.upwork.com/freelancers/youssefmesalm |
//+------------------------------------------------------------------+
bool RectangleCreate(const long            chart_ID=0,        // chart's ID
                     const string          name="Rectangle",  // rectangle name
                     const int             sub_window=0,      // subwindow index
                     datetime              time1=0,           // first point time
                     double                price1=0,          // first point price
                     datetime              time2=0,           // second point time
                     double                price2=0,          // second point price
                     const color           clr=clrRed,        // rectangle color
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // style of rectangle lines
                     const int             width=1,           // width of rectangle lines
                     const bool            fill=false,        // filling rectangle with color
                     const bool            back=false,        // in the background
                     const bool            selection=true,    // highlight to move
                     const bool            hidden=true,       // hidden in the object list
                     const long            z_order=0)         // priority for mouse click
  {
//--- set anchor points' coordinates if they are not set
   ChangeRectangleEmptyPoints(time1,price1,time2,price2);
//--- reset the error value
   ResetLastError();
//--- create a rectangle by the given coordinates
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle! Error code = ",GetLastError());
      return(false);
     }
//--- set rectangle color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);

//--- set the style of rectangle lines
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set width of the rectangle lines
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- enable (true) or disable (false) the mode of filling the rectangle
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the rectangle for moving
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//|  www.yousufmesalm.com | WhatsApp +201006179048 | Upwork: https://www.upwork.com/freelancers/youssefmesalm |
//+------------------------------------------------------------------+
bool RectanglePointChange(const long   chart_ID=0,       // chart's ID
                          const string name="Rectangle", // rectangle name
                          const int    point_index=0,    // anchor point index
                          datetime     time=0,           // anchor point time coordinate
                          double       price=0)          // anchor point price coordinate
  {
//--- if point position is not set, move it to the current bar having Bid price
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move the anchor point
   if(!ObjectMove(chart_ID,name,point_index,time,price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//|  www.yousufmesalm.com | WhatsApp +201006179048 | Upwork: https://www.upwork.com/freelancers/youssefmesalm |
//+------------------------------------------------------------------+
bool RectangleDelete(const long   chart_ID=0,       // chart's ID
                     const string name="Rectangle") // rectangle name
  {
//--- reset the error value
   ResetLastError();
//--- delete rectangle
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete rectangle! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//|                                            OB Box.mq5 |
//|                                    Copyright 2025, Yousuf Mesalm. |
//|  www.yousufmesalm.com | WhatsApp +201006179048 | Upwork: https://www.upwork.com/freelancers/youssefmesalm |
//+------------------------------------------------------------------+
void ChangeRectangleEmptyPoints(datetime &time1,double &price1,
                                datetime &time2,double &price2)
  {
//--- if the first point's time is not set, it will be on the current bar
   if(!time1)
      time1=TimeCurrent();
//--- if the first point's price is not set, it will have Bid value
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the second point's time is not set, it is located 9 bars left from the second one
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one
      time2=temp[0];
     }
//--- if the second point's price is not set, move it 300 points lower than the first one
   if(!price2)
      price2=price1-300*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
