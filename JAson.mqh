//+------------------------------------------------------------------+
//|                                                       JAson.mqh   |
//|                        简化版JSON处理库，用于SystemInfoReporter   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Your Name Here."
#property link      "https://www.cs123.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| CJAVal类 - 简单的JSON处理                                        |
//+------------------------------------------------------------------+
class CJAVal
{
private:
   string            m_key;
   string            m_value;
   CJAVal           *m_parent;
   CJAVal           *m_children[];
   int               m_count;

public:
                     CJAVal();
                    ~CJAVal();
   
   // 设置值
   void              Set(string key, string value);
   void              Set(string key, int value);
   void              Set(string key, double value);
   void              Set(string key, bool value);
   
   // 重载[]操作符，方便设置值
   CJAVal           *operator[](string key);
   
   // 序列化为JSON字符串
   string            Serialize();

private:
   // 内部序列化方法
   string            _Serialize(int indent);
   
   // 查找或创建子节点
   CJAVal           *FindOrCreateChild(string key);
};

//+------------------------------------------------------------------+
//| 构造函数                                                          |
//+------------------------------------------------------------------+
CJAVal::CJAVal()
{
   m_key = "";
   m_value = "";
   m_parent = NULL;
   m_count = 0;
}

//+------------------------------------------------------------------+
//| 析构函数                                                          |
//+------------------------------------------------------------------+
CJAVal::~CJAVal()
{
   for(int i = 0; i < m_count; i++)
   {
      delete m_children[i];
   }
}

//+------------------------------------------------------------------+
//| 设置字符串值                                                      |
//+------------------------------------------------------------------+
void CJAVal::Set(string key, string value)
{
   CJAVal *child = FindOrCreateChild(key);
   child.m_value = "\"" + value + "\"";
}

//+------------------------------------------------------------------+
//| 设置整数值                                                        |
//+------------------------------------------------------------------+
void CJAVal::Set(string key, int value)
{
   CJAVal *child = FindOrCreateChild(key);
   child.m_value = IntegerToString(value);
}

//+------------------------------------------------------------------+
//| 设置浮点数值                                                      |
//+------------------------------------------------------------------+
void CJAVal::Set(string key, double value)
{
   CJAVal *child = FindOrCreateChild(key);
   child.m_value = DoubleToString(value, 8);
}

//+------------------------------------------------------------------+
//| 设置布尔值                                                        |
//+------------------------------------------------------------------+
void CJAVal::Set(string key, bool value)
{
   CJAVal *child = FindOrCreateChild(key);
   child.m_value = value ? "true" : "false";
}

//+------------------------------------------------------------------+
//| 重载[]操作符                                                      |
//+------------------------------------------------------------------+
CJAVal *CJAVal::operator[](string key)
{
   return FindOrCreateChild(key);
}

//+------------------------------------------------------------------+
//| 查找或创建子节点                                                  |
//+------------------------------------------------------------------+
CJAVal *CJAVal::FindOrCreateChild(string key)
{
   // 先查找是否已存在
   for(int i = 0; i < m_count; i++)
   {
      if(m_children[i].m_key == key)
         return m_children[i];
   }
   
   // 不存在则创建新节点
   m_count++;
   ArrayResize(m_children, m_count);
   m_children[m_count-1] = new CJAVal();
   m_children[m_count-1].m_key = key;
   m_children[m_count-1].m_parent = GetPointer(this);
   
   return m_children[m_count-1];
}

//+------------------------------------------------------------------+
//| 序列化为JSON字符串                                                |
//+------------------------------------------------------------------+
string CJAVal::Serialize()
{
   return _Serialize(0);
}

//+------------------------------------------------------------------+
//| 内部序列化方法                                                    |
//+------------------------------------------------------------------+
string CJAVal::_Serialize(int indent)
{
   string result = "{";
   string indent_str = "";
   
   for(int i = 0; i < m_count; i++)
   {
      if(i > 0) result += ",";
      result += "\n" + indent_str + "  \"" + m_children[i].m_key + "\": " + m_children[i].m_value;
   }
   
   if(m_count > 0) result += "\n" + indent_str;
   result += "}";
   
   return result;
}
//+------------------------------------------------------------------+ 