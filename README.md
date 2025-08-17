# Talk to AI - 俄语学习对话系统

一个基于AI的俄语学习对话系统，帮助用户通过真实场景对话练习俄语口语能力。

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

## 技术架构

### 后端 (Python)
- FastAPI - 高性能Web框架
- SQLAlchemy - ORM框架
- SQLite - 数据库
- DashScope/Qwen - 阿里云通义千问大模型API
- SpeechRecognition - 语音识别
- PyAudio - 音频处理

### 前端 (Flutter)
- Flutter - 跨平台移动应用开发框架
- Dart - 编程语言
- http - HTTP客户端
- audioplayers - 音频播放
- shared_preferences - 本地数据存储
- permission_handler - 权限管理

## 项目结构

```
talk_to_ai_fullstack/
├── backend/          # Python后端服务
├── frontend/         # Flutter前端应用
├── docs/             # 项目文档
└── scripts/          # 部署和构建脚本
```

## 快速开始

### 后端服务

1. 进入后端目录:
   ```
   cd backend
   ```

2. 安装依赖:
   ```
   pip install -r requirements.txt
   ```

3. 设置DashScope API密钥:
   ```
   export DASHSCOPE_API_KEY=你的API密钥
   ```
   
   Windows系统使用:
   ```
   set DASHSCOPE_API_KEY=你的API密钥
   ```

4. 初始化数据库:
   ```
   python app/core/init_db.py
   ```

5. 启动服务:
   ```
   python main.py
   ```

6. API文档: http://localhost:8000/docs

### 前端应用

1. 进入前端目录:
   ```
   cd frontend
   ```

2. 安装依赖:
   ```
   flutter pub get
   ```

3. 连接设备或启动模拟器

4. 运行应用:
   ```
   flutter run
   ```

## 部署指南

### 本地开发部署

1. 启动后端服务:
   ```
   cd backend
   python main.py
   ```

2. 启动前端应用:
   ```
   cd frontend
   flutter run
   ```

### 生产环境部署

#### 后端部署

使用Gunicorn或Uvicorn部署FastAPI应用:
```
cd backend
gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app
```

或者使用Uvicorn:
```
cd backend
uvicorn main:app --host 0.0.0.0 --port 8000
```

#### 前端部署

构建各平台应用:

1. Android APK:
   ```
   cd frontend
   flutter build apk
   ```

2. iOS应用:
   ```
   cd frontend
   flutter build ios
   ```

3. Web应用:
   ```
   cd frontend
   flutter build web
   ```

4. Windows桌面应用:
   ```
   cd frontend
   flutter build windows
   ```

### 使用自动化脚本部署

项目提供了跨平台的部署脚本:

#### Windows系统
```
scripts\deploy.bat
scripts\dev-start.bat
```

#### Unix/Linux/macOS系统
```
chmod +x scripts/deploy.sh
chmod +x scripts/dev-start.sh
./scripts/deploy.sh
./scripts/dev-start.sh
```

## 可执行成果

### 当前版本
目前项目处于开发阶段，尚未发布正式版本。用户可以通过以下方式获取和运行项目：

1. 克隆项目源代码:
   ```
   git clone [项目地址]
   ```

2. 按照上述"快速开始"指南进行本地部署

### 未来发布计划
我们计划在项目稳定后发布以下可执行成果：

1. **Android APK安装包** - 可直接在Android设备上安装使用的移动应用
2. **Web应用** - 可通过浏览器访问的在线版本
3. **Windows桌面应用** - 可在Windows系统上直接运行的桌面版本

### Release版本获取
所有正式发布的可执行文件将发布在项目的[Release区域](https://github.com/your-username/talk-to-ai/releases)。

目前暂无正式发布版本，但您可以关注我们的Release页面以获取最新动态。

## 访问方式

### 开发环境访问
1. 后端API地址: http://localhost:8000
2. API文档地址: http://localhost:8000/docs
3. 前端应用: 在移动设备或模拟器上运行

### 生产环境访问
部署后可通过以下方式访问:
1. Web应用: http://your-domain.com
2. 移动应用: 通过应用商店或APK安装包安装
3. 桌面应用: 下载对应平台的可执行文件运行

## API文档

详细的API文档请参考 [backend/API_DOCUMENTATION.md](backend/API_DOCUMENTATION.md)

## 配置说明

### 环境变量

- `DASHSCOPE_API_KEY` - 阿里云DashScope API密钥（必需）
- `AUDIO_STORAGE_PATH` - 音频文件存储路径（可选，默认为`./storage`）

## 开发指南

### 添加新场景

1. 在数据库中添加新的场景模板
2. 或通过API创建自定义场景

### 扩展AI功能

1. 修改 `backend/app/services/ai_service.py` 中的提示词
2. 调整评分算法在 `backend/app/services/conversation_service.py`

## 版本历史

详细的版本变更记录请查看 [CHANGELOG.md](CHANGELOG.md)

## 文档资源

- [用户手册](docs/user_manual.md) - 详细使用指南
- [架构文档](docs/architecture.md) - 系统架构和技术细节
- [后端文档](backend/README.md) - 后端服务详细说明
- [前端文档](frontend/README.md) - 前端应用详细说明

## 许可证

本项目仅供学习和研究使用。

## 联系方式

如有问题，请提交Issue或联系项目维护者。
