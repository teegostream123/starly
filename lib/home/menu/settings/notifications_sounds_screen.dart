import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/app_bar.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';

class NotificationsSoundsScreen extends StatefulWidget {
  const NotificationsSoundsScreen({Key? key}) : super(key: key);
  static String route = "/menu/settings/NotificationsSounds";

  @override
  _NotificationsSoundsScreenState createState() =>
      _NotificationsSoundsScreenState();
}

class _NotificationsSoundsScreenState extends State<NotificationsSoundsScreen> {
  UserModel? currentUser;

  bool isLiveNotification = true;
  bool isMuteIncoming = false;
  bool isNotificationSound = true;
  bool isInAppSound = true;
  bool isInAppVibration = true;
  bool isGameNotification = true;

  String typeLive = "livenotification";
  String typeIcoming = "icomming";
  String typeNofication = "notsound";
  String typeInVibration = "appvibration";
  String typeInsound = "appsound";
  String typeGame = "gameNotification";

  _getUser() async {
    UserModel? userModel = await ParseUser.currentUser();

    currentUser = userModel;

    setState(() {

      isLiveNotification = currentUser!.getLiveNotification!;
      isMuteIncoming = currentUser!.getMuteIncomingCalls!;
      isNotificationSound = currentUser!.getNotificationSounds!;
      isInAppSound = currentUser!.getInAppSound!;
      isInAppVibration = currentUser!.getInAppVibration!;
      isGameNotification = currentUser!.getGameNotification!;

    });

  }

  @override
  void initState() {
    _getUser();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    currentUser = ModalRoute.of(context)!.settings.arguments as UserModel;

    return ToolBar(
      title: "notifications_and_sounds.screen_title".tr(),
      leftButtonIcon: Icons.arrow_back,
      onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
      child: Column(
        children: [
          settingsWidget(
              "notifications_and_sounds.title_live_notification".tr(),
              typeLive,
              isLiveNotification,
              ""),
          settingsWidget(
              "notifications_and_sounds.title_mute_calls".tr(),
              typeIcoming,
              isMuteIncoming,
              "notifications_and_sounds.explanation_mute_calls".tr()),
          settingsWidget(
              "notifications_and_sounds.title_sound_notification".tr(),
              typeNofication,
              isNotificationSound,
              "notifications_and_sounds.explanation_sound".tr()),
          settingsWidget(
              "notifications_and_sounds.title_in_app_sound".tr(),
              typeInsound,
              isInAppSound,
              "notifications_and_sounds.explanation_in_app_sound".tr()),
          settingsWidget(
              "notifications_and_sounds.title_in_app_vibration".tr(),
              typeInVibration,
              isInAppVibration,
              "notifications_and_sounds.explanation_in_app_vibration".tr()),
          settingsWidget(
              "notifications_and_sounds.title_game_notification".tr(),
              typeGame,
              isGameNotification,
              ""),
        ],
      ),
    );
  }

  ContainerCorner settingsWidget(
      String text, String type, bool? isEnabled, String description) {
    return ContainerCorner(
        width: double.infinity,
        color: kTransparentColor,
        borderColor: defaultColor.withOpacity(0.3),
        borderWidth: 0.5,
        onTap: () => _changeSetting(type),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWithTap(
                    text,
                    marginLeft: 10,
                    marginRight: 10,
                    marginTop: 10,
                    marginBottom: description != '' ? 0 : 12,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  description != ''
                      ? TextWithTap(
                          description,
                          marginLeft: 10,
                          marginRight: 10,
                          marginBottom: 8,
                          marginTop: 5,
                          fontSize: 12,
                          color: defaultColor,
                          fontWeight: FontWeight.w400,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : const SizedBox(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Checkbox(
                      value: isEnabled,
                      onChanged: (value) => _changeSetting(type),
                      activeColor: kPrimaryColor,
                    ),
            ),
          ],
        ));
  }

  _changeSetting(String type) {
    setState(() {
      switch (type) {
        case "livenotification":
          _saveLiveNotificationState();
          break;

        case "icomming":
          _saveMuteInComingCallsState();
          break;

        case "notsound":
          _saveNotificationSoundState();
          break;

        case "appvibration":
          _saveInAppVibrationState();
          break;

        case "appsound":
          _saveInAppSoundState();
          break;

        case "gameNotification":
          _saveGameNotificationState();
          break;
      }
    });
  }

  _saveGameNotificationState() async{

    currentUser!.setGameNotification = !isGameNotification;

    ParseResponse userResult = await currentUser!.save();

    _updateCurrentUser(userResult);
  }

  _saveInAppVibrationState() async{

    currentUser!.setInAppVibration = !isInAppVibration;

    ParseResponse userResult = await currentUser!.save();

    _updateCurrentUser(userResult);
  }

  _saveInAppSoundState() async{

    currentUser!.setInAppSound = !isInAppSound;

    ParseResponse userResult = await currentUser!.save();

    _updateCurrentUser(userResult);
  }

  _saveNotificationSoundState() async{

    currentUser!.setNotificationSounds = !isNotificationSound;

    ParseResponse userResult = await currentUser!.save();

    _updateCurrentUser(userResult);
  }

  _saveMuteInComingCallsState() async{

    currentUser!.setMuteIncomingCalls = !isMuteIncoming;

    ParseResponse userResult = await currentUser!.save();

    _updateCurrentUser(userResult);
  }

  _saveLiveNotificationState() async{

    currentUser!.setLiveNotification = !isLiveNotification;

    ParseResponse userResult = await currentUser!.save();

    _updateCurrentUser(userResult);
  }

  _updateCurrentUser(ParseResponse userResult) {
    if (userResult.success) {

      currentUser = userResult.results!.first as UserModel;

      _getUser();
    } else if (userResult.error!.code == 100) {
      QuickHelp.showAppNotificationAdvanced(
          context: context, title: "error".tr(), message: "not_connected".tr());
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "error".tr(),
          message: "try_again_later".tr());
    }
  }

}


