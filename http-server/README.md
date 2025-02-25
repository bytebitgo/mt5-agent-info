# EA数据接收服务器

这是一个用于接收MetaTrader 5 EA上报数据的HTTP服务器，基于Python Flask开发。服务器接收EA上报的JSON数据，异步返回任务ID，并将数据保存到Excel文件中。

## 功能特点

- 监听80端口，接收HTTP POST请求
- 接收EA上报的系统信息JSON数据
- 异步返回任务ID
- 支持根据任务ID查询任务状态
- 将数据追加保存到Excel文件中
- 提供健康检查接口
- 完整的日志记录

## 目录结构

```
http-server/
├── app.py              # 主应用程序
├── requirements.txt    # 依赖包列表
├── test_client.py      # 测试客户端
├── README.md           # 说明文档
├── server.log          # 服务器日志（运行后生成）
└── ea_reports.xlsx     # 数据存储Excel文件（运行后生成）
```

## 安装依赖

```bash
pip install -r requirements.txt
```

## 运行服务器

```bash
# 在Windows上可能需要管理员权限运行，因为使用了80端口
python app.py
```

服务器将在`0.0.0.0:80`上启动，并监听来自EA的请求。

## API接口

### 1. 接收EA数据

- **URL**: `/apv/v1/analyesis`
- **方法**: POST
- **请求体**: JSON格式的EA系统信息数据
- **响应**: 
  ```json
  {
    "status": "success",
    "message": "数据已接收",
    "task_id": "生成的UUID"
  }
  ```

### 2. 查询任务状态

- **URL**: `/task/<task_id>`
- **方法**: GET
- **响应**: 
  ```json
  {
    "task_id": "任务ID",
    "status": "received|processing|completed|failed",
    "message": "详细状态信息",
    "received_time": "接收时间",
    "completed_time": "完成时间"
  }
  ```

### 3. 健康检查

- **URL**: `/health`
- **方法**: GET
- **响应**: 
  ```json
  {
    "status": "ok",
    "time": "当前时间"
  }
  ```

## 测试客户端

项目包含一个测试客户端脚本`test_client.py`，用于模拟EA发送数据到服务器：

### 发送数据并查询状态

```bash
python test_client.py
```

测试客户端会读取项目根目录下的`example.json`文件，将其内容发送到服务器，然后自动查询任务状态。

### 仅查询任务状态

```bash
python test_client.py check <task_id>
```

使用此命令可以查询指定任务ID的状态。

## 任务状态说明

任务状态包括以下几种：

- **received**: 数据已接收，等待处理
- **processing**: 正在处理数据
- **completed**: 数据处理完成
- **failed**: 数据处理失败

## 数据存储

所有接收到的数据都会被保存到`ea_reports.xlsx`文件中，包含以下字段：

- task_id: 生成的任务ID
- received_time: 服务器接收数据的时间
- status: 任务状态
- completed_time: 任务完成时间
- 以及EA上报的所有字段（terminal_language, terminal_company等）

## 注意事项

1. 运行服务器需要管理员权限（因为使用了80端口）
2. 如果80端口被占用，可以在`app.py`中修改端口号
3. 确保安装了所有依赖包
4. 服务器运行日志保存在`server.log`文件中
5. 任务状态会在服务器重启后丢失，但可以从Excel文件中恢复 