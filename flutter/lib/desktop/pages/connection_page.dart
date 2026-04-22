// main window right pane

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hbb/common/widgets/connection_page_title.dart';
import 'package:flutter_hbb/common/widgets/login.dart';
import 'package:flutter_hbb/common/widgets/peer_card.dart';
import 'package:flutter_hbb/common/widgets/peers_view.dart';
import 'package:flutter_hbb/consts.dart';
import 'package:flutter_hbb/desktop/pages/desktop_setting_page.dart';
import 'package:flutter_hbb/desktop/pages/desktop_tab_page.dart';
import 'package:flutter_hbb/desktop/widgets/popup_menu.dart';
import 'package:flutter_hbb/models/ab_model.dart';
import 'package:flutter_hbb/models/peer_tab_model.dart';
import 'package:flutter_hbb/models/state_model.dart';
import 'package:flutter_hbb/themes/theme_manager.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_hbb/models/peer_model.dart';

import '../../common.dart';
import '../../common/formatter/id_formatter.dart';
import '../../common/widgets/autocomplete.dart';
import '../../models/platform_model.dart';
import '../../desktop/widgets/material_mod_popup_menu.dart' as mod_menu;

enum _DesktopSidebarSection {
  devices,
  connectionHistory,
  addressBook,
  fileTransfer,
}

enum _QuickConnectMode {
  connect,
  fileTransfer,
}

class OnlineStatusWidget extends StatefulWidget {
  const OnlineStatusWidget({Key? key, this.onSvcStatusChanged})
      : super(key: key);

  final VoidCallback? onSvcStatusChanged;

  @override
  State<OnlineStatusWidget> createState() => _OnlineStatusWidgetState();
}

/// State for the connection page.
class _OnlineStatusWidgetState extends State<OnlineStatusWidget> {
  final _svcStopped = Get.find<RxBool>(tag: 'stop-service');
  final _svcIsUsingPublicServer = true.obs;
  Timer? _updateTimer;

  double get em => 14.0;
  double? get height => bind.isIncomingOnly() ? null : em * 3;

