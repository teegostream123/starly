import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'UserModel.dart';

class PaymentSourceModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "PaymentSource";

  PaymentSourceModel() : super(keyTableName);
  PaymentSourceModel.clone() : this();

  @override
  PaymentSourceModel clone(Map<String, dynamic> map) => PaymentSourceModel.clone()..fromJson(map);

  static String platformStripe = "stripe";

  static String keyCreatedAt = "createdAt";
  static String keyUpdatedAt = "updatedAt";
  static String keyObjectId = "objectId";

  static String keyPlatform = "platform";

  static String keyId = "sourceId";
  static String keyObject = "object";
  static String keyBrand = "brand";
  static String keyCountry = "country";
  static String keyAuthor = "author";
  static String keyAuthorId = "authorId";
  static String keyCvcCheck = "cvc_check";

  static String keyExpMonth = "exp_month";
  static String keyExpYear = "exp_year";
  static String keyFingerprint = "fingerprint";
  static String keyFunding = "funding";
  static String keyLast4 = "last4";

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getPlatform => get<String>(keyPlatform);
  set setPlatform(String platform) => set<String>(keyPlatform, platform);

  String? get getId => get<String>(keyId);
  set setId(String id) => set<String>(keyId, id);

  String? get getPaymentMethod => get<String>(keyObject);
  set setPaymentMethod(String paymentMethod) => set<String>(keyObject, paymentMethod);

  String? get getBrand => get<String>(keyBrand);
  set setBrand(String brand) => set<String>(keyBrand, brand);

  String? get getCountry => get<String>(keyCountry);
  set setCountry(String country) => set<String>(keyCountry, country);

  String? get getCvcCheck => get<String>(keyCvcCheck);
  set setCvcCheck(String cvcCheck) => set<String>(keyCvcCheck, cvcCheck);

  int? get getExpMonth => get<int>(keyExpMonth);
  set setExpMonth(int expMonth) => set<int>(keyExpMonth, expMonth);

  int? get getExpYear => get<int>(keyExpYear);
  set setExpYear(int expYear) => set<int>(keyExpYear, expYear);

  String? get getFunding => get<String>(keyFunding);
  set setFunding(String funding) => set<String>(keyFunding, funding);

  String? get getLastDigits => get<String>(keyLast4);
  set setLastDigits(String lastDigits) => set<String>(keyLast4, lastDigits);

}