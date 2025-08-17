from fastapi import APIRouter
from app.api.v1.endpoints import scenario, conversation, report, auth, offline

api_router = APIRouter()

api_router.include_router(auth.router)
api_router.include_router(scenario.router)
api_router.include_router(conversation.router)
api_router.include_router(report.router)
api_router.include_router(offline.router)