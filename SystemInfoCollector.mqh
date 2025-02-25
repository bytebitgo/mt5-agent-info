//+------------------------------------------------------------------+
//|                                          SystemInfoCollector.mqh |
//|                                  Copyright 2023, Your Name Here. |
//|                                             https://www.cs123.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Your Name Here."
#property link      "https://www.cs123.com"
#property version   "1.00"
#property strict

#include <JAson.mqh>         // 用于JSON处理
#include <NetworkReporter.mqh>  // 用于网络上报

//+------------------------------------------------------------------+
//| 系统信息收集类                                                   |
//+------------------------------------------------------------------+
class CSystemInfoCollector
{
private:
   // 私有成员变量
   string m_api_endpoint;
   CNetworkReporter *m_reporter;
   
public:
   // 构造函数和析构函数
   CSystemInfoCollector(string api_endpoint = "");
   ~CSystemInfoCollector();
   
   // 公共方法
   bool CollectAndSendInfo();
   void CollectSystemInfo(CJAVal &json);
   
   // 设置API端点
   void SetApiEndpoint(string api_endpoint);
   string GetApiEndpoint() { return m_api_endpoint; }
};

//+------------------------------------------------------------------+
//| 构造函数                                                         |
//+------------------------------------------------------------------+
CSystemInfoCollector::CSystemInfoCollector(string api_endpoint = "")
{
   m_api_endpoint = api_endpoint;
   m_reporter = new CNetworkReporter(api_endpoint);
}

//+------------------------------------------------------------------+
//| 析构函数                                                         |
//+------------------------------------------------------------------+
CSystemInfoCollector::~CSystemInfoCollector()
{
   // 释放网络上报器
   if(m_reporter != NULL)
   {
      delete m_reporter;
      m_reporter = NULL;
   }
}

//+------------------------------------------------------------------+
//| 设置API端点                                                      |
//+------------------------------------------------------------------+
void CSystemInfoCollector::SetApiEndpoint(string api_endpoint)
{
   m_api_endpoint = api_endpoint;
   if(m_reporter != NULL)
   {
      m_reporter.SetApiEndpoint(api_endpoint);
   }
}

//+------------------------------------------------------------------+
//| 收集系统信息并填充JSON对象                                       |
//+------------------------------------------------------------------+
void CSystemInfoCollector::CollectSystemInfo(CJAVal &json)
{
   // 获取终端的语言
   string terminal_language = TerminalInfoString(TERMINAL_LANGUAGE);
   Print("终端语言: ", terminal_language);

   // 获取终端的公司名称
   string terminal_company = TerminalInfoString(TERMINAL_COMPANY);
   Print("公司名称: ", terminal_company);

   // 获取终端的名称
   string terminal_name = TerminalInfoString(TERMINAL_NAME);
   Print("终端名称: ", terminal_name);

   // 获取终端启动文件夹路径
   string terminal_path = TerminalInfoString(TERMINAL_PATH);
   Print("终端启动文件夹路径: ", terminal_path);

   // 获取终端数据文件夹路径
   string terminal_data_path = TerminalInfoString(TERMINAL_DATA_PATH);
   Print("终端数据文件夹路径: ", terminal_data_path);

   // 获取通用数据文件夹路径
   string terminal_common_data_path = TerminalInfoString(TERMINAL_COMMONDATA_PATH);
   Print("通用数据文件夹路径: ", terminal_common_data_path);

   // 获取系统CPU名称
   string terminal_cpu_name = TerminalInfoString(TERMINAL_CPU_NAME);
   Print("CPU名称: ", terminal_cpu_name);

   // 获取系统CPU架构
   string terminal_cpu_architecture = TerminalInfoString(TERMINAL_CPU_ARCHITECTURE);
   Print("CPU架构: ", terminal_cpu_architecture);

   // 获取用户操作系统版本
   string terminal_os_version = TerminalInfoString(TERMINAL_OS_VERSION);
   Print("操作系统版本: ", terminal_os_version);
   
   // 获取CPU核心数
   int cpu_cores = (int)TerminalInfoInteger(TERMINAL_CPU_CORES);
   Print("CPU核心数: ", cpu_cores);
   
   // 获取内存信息
   int memory_physical = (int)TerminalInfoInteger(TERMINAL_MEMORY_PHYSICAL);
   Print("物理内存大小(MB): ", memory_physical);
   
   // 获取账户信息
   long account_number = AccountInfoInteger(ACCOUNT_LOGIN);
   Print("账户号: ", account_number);
   
   string broker_name = AccountInfoString(ACCOUNT_COMPANY);
   Print("经纪商名称: ", broker_name);
   
   // 获取账户交易模式
   ENUM_ACCOUNT_TRADE_MODE trade_mode = (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
   string trade_mode_str = "";
   
   switch(trade_mode)
   {
      case ACCOUNT_TRADE_MODE_DEMO:
         trade_mode_str = "Demo";
         break;
      case ACCOUNT_TRADE_MODE_CONTEST:
         trade_mode_str = "Contest";
         break;
      case ACCOUNT_TRADE_MODE_REAL:
         trade_mode_str = "Real";
         break;
      default:
         trade_mode_str = "Unknown";
   }
   Print("账户交易模式: ", trade_mode_str);
   
   // 添加终端信息 - 使用Set方法
   json.Set("terminal_language", terminal_language);
   json.Set("terminal_company", terminal_company);
   json.Set("terminal_name", terminal_name);
   json.Set("terminal_path", terminal_path);
   json.Set("terminal_data_path", terminal_data_path);
   json.Set("terminal_common_data_path", terminal_common_data_path);
   json.Set("terminal_cpu_name", terminal_cpu_name);
   json.Set("terminal_cpu_architecture", terminal_cpu_architecture);
   json.Set("terminal_os_version", terminal_os_version);
   
   // 添加系统信息 - 使用Set方法
   json.Set("cpu_cores", cpu_cores);
   json.Set("memory_physical", memory_physical);
   
   // 添加账户信息 - 使用Set方法
   json.Set("account_number", (int)account_number);
   json.Set("broker_name", broker_name);
   json.Set("account_trade_mode", trade_mode_str);
   
   // 添加其他账户信息 - 使用Set方法
   json.Set("account_leverage", (int)AccountInfoInteger(ACCOUNT_LEVERAGE));
   json.Set("account_currency", AccountInfoString(ACCOUNT_CURRENCY));
   json.Set("account_balance", AccountInfoDouble(ACCOUNT_BALANCE));
   json.Set("account_equity", AccountInfoDouble(ACCOUNT_EQUITY));
   
   json.Set("ea_version", "1.00");
   json.Set("report_time", TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS));
}

//+------------------------------------------------------------------+
//| 收集并发送系统信息                                               |
//+------------------------------------------------------------------+
bool CSystemInfoCollector::CollectAndSendInfo()
{
   if(m_api_endpoint == "")
   {
      Print("错误: API端点未设置");
      return false;
   }
   
   if(m_reporter == NULL)
   {
      Print("错误: 网络上报器未初始化");
      return false;
   }
   
   // 创建JSON对象
   CJAVal json;
   
   // 收集系统信息
   CollectSystemInfo(json);
   
   // 将JSON转换为字符串
   string json_string = json.Serialize();
   
   // 上报数据
   bool result = m_reporter.SendJsonData(json_string);
   
   // 记录日志
   if(result)
      Print("系统信息已上报: ", json_string);
   else
      Print("系统信息上报失败");
      
   return result;
}
//+------------------------------------------------------------------+ 