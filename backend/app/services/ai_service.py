import os
import logging
from typing import Optional, Dict, Any, List
import dashscope
from openai import OpenAI
from app.services.voice_service import voice_service

# 配置日志记录
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

class AIService:
    """
    AI服务类
    处理AI对话回复生成功能
    """
    
    def __init__(self):
        # 获取API密钥
        self.api_key = os.getenv("DASHSCOPE_API_KEY") or "sk-ea0da86aed5646b6b3683bacddc5ecae"
        logger.info(f"使用API密钥: {self.api_key[:5]}... 初始化DashScope客户端")
        
        # 初始化dashscope
        dashscope.api_key = self.api_key
    
    def generate_initial_message(self, scenario: Dict[str, Any]) -> Optional[str]:
        """
        根据场景信息生成AI的初始消息
        :param scenario: 场景信息
        :return: AI的初始消息（中文介绍+俄语对话）
        """
        # 构造提示词
        location = scenario.get("location", "")
        time_of_day = scenario.get("time_of_day", "")
        characters = scenario.get("characters", [])
        
        # 构造场景描述
        character_description = "，".join(characters) if characters else "相关人员"
        
        prompt = f"你正在扮演一个在{location}的{character_description}。现在是{time_of_day}，请先用中文向用户介绍当前场景（一句话即可），然后用俄语主动向用户打招呼并开始对话。请根据场景提供合适的开场白，比如询问需要什么帮助、介绍当前环境等。按照以下格式返回：\n[中文场景介绍]\n[俄语对话内容]"
        
        messages = [
            {
                "role": "user",
                "content": prompt
            }
        ]
        
        try:
            logger.debug(f"调用DashScope API生成回复，模型: qwen-plus")
            logger.debug(f"请求参数: {messages}")
            
            response = dashscope.Generation.call(
                model="qwen-plus",
                messages=messages,
                result_format="message"
            )
            
            if response.status_code == 200:
                # 返回AI回复
                result = response.output.choices[0].message.content
                logger.debug(f"API返回结果: {result}")
                return result
            else:
                logger.error(f"AI初始消息生成失败: {response}")
                return f"您正在{location}场景中与{character_description}对话。\nЗдравствуйте! Добро пожаловать!"  # 默认消息
        except Exception as e:
            # 如果调用失败，返回默认消息
            logger.error(f"AI初始消息生成失败: {e}", exc_info=True)
            return f"您正在{location}场景中与{character_description}对话。\nЗдравствуйте! Добро пожаловать!"  # 默认消息
    
    def generate_response(self, user_message: str, scenario: Dict[str, Any], conversation_history: List[Dict[str, str]] = None) -> Optional[str]:
        """
        根据用户消息、场景信息和对话历史生成AI回复（俄语）
        :param user_message: 用户消息
        :param scenario: 场景信息
        :param conversation_history: 对话历史记录
        :return: AI回复（俄语）
        """
        logger.info("生成AI回复")
        logger.debug(f"用户消息: {user_message}")
        logger.debug(f"接收到的场景信息: {scenario}")
        logger.debug(f"对话历史: {conversation_history}")
        
        # 构造场景描述
        location = scenario.get("location", "")
        time_of_day = scenario.get("time_of_day", "")
        characters = scenario.get("characters", [])
        
        # 构造角色设定
        character_description = "，".join(characters) if characters else "相关人员"
        logger.debug(f"角色描述: {character_description}")
        
        system_prompt = f"你正在扮演一个在{location}的{character_description}。现在是{time_of_day}，请用俄语与用户对话。"
        logger.debug(f"系统提示: {system_prompt}")
        
        # 构造消息历史
        messages = []
        
        # 添加系统提示作为第一个消息
        messages.append({
            "role": "system",
            "content": system_prompt
        })
        
        # 如果有对话历史，则添加到消息中
        if conversation_history:
            messages.extend(conversation_history)
        
        # 添加当前用户消息
        messages.append({
            "role": "user",
            "content": user_message
        })
        
        try:
            logger.debug("调用DashScope API生成回复")
            logger.debug(f"发送给API的消息: {messages}")
            response = dashscope.Generation.call(
                model="qwen-plus",
                messages=messages,
                result_format="message"
            )
            
            if response.status_code == 200:
                result = response.output.choices[0].message.content
                logger.debug(f"API响应内容: {result}")
                # 返回AI回复
                return result
            else:
                logger.error(f"AI调用失败: {response}")
                return "Извините, я не понял. Можете повторить?"  # 对不起，我不明白，请重复
                
        except Exception as e:
            logger.error(f"AI调用失败: {e}", exc_info=True)
            return "Извините, я не понял. Можете повторить?"  # 对不起，我不明白，请重复
    
    def generate_chinese_evaluation(self, user_message: str) -> dict:
        """
        生成对用户俄语消息的中文评价
        :param user_message: 用户的俄语消息
        :return: 中文评价信息
        """
        # 构造评价分析提示
        evaluation_prompt = f"请对以下俄语语句进行发音、语法、流利度和词汇四个维度的评分（每项满分100分），并给出中文的总体评价和具体建议。用户俄语语句: \"{user_message}\"。请严格按照以下JSON格式返回结果: {{\"overall_score\": 85, \"pronunciation\": 80, \"grammar\": 85, \"fluency\": 90, \"vocabulary\": 88, \"evaluation_text\": \"很好！您的俄语表达比较自然。\", \"suggestions\": [\"继续保持练习，您的俄语正在进步！\"]}}"
        
        messages = [
            {
                "role": "user",
                "content": evaluation_prompt
            }
        ]
        
        try:
            # 调用阿里云百炼Qwen模型进行评价
            response = dashscope.Generation.call(
                model="qwen-plus",
                messages=messages,
                result_format="message"
            )
            
            if response.status_code == 200:
                # 解析返回的JSON
                import json
                response_content = response.output.choices[0].message.content
                # 去掉可能的markdown代码块标记
                if response_content.startswith("```json"):
                    response_content = response_content[7:]
                if response_content.endswith("```"):
                    response_content = response_content[:-3]
                
                evaluation_result = json.loads(response_content)
                return evaluation_result
            else:
                logger.error(f"评价AI调用失败: {response}")
                
        except Exception as e:
            # 如果调用失败，使用原来的随机评价
            logger.error(f"评价AI调用失败，使用默认评价: {e}", exc_info=True)
            import random
            
            # 评价维度
            pronunciation = random.randint(60, 100)  # 发音评分
            grammar = random.randint(60, 100)  # 语法评分
            fluency = random.randint(60, 100)  # 流利度评分
            vocabulary = random.randint(60, 100)  # 词汇评分
            
            # 综合评分
            overall_score = (pronunciation + grammar + fluency + vocabulary) // 4
            
            # 评价文本
            if overall_score >= 90:
                evaluation_text = "非常好！您的俄语表达很地道。"
            elif overall_score >= 80:
                evaluation_text = "很好！您的俄语表达比较自然。"
            elif overall_score >= 70:
                evaluation_text = "不错！继续练习会更好。"
            else:
                evaluation_text = "还需要加强练习，加油！"
            
            # 具体建议
            suggestions = []
            if pronunciation < 80:
                suggestions.append("注意俄语的发音，特别是元音的清晰度。")
            if grammar < 80:
                suggestions.append("注意俄语的语法结构，特别是动词变位。")
            if fluency < 80:
                suggestions.append("尝试使用更完整的句子进行表达。")
            if vocabulary < 80:
                suggestions.append("扩展词汇量，学习更多日常用语。")
            
            if not suggestions:
                suggestions.append("继续保持练习，您的俄语正在进步！")
            
            return {
                "overall_score": overall_score,
                "pronunciation": pronunciation,
                "grammar": grammar,
                "fluency": fluency,
                "vocabulary": vocabulary,
                "evaluation_text": evaluation_text,
                "suggestions": suggestions
            }
    
    def generate_response_with_voice(self, user_message: str, scenario: Dict[str, Any], conversation_history: List[Dict[str, str]] = None) -> dict:
        """
        生成AI回复的中文评价和评分
        :param user_message: 用户消息
        :param scenario: 场景信息
        :param conversation_history: 对话历史记录
        :return: 包含中文评价和评分的字典
        """
        logger.info("生成AI回复的中文评价和评分")
        logger.debug(f"用户消息: {user_message}")
        logger.debug(f"场景信息: {scenario}")
        logger.debug(f"对话历史: {conversation_history}")
        
        try:
            # 生成中文评价和评分
            evaluation_result = self.generate_chinese_evaluation(user_message)
            logger.debug(f"生成的评价结果: {evaluation_result}")
            
            return evaluation_result
        except Exception as e:
            logger.error(f"生成评价失败: {e}", exc_info=True)
            # 返回默认评价
            return {
                "overall_score": 80,
                "pronunciation": 85,
                "grammar": 75,
                "fluency": 80,
                "vocabulary": 78,
                "evaluation_text": "系统默认评价",
                "suggestions": ["请继续努力练习俄语"]
            }

ai_service = AIService()