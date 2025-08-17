import os
from typing import Optional
from pydantic import BaseSettings

class Settings(BaseSettings):
    # 项目配置
    PROJECT_NAME: str = "Talk to AI"
    API_V1_STR: str = "/api/v1"
    
    # 数据库配置
    DATABASE_URL: str = "sqlite:///./talk_to_ai.db"
    
    # JWT配置
    SECRET_KEY: str = "your-secret-key-here"  # 在生产环境中应该使用安全的密钥
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # 存储配置
    AUDIO_STORAGE_PATH: str = "./storage/audio"
    REPORT_STORAGE_PATH: str = "./storage/reports"
    
    # AI服务配置
    QWEN_API_KEY: Optional[str] = None  # 通义千问API密钥
    QWEN_MODEL: str = "qwen-plus"  # 通义千问模型名称
    AI_SERVICE_URL: Optional[str] = None
    
    # 语音服务配置
    SPEECH_RECOGNITION_SERVICE: str = "google"  # 语音识别服务提供商
    TRANSLATION_SERVICE: str = "google"  # 翻译服务提供商
    TTS_SERVICE: str = "google"  # 文本转语音服务提供商
    
    class Config:
        case_sensitive = True

settings = Settings()