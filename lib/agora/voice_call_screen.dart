import 'package:dokandar/agora/CallControlButton.dart';
import 'package:dokandar/agora/call_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class VoiceCallScreen extends StatefulWidget {
  final String name;
  final String image;

  const VoiceCallScreen({
    super.key,
    required this.name,
    required this.image,
  });

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  bool isMuted = false;
  bool isSpeakerOn = false;
  final CallManager callManager = Get.find<CallManager>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    callManager.endCall();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
    });
    callManager.toggleMicrophone(isMuted);
  }

  void _toggleSpeaker() {
    setState(() {
      isSpeakerOn = !isSpeakerOn;
    });
    callManager.toggleSpeaker(isSpeakerOn);
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
                backgroundImage: NetworkImage(widget.image),
              ),
              const SizedBox(height: 24),
              Text(
                widget.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Calling...",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CallControlButton(
                      icon: isMuted ? Icons.mic_off : Icons.mic,
                      color: isMuted ? Colors.red : Colors.white,
                      background: const Color(0xFF2C2C2E),
                      onTap: _toggleMute,
                    ),
                    CallControlButton(
                      icon: Icons.call_end,
                      color: Colors.red,
                      background: Colors.white,
                      onTap: callManager.endCall,
                    ),
                    CallControlButton(
                      icon: isSpeakerOn ? Icons.volume_up : Icons.hearing,
                      color: isSpeakerOn ? Colors.green : Colors.white,
                      background: const Color(0xFF2C2C2E),
                      onTap: _toggleSpeaker,
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
