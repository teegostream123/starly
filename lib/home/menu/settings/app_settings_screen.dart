import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/app_bar.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';

class AppSettingsScreen extends StatefulWidget {
   AppSettingsScreen({ Key? key }) : super(key: key);
  static String route = "/menu/settings/ApplicationSettings";

  @override
  _AppSettingsScreenState createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  UserModel? currentUser;

  bool isSendReadReceiptsEnabled = true;
  bool isOnClickGiftingEnabled = false;
  bool isDoNotEviteMeToLivePartyEnabled = false;
  bool isDoNotUsePictureInPictureEnabled = false;
  bool isAllowViewersToEnterPremiumEnabled = true;

  String sendReadReceipts = "receipts";
  String onClickGifting = "gifting";
  String liveParty = "party";
  String pictureInPicture = "picture";
  String allowViewers = "viewers";

  _getUser() async {
    UserModel? userModel = await ParseUser.currentUser();

    currentUser = userModel;

    setState(() {
      isSendReadReceiptsEnabled = currentUser!.getSendReadReceipts!;
      isOnClickGiftingEnabled = currentUser!.getEnableOneClickGifting!;
      isDoNotEviteMeToLivePartyEnabled = currentUser!.getDenyBeInvitedToLiveParty!;
      isDoNotUsePictureInPictureEnabled = currentUser!.getDenyPictureInPictureMode!;
      isAllowViewersToEnterPremiumEnabled = currentUser!.getAllowViewersToPremiumStream!;
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
      backgroundColor: QuickHelp.isDarkMode(context) ? kContentColorLightTheme : Colors.white,
      title: "application_settings.screen_title".tr(),
      leftButtonIcon: Icons.arrow_back,
      onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
      child:Column(
        children: [
          settingsWidget("application_settings.send_read_receipts".tr(),isSendReadReceiptsEnabled,sendReadReceipts),
          settingsWidget("application_settings.enable_one_click".tr(), isOnClickGiftingEnabled, onClickGifting),
          settingsWidget("application_settings.do_not_invite_me".tr(), isDoNotEviteMeToLivePartyEnabled,liveParty),
          settingsWidget("application_settings.do_not_use_pictures".tr(),isDoNotUsePictureInPictureEnabled, pictureInPicture),
          settingsWidget("application_settings.allow_viewers".tr(),isAllowViewersToEnterPremiumEnabled, allowViewers),
        ],
      ),
    );
  }

  ContainerCorner settingsWidget(String text, bool isEnabled, String type) {
    return ContainerCorner(
      width: double.infinity,
      color: kTransparentColor,
      borderColor: defaultColor.withOpacity(0.3),
      borderWidth: 0.5,
      onTap: () => _changeSettings(type),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextWithTap(
                  text,
                  marginLeft: 10,
                  marginRight: 10,
                  marginTop: 12,
                  marginBottom: 12,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                )
              ),
              Padding(
                padding:  EdgeInsets.only(right:8.0),
                child: Checkbox(
                  value: isEnabled, 
                  onChanged: (value) => _changeSettings(type),
                  activeColor:kPrimaryColor,
                ),
              ),
            ],
          )
        ]
      )
    );
  }

  _changeSettings(String type){
    setState(() { 
      switch (type) {
        case "receipts":
          _saveSendReadReceiptsState();
          break;
        
        case "gifting":
          _saveEnableOneClickGiftingState();
          break;

        case "party":
          _saveDenyInvitationToLivePartyState();
          break;

        case "picture":
          _saveDenyPictureInPictureModeState();
          break;

        case "viewers":
          _saveAllowUserToEnterPremiumStream();
        break;
      }
    });
  }

  _saveSendReadReceiptsState() async{

    currentUser!.setSendReadReceipts = !isSendReadReceiptsEnabled;

    ParseResponse userResult = await currentUser!.save();

    _updateCurrentUser(userResult, dialog: true);
  }

  _saveEnableOneClickGiftingState() async{

    currentUser!.setEnableOneClickGifting = !isOnClickGiftingEnabled;

    ParseResponse userResult = await currentUser!.save();

    _updateCurrentUser(userResult, dialog: true);
  }

  _saveDenyInvitationToLivePartyState() async{

    currentUser!.setDenyBeInvitedToLiveParty = !isDoNotEviteMeToLivePartyEnabled;

    ParseResponse userResult = await currentUser!.save();

    _updateCurrentUser(userResult, dialog: true);
  }

  _saveDenyPictureInPictureModeState() async{

    currentUser!.setDenyPictureInPictureMode = !isDoNotUsePictureInPictureEnabled;

    ParseResponse userResult = await currentUser!.save();

    _updateCurrentUser(userResult, dialog: true);
  }

  _saveAllowUserToEnterPremiumStream() async{

    currentUser!.setAllowViewersToPremiumStream = !isAllowViewersToEnterPremiumEnabled;

    ParseResponse userResult = await currentUser!.save();

    _updateCurrentUser(userResult, dialog: true);
  }

  _updateCurrentUser(ParseResponse userResult,{bool? dialog}) {
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