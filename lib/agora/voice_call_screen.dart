import 'package:flutter/material.dart';

import 'call_manager.dart';

// Voice call Screen Widget
class VoiceCallScreen extends StatefulWidget {
  const VoiceCallScreen({Key? key}) : super(key: key);

  @override
  VoiceCallScreenScreenState createState() => VoiceCallScreenScreenState();
}

class VoiceCallScreenScreenState extends State<VoiceCallScreen> {
  CallManager callManager = CallManager();

  @override
  void initState() {
    super.initState();
    callManager.initializeVoiceCalling();
  }

  @override
  void dispose() {
    callManager.cleanupAgoraEngine();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            await callManager.startVoiceCalling(11);
          },
          child: const Text('Call 11'),
        ),
        ElevatedButton(
          onPressed: () async {
            await callManager.startVoiceCalling(4142);
          },
          child: const Text('Call 4142'),
        ),
      ],
    ));
  }
}
