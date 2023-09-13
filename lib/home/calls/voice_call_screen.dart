import 'dart:async';
<<<<<<< HEAD
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
=======

import 'package:agora_rtc_engine/rtc_engine.dart';
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
<<<<<<< HEAD
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
=======
import 'package:permission'
    '_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
import 'package:teego/app/navigation_service.dart';
import 'package:teego/helpers/quick_actions.dart';
import 'package:teego/helpers/quick_cloud.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/home/home_screen.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/providers/calls_providers.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';
<<<<<<< HEAD
=======
import 'package:stop_watch_timer/stop_watch_timer.dart';
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
import 'package:wakelock/wakelock.dart';

import '../../app/setup.dart';
import '../../helpers/send_notifications.dart';
import '../../models/CallsModel.dart';
import '../../models/MessageListModel.dart';
import '../../models/MessageModel.dart';
<<<<<<< HEAD
=======
import '../../utils/shared_manager.dart';
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
import '../coins/coins_payment_widget.dart';

// ignore: must_be_immutable
class VoiceCallScreen extends StatefulWidget {
<<<<<<< HEAD
=======

>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
  static const String route = '/call/voice';

  UserModel? currentUser, mUser;
  bool? isCaller;

  String? channel;
  SharedPreferences? preferences;

<<<<<<< HEAD
  VoiceCallScreen(
      {Key? key,
      this.currentUser,
      this.mUser,
      this.channel,
      this.isCaller,
      required this.preferences})
      : super(key: key);
=======
  VoiceCallScreen({Key? key, this.currentUser, this.mUser, this.channel, this.isCaller, required this.preferences}) : super(key: key);
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<VoiceCallScreen> {
  RtcEngine? _engine;
  Timer? callPaymentTimer;
  int coinsUsed = 0;
  String callDuration = "00:00";
  String? credits = "0";
  String? diamonds = "0";
<<<<<<< HEAD
  StateSetter? screenState;
  LiveQuery liveQuery = LiveQuery();
=======
  StateSetter? screenState;LiveQuery liveQuery = LiveQuery();
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
  Subscription? subscription;
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();

  bool isJoined = false,
      isCallEnded = false,
      isConnected = false,
      previewAvailable = false,
      isCallAccepted = false,
      switchRender = true,
      switchAudio = false;

  List<int> remoteUid = [];

  @override
  void initState() {
    Wakelock.enable();

    QuickHelp.saveCurrentRoute(route: VoiceCallScreen.route);

    context.read<CallsProvider>().setCallRefused(false);
    context.read<CallsProvider>().setUserBusy(true);

    setState(() {
      credits = widget.currentUser!.getCredits!.toString();
      diamonds = widget.currentUser!.getDiamonds!.toString();
    });

    this._initEngine();
    super.initState();
  }

  @override
  void dispose() async {
    Wakelock.disable();

    //context.read<CallsProvider>().setUserBusy(false);
<<<<<<< HEAD

    //TODO: Destroy;
    // _engine!.destroy();
=======
    _engine!.destroy();
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081

    if (subscription != null) {
      liveQuery.client.unSubscribe(subscription!);
    }
    await _stopWatchTimer.dispose();
    callPaymentTimer?.cancel();
    super.dispose();
  }

  @override
<<<<<<< HEAD
  didChangeDependencies() {
=======
  didChangeDependencies(){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
    //context.dependOnInheritedWidgetOfExactType<ProviderInheritedWidget>();
    super.didChangeDependencies();
  }

  _initEngine() async {
<<<<<<< HEAD
    //TODO: init engine;
    // _engine = await RtcEngine.createWithContext(RtcEngineContext(
    //     SharedManager().getStreamProviderKey(widget.preferences)));
    this._addListeners();

    await _engine!.enableAudio();
    await _engine!
        .setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
=======

    _engine = await RtcEngine.createWithContext(RtcEngineContext(SharedManager().getStreamProviderKey(widget.preferences)));
    this._addListeners();

    await _engine!.enableAudio();
    await _engine!.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine!.setClientRole(ClientRole.Broadcaster);
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081

    this._joinChannel();

    startTimerToEnd();
  }

  _addListeners() {
<<<<<<< HEAD
    _engine!.registerEventHandler(
        RtcEngineEventHandler(onUserOffline: (uid, reason, type) {
      context.read<CallsProvider>().setUserBusy(false);

      endCallOffline(CallsModel.CALL_END_REASON_OFFLINE);
      //_callEnded();

      setState(() {
        isCallAccepted = false;
        previewAvailable = false;
        isCallEnded = true;
      });

      //_stopWatchTimer.onExecute.add(StopWatchExecute.stop);
      _stopWatchTimer.onStopTimer();
      remoteUid.removeWhere((element) => element == uid);
    }, onUserJoined: (connection, uid, id) {
      context.read<CallsProvider>().setUserBusy(true);

      setState(() {
        remoteUid.add(uid);
      });
    }, onLeaveChannel: (conntection, stats) {
      context.read<CallsProvider>().setUserBusy(false);

      setState(() {
        isJoined = false;
        remoteUid.clear();
      });
    }, onJoinChannelSuccess: (uid, elapsed) {
      context.read<CallsProvider>().setUserBusy(true);

      setState(() {
        isJoined = true;
      });
    }, onFirstLocalAudioFramePublished: (connection, elapsed) {
      print('AgoraVoiceCall firstLocalVoiceFrame');

      context.read<CallsProvider>().setUserBusy(true);

      setState(() {
        previewAvailable = true;
      });

      if (widget.isCaller == true) {
        context.read<CallsProvider>().callUserInvitation(
            calleeId: widget.mUser!.objectId!,
            isVideo: false,
            channel: widget.channel!);
      }
    }, onFirstRemoteAudioFrame: (connection, uId, width) {
      print('AgoraVoiceCall firstRemoteVoiceFrame');

      context.read<CallsProvider>().setUserBusy(true);

      //_stopWatchTimer.onExecute.add(StopWatchExecute.start);
      _stopWatchTimer.onStartTimer();

      if (widget.isCaller!) {
        initPaidTimer();
      }

      setState(() {
        previewAvailable = true;
        isConnected = true;
        isCallAccepted = true;
      });
    }));
  }

  startTimerToEnd() {
    Future.delayed(Duration(seconds: Setup.callWaitingDuration), () {
      if (mounted) {
        context.read<CallsProvider>().setUserBusy(false);

        if (!isConnected)
          widget.isCaller == true
              ? endCallBtnCaller(CallsModel.CALL_END_REASON_OFFLINE)
              : endCallBtnReceiver();
      }
=======
    _engine!.setEventHandler(
        RtcEngineEventHandler(joinChannelSuccess: (channel, uid, elapsed) {

          context.read<CallsProvider>().setUserBusy(true);

          setState(() {
            isJoined = true;
          });

        }, userJoined: (uid, elapsed) {

          context.read<CallsProvider>().setUserBusy(true);

          setState(() {
            remoteUid.add(uid);
          });
        }, userOffline: (uid, reason) {

          context.read<CallsProvider>().setUserBusy(false);

          endCallOffline(CallsModel.CALL_END_REASON_OFFLINE);
          //_callEnded();

          setState(() {
            isCallAccepted = false;
            previewAvailable = false;
            isCallEnded = true;
          });

          //_stopWatchTimer.onExecute.add(StopWatchExecute.stop);
          _stopWatchTimer.onStopTimer();
          remoteUid.removeWhere((element) => element == uid);
        }, leaveChannel: (stats) {

          context.read<CallsProvider>().setUserBusy(false);

          setState(() {
            isJoined = false;
            remoteUid.clear();
          });
        }, firstLocalAudioFrame: (elapsed) {
          print('AgoraVoiceCall firstLocalVoiceFrame');

          context.read<CallsProvider>().setUserBusy(true);

          setState(() {
            previewAvailable = true;
          });

          if (widget.isCaller == true) {

            context.read<CallsProvider>().callUserInvitation(
                calleeId: widget.mUser!.objectId!,
                isVideo: false,
                channel: widget.channel!);
          }
        }, firstRemoteAudioFrame: (uId, width) {
          print('AgoraVoiceCall firstRemoteVoiceFrame');

          context.read<CallsProvider>().setUserBusy(true);

          //_stopWatchTimer.onExecute.add(StopWatchExecute.start);
          _stopWatchTimer.onStartTimer();

          if(widget.isCaller!){
            initPaidTimer();
          }

          setState(() {
            previewAvailable = true;
            isConnected = true;
            isCallAccepted = true;
          });

        }));
  }

  startTimerToEnd(){

    Future.delayed(Duration(seconds: Setup.callWaitingDuration), () {

      if(mounted){

        context.read<CallsProvider>().setUserBusy(false);

        if(!isConnected) widget.isCaller == true ? endCallBtnCaller(CallsModel.CALL_END_REASON_OFFLINE) : endCallBtnReceiver();
      }

>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
    });
  }

  final stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onChange: (value) => print('onChange $value'),
    onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
    onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
  );

  _joinChannel() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();
    }
    await _engine!.joinChannel(
<<<<<<< HEAD
      channelId: widget.channel!,
      uid: widget.currentUser!.getUid!,
      options: ChannelMediaOptions(),
      token: '',
    );
=======
        null, widget.channel!, null, widget.currentUser!.getUid!);
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
  }

