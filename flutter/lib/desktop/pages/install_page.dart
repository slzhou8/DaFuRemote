import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import '../../themes/modern_theme.dart';
import 'package:flutter_hbb/desktop/widgets/tabbar_widget.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:flutter_hbb/models/state_model.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:window_manager/window_manager.dart';

class InstallPage extends StatefulWidget {
  const InstallPage({Key? key}) : super(key: key);

  @override
  State<InstallPage> createState() => _InstallPageState();
}

class _InstallPageState extends State<InstallPage> {
  final tabController = DesktopTabController(tabType: DesktopTabType.main);

  _InstallPageState() {
    Get.put<DesktopTabController>(tabController);
    const label = "install";
    tabController.add(TabInfo(
        key: label,
        label: label,
        closable: false,
        page: _InstallPageBody(
          key: const ValueKey(label),
        )));
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<DesktopTabController>();
  }

  @override
  Widget build(BuildContext context) {
    return DragToResizeArea(
      resizeEdgeSize: stateGlobal.resizeEdgeSize.value,
      enableResizeEdges: windowManagerEnableResizeEdges,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        body: DesktopTab(controller: tabController),
      ),
    );
  }
}

class _InstallPageBody extends StatefulWidget {
  const _InstallPageBody({Key? key}) : super(key: key);

  @override
  State<_InstallPageBody> createState() => _InstallPageBodyState();
}

