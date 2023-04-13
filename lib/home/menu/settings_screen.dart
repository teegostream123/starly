import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:teego/app/config.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/home/menu/referral_program_screen.dart';
import 'package:teego/home/menu/settings/account_settings_screen.dart';
import 'package:teego/home/menu/settings/app_settings_screen.dart';
import 'package:teego/home/menu/settings/customer_support.dart';
import 'package:teego/home/profile/profile_edit.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/app_bar.dart';
import 'package:teego/ui/button_with_icon.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';

// ignore: must_be_immutable
class SettingsScreen extends StatefulWidget {
  static String route = "/menu/settings";

  UserModel? currentUser;

  SettingsScreen({this.currentUser});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return ToolBar(
      title: "page_title.settings_title".tr(),
      centerTitle: QuickHelp.isAndroidPlatform() ? false : true,
      leftButtonIcon: Icons.arrow_back_ios,
      onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ContainerCorner(
                height: 50,
                marginAll: 5,
                borderRadius: 5,
                colors: [earnCashColor, coinColor],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Image.asset(
                              "assets/images/ic_agent_invite.png",
                              width: 30,
                              height: 30,
                            )),
                        TextWithTap(
                          "settings_screen.be_agent".tr(),
                          marginLeft: 10,
                          fontSize: 16,
                          color: Colors.white,
                        )
                      ],
                    ),
                    Expanded(
                      child: ButtonWithIcon(
                        text: "",
                        icon: Icons.arrow_forward_ios,
                        backgroundColor: kTransparentColor,
                        iconSize: 17,
                        iconColor: Colors.white,
                      ),
                    )
                  ],
                ),
                onTap: () => QuickHelp.goToNavigatorScreen(
                    context,
                    ReferralScreen(
                      currentUser: widget.currentUser,
                    )),
              ),
              ContainerCorner(
                borderColor: QuickHelp.isDarkMode(context)
                    ? kGreyColor2
                    : kColorsGrey300,
                borderWidth: 1,
                borderRadius: 1,
                marginTop: 5,
                marginLeft: 5,
                marginRight: 5,
                marginBottom: 15,
                child: Column(
                  children: [
                    settingsOptions("settings_screen.edit_profile".tr(),
                        "assets/images/ic_settings_profile_settings.png",
                        route: ProfileEdit.route,
                        arguments: widget.currentUser),
                    getDivider(),
                    settingsOptions(
                        "settings_screen.invite_to_app"
                            .tr(namedArgs: {"app_name": Config.appName}),
                        "assets/images/ic_settings_invite_friends.png",
                        share: true,
                        arguments: widget.currentUser),
                    getDivider(),
                   /* settingsOptions(
                        "settings_screen.my_qr_code"
                            .tr(namedArgs: {"app_name": Config.appName}),
                        "assets/images/ic_qrcode_app.png",
                        route: MyAppCodeScreen.route,
                        arguments: widget.currentUser),
                    getDivider(),*/
                    settingsOptions(
                      "settings_screen.account_settings".tr(),
                      "assets/images/ic_settings_app.png",
                      route: AccountSettingsScreen.route,
                      arguments: widget.currentUser,
                    ),
                    /* getDivider(),
                    settingsOptions("settings_screen.connected_accounts".tr(),
                        "assets/svg/connected_accounts_vector.svg",
                    route: ConnectedAccountsScreen.route
                    ),*/
                    /*getDivider(),
                    settingsOptions("settings_screen.app_privacy".tr(),
                        "assets/images/ic_settings_privacy.png",
                    route: PrivacySettingsScreen.route,
                      arguments: widget.currentUser,
                    ),*/
                    getDivider(),
                    settingsOptions("settings_screen.app_settings".tr(),
                        "assets/images/ic_settings_menu.png",
                        route: AppSettingsScreen.route,
                        arguments: widget.currentUser),
                    getDivider(),
                    settingsOptions("settings_screen.app_support".tr(),
                        "assets/images/ic_logo.png",
                        route: CustomerSupportScreen.route,),
                    getDivider(),
                    settingsOptions("settings_screen.app_third_party".tr(),
                        "assets/images/ic_settings_open_source.png",
                        route: QuickHelp.pageTypeOpenSource),
                  ],
                ),
              ),
              Column(
                children: [
                  TextWithTap("settings_screen.app_version_one".tr(namedArgs: {
                    "year": DateTime.now().year.toString(),
                    "company": Config.companyName
                  })),
                  TextWithTap("settings_screen.app_version_two".tr()),
                  TextWithTap("settings_screen.app_version_tree"
                      .tr(namedArgs: {"version": Config.appVersion})),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWithTap(
                    "page_title.terms_of_use".tr(),
                    marginRight: 20,
                    marginTop: 15,
                    decoration: TextDecoration.underline,
                    onTap: () => QuickHelp.goToWebPage(context,
                        pageType: QuickHelp.pageTypeTerms),
                  ),
                  TextWithTap(
                    "page_title.privacy_policy".tr(),
                    marginLeft: 20,
                    marginTop: 15,
                    decoration: TextDecoration.underline,
                    onTap: () => QuickHelp.goToWebPage(context,
                        pageType: QuickHelp.pageTypePrivacy),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getDivider() {
    return Divider(
      color: QuickHelp.isDarkMode(context) ? kGreyColor2 : kColorsGrey300,
      height: 1,
      thickness: 1,
    );
  }

  Widget settingsOptions(String text, String iconUrl,
      {String? route, Object? arguments, bool? share = false}) {
    return ButtonWithIcon(
      text: text,
      iconURL: iconUrl,
      backgroundColor: QuickHelp.isDarkMode(context)
          ? kContentColorLightTheme
          : kContentColorDarkTheme,
      textColor: QuickHelp.isDarkMode(context) ? kGreyColor1 : kColorsGrey700,
      urlIconColor:
          QuickHelp.isDarkMode(context) ? kGreyColor1 : kColorsGrey500,
      mainAxisAlignment: MainAxisAlignment.start,
      fontSize: 17,
      height: 50,
      onTap: () =>
      share == true
              ? Share.share("settings_screen.share_app_url".tr(namedArgs: {"app_name": Config.appName, "url": Config.appOrCompanyUrl}))
              : gotoActivity(route!, arguments),
    );
  }

  gotoActivity(String route, Object? arguments){

    if(route ==  ProfileEdit.route){

      QuickHelp.goToNavigatorScreen(
          context,
          ProfileEdit(
            currentUser: widget.currentUser,
          ),
      );

    } else if(route ==  CustomerSupportScreen.route){

      QuickHelp.goToNavigatorScreen(
        context,
        CustomerSupportScreen(
          currentUser: widget.currentUser,
        ),
      );

    } else if(route ==  AccountSettingsScreen.route){

      QuickHelp.goToNavigatorScreen(
        context,
        AccountSettingsScreen(
          currentUser: widget.currentUser,
        ),
      );

    } else {

      QuickHelp.goToNavigator(context, route, arguments: arguments);
    }

  }
}
