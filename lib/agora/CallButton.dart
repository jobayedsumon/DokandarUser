import 'package:dokandar/agora/call_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final CallManager callManager = Get.find<CallManager>();

class CallButton extends StatelessWidget {
  final int userId;
  final String userType;
  final String name;
  final String image;

  const CallButton({
    super.key,
    required this.userId,
    required this.userType,
    required this.name,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        callManager.startCall(
          userId,
          userType,
          name,
          image,
        );
      },
      child: Icon(Icons.phone, color: Theme.of(context).primaryColor, size: 20),
    );
  }
}
