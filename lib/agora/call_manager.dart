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

  VoidCallback? onCallConnected;

  void setOnCallConnected(VoidCallback callback) {
    onCallConnected = callback;
  }

  void clearCallbacks() {
    onCallConnected = null;
  }

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
          debugPrint(
              "AGORA: Local user ${connection.localUid} joined ${connection.channelId}");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint(
              "AGORA: Remote user $remoteUid joined ${connection.channelId}");
          onCallConnected?.call();
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint(
              "AGORA: Remote user $remoteUid left ${connection.channelId}");
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint(
              "AGORA: Local user ${connection.localUid} left ${connection.channelId}");
        },
        onError: (ErrorCodeType errorCodeType, String errorMessage) {
          debugPrint("AGORA: Error $errorCodeType: $errorMessage");
        },
      ),
    );
  }

  void _initializeFirebase() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleIncomingCallAndCallEnded(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleIncomingCallAndCallEnded(message);
    });
    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      _handleIncomingCallAndCallEnded(message);
    });
  }

  void _handleIncomingCallAndCallEnded(RemoteMessage message) {
    if (message.data['type'] == 'incoming_call') {
      Get.to(
        () => IncomingCallScreen(
          callerId: int.parse(message.data['callerId']),
          callerType: message.data['callerType'],
          channel: message.data['channel'],
          callerName: message.data['callerName'],
          callerImage: message.data['callerImage'],
        ),
      );
    }
    if (message.data['type'] == 'call_ended') {
      endCall();
    }
  }

  /// Pass the channel to generate a unique token for the logged in user
  String _generateToken(String channel) {
    return RtcTokenBuilder.build(
      appId: _appId,
      appCertificate: _appCertificate,
      channelName: channel,
      uid: _loggedInUser.id.toString(),
      role: RtcRole.publisher,
      expireTimestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600,
    );
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
    String calleeType,
    String channel,
    String token,
  ) async {
    final payload = {
      'userId': calleeId,
      'userType': calleeType,
      'title': 'Incoming Call',
      'body': 'You have an incoming call',
      'data': {
        'type': 'incoming_call',
        'channel': channel,
        'callerId': _loggedInUser.id.toString(),
        'callerType': 'customer',
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
    String calleeType,
    String calleeName,
    String calleeImage,
  ) async {
    // Navigate to the voice call screen
    Get.to(
      () => VoiceCallScreen(
        userId: calleeId,
        userType: calleeType,
        name: calleeName,
        image: calleeImage,
      ),
    );
    // Generate a unique channel name (callerId_calleeId_timestamp) and token
    final int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final String channel = '${_loggedInUser.id}_${calleeId}_$currentTimestamp';
    final String token = _generateToken(channel);
    // Join a channel
    await _joinChannel(channel, token, _loggedInUser.id!);
    // Send the channel name and agora token to the remote user
    _sendIncomingCallNotification(calleeId, calleeType, channel, token);
  }

  // Answers an incoming call
  Future<void> answerCall(
    int callerId,
    String channel,
    String callerName,
    String callerImage,
  ) async {
    final String token = _generateToken(channel);
    // Join the channel
    await _joinChannel(channel, token, _loggedInUser.id!);
    // Navigate to the voice call screen
    Get.off(
      () => VoiceCallScreen(
        userId: callerId,
        userType: 'customer',
        name: callerName,
        image: callerImage,
      ),
    );
  }

  // Ends the call
  Future<void> endCall({int? userId, String? userType}) async {
    await _engine.leaveChannel();
    await _engine.release();
    _initializeAgora();
    Get.back();

    if (userId != null && userType != null) {
      // Send a notification to the other user that the call has ended
      await _sendCallEndedNotification(userId, userType);
    }
  }

  Future<void> _sendCallEndedNotification(int userId, String userType) async {
    final payload = {
      'userId': userId,
      'userType': userType,
      'title': 'Call Ended',
      'body': 'The call has ended',
      'data': {
        'type': 'call_ended',
      },
    };
    await _apiClient.postData(AppConstants.pushNotificationUri, payload);
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
