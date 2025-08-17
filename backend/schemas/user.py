from pydantic import BaseModel
from typing import Optional

class UserBase(BaseModel):
    """
    用户基础模型
    """
    pass

class UserCreate(UserBase):
    """
    创建用户请求模型
    """
    pass

class User(UserBase):
    """
    用户模型
    """
    id: str
    is_active: bool = True

    class Config:
        orm_mode = True

class Token(BaseModel):
    """
    令牌模型
    """
    access_token: str
    token_type: str

class TokenData(BaseModel):
    """
    令牌数据模型
    """
    user_id: Optional[str] = None