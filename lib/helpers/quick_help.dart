import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:math' as math;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teego/app/cloud_params.dart';
import 'package:teego/app/setup.dart';
import 'package:teego/helpers/quick_actions.dart';
import 'package:teego/home/message/message_screen.dart';
import 'package:teego/models/ReportModel.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/rounded_gradient_button.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';
import 'package:teego/utils/shared_manager.dart';
import 'package:teego/widgets/need_resume.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:teego/app/config.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:teego/widgets/snackbar_pro/snack_bar_pro.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../app/navigation_service.dart';
import '../utils/datoo_exeption.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart'
    show consolidateHttpClientResponseBytes, kIsWeb;

import '../widgets/snackbar_pro/top_snack_bar.dart';

typedef EmailSendingCallback = void Function(bool sent, ParseError? error);

class QuickHelp {
  ParseConfig config = ParseConfig();

  static const String pageTypeTerms = "/terms";
  static const String pageTypePrivacy = "/privacy";
  static const String pageTypeOpenSource = "/opensource";
  static const String pageTypeHelpCenter = "/help";
  static const String pageTypeSafety = "/safety";
  static const String pageTypeCommunity = "/community";
  static const String pageTypeWhatsapp = "/whatsapp";
  static const String pageTypeInstructions = "/instructions";
  static const String pageTypeSupport = "/support";
  static const String pageTypeCashOut = "/cashOut";

  static String dateFormatDmy = "dd/MM/yyyy";
  static String dateFormatFacebook = "MM/dd/yyyy";
  static String dateFormatForFeed = "dd MMM, yyyy - HH:mm";

  static String dateFormatTimeOnly = "HH:mm";
  static String dateFormatListMessageFull = "dd MM, HH:mm";
  static String dateFormatDateOnly = "dd/MM/yy";
  static String dateFormatDayAndDateOnly = "EE., dd MMM";

  static String emailTypeWelcome = "welcome_email";
  static String emailTypeVerificationCode = "verification_code_email";

  static double earthMeanRadiusKm = 6371.0;
  static double earthMeanRadiusMile = 3958.8;

  // Online/offline track
  static int timeToSoon = 300 * 1000;
  static int timeToOffline = 2 * 60 * 1000;

  static final String admobBannerAdTest = isAndroidPlatform()?
  "ca-app-pub-3940256099942544/6300978111" : "ca-app-pub-3940256099942544/2934735716";

  static final String admobNativeAdTest = isAndroidPlatform()?
  "ca-app-pub-3940256099942544/2247696110" : "ca-app-pub-3940256099942544/3986624511";

  static final String admobOpenAppAdTest = isAndroidPlatform()?
  "ca-app-pub-3940256099942544/3419835294" : "ca-app-pub-3940256099942544/5662855259";

  static Color getColorStandard({bool? inverse}) {
    if (isDarkModeNoContext()) {
      if (inverse != null && inverse) {
        return kContentColorLightTheme;
      } else {
        return kContentColorDarkTheme;
      }
    } else {
      if (inverse != null && inverse) {
        return kContentColorDarkTheme;
      } else {
        return kContentColorLightTheme;
      }
    }
  }

  static List<String> getReportCodeMessageList() {
    List<String> list = [
      ReportModel.THIS_POST_HAS_SEXUAL_CONTENTS,
      ReportModel.FAKE_PROFILE_SPAN,
      ReportModel.INAPPROPRIATE_MESSAGE,
      ReportModel.SOMEONE_IS_IN_DANGER,
    ];

    return list;
  }

  static String getReportMessage(String code) {
    switch (code) {
      case ReportModel.THIS_POST_HAS_SEXUAL_CONTENTS:
        return "message_report.report_without_interest".tr();

      case ReportModel.FAKE_PROFILE_SPAN:
        return "message_report.report_fake_profile".tr();

      case ReportModel.INAPPROPRIATE_MESSAGE:
        return "message_report.report_inappropriate_message".tr();

      case ReportModel.SOMEONE_IS_IN_DANGER:
        return "message_report.report_some_in_danger".tr();

      default:
        return "";
    }
  }

  static Color getColorSettingsBg() {
    if (isDarkModeNoContext()) {
      return kContentColorLightTheme;
    } else {
      return kSettingsBg;
    }
  }

  static String getDurationInMinutes({Duration? duration}) {
    if (duration != null) {
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

      if (duration.inHours > 0) {
        return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
      } else {
        return "$twoDigitMinutes:$twoDigitSeconds";
      }
    } else {
      return "00:00";
    }
  }

  static String formatTime(int second) {
    var hour = (second / 3600).floor();
    var minutes = ((second - hour * 3600) / 60).floor();
    var seconds = (second - hour * 3600 - minutes * 60).floor();

    var secondExtraZero = (seconds < 10) ? "0" : "";
    var minuteExtraZero = (minutes < 10) ? "0" : "";
    var hourExtraZero = (hour < 10) ? "0" : "";

    if (hour > 0) {
      return "$hourExtraZero$hour:$minuteExtraZero$minutes:$secondExtraZero$seconds";
    } else {
      return "$minuteExtraZero$minutes:$secondExtraZero$seconds";
    }
  }

  static Color getColorTextCustom1({bool? inverse}) {
    if (isDarkModeNoContext()) {
      if (inverse != null && inverse) {
        return kContentColorLightTheme;
      } else {
        return kContentColorDarkTheme;
      }
    } else {
      if (inverse != null && inverse) {
        return kContentColorDarkTheme;
      } else {
        return kContentColorLightTheme;
      }
    }
  }

