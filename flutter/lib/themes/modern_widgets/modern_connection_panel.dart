import 'package:flutter/material.dart';
import '../modern_theme.dart';

/// 现代简约风格的连接面板组件
class ModernConnectionPanel extends StatelessWidget {
  final TextEditingController? idController;
  final TextEditingController? passwordController;
  final VoidCallback? onConnect;
  final VoidCallback? onFileTransfer;
  final VoidCallback? onViewCamera;
  final VoidCallback? onTerminal;
  final String? myId;
  final String? myAlias;

  const ModernConnectionPanel({
    Key? key,
    this.idController,
    this.passwordController,
    this.onConnect,
    this.onFileTransfer,
    this.onViewCamera,
    this.onTerminal,
    this.myId,
    this.myAlias,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? ModernColors.dark : ModernColors.light;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            '快速连接',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 我的ID显示
          _buildMyIdSection(context, colors),
          
          const SizedBox(height: 24),
          
          // 分割线
          Divider(color: colors.border, thickness: 1),
          
          const SizedBox(height: 24),
          
          // 远程ID输入
          _buildRemoteIdInput(context, colors),
          
          const SizedBox(height: 16),
          
          // 密码输入
          _buildPasswordInput(context, colors),
          
          const SizedBox(height: 24),
          
          // 连接按钮
          _buildConnectButton(context, colors),
          
          const SizedBox(height: 20),
          
          // 快捷操作
          _buildQuickActions(context, colors),
        ],
      ),
    );
  }

  Widget _buildMyIdSection(BuildContext context, ModernColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.devices_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '我的设备ID',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  myId ?? '未获取',
                  style: TextStyle(
                    fontSize: 18,
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          // 复制按钮
          InkWell(
            onTap: () {
              // 复制ID到剪贴板
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.copy_rounded,
                color: colors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoteIdInput(BuildContext context, ModernColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '远程设备ID',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: idController,
            decoration: InputDecoration(
              hintText: '输入远程设备ID',
              hintStyle: TextStyle(color: colors.textTertiary),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: colors.textTertiary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: TextStyle(
              fontSize: 15,
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordInput(BuildContext context, ModernColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '密码',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: '输入连接密码',
              hintStyle: TextStyle(color: colors.textTertiary),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: colors.textTertiary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: TextStyle(
              fontSize: 15,
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectButton(BuildContext context, ModernColors colors) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onConnect,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cast_connected_rounded,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              '连接',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ModernColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快捷操作',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildQuickActionCard(
              context,
              colors,
              icon: Icons.folder_open_rounded,
              label: '文件传输',
              onTap: onFileTransfer,
            ),
            const SizedBox(width: 12),
            _buildQuickActionCard(
              context,
              colors,
              icon: Icons.videocam_rounded,
              label: '查看摄像头',
              onTap: onViewCamera,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildQuickActionCard(
              context,
              colors,
              icon: Icons.terminal_rounded,
              label: '终端',
              onTap: onTerminal,
            ),
            const SizedBox(width: 12),
            _buildQuickActionCard(
              context,
              colors,
              icon: Icons.settings_rounded,
              label: '设置',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    ModernColors colors, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colors.border,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: colors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 现代简约风格的连接状态指示器
class ModernConnectionStatus extends StatelessWidget {
  final bool isConnected;
  final String statusText;
  final String? connectionType;

  const ModernConnectionStatus({
    Key? key,
    this.isConnected = false,
    this.statusText = '未连接',
    this.connectionType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? ModernColors.dark : ModernColors.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isConnected 
            ? colors.success.withOpacity(0.1) 
            : colors.textTertiary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isConnected ? colors.success : colors.textTertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isConnected ? colors.success : colors.textTertiary,
            ),
          ),
          if (connectionType != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                connectionType!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
