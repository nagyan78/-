from sqlalchemy import Column, Integer, String, Text, DateTime
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from sqlalchemy.ext.hybrid import hybrid_property
from app.core.database import Base
from typing import List
import json

class Scenario(Base):
    __tablename__ = "scenarios"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(Text, nullable=True)
    location = Column(String)
    time_of_day = Column(String)  # 例如: "morning", "afternoon", "evening"
    _characters = Column("characters", String, default="[]")  # JSON格式存储人物列表
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # 关联关系 - 使用字符串引用解决循环依赖
    conversations = relationship("Conversation", back_populates="scenario")
    
    @hybrid_property
    def characters(self) -> List[str]:
        """
        获取人物列表
        """
        # 处理空值情况
        if self._characters is None:
            return []
        
        # 处理字符串情况
        if isinstance(self._characters, str):
            if self._characters.strip() == "":
                return []
            try:
                return json.loads(self._characters)
            except (json.JSONDecodeError, TypeError):
                return []
        
        # 如果已经是列表格式，直接返回
        if isinstance(self._characters, list):
            return self._characters
            
        return []
    
    @characters.setter
    def characters(self, value: List[str]):
        """
        设置人物列表，将其序列化为JSON字符串存储
        """
        if value is None:
            self._characters = "[]"
        else:
            try:
                self._characters = json.dumps(value)
            except (TypeError, ValueError):
                self._characters = "[]"
    
    @characters.expression
    def characters(self):
        """
        为SQL表达式提供支持
        """
        return self._characters