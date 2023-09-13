import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teego/app/navigation_service.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/models/UserModel.dart';

import '../app/setup.dart';
import '../home/calls/video_call_screen.dart';
import '../home/calls/voice_call_screen.dart';
import '../home/live/live_streaming_screen.dart';
import '../utils/shared_manager.dart';

class CallsProvider extends ChangeNotifier {
  int connectionStateDisconnected = 1;
  int connectionStateConnecting = 2;
  int connectionStateConnected = 3;
  int connectionStateReconnecting = 4;
  int connectionStateAborted = 5;

  AgoraRtmClient? _client;
  LocalInvitation? invitation;
  bool _isLogin = false;

  //BuildContext? _context;
  UserModel? _currentUser;
  bool isCallCanceled = false;
  bool isCallRinging = false;
  bool isCallRefused = false;
  bool busy = false;
  String getRoute = "";

  AgoraRtmClient? getAgoraRtmClient() {
    if (_client != null) {
      _createClient();
    }

    return _client;
  }

  setUserBusy(bool isUserBusy) {
    busy = isUserBusy;
    _log("User busy $isUserBusy");
  }

  setCallRefused(bool callRefused) {
    isCallRefused = callRefused;
    //notifyListeners();
  }

  setCanceled(bool callCanceled) {
    isCallCanceled = callCanceled;
    //notifyListeners();
  }

  bool isAgoraUserLogged(UserModel? user) {
    _currentUser = user;

    if (!_isLogin) {
      _toggleLogin(user!);
    }
    return _isLogin;
  }

  void connectAgoraRtm() {
    _createClient();
  }

  void loginAgoraUser(UserModel? user) {
    _currentUser = user;

    _toggleLogin(user!);
  }

  void _createClient() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    _client = await AgoraRtmClient.createInstance(
        SharedManager().getStreamProviderKey(preferences));
    _client!.onMessageReceived = (RtmMessage message, String peerId) {
      _log("Peer msg: " + peerId + ", msg: " + (message.text));
      print('message in Agora RTM:::::$message\n peer id in Agora RTM:::::::$peerId');
    };

    _client!.onConnectionStateChanged = (int state, int reason) {
      _log('Connection state changed: ' +
          state.toString() +
          ', reason: ' +
          reason.toString());
      if (state == 5) {
        _client!.logout();
        _log('Logout.');
        _isLogin = false;
        //notifyListeners();
      }

      connectionState(state);

      if (state == connectionStateConnecting ||
          state == connectionStateConnected ||
          state == connectionStateReconnecting) {
        //callState = true;
      }

      if (state == connectionStateDisconnected ||
          state == connectionStateAborted) {
        //callState = false;
      }
    };

    // Call MAKER

    _client!.onLocalInvitationReceivedByPeer =
        (AgoraRtmLocalInvitation invite) {
      _log(
          'Local invitation received by peer: ${invite.calleeId}, content: ${invite.content}');
      isCallRinging = true;
      notifyListeners();
    };

    _client!.onLocalInvitationAccepted = (LocalInvitation invite, _) {
      _log(
          'Local invitation received by peer: ${invite.calleeId}, content: ${invite.content}');
      isCallRinging = true;
      //notifyListeners();
    };

    _client!.onLocalInvitationRefused = (AgoraRtmLocalInvitation invite, _) {
      _log(
          'Local invitation Refused by peer: ${invite.calleeId}, content: ${invite.content}');
      isCallRefused = true;

      if (invite.response != null && invite.response == "busy") {
        /* QuickHelp.showAppNotificationAdvanced(
            title: "sorry".tr(),
            message: "Busy",
            context: NavigationService.navigatorKey.currentContext!);*/
      }
      notifyListeners();
    };

    _client!.onLocalInvitationCanceled = (AgoraRtmLocalInvitation invite) {
      _log(
          'Local invitation Canceled by peer calle: ${invite.calleeId}, content: ${invite.content}');
      //isCallRefused = true;
      //notifyListeners();
    };

