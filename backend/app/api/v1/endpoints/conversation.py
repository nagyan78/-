from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import List
import json
import os
import time
from app.schemas.conversation import Conversation, ConversationCreate, ConversationUpdate, Message, MessageCreate, MessageUpdate
from app.schemas.report import Report
from app.services.conversation_service import conversation_service
from app.services.report_service import report_service
from app.services.voice_service import voice_service
from app.services.ai_service import ai_service
from app.core.database import get_db
from app.core.config import settings

router = APIRouter(prefix="/conversations", tags=["conversations"])

@router.post("/", response_model=Conversation)
def create_conversation(conversation: ConversationCreate, db: Session = Depends(get_db)):
    """
    创建新对话
    """
    # 验证场景是否存在
    from app.services.scenario_service import scenario_service
    scenario = scenario_service.get_scenario(db, conversation.scenario_id)
    if scenario is None:
        raise HTTPException(status_code=404, detail="Scenario not found")
    
    db_conversation = conversation_service.create_conversation(db, conversation=conversation)
    return db_conversation

@router.get("/{conversation_id}", response_model=Conversation)
def read_conversation(conversation_id: int, db: Session = Depends(get_db)):
    """
    根据ID获取对话
    """
    db_conversation = conversation_service.get_conversation(db, conversation_id=conversation_id)
    if db_conversation is None:
        raise HTTPException(status_code=404, detail="Conversation not found")
    return db_conversation

@router.put("/{conversation_id}", response_model=Conversation)
def update_conversation(conversation_id: int, conversation_update: ConversationUpdate, db: Session = Depends(get_db)):
    """
    更新对话状态（暂停/结束）
    """
    db_conversation = conversation_service.update_conversation_status(
        db, 
        conversation_id=conversation_id, 
        status=conversation_update.status
    )
    if db_conversation is None:
        raise HTTPException(status_code=404, detail="Conversation not found")
    return db_conversation

@router.post("/{conversation_id}/messages/text", response_model=Message)
def add_text_message(
    conversation_id: int, 
    sender: str = Form(...),
    content: str = Form(...),
    db: Session = Depends(get_db)
):
    """
    向对话添加文本消息
    """
    # 验证对话是否存在
    db_conversation = conversation_service.get_conversation(db, conversation_id=conversation_id)
    if db_conversation is None:
        raise HTTPException(status_code=404, detail="Conversation not found")
        
    # 创建消息
    message = MessageCreate(
        conversation_id=conversation_id,
        sender=sender,
        content=content
    )
    
    # 添加消息
    db_message = conversation_service.add_message(db, message=message)
    
    # 如果是用户发送的消息，则自动生成AI回复
    if sender == "user":
        try:
            ai_message = conversation_service.generate_ai_response(db, conversation_id, content)
            return ai_message
        except Exception as e:
            # 如果AI回复生成失败，仍然返回用户的消息
            print(f"AI回复生成失败: {e}")
    
    return db_message

@router.post("/{conversation_id}/messages/voice", response_model=Message)
async def add_voice_message(
    conversation_id: int,
    audio: UploadFile = File(...),
    sender: str = Form(...),
    db: Session = Depends(get_db)
):
    """
    向对话添加语音消息
    用户通过麦克风发送俄语语音，系统自动识别并翻译
    """
    # 验证对话是否存在
    db_conversation = conversation_service.get_conversation(db, conversation_id=conversation_id)
    if db_conversation is None:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    # 保存音频文件
    os.makedirs(settings.AUDIO_STORAGE_PATH, exist_ok=True)
    file_extension = os.path.splitext(audio.filename)[1] if audio.filename else ".wav"
    file_path = os.path.join(settings.AUDIO_STORAGE_PATH, f"voice_{conversation_id}_{int(time.time())}{file_extension}")
    
    # 保存上传的音频文件
    with open(file_path, "wb") as buffer:
        content = await audio.read()
        buffer.write(content)
    
    # 语音识别（俄语）
    recognized_text = voice_service.speech_to_text(file_path, language="ru-RU")
    if not recognized_text:
        raise HTTPException(status_code=400, detail="Failed to recognize speech")
    
    # 创建消息
    message = MessageCreate(
        conversation_id=conversation_id,
        sender=sender,
        content=recognized_text,
        audio_url=file_path,
        audio_duration=0.0  # 在实际应用中应该从音频文件中获取时长
    )
    
    # 添加消息到数据库
    db_message = conversation_service.add_message(db, message=message)
    
    # 如果是用户发送的消息，则自动生成AI回复
    if sender == "user":
        try:
            ai_message = conversation_service.generate_ai_response(db, conversation_id, recognized_text)
            return ai_message
        except Exception as e:
            # 如果AI回复生成失败，仍然返回用户的消息
            print(f"AI回复生成失败: {e}")
    
    return db_message

@router.get("/{conversation_id}/messages/", response_model=List[Message])
def get_messages(conversation_id: int, db: Session = Depends(get_db)):
    """
    获取对话中的所有消息
    """
    # 验证对话是否存在
    db_conversation = conversation_service.get_conversation(db, conversation_id=conversation_id)
    if db_conversation is None:
        raise HTTPException(status_code=404, detail="Conversation not found")
        
    # 获取消息
    messages = conversation_service.get_messages(db, conversation_id=conversation_id)
    return messages

@router.put("/messages/{message_id}", response_model=Message)
def update_message_thinking_status(message_id: int, message_update: MessageUpdate, db: Session = Depends(get_db)):
    """
    更新消息的思考状态（AI正在输入动画）
    """
    db_message = conversation_service.update_message_thinking_status(
        db, 
        message_id=message_id, 
        is_thinking=message_update.is_thinking
    )
    if db_message is None:
        raise HTTPException(status_code=404, detail="Message not found")
    return db_message

@router.post("/{conversation_id}/ai_response/", response_model=Message)
def generate_ai_response(
    conversation_id: int,
    user_message: str = Form(...),  # 修改为Form参数
    db: Session = Depends(get_db)
):
    """
    生成AI回复
    """
    # 验证对话是否存在
    db_conversation = conversation_service.get_conversation(db, conversation_id=conversation_id)
    if db_conversation is None:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    try:
        # 生成AI回复
        ai_message = conversation_service.generate_ai_response(db, conversation_id, user_message)
        return ai_message
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate AI response: {str(e)}")

@router.post("/{conversation_id}/end/", response_model=Report)
def end_conversation(conversation_id: int, db: Session = Depends(get_db)):
    """
    结束对话并生成报告
    """
    # 更新对话状态为已结束
    db_conversation = conversation_service.update_conversation_status(
        db, 
        conversation_id=conversation_id, 
        status="ended"
    )
    if db_conversation is None:
        raise HTTPException(status_code=404, detail="Conversation not found")
        
    # 生成报告
    report = report_service.create_report(db, conversation_id=conversation_id)
    if report is None:
        raise HTTPException(status_code=500, detail="Failed to generate report")
        
    return report