  static Color getColorToolbarIcons() {
    if (isDarkModeNoContext()) {
      return kContentColorDarkTheme;
    } else {
      return kColorsGrey600;
    }
  }

  static bool isDarkMode(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
  }

  static bool isDarkModeNoContext() {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    return brightness == Brightness.dark;
  }

  static bool isWebPlatform() {
    return UniversalPlatform.isWeb;
  }

  static bool isAndroidPlatform() {
    return UniversalPlatform.isAndroid;
  }

  static bool isFuchsiaPlatform() {
    return UniversalPlatform.isFuchsia;
  }

  static bool isIOSPlatform() {
    return UniversalPlatform.isIOS;
  }

  static bool isMacOsPlatform() {
    return UniversalPlatform.isMacOS;
  }

  static bool isLinuxPlatform() {
    return UniversalPlatform.isLinux;
  }

  static bool isWindowsPlatform() {
    return UniversalPlatform.isWindows;
  }

  // Get country code
  static String? getCountryIso() {
    final List<Locale>? systemLocales = WidgetsBinding.instance.window.locales;
    return systemLocales?.first.countryCode;
  }

  static String? getCountryCodeFromLocal(BuildContext context) {
    Locale myLocale = Localizations.localeOf(context);

    return myLocale.countryCode;
  }

  // Save Installation
  static Future<void> initInstallation(UserModel? user, String? token) async {
    DateTime dateTime = DateTime.now().toLocal();

    ParseInstallation installation = ParseInstallation.forQuery();
    ParseInstallation installationCurrent = await ParseInstallation.currentInstallation();

    if (token != null) {
      installation.set('deviceToken', token);
    } else {
      installation.unset('deviceToken');
    }

    installation.set('GCMSenderId', Config.pushGcm);
    installation.set('timeZone', dateTime.timeZoneName);
    installation.set('installationId', installationCurrent.installationId);

    if (kIsWeb) {
      installation.set('deviceType', 'web');
      installation.set('pushType', 'FCM');
    } else if (Platform.isAndroid) {
      installation.set('deviceType', 'android');
      installation.set('pushType', 'FCM');
    } else if (Platform.isIOS) {
      installation.set('deviceType', 'ios');
      installation.set('pushType', 'APN');
    }

    if (user != null) {
      installation.set('user', user);
      installation.subscribeToChannel('global');
    } else {
      installation.unset('user');
      installation.unsubscribeFromChannel('global');
    }
  }

  static setCurrentUser(UserModel? userModel, {StateSetter? setState}) async {
    UserModel userModel = await ParseUser.currentUser();

    if (setState != null) {
      setState(() {
        userModel = userModel;
      });
    } else {
      userModel = userModel;
    }
  }

  static Future<UserModel?>? getCurrentUser() async {
    UserModel? currentUser = await ParseUser.currentUser();
    return currentUser;
  }

  static Future<UserModel?> getCurrentUserModel(UserModel? userModel) async {
    UserModel currentUser = await ParseUser.currentUser();
    return currentUser;
  }

  static Future<UserModel> getUserModelResult(dynamic d) async {
    UserModel? user = await ParseUser.currentUser();
    user = UserModel.clone()..fromJson(d as Map<String, dynamic>);

    return user;
  }

  static Future<UserModel?> getUserAwait() async {
    UserModel? currentUser = await ParseUser.currentUser();

    if (currentUser != null) {
      ParseResponse response = await currentUser.getUpdatedUser();
      if (response.success) {
        currentUser = response.result;
        return currentUser;
      } else if (response.error!.code == 100) {
        // Return stored user

        return currentUser;
      } else if (response.error!.code == 101) {
        // User deleted or doesn't exist.

        currentUser.logout(deleteLocalUserData: true);
        return null;
      } else if (response.error!.code == 209) {
        // Invalid session token

        currentUser.logout(deleteLocalUserData: true);
        return null;
      } else {
        // General error

        return currentUser;
      }
    } else {
      return null;
    }
  }

  static Future<UserModel?> getUser(UserModel? currentUser) async {

    currentUser = await ParseUser.currentUser();

    if (currentUser != null) {

      ParseResponse response = await currentUser.getUpdatedUser();

      if (response.success) {

        UserModel userModel = response.results!.first!;

        return userModel;
      } else if (response.error!.code == 100) {
        // Return stored user

        return currentUser;
      } else if (response.error!.code == 101) {
        // User deleted or doesn't exist.

        currentUser.logout(deleteLocalUserData: true);
        return null;
      } else if (response.error!.code == 209) {
        // Invalid session token

        currentUser.logout(deleteLocalUserData: true);
        return null;
      } else {
        // General error

        return currentUser;
      }
    } else {

      return null;
    }
  }