  _leaveChannel() async {
    await _engine!.leaveChannel();
  }

  _switchMicrophone() {
    setState(() {
      switchAudio = !switchAudio;
    });
    if (switchAudio) {
      _engine!.disableAudio();
    } else {
      _engine!.enableAudio();
    }
  }

<<<<<<< HEAD
  setupCallObserver() {
=======

  setupCallObserver(){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
    print("AgoraCall setupCallObserver called");
    bool callRefused = context.watch<CallsProvider>().isCallRefused;

    if (callRefused == true) {
      print("AgoraCall isCallRefused == true");

      //endCallRefused();
<<<<<<< HEAD
      if (mounted) {
        endCallOffline(CallsModel.CALL_END_REASON_REFUSED);
      }
    }
  }

  initPaidTimer() {
    checkCredits(firstCheck: true);

    callPaymentTimer = Timer.periodic(Duration(seconds: 60), (timer) {
      checkCredits(firstCheck: false);
    });
  }

  checkCredits({bool? firstCheck}) {
    print("callPaymentTimer checked $firstCheck");

    if (widget.currentUser!.getCredits! >=
        Setup.coinsNeededForVoiceCallPerMinute) {
      widget.currentUser!.removeCredit = Setup.coinsNeededForVoiceCallPerMinute;
      widget.currentUser!.save().then((value) {
        coinsUsed = coinsUsed + Setup.coinsNeededForVoiceCallPerMinute;
=======
      if(mounted){
        endCallOffline(CallsModel.CALL_END_REASON_REFUSED);
      }
    }

  }

  initPaidTimer(){

    checkCredits(firstCheck: true);

    callPaymentTimer = Timer.periodic(Duration(seconds: 60), (timer) {

      checkCredits(firstCheck: false);
    });

  }

  checkCredits({bool? firstCheck}){

    print("callPaymentTimer checked $firstCheck");

    if(widget.currentUser!.getCredits! >= Setup.coinsNeededForVoiceCallPerMinute){

      widget.currentUser!.removeCredit = Setup.coinsNeededForVoiceCallPerMinute;
      widget.currentUser!.save().then((value) {

        coinsUsed = coinsUsed+Setup.coinsNeededForVoiceCallPerMinute;
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081

        screenState!(() {
          credits = widget.currentUser!.getCredits.toString();
        });

<<<<<<< HEAD
        QuickCloudCode.sendGift(
            author: widget.mUser!,
            credits: Setup.coinsNeededForVoiceCallPerMinute,
            preferences: widget.preferences);
        widget.currentUser = value.results!.first! as UserModel;

        if (widget.currentUser!.getCredits! <=
            Setup.coinsNeededForVoiceCallPerMinute / 2) {
          QuickHelp.showAppNotificationAdvanced(
            title: "video_call.coins_run_out".tr(namedArgs: {
              "coins": widget.currentUser!.getCredits!.toString()
            }),
=======
        QuickCloudCode.sendGift(author: widget.mUser!, credits:  Setup.coinsNeededForVoiceCallPerMinute, preferences: widget.preferences);
        widget.currentUser = value.results!.first! as UserModel;

        if(widget.currentUser!.getCredits! <= Setup.coinsNeededForVoiceCallPerMinute /2){

          QuickHelp.showAppNotificationAdvanced(
            title: "video_call.coins_run_out".tr(namedArgs: {"coins" : widget.currentUser!.getCredits!.toString()}),
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
            message: "video_call.coins_run_out_explain".tr(),
            context: context,
            isError: true,
          );
        }
      });
<<<<<<< HEAD
    } else {
=======


    } else {

>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      QuickHelp.showAppNotificationAdvanced(
          title: "video_call.no_coins".tr(),
          message: "video_call.coins_out_explain".tr(),
          context: context,
<<<<<<< HEAD
          isError: true);
=======
          isError: true
      );
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081

      endCallBtnCaller(CallsModel.CALL_END_REASON_CREDITS);
    }
  }

  saveCallHistory({String? endReason}) async {
<<<<<<< HEAD
=======

>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
    CallsModel callsModel = CallsModel();

    callsModel.setAuthor = widget.currentUser!;
    callsModel.setAuthorId = widget.currentUser!.objectId!;

    callsModel.setReceiver = widget.mUser!;
    callsModel.setReceiverId = widget.mUser!.objectId!;

    callsModel.setAccepted = isCallAccepted;
    callsModel.setDuration = callDuration;

    callsModel.setCallEndReason = endReason!;
    callsModel.setIsVoiceCall = true;
    callsModel.setCoins = coinsUsed;

    await callsModel.save();
    saveMessage(callsModel);
<<<<<<< HEAD
  }

  saveMessage(CallsModel callsModel) async {
=======

  }

  saveMessage(CallsModel callsModel) async {

>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
    MessageModel message = MessageModel();

    message.setAuthor = widget.currentUser!;
    message.setAuthorId = widget.currentUser!.objectId!;

    message.setReceiver = widget.mUser!;
    message.setReceiverId = widget.mUser!.objectId!;

    message.setDuration = MessageModel.messageTypeCall;
    message.setIsMessageFile = false;
    message.setCall = callsModel;

    message.setMessageType = MessageModel.messageTypeCall;

    message.setIsRead = false;

    await message.save();
    _saveList(message, callsModel);

<<<<<<< HEAD
    if (!isCallAccepted) {
=======
    if(!isCallAccepted){

>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      SendNotifications.sendPush(
        widget.currentUser!,
        widget.mUser!,
        SendNotifications.typeMissedCall,
<<<<<<< HEAD
        message: "push_notifications.missed_call"
            .tr(namedArgs: {"name": widget.currentUser!.getFullName!}),
      );
    }
=======
        message: "push_notifications.missed_call".tr(namedArgs: {"name":  widget.currentUser!.getFullName!}),
      );
    }

>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
  }

  _saveList(MessageModel messageModel, CallsModel call) async {
    QueryBuilder<MessageListModel> queryFrom =
<<<<<<< HEAD
        QueryBuilder<MessageListModel>(MessageListModel());
    queryFrom.whereEqualTo(MessageListModel.keyListId,
        widget.currentUser!.objectId! + widget.mUser!.objectId!);

    QueryBuilder<MessageListModel> queryTo =
        QueryBuilder<MessageListModel>(MessageListModel());
    queryTo.whereEqualTo(MessageListModel.keyListId,
        widget.mUser!.objectId! + widget.currentUser!.objectId!);

    QueryBuilder<MessageListModel> queryBuilder =
        QueryBuilder.or(MessageListModel(), [queryFrom, queryTo]);
=======
    QueryBuilder<MessageListModel>(MessageListModel());
    queryFrom.whereEqualTo(
        MessageListModel.keyListId, widget.currentUser!.objectId! + widget.mUser!.objectId!);

    QueryBuilder<MessageListModel> queryTo =
    QueryBuilder<MessageListModel>(MessageListModel());
    queryTo.whereEqualTo(
        MessageListModel.keyListId, widget.mUser!.objectId! + widget.currentUser!.objectId!);

    QueryBuilder<MessageListModel> queryBuilder =
    QueryBuilder.or(MessageListModel(), [queryFrom, queryTo]);
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081

    ParseResponse parseResponse = await queryBuilder.query();

    if (parseResponse.success) {
      if (parseResponse.results != null) {
        MessageListModel messageListModel = parseResponse.results!.first;

        messageListModel.setAuthor = widget.currentUser!;
        messageListModel.setAuthorId = widget.currentUser!.objectId!;

        messageListModel.setReceiver = widget.mUser!;
        messageListModel.setReceiverId = widget.mUser!.objectId!;
<<<<<<< HEAD
        messageListModel.setCall = call;
=======
        messageListModel.setCall= call;
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081

        messageListModel.setMessage = messageModel;
        messageListModel.setMessageId = messageModel.objectId!;
        messageListModel.setText = messageModel.getDuration!;
        messageListModel.setIsMessageFile = false;

        messageListModel.setMessageType = messageModel.getMessageType!;

        messageListModel.setIsRead = false;
<<<<<<< HEAD
        messageListModel.setListId =
            widget.currentUser!.objectId! + widget.mUser!.objectId!;
=======
        messageListModel.setListId = widget.currentUser!.objectId! + widget.mUser!.objectId!;
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081

        messageListModel.incrementCounter = 1;
        await messageListModel.save();

        messageModel.setMessageList = messageListModel;
        messageModel.setMessageListId = messageListModel.objectId!;

        await messageModel.save();
      } else {
        MessageListModel messageListModel = MessageListModel();

        messageListModel.setAuthor = widget.currentUser!;
        messageListModel.setAuthorId = widget.currentUser!.objectId!;

        messageListModel.setReceiver = widget.mUser!;
        messageListModel.setReceiverId = widget.mUser!.objectId!;

        messageListModel.setMessage = messageModel;
        messageListModel.setCall = call;
        messageListModel.setMessageId = messageModel.objectId!;
        messageListModel.setText = messageModel.getDuration!;
        messageListModel.setIsMessageFile = false;

        messageListModel.setMessageType = messageModel.getMessageType!;

<<<<<<< HEAD
        messageListModel.setListId =
            widget.currentUser!.objectId! + widget.mUser!.objectId!;
=======
        messageListModel.setListId = widget.currentUser!.objectId! + widget.mUser!.objectId!;
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
        messageListModel.setIsRead = false;

        messageListModel.incrementCounter = 1;
        await messageListModel.save();

        messageModel.setMessageList = messageListModel;
        messageModel.setMessageListId = messageListModel.objectId!;
        await messageModel.save();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
=======

>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
    screenState = setState;
    setupCallObserver();

    setupCounterLive();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _renderVideo(),
          _topButtons(),
          _timerOnStartConversation(),
          _andOrRefuseCallButton(),
        ],
      ),
    );
  }

  _userInformation() {
    return Align(
      child: Padding(
        padding: EdgeInsets.only(top: 200),
        child: Column(
          children: [
            QuickActions.avatarWidget(widget.mUser!, width: 100, height: 100),
            TextWithTap(
              '${widget.mUser!.getFullName!}',
              textAlign: TextAlign.center,
              marginTop: 10,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            TextWithTap(
              callStatus(),
              textAlign: TextAlign.center,
              marginTop: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
=======

>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
  String callStatus() {
    if (!previewAvailable) {
      return "video_call.on_call_connecting".tr();
    } else if (previewAvailable && !isCallAccepted) {
      return "video_call.on_calling".tr();
    } else if (isCallAccepted) {
      return "video_call.on_call_connected".tr();
    } else if (isCallEnded) {
      return "video_call.call_end_no_response".tr();
    }

    return "";
  }

  _topButtons() {
    return Padding(
      padding: EdgeInsets.only(top: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ContainerCorner(
            height: 40,
            marginBottom: 10,
            marginTop: 10,
            borderRadius: 20,
            marginLeft: 10,
            color: Colors.black.withOpacity(0.5),
            onTap: widget.isCaller! ? _buyCredits : null,
            child: Row(
              children: [
                Padding(
<<<<<<< HEAD
                  padding: const EdgeInsets.only(
                      left: 10, top: 10, bottom: 10, right: 10),
                  child: SvgPicture.asset(
                    widget.isCaller!
                        ? "assets/svg/coin.svg"
                        : "assets/svg/dolar_diamond.svg",
                    height: 20,
                    width: 20,
                  ),
                ),
                SizedBox(
                    child: TextWithTap(
                  widget.isCaller! ? credits! : diamonds!,
                  color: Colors.white,
                  marginRight: 15,
                  fontSize: 17,
                )),
                Visibility(
                  visible: widget.isCaller!,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 10, bottom: 10, right: 10),
                    child: SvgPicture.asset(
                      "assets/svg/ic_coin_with_star.svg",
                      height: 24,
                      width: 24,
                    ),
=======
                  padding: const EdgeInsets.only(left: 10, top: 10,bottom: 10, right: 10),
                  child: SvgPicture.asset(widget.isCaller! ? "assets/svg/coin.svg" : "assets/svg/dolar_diamond.svg" , height: 20, width: 20,),
                ),
                SizedBox(child: TextWithTap(widget.isCaller! ? credits! : diamonds!, color: Colors.white, marginRight: 15, fontSize: 17,)),
                Visibility(
                  visible: widget.isCaller!,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10,bottom: 10, right: 10),
                    child: SvgPicture.asset("assets/svg/ic_coin_with_star.svg", height: 24, width: 24,),
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
                  ),
                ),
              ],
            ),
          ),
          ContainerCorner(
            width: 40,
            height: 40,
            marginLeft: 10,
            marginRight: 10,
            borderRadius: 50,
            color: Colors.black.withOpacity(0.7),
            child: Icon(
              switchAudio ? Icons.mic : Icons.mic_off,
              size: 30,
              color: Colors.white,
            ),
            onTap: this._switchMicrophone,
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  _buyCredits() {
=======
  _buyCredits(){

>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
    CoinsFlowPayment(
      context: context,
      currentUser: widget.currentUser!,
      showOnlyCoinsPurchase: true,
<<<<<<< HEAD
      onCoinsPurchased: (tickets) {
        print(
            "onCoinsPurchased: $tickets new: ${widget.currentUser!.getCredits}");
=======
      onCoinsPurchased: (tickets){
        print("onCoinsPurchased: $tickets new: ${widget.currentUser!.getCredits}");
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081

        setState(() {
          credits = widget.currentUser!.getCredits.toString();
        });
      },
    );
  }

  _andOrRefuseCallButton() {
    return Align(
      child: ContainerCorner(
        width: 60,
        height: 60,
        marginLeft: 10,
        borderRadius: 50,
        color: Colors.red,
        marginBottom: 50,
        child: Icon(
          Icons.call_end,
          size: 45,
          color: Colors.white,
        ),
<<<<<<< HEAD
        onTap: () => widget.isCaller == true
            ? endCallBtnCaller(CallsModel.CALL_END_REASON_END)
            : endCallBtnReceiver(),
=======
        onTap: () =>
        widget.isCaller == true ? endCallBtnCaller(CallsModel.CALL_END_REASON_END) : endCallBtnReceiver(),
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      ),
      alignment: Alignment.bottomCenter,
    );
  }

  _timerOnStartConversation() {
    return Visibility(
      visible: isConnected,
      child: Align(
        child: ContainerCorner(
          color: kTransparentColor,
          marginBottom: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<int>(
                stream: _stopWatchTimer.secondTime,
                initialData: 0,
                builder: (context, snap) {
                  final value = snap.data;
                  callDuration = QuickHelp.formatTime(value!);
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: TextWithTap(
                          QuickHelp.formatTime(value),
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
              Visibility(
                visible: isCallEnded,
                child: TextWithTap(
                  "video_call.on_call_end".tr(),
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextWithTap(
                widget.mUser!.getFullName!,
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              )
            ],
          ),
        ),
        alignment: Alignment.bottomCenter,
      ),
    );
  }

  _renderVideo() {
    return Stack(
      children: [
        Visibility(
          visible: true,
          child: ContainerCorner(
            color: kTransparentColor,
            borderWidth: 0,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
<<<<<<< HEAD
            child: QuickActions.photosWidget(
                widget.currentUser!.getAvatar!.url!,
                borderRadius: 0,
                fit: BoxFit.cover),
=======
            child: QuickActions.photosWidget(widget.currentUser!.getAvatar!.url!,
                borderRadius: 0, fit: BoxFit.cover),
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
          ),
        ),
        Align(
          //alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _userInformation(),
              ],
            ),
          ),
        )
      ],
    );
  }

  endCallBtnCaller(String endReason) {
    setState(() {
      isCallEnded = true;
    });

<<<<<<< HEAD
    if (widget.isCaller!) {
=======
    if(widget.isCaller!){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      saveCallHistory(endReason: endReason);
    }

    if (isCallAccepted) {
      if (isJoined) {
        this._leaveChannel();
      }
    } else {
      context.read<CallsProvider>().cancelCallInvitation();
    }

    Future.delayed(Duration(seconds: 1), () {
      QuickHelp.goBackToPreviousPage(context);
    });
  }

  endCallBtnReceiver() {
    setState(() {
      isCallEnded = true;
    });

    if (isJoined) {
      this._leaveChannel();
    }

    Future.delayed(Duration(seconds: 1), () {
      QuickHelp.goToNavigatorScreen(
<<<<<<< HEAD
        context,
        HomeScreen(
          preferences: widget.preferences,
          currentUser: widget.currentUser,
        ), //route: HomeScreen.route,
=======
          context,
          HomeScreen(
            preferences: widget.preferences,
            currentUser: widget.currentUser,
          ), //route: HomeScreen.route,
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      );
    });
  }

  endCallOffline(String reason) {
<<<<<<< HEAD
=======

>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
    context.read<CallsProvider>().setUserBusy(false);

    setState(() {
      isCallEnded = true;
    });

<<<<<<< HEAD
    if (widget.isCaller!) {
=======
    if(widget.isCaller!){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      saveCallHistory(endReason: reason);
    }

    this._leaveChannel();

    Future.delayed(Duration(seconds: 1), () {
      if (widget.isCaller == true) {
        QuickHelp.goBackToPreviousPage(context);
      } else {
        QuickHelp.goToNavigatorScreen(
            context,
            HomeScreen(
              preferences: widget.preferences,
              currentUser: widget.currentUser,
            ),
            //route: HomeScreen.route,
            finish: true,
            back: false);
      }
    });
  }

  endCallRefused() {
    setState(() {
      isCallEnded = true;
    });

    this._leaveChannel();
    if (isCallEnded) {
<<<<<<< HEAD
      QuickHelp.goBackToPreviousPage(
          NavigationService.navigatorKey.currentState!.context);
=======
      QuickHelp.goBackToPreviousPage(NavigationService.navigatorKey.currentState!.context);
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
    }
  }

  setupCounterLive() async {
<<<<<<< HEAD
=======

>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
    QueryBuilder<UserModel> query = QueryBuilder(UserModel.forQuery());
    query.whereEqualTo(UserModel.keyObjectId, widget.currentUser!.objectId);

    subscription = await liveQuery.client.subscribe(query);

    subscription!.on(LiveQueryEvent.update, (user) async {
      print('*** UPDATE ***');

      widget.currentUser = user as UserModel;

      setState(() {
        credits = widget.currentUser!.getCredits!.toString();
        diamonds = widget.currentUser!.getDiamonds!.toString();
      });
<<<<<<< HEAD
=======

>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
    });

    subscription!.on(LiveQueryEvent.enter, (user) {
      print('*** ENTER ***');

      widget.currentUser = user as UserModel;

      setState(() {
        credits = widget.currentUser!.getCredits!.toString();
        diamonds = widget.currentUser!.getDiamonds!.toString();
      });
    });
<<<<<<< HEAD
=======

>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
  }
}
