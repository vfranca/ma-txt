//+------------------------------------------------------------------+
//|                                                      MA_TXT.mq5 |
//|                                           Valmir França da Silva |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Valmir França da Silva"
#property link      "https://www.mql5.com"
#property version   "1.42"
#property indicator_chart_window
#property indicator_buffers 1
//--- Dependências
#include "Split.mqh"
//--- Parâmetros de entrada
input int inp_bars_calculated=20; // Barras:
input ENUM_MA_METHOD inp_method=MODE_EMA; // Método:
input ENUM_APPLIED_PRICE inp_applied_price=PRICE_CLOSE; // Aplicada a:
input int inp_timer=10; // Tempo de atualização:
input int inp_amount=2; // Quantidade de médias no histórico:
input int inp_digits=2; // Dígitos da moeda:
input double inp_variacao_flat=0.10; // Variação flat:
//--- buffer do indicador
double ma[];
//--- variável para armazenar o manipulador do indicator iMA
int handler;
//--- Resultado da cópia para o buffer
int values_to_copy;
//--- Cotações
MqlRates rates[];
//+------------------------------------------------------------------+
//| Função de inicialização do indicador personalizado                 |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Dispara o temporizador
   EventSetTimer(inp_timer);
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
//---
   double ma[];
//--- Cria o manipulador do indicador
   handler = iMA(_Symbol, Period(), inp_bars_calculated, 0, inp_method, inp_applied_price);
//--- Copia resultados para array do buffer do indicador
   values_to_copy = CopyBuffer(handler, 0, 0, inp_amount, ma);
   if(values_to_copy < 0)
     {
      Print("Erro no manipulador do indicador!");
      return;
     }
//--- Exporta os dados para o arquivo TXT
   ExportaIndicadorCSV(Period(), ma);
  }
//+------------------------------------------------------------------+
//| Função paa exportar os dados para TXT                          |
//+------------------------------------------------------------------+
void ExportaIndicadorCSV(ENUM_TIMEFRAMES timeframes, const double &ind[])
  {
//--- Abre o arquivo para exportação dos dados
   int FILE = FileOpen(Symbol() + Split(_Period) + "-MA" + inp_bars_calculated + ".csv", FILE_WRITE | FILE_TXT);
   if(FILE != INVALID_HANDLE)
     {
      //--- Obtem as cotações
      int copy = CopyRates(Symbol(), timeframes, TimeTradeServer(), inp_amount, rates);
      //--- Escreve no arquivo
      for(int i = 1; i < copy; i++)
        {
         //--- Define a inclinação da média móvel
         string sInclinacao = "flat";
         string sVariacao = DoubleToString((MathAbs(ind[i] - ind[i-1])), inp_digits);
         if(ind[i] > (ind[i-1]+inp_variacao_flat))
            sInclinacao = "up";
         if(ind[i] < (ind[i-1]-inp_variacao_flat))
            sInclinacao = "down" ;
         //--- Escreve no arquivo TXT
         FileWrite(FILE,
                   rates[i].time, ",",
                   rates[i].close, ",",
                   NormalizeDouble(ind[i], inp_digits), ",",
                   sInclinacao, ",",
                   sVariacao, ",",
                   inp_variacao_flat, ",",
                   inp_bars_calculated, ",",
                   EnumToString(inp_method), ",",
                   EnumToString(inp_applied_price));
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
