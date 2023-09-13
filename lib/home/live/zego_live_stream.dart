import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import 'constants.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({
    Key? key,
    required this.liveID,
    this.isHost = false,
    required this.userID,
    required this.userName,
    required this.config,
  }) : super(key: key);

  final String liveID;
  final bool isHost;
  final String userID;
  final String userName;
  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltLiveStreaming(
        appID: Constants.appId,
        appSign: Constants.appSign,
        userID: widget.userID,
        userName: widget.userName,
        liveID: widget.liveID,
        config: widget.config,

        // : ZegoUIKitPrebuiltLiveStreamingConfig.audience(),
      ),
    );
  }
}
