from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

# 创建数据库引擎
engine = create_engine(
    settings.DATABASE_URL,
    # echo=True,  # 开发时可以开启，用于查看生成的SQL
    connect_args={"check_same_thread": False}  # 仅用于SQLite
)

# 创建SessionLocal类
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 创建Base类
Base = declarative_base()

def get_db():
    """
    获取数据库会话的依赖项
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()