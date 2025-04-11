import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_token_service/agora_token_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CallManager {
  static const appId = "003181bf5feb444897c5df04ec513194";
  static const appCertificate = 'db8fb2e6f78c4271a6b7131f53b655df';

  late RtcEngine engine;
  int localUid = 0;

  // Initializes Agora SDK
  Future<void> initialize(int userId) async {
    await _requestPermissions();
    await _initializeAgoraVoiceSDK();
    _setupEventHandlers();
    localUid = userId;
  }

  // Starts voice calling
  Future<void> startCall(int remoteUid) async {
    // Generate a unique channel name and token
    final (channel, token) = _generateChannelAndToken(remoteUid);
    // Join a channel
    await engine.joinChannel(
      token: token,
      channelId: channel,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: localUid,
    );
  }

  // Leaves the channel and releases resources
  Future<void> cleanup() async {
    await engine.leaveChannel();
    await engine.release();
  }

  // Requests microphone permission
  Future<void> _requestPermissions() async {
    await [Permission.microphone].request();
  }

  // Set up the Agora RTC engine instance
  Future<void> _initializeAgoraVoiceSDK() async {
    engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
  }

  // Register an event handler for Agora RTC
  void _setupEventHandlers() {
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

  (String, String) _generateChannelAndToken(int remoteUid) {
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final channel = '${localUid}_${remoteUid}_$currentTimestamp';
    // final channel = 'dokandar';

    final token = RtcTokenBuilder.build(
      appId: appId,
      appCertificate: appCertificate,
      channelName: channel,
      uid: localUid.toString(),
      role: RtcRole.publisher,
      expireTimestamp: currentTimestamp + 3600,
    );

    return (channel, token);
  }
}
