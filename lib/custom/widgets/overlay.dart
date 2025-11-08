import 'package:flutter/material.dart';
import 'package:webexlite/init.dart';
import 'package:provider/provider.dart';
import 'package:webexapis/webexapis.dart';
import 'package:packer/widgets/snack_bar.dart';
import 'package:packer/widgets/alert_dialog.dart';
import '../../core/constants/constants.dart';
import 'package:hive_ce/hive.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';

OverlayEntry? _overlayEntry;
OverlayEntry? _sendMessagesOverlayEntry;

void _closeOverlay(BuildContext context) {
  logger?.log('closing overlay', source: 'OverlayWidget');
  _overlayEntry?.remove();
  _overlayEntry = null;
}

void openOverlay(BuildContext context, List<String> urls,
    {int initialIndex = 0}) async {
  if (_overlayEntry != null) return;

  _overlayEntry = OverlayEntry(builder: (context) {
    return ImageOverlayContent(
      urls: urls,
      initialIndex: initialIndex,
      accessToken: accessToken!, // Assuming accessToken is always available
      onClose: () => _closeOverlay(context),
    );
  });

  Overlay.of(context).insert(_overlayEntry!);
  WidgetsBinding.instance.addPostFrameCallback((_) {});
}

class ImageOverlayContent extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  final String accessToken;
  final VoidCallback onClose;

  const ImageOverlayContent({
    super.key,
    required this.urls,
    this.initialIndex = 0,
    required this.accessToken,
    required this.onClose,
  });

  @override
  State<ImageOverlayContent> createState() => _ImageOverlayContentState();
}

class _ImageOverlayContentState extends State<ImageOverlayContent> {
  late PageController _pageController;
  late Box _imageBox;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _imageBox = Hive.box('webexlite');
  }

  Future<Uint8List?> _getImageData(String url) async {
    if (_imageBox.containsKey(url)) {
      return _imageBox.get(url) as Uint8List?;
    }

    try {
      final dio = Dio();
      final response = await dio.get(
        url,
        options: Options(
          headers: {"Authorization": "Bearer ${widget.accessToken}"},
          responseType: ResponseType.bytes,
        ),
      );
      if (response.statusCode == 200) {
        final imageData = Uint8List.fromList(response.data);
        await _imageBox.put(url, imageData);
        return imageData;
      }
    } catch (e) {
      logger?.error('Error fetching image from $url: $e', source: 'OverlayWidget');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Actions(
          actions: {
            DismissIntent: CallbackAction<DismissIntent>(onInvoke: (i) {
              widget.onClose();
              return null;
            }),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onClose,
            child: Center(
              child: GestureDetector(
                onTap: () {}, // prevent close when tapping inside
                child: Container(
                  width: 620,
                  height: 320, // Fixed height for the image container
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: widget.urls.length,
                        itemBuilder: (context, index) {
                          final imageUrl = widget.urls[index];
                          return FutureBuilder<Uint8List?>(
                            future: _getImageData(imageUrl),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.hasData) {
                                return Image.memory(snapshot.data!);
                              } else if (snapshot.hasError) {
                                return const Center(
                                    child: Text('Error loading image'));
                              }
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

void openSendMessagesOverlay(BuildContext context, String roomId) async {
  if (_sendMessagesOverlayEntry != null) return;

  _sendMessagesOverlayEntry = OverlayEntry(builder: (context) {
    return SendMessagesOverlay(roomId: roomId);
  });

  Overlay.of(context).insert(_sendMessagesOverlayEntry!);
  WidgetsBinding.instance.addPostFrameCallback((_) {});
}

void _closeSendMessagesOverlay() {
          logger?.log('closing send messages overlay', source: 'OverlayWidget');  _sendMessagesOverlayEntry?.remove();
  _sendMessagesOverlayEntry = null;
}

class SendMessagesOverlay extends StatefulWidget {
  final String roomId;
  const SendMessagesOverlay({super.key, required this.roomId});

  @override
  State<SendMessagesOverlay> createState() => _SendMessagesOverlayState();
}

class _SendMessagesOverlayState extends State<SendMessagesOverlay> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController messageContentController =
      TextEditingController();
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
      final room =
          rooms.firstWhere((r) => r['id'] == widget.roomId, orElse: () => null);
      if (room != null) {
        setState(() {
          _roomDisplayName = room['displayName'];
      
        });
      }
    } catch (e) {
      logger?.log('Error fetching room details: $e', source: 'OverlayWidget');
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
        content:
            'Message sent successfully to room ${_roomDisplayName ?? ''}',
      ).show();
      messageContentController.text = ''; // Clear field after sending
      _closeSendMessagesOverlay();
    } on Exception catch (e) {
      logger?.log(e.toString(), source: 'OverlayWidget');
      PackerSnackBar(content: 'Failed to send message').show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: GestureDetector(
          onTap: () => _closeSendMessagesOverlay(),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // prevent close when tapping inside
              child: Container(
                width: 620,
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Send Message to ${_roomDisplayName ?? ''}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: messageContentController,
                            decoration: const InputDecoration(
                              labelText: 'Message',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: null,
                            validator: (value) => value!.isEmpty
                                ? 'Message cannot be empty'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _closeSendMessagesOverlay();
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: sendMessage,
                                child: const Text('Send'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    messageContentController.dispose();
    super.dispose();
  }
}

