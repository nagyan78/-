from pydantic import BaseModel
from typing import List, Optional, Any
from datetime import datetime

class HighlightPhraseBase(BaseModel):
    """
    高亮金句基础模型
    """
    text: str
    timestamp: datetime
    translation: Optional[str] = None

class HighlightPhraseCreate(HighlightPhraseBase):
    """
    创建高亮金句请求模型
    """
    pass

class HighlightPhrase(HighlightPhraseBase):
    """
    高亮金句响应模型
    """
    id: int

    class Config:
        orm_mode = True

class SentimentPointBase(BaseModel):
    """
    情感分析点基础模型
    """
    timestamp: datetime
    sentiment_score: float  # -1 到 1，-1表示负面，1表示正面
    text: str

class SentimentPointCreate(SentimentPointBase):
    """
    创建情感分析点请求模型
    """
    pass

class SentimentPoint(SentimentPointBase):
    """
    情感分析点响应模型
    """
    id: int

    class Config:
        orm_mode = True

class ImprovementSuggestionBase(BaseModel):
    """
    改进建议基础模型
    """
    category: str  # 改进建议类别，如"词汇"、"语法"、"发音"
    text: str  # 改进建议内容
    priority: Optional[str] = None  # 优先级，如"high"、"medium"、"low"
    tip: Optional[str] = None  # 具体建议

class ImprovementSuggestionCreate(ImprovementSuggestionBase):
    """
    创建改进建议请求模型
    """
    pass

class ImprovementSuggestion(ImprovementSuggestionBase):
    """
    改进建议响应模型
    """
    id: int

    class Config:
        orm_mode = True

class ReportBase(BaseModel):
    """
    报告基础模型
    """
    conversation_id: int

class ReportCreate(BaseModel):
    """
    创建报告请求模型
    """
    conversation_id: int
    highlights: List[HighlightPhraseBase] = []
    sentiment_analysis: List[SentimentPointBase] = []
    suggestions: List[ImprovementSuggestionBase] = []
    pronunciation_score: Optional[float] = None
    grammar_score: Optional[float] = None
    fluency_score: Optional[float] = None
    vocabulary_score: Optional[float] = None
    overall_score: Optional[float] = None

class ReportUpdate(BaseModel):
    """
    更新报告请求模型
    """
    conversation_id: Optional[int] = None
    highlights: Optional[List[HighlightPhraseBase]] = None
    sentiment_analysis: Optional[List[SentimentPointBase]] = None
    suggestions: Optional[List[ImprovementSuggestionBase]] = None
    pronunciation_score: Optional[float] = None
    grammar_score: Optional[float] = None
    fluency_score: Optional[float] = None
    vocabulary_score: Optional[float] = None
    overall_score: Optional[float] = None

class ReportInDB(ReportBase):
    """
    数据库报告模型
    """
    id: int
    generated_at: datetime

    class Config:
        orm_mode = True

class Report(ReportInDB):
    """
    报告响应模型
    """
    highlights: List[HighlightPhrase] = []
    sentiment_analysis: List[SentimentPoint] = []
    suggestions: List[ImprovementSuggestion] = []
    pronunciation_score: Optional[float] = None
    grammar_score: Optional[float] = None
    fluency_score: Optional[float] = None
    vocabulary_score: Optional[float] = None
    overall_score: Optional[float] = None

class ReportExport(BaseModel):
    """
    报告导出模型
    """
    format: str  # 'pdf' 或 'wechat'
    report_id: int

class SpeechEvaluation(BaseModel):
    """
    语音评价模型
    """
    overall_score: int
    pronunciation: int
    grammar: int
    fluency: int
    evaluation_text: str
    suggestions: List[str]