class _InstallPageBodyState extends State<_InstallPageBody>
    with WindowListener {
  late final TextEditingController controller;
  final RxBool startmenu = true.obs;
  final RxBool desktopicon = true.obs;
  final RxBool printer = true.obs;
  final RxBool showProgress = false.obs;
  final RxBool btnEnabled = true.obs;
  final RxBool installSucceeded = false.obs;
  final RxString statusText = ''.obs;
  final RxString errorText = ''.obs;

  static const _bannerColor = Color(0xFF0F6CBD);
  static const _bannerAccent = Color(0xFF8BC4FF);

  final buttonStyle = OutlinedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 14),
  );

  _InstallPageBodyState() {
    controller = TextEditingController(text: bind.installInstallPath());
    final installOptions = jsonDecode(bind.installInstallOptions());
    startmenu.value = installOptions['STARTMENUSHORTCUTS'] != '0';
    desktopicon.value = installOptions['DESKTOPSHORTCUTS'] != '0';
    printer.value = installOptions['PRINTER'] != '0';
  }

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void onWindowClose() {
    if (showProgress.value) {
      return;
    }
    gFFI.close();
    super.onWindowClose();
    windowManager.setPreventClose(false);
    windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980, maxHeight: 620),
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 40,
                    offset: Offset(0, 20),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildBanner(),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(36, 32, 36, 20),
                            child: Obx(
                              () => SingleChildScrollView(
                                child: installSucceeded.value
                                    ? _buildCompletedPane(context)
                                    : _buildInstallPane(context),
                              ),
                            ),
                          ),
                        ),
                        _buildFooter(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBanner() {
    return Container(
      width: 270,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_bannerColor, Color(0xFF0A4E91)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -20,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: _bannerAccent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.shield_outlined,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(height: 22),
                Text(
                  appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  translate('Installation'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.86),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                _buildBannerStep('01', translate('Installation Path')),
                const SizedBox(height: 14),
                _buildBannerStep('02', translate('Installation')),
                const SizedBox(height: 14),
                _buildBannerStep('03', translate('Close')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerStep(String index, String label) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            index,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.92),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstallPane(BuildContext context) {
    final isDarkTheme = MyTheme.currentThemeMode() == ThemeMode.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF162033),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          translate('Accept and Install'),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF4C5B78),
          ),
        ),
        const SizedBox(height: 28),
        _buildSectionLabel(translate('Installation Path')),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDCE4F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ).workaroundFreezeLinuxMint(),
              ),
              const SizedBox(width: 12),
              Obx(
                () => OutlinedButton.icon(
                  icon: const Icon(Icons.folder_outlined, size: 18),
                  onPressed: btnEnabled.value ? selectInstallPath : null,
                  style: buttonStyle,
                  label: Text(translate('Change Path')),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionLabel(translate('Installation')),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDCE4F0)),
          ),
          child: Column(
            children: [
              _buildOption(startmenu,
                  icon: Icons.apps_outlined,
                  label: 'Create start menu shortcuts'),
              const SizedBox(height: 10),
              _buildOption(desktopicon,
                  icon: Icons.desktop_windows_outlined,
                  label: 'Create desktop icon'),
              const SizedBox(height: 10),
              _buildOption(printer,
                  icon: Icons.print_outlined,
                  label: 'Install {$appName} Printer'),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDarkTheme
                ? const Color.fromARGB(135, 87, 87, 90)
                : const Color(0xFFF6F8FB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDCE4F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 24, color: Color(0xFF4A678D)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translate('agreement_tip'),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF43536F),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      hoverColor: Colors.transparent,
                      onTap: () =>
                          launchUrlString('https://rustdesk.com/privacy.html'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.launch_outlined,
                              size: 16, color: _bannerColor),
                          const SizedBox(width: 6),
                          Text(
                            translate('End-user license agreement'),
                            style: const TextStyle(
                              color: _bannerColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Obx(() => _buildStatusPanel()),
      ],
    );
  }

  Widget _buildCompletedPane(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 26),
        Center(
          child: Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFFE9F7EE),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                size: 54, color: Color(0xFF249B55)),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            translate('Installation Successful!'),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF162033),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            appName,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF51627E),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDCE4F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                translate('Installation Path'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF607089),
                ),
              ),
              const SizedBox(height: 8),
              SelectableText(
                controller.text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E2A3D),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF5FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFCFE0FF)),
          ),
          child: Text(
            translate('Installation Successful!'),
            style: const TextStyle(
              color: Color(0xFF275EA8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 22),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE6ECF5))),
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: showProgress.value
                  ? Row(
                      children: [
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            statusText.value.isEmpty
                                ? translate('Installing ...')
                                : statusText.value,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4F607B),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      statusText.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: installSucceeded.value
                            ? const Color(0xFF249B55)
                            : const Color(0xFF4F607B),
                        fontWeight: installSucceeded.value
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
            ),
            if (installSucceeded.value) ...[
              OutlinedButton.icon(
                icon: const Icon(Icons.folder_open_outlined, size: 18),
                onPressed: openInstallFolder,
                style: buttonStyle,
                label: Text(translate('Open')),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_rounded, size: 18),
                onPressed: () => windowManager.close(),
                style: buttonStyle,
                label: Text(translate('Close')),
              ),
            ] else ...[
              OutlinedButton.icon(
                icon: const Icon(Icons.close_rounded, size: 18),
                label: Text(translate('Cancel')),
                onPressed:
                    btnEnabled.value ? () => windowManager.close() : null,
                style: buttonStyle,
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.done_rounded, size: 18),
                label: Text(translate('Accept and Install')),
                onPressed: btnEnabled.value ? install : null,
                style: buttonStyle,
              ),
              if (!bind.installShowRunWithoutInstall()) ...[
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  icon: const Icon(Icons.screen_share_outlined, size: 18),
                  label: Text(translate('Run without install')),
                  onPressed: btnEnabled.value
                      ? () => bind.installRunWithoutInstall()
                      : null,
                  style: buttonStyle,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPanel() {
    if (showProgress.value) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD8E5FF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LinearProgressIndicator(),
            const SizedBox(height: 10),
            Text(
              statusText.value.isEmpty
                  ? translate('Installing ...')
                  : statusText.value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF355B94),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    if (errorText.value.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF2C7C7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate('Installation failed!'),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFB3261E),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            errorText.value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF7A2E2A),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2A3850),
      ),
    );
  }

  Widget _buildOption(RxBool option,
      {required IconData icon, required String label}) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => btnEnabled.value ? option.value = !option.value : null,
      child: Obx(
        () => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: option.value
                ? const Color(0xFFF0F6FF)
                : const Color(0xFFF9FBFD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: option.value
                  ? const Color(0xFFBBD3FF)
                  : const Color(0xFFDDE6F0),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF54719C)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  translate(label),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF223047),
                  ),
                ),
              ),
              Checkbox(
                visualDensity:
                    const VisualDensity(horizontal: -4, vertical: -4),
                value: option.value,
                onChanged: btnEnabled.value
                    ? (v) => option.value = !option.value
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> install() async {
    btnEnabled.value = false;
    installSucceeded.value = false;
    errorText.value = '';
    statusText.value = translate('Installing ...');
    showProgress.value = true;

    var args = '';
    if (startmenu.value) args += ' startmenu';
    if (desktopicon.value) args += ' desktopicon';
    if (printer.value) args += ' printer';

    await bind.installInstallMe(options: args, path: controller.text);
    final status = await _waitInstallStatus();
    if (!mounted) return;

    showProgress.value = false;
    if (status.isEmpty) {
      installSucceeded.value = true;
      statusText.value = translate('Installation Successful!');
      btnEnabled.value = true;
      return;
    }

    btnEnabled.value = true;
    statusText.value = translate('Installation failed!');
    errorText.value = status;
  }

  Future<String> _waitInstallStatus() async {
    var status = await bind.mainGetAsyncStatus();
    while (status == " ") {
      await Future.delayed(const Duration(milliseconds: 250));
      status = await bind.mainGetAsyncStatus();
    }
    return status;
  }

  void selectInstallPath() async {
    final installPath = await FilePicker.platform
        .getDirectoryPath(initialDirectory: controller.text);
    if (installPath != null) {
      controller.text = join(installPath, await bind.mainGetAppName());
    }
  }

  void openInstallFolder() {
    launchUrlString(Uri.directory(controller.text, windows: true).toString());
  }
}
