import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../modern_theme.dart';

/// 现代简约风格的设备卡片组件
class ModernPeerCard extends StatelessWidget {
  final String peerId;
  final String alias;
  final String hostname;
  final String platform;
  final bool isOnline;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onMoreOptions;

  const ModernPeerCard({
    Key? key,
    required this.peerId,
    this.alias = '',
    this.hostname = '',
    this.platform = '',
    this.isOnline = false,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteToggle,
    this.onMoreOptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? ModernColors.dark : ModernColors.light;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 平台图标
                _buildPlatformIcon(context, colors),
                
                const SizedBox(width: 14),
                
                // 设备信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 设备名称行
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              alias.isNotEmpty ? alias : peerId,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // 在线状态指示器
                          _buildStatusIndicator(context, colors),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // 主机名和设备ID
                      Row(
                        children: [
                          if (hostname.isNotEmpty)
                            Text(
                              hostname,
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.textSecondary,
                              ),
                            ),
                          if (hostname.isNotEmpty)
                            const SizedBox(width: 8),
                          Text(
                            peerId,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // 操作按钮
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 收藏按钮
                    InkWell(
                      onTap: onFavoriteToggle,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                          color: isFavorite ? colors.warning : colors.textTertiary,
                          size: 22,
                        ),
                      ),
                    ),
                    
                    // 更多选项按钮
                    InkWell(
                      onTap: onMoreOptions,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.more_horiz_rounded,
                          color: colors.textTertiary,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformIcon(BuildContext context, ModernColors colors) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: _getPlatformIcon(platform),
      ),
    );
  }

  Widget _getPlatformIcon(String platform) {
    IconData iconData;
    switch (platform.toLowerCase()) {
      case 'windows':
      case 'win':
        iconData = Icons.desktop_windows_rounded;
        break;
      case 'macos':
      case 'mac':
        iconData = Icons.laptop_mac_rounded;
        break;
      case 'linux':
        iconData = Icons.computer_rounded;
        break;
      case 'android':
        iconData = Icons.phone_android_rounded;
        break;
      case 'ios':
        iconData = Icons.phone_iphone_rounded;
        break;
      default:
        iconData = Icons.devices_rounded;
    }
    return Icon(
      iconData,
      size: 26,
      color: ModernTheme.primaryLight,
    );
  }

  Widget _buildStatusIndicator(BuildContext context, ModernColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOnline 
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
              color: isOnline ? colors.success : colors.textTertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? '在线' : '离线',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isOnline ? colors.success : colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 现代简约风格的搜索框组件
class ModernSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final String hintText;

  const ModernSearchBar({
    Key? key,
    this.controller,
    this.onChanged,
    this.onFilterTap,
    this.hintText = '搜索设备...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? ModernColors.dark : ModernColors.light;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: colors.textTertiary),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colors.textTertiary,
          ),
          suffixIcon: onFilterTap != null
              ? IconButton(
                  icon: Icon(
                    Icons.tune_rounded,
                    color: colors.textSecondary,
                  ),
                  onPressed: onFilterTap,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: TextStyle(
          fontSize: 15,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}

/// 现代简约风格的分组标题组件
class ModernSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isExpanded;
  final VoidCallback? onTap;

  const ModernSectionHeader({
    Key? key,
    required this.title,
    this.count = 0,
    this.isExpanded = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? ModernColors.dark : ModernColors.light;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              isExpanded 
                  ? Icons.keyboard_arrow_down_rounded 
                  : Icons.keyboard_arrow_right_rounded,
              color: colors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
