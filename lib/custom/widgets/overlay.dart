import 'package:flutter/material.dart';
import 'package:webexlite/init.dart';

OverlayEntry? _overlayEntry;

void openOverlay(BuildContext context, String url) async {
  if (_overlayEntry != null) return;

  _overlayEntry = OverlayEntry(builder: (context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Actions(
          actions: {
            DismissIntent: CallbackAction<DismissIntent>(onInvoke: (i) {
              _closeOverlay(context);
              return null;
            }),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _closeOverlay(context),
            child: Center(
              child: GestureDetector(
                onTap: () {}, // prevent close when tapping inside
                child: Container(
                  width: 620,
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: StatefulBuilder(
                        builder: (context, localSetState) {
                          debugPrint("accessToken: $accessToken");
                          return SizedBox(
                            height: 320,
                            child: Image.network(url, headers: {
                              "Authorization": "Bearer $accessToken"
                            }),
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
  });

  Overlay.of(context).insert(_overlayEntry!);
  WidgetsBinding.instance.addPostFrameCallback((_) {});
}

void _closeOverlay(BuildContext context) {
  debugPrint('closing overlay');
  _overlayEntry = null;
  Overlay.of(context).dispose();
}
