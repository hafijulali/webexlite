import 'package:flutter/material.dart';


import 'package:packer/widgets/alert_dialog.dart';
import 'package:packer/widgets/snack_bar.dart';
import 'package:webexapis/webexapis.dart';
import 'package:provider/provider.dart';
import 'package:packer/widgets/app_bar.dart';

import '/init.dart';
import '../../core/constants/constants.dart';

class SendMessagesPage extends StatefulWidget {
  final String roomId;
  const SendMessagesPage({super.key, required this.roomId});

  @override
  State<SendMessagesPage> createState() => _SendMessagesPageState();
}

class _SendMessagesPageState extends State<SendMessagesPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController messageContentController = TextEditingController();

  bool isFormDirty = false;
  String? _roomDisplayName;

  @override
  void initState() {
    super.initState();
    _fetchRoomDetails();
  }

  Future<void> _fetchRoomDetails() async {
    try {
      final webexApis = context.read<WebexApis>();
      final roomsData = await webexApis.getRooms();
      final rooms = roomsData['items'] as List<dynamic>;
      final room = rooms.firstWhere((r) => r['id'] == widget.roomId, orElse: () => null);
      if (room != null) {
        setState(() {
          _roomDisplayName = room['displayName'];
        });
      }
    } catch (e) {
      logger?.debug('Error fetching room details: $e');
      // Optionally show an error message to the user
    }
  }

  void sendMessage() async {
    if (!_formKey.currentState!.validate()) {
      showAlertDialog(context, Constants().failure, 'Invalid form details');
      return;
    }
    _formKey.currentState!.save();

    try {
      final webexApis = context.read<WebexApis>();

      await webexApis.postMessage({
        'roomId': widget.roomId,
        'text': messageContentController.text,
      });

      PackerSnackBar(
        content: 'Message sent successfully to room ${_roomDisplayName ?? ''}',
      ).show();
      clearAllFields();
    } on Exception catch (e) {
                                logger?.error(e.toString());      PackerSnackBar(content: 'Failed to send message').show();
    }
  }

  Widget addForm(BuildContext context) {
    return Scaffold(
      appBar: PackerAppBar(
        center: Text(_roomDisplayName ?? 'Send Message'),
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(children: _formElements(context)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // currentPath = Constants().addAppsPageRoute; // Removed as it's not relevant for SendMessagesPage
    return addForm(context);
  }

  void clearAllFields() {
    setState(() {
      messageContentController.text = '';
      isFormDirty = false;
    });
  }

  Future<bool> confirmDiscard() async {
    final String? response = await showAlertDialog(
      context,
      'Confirm',
      'Are you sure to discard the form data?',
    );
    if (response == Constants().ok) {
      showSnackbar('Form data discarded');
      clearAllFields();
      setState(() => isFormDirty = false);
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }


  Widget _add(BuildContext context, String text) {
    return ElevatedButton(onPressed: sendMessage, child: Text(text));
  }

  ElevatedButton _cancel(BuildContext context) {
    return ElevatedButton(
      child: Text(Constants().cancel),
      onPressed: () async {
        if (isFormDirty == true) {
          confirmDiscard();
        }
      },
    );
  }

  TextFormField _messageContentField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Message Content',
        border: OutlineInputBorder(),
      ),
      controller: messageContentController,
      keyboardType: TextInputType.multiline,
      maxLines: null, // Allow unlimited lines
      validator: (String? text) =>
          text!.isEmpty ? 'Message content cannot be empty' : null,
    );
  }



  List<Widget> _formElements(BuildContext context) {
    return <Widget>[
      Form(
        key: _formKey,
        onChanged: () => setState(() => isFormDirty = true),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _messageContentField(),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                _add(context, 'Send'),
                const SizedBox(width: 16),
                _cancel(context),
              ],
            ),
          ],
        ),
      ),
    ];
  }

}