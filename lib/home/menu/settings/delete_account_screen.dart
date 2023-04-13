import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teego/app/config.dart';
import 'package:teego/auth/welcome_screen.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/app_bar.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';

enum Reason {
  doNotknowHowToUseTango,
  myAccountWasSuspended,
  iNoLongerHaveAnInterest,
  iDoNotWantAnyoneToKnow,
  iDoNotHaveEnoughFriends,
  iReceivedTooManyFriendRequests,
  imetInappropritedOrAbusiveUsers,
  receivedTooManyNotifications,
  poorAudioOrVideoQuality,
  toDeleteOldAccountHistoryAndCreateANewOne
}

// ignore: must_be_immutable
class DeleteAccountPage extends StatefulWidget {

  static String route = "/menu/settings/AccountSettings/DeleteAccount";

  UserModel? currentUser;

  DeleteAccountPage({Key? key, this.currentUser}) : super(key: key);

  @override
  _DeleteAccountPageState createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {


  List options = [
    "account_settings.option_how_to_use".tr(namedArgs: {"app_name": Config.appName}),
    "account_settings.option_suspended_account".tr(),
    "account_settings.option_interest_waste".tr(namedArgs: {"app_name": Config.appName}),
    "account_settings.option_none_knows".tr(namedArgs: {"app_name": Config.appName}),
    "account_settings.option_enough_friends".tr(namedArgs: {"app_name": Config.appName}),
    "account_settings.option_many_friends_request".tr(),
    "account_settings.option_inappropriate_user".tr(),
    "account_settings.option_many_notifications".tr(),
    "account_settings.option_poor_quality".tr(),
    "account_settings.option_delete_and_create".tr(namedArgs: {"app_name": Config.appName}),
  ];
  List values = [
    Reason.doNotknowHowToUseTango,
    Reason.myAccountWasSuspended,
    Reason.iNoLongerHaveAnInterest,
    Reason.iDoNotWantAnyoneToKnow,
    Reason.iDoNotHaveEnoughFriends,
    Reason.iReceivedTooManyFriendRequests,
    Reason.imetInappropritedOrAbusiveUsers,
    Reason.receivedTooManyNotifications,
    Reason.poorAudioOrVideoQuality,
    Reason.toDeleteOldAccountHistoryAndCreateANewOne,
  ];

  Reason? _reason = Reason.doNotknowHowToUseTango;

  String reason = "";


  @override
  Widget build(BuildContext context) {

    return ToolBar(
      backgroundColor: QuickHelp.isDarkMode(context) ? kContentColorLightTheme : Colors.white,
      title: "account_settings.delete_account".tr(),
      leftButtonWidget: BackButton(),
      child: SingleChildScrollView(
        scrollDirection:Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                    options.length,
                        (index){
                      return ListTile(
                          title: Text(
                            options[index],
                            style:  TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          leading: Radio<Reason>(
                            value: values[index],
                            activeColor: kPrimaryColor,
                            groupValue: _reason,
                            onChanged: (Reason? value) {
                              setState(() {
                                _reason = value;
                                reason = value.toString();
                              });
                            },
                          )
                      );
                    }
                )),
            ContainerCorner(
              marginTop: 50,
              width: 120,
              borderRadius: 5,
              color:kPrimaryColor,
              onTap:(){
                _deleteAccount(reason);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: TextWithTap(
                  "account_settings.delete_account".tr().toUpperCase(),
                  fontSize: 11,
                  textAlign: TextAlign.center,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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
        ),

      ),

    );
  }

  void doUserLogout(UserModel? userModel) async {
    //QuickHelp.showLoadingDialog(context);

    ParseResponse response = await userModel!.logout(deleteLocalUserData: true);
    if (response.success) {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.goToNavigatorScreen(
          context, WelcomeScreen(), finish: true, back: false);
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showError(context: context, message: response.error!.message);
    }
  }

  _deleteAccount(String reason) async {
    QuickHelp.showLoadingDialog(context);

    widget.currentUser!.setAccountDeleted = true;
    widget.currentUser!.setAccountDeletedReason = reason;
    var response = await widget.currentUser!.save();

    if (response.success) {
      doUserLogout(widget.currentUser);
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showErrorResult(context, response.error!.code);
    }
  }
}
