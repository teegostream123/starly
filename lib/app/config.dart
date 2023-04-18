import 'dart:ui';

class Config {
  static const String packageNameAndroid = "com.tiganlab.teego1";
  static const String packageNameiOS = "com.tiganlab.teego";
  static const String iosAppStoreId = "1631705048";
  static final String appName = "ustad jee";
  static final String appVersion = "1.0.0";
  static final String companyName = "Tigan, Lab";
  static final String appOrCompanyUrl = "https://tiganlab.com";
  static final String initialCountry = 'PK'; // United States

  static final String serverUrl = "https://parseapi.back4app.com/";
  static final String liveQueryUrl = "wss://teego.b4a.io";
  static final String appId = "HSnoUGSH5VrAik7tnZ9QrLi2TX5VugKptx8WHHh8";
  static final String clientKey = "x1fpB32UIrc91d1ztznVQuEC2olPEBAymcWqOBk2";

  static final String agoraAppId = "11537fc74b1d400dbfcda527011169c8";

  static final String pushGcm = "188663119667";
  static final String webPushCertificate =
      "BE5yAwjkDdQrXOUO534543543543543n0XEJl6Xf5zEJYIuIH08eC9IL4OQfsuLoaIwYM";

  // User support objectId
  static final String supportId = "WVp6hr1iTX";

  // Play Store and App Store public keys
  static final String publicGoogleSdkKey = "_";
  static final String publicIosSdkKey = "_";

  // Languages
  static String defaultLanguage = "en"; // English is default language.
  static List<Locale> languages = [
    Locale(defaultLanguage),
    //Locale('pt'),
    //Locale('fr')
  ];

  // Dynamic link
  static const String inviteSuffix = "invitee";
  static const String uriPrefix = "https://teego.page.link";
  static const String link = "https://teego.page.link";

  // Android Admob ad
  static const String admobAndroidOpenAppAd =
      "ca-app-pub-1084112649181796/8175353642";
  static const String admobAndroidHomeBannerAd =
      "ca-app-pub-1084112649181796/66935353347";
  static const String admobAndroidFeedNativeAd =
      "ca-app-pub-1084112649181796/436353592";
  static const String admobAndroidChatListBannerAd =
      "ca-app-pub-1084112649181796/335345104";
  static const String admobAndroidLiveBannerAd =
      "ca-app-pub-1084112649181796/172785349";
  static const String admobAndroidFeedBannerAd =
      "ca-app-pub-1084112649181796/6863535346";

  // iOS Admob ad
  static const String admobIOSOpenAppAd =
      "ca-app-pub-1084112649181796/632434508";
  static const String admobIOSHomeBannerAd =
      "ca-app-pub-1084112649181796/114347057";
  static const String admobIOSFeedNativeAd =
      "ca-app-pub-1084112649181796/7224533806";
  static const String admobIOSChatListBannerAd =
      "ca-app-pub-1084112649181796/58153458";
  static const String admobIOSLiveBannerAd =
      "ca-app-pub-1084112649181796/80953539063";
  static const String admobIOSFeedBannerAd =
      "ca-app-pub-1084112649181796/69053535815";

  // Web links for help, privacy policy and terms of use.
  static final String helpCenterUrl = "https://domain.com/help.html";
  static final String privacyPolicyUrl = "https://domain.com/privacy.html";
  static final String termsOfUseUrl = "https://domain.com/terms.html";
  static final String termsOfUseInAppUrl = "https://domain.com/terms.html";
  static final String dataSafetyUrl = "https://domain.com/help.hmtl";
  static final String openSourceUrl =
      "https://domain.com/third-party-license.html";
  static final String instructionsUrl = "https://domain.com/instructions.hmtl";
  static final String cashOutUrl = "https://domain.com/cashout.hmtl";
  static final String supportUrl = "https://support.domain.com/";

  // Google Play and Apple Pay In-app Purchases IDs
  static final String credit100 = "teego.100.credits";
  static final String credit200 = "teego.200.credits";
  static final String credit500 = "teego.500.credits";
  static final String credit1000 = "teego.1000.credits";
  static final String credit2100 = "teego.2100.credits";
  static final String credit5250 = "teego.5250.credits";
  static final String credit10500 = "teego.10500.credits";
}
