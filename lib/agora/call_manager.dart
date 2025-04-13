import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_token_service/agora_token_service.dart';
import 'package:dokandar/agora/incoming_call_screen.dart';
import 'package:dokandar/agora/voice_call_screen.dart';
import 'package:dokandar/data/model/response/userinfo_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/api/api_client.dart';
import '../util/app_constants.dart';

class CallManager {
  static const _appId = "003181bf5feb444897c5df04ec513194";
  static const _appCertificate = 'db8fb2e6f78c4271a6b7131f53b655df';

  late RtcEngine _engine;

  final ApiClient _apiClient = Get.find<ApiClient>();

  final UserInfoModel _loggedInUser;

  CallManager(this._loggedInUser) {
    // Initialize Agora
    _initializeAgora();
    // Initialize Firebase Messaging
    _initializeFirebase();
  }

  // Initializes Agora
  Future<void> _initializeAgora() async {
    await _requestPermissions();
    await _initializeAgoraVoiceSDK();
    _setupEventHandlers();
  }

  // Requests microphone permission
  Future<void> _requestPermissions() async {
    await [Permission.microphone].request();
  }

  // Set up the Agora RTC _engine instance
  Future<void> _initializeAgoraVoiceSDK() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: _appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
  }

  // Register an event handler for Agora RTC
  void _setupEventHandlers() {
    _engine.registerEventHandler(
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
          endCall();
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint("AGORA: Local user ${connection.localUid} left");
          endCall();
        },
        onError: (ErrorCodeType errorCodeType, String errorMessage) {
          debugPrint("AGORA: Error $errorCodeType: $errorMessage");
        },
      ),
    );
  }

  void _initializeFirebase() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleIncomingCall(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleIncomingCall(message);
    });
    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      _handleIncomingCall(message);
    });
  }

  void _handleIncomingCall(RemoteMessage message) {
    if (message.data['type'] == 'incoming_call') {
      Get.to(
        () => IncomingCallScreen(
          channel: message.data['channel'],
          token: message.data['token'],
          callerName: message.data['callerName'],
          callerImage: message.data['callerImage'],
        ),
      );
    }
  }

  /// Pass the calleeId to generate a unique channel name and token
  (String, String) _generateChannelAndToken(int calleeId) {
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final channel = '${_loggedInUser.id!}_${calleeId}_$currentTimestamp';

    final token = RtcTokenBuilder.build(
      appId: _appId,
      appCertificate: _appCertificate,
      channelName: channel,
      uid: _loggedInUser.id!.toString(),
      role: RtcRole.publisher,
      expireTimestamp: currentTimestamp + 3600,
    );

    return (channel, token);
  }

  Future<void> _joinChannel(String channel, String token, int userId) async {
    await _engine.joinChannel(
      token: token,
      channelId: channel,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: userId,
    );
  }

  Future<void> _sendIncomingCallNotification(
    int calleeId,
    String channel,
    String token,
  ) async {
    final payload = {
      'userId': calleeId,
      'title': 'Incoming Call',
      'body': 'You have an incoming call',
      'data': {
        'type': 'incoming_call',
        'channel': channel,
        'token': token,
        'callerName': '${_loggedInUser.fName} ${_loggedInUser.lName}',
        'callerImage': _loggedInUser.image ??
            'https://placehold.co/100x100/white/red/png?text=${_loggedInUser.fName?[0]}+${_loggedInUser.lName?[0]}',
      },
    };
    await _apiClient.postData(AppConstants.pushNotificationUri, payload);
  }

  // Starts voice calling
  Future<void> startCall(
    int calleeId,
    String calleeName,
    String calleeImage,
  ) async {
    // Navigate to the voice call screen
    Get.to(
      () => VoiceCallScreen(
        name: calleeName,
        image: calleeImage,
      ),
    );
    // Generate a unique channel name (callerId_calleeId_timestamp) and token
    final (channel, token) = _generateChannelAndToken(calleeId);
    // Join a channel
    await _joinChannel(channel, token, _loggedInUser.id!);
    // Send the channel name and agora token to the remote user
    _sendIncomingCallNotification(calleeId, channel, token);
  }

  // Answers an incoming call
  Future<void> answerCall(
    String channel,
    String token,
    String callerName,
    String callerImage,
  ) async {
    // Join the channel
    await _joinChannel(token, channel, _loggedInUser.id!);
    // Navigate to the voice call screen
    Get.off(
      () => VoiceCallScreen(
        name: callerName,
        image: callerImage,
      ),
    );
  }

  // Ends the call
  Future<void> endCall() async {
    await _engine.leaveChannel();
    await _engine.release();
    Get.back();
  }

  // Toggles the microphone state
  Future<void> toggleMicrophone(bool mute) async {
    await _engine.muteLocalAudioStream(mute);
  }

  // Toggles the speaker state
  Future<void> toggleSpeaker(bool speakerOn) async {
    await _engine.setEnableSpeakerphone(speakerOn);
  }
}
