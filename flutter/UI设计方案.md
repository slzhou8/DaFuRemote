# RustDesk UI 重新设计方案

## 现有 UI 分析

### 技术栈
- **框架**: Flutter (Dart)
- **状态管理**: GetX + Provider
- **UI 组件**: Material Design
- **主题系统**: 自定义 MyTheme (支持亮色/暗色模式)

### 现有 UI 结构
```
lib/
├── common/          # 共享组件
│   └── widgets/     # 通用 UI 组件
├── desktop/         # 桌面端 UI
│   ├── pages/       # 页面组件
│   ├── screen/      # 屏幕相关
│   └── widgets/     # 桌面端专用组件
├── mobile/          # 移动端 UI
│   ├── pages/       # 页面组件
│   └── widgets/     # 移动端专用组件
└── models/          # 数据模型
```

### 现有 UI 问题
1. 界面风格较为传统，缺乏现代感
2. 色彩搭配单一，主要以蓝色为主
3. 组件样式不够统一
4. 缺少动画和过渡效果
5. 信息层级不够清晰

---

## 方案一：现代简约风格 (Modern Minimalist)

### 设计理念
- **关键词**: 简洁、清爽、高效
- **灵感来源**: Apple Design、Google Material You
- **适用场景**: 商务办公、日常远程协助

### 色彩方案

#### 亮色模式
```dart
// 主色调 - 柔和蓝紫渐变
static const Color primaryLight = Color(0xFF6366F1);    // 主色
static const Color primaryLightVariant = Color(0xFF818CF8); // 变体
static const Color secondaryLight = Color(0xFF06B6D4);  // 辅助色

// 背景色
static const Color backgroundLight = Color(0xFFF8FAFC); // 主背景
static const Color surfaceLight = Color(0xFFFFFFFF);    // 卡片背景
static const Color surfaceVariantLight = Color(0xFFF1F5F9); // 变体背景

// 文字颜色
static const Color textPrimaryLight = Color(0xFF0F172A);
static const Color textSecondaryLight = Color(0xFF475569);
static const Color textTertiaryLight = Color(0xFF94A3B8);

// 状态色
static const Color successLight = Color(0xFF10B981);
static const Color warningLight = Color(0xFFF59E0B);
static const Color errorLight = Color(0xFFEF4444);
static const Color infoLight = Color(0xFF3B82F6);

// 边框
static const Color borderLight = Color(0xFFE2E8F0);
```

#### 暗色模式
```dart
// 主色调
static const Color primaryDark = Color(0xFF818CF8);
static const Color primaryDarkVariant = Color(0xFF6366F1);
static const Color secondaryDark = Color(0xFF22D3EE);

// 背景色
static const Color backgroundDark = Color(0xFF0F172A);
static const Color surfaceDark = Color(0xFF1E293B);
static const Color surfaceVariantDark = Color(0xFF334155);

// 文字颜色
static const Color textPrimaryDark = Color(0xFFF8FAFC);
static const Color textSecondaryDark = Color(0xFFCBD5E1);
static const Color textTertiaryDark = Color(0xFF64748B);

// 状态色
static const Color successDark = Color(0xFF34D399);
static const Color warningDark = Color(0xFFFBBF24);
static const Color errorDark = Color(0xFFF87171);
static const Color infoDark = Color(0xFF60A5FA);

// 边框
static const Color borderDark = Color(0xFF334155);
```

### 组件设计

