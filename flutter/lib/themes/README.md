# RustDesk 现代简约风格 UI 组件库

## 概述

本项目为 RustDesk Flutter 客户端提供了一套现代简约风格的 UI 主题和组件，采用 Material Design 3 设计规范，支持亮色和暗色模式。

## 设计理念

- **简洁清爽**：使用柔和的蓝紫渐变配色，减少视觉干扰
- **高效交互**：清晰的层级结构和直观的组件设计
- **圆角卡片**：统一的圆角设计，提升视觉舒适度
- **响应式**：适配不同屏幕尺寸

## 文件结构

```
lib/themes/
├── modern_theme.dart          # 主题定义（亮色/暗色模式）
├── theme_manager.dart         # 主题管理器（主题切换、偏好设置）
├── modern_widgets/
│   ├── index.dart             # 组件导出文件
│   ├── modern_peer_card.dart  # 设备卡片组件
│   └── modern_connection_panel.dart  # 连接面板组件
└── README.md                  # 使用文档
```

## 快速开始

### 1. 初始化主题管理器

在 `main.dart` 的 `main()` 函数中初始化主题管理器：

```dart
import 'package:flutter_hbb/themes/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 注册主题管理器
  Get.put(ThemeManager());
  
  runApp(App());
}
```

### 2. 应用主题

在 `GetMaterialApp` 中使用主题：

```dart
import 'package:flutter_hbb/themes/theme_manager.dart';

GetMaterialApp(
  theme: ThemeManager.instance.getLightThemeData(),
  darkTheme: ThemeManager.instance.getDarkThemeData(),
  themeMode: ThemeManager.instance.isDarkMode ? ThemeMode.dark : ThemeMode.light,
  // ...
)
```

### 3. 使用组件

#### 设备卡片

```dart
import 'package:flutter_hbb/themes/modern_widgets/index.dart';

ModernPeerCard(
  peerId: '123456789',
  alias: '我的电脑',
  hostname: 'DESKTOP-ABC123',
  platform: 'Windows',
  isOnline: true,
  isFavorite: false,
  onTap: () {
    // 点击事件
  },
  onFavoriteToggle: () {
    // 收藏切换
  },
  onMoreOptions: () {
    // 更多选项
  },
)
```

#### 搜索框

```dart
ModernSearchBar(
  controller: searchController,
  onChanged: (value) {
    // 搜索回调
  },
  onFilterTap: () {
    // 筛选按钮点击
  },
)
```

#### 分组标题

```dart
ModernSectionHeader(
  title: '我的设备',
  count: 5,
  isExpanded: true,
  onTap: () {
    // 展开/折叠
  },
)
```

#### 连接面板

```dart
ModernConnectionPanel(
  idController: idController,
  passwordController: passwordController,
  myId: '987654321',
  onConnect: () {
    // 连接按钮点击
  },
  onFileTransfer: () {
    // 文件传输
  },
  onViewCamera: () {
    // 查看摄像头
  },
  onTerminal: () {
    // 终端
  },
)
```

#### 连接状态指示器

```dart
ModernConnectionStatus(
  isConnected: true,
  statusText: '已连接',
  connectionType: 'TCP',
)
```

## 主题颜色

### 亮色模式

| 颜色名称 | 色值 | 用途 |
|---------|------|------|
| Primary | `#6366F1` | 主色调 |
| Primary Variant | `#818CF8` | 主色调变体 |
| Secondary | `#06B6D4` | 辅助色 |
| Background | `#F8FAFC` | 背景色 |
| Surface | `#FFFFFF` | 表面色 |
| Text Primary | `#0F172A` | 主要文字 |
| Text Secondary | `#475569` | 次要文字 |
| Success | `#10B981` | 成功状态 |
| Warning | `#F59E0B` | 警告状态 |
| Error | `#EF4444` | 错误状态 |

### 暗色模式

| 颜色名称 | 色值 | 用途 |
|---------|------|------|
| Primary | `#818CF8` | 主色调 |
| Primary Variant | `#6366F1` | 主色调变体 |
| Secondary | `#22D3EE` | 辅助色 |
| Background | `#0F172A` | 背景色 |
| Surface | `#1E293B` | 表面色 |
| Text Primary | `#F8FAFC` | 主要文字 |
| Text Secondary | `#CBD5E1` | 次要文字 |
| Success | `#34D399` | 成功状态 |
| Warning | `#FBBF24` | 警告状态 |
| Error | `#F87171` | 错误状态 |

## 主题切换

```dart
// 切换暗色模式
ThemeManager.instance.toggleDarkMode(true);

// 设置主题风格（未来可扩展）
ThemeManager.instance.setTheme(ThemeStyle.modern);
```

## 使用 ModernColors

在组件中获取当前主题颜色：

```dart
@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final colors = isDark ? ModernColors.dark : ModernColors.light;
  
  return Container(
    color: colors.primary,
    // ...
  );
}
```

或者使用扩展方法：

```dart
@override
Widget build(BuildContext context) {
  final colors = context.modernColors;
  
  return Container(
    color: colors.primary,
    // ...
  );
}
```

## 自定义主题

如需自定义主题颜色，可以修改 `modern_theme.dart` 中的颜色常量：

```dart
class ModernTheme {
  // 亮色模式
  static const Color primaryLight = Color(0xFF6366F1);
  
  // 暗色模式
  static const Color primaryDark = Color(0xFF818CF8);
  
  // ...
}
```

## 注意事项

1. **Material 3**：主题使用 `useMaterial3: true`，确保 Flutter 版本支持
2. **圆角统一**：卡片圆角 16px，按钮圆角 12px，输入框圆角 12px
3. **阴影层级**：使用低透明度阴影（0.05），保持界面清爽
4. **文字层级**：Primary（主要）、Secondary（次要）、Tertiary（辅助）

## 后续计划

- [ ] 添加更多组件（设置页面、对话框等）
- [ ] 支持主题风格切换（科技暗黑、商务专业）
- [ ] 添加动画效果
- [ ] 优化移动端适配
