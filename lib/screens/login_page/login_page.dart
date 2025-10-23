import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:packer/navigation/navigate.dart';
import 'package:pkce/pkce.dart';
import 'package:webexapis/webexapis.dart';

import '../../app_shell.dart';

import '../../core/constants/constants.dart';
import '../../init.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController codeController = TextEditingController();
  WebexApis webexApis = WebexApis(clientId: '', clientSecret: '');
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  PkcePair? _pkcePair;

  @override
  void initState() {
    super.initState();
    webexApis = WebexApis(
      clientId: dotenv.env['CLIENT_ID'],
      clientSecret: dotenv.env['CLIENT_SECRET'],
    );
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    final appLink = await _appLinks.getInitialAppLink();
    if (appLink != null) {
      _handleUri(appLink);
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    });
  }

  void _handleUri(Uri uri) {
    if (uri.queryParameters.containsKey('code')) {
      final code = uri.queryParameters['code'];
      codeController.text = code!;
      _exchangeCodeForToken();
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Building LoginPage");
    return Scaffold(
        appBar: AppBar(
          title: Text(Constants().appName),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _formElements(context)),
        ));
  }

  Widget _action(BuildContext context, String text) {
    return ElevatedButton(
        onPressed: () async {
          debugPrint("LoginPage: action pressed - $text");
          await _launchAuthorizationUrl();
        },
        child: Text(text));
  }

  ElevatedButton _cancel(BuildContext context) {
    return ElevatedButton(
      child: const Text('SKIP'),
      onPressed: () async {
        debugPrint("LoginPage: skip pressed");
        safePushNamed(
            context, Constants().loginPageRoute, Constants().homePageRoute);
      },
    );
  }

  List<Widget> _formElements(BuildContext context) {
    return <Widget>[
      Form(
        child: Column(
          children: _inputFields(context),
        ),
      ),
      Row(
        children: _inputButtons(context),
      ),
    ];
  }

  List<Widget> _inputButtons(BuildContext context) {
    return <Widget>[
      _action(context, 'SIGNIN'),
      const SizedBox(
        width: 16,
      ),
      const SizedBox(
        width: 16,
      ),
      _cancel(context)
    ];
  }

  List<Widget> _inputFields(BuildContext context) {
    return <Widget>[
      _codeField(),
      const SizedBox(height: 16),
      _submitButton(),
    ];
  }

  TextFormField _codeField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Authorization Code',
        border: OutlineInputBorder(),
      ),
      controller: codeController,
    );
  }

  ElevatedButton _submitButton() {
    return ElevatedButton(
      onPressed: () async {
        await _exchangeCodeForToken();
      },
      child: const Text('SUBMIT CODE'),
    );
  }

  Future<void> _launchAuthorizationUrl() async {
    final scopes = [
      'spark:people_read',
      'spark:people_write',
      'spark:rooms_write',
      'spark:messages_read',
      'spark-compliance:rooms_read',
      'spark-compliance:team_memberships_write',
      'spark:kms',
      'spark:rooms_read',
      'spark-admin:messages_read',
      'spark:messages_write',
      'spark-compliance:teams_read',
      'spark:teams_read',
      'spark-compliance:messages_read',
    ];
    _pkcePair = webexApis.generatePKCEPair();
    await settingsDatabase?.put('code_verifier', _pkcePair!.codeVerifier);
    await webexApis.launchAuthorizationUrl(
      redirectUri: Constants().redirectUri,
      state: 'set_state_here',
      scopes: scopes,
      codeChallenge: _pkcePair!.codeChallenge,
    );
  }

  Future<void> _exchangeCodeForToken() async {
    try {
      final codeVerifier = await settingsDatabase?.get('code_verifier');
      debugPrint("codeVerifier from db: $codeVerifier");
      final newToken = await webexApis.exchangeCodeForToken(
        code: codeController.text,
        redirectUri: Constants().redirectUri,
        codeVerifier: codeVerifier,
      );

      token = newToken;
      accessToken = newToken.accessToken;
      if (token != null) {
        await settingsDatabase?.put(Constants().tokenSettingsKey, token!.toJson());
      }

      final newWebexApis = WebexApis(
          token: token,
          clientId: dotenv.env['CLIENT_ID'],
          clientSecret: dotenv.env['CLIENT_SECRET'],
          onTokenRefreshed: (newToken) async {
            token = newToken;
            accessToken = newToken.accessToken;
            if (token != null) {
              await settingsDatabase?.put(
                  Constants().tokenSettingsKey, token!.toJson());
            }
          });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AppShell(webexApis: newWebexApis),
        ),
      );
    } catch (e) {
      // Handle error
      debugPrint('Error exchanging code for token: $e');
    }
  }
}