#### 1. 主窗口布局
```
┌─────────────────────────────────────────────────────────┐
│  [Logo]  RustDesk                    [最小化][最大化][×] │  ← 标题栏 (60px)
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────────┐  ┌───────────────────────────────┐ │
│  │                 │  │                               │ │
│  │   侧边导航栏     │  │         主内容区域             │ │
│  │   (240px)       │  │                               │ │
│  │                 │  │                               │ │
│  │  • 我的设备     │  │   ┌─────────────────────┐     │ │
│  │  • 地址簿       │  │   │  搜索栏              │     │ │
│  │  • 会话记录     │  │   └─────────────────────┘     │ │
│  │  • 文件传输     │  │                               │ │
│  │  • 设置         │  │   ┌─────┐ ┌─────┐ ┌─────┐    │ │
│  │                 │  │   │设备1│ │设备2│ │设备3│    │ │
│  │                 │  │   └─────┘ └─────┘ └─────┘    │ │
│  │                 │  │                               │ │
│  └─────────────────┘  └───────────────────────────────┘ │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

#### 2. 设备卡片组件
```dart
// 现代简约风格设备卡片
class ModernDeviceCard extends StatelessWidget {
  final String deviceName;
  final String deviceId;
  final String status; // online/offline/busy
  final String? platform;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).extension<ColorThemeExtension>()!.border!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 状态指示器 + 平台图标
                Row(
                  children: [
                    _StatusIndicator(status: status),
                    SizedBox(width: 8),
                    _PlatformIcon(platform: platform),
                    Spacer(),
                    _MoreButton(),
                  ],
                ),
                SizedBox(height: 12),
                // 设备名称
                Text(
                  deviceName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                // 设备ID
                Text(
                  deviceId,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

#### 3. 连接按钮组件
```dart
// 渐变连接按钮
class GradientConnectButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isPrimary 
            ? LinearGradient(
                colors: [
                  MyTheme.primaryLight,
                  MyTheme.primaryLightVariant,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(12),
        border: isPrimary 
            ? null 
            : Border.all(color: MyTheme.borderLight),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: isPrimary ? Colors.white : null),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? Colors.white : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### 动画效果
```dart
// 页面切换动画
class ModernPageTransition extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0.0, 0.05),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

// 卡片悬停动画
class HoverCardEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  
  @override
  _HoverCardEffectState createState() => _HoverCardEffectState();
}

class _HoverCardEffectState extends State<HoverCardEffect> 
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _isHovered = true;
        _controller.forward();
      },
      onExit: (_) {
        _isHovered = false;
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      _isHovered ? 0.08 : 0.04,
                    ),
                    blurRadius: _isHovered ? 20 : 12,
                    offset: Offset(0, _isHovered ? 8 : 4),
                  ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
```

---

## 方案二：科技暗黑风格 (Tech Dark)

### 设计理念
- **关键词**: 科技感、未来感、沉浸
- **灵感来源**: Cyberpunk、科幻界面、游戏 UI
- **适用场景**: 技术极客、游戏玩家、专业用户

### 色彩方案

#### 主色调
```dart
// 霓虹色系
static const Color neonBlue = Color(0xFF00F0FF);      // 霓虹蓝
static const Color neonPurple = Color(0xFFB026FF);    // 霓虹紫
static const Color neonPink = Color(0xFFFF006E);      // 霓虹粉
static const Color neonGreen = Color(0xFF39FF14);     // 霓虹绿

// 背景色 - 深空黑
static const Color bgPrimary = Color(0xFF0A0A0F);     // 主背景
static const Color bgSecondary = Color(0xFF12121A);   // 次级背景
static const Color bgTertiary = Color(0xFF1A1A25);    // 第三级背景
static const Color bgCard = Color(0xFF16161F);        // 卡片背景

// 文字颜色
static const Color textPrimary = Color(0xFFEAEAEA);
static const Color textSecondary = Color(0xFFA0A0B0);
static const Color textTertiary = Color(0xFF606070);

