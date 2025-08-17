from fastapi import APIRouter, Depends, HTTPException
from typing import List, Dict, Any
from app.schemas.user import User
from app.services.offline_service import offline_service
from app.api.v1.endpoints.auth import get_current_user

router = APIRouter(prefix="/offline", tags=["offline"])

@router.post("/save/")
def save_offline_conversation(
    conversation_data: Dict[str, Any],
    current_user: str = Depends(get_current_user)
):
    """
    保存离线对话数据
    """
    filename = offline_service.save_offline_conversation(current_user, conversation_data)
    return {"message": "Conversation saved for offline sync", "filename": filename}

@router.get("/list/", response_model=List[Dict[str, Any]])
def list_offline_conversations(current_user: str = Depends(get_current_user)):
    """
    获取离线对话数据列表
    """
    conversations = offline_service.get_offline_conversations(current_user)
    return conversations

@router.post("/sync/")
def sync_offline_conversations(current_user: str = Depends(get_current_user)):
    """
    同步离线对话数据
    """
    synced_conversations = offline_service.sync_offline_conversations(current_user)
    
    # 删除已同步的文件
    for conv in synced_conversations:
        if "saved_at" in conv:
            filename = conv["saved_at"]
            offline_service.delete_offline_conversation(filename)
    
    return {
        "message": f"Synced {len(synced_conversations)} conversations",
        "synced_conversations": synced_conversations
    }