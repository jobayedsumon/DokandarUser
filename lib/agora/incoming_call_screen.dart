import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:dokandar/agora/call_manager.dart';
import 'package:dokandar/agora/call_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class IncomingCallScreen extends StatefulWidget {
  final int callerId;
  final String callerType;
  final String channel;
  final String callerName;
  final String callerImage;

  const IncomingCallScreen({
    super.key,
    required this.callerId,
    required this.callerType,
    required this.channel,
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
  Timer? _callTimeout;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _playTone();
    _startTimeout();
  }

  void _playTone() async {
    _audioPlayer = await _audioCache.loop('notification.wav');
  }

  void _startTimeout() {
    _callTimeout = Timer(const Duration(seconds: 30), () {
      // Auto reject the call after 30 seconds
      callManager.endCall();
      _audioPlayer.stop();
    });
  }

  void _cancelTimeout() {
    _callTimeout?.cancel();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _audioPlayer.stop();
    _cancelTimeout();
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
                      onTap: () {
                        _cancelTimeout();
                        _audioPlayer.stop();
                        callManager.endCall(
                            userId: widget.callerId,
                            userType: widget.callerType);
                      },
                    ),
                    CallControlButton(
                      icon: Icons.call,
                      color: Colors.white,
                      background: Colors.green,
                      onTap: () {
                        _cancelTimeout();
                        _audioPlayer.stop();
                        callManager.answerCall(
                          widget.channel,
                          widget.callerId,
                          widget.callerType,
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
