import 'package:flutter/material.dart';
import 'package:packer/logging/file_logger.dart';
import 'package:packer/widgets/log_view.dart';

class LogViewerPage extends StatelessWidget {
  final FileLogger fileLogger;

  const LogViewerPage({super.key, required this.fileLogger});

  @override
  Widget build(BuildContext context) {
    return PackerLogView(fileLogger: fileLogger);
  }
}
