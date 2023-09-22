import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:teego/models/entitlement.dart';
import 'package:teego/home/coins/purchase_api.dart';

class RevenueCatProvider extends ChangeNotifier {
  factory RevenueCatProvider() => _instance;
  RevenueCatProvider._() {
    init();
  }

  static final RevenueCatProvider _instance = RevenueCatProvider._();

  int coins = 0;

  Entitlement _entitlement = Entitlement.free;
  Entitlement get entitlement => _entitlement;

  Future init() async {
    // Purchases.addPurchaserInfoUpdateListener((purchaserInfo) async {
    //   updatePurchaseStatus();
    // });
  }

  Future updatePurchaseStatus() async {
    // final purchaserInfo = await Purchases.getPurchaserInfo();

    // final entitlements = purchaserInfo.entitlements.active.values.toList();

    // entitlements.isEmpty ? Entitlement.free : Entitlement.allCourses;

    notifyListeners();
  }

  void addCoinsPackage(Package package) {
    switch (package.offeringIdentifier) {
      case Coins.idCoins50:
        coins += 50;
        break;
      case Coins.idCoins100:
        coins += 100;
        break;
      case Coins.idCoins200:
        coins += 200;

        break;
      case Coins.idCoins500:
        coins += 500;
        break;
    }
    notifyListeners();
  }

  void spend50Coins() {
    coins -= 50;

    notifyListeners();
  }

  void spend10Coins() {
    if (coins >= 10) {
      coins -= 10;
      notifyListeners();
    }
  }
}
