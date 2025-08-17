import uuid
from typing import Optional
from datetime import datetime, timedelta
from jose import JWTError, jwt
from app.core.config import settings

class AuthService:
    """
    认证服务类
    处理用户认证相关的业务逻辑
    """
    
    def generate_anonymous_user_id(self) -> str:
        """
        生成匿名用户ID
        """
        return f"anon_{uuid.uuid4().hex}"
    
    def create_access_token(self, user_id: str, expires_delta: Optional[timedelta] = None) -> str:
        """
        创建访问令牌
        """
        to_encode = {"sub": user_id}
        if expires_delta:
            expire = datetime.utcnow() + expires_delta
        else:
            expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        to_encode.update({"exp": expire})
        encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm="HS256")
        return encoded_jwt
    
    def verify_token(self, token: str) -> Optional[str]:
        """
        验证访问令牌
        """
        try:
            payload = jwt.decode(token, settings.SECRET_KEY, algorithms=["HS256"])
            user_id: str = payload.get("sub")
            if user_id is None:
                return None
            return user_id
        except JWTError:
            return None

auth_service = AuthService()