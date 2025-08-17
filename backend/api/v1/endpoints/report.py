from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import json
from app.schemas.report import Report, ReportExport
from app.services.report_service import report_service
from app.core.database import get_db

router = APIRouter(prefix="/reports", tags=["reports"])

@router.get("/{report_id}", response_model=Report)
def read_report(report_id: int, db: Session = Depends(get_db)):
    """
    根据ID获取报告
    """
    db_report = report_service.get_report(db, report_id=report_id)
    if db_report is None:
        raise HTTPException(status_code=404, detail="Report not found")
        
    return db_report

@router.get("/conversation/{conversation_id}", response_model=Report)
def read_report_by_conversation(conversation_id: int, db: Session = Depends(get_db)):
    """
    根据对话ID获取报告
    """
    db_report = report_service.get_report_by_conversation(db, conversation_id=conversation_id)
    if db_report is None:
        raise HTTPException(status_code=404, detail="Report not found")
        
    return db_report

@router.post("/export/", response_model=dict)
def export_report(report_export: ReportExport, db: Session = Depends(get_db)):
    """
    导出报告（PDF或微信分享）
    """
    file_path = report_service.export_report(
        db, 
        report_id=report_export.report_id, 
        format=report_export.format
    )
    
    if file_path is None:
        raise HTTPException(status_code=404, detail="Report not found or export failed")
        
    # 根据导出格式返回不同的信息
    if report_export.format == "pdf":
        return {
            "file_path": file_path, 
            "message": "Report exported as PDF successfully",
            "download_url": f"http://localhost:8000{file_path}"  # 实际应用中应该是真实的下载链接
        }
    elif report_export.format == "wechat":
        return {
            "file_path": file_path, 
            "message": "Report prepared for WeChat sharing successfully",
            "share_data": {
                "title": "对话练习报告",
                "description": "点击查看您的AI对话练习报告",
                "thumb_url": "http://example.com/thumb.png"  # 实际应用中应该是真实的缩略图链接
            }
        }
    else:
        return {"file_path": file_path, "message": "Report exported successfully"}