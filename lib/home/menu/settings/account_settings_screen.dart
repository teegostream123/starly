import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teego/app/config.dart';
import 'package:teego/app/setup.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/home/menu/settings/delete_account_screen.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/app_bar.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';

import '../../../auth/welcome_screen.dart';

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
class AccountSettingsScreen extends StatefulWidget {
  static String route = "/menu/settings/AccountSettings";

  UserModel? currentUser;

  AccountSettingsScreen({Key? key, this.currentUser}) : super(key: key);

  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  PhoneNumber number = PhoneNumber(isoCode: Config.initialCountry);

  TextEditingController emailController = TextEditingController();

  List options = [
    "account_settings.option_how_to_use"
        .tr(namedArgs: {"app_name": Config.appName}),
    "account_settings.option_suspended_account".tr(),
    "account_settings.option_interest_waste"
        .tr(namedArgs: {"app_name": Config.appName}),
    "account_settings.option_none_knows"
        .tr(namedArgs: {"app_name": Config.appName}),
    "account_settings.option_enough_friends"
        .tr(namedArgs: {"app_name": Config.appName}),
    "account_settings.option_many_friends_request".tr(),
    "account_settings.option_inappropriate_user".tr(),
    "account_settings.option_many_notifications".tr(),
    "account_settings.option_poor_quality".tr(),
    "account_settings.option_delete_and_create"
        .tr(namedArgs: {"app_name": Config.appName}),
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

  bool isSafeAddressEnabled = true;

  bool _isNumberValid = false;
  String showInvalidEmailMessage = "";
  TextEditingController phoneNumberEditingController = TextEditingController();

  String typePhone = "phone";
  String typeEmail = "email";
  String typeDelete = "delete";
  String typeAddress = "address";

  String userEmail = "";
  String userPhoneNumber = "";
  String countryIsoCode = "";
  String initialCountry = Config.initialCountry;

  //Reason? _reason = Reason.doNotknowHowToUseTango;

  _getUser() async {
    setState(() {
      userEmail = widget.currentUser!.getEmail!;
      userPhoneNumber = widget.currentUser!.getPhoneNumberFull!;

      initialCountry = widget.currentUser!.getCountryCode!;
    });
  }

  @override
  void initState() {
    _getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ToolBar(
      backgroundColor: QuickHelp.isDarkMode(context)
          ? kContentColorLightTheme
          : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          settingsWidget(
              "account_settings.phone_number".tr(), userPhoneNumber, typePhone),
          settingsWidget("account_settings.email_".tr(), userEmail, typeEmail),
          settingsWidget(
              "account_settings.delete_account".tr(),
              "account_settings.your_account"
                  .tr(namedArgs: {"app_name": Config.appName}),
              typeDelete),
          logoutWidget("account_settings.email_".tr(), userEmail, typeEmail),
        ],
      ),
      title: "account_settings.account_settings".tr(),
      leftButtonWidget: BackButton(),
    );
  }

  ContainerCorner settingsWidget(String text, String value, String type) {
    return ContainerCorner(
      width: double.infinity,
      color: kTransparentColor,
      borderColor: defaultColor.withOpacity(0.3),
      borderWidth: 0.5,
      onTap: () {
        _goToPage(type);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          type == typeAddress
              ? Row(
                  children: [
                    Expanded(
                        child: TextWithTap(
                      text,
                      marginLeft: 10,
                      marginRight: 10,
                      marginTop: 10,
                      marginBottom: 10,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                    )),
                    Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: Checkbox(
                        value: isSafeAddressEnabled,
                        onChanged: (value) => _changeSetting(),
                        activeColor: kPrimaryColor,
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWithTap(
                      text,
                      marginLeft: 10,
                      marginRight: 10,
                      marginTop: 8,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    TextWithTap(
                      value.isEmpty ? "account_settings.unset_".tr() : value,
                      marginLeft: 10,
                      marginRight: 10,
                      marginBottom: 8,
                      marginTop: 5,
                      fontSize: 14,
                      color: defaultColor,
                      fontWeight: FontWeight.w400,
                    )
                  ],
                ),
        ],
      ),
    );
  }

  ContainerCorner logoutWidget(String text, String value, String type) {
    return ContainerCorner(
      width: double.infinity,
      color: kTransparentColor,
      borderColor: defaultColor.withOpacity(0.3),
      borderWidth: 0.5,
      onTap: () {
        QuickHelp.showDialogWithButtonCustom(
            context: context,
            title: "account_settings.logout_user_sure".tr(),
            message: "account_settings.logout_user_details".tr(),
            cancelButtonText: "no".tr(),
            confirmButtonText: "account_settings.logout_user".tr(),
            onPressed: () {
              QuickHelp.showLoadingDialog(context);

              widget.currentUser!
                  .logout(deleteLocalUserData: true)
                  .then((value) {
                QuickHelp.hideLoadingDialog(context);
                QuickHelp.goToPageWithClear(
                  context,
                  WelcomeScreen(),
                );
              }).onError(
                (error, stackTrace) {
                  QuickHelp.hideLoadingDialog(context);
                },
              );
            });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWithTap(
            "account_settings.logout_user".tr(),
            marginLeft: 10,
            marginRight: 10,
            marginTop: 8,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          TextWithTap(
            "account_settings.logout_user_details".tr(),
            marginLeft: 10,
            marginRight: 10,
            marginBottom: 8,
            marginTop: 5,
            fontSize: 14,
            color: defaultColor,
            fontWeight: FontWeight.w400,
          )
        ],
      ),
    );
  }

  _goToPage(String type) {
    if (type == typeAddress) {
      _changeSetting();
    } else {
      switch (type) {
        case "phone":
          showPhoneDialog(context);
          break;

        case "email":
          showEmailDialog(context);
          break;

        case "delete":
          QuickHelp.goToNavigatorScreen(
              context, DeleteAccountPage(currentUser: widget.currentUser));
          break;

        default:
      }
    }
  }

  void showPhoneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        actionsAlignment: MainAxisAlignment.end,
        titleTextStyle: TextStyle(
          fontSize: 14,
        ),
        titlePadding: EdgeInsets.only(left: 20, top: 15),
        title: Text(
          "account_settings.mobile_".tr(),
          style: TextStyle(
              color:
                  QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ContainerCorner(
                  width: 250,
                  child: InternationalPhoneNumberInput(
                    inputDecoration: InputDecoration(
                      hintText: "auth.phone_number_hint".tr(),
                      hintStyle: QuickHelp.isDarkMode(context)
                          ? TextStyle(color: kColorsGrey500)
                          : TextStyle(color: kColorsGrey500),
                    ),
                    //countries: Setup.allowedCountries,
                    errorMessage: "auth.invalid_phone_number".tr(),
                    searchBoxDecoration: InputDecoration(
                      hintText: "auth.country_input_hint".tr(),
                    ),
                    onInputChanged: (PhoneNumber number) {
                      print(number.phoneNumber);
                      print(number.dialCode);
                      setState(() {
                        userPhoneNumber = number.phoneNumber.toString();
                        countryIsoCode = number.isoCode.toString();
                      });
                      //this.number = number;
                      //this._phoneNumber = number.phoneNumber!;
                    },
                    onInputValidated: (bool value) {
                      //print(value);
                      setState(() {
                        _isNumberValid = value;
                      });
                      print(phoneNumberEditingController.text);
                    },
                    countrySelectorScrollControlled: true,
                    locale: initialCountry,
                    selectorConfig: SelectorConfig(
                        selectorType: PhoneInputSelectorType.DIALOG,
                        showFlags: true,
                        useEmoji: QuickHelp.isWebPlatform() ? false : true,
                        setSelectorButtonAsPrefixIcon: true,
                        trailingSpace: true,
                        leadingPadding: 5),
                    ignoreBlank: false,
                    spaceBetweenSelectorAndTextField: 10,
                    autoValidateMode: AutovalidateMode.onUserInteraction,
                    textStyle: TextStyle(color: Colors.black),
                    selectorTextStyle: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.normal),
                    initialValue: widget.currentUser!.getCountryCode != null &&
                            widget.currentUser!.getCountryCode!.isNotEmpty
                        ? PhoneNumber(
                            isoCode: widget.currentUser!.getCountryCode)
                        : number,
                    countries: Setup.allowedCountries,
                    textFieldController: phoneNumberEditingController,
                    formatInput: true,
                    autoFocus: true,
                    autoFocusSearch: true,
                    //hintText: number.phoneNumber,
                    keyboardType: TextInputType.numberWithOptions(
                        signed: false, decimal: false),
                    inputBorder: OutlineInputBorder(),
                    onSaved: (PhoneNumber number) {
                      //print('On Saved: $number');
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                "account_settings.phone_number_required"
                    .tr(namedArgs: {"app_name": Config.appName}),
                style: TextStyle(
                  fontSize: 13.5,
                  //color:kSecondaryColor.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
        actionsPadding: EdgeInsets.symmetric(vertical: 5.0),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "cancel".tr().toUpperCase(),
              style: TextStyle(
                color:
                    QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              updatePhoneNumber();
            },
            child: Text(
              "save".tr().toUpperCase(),
              style: TextStyle(
                color:
                    QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        actionsAlignment: MainAxisAlignment.end,
        titleTextStyle: TextStyle(
          fontSize: 14,
          color: QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
        ),
        titlePadding: EdgeInsets.only(left: 20, top: 15),
        title: Text(
          "email_".tr(),
          style: TextStyle(
              color:
                  QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                      alignLabelWithHint: true,
                      labelText: widget.currentUser!.getEmail,
                      hintText: widget.currentUser!.getEmail,
                      focusColor: kSecondaryColor,
                      labelStyle: TextStyle(
                        fontSize: 15,
                        //color: defaultColor,
                      )),
                  autocorrect: false,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  onChanged: (email) {
                    _alertInvalidEmail(email);
                  },
                ),
                TextWithTap(
                  showInvalidEmailMessage,
                  color: kRedColor1,
                ),
              ],
            );
          },
        ),
        actionsPadding: EdgeInsets.symmetric(vertical: 5.0),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "cancel".tr().toUpperCase(),
              style: TextStyle(
                color:
                    QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _updateEmail(emailController.text);
            },
            child: Text(
              "save".tr().toUpperCase(),
              style: TextStyle(
                color:
                    QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  _alertInvalidEmail(String email) {
    setState(() {
      if (email.isNotEmpty) {
        if (_validateEmail(email)) {
          showInvalidEmailMessage = "";
        } else {
          showInvalidEmailMessage = "account_settings.invalid_email".tr();
        }
      } else {
        showInvalidEmailMessage = "";
      }
    });
  }

  _updateEmail(String email) async {
    if (_validateEmail(email)) {
      QuickHelp.showLoadingDialog(context);
      widget.currentUser!.setEmail = email;

      ParseResponse userResult = await widget.currentUser!.save();

      _updateCurrentUser(userResult);
    } else {
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "account_settings.error_email_title".tr(),
        message: "account_settings.error_email_explain".tr(),
      );
    }
  }

  updatePhoneNumber() async {
    if (_isNumberValid) {
      QuickHelp.showLoadingDialog(context);

      if (userPhoneNumber.isNotEmpty && countryIsoCode.isNotEmpty) {
        widget.currentUser?.setPhoneNumberFull = userPhoneNumber;
        widget.currentUser?.setCountryCode = countryIsoCode;

        ParseResponse userResult = await widget.currentUser!.save();

        _updateCurrentUser(userResult);
      }
    }
  }

  _changeSetting() {
    setState(() {
      isSafeAddressEnabled = !isSafeAddressEnabled;
      // The rest of the code goes here
    });
  }

  _updateCurrentUser(ParseResponse userResult) {
    if (userResult.success) {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.hideLoadingDialog(context);

      widget.currentUser = userResult.results!.first as UserModel;

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
}