    _client!.onLocalInvitationFailure =
        (AgoraRtmLocalInvitation invite, int error) {
      _log(
          'Local invitation Failure by peer: ${invite.calleeId}, content: ${invite.content}');
      //notifyListeners();
    };

    // Call RECEIVER

    _client!.onRemoteInvitationAccepted = (AgoraRtmRemoteInvitation invite) {
      _log(
          'Remote invitation Accepted: ${invite.callerId}, content: ${invite.content}');
    };

    _client!.onRemoteInvitationReceivedByPeer =
        (AgoraRtmRemoteInvitation invite) {
      _log(
          'Remote invitation received by peer: ${invite.callerId}, content: ${invite.content}');

      if (busy == false) {
        initCallScreen(invite, preferences);
      } else {
        //refuseRemoteInvitation(invite);
      }
    };

    _client!.onRemoteInvitationCanceled = (AgoraRtmRemoteInvitation invite) {
      _log(
          'Remote invitation Canceled by peer caller: ${invite.callerId}, content: ${invite.content}');
      isCallCanceled = true;
      notifyListeners();
    };

    _client!.onRemoteInvitationRefused = (AgoraRtmRemoteInvitation invite) {
      _log(
          'Remote invitation Refused by peer: ${invite.callerId}, content: ${invite.content}');
      //notifyListeners();
    };

