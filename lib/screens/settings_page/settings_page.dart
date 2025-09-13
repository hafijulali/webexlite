import 'package:flutter/material.dart';
import 'package:packer/utils/package_utils.dart';
import 'package:packer/widgets/app_bar.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../init.dart';
import '../../core/constants/constants.dart';
import '../../custom/widgets/app_bar.dart';
import 'app_theme/app_theme.dart';
import 'auth/auth.dart';
import 'export_database/export_database.dart';
import 'export_database/export_json.dart';
import 'font_size/font_size.dart';
import 'import_database/import_database.dart';
import 'items_limit/items_limit.dart';
import 'landing_page/landing_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SwitchListTile _useMaterial3(BuildContext context) {
    return SwitchListTile(
      title: const Text('Use Material 3'),
      value: useMaterial3,
      onChanged: (bool value) {
        debugPrint("SettingsPage: toggling Material3 to $value");
        setState(() {
          settingsDatabase!.put(Constants().material3SettingsKey, value);
          useMaterial3 = value;
        });
      },
      secondary: const Icon(Icons.design_services_outlined),
    );
  }

  SwitchListTile _enableDebugLogs(BuildContext context) {
    return SwitchListTile(
      title: const Text('Enable app debug logs'),
      subtitle: const Text('Warning, may contain sensitive data'),
      value: enableDebug,
      onChanged: (bool value) {
        setState(() {
          enableDebug = value;
        });
        if (enableDebug) {
          debugPrint("Debug logs enabled");
          webexApis?.apiClient.enableDebugLogs();
        } else {
          debugPrint("Debug logs disabled");
          webexApis?.apiClient.disableDebugLogs();
        }
      },
      secondary: const Icon(Icons.design_services_outlined),
    );
  }

  SwitchListTile _showSubtitle(BuildContext context) {
    return SwitchListTile(
      title: const Text('Show subtitle in list items'),
      value: showSubtitle,
      onChanged: (bool value) {
        debugPrint("SettingsPage: toggling showSubtitle to $value");
        setState(() {
          showSubtitle = value;
          settingsDatabase?.put(Constants().showSubtitleKey, value);
        });
      },
      secondary: const Icon(Icons.subtitles_outlined),
    );
  }

  List<Widget> _widgetsTiles(BuildContext context) {
    return <Widget>[
      appTheme(context),
      const SizedBox(height: 16),
      _useMaterial3(context),
      const SizedBox(height: 16),
      _showSubtitle(context),
      const SizedBox(height: 16),
      maxItemsLimit(context),
      const SizedBox(height: 16),
      exportDatabase(context),
      const SizedBox(height: 16),
      exportToJson(context),
      const SizedBox(height: 16),
      importDatabase(context),
      const SizedBox(height: 16),
      landingPage(context),
      const SizedBox(height: 16),
      changeFontSize(context),
      const SizedBox(height: 16),
      auth(context),
      const SizedBox(height: 16),
      _buildInfo(context),
      const SizedBox(height: 16),
      _enableDebugLogs(context),
      const SizedBox(height: 16),
    ];
  }

  Widget settingsPage(BuildContext context) {
    return Scaffold(
      appBar: PackerAppBar(
        actions: actions(context),
        center: Text(Constants().settingsPageRoute.substring(1)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(children: _widgetsTiles(context)),
      ),
    );
  }

  ListTile _buildInfo(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.mobile_friendly_outlined),
      title: Text('App Version : $appVersion'),
      onTap: () async {
        debugPrint("SettingsPage: opening app codebase url");
        await launchUrlString(Constants().appCodebase);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    debugPrint("SettingsPage: initState");
    getAppVersion()
        .then((String version) => setState(() => appVersion = version));
  }

  @override
  Widget build(BuildContext context) {
    currentPath = Constants().settingsPageRoute;
    debugPrint("Building SettingsPage");
    return settingsPage(context);
  }
}
