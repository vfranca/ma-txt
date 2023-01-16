//+------------------------------------------------------------------+
//|                                                      IMA_TXT.mq5 |
//|                                           Valmir França da Silva |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Valmir França da Silva"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
//--- Dependências
#include "Split.mqh"
//--- Parâmetros de entrada
input int input_timer=10; // Tempo de atualização
input int input_amount=1000; // Quantidade de médias calculadas
input int input_digits=2; // Dígitos da moeda
input int input_period_amount=20; // períodos da média móvel
input int input_angle=10; // inclinação da média móvel
input ENUM_MA_METHOD input_method=MODE_SMA; // tipo de suavização
input ENUM_APPLIED_PRICE input_applied_price=PRICE_CLOSE; // tipo de preço
input ENUM_TIMEFRAMES input_period=PERIOD_CURRENT; // Período da média móvel
//--- buffer do indicador
double ma[];
//--- variável para armazenar o manipulador do indicator iMA
int handle;
//--- Resultado da cópia para o buffer
int copied;
//--- Cotações
MqlRates rates[];
//+------------------------------------------------------------------+
//| Função de inicialização do indicador personalizado                 |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Dispara o temporizador
   EventSetTimer(input_timer);
//--- Exporta os dados para arquivo TXT
   GeraFile(Period(), Period());
//--- atribuição de array para buffer do indicador
   SetIndexBuffer(0,ma,INDICATOR_DATA);
//--- inicialização normal do indicador
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Função de iteração do indicador personalizado                      |
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
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Função de desinicialização do indicador                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Encerra o temporizador
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Função disparada pelo temporizador  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- Exporta os dados para o arquivo TXT
   GeraFile(Period(), Period());
  }
//+------------------------------------------------------------------+
//| Função paa exportar os dados para TXT                          |
//+------------------------------------------------------------------+
void GeraFile(ENUM_TIMEFRAMES timeframes, string tile)
  {
//--- buffer do indicador
   double ma[];
//--- Obtem a média móvel
   handle = iMA(_Symbol, timeframes, input_period_amount, 0, input_method, input_applied_price);
//---
   copied = CopyBuffer(handle, 0, 0, input_amount, ma);
   if(copied < 0)
     {
      Print("handle não OK ");
      return;
     }
//--- Abre o arquivo para exportação dos dados
   int FILE = FileOpen(Symbol() + Split(_Period) +"-MA.csv", FILE_WRITE | FILE_TXT);
   if(FILE != INVALID_HANDLE)
     {
      //--- Obtem as cotações
      int copy = CopyRates(Symbol(), timeframes, TimeTradeServer(), input_amount, rates);
      //--- Escreve no arquivo
      for(int i = 1; i < copy; i++)
        {
         //--- Define a inclinação da média móvel
         string sMA = "flat";
         string sAngle = DoubleToString((MathAbs(ma[i] - ma[i-1])), input_digits);
         if(ma[i] > (ma[i-1]+input_angle))
            sMA = "up";
         if(ma[i] < (ma[i-1]-input_angle))
            sMA = "down" ;
         //--- Escreve no arquivo TXT
         FileWrite(FILE,
                   rates[i].time, ",",
                   rates[i].close,",",
                   ma[i], ",",
                   sMA+sAngle);
        }//end for
     }
   else
     {
      Print("Erro ao abrir arquivo, arquivo pode já estar aberto!");
     }
//--- Fecha o arquivo
   FileClose(FILE);
  }
//+------------------------------------------------------------------+
