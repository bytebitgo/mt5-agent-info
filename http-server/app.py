from flask import Flask, request, jsonify
import pandas as pd
import os
import uuid
import time
import threading
from datetime import datetime
import logging

app = Flask(__name__)


# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("server.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Excel文件路径
EXCEL_FILE = 'ea_reports.xlsx'

# 任务状态字典，用于存储任务状态
# 格式: {task_id: {"status": "processing|completed|failed", "message": "详细信息"}}
task_status = {}

# 确保Excel文件存在，如果不存在则创建
def ensure_excel_exists():
    if not os.path.exists(EXCEL_FILE):
        # 创建一个空的DataFrame，列名与EA上报的JSON字段对应
        df = pd.DataFrame(columns=[
            'task_id',
            'received_time',
            'status',
            'completed_time',
            'terminal_language',
            'terminal_company',
            'terminal_name',
            'terminal_path',
            'terminal_data_path',
            'terminal_common_data_path',
            'terminal_cpu_name',
            'terminal_cpu_architecture',
            'terminal_os_version',
            'cpu_cores',
            'memory_physical',
            'account_number',
            'broker_name',
            'account_trade_mode',
            'account_leverage',
            'account_currency',
            'account_balance',
            'account_equity',
            'ea_version',
            'report_time'
        ])
        # 保存为Excel文件
        df.to_excel(EXCEL_FILE, index=False)
        logger.info(f"创建了新的Excel文件: {EXCEL_FILE}")

# 异步保存数据到Excel
def save_to_excel_async(data, task_id):
    try:
        # 更新任务状态为处理中
        task_status[task_id] = {"status": "processing", "message": "正在处理数据"}
        
        # 确保Excel文件存在
        ensure_excel_exists()
        
        # 读取现有Excel文件
        df = pd.read_excel(EXCEL_FILE)
        
        # 准备新行数据
        new_row = {
            'task_id': task_id,
            'received_time': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'status': 'completed',
            'completed_time': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        }
        
        # 添加EA上报的所有字段
        for key, value in data.items():
            if key in df.columns:
                new_row[key] = value
        
        # 将新行添加到DataFrame
        df = pd.concat([df, pd.DataFrame([new_row])], ignore_index=True)
        
        # 保存回Excel文件
        df.to_excel(EXCEL_FILE, index=False)
        logger.info(f"成功将数据保存到Excel，任务ID: {task_id}")
        
        # 更新任务状态为完成
        task_status[task_id] = {"status": "completed", "message": "数据处理完成"}
    except Exception as e:
        error_msg = f"保存数据到Excel时出错: {str(e)}"
        logger.error(error_msg)
        # 更新任务状态为失败
        task_status[task_id] = {"status": "failed", "message": error_msg}

@app.route('/apv/v1/analyesis', methods=['POST'])
def receive_data():
    try:
        # 获取JSON数据
        data = request.json
        
        # 生成任务ID
        task_id = str(uuid.uuid4())
        
        # 记录接收到的数据
        logger.info(f"接收到数据，任务ID: {task_id}")
        logger.debug(f"数据内容: {data}")
        
        # 初始化任务状态
        task_status[task_id] = {"status": "received", "message": "数据已接收，等待处理"}
        
        # 启动异步线程保存数据
        threading.Thread(target=save_to_excel_async, args=(data, task_id)).start()
        
        # 返回任务ID
        return jsonify({
            "status": "success",
            "message": "数据已接收",
            "task_id": task_id
        }), 200
    except Exception as e:
        error_msg = f"处理请求时出错: {str(e)}"
        logger.error(error_msg)
        return jsonify({
            "status": "error",
            "message": error_msg
        }), 500

@app.route('/task/<task_id>', methods=['GET'])
def check_task_status(task_id):
    try:
        # 检查任务ID是否存在于内存中的任务状态字典
        if task_id in task_status:
            status_info = task_status[task_id]
            return jsonify({
                "task_id": task_id,
                "status": status_info["status"],
                "message": status_info["message"]
            }), 200
        
        # 如果不在内存中，尝试从Excel文件中查找
        if os.path.exists(EXCEL_FILE):
            df = pd.read_excel(EXCEL_FILE)
            task_row = df[df['task_id'] == task_id]
            
            if not task_row.empty:
                # 找到了任务记录
                status = task_row['status'].values[0]
                return jsonify({
                    "task_id": task_id,
                    "status": status,
                    "message": f"任务状态: {status}",
                    "received_time": task_row['received_time'].values[0],
                    "completed_time": task_row['completed_time'].values[0] if 'completed_time' in task_row else None
                }), 200
        
        # 任务ID不存在
        return jsonify({
            "status": "error",
            "message": f"找不到任务ID: {task_id}"
        }), 404
    except Exception as e:
        error_msg = f"查询任务状态时出错: {str(e)}"
        logger.error(error_msg)
        return jsonify({
            "status": "error",
            "message": error_msg
        }), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({
        "status": "ok",
        "time": datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    }), 200

if __name__ == '__main__':
    # 确保Excel文件存在
    ensure_excel_exists()
    
    # 启动Flask应用
    logger.info("服务器启动中...")
    app.run(host='0.0.0.0', port=80, debug=True)
 