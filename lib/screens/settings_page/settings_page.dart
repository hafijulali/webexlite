import 'package:webexapis/webexapis.dart';
import 'package:provider/provider.dart';

import 'package:packer/logging/file_logger.dart';
import 'log_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:packer/utils/package_utils.dart';
import 'package:packer/widgets/app_bar.dart';
import 'package:packer/widgets/snack_bar.dart';
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
  bool _useMessageOverlay = false;
  int _cacheExpiryTime = 60; // Default to 60 minutes

  SwitchListTile _useMessageOverlaySwitchTile(BuildContext context) {
    return SwitchListTile(
      title: const Text('Use Message Overlay'),
      subtitle: const Text('Use overlay for sending messages instead of a new page'),
      value: _useMessageOverlay,
      onChanged: (bool value) {
        logger?.debug("SettingsPage: toggling Message Overlay to $value");
        setState(() {
          _useMessageOverlay = value;
          settingsDatabase?.put(Constants().messageOverlaySettingsKey, value);
        });
      },
      secondary: const Icon(Icons.message_outlined),
    );
  }

  ListTile _cacheExpiryTimeDropdown(BuildContext context) {
    final List<int> expiryOptions = [
      1, // 1 minute
      5, // 5 minutes
      15, // 15 minutes
      30, // 30 minutes
      60, // 1 hour
      120, // 2 hours
      240, // 4 hours
      480, // 8 hours
    ];

    List<DropdownMenuEntry<int>> dropdownMenuEntries() {
      final List<DropdownMenuEntry<int>> menuItems = List.empty(growable: true);
      for (final int value in expiryOptions) {
        String text;
        if (value < 60) {
          text = '$value minutes';
        } else if (value == 60) {
          text = '1 hour';
        } else {
          text = '${value ~/ 60} hours';
        }
        menuItems.add(
          DropdownMenuEntry<int>(
            value: value,
            label: text,
          ),
        );
      }
      return menuItems;
    }

    return ListTile(
      leading: const Icon(Icons.timer),
      title: const Text('Cache Expiry Time'),
      trailing: SizedBox(
        width: Constants().settingsTileWidgetWidth,
        child: DropdownMenu<int>(
          hintText: _cacheExpiryTime.toString(),
          dropdownMenuEntries: dropdownMenuEntries(),
          onSelected: (value) {
            if (value != null) {
              logger?.debug("SettingsPage: setting cache expiry time to $value minutes");
              setState(() {
                _cacheExpiryTime = value;
                settingsDatabase?.put(Constants().cacheExpiryTimeSettingsKey, value);
              });
            }
          },
        ),
      ),
    );
  }

  SwitchListTile _useMaterial3(BuildContext context) {
    return SwitchListTile(
      title: const Text('Use Material 3'),
      value: useMaterial3,
      onChanged: (bool value) {
        logger?.debug("SettingsPage: toggling Material3 to $value");
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
          logger?.log("Debug logs enabled");
          context.read<WebexApis>().apiClient.enableDebugLogs();
        } else {
          logger?.log("Debug logs disabled");
          context.read<WebexApis>().apiClient.disableDebugLogs();
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
        logger?.debug("SettingsPage: toggling showSubtitle to $value");
        setState(() {
          showSubtitle = value;
          settingsDatabase?.put(Constants().showSubtitleKey, value);
        });
      },
      secondary: const Icon(Icons.subtitles_outlined),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      Constants().loginPageRoute,
      (route) => false,
    );
  }

  ListTile _signOut(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text('Sign Out'),
      onTap: () async {
        logger?.debug("SettingsPage: signing out");
        await context.read<WebexApis>().signOut();
        await settingsDatabase?.delete(Constants().tokenSettingsKey);
        if (context.mounted) {
          _navigateToLogin(context);
        }
      },
    );
  }

  ListTile _buildInfo(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.mobile_friendly_outlined),
      title: Text('App Version : $appVersion'),
      onTap: () async {
        logger?.debug("SettingsPage: opening app codebase url");
        await launchUrlString(Constants().appCodebase);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    logger?.debug("SettingsPage: initState");
    getAppVersion()
        .then((String version) => setState(() => appVersion = version));
    _useMessageOverlay = settingsDatabase?.get(Constants().messageOverlaySettingsKey) ?? false;
    _cacheExpiryTime = settingsDatabase?.get(Constants().cacheExpiryTimeSettingsKey) ?? 60; // Default to 60 minutes
  }

  ListTile _viewLogs(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.plagiarism_outlined),
      title: const Text(
        'View Logs',
        style: TextStyle(fontFamily: 'RobotoMono'),
      ),
      onTap: () {
        if (logger is FileLogger) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LogViewerPage(fileLogger: logger as FileLogger),
            ),
          );
        } else {
          showSnackbar('Log viewing is only available with FileLogger.');
        }
      },
    );
  }

  ListTile _exportLogs(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.bug_report_outlined),
      title: const Text('Export Logs'),
      onTap: () async {
        final result = await logger?.exportLogs();
        if (!mounted) return;
        showSnackbar(result ?? 'Failed to export logs.');
      },
    );
  }

  List<Widget> _widgetsTiles(BuildContext context) {
    return <Widget>[
      appTheme(context),
      const SizedBox(height: 16),
      _useMaterial3(context),
      const SizedBox(height: 16),
      _useMessageOverlaySwitchTile(context),
      const SizedBox(height: 16),
      maxItemsLimit(context),
      const SizedBox(height: 16),
      _cacheExpiryTimeDropdown(context),
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
      _enableDebugLogs(context),
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 16),
      const Text('Troubleshooting', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      _viewLogs(context),
      const SizedBox(height: 16),
      _exportLogs(context),
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 16),
      _signOut(context),
      const SizedBox(height: 16),
      _buildInfo(context),
    ];
  }

  @override
  Widget build(BuildContext context) {
    currentPath = Constants().settingsPageRoute;
    logger?.debug("Building SettingsPage");
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
}