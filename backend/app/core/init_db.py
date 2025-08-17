from sqlalchemy.orm import Session
from sqlalchemy import text
from app.core.database import engine, SessionLocal
# 调整导入顺序以解决循环依赖问题
from app.models import scenario, conversation, report
import logging

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def upgrade_db():
    """
    升级数据库结构，确保所有字段都存在
    """
    try:
        # 检查并添加vocabulary_score字段（如果不存在）
        with engine.connect() as conn:
            # 检查字段是否存在
            result = conn.execute(text("PRAGMA table_info(reports)"))
            columns = [row[1] for row in result.fetchall()]
            
            if 'vocabulary_score' not in columns:
                logger.info("Adding vocabulary_score column to reports table")
                conn.execute(text("ALTER TABLE reports ADD COLUMN vocabulary_score FLOAT"))
                conn.commit()
                logger.info("vocabulary_score column added successfully")
            else:
                logger.info("vocabulary_score column already exists")
    except Exception as e:
        logger.error(f"Error upgrading database: {e}")

def init_db():
    """
    初始化数据库，创建所有表
    """
    scenario.Base.metadata.create_all(bind=engine)
    conversation.Base.metadata.create_all(bind=engine)
    report.Base.metadata.create_all(bind=engine)
    
    # 执行数据库升级
    upgrade_db()

if __name__ == "__main__":
    init_db()
    print("Database tables created successfully!")