    _client!.onRemoteInvitationFailure =
        (AgoraRtmRemoteInvitation invite, int error) {
      _log(
          'Remote invitation Failure by peer: ${invite.callerId}, content: ${invite.content}');
      //notifyListeners();
    };
  }

  // is mn sy agora remove krna

  void _toggleLogin(UserModel? userModel) async {
    if (_isLogin) {
      try {
        await _client!.logout();
        _log('Logout success.');

        _isLogin = false;
        //notifyListeners();
      } catch (errorCode) {
        _log('Logout error: ' + errorCode.toString());
      }
    } else {
      if (userModel!.objectId!.isEmpty) {
        _log('Please input your user id to login.');
        return;
      }

      try {
        await _client!.login(null, userModel.objectId!);
        _log('Login success: ' + userModel.objectId!);

        _isLogin = true;
        //notifyListeners();
      } catch (errorCode) {
        _log('Login error: ' + errorCode.toString());
      }
    }
  }

  // Make call to other user
  void callUserInvitation(
      {required String calleeId,
      required String channel,
      required bool isVideo}) async {
    _log('callUserInvitation clicked');

    try {
      // invitation = LocalInvitation(
      //   calleeId: calleeId,
      //   content: isVideo ? "video" : "voice",
      //   channelId: channel,
      // );

      _log(invitation!.content ?? '');
      await _client!.sendLocalInvitation(invitation!.toJson());
      _log('Send local invitation success.');
      //notifyListeners();
    } catch (errorCode) {
      _log('Send local invitation error: ' + errorCode.toString());
    }
  }

  // Cancel call made to other user before pickup
  void cancelCallInvitation() {
    busy = false;
    if (_client != null && invitation != null) {
      _client!.cancelLocalInvitation(invitation!.toJson());
    } else {
      _log("cancelCallInvitation _client null");
    }
  }

  // Accept a call invitation.
  void answerCall(final AgoraRtmRemoteInvitation invitation) {
    if (_client != null) {
      _client!.acceptRemoteInvitation(invitation.toJson());
    } else {
      _log("acceptRemoteInvitation _client null");
    }
  }

  // Refuse a call invitation.
  void refuseRemoteInvitation(RemoteInvitation invitation) {
    if (_client != null) {
      invitation.response = "busy";
      //invitation.state = 1;
      _client!.refuseRemoteInvitation(invitation.toJson());
    } else {
      _log("refuseRemoteInvitation _client null");
    }
  }

  getRoutes() async {
    final route = await SharedPreferences.getInstance();
    getRoute = route.getString("currentRoute")!;
  }

  initCallScreen(AgoraRtmRemoteInvitation agoraRtmRemoteInvitation,
      SharedPreferences preferences) async {
    getRoutes();

    isCallCanceled = false;

    QueryBuilder<UserModel> queryUser =
        QueryBuilder<UserModel>(UserModel.forQuery());
    queryUser.whereEqualTo(
        UserModel.keyObjectId, agoraRtmRemoteInvitation.callerId);

    ParseResponse parseResponse = await queryUser.query();
    if (parseResponse.success && parseResponse.results != null) {
      UserModel mUser = parseResponse.results!.first! as UserModel;

      if (getRoute == VideoCallScreen.route) {
        //invitation.content = "busy";
        refuseRemoteInvitation(agoraRtmRemoteInvitation);
      } else if (getRoute == VoiceCallScreen.route) {
        //invitation.content = "busy";
        refuseRemoteInvitation(agoraRtmRemoteInvitation);
      } else if (getRoute == LiveStreamingScreen.route) {
        //invitation.content = "live";

        refuseRemoteInvitation(agoraRtmRemoteInvitation);

        //remoteInvitation = agoraRtmRemoteInvitation;
        //notifyListeners();

        /*QuickHelp.showDialogPermission(
          context: NavigationService.navigatorKey.currentContext!,
          title: "permissions.allow_push_denied_title".tr(),
          message: "live_streaming.accept_call_advise".tr(),
          dismissible: false,
          confirmButtonText: "ok_".tr(),
          onPressed: () async {
            QuickHelp.hideLoadingDialog(
                NavigationService.navigatorKey.currentContext!);

            _endLiveStreaming().then((value) {

              _acceptCall(
                isVideo: agoraRtmRemoteInvitation.content! == "video"
                    ? true
                    : false,
                currentUser: _currentUser!,
                mUser: mUser,
                channel: agoraRtmRemoteInvitation.channelId!,
                agoraRtmRemoteInvitation: agoraRtmRemoteInvitation,
              );

            });
          },
        );*/

        //showInComingCallBackground(_currentUser!, mUser, agoraRtmRemoteInvitation);
      } else if (getRoute == "background") {
        _log("AgoraCall received $getRoute");

        showInComingCallBackground(
            _currentUser!, mUser, agoraRtmRemoteInvitation, preferences);
      } else {
        _log("AgoraCall received $getRoute");

        showInComingCallBackground(
            _currentUser!, mUser, agoraRtmRemoteInvitation, preferences);
        /* QuickHelp.goToNavigatorScreen(
          NavigationService.navigatorKey.currentContext!,
          IncomingCallScreen(
            mUser: mUser,
            currentUser: _currentUser,
            channel: agoraRtmRemoteInvitation.channelId!,
            isVideoCall:
                agoraRtmRemoteInvitation.content! == "video" ? true : false,
            agoraRtmRemoteInvitation: agoraRtmRemoteInvitation,
          ),
          route: IncomingCallScreen.route,
        );*/
      }
    } else {
      _log("parseResponse error");
    }
  }

  void _acceptCall({
    required bool isVideo,
    required UserModel currentUser,
    required UserModel mUser,
    required String channel,
    required RemoteInvitation agoraRtmRemoteInvitation,
    required SharedPreferences preferences,
  }) {
    if (isVideo) {
      QuickHelp.goToNavigatorScreen(
        NavigationService.navigatorKey.currentContext!,
        VideoCallScreen(
          connection: RtcConnection(channelId: channel),
          currentUser: currentUser,
          mUser: mUser,
          channel: channel,
          isCaller: false,
          preferences: preferences,
        ),
        finish: false,
        back: true,
      );
    } else {
      QuickHelp.goToNavigatorScreen(
        NavigationService.navigatorKey.currentContext!,
        VoiceCallScreen(
          mUser: mUser,
          currentUser: currentUser,
          channel: channel,
          isCaller: false,
          preferences: preferences,
        ),
        finish: false,
        back: true,
      );
    }
  }

  showInComingCallBackground(
      UserModel currentUser,
      UserModel callerUser,
      AgoraRtmRemoteInvitation invitation,
      SharedPreferences preferences) async {
    final params = CallKitParams(
      id: currentUser.objectId,
      nameCaller: callerUser.getFullName,
      appName: Setup.appName,
      avatar: callerUser.getAvatar!.url,
      handle: invitation.content! == "video"
          ? "calls_screen.text_video_call".tr()
          : "calls_screen.text_voice_call".tr(),
      type: invitation.content! == "video" ? 1 : 0,
      duration: 30000,
      textAccept: "calls_screen.text_accept".tr(),
      textDecline: "calls_screen.text_decline".tr(),
      // textMissedCall: "calls_screen.text_missed_call".tr(),
      // textCallback: "calls_screen.text_callback".tr(),
      //extra: <String, dynamic>{'userId': '1a2b3c4d'},
      //headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: AndroidParams(
        isCustomNotification: false,
        isShowLogo: false,
        // isShowCallback: false,
        // isShowMissedCallNotification: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#27E150',
        //backgroundUrl: 'assets/test.png',
        actionColor: '#4CAF50',
      ),
      ios: IOSParams(
        //iconName: 'CallKitLogo',
        handleType: '',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(params);
    await listenerEvent(
        invitation: invitation,
        callerUser: callerUser,
        preferences: preferences);
  }

  endInComingCall() async {
    await FlutterCallkitIncoming.endAllCalls();
  }

  Future<void> listenerEvent(
      {Function? callback,
      UserModel? callerUser,
      AgoraRtmRemoteInvitation? invitation,
      required SharedPreferences preferences}) async {
    try {
      FlutterCallkitIncoming.onEvent.listen((event) async {
        print('HOME CallKit: ${event!.event}');
        switch (event.event) {
          case Event.actionCallIncoming:
            // TODO: received an incoming call
            break;
          case Event.actionCallStart:
            // TODO: started an outgoing call
            // TODO: show screen calling in Flutter
            break;
          case Event.actionCallAccept:
            // TODO: accepted an incoming call
            // TODO: show screen calling in Flutter
            answerCall(invitation!);

            _acceptCall(
              isVideo: invitation.content! == "video" ? true : false,
              currentUser: _currentUser!,
              mUser: callerUser!,
              channel: invitation.channelId!,
              agoraRtmRemoteInvitation: invitation,
              preferences: preferences,
            );

            break;
          case Event.actionCallDecline:
            // TODO: declined an incoming call

            refuseRemoteInvitation(invitation!);
            endInComingCall();
            break;
          case Event.actionCallEnded:
            // TODO: ended an incoming/outgoing call

            refuseRemoteInvitation(invitation!);
            endInComingCall();
            break;
          case Event.actionCallTimeout:
            // TODO: missed an incoming call

            refuseRemoteInvitation(invitation!);
            //endInComingCall();
            break;
          case Event.actionCallCallback:
            // TODO: only Android - click action `Call back` from missed call notification
            break;
          case Event.actionCallToggleHold:
            // TODO: only iOS
            break;
          case Event.actionCallToggleMute:
            // TODO: only iOS
            break;
          case Event.actionCallToggleDmtf:
            // TODO: only iOS
            break;
          case Event.actionCallToggleGroup:
            // TODO: only iOS
            break;
          case Event.actionCallToggleAudioSession:
            // TODO: only iOS
            break;
          case Event.actionDidUpdateDevicePushTokenVoip:
            // TODO: only iOS
            break;
        }
        /*if (callback != null) {
          callback(event.toString());
        }*/
      });
    } on Exception {}
  }

  _log(String string) {
    print("AgoraCall " + string);
  }

  connectionState(int state) {
    if (state == connectionStateAborted) {
      _log("connectionStateAborted");
    } else if (state == connectionStateConnecting) {
      _log("connectionStateConnecting");
    } else if (state == connectionStateConnected) {
      _log("connectionStateConnected");
    } else if (state == connectionStateReconnecting) {
      _log("connectionStateReconnecting");
    } else if (state == connectionStateAborted) {
      _log("connectionStateAborted");
    }
  }
}
