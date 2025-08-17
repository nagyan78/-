from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
from app.schemas.scenario import Scenario

class ConversationBase(BaseModel):
    """
    对话基础模型
    """
    scenario_id: int
    user_id: str

class ConversationCreate(ConversationBase):
    """
    创建对话请求模型
    """
    pass

class ConversationUpdate(BaseModel):
    """
    更新对话请求模型
    """
    status: Optional[str] = None
    ended_at: Optional[datetime] = None

class MessageBase(BaseModel):
    """
    消息基础模型
    """
    conversation_id: int
    sender: str  # user 或 ai
    content: str
    audio_url: Optional[str] = None
    audio_duration: Optional[float] = None
    is_thinking: Optional[bool] = False

class MessageCreate(MessageBase):
    """
    创建消息请求模型
    """
    pass

class MessageUpdate(BaseModel):
    """
    更新消息请求模型
    """
    is_thinking: Optional[bool] = None

class MessageInDB(MessageBase):
    """
    数据库消息模型
    """
    id: int
    timestamp: datetime

    class Config:
        orm_mode = True

class Message(MessageInDB):
    """
    消息响应模型
    """
    pass

class ConversationInDB(ConversationBase):
    """
    数据库对话模型
    """
    id: int
    status: str
    started_at: datetime
    ended_at: Optional[datetime] = None
    scenario: Optional[Scenario] = None
    messages: List[Message] = []

    class Config:
        orm_mode = True

class Conversation(ConversationInDB):
    """
    对话响应模型
    """
    pass