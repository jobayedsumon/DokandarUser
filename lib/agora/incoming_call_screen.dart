import 'package:audioplayers/audioplayers.dart';
import 'package:dokandar/agora/CallControlButton.dart';
import 'package:dokandar/agora/call_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class IncomingCallScreen extends StatefulWidget {
  final String channel;
  final String token;
  final String callerName;
  final String callerImage;

  const IncomingCallScreen({
    super.key,
    required this.channel,
    required this.token,
    required this.callerName,
    required this.callerImage,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  final CallManager callManager = Get.find<CallManager>();
  final AudioCache _audioCache = AudioCache(prefix: 'assets/');
  late AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    () async {
      _audioPlayer = await _audioCache.loop('notification.wav');
    }();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 60),
              CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage(widget.callerImage),
              ),
              const SizedBox(height: 24),
              Text(
                widget.callerName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Incoming Call...",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CallControlButton(
                      icon: Icons.call_end,
                      color: Colors.red,
                      background: Colors.white,
                      onTap: callManager.endCall,
                    ),
                    CallControlButton(
                      icon: Icons.call,
                      color: Colors.white,
                      background: Colors.green,
                      onTap: () {
                        callManager.answerCall(
                          widget.channel,
                          widget.token,
                          widget.callerName,
                          widget.callerImage,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
