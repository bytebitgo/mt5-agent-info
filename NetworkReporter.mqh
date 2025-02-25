//+------------------------------------------------------------------+
//|                                             NetworkReporter.mqh   |
//|                                  Copyright 2023, Your Name Here.  |
//|                                             https://www.cs123.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Your Name Here."
#property link      "https://www.cs123.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| 网络上报类                                                        |
//+------------------------------------------------------------------+
class CNetworkReporter
{
private:
   // 私有成员变量
   string m_api_endpoint;
   int    m_timeout;
   
public:
   // 构造函数和析构函数
   CNetworkReporter(string api_endpoint = "", int timeout = 10000);
   ~CNetworkReporter();
   
   // 公共方法
   bool SendData(string data, string content_type = "application/json");
   bool SendJsonData(string json_data);
   
   // 设置API端点
   void SetApiEndpoint(string api_endpoint) { m_api_endpoint = api_endpoint; }
   string GetApiEndpoint() { return m_api_endpoint; }
   
   // 设置超时时间
   void SetTimeout(int timeout) { m_timeout = timeout; }
   int GetTimeout() { return m_timeout; }
};

//+------------------------------------------------------------------+
//| 构造函数                                                         |
//+------------------------------------------------------------------+
CNetworkReporter::CNetworkReporter(string api_endpoint = "", int timeout = 10000)
{
   m_api_endpoint = api_endpoint;
   m_timeout = timeout;
}

//+------------------------------------------------------------------+
//| 析构函数                                                         |
//+------------------------------------------------------------------+
CNetworkReporter::~CNetworkReporter()
{
   // 析构函数不需要特殊处理
}

//+------------------------------------------------------------------+
//| 发送数据到服务器                                                 |
//+------------------------------------------------------------------+
bool CNetworkReporter::SendData(string data, string content_type = "application/json")
{
   if(m_api_endpoint == "")
   {
      Print("错误: API端点未设置");
      return false;
   }
   
   char data_array[];
   StringToCharArray(data, data_array);
   
   char result[];
   string result_headers;
   
   // 准备请求头
   string headers = "Content-Type: " + content_type + "\r\n";
   
   // 发送POST请求
   int res = WebRequest("POST", m_api_endpoint, headers, m_timeout, data_array, result, result_headers);
   
   if(res == -1)
   {
      int error_code = GetLastError();
      Print("HTTP请求失败，错误码: ", error_code);
      
      // 检查是否需要允许WebRequest
      if(error_code == 4014)
      {
         MessageBox("请允许WebRequest功能访问URL: " + m_api_endpoint + "\n在工具 -> 选项 -> 专家顾问 -> 添加指定的URL", "WebRequest权限错误", MB_ICONERROR);
         return false;
      }
      
      return false;
   }
   else
   {
      // 将结果转换为字符串并打印
      string result_string = CharArrayToString(result);
      Print("服务器响应: ", result_string);
      return true;
   }
}

//+------------------------------------------------------------------+
//| 发送JSON数据到服务器                                             |
//+------------------------------------------------------------------+
bool CNetworkReporter::SendJsonData(string json_data)
{
   return SendData(json_data, "application/json");
}
//+------------------------------------------------------------------+ 