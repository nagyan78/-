# Talk to AI Frontend

基于Flutter的移动端应用，提供俄语对话练习功能。

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

- 多场景俄语对话练习（餐厅、购物、问路等）
- 语音输入和播放功能
- 实时对话交互
- 对话评分和报告查看
- 离线缓存支持
- 多媒体消息展示

## 技术栈

- Flutter - 跨平台移动应用开发框架
- Dart - 编程语言
- http - HTTP客户端
- audioplayers - 音频播放
- shared_preferences - 本地数据存储
- permission_handler - 权限管理

## 快速开始

### 环境准备

1. 安装Flutter SDK: https://flutter.dev/docs/get-started/install
2. 配置Flutter环境变量
3. 运行 `flutter doctor` 检查环境配置

### 安装依赖

```bash
flutter pub get
```

### 连接设备

连接Android或iOS设备，或启动模拟器。

### 运行应用

```bash
flutter run
```

## 项目结构

```
lib/
├── models/           # 数据模型
├── screens/          # 页面组件
├── services/         # 服务层（API调用等）
├── widgets/          # 自定义组件
└── utils/            # 工具函数
```

## 可执行成果

### 当前版本
目前项目处于开发阶段，尚未发布正式版本。用户可以通过以下方式获取和运行前端应用：

1. 克隆项目源代码:
   ```
   git clone [项目地址]
   ```

2. 进入前端目录:
   ```
   cd talk_to_ai_fullstack/frontend
   ```

3. 按照上述"快速开始"指南进行本地部署

### 未来发布计划
我们计划在项目稳定后发布以下可执行成果：

1. **Android APK安装包** - 可直接在Android设备上安装使用的移动应用
2. **iOS应用** - 可通过App Store下载的iOS应用
3. **Web应用** - 可通过浏览器访问的在线版本
4. **Windows桌面应用** - 可在Windows系统上直接运行的桌面版本
5. **macOS应用** - 可在macOS系统上直接运行的桌面版本

所有可执行文件将在项目的[Release区域](https://github.com/your-username/talk-to-ai/releases)发布。

## 访问方式

### 开发环境访问
在开发环境中，应用通过Flutter开发服务器运行，可直接在连接的设备或模拟器上使用。

### 生产环境访问
部署后可通过以下方式访问:
1. Android应用: 通过Google Play或APK安装包安装
2. iOS应用: 通过App Store下载
3. Web应用: 通过浏览器访问指定网址
4. 桌面应用: 下载对应平台的可执行文件运行

## 开发指南

### 添加新页面

1. 在`screens/`目录下创建新的页面文件
2. 在需要的地方导入并使用新页面

### 添加新组件

1. 在`widgets/`目录下创建新的组件文件
2. 实现组件功能
3. 在页面中使用组件

### API调用

API调用在`services/`目录中实现，通过`ApiService`类提供统一接口。

## 构建和发布

### Android

```bash
flutter build apk
```

### iOS

```bash
flutter build ios
```

### Web

```bash
flutter build web
```

### Windows桌面

```bash
flutter build windows
```

### macOS

```bash
flutter build macos
```

## 配置说明

### 后端API地址

在`lib/services/api_service.dart`中配置后端API地址：

```dart
static const String baseUrl = 'http://localhost:8000/api/v1';
```

请根据实际部署情况修改此地址。

## 测试

运行单元测试：

```bash
flutter test
```

## 许可证

本项目仅供学习和研究使用。

## 联系方式

如有问题，请提交Issue或联系项目维护者。