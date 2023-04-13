import 'package:teego/app/setup.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:easy_localization/easy_localization.dart';

class UserModel extends ParseUser implements ParseCloneable {

  UserModel(String? username, String? password, String? emailAddress)
      : super(username, password, emailAddress);

  UserModel.clone() : this(null, null, null);

  UserModel.forQuery() : super(null, null, null);

  @override
  clone(Map map) => UserModel.clone()..fromJson(map as Map<String, dynamic>);

  static Future<UserModel> getUserResult(dynamic user) async{

    UserModel? user = await ParseUser.currentUser();
    user = UserModel.clone()..fromJson(user as Map<String, dynamic>);

    return user;
  }

  static String keyObjectId = "objectId";

  static const WHAT_I_WANT_JUST_TO_CHAT = "JC";
  static const WHAT_I_WANT_SOMETHING_CASUAL = "SC";
  static const WHAT_I_WANT_SOMETHING_SERIOUS = "SS";
  static const WHAT_I_WANT_LET_SEE_WHAT_HAPPENS = "WH";

  static const RELATIONSHIP_COMPLICATED = "CP";
  static const RELATIONSHIP_SINGLE = "SG";
  static const RELATIONSHIP_TAKEN = "TK";

  static const SEXUALITY_STRAIGHT = "ST";
  static const SEXUALITY_GAY = "GY";
  static const SEXUALITY_BISEXUAL = "BS";
  static const SEXUALITY_LESBIAN = "LB";

  static const PASSIONS_CYCLING = "CCN";
  static const PASSIONS_FOODIE = "FOD";
  static const PASSIONS_SPIRITUALITY = "STY";
  static const PASSIONS_MOVIES = "MVS";
  static const PASSIONS_TECHNOLOGY = "TNY";
  static const PASSIONS_YOGA = "YGA";
  static const PASSIONS_GOG_LOVER = "GLR";
  static const PASSIONS_CROSSFIT = "CST";
  static const PASSIONS_SWIMMING = "SMG";
  static const PASSIONS_BRUNCH = "BNH";

  static const PASSIONS_Picniking = "PCN";
  static const PASSIONS_Tattoos = "TOO";
  static const PASSIONS_Volunteering = "VTG";
  static const PASSIONS_Art = "ART";
  static const PASSIONS_Activism = "ACM";
  static const PASSIONS_Vegetarian = "VRA";
  static const PASSIONS_Walking = "WLG";

  static const PASSIONS_Theater = "THR";
  static const PASSIONS_Hiking = "HIN";
  static const PASSIONS_Blogging = "BLN";
  static const PASSIONS_Festivals = "FTL";
  static const PASSIONS_Dancing = "DAG";
  static const PASSIONS_Vlogging = "VGN";
  static const PASSIONS_Sushi = "SUI";
  static const PASSIONS_Craft_BEER = "CRR";
  static const PASSIONS_Soccer = "SCR";
  static const PASSIONS_Instagram = "ITM";

  static const PASSIONS_Baking = "BNG";
  static const PASSIONS_Snowboarding = "SRG";
  static const PASSIONS_Outdoors = "OOR";
  static const PASSIONS_Board = "BRD";
  static const PASSIONS_enviro = "ERO";
  static const PASSIONS_Surfing = "SNG";
  static const PASSIONS_Writer = "WTR";
  static const PASSIONS_Wine = "WNE";
  static const PASSIONS_Museum = "MUM";
  static const PASSIONS_Astrology = "ALY";
  static const PASSIONS_Sports = "SRS";

  static const PASSIONS_Tiktok = "TKT";
  static const PASSIONS_Diy = "DIY";
  static const PASSIONS_Disney = "DNY";
  static const PASSIONS_Apple = "APL";
  static const PASSIONS_Plant = "PAT";
  static const PASSIONS_Karaoke = "KAK";
  static const PASSIONS_CAT_LOVER = "CTR";
  static const PASSIONS_Photography = "PTA";
  static const PASSIONS_Gamer = "GMR";

  static const PASSIONS_Trivia = "TVI";
  static const PASSIONS_Music = "MIC";
  static const PASSIONS_Travel = "TVL";
  static const PASSIONS_Coffee = "CFE";
  static const PASSIONS_Language = "LGA";
  static const PASSIONS_Designer = "DNR";
  static const PASSIONS_Tea = "TEA";


  static const SEXUALITY_ASEXUAL = "AS";
  static const SEXUALITY_DEMI_SEXUAL = "DS";
  static const SEXUALITY_PAN_SEXUAL = "PS";
  static const SEXUALITY_QUEER = "QU";
  static const SEXUALITY_ASK_ME = "AM";

  static const BODY_TYPE_ATHLETIC = "AT";
  static const BODY_TYPE_AVERAGE = "AV";
  static const BODY_TYPE_FEW_EXTRA_POUNDS = "EP";
  static const BODY_TYPE_MUSCULAR = "ML";
  static const BODY_TYPE_BIG_AND_BEAUTIFUL = "BB";
  static const BODY_TYPE_SLIM = "SL";

  static const LIVING_BY_MYSELF = "MS";
  static const LIVING_STUDENT_DORMITORY = "SD";
  static const LIVING_WITH_PARENTS = "PR";
  static const LIVING_WITH_PARTNER = "PN";
  static const LIVING_WITH_ROOMMATES = "RM";

  static const KIDS_GROWN_UP = "GU";
  static const KIDS_ALREADY_HAVE = "AH";
  static const KIDS_NO_NOVER = "NN";
  static const KIDS_SOMEDAY = "SY";

