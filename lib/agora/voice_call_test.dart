import 'package:dokandar/agora/call_manager.dart';
import 'package:dokandar/agora/incoming_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final CallManager callManager = Get.find<CallManager>();

class VoiceCallTest extends StatelessWidget {
  const VoiceCallTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () async {
              Get.to(IncomingCallScreen(
                  channel: 'channel',
                  token: 'token',
                  callerName: 'callerName',
                  callerImage: 'callerImage'));
              // callManager.startCall(
              //   11,
              //   'Jobayed Sumon',
              //   'https://placehold.co/100x100/white/red/png?text=JS',
              // );
            },
            child: const Text('Call Jobayed Sumon (11)'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              callManager.startCall(
                4142,
                'Sumon Jobayed',
                'https://placehold.co/100x100/white/red/png?text=SJ',
              );
            },
            child: const Text('Call Sumon Jobayed (4142)'),
          ),
        ],
      ),
    );
  }
}
