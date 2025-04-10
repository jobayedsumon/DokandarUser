import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CallManager {
  // Fill in the app ID obtained from Agora Console
  static const appId = "003181bf5feb444897c5df04ec513194";

  // Fill in the temporary token generated from Agora Console
  static const token =
      "007eJxTYJij4RK1WVRm9YU18o4BPKKbC8rveX6wnpTu/KJKYOuBLf0KDAYGxoYWhklppmmpSSYmJhaW5smmKWkGJqnJpobGhpYmmi4/0hsCGRkY5EVYGRkgEMTnYEjJz07MS0ksYmAAACRyHik=";

  // Fill in the channel name you used to generate the token
  static const channel = "dokandar";

  // Stores Agora RTC Engine instance
  late RtcEngine engine;

  // Initializes Agora SDK
  Future<void> initializeVoiceCalling() async {
    await requestPermissions();
    await initializeAgoraVoiceSDK();
    setupEventHandlers();
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

  // Starts voice calling
  Future<void> startVoiceCalling(int uid) async {
    // Join a channel
    await engine.joinChannel(
      token: token,
      channelId: channel,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: uid,
    );
  }

  // Leaves the channel and releases resources
  Future<void> cleanupAgoraEngine() async {
    await engine.leaveChannel();
    await engine.release();
  }

  // Register an event handler for Agora RTC
  void setupEventHandlers() {
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("AGORA: Local user ${connection.localUid} joined");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("AGORA: Remote user $remoteUid joined");
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("AGORA: Remote user $remoteUid left");
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint("AGORA: Local user ${connection.localUid} left");
        },
        onError: (ErrorCodeType errorCodeType, String errorMessage) {
          debugPrint("AGORA: Error $errorCodeType: $errorMessage");
        },
      ),
    );
  }
}
