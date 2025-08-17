from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, Float
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.core.database import Base

class Report(Base):
    __tablename__ = "reports"
    
    id = Column(Integer, primary_key=True, index=True)
    conversation_id = Column(Integer, ForeignKey("conversations.id"))
    highlights = Column(Text)  # JSON格式存储高亮金句
    sentiment_analysis = Column(Text)  # JSON格式存储情感分析数据
    suggestions = Column(Text)  # JSON格式存储改进建议
    pronunciation_score = Column(Float, nullable=True)  # 发音评分
    grammar_score = Column(Float, nullable=True)  # 语法评分
    fluency_score = Column(Float, nullable=True)  # 流利度评分
    vocabulary_score = Column(Float, nullable=True)  # 词汇评分
    overall_score = Column(Float, nullable=True)  # 综合评分
    generated_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 关联关系 - 使用字符串引用解决循环依赖
    conversation = relationship("Conversation", back_populates="report")

class HighlightPhrase(Base):
    __tablename__ = "highlight_phrases"
    
    id = Column(Integer, primary_key=True, index=True)
    report_id = Column(Integer, ForeignKey("reports.id"))
    text = Column(Text)
    timestamp = Column(DateTime(timezone=True))
    translation = Column(Text, nullable=True)

class SentimentPoint(Base):
    __tablename__ = "sentiment_points"
    
    id = Column(Integer, primary_key=True, index=True)
    report_id = Column(Integer, ForeignKey("reports.id"))
    timestamp = Column(DateTime(timezone=True))
    sentiment_score = Column(Float)  # -1 到 1，-1表示负面，1表示正面
    text = Column(Text)

class ImprovementSuggestion(Base):
    __tablename__ = "improvement_suggestions"
    
    id = Column(Integer, primary_key=True, index=True)
    report_id = Column(Integer, ForeignKey("reports.id"))
    category = Column(String)  # 改进建议类别，如"词汇"、"语法"、"发音"
    text = Column(Text)  # 改进建议内容
    importance = Column(Integer)  # 重要性，1-5级