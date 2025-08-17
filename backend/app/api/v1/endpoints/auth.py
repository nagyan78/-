from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from datetime import timedelta
from app.schemas.user import User, Token
from app.services.auth_service import auth_service

router = APIRouter(prefix="/auth", tags=["authentication"])
security = HTTPBearer()

@router.post("/anonymous", response_model=Token)
def create_anonymous_user():
    """
    创建匿名用户并返回访问令牌
    """
    user_id = auth_service.generate_anonymous_user_id()
    access_token_expires = timedelta(minutes=30)
    access_token = auth_service.create_access_token(
        user_id, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """
    获取当前用户（基于令牌）
    """
    token = credentials.credentials
    user_id = auth_service.verify_token(token)
    if user_id is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user_id