  static const SMOKING_IAM_A_HEAVY_SMOKER = "ES";
  static const SMOKING_I_HATE_SMOKING = "HS";
  static const SMOKING_I_DO_NOT_LIKE_IT = "DL";
  static const SMOKING_IAM_A_SOCIAL_SMOKER = "SM";
  static const SMOKING_I_SMOKE_OCCASIONALLY = "OC";

  static const DRINKING_I_DRINK_SOCIALLY = "DS";
  static const DRINKING_I_DO_NOT_DRINK = "DD";
  static const DRINKING_IAM_AGAINST_DRINKING = "AD";
  static const DRINKING_I_DRINK_A_LOT = "DT";

  static const ANY_USER = "AU";
  static const ONLY_MY_FRIENDS = "OF";

  static const PREMIUM_TYPE_FAN = "FAN";
  static const PREMIUM_TYPE_SUPER_FAN = "SUPER_FAN";

  // User role
  static final String roleUser = "user";
  static final String roleAdmin = "admin";

  // Filter
  static final String keyGenderMale = "male";
  static final String keyGenderFemale = "female";
  static final String keyGenderBoth = "both";

  static final String keyStatusAll = "all";
  static final String keyStatusOnline= "online";
  static final String keyStatusNew = "new";

  // Backend field
  static final String keyUid = "uid";
  static final String keyId = "objectId";
  static const String keySessionToken = 'sessionToken';
  static final String keyCreatedAt = "createdAt";
  static final String keyUpdatedAt = "updatedAt";
  static final String keyInstallation = "installation";

  // User sensitive data
  static final String keyRole = "role";
  static final String keyUsername = "username";
  static final String keyEmail = "email";
  static const String keyEmailPublic = 'email_public';
  static const String keyEmailVerified = 'emailVerified';
  static const String keySecondaryPassword = 'secondary_password';
  static final String keyHasPassword = "has_password";
  static final String keyHasChangedName = "has_name_changed";
  static final String keyAccountHidden = "account_hidden";

  // User required data
  static final String keyFullName = "name";
  static final String keyFirstName = "first_name";
  static final String keyLastName = "last_name";
  static final String keyBio = "bio";
  static final String keyBirthday = "birthday";
  static final String keyAge = "age";
  static final String keyGender = "gender";
  static final String keyAvatar = "avatar";
  static final String keyCover = "cover";

  // Phone data
  static final String keyCountry = "country";
  static final String keyCountryCode = "country_code";
  static final String keyCountryDialCode = "country_dial_code";
  static final String keyPhoneNumber = "phone_number";
  static final String keyPhoneNumberFull = "phone_number_full";

  // Social media fields
  static final String keyFacebookId = "fbId";
  static final String keyGoogleId = "ggId";
  static final String keyAppleId = "appleId";
  static final String keyInstagramId = "instaId";
  static final String keyInstagramLink = "instaLink";
  static final String keyInstagramToken = "instaToken";

  // User additional data
  static final String keyPhotoVerified = "photo_verified";
  static final String keyAboutMe = "aboutMe";
  static final String keyGeoPoint = "geopoint";
  static final String keyHasGeoPoint = "hasGeopoint";
  static final String keyLocation = "location";
  static final String keyCity = "city";
  static final String keyHideMyLocation = "hideLocation";
  static final String keyLastOnline = "lastOnline";
  static final String keyUserStatus = "activationStatus";
  static final String keyUserAccountDeleted = "accountDeleted";
  static final String keyUserAccountDeletedReason = "accountDeletedReason";
  static final String keyPopularity = "popularity";

  // User filter preferences
  static final String keyPrefLocationType = "prefLocationType";
  static final String keyPrefGender = "prefGender";
  static final String keyPrefStatus = "prefStatus";
  static final String keyPrefMinimumAge = "prefMinAge";
  static final String keyPrefMaximumAge = "prefMaxAge";
  static final String keyPrefDistance = "distanceFilter";

  // Vip and Premium features
  static final String keyPremiumLifeTime = "premium_lifetime";
  static final String keyPremium = "premium";
  static final String keyPremiumType = "premiumType";
  static final String keyCoins = "credit";
  static final String keyCoinsSent = "creditSent";
  static final String keyDiamonds = "diamonds";
  static final String keyDiamondsTotal = "diamondsTotal";

  static final String keyDiamondsAgency = "diamondsAgency";
  static final String keyDiamondsAgencyTotal = "diamondsAgencyTotal";

  // School and job
  static final String keyCompanyName = "company_name";
  static final String keyJobTitle = "job_title";
  static final String keySchool = "school";

  // Mood
  static final String keyMoodTitle = "mood";

  // Credits features to activate
  static final String vipAdsDisabled = "AdsDisabled";
  static final String vip3xPopular = "popular";
  static final String vipShowOnline = "showOnline";
  static final String vipExtraShows = "extraShows";
  static final String vipMoreVisits = "getMoreVisits";
  static final String vipMoveToTop = "moveToTop";

  // Premium invisible mode
  static final String vipInvisibleMode = "invisibleMode";
  static final String vipIsInvisible = "isInvisible";

  // Users blocks
  static final String keyBlockedUsers = "blockedUsers";
  static final String keyBlockedUserIDs = "blockedUsersIDs";

  // Privacy
  static final String keyPrivacyShowDistance = "privacyShowDistance";
  static final String keyPrivacyShowStatusOnline = "privacyShowOnlineStatus";

  // Edit profile
  static final String keyWhatIWant = "profile_honestly_want";
  static final String keyRelationship = "profile_relationship";
  static final String keySexuality = "profile_sexuality";
  static final String keyHeight = "profile_body_height";
  static final String keyBodyType = "profile_body_type";
  static final String keyLiving = "profile_living";
  static final String keyKids = "profile_kids";
  static final String keySmoking = "profile_smoking";
  static final String keyDrinking = "profile_drinking";
  static final String keyLanguage = "profile_language";