  // Check if email is valid
  static bool isValidEmail(String email) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\])|(([a-zA-Z\-\d]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  // Check if string has only number(s)
  static bool isNumeric(String string) {
    return double.tryParse(string) != null;
  }

  static bool isPasswordCompliant(String password, [int minLength = 6]) {
    bool hasUppercase = password.contains(new RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(new RegExp(r'\d'));
    bool hasLowercase = password.contains(new RegExp(r'[a-z]'));
    bool hasSpecialCharacters =
        password.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasMinLength = password.length > minLength;

    return hasDigits &
        hasUppercase &
        hasLowercase &
        hasSpecialCharacters &
        hasMinLength;
  }

  static DateTime getDateFromString(String date, String format) {
    return new DateFormat(format).parse(date);
  }

  static Object getDateDynamic(String date) {
    DateFormat dateFormat = DateFormat(dateFormatDmy);
    DateTime dateTime = dateFormat.parse(date);

    return json.encode(dateTime, toEncodable: myEncode);
  }

  static dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }

  static DateTime getDate(String date) {
    DateFormat dateFormat = DateFormat(dateFormatDmy);
    DateTime dateTime = dateFormat.parse(date);

    return dateTime;
  }

  static bool isValidDateBirth(String date, String format) {
    try {
      int day = 1, month = 1, year = 2000;

      //Get separator data  10/10/2020, 2020-10-10, 10.10.2020
      String separator = RegExp("([-/.])").firstMatch(date)!.group(0)![0];

      //Split by separator [mm, dd, yyyy]
      var frSplit = format.split(separator);
      //Split by separtor [10, 10, 2020]
      var dtSplit = date.split(separator);

      for (int i = 0; i < frSplit.length; i++) {
        var frm = frSplit[i].toLowerCase();
        var vl = dtSplit[i];

        if (frm == "dd")
          day = int.parse(vl);
        else if (frm == "mm")
          month = int.parse(vl);
        else if (frm == "yyyy") year = int.parse(vl);
      }

      //First date check
      //The dart does not throw an exception for invalid date.
      var now = DateTime.now();
      if (month > 12 ||
          month < 1 ||
          day < 1 ||
          day > daysInMonth(month, year) ||
          year < 1810 ||
          (year > now.year && day > now.day && month > now.month))
        throw Exception("Date birth invalid.");

      return true;
    } catch (e) {
      return false;
    }
  }

  static bool minimumAgeAllowed(String birthDateString, String datePattern) {
    // Current time - at this moment
    DateTime today = DateTime.now();

    // Parsed date to check
    DateTime birthDate = DateFormat(datePattern).parse(birthDateString);

    // Date to check but moved 18 years ahead
    DateTime adultDate = DateTime(
      birthDate.year + Setup.minimumAgeToRegister,
      birthDate.month,
      birthDate.day,
    );

    return adultDate.isBefore(today);
  }

  static int daysInMonth(int month, int year) {
    int days = 28 +
        (month + (month / 8).floor()) % 2 +
        2 % month +
        2 * (1 / month).floor();
    return (isLeapYear(year) && month == 2) ? 29 : days;
  }

  static bool isLeapYear(int year) =>
      ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0);

  static void showLoadingDialog(BuildContext context, {bool? isDismissible}) {
    showDialog(
        context: context,
        barrierDismissible: isDismissible != null ? isDismissible : false,
        builder: (BuildContext context) {
          return showLoadingAnimation(); //LoadingDialog();
        });
  }

  static void hideLoadingDialog(BuildContext context, {dynamic result}) {
    Navigator.pop(context, result );
  }

  static goToNavigator(BuildContext context, String route,
      {Object? arguments, ResumableState? resumeState}) {
    Future.delayed(Duration.zero, () {
      if (resumeState != null) {
        resumeState.pushNamed(context, route, arguments: arguments);
      } else {
        //Navigator.of(context).pushNamed(route, arguments: arguments);
        NavigationService.navigatorKey.currentState?.pushNamed(route, arguments: arguments);
      }
    });
  }

  static gotoChat(BuildContext context, {UserModel? currentUser, UserModel? mUser, required SharedPreferences preferences}){
    QuickHelp.goToNavigatorScreen(context, MessageScreen(currentUser: currentUser, mUser: mUser, preferences: preferences));
  }

  static goToNavigatorScreen(BuildContext context, Widget widget,
      {bool? finish = false, bool? back = true}) {
    if (finish == false) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => widget,
        ),
      );
    } else {
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => widget,
        ), (route) => back!, //if you want to disable back feature set to false
      );
    }
  }

  static Future<dynamic> goToNavigatorScreenForResult(BuildContext context, Widget widget) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        //settings: RouteSettings(name: route),
          builder: (context) => widget),
    );

    return result;
  }

  static void goBack(BuildContext context, {Object? arguments}) {
    Navigator.pop(context, arguments);
  }

  static goToPageWithClear(BuildContext context, Widget widget) {
    Navigator.pushAndRemoveUntil<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => widget,
      ),
      (route) => false, //if you want to disable back feature set to false
    );
  }

  static void goBackToPreviousPage(BuildContext context,
      {bool? useCustomAnimation,
      PageTransitionsBuilder? pageTransitionsBuilder, dynamic result}) {
    Navigator.of(context).pop(result);
  }

  static checkRoute(BuildContext context, bool authNeeded, Widget widget) {
    if (authNeeded && QuickHelp.getCurrentUser() != null) {
      return widget;
    } else {
      return QuickHelp.goBackToPreviousPage(context);
    }
  }

  static void showDialogWithButton(
      {required BuildContext context,
      String? message,
      String? title,
      String? buttonText,
      VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title!),
          content: Text(message!),
          actions: [
            new ElevatedButton(
              child: Text(buttonText!),
              onPressed: () {
                Navigator.of(context).pop();
                if (onPressed != null) {
                  onPressed();
                }
              },
            ),
          ],
        );
      },
    );
  }

  static void showDialogWithButtonCustom(
      {required BuildContext context,
      String? message,
      String? title,
      required String? cancelButtonText,
      required String? confirmButtonText,
      VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: QuickHelp.isDarkMode(context)
              ? kContentColorLightTheme
              : kContentColorDarkTheme,
          title: TextWithTap(
            title!,
            fontWeight: FontWeight.bold,
          ),
          content: Text(message!),
          actions: [
            TextWithTap(
              cancelButtonText!,
              fontWeight: FontWeight.bold,
              marginRight: 10,
              marginLeft: 10,
              marginBottom: 10,
              onTap: () => Navigator.of(context).pop(),
            ),
            TextWithTap(
              confirmButtonText!,
              fontWeight: FontWeight.bold,
              marginRight: 10,
              marginLeft: 10,
              marginBottom: 10,
              onTap: () {
                if (onPressed != null) {
                  onPressed();
                }
              },
            ),
          ],
        );
      },
    );
  }

  static void showDialogHeyto(
      {required BuildContext context,
      String? message,
      String? title,
      required String? cancelButtonText,
      required String? confirmButtonText,
      VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: QuickHelp.isDarkMode(context)
              ? kContentColorLightTheme
              : kContentColorDarkTheme,
          elevation: 2,
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Column(
            children: [
              Center(
                child: Container(
                  width: 28,
                  height: 28,
                  child: SvgPicture.asset(
                    'assets/svg/ic_icon.svg',
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
              TextWithTap(
                title!,
                marginTop: 28,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: TextWithTap(
            message!,
            textAlign: TextAlign.center,
          ),
          actions: [
            Column(
              children: [
                RoundedGradientButton(
                  text: confirmButtonText!,
                  //width: 150,
                  height: 48,
                  marginLeft: 30,
                  marginRight: 30,
                  marginBottom: 30,
                  borderRadius: 60,
                  textColor: Colors.white,
                  borderRadiusBottomLeft: 15,
                  colors: [kPrimaryColor, kSecondaryColor],
                  marginTop: 0,
                  fontSize: 16,
                  onTap: () {
                    if (onPressed != null) {
                      onPressed();
                    }
                  },
                ),
                TextWithTap(
                  cancelButtonText!.toUpperCase(),
                  fontWeight: FontWeight.bold,
                  color: kPrimacyGrayColor,
                  marginRight: 10,
                  marginLeft: 10,
                  fontSize: 15,
                  marginBottom: 10,
                  textAlign: TextAlign.center,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static void showDialogPermission(
      {required BuildContext context,
      String? message,
      String? title,
      required String? confirmButtonText,
      VoidCallback? onPressed, bool? dismissible = true}) {
    showDialog(
      context: context,
      barrierDismissible: dismissible!,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: QuickHelp.isDarkMode(context)
              ? kContentColorLightTheme
              : kContentColorDarkTheme,
          elevation: 2,
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: TextWithTap(
            title!,
            marginTop: 5,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          content: TextWithTap(
            message!,
            textAlign: TextAlign.center,
            color: kSecondaryGrayColor,
          ),
          actions: [
            Column(
              children: [
                RoundedGradientButton(
                  text: confirmButtonText!,
                  //width: 150,
                  height: 48,
                  marginLeft: 30,
                  marginRight: 30,
                  marginBottom: 20,
                  borderRadius: 60,
                  textColor: Colors.white,
                  borderRadiusBottomLeft: 15,
                  colors: [kPrimaryColor, kSecondaryColor],
                  marginTop: 0,
                  fontSize: 15,
                  onTap: () {
                    if (onPressed != null) {
                      onPressed();
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static void showDialogLivEend(
      {required BuildContext context,
      String? message,
      String? title,
      required String? confirmButtonText,
      VoidCallback? onPressed,
      bool? dismiss = true}) {
    showDialog(
      barrierDismissible: dismiss!,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: QuickHelp.isDarkMode(context)
              ? kContentColorLightTheme
              : kContentColorDarkTheme,
          elevation: 2,
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: TextWithTap(
            title!,
            marginTop: 5,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          content: TextWithTap(
            message!,
            textAlign: TextAlign.center,
            color: kSecondaryGrayColor,
          ),
          actions: [
            Column(
              children: [
                RoundedGradientButton(
                  text: confirmButtonText!,
                  //width: 150,
                  height: 48,
                  marginLeft: 30,
                  marginRight: 30,
                  marginBottom: 20,
                  borderRadius: 60,
                  textColor: Colors.white,
                  borderRadiusBottomLeft: 15,
                  colors: [kPrimaryColor, kSecondaryColor],
                  marginTop: 0,
                  fontSize: 15,
                  onTap: () {
                    if (onPressed != null) {
                      onPressed();
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static void showError(
      {required BuildContext context,
      String? message,
      VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error!"),
          content: Text(message!),
          actions: <Widget>[
            new ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (onPressed != null) {
                  onPressed();
                }
              },
            ),
          ],
        );
      },
    );
  }

  static bool isAccountDisabled(UserModel? user) {

    if(user!.getActivationStatus == true){
      return true;

    } else if(user.getAccountDeleted == true){
      return true;

    } else {
      return false;
    }
  }

  static updateUserServer(
      {required String column,
      required dynamic value,
      required UserModel user}) async {
    ParseCloudFunction function =
        ParseCloudFunction(CloudParams.updateUserGlobalParam);
    Map<String, dynamic> params = <String, dynamic>{
      CloudParams.columnGlobal: column,
      CloudParams.valueGlobal: value,
      CloudParams.userGlobal: user.getUsername!,
    };

    ParseResponse parseResponse = await function.execute(parameters: params);
    if (parseResponse.success) {
      UserModel.getUserResult(parseResponse.result);
    }
  }

  static updateUserServerList({required Map<String, dynamic> map}) async {
    ParseCloudFunction function =
        ParseCloudFunction(CloudParams.updateUserGlobalListParam);
    Map<String, dynamic> params = map;

    ParseResponse parseResponse = await function.execute(parameters: params);
    if (parseResponse.success) {
      UserModel.getUserResult(parseResponse.result);
    }
  }

  //final emailSendingCallback? _sendingCallback;

  static sendEmail(String accountNumber, String emailType,
      {EmailSendingCallback? sendingCallback}) async {
    ParseCloudFunction function =
        ParseCloudFunction(CloudParams.sendEmailParam);
    Map<String, String> params = <String, String>{
      CloudParams.userGlobal: accountNumber,
      CloudParams.emailType: emailType
    };
    ParseResponse result = await function.execute(parameters: params);

    if (result.success) {
      sendingCallback!(true, null);
    } else {
      sendingCallback!(false, result.error);
    }
  }

  static bool isMobile() {
    if (isWebPlatform()) {
      return false;
    } else if (isAndroidPlatform()) {
      return true;
    } else if (isIOSPlatform()) {
      return true;
    } else {
      return false;
    }
  }

  static goToWebPage(BuildContext context, {required String pageType}) {
    goToNavigator(context, pageType);
  }

  static void showErrorResult(BuildContext context, int error) {
    QuickHelp.hideLoadingDialog(context);

    if (error == DatooException.connectionFailed) {
      // Internet problem
      QuickHelp.showAppNotificationAdvanced(
          context: context, title: "error".tr(),
          message: "not_connected".tr(),  isError: true,
      );
    } else if (error == DatooException.otherCause) {
      // Internet problem
      QuickHelp.showAppNotificationAdvanced(
          context: context, title: "error".tr(), message: "not_connected".tr(), isError: true,);
    } else if (error == DatooException.emailTaken) {
      // Internet problem
      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "error".tr(),
          message: "auth.email_taken".tr(),
        isError: true,
      );
    }

    /*else if(error == DatooException.accountBlocked){
      // Internet problem
      QuickHelp.showAlertError(context: context, title: "error".tr(), message: "auth.account_blocked".tr());
    }*/
    else {
      // Invalid credentials
      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "error".tr(),
          message: "auth.invalid_credentials".tr(),
          isError: true,
      );
    }
  }

  static bool isAndroidLogin() {
    if (QuickHelp.isAndroidPlatform()) {
      return false;
    } else if (QuickHelp.isIOSPlatform() && Setup.isAppleLoginEnabled) {
      return true;
    } else {
      return false;
    }
  }

  static final bool areSocialLoginsDisabled = !Setup.isPhoneLoginEnabled &&
      !Setup.isGoogleLoginEnabled &&
      !isAndroidLogin();

  static int generateUId() {
    Random rnd = new Random();
    return 1000000000 + rnd.nextInt(999999999);
  }

  static int generateShortUId() {
    Random rnd = new Random();
    return 1000 + rnd.nextInt(9999);
  }

  static Future<String> downloadFilePath(
      String url, String fileName, String dir) async {
    HttpClient httpClient = new HttpClient();
    File file;
    String filePath = '';
    String myUrl = '';

    try {
      myUrl = url + '/' + fileName;
      var request = await httpClient.getUrl(Uri.parse(myUrl));
      var response = await request.close();
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        filePath = '$dir/$fileName';
        file = File(filePath);
        await file.writeAsBytes(bytes);
      } else
        filePath = 'Error code: ' + response.statusCode.toString();
    } catch (ex) {
      filePath = 'Can not fetch url';
    }

    return filePath;
  }

  static Map<String, dynamic>? getInfoFromToken(String token) {
    // validate token

    final List<String> parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }
    // retrieve token payload
    final String payload = parts[1];
    final String normalized = base64Url.normalize(payload);
    final String resp = utf8.decode(base64Url.decode(normalized));
    // convert to Map
    final payloadMap = json.decode(resp);
    if (payloadMap is! Map<String, dynamic>) {
      return null;
    }
    return payloadMap;
  }

  static Future<dynamic> downloadFile(String url, String filename) async {
    HttpClient httpClient = new HttpClient();

    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  static setWebPageTitle(BuildContext context, String title) {
    SystemChrome.setApplicationSwitcherDescription(
        ApplicationSwitcherDescription(
      label: '${Setup.appName} - $title',
      primaryColor: Theme.of(context).primaryColor.value,
    ));
  }

  static String getMoodNameByCode(String modeCode) {
    switch (modeCode) {
      case "RC":
        return "profile_tab.mood_rc".tr();

      case "LMU":
        return "profile_tab.mood_lmu".tr();

      case "HLE":
        return "profile_tab.mood_hle".tr();

      case "BMM":
        return "profile_tab.mood_bmm".tr();

      case "CC":
        return "profile_tab.mood_cc".tr();

      case "RFD":
        return "profile_tab.mood_rfd".tr();

      case "ICUD":
        return "profile_tab.mood_icud".tr();

      case "JPT":
        return "profile_tab.mood_jpt".tr();

      case "MML":
        return "profile_tab.mood_mml".tr();

      case "SM":
        return "profile_tab.mood_sm".tr();

      default:
        return "profile_tab.mood_none".tr();
    }
  }

  static void setRandomArray(List arrayList) {
    arrayList.shuffle();
  }

  static int getAgeFromDate(DateTime birthday) {
    DateTime currentDate = DateTime.now();

    int age = currentDate.year - birthday.year;

    int month1 = currentDate.month;
    int month2 = birthday.month;

    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthday.day;

      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  static int getAgeFromDateString(String birthDateString, String datePattern) {
    // Parsed date to check
    DateTime birthday = DateFormat(datePattern).parse(birthDateString);

    DateTime currentDate = DateTime.now();

    int age = currentDate.year - birthday.year;

    int month1 = currentDate.month;
    int month2 = birthday.month;

    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthday.day;

      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  static DateTime incrementDate(int days) {
    DateTime limitDate = DateTime.now();
    limitDate.add(Duration(days: days));

    return limitDate;
  }

  static String getStringFromDate(DateTime utcTime) {

    final dateTime = utcTime.toLocal();

    return DateFormat(dateFormatDmy).format(dateTime);
  }

  static String getTimeAgoForFeed(DateTime utcTime) {

    // Get local time based on UTC time
    final dateTime = utcTime.toLocal();

    DateTime now = DateTime.now();
    int dateDiff = DateTime(dateTime.year, dateTime.month, dateTime.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    if (dateDiff == -1) {
      // Yesterday
      return "date_time.yesterday_".tr();
    } else if (dateDiff == 0) {
      // today
      return DateFormat().add_Hm().format(dateTime);
    } else {
      return DateFormat().add_MMMEd().add_Hm().format(dateTime);
    }
  }

  static String getBirthdayFromDate(DateTime date) {
    return DateFormat(dateFormatDmy).format(date.add(Duration(days: 1)));
  }

  static String getDeviceOsName() {
    if (QuickHelp.isAndroidPlatform()) {
      return "Android";
    } else if (QuickHelp.isIOSPlatform()) {
      return "iOS";
    } else if (QuickHelp.isWebPlatform()) {
      return "Web";
    } else if (QuickHelp.isWindowsPlatform()) {
      return "Windows";
    } else if (QuickHelp.isLinuxPlatform()) {
      return "Linux";
    } else if (QuickHelp.isFuchsiaPlatform()) {
      return "Fuchsia";
    } else if (QuickHelp.isMacOsPlatform()) {
      return "MacOS";
    }

    return "";
  }

  static String getDeviceOsType() {
    if (QuickHelp.isAndroidPlatform()) {
      return "android";
    } else if (QuickHelp.isIOSPlatform()) {
      return "ios";
    } else if (QuickHelp.isWebPlatform()) {
      return "web";
    } else if (QuickHelp.isWindowsPlatform()) {
      return "windows";
    } else if (QuickHelp.isLinuxPlatform()) {
      return "linux";
    } else if (QuickHelp.isFuchsiaPlatform()) {
      return "fuchsia";
    } else if (QuickHelp.isMacOsPlatform()) {
      return "macos";
    }

    return "";
  }

  static getGender(UserModel user) {
    if (user.getGender == UserModel.keyGenderMale) {
      return "male_".tr();
    } else {
      return "female_".tr();
    }
  }

  static List<String> getShowMyPostToList() {
    List<String> list = [UserModel.ANY_USER, UserModel.ONLY_MY_FRIENDS, ""];

    return list;
  }

  static String getShowMyPostToMessage(String code) {
    switch (code) {
      case UserModel.ANY_USER:
        return "privacy_settings.explain_see_my_posts"
            .tr(namedArgs: {"app_name": Config.appName});

      case UserModel.ONLY_MY_FRIENDS:
        return "privacy_settings.explain_see_my_post".tr();

      default:
        return "edit_profile.profile_no_answer".tr();
    }
  }

  static Future<void> launchInWebViewWithJavaScript(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(
        url,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  static Widget appLoading() {
    return Center(
      child: Container(
        width: 50,
        height: 50,
        child:
            showLoadingAnimation(), //SvgPicture.asset('assets/svg/ic_icon.svg', width: 50, height: 50,),
      ),
    );
  }

  static Widget appLoadingLogo() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        child: Image.asset(
          QuickHelp.isDarkModeNoContext()
              ? 'assets/images/ic_logo_white.png'
              : 'assets/images/ic_logo.png',
          width: 120,
          height: 120,
        ),
      ),
    );
  }

  static double distanceInKilometersTo(
      ParseGeoPoint point1, ParseGeoPoint point2) {
    return _distanceInRadiansTo(point1, point2) * earthMeanRadiusKm;
  }

  static double distanceInMilesTo(ParseGeoPoint point1, ParseGeoPoint point2) {
    return _distanceInRadiansTo(point1, point2) * earthMeanRadiusMile;
  }

  static double _distanceInRadiansTo(
      ParseGeoPoint point1, ParseGeoPoint point2) {
    double d2r = math.pi / 180.0; // radian conversion factor
    double lat1rad = point1.latitude * d2r;
    double long1rad = point1.longitude * d2r;
    double lat2rad = point2.latitude * d2r;
    double long2rad = point2.longitude * d2r;
    double deltaLat = lat1rad - lat2rad;
    double deltaLong = long1rad - long2rad;
    double sinDeltaLatDiv2 = math.sin(deltaLat / 2);
    double sinDeltaLongDiv2 = math.sin(deltaLong / 2);
    // Square of half the straight line chord distance between both points.
    // [0.0, 1.0]
    double a = sinDeltaLatDiv2 * sinDeltaLatDiv2 +
        math.cos(lat1rad) *
            math.cos(lat2rad) *
            sinDeltaLongDiv2 *
            sinDeltaLongDiv2;
    a = math.min(1.0, a);
    return 2 * math.asin(math.sqrt(a));
  }

  static String isUserOnlineChat(UserModel user) {
    DateTime? dateTime;

    if (user.getLastOnline != null) {
      dateTime = user.getLastOnline;
    } else {
      dateTime = user.updatedAt;
    }

    if (DateTime.now().millisecondsSinceEpoch -
            dateTime!.millisecondsSinceEpoch >
        timeToOffline) {
      // offline
      return "offline_".tr();
    } else if (DateTime.now().millisecondsSinceEpoch -
            dateTime.millisecondsSinceEpoch >
        timeToSoon) {
      // offline / recently online
      return QuickHelp.timeAgoSinceDate(dateTime);
    } else {
      // online
      return "online_".tr();
    }
  }

  static String isUserOnlineLiveInvite(UserModel user) {
    DateTime? dateTime;

    if (user.getLastOnline != null) {
      dateTime = user.getLastOnline;
    } else {
      dateTime = user.updatedAt;
    }

    if (DateTime.now().millisecondsSinceEpoch -
        dateTime!.millisecondsSinceEpoch >
        timeToOffline) {
      // offline
      return "offline_".tr();

    } else {
      // online
      return "online_".tr();
    }
  }

  static bool isUserOnline(UserModel user) {
    DateTime? dateTime;

    if (user.getLastOnline != null) {
      dateTime = user.getLastOnline;
    } else {
      dateTime = user.updatedAt;
    }

    if (DateTime.now().millisecondsSinceEpoch -
            dateTime!.millisecondsSinceEpoch >
        timeToOffline) {
      // offline
      return false;
    } else if (DateTime.now().millisecondsSinceEpoch -
            dateTime.millisecondsSinceEpoch >
        timeToSoon) {
      // offline / recently online
      return true;
    } else {
      // online
      return true;
    }
  }

  static DateTime getDateFromAge(int age) {
    var birthday = DateTime.now();

    int currentYear = birthday.year;
    int birthYear = currentYear - age;

    return new DateTime(birthYear, birthday.month, birthday.day);
  }

  static String getDiamondsLeftToRedeem(int diamonds, SharedPreferences preferences) {
    if (diamonds >= SharedManager().getDiamondsNeededToRedeem(preferences)) {
      return 0.toString();
    } else {
      return (SharedManager().getDiamondsNeededToRedeem(preferences) - diamonds).toString();
    }
  }

  static bool hasSameDate(DateTime first, DateTime second) {
    int dateDiff = DateTime(second.year, second.month, second.day)
        .difference(DateTime(first.year, first.month, first.day))
        .inDays;
    return dateDiff == 0;
  }

  static String getMessageListTime(DateTime utcTime) {

    final dateTime = utcTime.toLocal();

    Duration diff = DateTime.now().difference(dateTime);
    DateTime now = DateTime.now();
    int dateDiff = DateTime(dateTime.year, dateTime.month, dateTime.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    if (dateDiff == -1) {
      // Yesterday
      return "date_time.yesterday_".tr();
    } else if (dateDiff == 0) {
      // today
      return DateFormat(dateFormatTimeOnly).format(dateTime);
    } else if (diff.inDays > 0 && diff.inDays < 6) {
      // Day name
      return getDaysOfWeek(dateTime);
    } else {
      return DateFormat(dateFormatDateOnly).format(dateTime);
    }
  }

  static String getMessageTime(DateTime utcTime, {bool? time}) {

    final dateTime = utcTime.toLocal();

    if (time != null && time == true) {
      return DateFormat(dateFormatTimeOnly).format(dateTime);
    } else {
      Duration diff = DateTime.now().difference(dateTime);
      DateTime now = DateTime.now();
      int dateDiff = DateTime(dateTime.year, dateTime.month, dateTime.day)
          .difference(DateTime(now.year, now.month, now.day))
          .inDays;

      if (dateDiff == -1) {
        // Yesterday
        return "date_time.yesterday_".tr();
      } else if (dateDiff == 0) {
        // today
        return "date_time.today_".tr();
      } else if (diff.inDays > 0 && diff.inDays < 6) {
        // Day name
        return getDaysOfWeek(dateTime);
      } else {
        return DateFormat().add_MMMEd().format(dateTime);
      }
    }
  }


  static String getTimeAndDate(DateTime utcTime, {bool? time}) {

    final dateTime = utcTime.toLocal();

    DateTime date1 = DateTime.now();
    return dateTime.difference(date1).toYearsMonthsDaysString();
  }

  static String getDaysOfWeek(DateTime dateTime) {
    int day = dateTime.weekday;

    if (day == 1) {
      return "date_time.monday_".tr();
    } else if (day == 2) {
      return "date_time.tuesday_".tr();
    } else if (day == 3) {
      return "date_time.wednesday_".tr();
    } else if (day == 4) {
      return "date_time.thursday_".tr();
    } else if (day == 5) {
      return "date_time.friday_".tr();
    } else if (day == 6) {
      return "date_time.saturday_".tr();
    } else if (day == 7) {
      return "date_time.sunday_".tr();
    }

    return "";
  }

  static String timeAgoSinceDate(DateTime utcTime,
      {bool numericDates = true}) {

    final dateTime = utcTime.toLocal();

    final date2 = DateTime.now();
    final difference = date2.difference(dateTime);

    if (difference.inDays > 8) {
      return DateFormat(dateFormatDateOnly).format(dateTime);
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1 week ago' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1 day ago' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1 hour ago' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 minute ago' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} seconds ago';
    } else {
      return 'Just now';
    }
  }

  static void showAppNotification(
      {required BuildContext context,
      String? title,
        bool isError = true}) {
    showTopSnackBar(
      context,
      isError
          ? SnackBarPro.error(
              title: title!,
            )
          : SnackBarPro.success(
              title: title!,
            ),
    );
  }

  static void showAppNotificationAdvanced(
      {required String title,
        required BuildContext context,
      Widget? avatar,
      String? message,
      bool? isError = true,
        VoidCallback? onTap,
      UserModel? user,
        String? avatarUrl}) {
    showTopSnackBar(
      context,
      SnackBarPro.custom(
        title: title,
        message: message,
        icon: user != null
            ? QuickActions.avatarWidget(
                user,
                imageUrl: avatarUrl,
                width: 60,
                height: 60,
              )
            : avatar,
        textStyleTitle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isError != null ? Colors.white : Colors.black,
              ),
        textStyleMessage: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 15,
          color: isError != null ? Colors.white : Colors.black,
        ),
        isError: isError,
      ),
      onTap: onTap,
      overlayState: null,
    );
  }

  static double convertDiamondsToMoney(int diamonds, SharedPreferences preferences){
    double totalMoney = (diamonds.toDouble() / 10000) * SharedManager().getWithDrawPercent(preferences);
    return totalMoney;
  }

  static double convertMoneyToDiamonds(double amount, SharedPreferences preferences){
    double diamonds = (amount.toDouble() * 10000) / SharedManager().getWithDrawPercent(preferences);
    return diamonds;
  }

  static int getDiamondsForReceiver(int diamonds, SharedPreferences preferences){
    double finalDiamonds = (diamonds /100) * SharedManager().getDiamondsEarnPercent(preferences);
    return int.parse(finalDiamonds.toStringAsFixed(0));
  }

  static int getDiamondsForAgency(int diamonds, SharedPreferences preferences){
    double finalDiamonds = (diamonds /100) * SharedManager().getAgencyPercent(preferences);
    return int.parse(finalDiamonds.toStringAsFixed(0));
  }

  static DateTime getUntilDateFromDays(int days){
    return DateTime.now().add(Duration(days: days));
  }

  static void showLoadingDialogWithText(BuildContext context, {bool? isDismissible, bool? useLogo = false, required String description, Color? backgroundColor}) {
    showDialog(
        context: context,
        barrierDismissible: isDismissible != null ? isDismissible : false,
        builder: (BuildContext context) {
          return Scaffold(
            extendBodyBehindAppBar: false,
            backgroundColor: backgroundColor,
            body: Container(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    useLogo! ? appLoadingLogo() : appLoading(),
                    TextWithTap(description, marginTop: !useLogo ? 10 : 0, marginLeft: 10, marginRight: 10,),
                  ],
                ),
              ),
            ),
          );
        });
  }

  static Future<File?> compressImage(String path, {int quality = 40}) async {

    final dir = await getTemporaryDirectory();
    final targetPath = dir.absolute.path + '/file.jpg';

    var result = await FlutterImageCompress.compressAndGetFile(
      path, targetPath,
      quality: quality,
      rotate: 0,
    );

    return result;
  }

  static File bytesToFile(Uint8List uint8List){
    return File.fromRawPath(uint8List);
  }

  static Widget showLoadingAnimation({Color leftDotColor = kPrimaryColor, Color rightDotColor = kSecondaryColor, double size = 35}){
    return Center(child: LoadingAnimationWidget.twistingDots(leftDotColor: leftDotColor, rightDotColor: rightDotColor, size: size));
  }

  static String convertNumberToK(int number){
    return NumberFormat.compact().format(number);
  }

  static saveCurrentRoute({required String route}) async {
    final currentRoute = await SharedPreferences.getInstance();
    await currentRoute.setString('currentRoute', route);
    print("route: ${currentRoute.getString('currentRoute')}");
  }

  static removeFocusOnTextField(BuildContext context) {
    FocusScopeNode focusScopeNode = FocusScope.of(context);
    if (!focusScopeNode.hasPrimaryFocus &&
        focusScopeNode.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }
}

extension DurationExtensions on Duration {
  String toYearsMonthsDaysString() {
    final years = this.inDays ~/ 365;
    // You will need a custom logic for the months part, since not every month has 30 days
    final months = (this.inDays % 365) ~/ 30;
    final days = (this.inDays % 365) % 30;

    return "$years y - $months m - $days d";
  }
}
