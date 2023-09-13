import 'package:teego/models/UserModel.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class WithdrawModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "Withdrawn";

  WithdrawModel() : super(keyTableName);
  WithdrawModel.clone() : this();

  @override
  WithdrawModel clone(Map<String, dynamic> map) => WithdrawModel.clone()..fromJson(map);

  static const PENDING = "pending";
  static const PROCESSING = "processing";
  static const COMPLETED = "completed";
  static const REFUSED = "refused";


  static const PAYONEER = "payoneer";
  static const PAYPAL = "paypal";
  static const IBAN = "IBAN";
  static const USDT = "USDT";

  static const CURRENCY = "USD";

  static const ethereum = "Ethereum (ERC20)";
  static const polygon = "Polygon";
  static const solana = "Solana";
  static const tron = "Tron (TRC20)";

  static final String keyAuthor = "author";
  static final String keyTokens = "diamonds";
  static final String keyAmount = "amount";
  static final String keyCompleted = "completed"; //false,true
  static final String keyStatus = "status"; // pending, processing, completed
  static final String keyEmail = "email";
  static final String keyMethod = "method";
  static final String keyCurrency = "currency";
  static final String keyIBAN = "IBAN";
  static final String keyAccountName = "account_name";
  static final String keyBankName = "bank_name";
  static final String keyPaidAt = "paidAt";

  static final String keyAddress = "usdt_address";
  static final String keyNetWork = "network";

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  set setDiamonds(int diamonds) => setIncrement(keyTokens, diamonds);
  int? get getDiamonds {
    int? diamond = get<int>(keyTokens);
    if(diamond != null){
      return diamond;
    } else {
      return 0;
    }
  }

  set setCredit(double amount) => setIncrement(keyAmount, amount);
  dynamic get getCredit {
    dynamic amount = get<dynamic>(keyAmount);
    if(amount != null){
      return amount;
    } else {
      return 0;
    }
  }

  set setCompleted(bool completed) => set<bool>(keyCompleted, completed);
  bool? get getCompleted{
    bool? completed = get<bool>(keyCompleted);
    if(completed != null){
      return completed;
    }else{
      return true;
    }
  }

  String? get getStatus => get<String>(keyStatus);
  set setStatus(String status) => set<String>(keyStatus, status);

  String? get getAccountName => get<String>(keyAccountName);
  set setAccountName(String name) => set<String>(keyAccountName, name);

  String? get getBankName => get<String>(keyBankName);
  set setBankName(String bank) => set<String>(keyBankName, bank);

  String? get getEmail => get<String>(keyEmail);
  set setEmail(String email) => set<String>(keyEmail, email);

  String? get getIBAN => get<String>(keyIBAN);
  set setIBAN(String iban) => set<String>(keyIBAN, iban);

  String? get getMethod => get<String>(keyMethod);
  set setMethod(String method) => set<String>(keyMethod, method);

  String? get getCurrency => get<String>(keyCurrency);
  set setCurrency(String currency) => set<String>(keyCurrency, currency);

  DateTime? get getPaidAt => get<DateTime>(keyPaidAt);
  set setPaidAt(DateTime dateTime) => set<DateTime>(keyPaidAt, dateTime);

  String? get getAddress => get<String>(keyAddress);
  set setAddress(String address) => set<String>(keyAddress, address);

  String? get getNetWork => get<String>(keyNetWork);
  set setNetWork(String netWork) => set<String>(keyNetWork, netWork);

}