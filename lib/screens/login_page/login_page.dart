import 'package:flutter/material.dart';
import 'package:packer/widgets/snack_bar.dart';

import '../../core/constants/constants.dart';

// INFO : Login feature requires API key to be stored in the code.
// As of 2025 flutter doesnt have a secure way to store obfuscated API keys.
// Thus, [LoginPage] would not be helpful for Flutter Web.

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (false) {
      _showFirstLoginMessageSnackBar();
    }
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
          false
              ? await _saveSignupCredentials()
              : await _verifySigninCredentials();
        },
        child: Text(text));
  }

  ElevatedButton _cancel(BuildContext context) {
    return ElevatedButton(
      child: const Text('CLEAR'),
      onPressed: () async {
        usernameController.text = passwordController.text = '';
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
      // TODO : Backend needs to have roboust logic for signup, thus disabling for now
      false ? _action(context, 'SIGNUP') : _action(context, 'SIGNIN'),
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
      _usernameField(),
      const SizedBox(height: 16),
      _passwordField(),
      const SizedBox(height: 16),
    ];
  }

  TextFormField _passwordField() {
    return TextFormField(
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
      ),
      controller: passwordController,
      validator: (String? text) =>
          text!.isEmpty ? 'Password must not be empty' : null,
    );
  }

  Future<dynamic> _saveSignupCredentials() async {
    // WARN : See above todo comment
    return;
  }

  Future<void> _showFirstLoginMessageSnackBar() async {
    await showSnackbar('First login');
  }

  TextFormField _usernameField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Username',
        border: OutlineInputBorder(),
      ),
      controller: usernameController,
      validator: (String? text) =>
          text!.isEmpty ? 'Username must not be empty' : null,
    );
  }

  Future<dynamic> _verifySigninCredentials() async {
    // WARN: See above todo comment
    return;
  }
}
