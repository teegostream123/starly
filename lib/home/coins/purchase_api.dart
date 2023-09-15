import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class Coins {
  static const idCoins50 = '50_coins';
  static const idCoins100 = '100_coins';
  static const idCoins200 = '200_coins';
  static const idCoins500 = '500_coins';

  static const allIds = [idCoins100, idCoins200, idCoins200, idCoins500];
}

class PurchaseApi {
  static const _apiKey = 'goog_VNeFGMeMYTOdcfvlwIybIlYpoGC';

  static Future init() async {
    await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup(_apiKey);
  }

  static Future<List<Offering>> fetchOffers() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      return current == null ? [] : [current];
    } on PlatformException catch (e) {
      return [];
    }
  }

  static Future<bool> purchasePackage(Package package) async {
    try {
      await Purchases.purchasePackage(package);
      return true;
    } catch (e) {
      return false;
    }
  }
}