  static final String keyPassions = "profile_passions";
  static final String keySexualOrientations = "profile_sex_orientations";

  static final String keyShowGenderInProfile = "profile_show_gender";
  static final String keyShowSexualOrientationInProfile = "profile_show_sex_orientation";
  static final String keyDistanceInMiles = "profile_distance_miles";

  static final String keyFollowing = "following";
  static final String keyFollowers = "followers";
  static final String keyPayouts = "payouts";

  static final String keyReceiveChatRequest = "receiveChatRequest";
  static final String keyShowUpInSearch = "showUpInSearch";
  static final String keyShowVipLevel = "showVipLevel";
  static final String keyShowLocation = "showLocation";
  static final String keyShowLastTimeSeen = "showLastTimeSeen";
  static final String keyInvisibleMode = "invisibleMode";
  static final String keyShowMyPostsTo = "showMyPostsTo";

  static final String keySendReadReceipts = "sendReadReceipts";
  static final String keyEnableOneClickGifting = "enableOneClickGifting";
  static final String keyDenyBeInvitedToLiveParty = "denyBeInvitedToLiveParty";
  static final String keyDenyPictureInPictureMode = "denyPictureInPictureMode";
  static final String keyAllowViewersToPremiumStream = "allowViewersToPremiumStream";

  // Notifications
  static final String keyLiveNotification = "liveNotification";
  static final String keyMuteIncomingCalls = "muteIncomingCalls";
  static final String keyNotificationSounds = "notificationSounds";
  static final String keyInAppSound = "inAppSound";
  static final String keyInAppVibration = "inAppVibration";
  static final String keyGameNotification = "gameNotification";

  static final String keyReportedPostsIDs = "reportedPostsID";
  static final String keyReportedPostReason = "reportedPostReason";

  static final String keyPayoneerEmail= "payoneerEmail";
  static final String keyPayPalEmail= "paypalEmail";
  static final String keyIban= "Iban";
  static final String keyAccountName = "account_name";
  static final String keyBankName = "bank_name";

  static final String keyNeedsChangeName= "nameToChange";

  static final String keyInvitedUsers = "invitedUsers";
  static final String keyInvitedByUser = "invitedByUser";
  static final String keyInvitedAnswered = "inviteQuestion";


  String? get getSessionToken => get<String>(keySessionToken);

  int? get getUid => get<int>(keyUid);
  set setUid(int uid) => set<int>(keyUid, uid);

  String? get getUserRole => get<String>(keyRole);
  set setUserRole(String role) => set<String>(keyRole, role);

  String? get getUsername => get<String>(keyUsername);
  set setUsername(String username) => set<String>(keyUsername, username);

  String? get getEmail => get<String>(keyEmail);
  set setEmail(String email) => set<String>(keyEmail, email);

  String? get getEmailPublic => get<String>(keyEmailPublic);
  set setEmailPublic(String emailPublic) => set<String>(keyEmailPublic, emailPublic);

  String? get getFullName {
    String? name = get<String>(keyFullName);
    if(name != null){
      return name;
    } else {
      return getUsername;
    }
  }
  set setFullName(String fullName) => set<String>(keyFullName, fullName);

  String? get getFirstName => get<String>(keyFirstName);

  set setFirstName(String firstName) => set<String>(keyFirstName, firstName);

  String? get getLastName => get<String>(keyLastName);
  set setLastName(String lastName) => set<String>(keyLastName, lastName);

  String? get getGender => get<String>(keyGender);

  set setGender(String gender) => set<String>(keyGender, gender);

  String? get getGenderPref {

    String? prefGender = get<String>(keyPrefGender);
    if(prefGender != null){
      return prefGender;
    } else {
      return keyGenderBoth;
    }
  }
  set setGenderPref(String genderPref) => set<String>(keyPrefGender, genderPref);

  int? get getPrefDistance {

    int? prefDistance = get<int>(keyPrefDistance);
    if(prefDistance != null){
      return prefDistance;
    } else {
      return Setup.maxDistanceBetweenUsers;
    }
  }
  set setPrefDistance(int prefDistance) => set<int>(keyPrefDistance, prefDistance);

  String? get getBio => get<String>(keyBio);
  set setBio(String bio) => set<String>(keyBio, bio);

  ParseFileBase? get getAvatar => get<ParseFileBase>(keyAvatar);
  set setAvatar(ParseFileBase parseFileBase) => set<ParseFileBase>(keyAvatar, parseFileBase);

  ParseFileBase? get getCover => get<ParseFileBase>(keyCover);
  set setCover(ParseFileBase parseFileBase) => set<ParseFileBase>(keyCover, parseFileBase);

  DateTime? get getBirthday => get<DateTime>(keyBirthday);
  set setBirthday(DateTime birthday) => set<DateTime>(keyBirthday, birthday);

  DateTime? get getLastOnline => get<DateTime>(keyLastOnline);
  set setLastOnline(DateTime time) => set<DateTime>(keyLastOnline, time);

  bool? get getEmailVerified => get<bool>(keyEmailVerified);
  set setEmailVerified(bool emailVerified) => set<bool>(keyEmailVerified, emailVerified);

  bool? get getActivationStatus => get<bool>(keyUserStatus);
  set setActivationStatus(bool activated) => set<bool>(keyUserStatus, activated);

  bool? get getAccountDeleted => get<bool>(keyUserAccountDeleted);
  set setAccountDeleted(bool deleted) => set<bool>(keyUserAccountDeleted, deleted);

