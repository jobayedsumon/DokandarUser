import 'package:flutter/material.dart';

import 'call_manager.dart';

// Voice call Screen Widget
class VoiceCallScreen extends StatefulWidget {
  final int userId;

  const VoiceCallScreen(this.userId, {Key? key}) : super(key: key);

  @override
  VoiceCallScreenScreenState createState() => VoiceCallScreenScreenState();
}

class VoiceCallScreenScreenState extends State<VoiceCallScreen> {
  CallManager callManager = CallManager();

  @override
  void initState() {
    super.initState();
    callManager.initialize(widget.userId);
  }

  @override
  void dispose() {
    callManager.cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            await callManager.startCall(11);
          },
          child: const Text('Call 11'),
        ),
        ElevatedButton(
          onPressed: () async {
            await callManager.startCall(4142);
          },
          child: const Text('Call 4142'),
        ),
      ],
    ));
  }
}
