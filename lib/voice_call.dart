import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// Fill in the app ID obtained from Agora Console
const appId = "003181bf5feb444897c5df04ec513194";
// Fill in the temporary token generated from Agora Console
const token = "007eJxTYAh+s+mpg9XFN6f6/vLdM7mZlxNcZPTM2GE631nmE6cWBvQpMBgYGBtaGCalmaalJpmYmFhYmiebpqQZmKQmmxoaG1qazDj8Ob0hkJHh86uXDIxQCOJzMKTkZyfmpSQWMTAAAIebJBs=";
// Fill in the channel name you used to generate the token
const channel = "dokandar";

// Voice call Screen Widget
class VoiceCallScreen extends StatefulWidget {
  const VoiceCallScreen({Key? key}) : super(key: key);

  @override
  VoiceCallScreenScreenState createState() => VoiceCallScreenScreenState();
}

class VoiceCallScreenScreenState extends State<VoiceCallScreen> {
  late RtcEngine engine; // Stores Agora RTC Engine instance
  int? remoteUid; // Stores the remote user's UID

  @override
  void initState() {
    super.initState();
    startVoiceCalling();
  }

  // Initializes Agora SDK
  Future<void> startVoiceCalling() async {
    await requestPermissions();
    await initializeAgoraVoiceSDK();
    setupEventHandlers();
    await joinChannel();
  }

  // Requests microphone permission
  Future<void> requestPermissions() async {
    await [Permission.microphone].request();
  }

  // Set up the Agora RTC engine instance
  Future<void> initializeAgoraVoiceSDK() async {
    engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
  }

  // Register an event handler for Agora RTC
  void setupEventHandlers() {
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user ${connection.localUid} joined");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined");
          setState(() {
            remoteUid = remoteUid; // Store remote user ID
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("Remote user $remoteUid left");
          setState(() {
            remoteUid = 0; // Remove remote user ID
          });
        },
      ),
    );
  }

  // Join a channel
  Future<void> joinChannel() async {
    await engine.joinChannel(
      token: token,
      channelId: channel,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: 0,
    );
  }

  @override
  void dispose() {
    cleanupAgoraEngine();
    super.dispose();
  }

  // Leaves the channel and releases resources
  Future<void> cleanupAgoraEngine() async {
    await engine.leaveChannel();
    await engine.release();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agora Voice Call',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Agora Voice Call'),
        ),
        body: Center(
          child: Text(
            remoteUid != null
                ? "Remote user $remoteUid joined"
                : "No remote user in the channel", // Show appropriate message
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}