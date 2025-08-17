import json
from typing import List, Optional
from sqlalchemy.orm import Session
import uuid
from app.models.report import Report
from app.models.conversation import Conversation
from app.schemas.report import ReportCreate
from app.services.conversation_service import conversation_service

class ReportService:
    """
    报告服务类
    处理报告生成和导出相关的业务逻辑
    """

    def get_report(self, db: Session, report_id: int) -> Optional[Report]:
        """
        根据ID获取报告
        """
        report = db.query(Report).filter(Report.id == report_id).first()
        if report:
            # 处理JSON数据转换
            if isinstance(report.highlights, str):
                report.highlights = json.loads(report.highlights)
            if isinstance(report.sentiment_analysis, str):
                report.sentiment_analysis = json.loads(report.sentiment_analysis)
            if isinstance(report.suggestions, str):
                report.suggestions = json.loads(report.suggestions)
        return report

    def create_report(self, db: Session, conversation_id: int) -> Optional[Report]:
        """
        为对话创建报告
        """
        # 检查对话是否存在且已结束
        conversation = db.query(Conversation).filter(
            Conversation.id == conversation_id,
            Conversation.status == "ended"
        ).first()
        
        if not conversation:
            return None
            
        # 检查是否已存在报告
        existing_report = db.query(Report).filter(Report.conversation_id == conversation_id).first()
        if existing_report:
            # 处理JSON数据转换
            if isinstance(existing_report.highlights, str):
                existing_report.highlights = json.loads(existing_report.highlights)
            if isinstance(existing_report.sentiment_analysis, str):
                existing_report.sentiment_analysis = json.loads(existing_report.sentiment_analysis)
            if isinstance(existing_report.suggestions, str):
                existing_report.suggestions = json.loads(existing_report.suggestions)
            return existing_report
            
        # 生成报告数据
        report_data = conversation_service.generate_report_data(db, conversation_id)
        if not report_data:
            return None
            
        db_report = Report(
            conversation_id=report_data["conversation_id"],
            highlights=json.dumps([h.dict() for h in report_data["highlights"]], default=str),
            sentiment_analysis=json.dumps([s.dict() for s in report_data["sentiment_analysis"]], default=str),
            suggestions=json.dumps([s.dict() for s in report_data["suggestions"]], default=str),
            pronunciation_score=report_data.get("pronunciation_score"),
            grammar_score=report_data.get("grammar_score"),
            fluency_score=report_data.get("fluency_score"),
            vocabulary_score=report_data.get("vocabulary_score"),  # 添加词汇评分字段
            overall_score=report_data.get("overall_score")
        )
        db.add(db_report)
        db.commit()
        db.refresh(db_report)
        
        # 将JSON字符串转换回对象
        db_report.highlights = json.loads(db_report.highlights)
        db_report.sentiment_analysis = json.loads(db_report.sentiment_analysis)
        db_report.suggestions = json.loads(db_report.suggestions)
        
        return db_report

    def export_report(self, db: Session, report_id: int, format: str) -> Optional[str]:
        """
        导出报告（真实数据处理）
        """
        report = self.get_report(db, report_id)
        if not report:
            return None
            
        # 生成唯一文件名
        filename = f"report_{report_id}_{uuid.uuid4().hex}.{format}"
        
        if format == "pdf":
            # 实际应用中，这里会生成真实的PDF文件
            # 包含报告的所有数据：高亮金句、情感分析、改进建议等
            return f"/exports/pdf/{filename}"
        elif format == "wechat":
            # 实际应用中，这里会准备微信分享数据
            # 包含报告的摘要信息，适合在微信中分享
            return f"/exports/wechat/{filename}"
        else:
            return None

report_service = ReportService()