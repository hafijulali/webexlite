import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:packer/navigation/navigate.dart';
import 'package:pkce/pkce.dart';
import 'package:webexapis/webexapis.dart';
import 'package:packer/widgets/app_bar.dart';
import 'package:universal_html/html.dart' as html;

import 'package:webexlite/core/constants/oauth.dart';
import 'package:webexlite/core/constants/constants.dart';

import '../../init.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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

    if (kIsWeb) {
      final uri = Uri.parse(html.window.location.href);
      logger?.log("LoginPage (Web): initState - current URL: $uri");
      if (uri.queryParameters.containsKey('code')) {
        final code = uri.queryParameters['code'];
        codeController.text = code!;
        logger?.log("LoginPage (Web): Code parameter found in URL: $code");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _exchangeCodeForToken();
        });
      }
    } else {
      _initDeepLinks();
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _linkSubscription?.cancel();
    }
    super.dispose();
  }

  void _initDeepLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    });
  }

  void _handleUri(Uri uri) {
    logger?.log("LoginPage: _handleUri called with URI: $uri");
    logger?.log("LoginPage: URI scheme: ${uri.scheme}");
    logger?.log("LoginPage: URI host: ${uri.host}");
    logger?.log("LoginPage: URI port: ${uri.port}");
    logger?.log("LoginPage: URI path: ${uri.path}");
    logger?.log("LoginPage: URI query: ${uri.query}");
    logger?.log("LoginPage: URI query parameters: ${uri.queryParameters}");
    if (uri.queryParameters.containsKey('code')) {
      final code = uri.queryParameters['code'];
      codeController.text = code!;
      logger?.log("LoginPage: Code parameter found: $code");
      _exchangeCodeForToken();
    } else {
      logger?.log("LoginPage: Code parameter NOT found in URI.");
    }
  }

  @override
  Widget build(BuildContext context) {
    logger?.log("Building LoginPage");
    return Scaffold(
        appBar: PackerAppBar(
          center: const Text('Login'),
          actions: <IconButton>[
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.refresh_outlined),
            ),
          ],
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
          logger?.log("LoginPage: action pressed - $text");
          await _launchAuthorizationUrl();
        },
        child: Text(text));
  }

  ElevatedButton _cancel(BuildContext context) {
    return ElevatedButton(
      child: const Text('SKIP'),
      onPressed: () async {
        logger?.log("LoginPage: skip pressed");
        safePushNamed(context, Constants().homePageRoute);
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
    logger?.log("LoginPage: _launchAuthorizationUrl called");
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
      'meeting:schedules_write',
      'meeting:schedules_read',
    ];
    _pkcePair = webexApis.generatePKCEPair();
    await settingsDatabase?.put('code_verifier', _pkcePair!.codeVerifier);
    await webexApis.launchAuthorizationUrl(
      redirectUri: OAuthConstants.getRedirectUri(),
      state: 'set_state_here',
      scopes: scopes,
      codeChallenge: _pkcePair!.codeChallenge,
    );
  }

  Future<void> _exchangeCodeForToken() async {
    logger?.log("LoginPage: _exchangeCodeForToken called");
    try {
      final codeVerifier = await settingsDatabase?.get('code_verifier');
      logger?.log("codeVerifier from db: $codeVerifier");
      final newToken = await webexApis.exchangeCodeForToken(
        code: codeController.text,
        redirectUri: OAuthConstants.getRedirectUri(),
        codeVerifier: codeVerifier,
      );
      logger?.log("LoginPage: newToken received: $newToken");

      token = newToken;
      accessToken = newToken.accessToken;
      if (token != null) {
        logger?.log(
            "LoginPage: Saving token with key: ${Constants().tokenSettingsKey}");
        logger?.log("LoginPage: Token content to save: ${token!.toJson()}");
        await settingsDatabase?.put(
            Constants().tokenSettingsKey, token!.toJson());
        logger?.log(
            "LoginPage: Token saved to settingsDatabase. Key: ${Constants().tokenSettingsKey}, Value: ${token!.toJson()}");
      }

      if (!mounted) return;
      logger?.log("LoginPage: Navigating to HomePage.");
      safePushNamed(context, Constants().homePageRoute);
    } catch (e) {
      // Handle error
      logger?.log('Error exchanging code for token: $e');
    }
  }
}