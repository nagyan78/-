from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from app.api.v1.api import api_router
from app.core.config import settings

@asynccontextmanager
async def lifespan(app: FastAPI):
    # 启动时的初始化操作
    print("Starting Talk to AI backend...")
    # 确保数据库初始化
    from app.core.init_db import init_db
    init_db()
    yield
    # 关闭时的清理操作
    print("Shutting down Talk to AI backend...")

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="AI对话练习后端API，支持场景创建、实时对话和复盘报告",
    version="1.5.0",
    lifespan=lifespan
)

# 添加CORS中间件以解决跨域问题
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 在生产环境中应该指定具体的域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    allow_origin_regex=None,
    expose_headers=[]
)

# 包含API路由
app.include_router(api_router, prefix=settings.API_V1_STR)

@app.get("/")
async def root():
    return {"message": "Talk to AI Backend", "version": "1.5.0"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

# 添加一个端点来获取系统统计信息
@app.get("/stats")
async def get_stats():
    """
    获取系统统计信息
    """
    return {
        "message": "System stats endpoint",
        "status": "active"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)