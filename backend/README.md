# Talk to AI Backend

基于FastAPI的后端服务，提供AI对话、语音识别、评分等功能。

## 项目创意

随着"一带一路"倡议的推进，中俄贸易合作日益密切，对俄语人才的需求不断增加。然而，传统的俄语学习方式往往缺乏真实的对话练习环境，导致学习者难以掌握实际交流能力。

本项目旨在通过AI技术构建一个沉浸式的俄语对话练习平台，让用户能够在各种真实场景中与AI进行俄语对话，提高口语表达能力。系统通过语音识别、自然语言处理和语音合成技术，为用户提供实时的对话反馈和多维度评分，帮助用户有效提升俄语水平。

## 实现功能

### 核心功能
- **多场景对话练习**：提供餐厅点餐、购物、问路等多种俄语对话场景
- **语音对话交互**：支持语音输入和语音回复，模拟真实对话环境
- **智能AI对话**：基于通义千问大模型的AI助手，提供自然流畅的俄语对话
- **多维度评分系统**：从发音、语法、流利度、词汇四个方面对用户表达进行评分
- **对话报告分析**：生成详细的对话报告，包含高亮金句、情感分析和改进建议
- **离线缓存支持**：网络不稳定时也能使用，数据会在网络恢复后同步

### 技术特色
- **实时语音识别**：准确识别用户俄语语音输入
- **智能对话生成**：基于上下文的AI对话回复生成
- **多维度评估**：综合评估用户俄语表达能力
- **个性化学习**：根据用户表现提供个性化学习建议

## 功能特性

- 用户认证和匿名访问
- 场景管理（预设场景和自定义场景）
- 实时对话处理
- 语音识别和文本转语音
- 多维度评分系统（发音、语法、流利度、词汇）
- 对话报告生成
- 离线缓存支持

## API文档

详细的API文档请参考 [API_DOCUMENTATION.md](API_DOCUMENTATION.md)

## 技术栈

- FastAPI - 高性能Web框架
- SQLAlchemy - ORM框架
- SQLite - 数据库
- DashScope/Qwen - 阿里云通义千问大模型API
- SpeechRecognition - 语音识别
- PyAudio - 音频处理

## 快速开始

### 安装依赖

```bash
pip install -r requirements.txt
```

### 环境配置

设置DashScope API密钥：

```bash
export DASHSCOPE_API_KEY=你的API密钥
```

在Windows上：

```cmd
set DASHSCOPE_API_KEY=你的API密钥
```

### 初始化数据库

```bash
python app/core/init_db.py
```

### 启动服务

```bash
python main.py
```

服务将在 http://localhost:8000 上运行。

## API文档

启动服务后，访问 http://localhost:8000/docs 查看交互式API文档。

## 项目结构

```
app/
├── api/              # API路由
│   └── v1/
│       ├── api.py    # API路由聚合
│       └── endpoints/ # API端点实现
├── core/             # 核心配置和初始化
├── models/           # 数据库模型
├── schemas/          # 数据验证模型
├── services/         # 业务逻辑实现
└── utils/            # 工具函数
```

## 可执行成果

### 当前版本
目前项目处于开发阶段，尚未发布正式版本。用户可以通过以下方式获取和运行后端服务：

1. 克隆项目源代码:
   ```
   git clone [项目地址]
   ```

2. 进入后端目录:
   ```
   cd talk_to_ai_fullstack/backend
   ```

3. 按照上述"快速开始"指南进行本地部署

### 未来发布计划
我们计划在项目稳定后发布以下可执行成果：

1. **Docker镜像** - 可通过Docker直接部署的后端服务镜像
2. **独立可执行文件** - 打包了所有依赖的独立可执行文件
3. **云服务部署包** - 适用于各种云平台的部署包

所有可执行文件将在项目的[Release区域](https://github.com/your-username/talk-to-ai/releases)发布。

## 访问方式

### 开发环境访问
- API地址: http://localhost:8000
- API文档地址: http://localhost:8000/docs

### 生产环境访问
部署后可通过以下方式访问:
- API地址: http://your-domain.com/api
- API文档地址: http://your-domain.com/docs

## 配置说明

### 环境变量

- `DASHSCOPE_API_KEY` - sk-ea0da86aed5646b6b3683bacddc5ecae
- `AUDIO_STORAGE_PATH` - 音频文件存储路径（可选，默认为`./storage`）

### 数据库

使用SQLite数据库，默认存储在项目根目录的`talk_to_ai.db`文件中。

## 开发指南

### 添加新功能

1. 在`schemas/`中定义数据模型
2. 在`models/`中定义数据库模型
3. 在`services/`中实现业务逻辑
4. 在`api/v1/endpoints/`中添加API端点
5. 在`api/v1/api.py`中注册路由

### 代码规范

- 遵循PEP 8代码规范
- 使用类型注解
- 编写清晰的文档字符串

## 部署

### 生产环境部署

推荐使用Gunicorn或Uvicorn部署：

```bash
gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app
```

### Docker部署

创建Docker镜像：

```bash
# 构建镜像
docker build -t talk-to-ai-backend .

# 运行容器
docker run -p 8000:8000 talk-to-ai-backend
```

### 云服务部署

项目可以部署到以下云服务平台：
1. 阿里云ECS
2. 腾讯云CVM
3. AWS EC2
4. Google Cloud Platform
5. Microsoft Azure

## 许可证

本项目仅供学习和研究使用。

## 联系方式

如有问题，请提交Issue或联系项目维护者。