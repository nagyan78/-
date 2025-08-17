import json
import os
from typing import List, Dict, Any
from datetime import datetime
from app.core.config import settings

class OfflineService:
    """
    离线缓存服务类
    处理离线对话数据的存储和同步
    """
    
    def __init__(self):
        # 确保缓存目录存在
        self.cache_dir = "./cache/offline"
        os.makedirs(self.cache_dir, exist_ok=True)
    
    def save_offline_conversation(self, user_id: str, conversation_data: Dict[str, Any]) -> str:
        """
        保存离线对话数据
        """
        # 生成唯一文件名
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
        filename = f"offline_conv_{user_id}_{timestamp}.json"
        filepath = os.path.join(self.cache_dir, filename)
        
        # 添加元数据
        conversation_data["metadata"] = {
            "saved_at": datetime.now().isoformat(),
            "user_id": user_id,
            "version": "1.0",
            "type": "conversation_data"
        }
        
        # 保存到文件
        with open(filepath, "w", encoding="utf-8") as f:
            json.dump(conversation_data, f, ensure_ascii=False, indent=2)
            
        return filename
    
    def get_offline_conversations(self, user_id: str) -> List[Dict[str, Any]]:
        """
        获取用户的离线对话数据
        """
        offline_conversations = []
        
        # 遍历缓存目录中的文件
        for filename in os.listdir(self.cache_dir):
            if filename.startswith(f"offline_conv_{user_id}_") and filename.endswith(".json"):
                filepath = os.path.join(self.cache_dir, filename)
                try:
                    with open(filepath, "r", encoding="utf-8") as f:
                        conversation_data = json.load(f)
                        # 验证数据完整性
                        if "metadata" in conversation_data and "user_id" in conversation_data["metadata"]:
                            offline_conversations.append(conversation_data)
                except Exception as e:
                    print(f"Error reading offline conversation file {filename}: {e}")
                    
        return offline_conversations
    
    def delete_offline_conversation(self, filename: str) -> bool:
        """
        删除已同步的离线对话文件
        """
        filepath = os.path.join(self.cache_dir, filename)
        try:
            if os.path.exists(filepath):
                os.remove(filepath)
                return True
            return False
        except Exception as e:
            print(f"Error deleting offline conversation file {filename}: {e}")
            return False
    
    def sync_offline_conversations(self, user_id: str) -> List[Dict[str, Any]]:
        """
        同步用户的离线对话数据
        返回已同步的数据列表
        """
        # 获取离线对话数据
        offline_conversations = self.get_offline_conversations(user_id)
        synced_conversations = []
        
        # 处理每个离线对话数据
        for conv in offline_conversations:
            # 添加同步状态信息
            conv["sync_status"] = "success"
            conv["synced_at"] = datetime.now().isoformat()
            synced_conversations.append(conv)
            
        return synced_conversations

offline_service = OfflineService()