import requests
import json
import time
from datetime import datetime
import sys

# 服务器地址
SERVER_URL = "http://localhost:80/apv/v1/analyesis"
TASK_STATUS_URL = "http://localhost:80/task/"

# 读取示例JSON数据
def load_example_json():
    try:
        with open('../example.json', 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"读取示例JSON文件时出错: {str(e)}")
        return None

# 发送数据到服务器
def send_data_to_server(data):
    try:
        # 更新上报时间为当前时间
        data['report_time'] = datetime.now().strftime('%Y.%m.%d %H:%M:%S')
        
        # 发送POST请求
        response = requests.post(SERVER_URL, json=data, headers={'Content-Type': 'application/json'})
        
        # 打印响应
        print(f"状态码: {response.status_code}")
        print(f"响应内容: {response.json()}")
        
        return response.json()
    except Exception as e:
        print(f"发送数据时出错: {str(e)}")
        return None

# 查询任务状态
def check_task_status(task_id):
    try:
        # 发送GET请求
        response = requests.get(f"{TASK_STATUS_URL}{task_id}")
        
        # 打印响应
        print(f"状态码: {response.status_code}")
        print(f"响应内容: {response.json()}")
        
        return response.json()
    except Exception as e:
        print(f"查询任务状态时出错: {str(e)}")
        return None

# 主函数
def main():
    # 检查命令行参数
    if len(sys.argv) > 1:
        # 如果提供了任务ID，则查询任务状态
        if sys.argv[1] == "check" and len(sys.argv) > 2:
            task_id = sys.argv[2]
            print(f"正在查询任务ID: {task_id} 的状态...")
            result = check_task_status(task_id)
            
            if result and "status" in result:
                print(f"\n任务状态: {result['status']}")
                print(f"详细信息: {result['message']}")
            else:
                print("\n查询任务状态失败!")
            return
    
    # 加载示例数据
    data = load_example_json()
    if not data:
        print("无法加载示例数据，退出")
        return
    
    print("已加载示例数据:")
    print(json.dumps(data, indent=2, ensure_ascii=False))
    
    # 发送数据
    print("\n正在发送数据到服务器...")
    result = send_data_to_server(data)
    
    if result and 'task_id' in result:
        task_id = result['task_id']
        print(f"\n数据发送成功! 任务ID: {task_id}")
        
        # 等待一秒，然后查询任务状态
        print("\n等待1秒后查询任务状态...")
        time.sleep(1)
        
        # 查询任务状态
        status_result = check_task_status(task_id)
        if status_result and "status" in status_result:
            print(f"\n任务状态: {status_result['status']}")
            print(f"详细信息: {status_result['message']}")
        else:
            print("\n查询任务状态失败!")
    else:
        print("\n数据发送失败!")

if __name__ == "__main__":
    main() 