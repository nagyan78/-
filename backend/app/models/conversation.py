from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, Float, Boolean
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.core.database import Base

class Conversation(Base):
    __tablename__ = "conversations"
    
    id = Column(Integer, primary_key=True, index=True)
    scenario_id = Column(Integer, ForeignKey("scenarios.id"))
    user_id = Column(String, index=True)  # 匿名用户ID
    status = Column(String, default="active")  # active, paused, ended
    started_at = Column(DateTime(timezone=True), server_default=func.now())
    ended_at = Column(DateTime(timezone=True), nullable=True)
    
    # 关联关系会在所有模型加载后通过configure_mappers设置

class Message(Base):
    __tablename__ = "messages"
    
    id = Column(Integer, primary_key=True, index=True)
    conversation_id = Column(Integer, ForeignKey("conversations.id"))
    sender = Column(String)  # user 或 ai
    content = Column(Text)  # 文本内容
    audio_url = Column(String, nullable=True)  # 音频文件URL
    audio_duration = Column(Float, nullable=True)  # 音频时长（秒）
    is_thinking = Column(Boolean, default=False)  # AI正在输入动画
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
    
    # 关联关系
    conversation = relationship("Conversation", back_populates="messages")

# 在所有模型定义后设置关系
from sqlalchemy.orm import configure_mappers

def setup_relationships():
    # 为Conversation设置关系
    from app.models.report import Report
    from app.models.scenario import Scenario
    
    Conversation.scenario = relationship("Scenario", back_populates="conversations")
    Conversation.messages = relationship("Message", back_populates="conversation")
    Conversation.report = relationship("Report", back_populates="conversation", uselist=False)

# 当模块被导入时设置关系
setup_relationships()