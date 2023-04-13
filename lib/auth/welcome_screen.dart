import 'dart:async';
import 'dart:io';

import 'package:faker/faker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teego/app/config.dart';
import 'package:teego/app/setup.dart';
import 'package:teego/auth/social_login.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/button_with_icon.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/ui/button_with_image.dart';
import 'package:teego/ui/button_with_svg.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teego/utils/datoo_exeption.dart';
import 'package:teego/widgets/CountDownTimer.dart';

import '../app/constants.dart';
import '../helpers/responsive.dart';
import '../services/dynamic_link_service.dart';
import '../utils/shared_manager.dart';
import 'dispache_screen.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
late ConfirmationResult confirmationResult;
late UserCredential userCredential;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  static const String route = '/welcome';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PhoneNumber number = PhoneNumber(isoCode: Config.initialCountry);

  TextEditingController phoneNumberEditingController = TextEditingController();
  TextEditingController pinCodeEditingController = TextEditingController();

  bool hasError = false;

  int position = 0;

  int _positionPhoneInput = 0;

  String _phoneNumber = "";
  String _pinCode = "";

  bool _showResend = false;
  late String _verificationId;
  int? _tokenResend;

  late SharedPreferences preferences;

  @override
  void initState() {

    initSharedPref();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  initSharedPref() async {
    preferences = await SharedPreferences.getInstance();
    Constants.queryParseConfig(preferences);
  }

  void _sendVerificationCode(bool resend) async {
    QuickHelp.showLoadingDialog(context, isDismissible: false);

    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
      await _auth.signInWithCredential(phoneAuthCredential);

      print('Verified automatically');

      _checkUserAccount();
    };

    PhoneVerificationFailed verificationFailed = (FirebaseAuthException e) {
      QuickHelp.hideLoadingDialog(context);

      print(
          'Phone number verification failed. Code: ${e.code}. Message: ${e.message}');

      if (e.code == "web-context-cancelled") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "auth.canceled_phone".tr());
      } else if (e.code == "invalid-verification-code") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "auth.invalid_code".tr());
      } else if (e.code == "network-request-failed") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "no_internet_connection".tr());
      } else if (e.code == "invalid-phone-number") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "auth.invalid_phone_number".tr());
      } else {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "try_again_later".tr());
      }
    };

    PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      QuickHelp.hideLoadingDialog(context);
      // Check your phone for the sms code
      _verificationId = verificationId;
      _tokenResend = forceResendingToken;

      print('Verification code sent');

      if (!resend) {
        //_updateCurrentState();
        nextPosition();
      }

      setState(() {
        _showResend = false;
      });
    };

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
      print('PhoneCodeAutoRetrievalTimeout');
    };

    try {
      if (QuickHelp.isWebPlatform()) {
        confirmationResult =
            await _auth.signInWithPhoneNumber(number.phoneNumber!);
        //userCredential = await confirmationResult.confirm('123456');
      } else {
        await _auth.verifyPhoneNumber(
            phoneNumber: number.phoneNumber!,
            timeout: const Duration(seconds: 5),
            verificationCompleted: verificationCompleted,
            verificationFailed: verificationFailed,
            codeSent: codeSent,
            forceResendingToken: _tokenResend,
            codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
      }
    } on FirebaseAuthException catch (e) {
      QuickHelp.hideLoadingDialog(context);

      if (e.code == "web-context-cancelled") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "auth.canceled_phone".tr());
      } else if (e.code == "invalid-verification-code") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "auth.invalid_code".tr());
      } else if (e.code == "network-request-failed") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "no_internet_connection".tr());
      } else if (e.code == "invalid-phone-number") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "auth.invalid_phone_number".tr());
      } else {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "try_again_later".tr());
      }
    }
  }

  Future<void> verifyCode(String pinCode) async {
    _pinCode = pinCode;
    QuickHelp.showLoadingDialog(context);

    try {
      if (QuickHelp.isWebPlatform()) {
        userCredential = await confirmationResult.confirm(_pinCode);

        final User? user =
            (await _auth.signInWithCredential(userCredential.credential!)).user;

        if (user != null) {
          _checkUserAccount();
        }
      } else {
        final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: _pinCode,
        );

        final User? user = (await _auth.signInWithCredential(credential)).user;

        if (user != null) {
          _checkUserAccount();
        }
      }

      //return;
    } on FirebaseAuthException catch (e) {
      QuickHelp.hideLoadingDialog(context);

      if (e.code == "web-context-cancelled") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "auth.canceled_phone".tr());
      } else if (e.code == "invalid-verification-code") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "auth.invalid_code".tr());
      } else if (e.code == "network-request-failed") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "no_internet_connection".tr());
      } else {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "try_again_later".tr());
      }
    }
  }

  // Login button clicked
  Future<void> _checkUserAccount() async {
    QueryBuilder<UserModel> queryBuilder =
        QueryBuilder<UserModel>(UserModel.forQuery());
    queryBuilder.whereEqualTo(UserModel.keyPhoneNumber, number.parseNumber());
    ParseResponse apiResponse = await queryBuilder.query();

    if (apiResponse.success && apiResponse.results != null) {
      UserModel userModel = apiResponse.results!.first;
      _processLogin(userModel.getUsername, userModel.getSecondaryPassword!);
    } else if (apiResponse.success && apiResponse.results == null) {
      signUpUser();
    } else if (apiResponse.error!.code == DatooException.objectNotFound) {
      signUpUser();
    } else {
      showError(apiResponse.error!.code);
    }
  }

  Future<void> _processLogin(String? username, String password) async {
    final user = ParseUser(username, password, null);

    var response = await user.login();

    if (response.success) {
      showSuccess();
    } else {
      showError(response.error!.code);
    }
  }

  Future<void> showSuccess() async {
    QuickHelp.hideLoadingDialog(context);

    UserModel? currentUser = await ParseUser.currentUser();
    if (currentUser != null) {
      QuickHelp.goToNavigatorScreen(
          context,
          DispacheScreen(
            currentUser: currentUser,
            preferences: preferences,
          ),
          finish: true,
          back: false);
    }
  }

  void showError(int error) {
    QuickHelp.hideLoadingDialog(context);

    if (error == DatooException.connectionFailed) {
      QuickHelp.showAppNotificationAdvanced(
          context: context, title: "error".tr(), message: "not_connected".tr());
    } else if (error == DatooException.accountBlocked) {
      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "error".tr(),
          message: "auth.account_blocked".tr());
    } else if (error == DatooException.accountDeleted) {
      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "error".tr(),
          message: "auth.account_deleted".tr());
    } else {
      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "error".tr(),
          message: "auth.invalid_credentials".tr());
    }
  }

  nextPosition() {
    setState(() {
      position = position + 1;
    });
  }

  previousPosition() {
    setState(() {
      position = position - 1;
    });
  }

  Future<void> googleLogin() async {
    try {
      GoogleSignInAccount? account = await _googleSignIn.signIn();
      GoogleSignInAuthentication authentication = await account!.authentication;

      QuickHelp.showLoadingDialog(context);

      final ParseResponse response = await ParseUser.loginWith(
          'google',
          google(authentication.accessToken!, _googleSignIn.currentUser!.id,
              authentication.idToken!));
      if (response.success) {
        UserModel? user = await ParseUser.currentUser();

        if (user != null) {
          if (user.getUid == null) {
            getGoogleUserDetails(user, account, authentication.idToken!);
          } else {
            SocialLogin.goHome(context, user, preferences);
          }
        } else {
          QuickHelp.hideLoadingDialog(context);
          QuickHelp.showAppNotificationAdvanced(
              context: context, title: "auth.gg_login_error".tr());
          await _googleSignIn.signOut();
        }
      } else {
        QuickHelp.hideLoadingDialog(context);
        QuickHelp.showAppNotificationAdvanced(
            context: context, title: response.error!.message);
        await _googleSignIn.signOut();
      }
    } catch (error) {
      if (error == GoogleSignIn.kSignInCanceledError) {
        QuickHelp.showAppNotificationAdvanced(
            context: context, title: "auth.gg_login_cancelled".tr());
      } else if (error == GoogleSignIn.kNetworkError) {
        QuickHelp.showAppNotificationAdvanced(
            context: context, title: "not_connected".tr());
      } else {
        QuickHelp.showAppNotificationAdvanced(
            context: context, title: "auth.gg_login_error".tr());
      }

      await _googleSignIn.signOut();
    }
  }

  void getGoogleUserDetails(
      UserModel user, GoogleSignInAccount googleUser, String idToken) async {
    Map<String, dynamic>? idMap = QuickHelp.getInfoFromToken(idToken);

    String firstName = idMap!["given_name"];
    String lastName = idMap["family_name"];

    String username =
        lastName.replaceAll(" ", "") + firstName.replaceAll(" ", "");

    user.setFullName = googleUser.displayName!;
    user.setGoogleId = googleUser.id;
    user.setFirstName = firstName;
    user.setLastName = lastName;
    user.username = username.toLowerCase().trim();
    user.setEmail = googleUser.email;
    user.setEmailPublic = googleUser.email;
    //user.setGender = await getGender();
    user.setUid = QuickHelp.generateUId();
    user.setPopularity = 0;
    user.setUserRole = UserModel.roleUser;
    user.setPrefMinAge = Setup.minimumAgeToRegister;
    user.setPrefMaxAge = Setup.maximumAgeToRegister;
    user.setLocationTypeNearBy = true;
    user.addCredit = Setup.welcomeCredit;
    user.setBio = Setup.bio;
    user.setHasPassword = false;
    //user.setBirthday = QuickHelp.getDateFromString(_userData!['birthday'], QuickHelp.dateFormatFacebook);
    ParseResponse response = await user.save();

    if (response.success) {
      SocialLogin.getPhotoFromUrl(
          context, user, googleUser.photoUrl!, preferences);
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showErrorResult(context, response.error!.code);
    }
  }

  Widget welcomePage() {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: ContainerCorner(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  Column(
                    children: [
                      ContainerCorner(
                          marginTop: 10,
                          //height: Responsive.isMobile(context) ? 250 : 380,
                          width: Responsive.isMobile(context) ? 250 : 380,
                          child: Image.asset("assets/images/ic_logo.png", width: 100, height: 100,),),
                      /*ContainerCorner(
                          //marginTop: 10,
                          //height: Responsive.isMobile(context) ? 250 : 380,
                          width: Responsive.isMobile(context) ? 250 : 380,
                          child: Image.asset("assets/images/ic_logo_name.png",
                            color: QuickHelp.isDarkModeNoContext() ? Colors.white : Colors.black,
                          )
                      ),*/
                    ],
                  ),
                  ButtonWithImage(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    height: 48,
                    marginLeft: 30,
                    marginRight: 30,
                    borderRadius: 60,
                    imageHeight: 25,
                    imageWidth: 25,
                    fontSize: 16,
                    imageName: "ic_icon.png",
                    imageColor: kContentColorLightTheme,
                    color: Colors.white,
                    textColor: Colors.black,
                    text: "auth.get_started".tr(),
                    fontWeight: FontWeight.bold,
                    //matchParent: true,
                    press: () {
                      showMobileDialog();
                      //showMobileModal();
                    },
                  ),
                  termsAndPrivacyMobile(),
                  Container(),
                ],
              ),
            ),
          ),
        ));
  }

  termsAndPrivacyMobile({Color? color}) {
    return ContainerCorner(
      child: Column(
        children: [
          TextWithTap(
            "auth.by_clicking".tr(),
            marginBottom: 20,
            textAlign: TextAlign.center,
            color: color,
          ),
          RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: [
                TextSpan(
                    style: TextStyle(
                        color: color != null
                            ? color
                            : QuickHelp.isDarkMode(context)
                                ? Colors.white
                                : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    text: "auth.privacy_policy".tr(),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        QuickHelp.goToWebPage(
                          context,
                          pageType: QuickHelp.pageTypePrivacy,
                          //pageUrl: Config.privacyPolicyUrl
                        );
                      }),
                TextSpan(
                    style: TextStyle(
                        color: color != null
                            ? color
                            : QuickHelp.isDarkMode(context)
                                ? Colors.white
                                : Colors.black,
                        fontSize: 16),
                    text: "and_".tr()),
                TextSpan(
                    style: TextStyle(
                        color: color != null
                            ? color
                            : QuickHelp.isDarkMode(context)
                                ? Colors.white
                                : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    text: "auth.terms_of_use".tr(),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        QuickHelp.goToWebPage(
                          context,
                          pageType: QuickHelp.pageTypeTerms,
                          //pageUrl: Config.termsOfUseUrl
                        );
                      }),
              ])),
        ],
      ),
      marginLeft: 5,
      marginRight: 5,
      marginBottom: 10,
    );
  }

  void showMobileDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: QuickHelp.isDarkMode(context)
                ? kContentColorLightTheme
                : Colors.white,
            content: showMobileLogin(),
            contentPadding: EdgeInsets.all(0),
            insetPadding: EdgeInsets.all(0),
            title: ContainerCorner(
              //marginTop: 10,
              //height: Responsive.isMobile(context) ? 250 : 380,
              width: Responsive.isMobile(context) ? 250 : 380,
              child: TextWithTap(
                "auth.login_method".tr(),
                textAlign: TextAlign.center,
              ), /*Image.asset(
                "assets/images/ic_logo_name.png",
                color: QuickHelp.isDarkModeNoContext()
                    ? Colors.white
                    : Colors.black,
              ),*/
            ),
          );
        });
  }

  void showMobileModal() async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showReportBottomSheet();
        });
  }

  void showPhoneLoginModal() async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showPhoneLoginBottomSheet();
        });
  }

  Widget _showReportBottomSheet() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.1,
            maxChildSize: 1.0,
            builder: (_, controller) {
              return StatefulBuilder(builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(
                    //color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(25.0),
                      topRight: const Radius.circular(25.0),
                    ),
                  ),
                  child: ContainerCorner(
                    radiusTopRight: 25.0,
                    radiusTopLeft: 25.0,
                    color: QuickHelp.isDarkMode(context)
                        ? kContentColorLightTheme.withOpacity(0.7)
                        : Colors.white.withOpacity(0.1),
                    child: Center(child: showMobileLogin()),
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _showPhoneLoginBottomSheet() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.1,
            maxChildSize: 1.0,
            builder: (_, controller) {
              return StatefulBuilder(builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(
                    //color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(25.0),
                      topRight: const Radius.circular(25.0),
                    ),
                  ),
                  child: ContainerCorner(
                    radiusTopRight: 25.0,
                    radiusTopLeft: 25.0,
                    color: QuickHelp.isDarkMode(context)
                        ? kContentColorLightTheme
                        : Colors.white,
                    child: phoneNumberInput(),
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }

  Widget showMobileLogin() {
    return ContainerCorner(
      height: 250,
      marginTop: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /*Visibility(
            visible: SharedManager().isPhoneLoginEnabled(preferences),
            child: ButtonWithSvg(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              height: 48,
              marginLeft: 30,
              marginRight: 30,
              marginBottom: 10,
              borderRadius: 60,
              svgHeight: 25,
              svgWidth: 25,
              fontSize: 16,
              svgName: "ic_google_login",
              color: Colors.white,
              textColor: Colors.black,
              //svgColor: Colors.white,
              text: "auth.phone_login".tr(),
              fontWeight: FontWeight.normal,
              //matchParent: true,
              press: () {
                QuickHelp.goBack(context);
                showPhoneLoginModal();
              },
            ),
          ),*/
          Visibility(
            visible: SharedManager().isGoogleLoginEnabled(preferences),
            child: ButtonWithSvg(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              height: 48,
              marginLeft: 30,
              marginRight: 30,
              marginBottom: 10,
              borderRadius: 60,
              svgHeight: 25,
              svgWidth: 25,
              fontSize: 16,
              svgName: "ic_google_login",
              color: Colors.white,
              textColor: Colors.black,
              //svgColor: Colors.white,
              text: "auth.google_login".tr(),
              fontWeight: FontWeight.normal,
              //matchParent: true,
              press: () {
                QuickHelp.goBack(context);
                googleLogin();
              },
            ),
          ),
          Visibility(
            visible: QuickHelp.isIOSPlatform() && SharedManager().isAppleLoginEnabled(preferences),
            child: ButtonWithSvg(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              height: 48,
              marginLeft: 30,
              marginRight: 30,
              marginBottom: 10,
              borderRadius: 60,
              svgHeight: 25,
              svgWidth: 25,
              fontSize: 16,
              svgName: "ic_apple_logo",
              color: Colors.white,
              textColor: Colors.black,
              //svgColor: Colors.white,
              text: "auth.apple_login".tr(),
              fontWeight: FontWeight.normal,
              //matchParent: true,
              press: () {
                QuickHelp.goBack(context);
                SocialLogin.loginApple(context, preferences);
              },
            ),
          ),
          Visibility(
            visible: SharedManager().isFacebookLoginEnabled(preferences),
            child: ButtonWithSvg(
              height: 48,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              marginLeft: 30,
              marginRight: 30,
              marginBottom: 20,
              borderRadius: 60,
              svgHeight: 25,
              svgWidth: 25,
              fontSize: 16,
              svgName: "ic_facebook_logo",
              color: Colors.white,
              textColor: Colors.black,
              text: "auth.facebook_login".tr(),
              fontWeight: FontWeight.normal,
              press: () {
                QuickHelp.goBack(context);
                SocialLogin.loginFacebook(context, preferences);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    QuickHelp.setWebPageTitle(context,
        "page_title.welcome_title".tr(namedArgs: {"app_name": Config.appName}));

    return welcomePage();
  }

  Widget phoneNumberInput() {
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Column(
        children: [
          TextWithTap(
            "auth.enter_phone_num".tr(),
            marginTop: 10,
            fontSize: 17,
            marginBottom: 30,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          InternationalPhoneNumberInput(
            inputDecoration: InputDecoration(
              hintText: "auth.phone_number_hint".tr(),
              hintStyle: QuickHelp.isDarkMode(context)
                  ? TextStyle(color: kColorsGrey500)
                  : TextStyle(color: kColorsGrey500),
              //border: InputBorder.none,
            ),
            //countries: Setup.allowedCountries,
            errorMessage: "auth.invalid_phone_number".tr(),
            searchBoxDecoration: InputDecoration(
              hintText: "auth.country_input_hint".tr(),
            ),
            onInputChanged: (PhoneNumber number) {
              //print(number.phoneNumber);
              this.number = number;
              this._phoneNumber = number.phoneNumber!;
            },
            onInputValidated: (bool value) {},
            countrySelectorScrollControlled: true,
            locale: Config.initialCountry,
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
            initialValue: number,
            countries: Setup.allowedCountries,
            textFieldController: phoneNumberEditingController,
            formatInput: true,
            autoFocus: true,
            autoFocusSearch: true,
            //hintText: number.phoneNumber,
            keyboardType:
                TextInputType.numberWithOptions(signed: false, decimal: false),
            inputBorder: OutlineInputBorder(),
            onSaved: (PhoneNumber number) {
              //print('On Saved: $number');
            },
          ),
          ButtonWithIcon(
            mainAxisAlignment: MainAxisAlignment.center,
            height: 45,
            marginTop: 25,
            marginBottom: 10,
            borderRadius: 60,
            fontSize: 14,
            textColor: Colors.white,
            backgroundColor: kColorsDeepOrange400,
            text: "next".tr().toUpperCase(),
            fontWeight: FontWeight.normal,
            onTap: () {
              if (_formKey.currentState!.validate()) {
                FocusManager.instance.primaryFocus?.unfocus();

                if (position == _positionPhoneInput) {
                  _sendVerificationCode(false);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget phoneCodeInput() {
    return Padding(
      padding: EdgeInsets.only(top: 40, left: 30, right: 30),
      child: Column(
        children: [
          TextWithTap(
            "auth.code_sent_to".tr(),
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          TextWithTap(
            _phoneNumber,
            marginTop: 20,
            //marginLeft: 40,
            marginBottom: 18,
            fontSize: 20,
            color: Colors.black,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.normal,
            marginRight: 10,
          ),
          TextWithTap(
            "auth.enter_code".tr(),
            marginTop: 20,
            marginBottom: 20,
            fontSize: 17,
            color: Colors.black,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.normal,
            onTap: () => _showResend ? _sendVerificationCode(true) : null,
          ),
          Container(
            child: PinCodeTextField(
              appContext: context,
              length: Setup.verificationCodeDigits,
              keyboardType: TextInputType.number,
              obscureText: false,
              animationType: AnimationType.fade,
              autoFocus: true,
              pinTheme: PinTheme(
                borderWidth: 2.0,
                shape: PinCodeFieldShape.underline,
                borderRadius: BorderRadius.zero,
                fieldHeight: 50,
                fieldWidth: 45,
                activeFillColor: Colors.transparent,
                inactiveFillColor: Colors.transparent,
                selectedFillColor: Colors.transparent,
                //errorBorderColor: Color(0xFFC7C7C7),
                activeColor: kPrimaryColor,
                inactiveColor: kDisabledColor,
                selectedColor: kDisabledGrayColor,
              ),
              animationDuration: Duration(milliseconds: 300),
              backgroundColor: Colors.transparent,
              enableActiveFill: true,
              controller: pinCodeEditingController,
              autovalidateMode: AutovalidateMode.always,
              validator: (value) {
                return null;
              },
              useHapticFeedback: true,
              hapticFeedbackTypes: HapticFeedbackTypes.selection,
              onChanged: (value) {
                print(value);
              },
              onCompleted: (v) {
                _pinCode = v;
                verifyCode(v);
              },
              beforeTextPaste: (text) {
                print("Allowing to paste $text");
                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                //but you can show anything you want here, like your pop up saying wrong paste format or etc
                return true;
              },
            ),
          ),
          ContainerCorner(
            marginTop: 3,
            marginRight: 4,
            color: Colors.transparent,
            child: Visibility(
              visible: !_showResend,
              child: CountDownTimer(
                countDownTimerStyle: TextStyle(
                    color: kGrayDark,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.normal,
                    fontSize: 14),
                text: "auth.resend_in".tr(),
                secondsRemaining: 30,
                whenTimeExpires: () {
                  setState(() {
                    _showResend = true;
                  });
                },
              ),
            ),
          ),
          Visibility(
            visible: _showResend,
            child: TextWithTap(
              "auth.resend_now".tr(),
              marginTop: 10,
              marginBottom: 5,
              color: kGrayDark,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.normal,
              fontSize: 14,
              onTap: () => _showResend ? _sendVerificationCode(true) : null,
            ),
          ),
          TextWithTap(
            "auth.edit_phone_number".tr(),
            marginTop: 10,
            marginBottom: 5,
            color: kGrayDark,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.normal,
            fontSize: 14,
            onTap: () => previousPosition(),
          ),
          TextWithTap(
            "auth.contact_support".tr(),
            marginTop: 10,
            marginBottom: 15,
            color: kPrimaryColor,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            onTap: () => QuickHelp.goToWebPage(context,
                pageType: QuickHelp.pageTypeHelpCenter),
          ),
        ],
      ),
    );
  }

  Future<void> signUpUser() async {
    var faker = Faker();

    String imageUrl =
        faker.image.image(width: 640, height: 640, keywords: ["nature"]);

    String password = QuickHelp.generateUId().toString();
    String username = number.parseNumber();

    UserModel user = UserModel(username, password, null);

    //user.setFullName = number.phoneNumber!;
    user.setFullName = ""; //faker.person.firstName();
    user.setSecondaryPassword = password;
    //user.setFirstName = username;
    user.setFirstName = ""; //faker.person.firstName();
    //user.setLastName = faker.person.lastName();
    user.username = username.toLowerCase();
    user.setPhotoVerified = true;
    //user.setNeedsChangeName = true;

    //user.setPhoneNumberFull = phoneNumber;

    //user.setCountry = country.name!;
    user.setCountryCode = number.isoCode!;
    user.setCountryDialCode = number.dialCode!;
    //user.setSchool = schoolEditingController.text;
    user.setPhoneNumber = username;
    user.setPhoneNumberFull = number.phoneNumber!;
    //user.setEmail = emailEditingController.text.trim();
    //user.setEmailPublic = emailEditingController.text.trim();
    //user.setGender = mySelectedGender;
    user.setUid = QuickHelp.generateUId();

    user.setUserRole = UserModel.roleUser;
    user.setPrefMinAge = Setup.minimumAgeToRegister;
    user.setPrefMaxAge = Setup.maximumAgeToRegister;
    user.setLocationTypeNearBy = true;
    user.addCredit = Setup.welcomeCredit;
    user.setBio = Setup.bio;
    user.setHasPassword = true;
    //user.setBirthday = QuickHelp.getDate(birthdayEditingController.text);

    ParseResponse userResult = await user.signUp(allowWithoutEmail: true);

    if (userResult.success) {
      getPhotoFromUrl(context, user, imageUrl, preferences);
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

  static void getPhotoFromUrl(BuildContext context, UserModel user, String url,
      SharedPreferences preferences) async {
    File avatar = await QuickHelp.downloadFile(url, "avatar.jpeg") as File;

    ParseFileBase parseFile;
    if (QuickHelp.isWebPlatform()) {
      //Seems weird, but this lets you get the data from the selected file as an Uint8List very easily.
      ParseWebFile file =
          ParseWebFile(null, name: "avatar.jpeg", url: avatar.path);
      await file.download();
      parseFile = ParseWebFile(file.file, name: file.name);
    } else {
      parseFile = ParseFile(File(avatar.path));
    }

    user.setAvatar = parseFile;
    //user.setAvatar1 = parseFile;

    final ParseResponse response = await user.save();
    if (response.success) {
      saveAgencyEarn(context, user, preferences);
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.goToNavigatorScreen(
          context,
          DispacheScreen(
            currentUser: user,
            preferences: preferences,
          ),
          finish: true,
          back: false);
    } else {
      saveAgencyEarn(context, user, preferences);
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.goToNavigatorScreen(
          context,
          DispacheScreen(
            currentUser: user,
            preferences: preferences,
          ),
          finish: true,
          back: false);
    }
  }

  static saveAgencyEarn(
      BuildContext context, UserModel user, SharedPreferences preferences) {
    if (SharedManager().getInvitee(preferences)!.isNotEmpty) {
      DynamicLinkService().registerInviteBy(
          user, SharedManager().getInvitee(preferences)!, context);
      SharedManager().clearInvitee(preferences);
    }
  }
}