  String? get getFacebookId {
    String? content = get<String>(keyFacebookId);
    if(content != null && content.isNotEmpty){
      return content;
    } else {
      return "";
    }
  }
  set setFacebookId(String facebookId) => set<String>(keyFacebookId, facebookId);

  String? get getGoogleId {
    String? content = get<String>(keyGoogleId);
    if(content != null && content.isNotEmpty){
      return content;
    } else {
      return "";
    }
  }

  bool? get isAdmin {
    String? role = get<String>(keyRole);
    if(role != null && role.isNotEmpty){
      if(role == UserModel.roleAdmin){
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  bool? get isDeleted {
    bool? disabled = get<bool>(keyUserStatus);

    if(disabled != null && disabled){
      return true;
    }  else {
      return false;
    }
  }

  bool? get isSuspended {
    bool? deleted = get<bool>(keyUserAccountDeleted);
    if(deleted != null && deleted){
      return true;
    }  else {
      return false;
    }
  }

  bool? get isDeletedOrSuspended {

    if(isDeleted! || isSuspended!){
      return true;
    }  else {
      return false;
    }
  }

  String? get getAccountDeletedReason => get<String>(keyUserAccountDeletedReason);
  set setAccountDeletedReason(String reason) => set<String>(keyUserAccountDeletedReason, reason);


  set setGoogleId(String googleId) => set<String>(keyGoogleId, googleId);

  String? get getAppleId => get<String>(keyAppleId);
  set setAppleId(String appleId) => set<String>(keyAppleId, appleId);

  String? get getInstagramId => get<String>(keyInstagramId);
  set setInstagramId(String instagramId) => set<String>(keyInstagramId, instagramId);

  bool? get getHasPassword => get<bool>(keyHasPassword);
  set setHasPassword(bool hasPassword) => set<bool>(keyHasPassword, hasPassword);

  bool? get getHasGeoPoint {

    bool? hasGeoPoint = get<bool>(keyHasGeoPoint);
    if(hasGeoPoint != null){
      return hasGeoPoint;
    } else {
      return false;
    }
  }
  set setHasGeoPoint(bool hasGeoPoint) => set<bool>(keyHasGeoPoint, hasGeoPoint);

  bool? get getLocationTypeNearBy {

    bool? locationPref = get<bool>(keyPrefLocationType);
    if(locationPref != null){
      return locationPref;
    } else {
      return true;
    }
  }
  set setLocationTypeNearBy(bool prefLocationType) => set<bool>(keyPrefLocationType, prefLocationType);

  String? get getLocation {
    String? location = get<String>(keyLocation);
    if(location != null && location.isNotEmpty){

      if(this.getHideMyLocation == true){
        return "edit_profile.city_hidden".tr();
      } else {
        return location;
      }

    } else {
        return "edit_profile.no_location_update".tr();
    }
  }

  String? get getLocationOrEmpty {
    String? location = get<String>(keyLocation);
    if(location != null && location.isNotEmpty){
      return location;
    } else {
      return "";
    }
  }
  String? get getLocationOnly {
    String? location = get<String>(keyLocation);
    if(location != null && location.isNotEmpty){
      return location;
    } else {
      return "edit_profile.add_city_name".tr();
    }
  }
  set setLocation(String locationName) => set<String>(keyLocation, locationName);

  String? get getCity {
    String? city = get<String>(keyCity);
    if(city != null && city.isNotEmpty){
      return city;
    } else {
      return "";
    }
  }
  set setCity(String city) => set<String>(keyCity, city);

  int? get getPopularity => get<int>(keyPopularity);
  set setPopularity(int popularity) => set<int>(keyPopularity, popularity);

  int? get getPrefMinAge {
    int? prefAge = get<int>(keyPrefMinimumAge);
    if(prefAge != null){
      return prefAge;
    } else {
      return Setup.minimumAgeToRegister;
    }
  }
  set setPrefMinAge(int minAge) => set<int>(keyPrefMinimumAge, minAge);

  int? get getPrefMaxAge {
    int? prefAge = get<int>(keyPrefMaximumAge);
    if(prefAge != null){
      return prefAge;
    } else {
      return Setup.maximumAgeToRegister;
    }
  }
  set setPrefMaxAge(int maxAge) => set<int>(keyPrefMaximumAge, maxAge);

  int? get getCredits => get<int>(keyCoins);
  int? get getCreditsSent => get<int>(keyCoinsSent);
  set addCredit(int credits) => setIncrement(keyCoins, credits);
  //set removeCredit(int credits) => setDecrement(keyCoins, credits);
  set removeCredit(int credits){
    setDecrement(keyCoins, credits);
    setIncrement(keyCoinsSent, credits);
  }

  String? get getCountry {
    String? country = get<String>(keyCountry);
    if(country != null && country.isNotEmpty){
      return country;
    } else {
      return "";
    }
  }
  set setCountry(String country) => set<String>(keyCountry, country);

  String? get getCountryCode {
    String? code = get<String>(keyCountryCode);
    if(code != null && code.isNotEmpty){
      return code;
    } else {
      return "";
    }
  }
  set setCountryCode(String countryCode) => set<String>(keyCountryCode, countryCode);

  String? get getCountryDialCode => get<String>(keyCountryDialCode);
  set setCountryDialCode(String countryDialCode) => set<String>(keyCountryDialCode, countryDialCode);

  String? get getPhoneNumber {
    String? phone = get<String>(keyPhoneNumber);
    if(phone != null && phone.isNotEmpty){
      return phone;
    } else {
      return "";
    }
  }

  set setPhoneNumber(String phoneNumber) => set<String>(keyPhoneNumber, phoneNumber);


  set setPhoneNumberFull(String phoneNumberFull) => set<String>(keyPhoneNumberFull, phoneNumberFull);

  String? get getPhoneNumberFull {
    String? phone = get<String>(keyPhoneNumberFull);
    if(phone != null && phone.isNotEmpty){
      return phone;
    } else {
      return "";
    }
  }

  String? get getCompanyName {
    String? company = get<String>(keyCompanyName);
    if(company != null && company.isNotEmpty){
      return company;
    } else {
      return "";
    }
  }
  set setCompanyName(String companyName) => set<String>(keyCompanyName, companyName);

  String? get getJobTitle {

    String? job = get<String>(keyJobTitle);
    if(job != null && job.isNotEmpty){
      return job;
    } else {
      return "";
    }
  }
  set setJobTitle(String jobTitle) => set<String>(keyJobTitle, jobTitle);

  String? get getSchool {

    String? school = get<String>(keySchool);
    if(school != null && school.isNotEmpty){
      return school;
    } else {
      return "";
    }

  }
  set setSchool(String school) => set<String>(keySchool, school);

  String? get getAboutYou {

    String? about = get<String>(keyAboutMe);

    if(about != null && about.isNotEmpty){
      return about;

    } else {
      return "";
    }

  }
  set setAboutYou(String about) => set<String>(keyAboutMe, about);

  String? get getMoodTitle{
    String? mood = get<String>(keyMoodTitle);
    if(mood != null && mood.isNotEmpty){
      return mood;
    } else {
      return "";
    }
  }
  set setMoodTitle(String moodTitle) => set<String>(keyMoodTitle, moodTitle);

  bool? get isPhotoVerified {
    bool? photoVerified = get<bool>(keyPhotoVerified);
    if(photoVerified != null){
      return photoVerified;
    } else {
      return false;
    }
  }

  set setPhotoVerified(bool photoVerified) => set<bool>(keyPhotoVerified, photoVerified);

  bool? get isPremium {
    DateTime? premium = get<DateTime>(keyPremium);
    DateTime now = DateTime.now();
    if(premium != null){

      if(now.isBefore(premium)){
        return true;
      } else {
        return false;
      }

    } else {
      return false;
    }
  }

  DateTime? get getPremium => get<DateTime>(keyPremium);
  set setPremium(DateTime premium) => set<DateTime>(keyPremium, premium);

  DateTime? get getVipAdsDisabled => get<DateTime>(vipAdsDisabled);
  set setVipAdsDisabled(DateTime adsDisabled) => set<DateTime>(vipAdsDisabled, adsDisabled);

  DateTime? get getVip3xPopular => get<DateTime>(vip3xPopular);
  set setVip3xPopular(DateTime xPopular) => set<DateTime>(vip3xPopular, xPopular);

  DateTime? get getVipShowOnline => get<DateTime>(vipShowOnline);
  set setVipShowOnline(DateTime showOnline) => set<DateTime>(vipShowOnline, showOnline);

  DateTime? get getVipExtraShows => get<DateTime>(vipExtraShows);
  set setVipExtraShows(DateTime extraShows) => set<DateTime>(vipExtraShows, extraShows);

  DateTime? get getVipMoreVisits => get<DateTime>(vipMoreVisits);
  set setVipMoreVisits(DateTime moreVisits) => set<DateTime>(vipMoreVisits, moreVisits);

  DateTime? get getVipMoveToTop => get<DateTime>(vipMoveToTop);
  set setVipMoveToTop(DateTime moveToTop) => set<DateTime>(vipMoveToTop, moveToTop);

  bool? get getVipInvisibleMode => get<bool>(vipInvisibleMode);
  set setVipInvisibleMode(bool invisibleMode) => set<bool>(vipInvisibleMode, invisibleMode);

  bool? get getVipIsInvisible => get<bool>(vipIsInvisible);
  set setVipIsInvisible(bool isInvisible) => set<bool>(vipIsInvisible, isInvisible);

  set setNameChanged(bool nameChanged) => set<bool>(keyHasChangedName, nameChanged);

  bool? get getAccountHidden => get<bool>(keyAccountHidden);
  set setAccountHidden(bool accountHidden) => set<bool>(keyAccountHidden, accountHidden);

  List<dynamic>? get getBlockedUsers{

    List<dynamic>? users = get<List<dynamic>>(keyBlockedUsers);
    if(users != null){
      return users;
    } else {
      return [];
    }
  }
  set setBlockedUsers(List<UserModel> blockedUsers) => set<List<UserModel>>(keyBlockedUsers, blockedUsers);

  List<dynamic>? get getBlockedUsersIDs{

    List<dynamic>? users = get<List<dynamic>>(keyBlockedUserIDs);
    if(users != null){
      return users;
    } else {
      return [];
    }
  }

  set setBlockedUsersIDs(List<dynamic> blockedUsersIDs) => set<List<dynamic>>(keyBlockedUserIDs, blockedUsersIDs);

  set setBlockedUserIds(String blockedUser) {
    List<String> user = [];
    user.add(blockedUser);
    setAddAllUnique(keyBlockedUserIDs, user);
  }

  set removeBlockedUserIds(String blockedUser) {
    List<String> user = [];
    user.add(blockedUser);

    setRemoveAll(keyBlockedUserIDs, user);
  }

  List<dynamic>? get getBlockedUsersIds{

    List<String>? users = get<List<String>>(keyBlockedUsers);
    if(users != null){
      return users;
    } else {
      return [];
    }
  }

  set setBlockedUser(UserModel blockedUser) {
    List<UserModel> user = [];
    user.add(blockedUser);

    setAddAllUnique(keyBlockedUsers, user);
  }

  set removeBlockedUsers(List<UserModel> blockedUsers) {
    setRemoveAll(keyBlockedUsers, blockedUsers);
  }

  set removeBlockedUser(UserModel blockedUser) {
    List<UserModel> user = [];
    user.add(blockedUser);

    setRemoveAll(keyBlockedUsers, user);
  }

  bool? get getPrivacyShowDistance {

    bool? privacyShowDistance = get<bool>(keyPrivacyShowDistance);
    if(privacyShowDistance != null){
      return !privacyShowDistance;
    } else {
      return true;
    }
  }
  set setPrivacyShowDistance(bool privacyShowDistance) => set<bool>(keyPrivacyShowDistance, privacyShowDistance);

  bool? get getPrivacyShowStatusOnline {

    bool? privacyShowStatusOnline = get<bool>(keyPrivacyShowStatusOnline);
    if(privacyShowStatusOnline != null){
      return !privacyShowStatusOnline;
    } else {
      return true;
    }
  }
  set setPrivacyShowStatusOnline(bool privacyShowStatusOnline) => set<bool>(keyPrivacyShowStatusOnline, privacyShowStatusOnline);

  String? get getWhatIWant {

    String? what = get<String>(keyWhatIWant);
    if(what != null){
      return what;
    } else {
      return "";
    }
  }
  set setWhatIWant(String whatIWant) => set<String>(keyWhatIWant, whatIWant);

  String? get getLanguage {

    String? language = get<String>(keyLanguage);
    if(language != null){
      return language;
    } else {
      return "";
    }
  }
  set setLanguage(String language) => set<String>(keyLanguage, language);

  String? get getDrinking {

    String? drinking = get<String>(keyDrinking);
    if(drinking != null){
      return drinking;
    } else {
      return "";
    }
  }
  set setDrinking(String drinking) => set<String>(keyDrinking, drinking);

  String? get getSmoking {

    String? smoking = get<String>(keySmoking);
    if(smoking != null){
      return smoking;
    } else {
      return "";
    }
  }
  set setSmoking(String smoking) => set<String>(keySmoking, smoking);

  String? get getKids {

    String? kids = get<String>(keyKids);
    if(kids != null){
      return kids;
    } else {
      return "";
    }
  }
  set setKids(String kids) => set<String>(keyKids, kids);

  String? get getLiving {

    String? living = get<String>(keyLiving);
    if(living != null){
      return living;
    } else {
      return "";
    }
  }
  set setLiving(String living) => set<String>(keyLiving, living);

  String? get getBodyType {

    String? bodyType = get<String>(keyBodyType);
    if(bodyType != null){
      return bodyType;
    } else {
      return "";
    }
  }
  set setBodyType(String bodyType) => set<String>(keyBodyType, bodyType);

  int? get getHeight {

    int? height = get<int>(keyHeight);
    if(height != null){
      return height;
    } else {
      return 91;
    }
  }
  set setHeight(int height) => set<int>(keyHeight, height);

  String? get getSexuality {

    String? sexuality = get<String>(keySexuality);
    if(sexuality != null){
      return sexuality;
    } else {
      return "";
    }
  }
  set setSexuality(String sexuality) => set<String>(keySexuality, sexuality);

  String? get getRelationship {

    String? relationship = get<String>(keyRelationship);
    if(relationship != null){
      return relationship;
    } else {
      return "";
    }
  }
  set setRelationship(String relationship) => set<String>(keyRelationship, relationship);


  String? get getSecondaryPassword => get<String>(keySecondaryPassword);
  set setSecondaryPassword(String secondaryPassword) => set<String>(keySecondaryPassword, secondaryPassword);


  List<dynamic>? get getSexualOrientations {

    List<dynamic> sexualZero = [SEXUALITY_ASK_ME];

    List<dynamic>? sexualOrientation = get<List<dynamic>>(keySexualOrientations);
    if(sexualOrientation != null && sexualOrientation.length > 0){
      return sexualOrientation;
    } else {
      return sexualZero;
    }
  }
  set setSexualOrientations(List<String> sexualOrientations) => set<List<String>>(keySexualOrientations, sexualOrientations);

  List<dynamic>? get getPassions {

    List<dynamic> passionsZero = ["none"];

    List<dynamic>? passions = get<List<dynamic>>(keyPassions);
    if(passions != null && passions.length > 0){
      return passions;
    } else {
      return passionsZero;
    }
  }

  List<dynamic>? get getPassionsRealList {

    List<dynamic> passionsZero = [];

    List<dynamic>? passions = get<List<dynamic>>(keyPassions);
    if(passions != null && passions.length > 0){
      return passions;
    } else {
      return passionsZero;
    }
  }
  set setPassions(List<String> passions) => set<List<String>>(keyPassions, passions);

  bool? get getShowSexualOrientation => get<bool>(keyShowSexualOrientationInProfile);
  set setShowSexualOrientation(bool showSexualOrientation) => set<bool>(keyShowSexualOrientationInProfile, showSexualOrientation);

  bool? get getShowGenderInProfile => get<bool>(keyShowGenderInProfile);
  set setShowGenderInProfile(bool showGenderInProfile) => set<bool>(keyShowGenderInProfile, showGenderInProfile);

  bool? get getDistanceInMiles {

    bool? distanceInMiles = get<bool>(keyDistanceInMiles);
    if(distanceInMiles != null){
      return distanceInMiles;
    } else {
      return false;
    }

  }
  set setDistanceInMiles(bool distanceInMiles) => set<bool>(keyDistanceInMiles, distanceInMiles);

  bool? get getHideMyLocation {

    bool? hideMyLocation = get<bool>(keyHideMyLocation);
    if(hideMyLocation != null){
      return hideMyLocation;
    } else {
      return false;
    }
  }
  set setHideMyLocation(bool hideMyLocation) => set<bool>(keyHideMyLocation, hideMyLocation);

  ParseGeoPoint? get getGeoPoint => get<ParseGeoPoint>(keyGeoPoint);
  set setGeoPoint(ParseGeoPoint geoPoint) => set<ParseGeoPoint>(keyGeoPoint, geoPoint);

  int? get getAge => get<int>(keyAge);
  set setAge(int age) => set<int>(keyAge, age);

  int? get getDiamonds {

    int? token = get<int>(keyDiamonds);
    if(token != null){
      return token;
    } else {
      return 0;
    }
  }
  set setDiamonds(int diamonds) => setIncrement(keyDiamonds, diamonds);
  set removeDiamonds(int diamonds) => setDecrement(keyDiamonds, diamonds);

  int? get getDiamondsTotal {

    int? token = get<int>(keyDiamondsTotal);
    if(token != null){
      return token;
    } else {
      return 0;
    }
  }
  set setDiamondsTotal(int diamondsTotal) => setIncrement(keyDiamondsTotal, diamondsTotal);

  int? get getPayouts {

    int? payout = get<int>(keyPayouts);
    if(payout != null){
      return payout;
    } else {
      return 0;
    }
  }
  set setPayouts(int incrementPayout) => setIncrement(keyPayouts, incrementPayout);


  List? get getFollowing{

    List? following = get<List<dynamic>>(keyFollowing); //get<List<dynamic>>(keyFollowing);
    if(following != null && following.length > 0){
      return following;
    } else {
      return [];
    }
  }
  set setFollowing(String authorId) => setAddUnique(keyFollowing, authorId);
  set removeFollowing(String authorId) => setRemove(keyFollowing, authorId);

  List<dynamic>? get getFollowers{

    List<dynamic>? followers = get<List<dynamic>>(keyFollowers);
    if(followers != null && followers.length > 0){
      return followers;
    } else {
      return [];
    }
  }
  set setFollowers(String authorId) => setAddUnique(keyFollowers, authorId);
  set removeFollowers(String authorId) => setRemove(keyFollowers, authorId);

  bool? get getReceiveChatRequest{
    bool? receiveChatRequest = get<bool>(keyReceiveChatRequest);
    if(receiveChatRequest != null){
      return receiveChatRequest;
    } else {
      return false;
    }
  }
  set setReceiveChatRequest(bool receiveChatRequest) => set<bool>(keyReceiveChatRequest, receiveChatRequest);

  bool? get getShowUpInSearch{
    bool? showUpInSearch = get<bool>(keyShowUpInSearch);
    if(showUpInSearch != null){
      return showUpInSearch;
    }else{
      return false;
    }

  }
  set setShowUpInSearch(bool showUpInSearch) => set<bool>(keyShowUpInSearch, showUpInSearch);

  bool? get getShowVipLevel {
    bool? showVipLevel = get<bool>(keyShowVipLevel);
    if(showVipLevel != null){
      return showVipLevel;
    }else{
      return false;
    }
  }
  set setShowVipLevel(bool showVipLevel) => set<bool>(keyShowVipLevel, showVipLevel);

  bool? get getShowLocation {
    bool? showLocation = get<bool>(keyShowLocation);
    if(showLocation != null){
      return showLocation;
    }else{
      return false;
    }
  }
  set setShowLocation(bool showLocation) => set<bool>(keyShowLocation, showLocation);

  bool? get getShowLastTimeSeen{
    bool? showLastTimeSeen = get<bool>(keyShowLastTimeSeen);
    if(showLastTimeSeen != null){
      return showLastTimeSeen;
    }else{
      return false;
    }
  }
  set setShowLastTimeSeen(bool showLastTimeSeen) => set<bool>(keyShowLastTimeSeen, showLastTimeSeen);

  bool? get getInvisibleMode {
    bool? invisibleMode = get<bool>(keyInvisibleMode);
    if(invisibleMode != null){
      return invisibleMode;
    }else{
      return false;
    }
  }
  set setInvisibleMode(bool invisibleMode) => set<bool>(keyInvisibleMode, invisibleMode);

  String? get getShowMyPostsTo {
    String? showMyPostsTo = get<String>(keyShowMyPostsTo);
    if(showMyPostsTo != null){
      return showMyPostsTo;
    }else{
      return ANY_USER;
    }
  }
  set setShowMyPostsTo(String showMyPostsTo) => set<String>(keyShowMyPostsTo, showMyPostsTo);

  set setSendReadReceipts(bool sendReadReceipts) => set<bool>(keySendReadReceipts, sendReadReceipts);

  bool? get getSendReadReceipts{
    bool? sendReadReceipts = get<bool>(keySendReadReceipts);
    if(sendReadReceipts != null){
      return sendReadReceipts;
    }else{
      return false;
    }
  }

  set setEnableOneClickGifting(bool enableOneClickGifting) => set<bool>(keyEnableOneClickGifting, enableOneClickGifting);

  bool? get getEnableOneClickGifting{
    bool? enableOneClickGifting = get<bool>(keyEnableOneClickGifting);
    if(enableOneClickGifting != null){
      return enableOneClickGifting;
    }else{
      return false;
    }
  }

  set setDenyBeInvitedToLiveParty(bool denyBeInvitedToLiveParty) => set<bool>(keyDenyBeInvitedToLiveParty, denyBeInvitedToLiveParty);

  bool? get getDenyBeInvitedToLiveParty{
    bool? denyBeInvitedToLiveParty = get<bool>(keyDenyBeInvitedToLiveParty);
    if(denyBeInvitedToLiveParty != null){
      return denyBeInvitedToLiveParty;
    }else{
      return false;
    }
  }

  set setDenyPictureInPictureMode(bool denyPictureInPictureMode) => set<bool>(keyDenyPictureInPictureMode, denyPictureInPictureMode);

  bool? get getDenyPictureInPictureMode{
    bool? denyPictureInPictureMode = get<bool>(keyDenyPictureInPictureMode);
    if(denyPictureInPictureMode != null){
      return denyPictureInPictureMode;
    }else{
      return false;
    }
  }

  set setAllowViewersToPremiumStream(bool allowViewersToPremiumStream) => set<bool>(keyAllowViewersToPremiumStream, allowViewersToPremiumStream);

  bool? get getAllowViewersToPremiumStream{
    bool? allowViewersToPremiumStream = get<bool>(keyAllowViewersToPremiumStream);
    if(allowViewersToPremiumStream != null){
      return allowViewersToPremiumStream;
    }else{
      return false;
    }
  }

  set setLiveNotification(bool liveNotification) => set<bool>(keyLiveNotification, liveNotification);

  bool? get getLiveNotification{
    bool? liveNotification = get<bool>(keyLiveNotification);
    if(liveNotification != null){
      return liveNotification;
    }else{
      return true;
    }
  }

  set setMuteIncomingCalls(bool muteIncomingCalls) => set<bool>(keyMuteIncomingCalls, muteIncomingCalls);

  bool? get getMuteIncomingCalls{
    bool? muteIncomingCalls = get<bool>(keyMuteIncomingCalls);
    if(muteIncomingCalls != null){
      return muteIncomingCalls;
    }else{
      return true;
    }
  }

  set setNotificationSounds(bool notificationSounds) => set<bool>(keyNotificationSounds, notificationSounds);

  bool? get getNotificationSounds{
    bool? notificationSounds = get<bool>(keyNotificationSounds);
    if(notificationSounds != null){
      return notificationSounds;
    }else{
      return true;
    }
  }

  set setInAppSound(bool inAppSound) => set<bool>(keyInAppSound, inAppSound);

  bool? get getInAppSound{
    bool? inAppSound = get<bool>(keyInAppSound);
    if(inAppSound != null){
      return inAppSound;
    }else{
      return true;
    }
  }


  set setInAppVibration(bool inAppVibration) => set<bool>(keyInAppVibration, inAppVibration);

  bool? get getInAppVibration{
    bool? inAppVibration = get<bool>(keyInAppVibration);
    if(inAppVibration != null){
      return inAppVibration;
    }else{
      return true;
    }
  }

  set setGameNotification(bool gameNotification) => set<bool>(keyGameNotification, gameNotification);

  bool? get getGameNotification{
    bool? gameNotification = get<bool>(keyGameNotification);
    if(gameNotification != null){
      return gameNotification;
    }else{
      return true;
    }
  }



  List<dynamic>? get getReportedPostIDs{

    List<dynamic>? postID = get<List<dynamic>>(keyReportedPostsIDs);
    if(postID != null){
      return postID;
    } else {
      return [];
    }
  }

  set setReportedPostIDs(dynamic postID) {
    List<dynamic> postIdArray = [];
    postIdArray.add(postID);
    setAddAllUnique(keyReportedPostsIDs, postIdArray);
  }

  String? get getReportedPostReason => get<String>(keyReportedPostReason);
  set setReportedPostReason(String reason) => set<String>(keyReportedPostReason, reason);

  String? get getPayoneerEmail => get<String>(keyPayoneerEmail);
  set setPayEmail(String payEmail) => set<String>(keyPayoneerEmail, payEmail);

  String? get getPayPalEmail => get<String>(keyPayPalEmail);
  set setPayPalEmail(String payPalEmail) => set<String>(keyPayPalEmail, payPalEmail);

  String? get getIban => get<String>(keyIban);
  set setIban(String iban) => set<String>(keyIban, iban);

  String? get getAccountName => get<String>(keyAccountName);
  set setAccountName(String name) => set<String>(keyAccountName, name);

  String? get getBankName => get<String>(keyBankName);
  set setBankName(String bank) => set<String>(keyBankName, bank);

  dynamic get getInstallation => get(keyInstallation);
  set setInstallation(ParseInstallation installation) => set<ParseInstallation>(keyInstallation, installation);

  List? get getInvitedUsers{

    List? invited = get<List<dynamic>>(keyInvitedUsers);
    if(invited != null && invited.length > 0){
      return invited;
    } else {
      return [];
    }
  }

  bool? get getInvitedByAnswer => get<bool>(keyInvitedAnswered);
  set setInvitedByAnswer(bool invitedAnswer) => set<bool>(keyInvitedAnswered, invitedAnswer);

  String? get getInvitedByUser => get<String>(keyInvitedByUser);
  set setInvitedByUser(String invitedBy) => set<String>(keyInvitedByUser, invitedBy);

  String? get getPremiumType => get<String>(keyPremiumType);
  set setPremiumType(String premiumType) => set<String>(keyPremiumType, premiumType);

  int? get getDiamondsAgency {

    int? token = get<int>(keyDiamondsAgency);
    if(token != null){
      return token;
    } else {
      return 0;
    }
  }
  set setDiamondsAgency(int diamonds) => setIncrement(keyDiamondsAgency, diamonds);
  set removeDiamondsAgency(int diamonds) => setDecrement(keyDiamondsAgency, diamonds);

  int? get getDiamondsAgencyTotal {

    int? token = get<int>(keyDiamondsAgencyTotal);
    if(token != null){
      return token;
    } else {
      return 0;
    }
  }
  set setDiamondsAgencyTotal(int diamonds) => setIncrement(keyDiamondsAgencyTotal, diamonds);
  set removeDiamondsAgencyTotal(int diamonds) => setDecrement(keyDiamondsAgencyTotal, diamonds);
}