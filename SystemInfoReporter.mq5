//+------------------------------------------------------------------+
//|                                           SystemInfoReporter.mq5 |
//|                                  Copyright 2023, Your Name Here. |
//|                                             https://www.cs123.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Your Name Here."
#property link      "https://www.cs123.com"
#property version   "1.00"
#property strict

// 引入必要的库
#include <JAson.mqh>                 // 用于JSON处理
#include <NetworkReporter.mqh>       // 用于网络上报
#include <SystemInfoCollector.mqh>   // 用于系统信息收集

// 全局变量
string api_endpoint = "https://www.cs123.com/apv/v1/analyesis";
int report_interval = 3600;  // 上报间隔，单位：秒（默认1小时）
datetime last_report_time = 0;

// 模块实例
CSystemInfoCollector *info_collector = NULL;
CNetworkReporter *network_reporter = NULL;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // 创建网络上报器
   network_reporter = new CNetworkReporter(api_endpoint);
   
   // 创建系统信息收集器
   info_collector = new CSystemInfoCollector();
   
   
   // 初始化时立即上报一次
   if(!ReportSystemInfo())
   {
      // 如果上报失败，检查是否是WebRequest权限问题
      if(GetLastError() == 4014)
      {
         Print("由于WebRequest权限错误，EA将退出");
         ExpertRemove();
         return(INIT_FAILED);
      }
   }
   
   // 设置定时器，定期上报
   EventSetTimer(report_interval);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // 停止定时器
   EventKillTimer();
   
   // 释放资源
   if(info_collector != NULL)
   {
      delete info_collector;
      info_collector = NULL;
   }
   
   if(network_reporter != NULL)
   {
      delete network_reporter;
      network_reporter = NULL;
   }
   
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // 在Tick函数中不执行任何操作，使用定时器来控制上报频率
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   // 定时上报系统信息
   ReportSystemInfo();
}

//+------------------------------------------------------------------+
//| 收集并上报系统信息                                               |
//+------------------------------------------------------------------+
bool ReportSystemInfo()
{
   if(info_collector == NULL || network_reporter == NULL )
   {
      Print("错误: 模块未正确初始化");
      return false;
   }
   
   // 创建JSON对象
   CJAVal system_info;
   
   // 收集系统信息
   info_collector.CollectSystemInfo(system_info);
   
 
   
   // 将JSON转换为字符串
   string json_string = system_info.Serialize();
   
   // 上报数据
   bool result = network_reporter.SendJsonData(json_string);
   
   // 更新上次上报时间
   if(result)
   {
      last_report_time = TimeCurrent();
      Print("系统信息已上报: ", json_string);
   }
   else
   {
      Print("系统信息上报失败");
   }
   
   return result;
}