// 发光效果色
static const Color glowBlue = Color(0x4000F0FF);
static const Color glowPurple = Color(0x40B026FF);
```

### 组件设计

#### 1. 发光边框卡片
```dart
class GlowBorderCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double glowIntensity;
  
  const GlowBorderCard({
    required this.child,
    this.glowColor = neonBlue,
    this.glowIntensity = 0.5,
  });
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GlowBorderPainter(
        color: glowColor,
        intensity: glowIntensity,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class GlowBorderPainter extends CustomPainter {
  final Color color;
  final double intensity;
  final BorderRadius borderRadius;
  
  GlowBorderPainter({
    required this.color,
    required this.intensity,
    required this.borderRadius,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);
    
    // 外层发光
    final paint1 = Paint()
      ..color = color.withOpacity(intensity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawRRect(rrect, paint1);
    
    // 内层边框
    final paint2 = Paint()
      ..color = color.withOpacity(intensity * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect.deflate(4), paint2);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

#### 2. 扫描线动画效果
```dart
class ScanLineEffect extends StatefulWidget {
  final Widget child;
  
  const ScanLineEffect({required this.child});
  
  @override
  _ScanLineEffectState createState() => _ScanLineEffectState();
}

class _ScanLineEffectState extends State<ScanLineEffect> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Positioned(
              top: _animation.value * MediaQuery.of(context).size.height,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      neonBlue.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

#### 3. 终端风格连接面板
```dart
class TerminalConnectPanel extends StatelessWidget {
  final TextEditingController idController;
  final TextEditingController passwordController;
  final VoidCallback onConnect;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgSecondary,
        border: Border.all(color: neonBlue.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 终端标题
          Row(
            children: [
              Icon(Icons.terminal, color: neonBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'REMOTE_CONNECTION',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 14,
                  color: neonBlue,
                  letterSpacing: 2,
                ),
              ),
              Spacer(),
              _BlinkingCursor(),
            ],
          ),
          Divider(color: neonBlue.withOpacity(0.2), height: 24),
          SizedBox(height: 16),
          
          // ID 输入
          _TerminalInput(
            label: 'TARGET_ID',
            controller: idController,
            icon: Icons.devices,
          ),
          SizedBox(height: 12),
          
          // 密码输入
          _TerminalInput(
            label: 'AUTH_KEY',
            controller: passwordController,
            icon: Icons.lock,
            isPassword: true,
          ),
          SizedBox(height: 20),
          
          // 连接按钮
          SizedBox(
            width: double.infinity,
            child: _NeonButton(
              label: 'INITIATE_CONNECTION',
              onPressed: onConnect,
              color: neonBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  @override
  __BlinkingCursorState createState() => __BlinkingCursorState();
}

class __BlinkingCursorState extends State<_BlinkingCursor> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Text('█', style: TextStyle(color: neonBlue, fontSize: 14)),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## 方案三：商务专业风格 (Business Professional)

### 设计理念
- **关键词**: 专业、稳重、高效
- **灵感来源**: Microsoft Fluent Design、企业级 SaaS 产品
- **适用场景**: 企业办公、IT 运维、技术支持

### 色彩方案

#### 亮色模式
```dart
// 主色调 - 深蓝商务色
static const Color primaryBusiness = Color(0xFF1E40AF);    // 商务蓝
static const Color primaryBusinessLight = Color(0xFF3B82F6);
static const Color primaryBusinessDark = Color(0xFF1E3A8A);

// 辅助色
static const Color accentBusiness = Color(0xFF059669);     // 成功绿
static const Color accentWarning = Color(0xFFD97706);      // 警告橙
static const Color accentDanger = Color(0xFFDC2626);       // 危险红

// 中性色
static const Color neutral50 = Color(0xFFF9FAFB);
static const Color neutral100 = Color(0xFFF3F4F6);
static const Color neutral200 = Color(0xFFE5E7EB);
static const Color neutral300 = Color(0xFFD1D5DB);
static const Color neutral400 = Color(0xFF9CA3AF);
static const Color neutral500 = Color(0xFF6B7280);
static const Color neutral600 = Color(0xFF4B5563);
static const Color neutral700 = Color(0xFF374151);
static const Color neutral800 = Color(0xFF1F2937);
static const Color neutral900 = Color(0xFF111827);

// 背景色
static const Color bgBusinessPrimary = Color(0xFFFFFFFF);
static const Color bgBusinessSecondary = Color(0xFFF9FAFB);
static const Color bgBusinessTertiary = Color(0xFFF3F4F6);

// 文字颜色
static const Color textBusinessPrimary = Color(0xFF111827);
static const Color textBusinessSecondary = Color(0xFF4B5563);
static const Color textBusinessTertiary = Color(0xFF9CA3AF);
```

### 组件设计

#### 1. 专业导航栏
```dart
class BusinessNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgBusinessPrimary,
        border: Border(
          bottom: BorderSide(color: neutral200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              // Logo + 品牌名
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryBusiness, primaryBusinessLight],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.desktop_windows, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'RustDesk',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textBusinessPrimary,
                    ),
                  ),
                ],
              ),
              Spacer(),
              
              // 导航项
              _NavItem(label: '设备', icon: Icons.devices, isActive: true),
              _NavItem(label: '会话', icon: Icons.history),
              _NavItem(label: '文件', icon: Icons.folder),
              _NavItem(label: '设置', icon: Icons.settings),
              
              SizedBox(width: 24),
              
              // 用户头像
              _UserAvatar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  
  const _NavItem({
    required this.label,
    required this.icon,
    this.isActive = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? primaryBusiness.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive ? primaryBusiness : textBusinessSecondary,
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? primaryBusiness : textBusinessSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 2. 数据表格风格设备列表
```dart
class BusinessDeviceTable extends StatelessWidget {
  final List<Device> devices;
  final Function(Device) onConnect;
  final Function(Device) onMore;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgBusinessPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: neutral200),
      ),
      child: Column(
        children: [
          // 表头
          _TableHeader(),
          Divider(height: 1, color: neutral200),
          
          // 数据行
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return _DeviceTableRow(
                  device: devices[index],
                  onConnect: () => onConnect(devices[index]),
                  onMore: () => onMore(devices[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: neutral50,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          SizedBox(width: 40), // 复选框
          Expanded(flex: 2, child: _HeaderCell('设备名称')),
          Expanded(flex: 1, child: _HeaderCell('状态')),
          Expanded(flex: 1, child: _HeaderCell('平台')),
          Expanded(flex: 2, child: _HeaderCell('ID')),
          Expanded(flex: 1, child: _HeaderCell('最后在线')),
          SizedBox(width: 80), // 操作按钮
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  
  const _HeaderCell(this.label);
  
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textBusinessSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _DeviceTableRow extends StatelessWidget {
  final Device device;
  final VoidCallback onConnect;
  final VoidCallback onMore;
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onConnect,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: neutral100, width: 1),
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: 40),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  _StatusDot(status: device.status),
                  SizedBox(width: 12),
                  Text(
                    device.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textBusinessPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(flex: 1, child: _StatusBadge(device.status)),
            Expanded(flex: 1, child: _PlatformBadge(device.platform)),
            Expanded(
              flex: 2,
              child: Text(
                device.id,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'JetBrainsMono',
                  color: textBusinessSecondary,
                ),
              ),
            ),
            Expanded(flex: 1, child: _LastSeenText(device.lastSeen)),
            SizedBox(width: 80),
            _RowActions(onConnect: onConnect, onMore: onMore),
          ],
        ),
      ),
    );
  }
}
```

#### 3. 快速连接面板
```dart
class QuickConnectPanel extends StatelessWidget {
  final TextEditingController idController;
  final VoidCallback onConnect;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBusiness, primaryBusinessDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '快速连接',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '输入远程设备 ID 即可建立连接',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 20),
          
          // 输入框
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: idController,
              decoration: InputDecoration(
                hintText: '输入设备 ID...',
                hintStyle: TextStyle(color: neutral400),
                prefixIcon: Icon(Icons.search, color: primaryBusiness),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: TextStyle(fontSize: 15),
            ),
          ),
          SizedBox(height: 16),
          
          // 连接按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConnect,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryBusiness,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '立即连接',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 主题切换实现

### 主题管理器
```dart
class ThemeManager extends GetxController {
  static ThemeManager get instance => Get.find();
  
  final _currentTheme = Rx<ThemeStyle>(ThemeStyle.modern);
  ThemeStyle get currentTheme => _currentTheme.value;
  
  final _isDarkMode = Rx<bool>(false);
  bool get isDarkMode => _isDarkMode.value;
  
  void setTheme(ThemeStyle style) {
    _currentTheme.value = style;
    Get.changeTheme(_buildThemeData(style, _isDarkMode.value));
    update();
  }
  
  void toggleDarkMode(bool isDark) {
    _isDarkMode.value = isDark;
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
    update();
  }
  
  ThemeData _buildThemeData(ThemeStyle style, bool isDark) {
    switch (style) {
      case ThemeStyle.modern:
        return isDark ? ModernTheme.darkTheme : ModernTheme.lightTheme;
      case ThemeStyle.tech:
        return TechTheme.darkTheme; // 科技风格默认暗色
      case ThemeStyle.business:
        return isDark ? BusinessTheme.darkTheme : BusinessTheme.lightTheme;
    }
  }
}

enum ThemeStyle {
  modern,    // 现代简约
  tech,      // 科技暗黑
  business,  // 商务专业
}
```

### 主题设置页面
```dart
class ThemeSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeManager>(
      builder: (manager) {
        return Scaffold(
          appBar: AppBar(title: Text('主题设置')),
          body: ListView(
            padding: EdgeInsets.all(20),
            children: [
              _ThemeOptionCard(
                title: '现代简约',
                description: '清爽简洁，适合日常使用',
                previewColors: [Color(0xFF6366F1), Color(0xFFF8FAFC)],
                isSelected: manager.currentTheme == ThemeStyle.modern,
                onTap: () => manager.setTheme(ThemeStyle.modern),
              ),
              SizedBox(height: 16),
              _ThemeOptionCard(
                title: '科技暗黑',
                description: '未来感十足，极客首选',
                previewColors: [Color(0xFF00F0FF), Color(0xFF0A0A0F)],
                isSelected: manager.currentTheme == ThemeStyle.tech,
                onTap: () => manager.setTheme(ThemeStyle.tech),
              ),
              SizedBox(height: 16),
              _ThemeOptionCard(
                title: '商务专业',
                description: '稳重高效，企业办公首选',
                previewColors: [Color(0xFF1E40AF), Color(0xFFFFFFFF)],
                isSelected: manager.currentTheme == ThemeStyle.business,
                onTap: () => manager.setTheme(ThemeStyle.business),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final List<Color> previewColors;
  final bool isSelected;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? MyTheme.primaryLight.withOpacity(0.08) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? MyTheme.primaryLight : MyTheme.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // 颜色预览
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: previewColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            SizedBox(width: 16),
            // 文字信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            // 选中指示器
            if (isSelected)
              Icon(Icons.check_circle, color: MyTheme.primaryLight, size: 24),
          ],
        ),
      ),
    );
  }
}
```

---

## 实施建议

### 第一阶段：基础架构
1. 创建主题配置文件结构
2. 实现主题切换机制
3. 定义通用组件库

### 第二阶段：核心页面
1. 重新设计主窗口布局
2. 实现设备列表组件
3. 实现连接面板组件

### 第三阶段：细节优化
1. 添加动画和过渡效果
2. 优化响应式布局
3. 完善暗色模式适配

### 第四阶段：测试发布
1. 多平台测试
2. 性能优化
3. 用户反馈收集

---

## 文件结构建议

```
lib/
├── themes/                    # 新增：主题管理
│   ├── theme_manager.dart
│   ├── modern_theme.dart
│   ├── tech_theme.dart
│   └── business_theme.dart
├── components/                # 新增：通用组件库
│   ├── buttons/
│   │   ├── gradient_button.dart
│   │   ├── neon_button.dart
│   │   └── business_button.dart
│   ├── cards/
│   │   ├── device_card.dart
│   │   ├── glow_card.dart
│   │   └── business_card.dart
│   ├── inputs/
│   │   ├── modern_input.dart
│   │   ├── terminal_input.dart
│   │   └── business_input.dart
│   └── navigation/
│       ├── modern_nav.dart
│       ├── tech_nav.dart
│       └── business_nav.dart
├── common/
│   └── widgets/              # 保留：原有共享组件
├── desktop/
│   ├── pages/
│   │   ├── modern_home_page.dart
│   │   ├── tech_home_page.dart
│   │   └── business_home_page.dart
│   └── widgets/
└── mobile/
    ├── pages/
    └── widgets/
```

---

## 总结

| 特性 | 现代简约 | 科技暗黑 | 商务专业 |
|------|---------|---------|---------|
| 适用人群 | 普通用户 | 技术极客 | 企业用户 |
| 主色调 | 蓝紫渐变 | 霓虹色系 | 深蓝商务色 |
| 背景风格 | 浅灰/纯白 | 深空黑 | 白色/浅灰 |
| 组件风格 | 圆角卡片 | 发光边框 | 数据表格 |
| 动画效果 | 柔和过渡 | 扫描线/闪烁 | 简洁微动 |
| 字体选择 | 系统默认 | 等宽字体 | 商务字体 |

建议先实现**现代简约风格**作为默认主题，因为它：
1. 符合当前设计趋势
2. 用户接受度高
3. 实现复杂度适中
4. 易于扩展其他风格
