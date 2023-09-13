import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teego/app/config.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/app_bar.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';

enum Permission { anyUser, onlyFriends }

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({ Key? key }) : super(key: key);
  static String route = "/menu/settings/PrivacySettings";

  @override
  _PrivacySettingsScreenState createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  UserModel? currentUser;

  // varables for each setting option
  bool isReceiveChatRequest = false;
  bool isShowUpInSearch = true;
  bool isShowVipLevel = true;
  bool isShowLocation = true;
  bool isShowLastTimeSeen = true;
  bool isInvisibleMode = false;
  String showMyPostToCode = "AU";

  // type for each settings option
  String typeCanSee = "myposts";
  String typeReceive = "request";
  String typeSearch = "search";
  String typeVip = "viplevel";
  String typeLocation = "location";
  String typeLastTime = "lastSeen";
  String typeInvisible = "invisible";

  Permission? _permission = Permission.anyUser;

  _getUser() async {
    UserModel? userModel = await ParseUser.currentUser();

    currentUser = userModel;

    setState(() {
      isReceiveChatRequest = currentUser!.getReceiveChatRequest!;
      isShowUpInSearch = currentUser!.getShowUpInSearch!;
      isShowVipLevel = currentUser!.getShowVipLevel!;
      isShowLocation = currentUser!.getShowLocation!;
      isShowLastTimeSeen = currentUser!.getShowLastTimeSeen!;
      isInvisibleMode = currentUser!.getInvisibleMode!;
      showMyPostToCode = currentUser!.getShowMyPostsTo!;

      if(showMyPostToCode == UserModel.ANY_USER){
        _permission = Permission.anyUser;
      }else if(showMyPostToCode == UserModel.ONLY_MY_FRIENDS){
        _permission = Permission.onlyFriends;
      }

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
      title: "privacy_settings.screen_title".tr(),
      leftButtonIcon: Icons.arrow_back,
      onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
      child: Column(
        children: [
          settingsWidget("privacy_settings.title_see_my_posts".tr(),null,typeCanSee, QuickHelp.getShowMyPostToMessage(showMyPostToCode)),
          settingsWidget("privacy_settings.title_receive_chat_request".tr(), isReceiveChatRequest, typeReceive, ""),
          settingsWidget("privacy_settings.title_show_in_search".tr(), isShowUpInSearch, typeSearch, ""),
          settingsWidget("privacy_settings.title_show_vip_lever".tr(), isShowVipLevel, typeVip, ""),
          settingsWidget("privacy_settings.title_show_location".tr(), isShowLocation, typeLocation, ""),
          settingsWidget("privacy_settings.title_show_last_time_seen".tr(), isShowLastTimeSeen, typeLastTime, ""),
          settingsWidget("privacy_settings.title_invisible_mode".tr(), isInvisibleMode, typeInvisible, "privacy_settings.explain_invisible_mode".tr()),
        ],
      ),
    );
  }

  ContainerCorner settingsWidget(String text, bool? isEnabled, String type, String description) {
    return ContainerCorner(
      width: double.infinity,
      color: kTransparentColor,
      borderColor: defaultColor.withOpacity(0.3),
      borderWidth: 0.5,
      onTap: () => _goToPage(type),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          type != typeCanSee?
          Row(
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
                      marginBottom: type == typeInvisible ? 0:12,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                    ),
                    type == typeInvisible
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
                    :const SizedBox(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right:10.0),
                child: Checkbox(
                  value: isEnabled, 
                  onChanged: (value) =>  _changeSetting(type),
                  activeColor:kPrimaryColor,
                ),
              ),
            ],
          )
          :Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWithTap(
                text,
                marginLeft: 10,
                marginRight: 10,
                marginTop: 8,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
              TextWithTap(
                QuickHelp.getShowMyPostToMessage(showMyPostToCode),
                marginLeft: 10,
                marginRight: 10,
                marginBottom: 8,
                marginTop: 5,
                fontSize: 12,
                color: defaultColor,
                fontWeight: FontWeight.w400,
              )
            ],
          ),
        ],
      ),
    );
  }

  void _goToPage(String type) {
    if(type != typeCanSee){
      _changeSetting(type);
    }else{
      _showAlertDialog();
    }
  }

  _saveReceiveChatRequestState() async{

    currentUser!.setReceiveChatRequest = !isReceiveChatRequest;

    ParseResponse userResult = await currentUser!.save();

    _updateCurrentUser(userResult);
  }

  _saveShowInUpSearchState() async{

    currentUser!.setShowUpInSearch = !isShowUpInSearch;

    ParseResponse userResult = await currentUser!.save();

    _updateCurrentUser(userResult);
  }

  _saveShowVipLevelState() async{

    currentUser!.setShowVipLevel = !isShowVipLevel;

    ParseResponse userResult = await currentUser!.save();

    _updateCurrentUser(userResult);
  }

  _saveShowLocationState() async{
    currentUser!.setShowLocation = !isShowLocation;

    ParseResponse userResult = await currentUser!.save();

    _updateCurrentUser(userResult);
  }

  _saveShowLastTimeSeenState() async{

    currentUser!.setShowLastTimeSeen= !isShowLastTimeSeen;

    ParseResponse userResult = await currentUser!.save();

    _updateCurrentUser(userResult);
  }

  _saveInvisibleModeState() async{

    currentUser!.setInvisibleMode = !isInvisibleMode;

    ParseResponse userResult = await currentUser!.save();

    _updateCurrentUser(userResult);
  }

  _saveShowMyPostsTo(String code) async{
    QuickHelp.showLoadingDialog(context);

    currentUser!.setShowMyPostsTo = code;

    ParseResponse userResult = await currentUser!.save();

    _updateCurrentUser(userResult, dialog: true);
  }

  _updateCurrentUser(ParseResponse userResult,{bool? dialog}) {
    if (userResult.success) {

      if(dialog != null && dialog){
        QuickHelp.hideLoadingDialog(context);
        QuickHelp.hideLoadingDialog(context);
      }

      currentUser = userResult.results!.first as UserModel;

      _getUser();
    } else if (userResult.error!.code == 100) {
      QuickHelp.hideLoadingDialog(context);
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

  _changeSetting(String type) {
    setState(() {
      switch (type) {
        case "request":
          _saveReceiveChatRequestState();
        break;

        case "search":
          _saveShowInUpSearchState();
        break;

        case "viplevel":
          _saveShowVipLevelState();
        break;

        case "location":
          _saveShowLocationState();
        break;

        case "lastSeen":
          _saveShowLastTimeSeenState();
        break;

        case "invisible":
          _saveInvisibleModeState();
        break;
      } 
    });
  }

  void _showAlertDialog(){
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.only(left: 24.0,top: 12),
        title: Text(
          "privacy_settings.title_see_my_posts".tr(),
        textAlign: TextAlign.start,
        style: TextStyle(
          fontWeight:FontWeight.w700,
          fontSize: 16,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 0),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text("privacy_settings.explain_see_my_posts".tr(namedArgs: {"app_name": Config.appName})),
            leading: Radio<Permission>(
              activeColor: kPrimaryColor,
              value: Permission.anyUser, 
              groupValue: _permission, 
              onChanged: (Permission? value) {
                setState(() {
                  _permission = value;
                  _saveShowMyPostsTo(UserModel.ANY_USER);
                });
              },
            )
          ),
          ListTile(
            title: Text("privacy_settings.explain_see_my_post".tr()),
            leading: Radio<Permission>(
              value: Permission.onlyFriends, 
              activeColor: kPrimaryColor,
              groupValue: _permission, 
              onChanged: (Permission? value) {
                setState(() {
                  _permission = value;
                  _saveShowMyPostsTo(UserModel.ONLY_MY_FRIENDS);
                });
              },
            )
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), 
          child: Text(
            "cancel".tr().toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              color: QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    ));
  }
}