  void onUsePublicServerGuide() {
    const url = "https://rustdesk.com/pricing";
    canLaunchUrlString(url).then((can) {
      if (can) {
        launchUrlString(url);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _updateTimer = periodic_immediate(Duration(seconds: 1), () async {
      updateStatus();
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIncomingOnly = bind.isIncomingOnly();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? ModernColors.dark : ModernColors.light;

    startServiceWidget() => Offstage(
          offstage: !_svcStopped.value,
          child: InkWell(
            onTap: () async {
              await start_service(true);
            },
            child: Text(
              translate("Start service"),
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontSize: em,
                color: colors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ).marginOnly(left: em),
        );

    setupServerWidget() => Flexible(
          child: Offstage(
            offstage: !(!_svcStopped.value &&
                stateGlobal.svcStatus.value == SvcStatus.ready &&
                _svcIsUsingPublicServer.value),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(', ', style: TextStyle(fontSize: em)),
                Flexible(
                  child: InkWell(
                    onTap: onUsePublicServerGuide,
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            translate('setup_server_tip'),
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: em,
                              color: colors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

    basicWidget() => Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _svcStopped.value ||
                        stateGlobal.svcStatus.value == SvcStatus.connecting
                    ? colors.warning
                    : (stateGlobal.svcStatus.value == SvcStatus.ready
                        ? colors.success
                        : colors.error),
              ),
            ).marginSymmetric(horizontal: em),
            Container(
              width: isIncomingOnly ? 226 : null,
              child: _buildConnStatusMsg(context, colors),
            ),
            // stop
            if (!isIncomingOnly) startServiceWidget(),
            // ready && public
            // No need to show the guide if is custom client.
            if (!isIncomingOnly) setupServerWidget(),
          ],
        );

    return Container(
      height: height,
      child: Obx(
        () => isIncomingOnly
            ? Column(
                children: [
                  basicWidget(),
                  Align(
                    child: startServiceWidget(),
                    alignment: Alignment.centerLeft,
                  ).marginOnly(top: 2.0, left: 22.0),
                ],
              )
            : basicWidget(),
      ),
    ).paddingOnly(right: isIncomingOnly ? 8 : 0);
  }

  _buildConnStatusMsg(BuildContext context, ModernColors colors) {
    widget.onSvcStatusChanged?.call();
    return Text(
      _svcStopped.value
          ? translate("Service is not running")
          : stateGlobal.svcStatus.value == SvcStatus.connecting
              ? translate("connecting_status")
              : stateGlobal.svcStatus.value == SvcStatus.notReady
                  ? translate("not_ready_status")
                  : translate('Ready'),
      style: TextStyle(
        fontSize: em,
        color: colors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  updateStatus() async {
    final status =
        jsonDecode(await bind.mainGetConnectStatus()) as Map<String, dynamic>;
    final statusNum = status['status_num'] as int;
    if (statusNum == 0) {
      stateGlobal.svcStatus.value = SvcStatus.connecting;
    } else if (statusNum == -1) {
      stateGlobal.svcStatus.value = SvcStatus.notReady;
    } else if (statusNum == 1) {
      stateGlobal.svcStatus.value = SvcStatus.ready;
    } else {
      stateGlobal.svcStatus.value = SvcStatus.notReady;
    }
    _svcIsUsingPublicServer.value = await bind.mainIsUsingPublicServer();
    try {
      stateGlobal.videoConnCount.value = status['video_conn_count'] as int;
    } catch (_) {}
  }
}

/// Connection page for connecting to a remote peer.
class ConnectionPage extends StatefulWidget {
  const ConnectionPage({Key? key}) : super(key: key);

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

/// State for the connection page.
class _ConnectionPageState extends State<ConnectionPage>
    with SingleTickerProviderStateMixin, WindowListener {
  /// Controller for the id input bar.
  final _idController = IDTextEditingController();

  final RxBool _idInputFocused = false.obs;
  final FocusNode _idFocusNode = FocusNode();
  final TextEditingController _idEditingController = TextEditingController();

  String selectedConnectionType = 'Connect';

  bool isWindowMinimized = false;

  final AllPeersLoader _allPeersLoader = AllPeersLoader();

  // https://github.com/flutter/flutter/issues/157244
  Iterable<Peer> _autocompleteOpts = [];

  final _menuOpen = false.obs;
  _DesktopSidebarSection _activeSection = _DesktopSidebarSection.devices;
  bool _showListView = true;

  @override
  void initState() {
    super.initState();
    _allPeersLoader.init(setState);
    peerCardUiType.value = PeerUiType.list;
    _showListView = peerCardUiType.value == PeerUiType.list;
    _idFocusNode.addListener(onFocusChanged);
    peerSearchTextController.addListener(_onSearchTextChanged);
    if (_idController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final lastRemoteId = await bind.mainGetLastRemoteId();
        if (lastRemoteId != _idController.id) {
          setState(() {
            _idController.id = lastRemoteId;
          });
        }
      });
    }
    Get.put<TextEditingController>(_idEditingController);
    Get.put<IDTextEditingController>(_idController);
    windowManager.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _activateSection(_DesktopSidebarSection.devices, reload: true);
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    windowManager.removeListener(this);
    _allPeersLoader.clear();
    _idFocusNode.removeListener(onFocusChanged);
    peerSearchTextController.removeListener(_onSearchTextChanged);
    _idFocusNode.dispose();
    _idEditingController.dispose();
    if (Get.isRegistered<IDTextEditingController>()) {
      Get.delete<IDTextEditingController>();
    }
    if (Get.isRegistered<TextEditingController>()) {
      Get.delete<TextEditingController>();
    }
    super.dispose();
  }

  @override
  void onWindowEvent(String eventName) {
    super.onWindowEvent(eventName);
    if (eventName == 'minimize') {
      isWindowMinimized = true;
    } else if (eventName == 'maximize' || eventName == 'restore') {
      if (isWindowMinimized && isWindows) {
        // windows can't update when minimized.
        Get.forceAppUpdate();
      }
      isWindowMinimized = false;
    }
  }

  @override
  void onWindowEnterFullScreen() {
    // Remove edge border by setting the value to zero.
    stateGlobal.resizeEdgeSize.value = 0;
  }

  @override
  void onWindowLeaveFullScreen() {
    // Restore edge border to default edge size.
    stateGlobal.resizeEdgeSize.value = stateGlobal.isMaximized.isTrue
        ? kMaximizeEdgeSize
        : windowResizeEdgeSize;
  }

  @override
  void onWindowClose() {
    super.onWindowClose();
    bind.mainOnMainWindowClose();
  }

  void onFocusChanged() {
    _idInputFocused.value = _idFocusNode.hasFocus;
    if (_idFocusNode.hasFocus) {
      if (_allPeersLoader.needLoad) {
        _allPeersLoader.getAllPeers();
      }

      final textLength = _idEditingController.value.text.length;
      // Select all to facilitate removing text, just following the behavior of address input of chrome.
      _idEditingController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textLength,
      );
    }
  }

  void _onSearchTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? ModernColors.dark : ModernColors.light;

    return Obx(() {
      final isLoggedIn = gFFI.userModel.isLogin;
      return Container(
        color: colors.background,
        child: Row(
          children: [
            _buildSidebar(context, colors, isLoggedIn),
            VerticalDivider(width: 1, thickness: 1, color: colors.border),
            Expanded(
              child: isLoggedIn
                  ? _buildWorkspace(context, colors)
                  : Center(
                      child: _buildLoginRequiredCard(context, colors),
                    ),
            ),
          ],
        ),
      );
    });
  }

  void _activateSection(_DesktopSidebarSection section, {bool reload = false}) {
    if (!reload && _activeSection == section) {
      return;
    }
    setState(() {
      _activeSection = section;
    });
    switch (section) {
      case _DesktopSidebarSection.devices:
        gFFI.peerTabModel.setCurrentTab(PeerTabIndex.group.index);
        bind.setLocalFlutterOption(
          k: kOptionPeerTabIndex,
          v: PeerTabIndex.group.index.toString(),
        );
        gFFI.groupModel.pull(force: reload);
        break;
      case _DesktopSidebarSection.connectionHistory:
        gFFI.peerTabModel.setCurrentTab(PeerTabIndex.recent.index);
        bind.setLocalFlutterOption(
          k: kOptionPeerTabIndex,
          v: PeerTabIndex.recent.index.toString(),
        );
        bind.mainLoadRecentPeers();
        break;
      case _DesktopSidebarSection.addressBook:
        gFFI.peerTabModel.setCurrentTab(PeerTabIndex.ab.index);
        bind.setLocalFlutterOption(
          k: kOptionPeerTabIndex,
          v: PeerTabIndex.ab.index.toString(),
        );
        gFFI.abModel.pullAb(force: ForcePullAb.listAndCurrent, quiet: false);
        break;
      case _DesktopSidebarSection.fileTransfer:
        break;
    }
  }

  Widget _buildSidebar(
      BuildContext context, ModernColors colors, bool isLoggedIn) {
    return Container(
      width: 208,
      color: colors.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.cloud_circle_rounded,
                    color: colors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildSidebarItem(
            context,
            colors,
            section: _DesktopSidebarSection.devices,
            icon: Icons.devices_other_rounded,
            label: translate('My devices'),
            enabled: isLoggedIn,
          ),
          _buildSidebarItem(
            context,
            colors,
            section: _DesktopSidebarSection.connectionHistory,
            icon: Icons.history_rounded,
            label: translate('Recent sessions'),
            enabled: isLoggedIn,
          ),
          _buildSidebarItem(
            context,
            colors,
            section: _DesktopSidebarSection.addressBook,
            icon: Icons.contacts_outlined,
            label: translate('Address book'),
            enabled: isLoggedIn,
          ),
          _buildSidebarItem(
            context,
            colors,
            section: _DesktopSidebarSection.fileTransfer,
            icon: Icons.folder_open_rounded,
            label: translate('Transfer file'),
            enabled: isLoggedIn,
          ),
          _buildSidebarAction(
            context,
            colors,
            icon: Icons.settings_outlined,
            label: translate('Settings'),
            onTap: _openSettings,
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colors.border)),
            ),
            child: const OnlineStatusWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context,
    ModernColors colors, {
    required _DesktopSidebarSection section,
    required IconData icon,
    required String label,
    required bool enabled,
  }) {
    final selected = _activeSection == section;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? () => _activateSection(section) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color:
                selected ? colors.primary.withOpacity(0.1) : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: selected ? colors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? colors.primary
                    : (enabled ? colors.textSecondary : colors.textTertiary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? colors.primary
                        : (enabled ? colors.textPrimary : colors.textTertiary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarAction(
    BuildContext context,
    ModernColors colors, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Icon(icon, size: 20, color: colors.textSecondary),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkspace(BuildContext context, ModernColors colors) {
    final showToolbar = _activeSection != _DesktopSidebarSection.fileTransfer;
    final showFooter = _activeSection != _DesktopSidebarSection.fileTransfer;
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 28, 30, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _sectionTitle(_activeSection),
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: showToolbar ? 22 : 16),
          if (showToolbar) _buildToolbar(colors),
          if (showToolbar) const SizedBox(height: 18),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildSectionBody(colors),
              ),
            ),
          ),
          if (showFooter) const SizedBox(height: 18),
          if (showFooter) _buildFooter(colors),
        ],
      ),
    );
  }

  String _sectionTitle(_DesktopSidebarSection section) {
    switch (section) {
      case _DesktopSidebarSection.devices:
        return translate('My devices');
      case _DesktopSidebarSection.connectionHistory:
        return translate('Recent sessions');
      case _DesktopSidebarSection.addressBook:
        return translate('Address book');
      case _DesktopSidebarSection.fileTransfer:
        return translate('Transfer file');
    }
  }

  Widget _buildToolbar(ModernColors colors) {
    final primaryActionLabel =
        _activeSection == _DesktopSidebarSection.addressBook
            ? translate('Add to address book')
            : 'Add Device';

    return Row(
      children: [
        Expanded(child: _buildSearchInput(colors)),
        const SizedBox(width: 18),
        _buildViewSwitch(colors),
        const SizedBox(width: 18),
        SizedBox(
          height: 46,
          child: ElevatedButton.icon(
            onPressed: _handlePrimaryAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(
              primaryActionLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchInput(ModernColors colors) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 20, color: colors.textTertiary)
              .marginOnly(left: 14, right: 10),
          Expanded(
            child: TextField(
              controller: peerSearchTextController,
              onChanged: (value) => peerSearchText.value = value,
              style: TextStyle(
                fontSize: 14,
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: colors.primary,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search device / note / ID',
                hintStyle: TextStyle(
                  color: colors.textTertiary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ).workaroundFreezeLinuxMint(),
          ),
          if (peerSearchTextController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                setState(() {
                  peerSearchTextController.clear();
                  peerSearchText.value = '';
                });
              },
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: colors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildViewSwitch(ModernColors colors) {
    void setViewMode(bool listMode) {
      setState(() {
        _showListView = listMode;
        peerCardUiType.value = listMode ? PeerUiType.list : PeerUiType.grid;
      });
    }

    Widget buildModeButton({
      required bool selected,
      required IconData icon,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 48,
          height: 46,
          decoration: BoxDecoration(
            color: selected ? colors.primary.withOpacity(0.12) : colors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  selected ? colors.primary.withOpacity(0.35) : colors.border,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: selected ? colors.primary : colors.textSecondary,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          buildModeButton(
            selected: _showListView,
            icon: Icons.view_list_rounded,
            onTap: () => setViewMode(true),
          ),
          const SizedBox(width: 6),
          buildModeButton(
            selected: !_showListView,
            icon: Icons.grid_view_rounded,
            onTap: () => setViewMode(false),
          ),
        ],
      ),
    );
  }

  void _handlePrimaryAction() {
    switch (_activeSection) {
      case _DesktopSidebarSection.devices:
      case _DesktopSidebarSection.connectionHistory:
      case _DesktopSidebarSection.addressBook:
        _showAddDeviceDialog();
        break;
      case _DesktopSidebarSection.fileTransfer:
        onConnect(isFileTransfer: true);
        break;
    }
  }

  Widget _buildSectionBody(ModernColors colors) {
    switch (_activeSection) {
      case _DesktopSidebarSection.devices:
        return MyGroupPeerView(menuPadding: kDesktopMenuPadding);
      case _DesktopSidebarSection.connectionHistory:
        return RecentPeersView(menuPadding: kDesktopMenuPadding);
      case _DesktopSidebarSection.addressBook:
        return AddressBookPeersView(menuPadding: kDesktopMenuPadding);
      case _DesktopSidebarSection.fileTransfer:
        return _buildFileTransferSection(colors);
    }
  }

  Widget _buildFileTransferSection(ModernColors colors) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        final panel = _buildRemoteIDTextField(
          context,
          colors,
          mode: _QuickConnectMode.fileTransfer,
          title: translate('Transfer file'),
        );
        final tips = _buildFileTransferTips(colors);
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: tips),
                        const SizedBox(width: 24),
                        panel,
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        tips,
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.center,
                          child: panel,
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFileTransferTips(ModernColors colors) {
    Widget buildTip({
      required IconData icon,
      required String title,
      required String subtitle,
    }) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: colors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select a remote device and start a direct file transfer session.',
          style: TextStyle(
            fontSize: 15,
            height: 1.55,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        buildTip(
          icon: Icons.dialpad_rounded,
          title: 'Enter remote ID',
          subtitle:
              'Use the device ID under the current account, or any reachable device ID that you have permission to access.',
        ),
        const SizedBox(height: 12),
        buildTip(
          icon: Icons.folder_zip_outlined,
          title: 'Open transfer window',
          subtitle:
              'The client will create a file transfer session instead of opening remote desktop control.',
        ),
        const SizedBox(height: 12),
        buildTip(
          icon: Icons.settings_outlined,
          title: 'Connection settings',
          subtitle:
              'If you need to adjust relay, security, or other connection options, open Settings before starting the transfer.',
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings_outlined, size: 18),
            label: Text(
              translate('Settings'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ModernColors colors) {
    return AnimatedBuilder(
      animation: gFFI.peerTabModel,
      builder: (context, child) {
        final total = gFFI.peerTabModel.currentTabCachedPeers.length;
        return Row(
          children: [
            Text(
              '$total devices',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  _buildPageButton(
                    colors,
                    icon: Icons.chevron_left_rounded,
                    enabled: false,
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.1),
                      border: Border.symmetric(
                        vertical: BorderSide(color: colors.border),
                      ),
                    ),
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _buildPageButton(
                    colors,
                    icon: Icons.chevron_right_rounded,
                    enabled: false,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Text(
                    '10 / page',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPageButton(
    ModernColors colors, {
    required IconData icon,
    required bool enabled,
  }) {
    return SizedBox(
      width: 38,
      height: 38,
      child: Icon(
        icon,
        size: 18,
        color: enabled ? colors.textSecondary : colors.textTertiary,
      ),
    );
  }

  /// Callback for the connect button.
  /// Connects to the selected peer.
  Future<void> onConnect({
    bool isFileTransfer = false,
    bool isViewCamera = false,
    bool isTerminal = false,
  }) async {
    if (!gFFI.userModel.isLogin) {
      await _loginAndFocusMyDevices();
      return;
    }
    final id = _idController.id.replaceAll(' ', '').trim();
    if (id.isEmpty) {
      showToast(translate('Enter Remote ID'));
      return;
    }
    if (await shouldBlockSelfConnect(id)) {
      showToast('Current device cannot connect to itself');
      return;
    }
    connect(
      context,
      id,
      isFileTransfer: isFileTransfer,
      isViewCamera: isViewCamera,
      isTerminal: isTerminal,
    );
  }

  Future<void> _focusMyDevicesTab() async {
    gFFI.peerTabModel.setCurrentTab(PeerTabIndex.group.index);
    await bind.setLocalFlutterOption(
      k: kOptionPeerTabIndex,
      v: PeerTabIndex.group.index.toString(),
    );
  }

  Future<void> _loginAndFocusMyDevices() async {
    final loggedIn = await loginDialog();
    if (loggedIn == true) {
      await _focusMyDevicesTab();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _registerAndFocusMyDevices() async {
    final loggedIn = await registerDialog();
    if (loggedIn == true) {
      await _focusMyDevicesTab();
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _openSettings() {
    DesktopTabPage.onAddSetting(initialPage: SettingsTabKey.general);
  }

  Future<void> _showAddDeviceDialog() async {
    if (!gFFI.userModel.isLogin) {
      await _loginAndFocusMyDevices();
      return;
    }

    await gFFI.abModel.pullAb(force: ForcePullAb.listAndCurrent, quiet: false);
    final writableAddressBooks = gFFI.abModel.addressBooksCanWrite();
    if (writableAddressBooks.isEmpty) {
      showToast('Address book is unavailable');
      return;
    }
    var selectedAddressBook = gFFI.abModel.current.canWrite()
        ? gFFI.abModel.currentName.value
        : writableAddressBooks.first;
    if (!writableAddressBooks.contains(selectedAddressBook)) {
      selectedAddressBook = writableAddressBooks.first;
    }
    if (gFFI.abModel.currentName.value != selectedAddressBook) {
      await gFFI.abModel.setCurrentName(selectedAddressBook);
    }
    if (gFFI.abModel.isCurrentAbFull(true)) {
      return;
    }

    final idController = TextEditingController();
    final aliasController = TextEditingController();
    final passwordController = TextEditingController();
    final noteController = TextEditingController();
    final selectedTags = <dynamic>[].obs;
    String? idError;
    bool isSubmitting = false;

    final res = await gFFI.dialogManager.show<bool>((setState, close, context) {
      final dialogColors = Theme.of(context).brightness == Brightness.dark
          ? ModernColors.dark
          : ModernColors.light;

      Future<void> switchAddressBook(String value) async {
        if (value == selectedAddressBook) {
          return;
        }
        setState(() {
          isSubmitting = true;
          idError = null;
        });
        await gFFI.abModel.setCurrentName(value);
        setState(() {
          selectedAddressBook = value;
          selectedTags.clear();
          isSubmitting = false;
        });
      }

      Future<void> submit() async {
        final id = idController.text.replaceAll(' ', '').trim();
        if (id.isEmpty) {
          setState(() => idError = translate('Enter Remote ID'));
          return;
        }
        if (await shouldBlockSelfConnect(id)) {
          setState(() {
            idError = 'Current device cannot be added here';
          });
          return;
        }
        if (gFFI.abModel.idContainByCurrent(id)) {
          setState(() {
            idError = translate('ID already exists');
          });
          return;
        }
        if (gFFI.abModel.isCurrentAbFull(true)) {
          return;
        }
        setState(() {
          idError = null;
          isSubmitting = true;
        });
        final err = await gFFI.abModel.addIdToCurrent(
          id,
          aliasController.text.trim(),
          gFFI.abModel.current.isPersonal() ? '' : passwordController.text,
          List<dynamic>.from(selectedTags),
          noteController.text.trim(),
        );
        if (err == null) {
          close(true);
          return;
        }
        setState(() {
          idError = err;
          isSubmitting = false;
        });
      }

      return CustomAlertDialog(
        title: Text(translate('Add to address book')),
        contentBoxConstraints: const BoxConstraints(minWidth: 420),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (writableAddressBooks.length > 1)
              DropdownButtonFormField<String>(
                value: selectedAddressBook,
                items: writableAddressBooks
                    .map(
                      (name) => DropdownMenuItem<String>(
                        value: name,
                        child: Text(name),
                      ),
                    )
                    .toList(growable: false),
                onChanged:
                    isSubmitting ? null : (value) => switchAddressBook(value!),
                decoration: InputDecoration(
                  labelText: translate('Address book'),
                ),
              ).workaroundFreezeLinuxMint(),
            if (writableAddressBooks.length > 1) const SizedBox(height: 12),
            TextField(
              controller: idController,
              autofocus: true,
              inputFormatters: [IDTextInputFormatter()],
              decoration: InputDecoration(
                labelText: translate('ID'),
                errorText: idError,
              ),
              onChanged: (_) {
                if (idError != null) {
                  setState(() => idError = null);
                }
              },
            ).workaroundFreezeLinuxMint(),
            const SizedBox(height: 12),
            TextField(
              controller: aliasController,
              decoration: InputDecoration(
                labelText: translate('Alias'),
              ),
            ).workaroundFreezeLinuxMint(),
            const SizedBox(height: 12),
            if (!gFFI.abModel.current.isPersonal()) ...[
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: translate('Password'),
                ),
              ).workaroundFreezeLinuxMint(),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: translate('Note'),
                alignLabelWithHint: true,
              ),
            ).workaroundFreezeLinuxMint(),
            if (gFFI.abModel.currentAbTags.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                translate('Tags'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: dialogColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: gFFI.abModel.currentAbTags
                      .map(
                        (tag) => FilterChip(
                          label: Text(tag),
                          selected: selectedTags.contains(tag),
                          onSelected: isSubmitting
                              ? null
                              : (selected) {
                                  if (selected) {
                                    selectedTags.add(tag);
                                  } else {
                                    selectedTags.remove(tag);
                                  }
                                },
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ],
            if (!gFFI.abModel.current.isPersonal()) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: dialogColors.warning,
                  ).marginOnly(top: 2, right: 6),
                  Expanded(
                    child: Text(
                      translate('share_warning_tip'),
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: dialogColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (isSubmitting) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
          ],
        ),
        actions: [
          dialogButton(
            'Cancel',
            onPressed: close,
            isOutline: true,
          ),
          dialogButton(
            'OK',
            onPressed: isSubmitting ? null : submit,
          ),
        ],
        onCancel: close,
        onSubmit: submit,
      );
    });

    idController.dispose();
    aliasController.dispose();
    passwordController.dispose();
    noteController.dispose();

    if (res == true) {
      showToast(translate('Successful'));
      _activateSection(_DesktopSidebarSection.addressBook, reload: true);
    }
  }

  Widget _buildLoginRequiredCard(BuildContext context, ModernColors colors) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 560),
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: colors.border),
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(Icons.lock_outline, size: 42, color: colors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            '$appName login required',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Please sign in to $appName before starting a remote session. After login, the client will show the devices under the current account.',
            style: TextStyle(
              color: colors.textSecondary,
              height: 1.5,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _loginAndFocusMyDevices,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(translate('Login'),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _registerAndFocusMyDevices,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.secondary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(translate('Register'),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// UI for the remote ID TextField.
  /// Search for a peer.
  Widget _buildRemoteIDTextField(
    BuildContext context,
    ModernColors colors, {
    _QuickConnectMode mode = _QuickConnectMode.connect,
    String? title,
  }) {
    final isFileTransferMode = mode == _QuickConnectMode.fileTransfer;
    Future<void> primaryAction() async {
      if (isFileTransferMode) {
        await onConnect(isFileTransfer: true);
      } else {
        await onConnect();
      }
    }

    var w = Container(
      width: 320 + 20 * 2,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: colors.border),
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Ink(
        child: Column(
          children: [
            (title == null
                    ? getConnectionPageTitle(context, false)
                    : Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ))
                .marginOnly(bottom: 15),
            Row(
              children: [
                Expanded(
                  child: RawAutocomplete<Peer>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        _autocompleteOpts = const Iterable<Peer>.empty();
                      } else if (_allPeersLoader.peers.isEmpty &&
                          !_allPeersLoader.isPeersLoaded) {
                        Peer emptyPeer = Peer(
                          id: '',
                          username: '',
                          hostname: '',
                          alias: '',
                          platform: '',
                          tags: [],
                          hash: '',
                          password: '',
                          forceAlwaysRelay: false,
                          rdpPort: '',
                          rdpUsername: '',
                          loginName: '',
                          device_group_name: '',
                          note: '',
                        );
                        _autocompleteOpts = [emptyPeer];
                      } else {
                        String textWithoutSpaces =
                            textEditingValue.text.replaceAll(" ", "");
                        if (int.tryParse(textWithoutSpaces) != null) {
                          textEditingValue = TextEditingValue(
                            text: textWithoutSpaces,
                            selection: textEditingValue.selection,
                          );
                        }
                        String textToFind = textEditingValue.text.toLowerCase();
                        _autocompleteOpts = _allPeersLoader.peers
                            .where(
                              (peer) =>
                                  peer.id.toLowerCase().contains(textToFind) ||
                                  peer.username.toLowerCase().contains(
                                        textToFind,
                                      ) ||
                                  peer.hostname.toLowerCase().contains(
                                        textToFind,
                                      ) ||
                                  peer.alias.toLowerCase().contains(textToFind),
                            )
                            .toList();
                      }
                      return _autocompleteOpts;
                    },
                    focusNode: _idFocusNode,
                    textEditingController: _idEditingController,
                    fieldViewBuilder: (
                      BuildContext context,
                      TextEditingController fieldTextEditingController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted,
                    ) {
                      updateTextAndPreserveSelection(
                        fieldTextEditingController,
                        _idController.text,
                      );
                      return Obx(
                        () => TextField(
                          autocorrect: false,
                          enableSuggestions: false,
                          keyboardType: TextInputType.visiblePassword,
                          focusNode: fieldFocusNode,
                          style: TextStyle(
                            fontFamily: 'WorkSans',
                            fontSize: 22,
                            height: 1.4,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          cursorColor: colors.primary,
                          decoration: InputDecoration(
                            filled: false,
                            counterText: '',
                            hintText: _idInputFocused.value
                                ? null
                                : translate('Enter Remote ID'),
                            hintStyle: TextStyle(color: colors.textTertiary),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 13,
                            ),
                          ),
                          controller: fieldTextEditingController,
                          inputFormatters: [IDTextInputFormatter()],
                          onChanged: (v) {
                            _idController.id = v;
                          },
                          onSubmitted: (_) {
                            primaryAction();
                          },
                        ).workaroundFreezeLinuxMint(),
                      );
                    },
                    onSelected: (option) {
                      setState(() {
                        _idController.id = option.id;
                        FocusScope.of(context).unfocus();
                      });
                    },
                    optionsViewBuilder: (
                      BuildContext context,
                      AutocompleteOnSelected<Peer> onSelected,
                      Iterable<Peer> options,
                    ) {
                      options = _autocompleteOpts;
                      double maxHeight = options.length * 50;
                      if (options.length == 1) {
                        maxHeight = 52;
                      } else if (options.length == 3) {
                        maxHeight = 146;
                      } else if (options.length == 4) {
                        maxHeight = 193;
                      }
                      maxHeight = maxHeight.clamp(0, 200);

                      return Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: colors.textPrimary.withOpacity(0.15),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Material(
                              color: colors.surface,
                              elevation: 4,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: maxHeight,
                                  maxWidth: 319,
                                ),
                                child: _allPeersLoader.peers.isEmpty &&
                                        !_allPeersLoader.isPeersLoaded
                                    ? Container(
                                        height: 80,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: colors.primary,
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                          top: 5,
                                        ),
                                        child: ListView(
                                          children: options
                                              .map(
                                                (peer) => AutocompletePeerTile(
                                                  onSelect: () =>
                                                      onSelected(peer),
                                                  peer: peer,
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 13.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: primaryAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isFileTransferMode
                                ? Icons.folder_open_rounded
                                : Icons.cast_connected_rounded,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                              translate(
                                isFileTransferMode
                                    ? 'Transfer file'
                                    : 'Connect',
                              ),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(10),
                      color: colors.surfaceVariant,
                    ),
                    child: Center(
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          var offset = Offset(0, 0);
                          return Obx(
                            () => InkWell(
                              borderRadius: BorderRadius.circular(10),
                              child: _menuOpen.value
                                  ? Transform.rotate(
                                      angle: pi,
                                      child: Icon(Icons.more_horiz_rounded,
                                          size: 18,
                                          color: colors.textSecondary),
                                    )
                                  : Icon(Icons.more_horiz_rounded,
                                      size: 18, color: colors.textSecondary),
                              onTapDown: (e) {
                                offset = e.globalPosition;
                              },
                              onTap: () async {
                                _menuOpen.value = true;
                                final x = offset.dx;
                                final y = offset.dy;
                                await mod_menu
                                    .showMenu(
                                  context: context,
                                  position: RelativeRect.fromLTRB(
                                    x,
                                    y,
                                    x,
                                    y,
                                  ),
                                  items: [
                                    (
                                      'Transfer file',
                                      () => onConnect(
                                            isFileTransfer: true,
                                          ),
                                    ),
                                    (
                                      'View camera',
                                      () => onConnect(
                                            isViewCamera: true,
                                          ),
                                    ),
                                    (
                                      '${translate('Terminal')} (beta)',
                                      () => onConnect(
                                            isTerminal: true,
                                          ),
                                    ),
                                  ]
                                      .map(
                                        (e) => MenuEntryButton<String>(
                                          childBuilder: (TextStyle? style) =>
                                              Text(
                                            translate(e.$1),
                                            style: style,
                                          ),
                                          proc: () => e.$2(),
                                          padding: EdgeInsets.symmetric(
                                            horizontal:
                                                kDesktopMenuPadding.left,
                                          ),
                                          dismissOnClicked: true,
                                        ),
                                      )
                                      .map(
                                        (e) => e.build(
                                          context,
                                          const MenuConfig(
                                            commonColor: CustomPopupMenuTheme
                                                .commonColor,
                                            height: CustomPopupMenuTheme.height,
                                            dividerHeight: CustomPopupMenuTheme
                                                .dividerHeight,
                                          ),
                                        ),
                                      )
                                      .expand((i) => i)
                                      .toList(),
                                  elevation: 8,
                                )
                                    .then((_) {
                                  _menuOpen.value = false;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      child: w,
    );
  }
}
