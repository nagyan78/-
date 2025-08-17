from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class ScenarioBase(BaseModel):
    """
    场景基础模型
    """
    title: str
    description: Optional[str] = None
    location: str
    time_of_day: str  # 例如: "morning", "afternoon", "evening"
    characters: List[str]  # 参与人物列表

class ScenarioCreate(ScenarioBase):
    """
    创建场景请求模型
    """
    pass

class ScenarioUpdate(ScenarioBase):
    """
    更新场景请求模型
    """
    title: Optional[str] = None
    location: Optional[str] = None
    time_of_day: Optional[str] = None
    characters: Optional[List[str]] = None

class ScenarioInDB(ScenarioBase):
    """
    数据库场景模型
    """
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True

class Scenario(ScenarioInDB):
    """
    场景响应模型
    """
    pass