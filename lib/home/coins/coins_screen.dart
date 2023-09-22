import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:teego/app/Config.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/home/coins/paywall_widget.dart';
import 'package:teego/home/coins/purchase_api.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/models/others/in_app_model.dart';
import 'package:teego/providers/revenuecat.dart';
import 'package:teego/utils/colors.dart';
import 'package:teego/utils/colors.dart';

/////goog_VNeFGMeMYTOdcfvlwIybIlYpoGC

class CoinsScreen extends StatefulWidget {
  static String route = "/home/coins/purchase";

  UserModel? currentUser;

  CoinsScreen({this.currentUser});

  @override
  State<CoinsScreen> createState() => _CoinsScreenState();
}

class _CoinsScreenState extends State<CoinsScreen> {
  void getUser() async {
    widget.currentUser = await ParseUser.currentUser();
  }

  late Offerings offerings;
  bool _isAvailable = false;
  bool _loading = true;
  InAppPurchaseModel? _inAppPurchaseModel;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    QuickHelp.saveCurrentRoute(route: CoinsScreen.route);
    initProducts();

    super.initState();
  }

  initProducts() async {
    try {
      offerings = await Purchases.getOfferings();

      if (offerings.current!.availablePackages.length > 0) {
        setState(() {
          _isAvailable = true;
          _loading = false;
        });
        // Display packages for sale
      }
    } on PlatformException {
      // optional error handling

      setState(() {
        _isAvailable = false;
        _loading = false;
      });
    }
  }

  // List<InAppPurchaseModel> getInAppList() {
  //   List<Package> myProductList = offerings.current!.availablePackages;

  //   List<InAppPurchaseModel> inAppPurchaseList = [];

  //   for (Package package in myProductList) {
  //     if (package.identifier == Config.credit200) {
  //       InAppPurchaseModel credits200 = InAppPurchaseModel(
  //           id: Config.credit200,
  //           coins: 200,
  //           price: package.storeProduct.priceString,
  //           image: "assets/images/ic_coins_4.png",
  //           type: InAppPurchaseModel.typeNormal,
  //           storeProduct: package.storeProduct,
  //           package: package,
  //           currency: package.storeProduct.currencyCode,
  //           currencySymbol: package.storeProduct.currencyCode);

  //       if (!inAppPurchaseList.contains(Config.credit200)) {
  //         inAppPurchaseList.add(credits200);
  //       }
  //     }

  //     if (package.identifier == Config.credit1000) {
  //       InAppPurchaseModel credits1000 = InAppPurchaseModel(
  //           id: Config.credit1000,
  //           coins: 1000,
  //           price: package.storeProduct.priceString,
  //           image: "assets/images/ic_coins_1.png",
  //           discount: (package.storeProduct.price * 1.1).toStringAsFixed(2),
  //           type: InAppPurchaseModel.typeNormal,
  //           storeProduct: package.storeProduct,
  //           package: package,
  //           currency: package.storeProduct.currencyCode,
  //           currencySymbol: package.storeProduct.currencyCode);

  //       if (!inAppPurchaseList.contains(Config.credit1000)) {
  //         inAppPurchaseList.add(credits1000);
  //       }
  //     }

  //     if (package.identifier == Config.credit100) {
  //       InAppPurchaseModel credits100 = InAppPurchaseModel(
  //           id: Config.credit100,
  //           coins: 100,
  //           price: package.storeProduct.priceString,
  //           image: "assets/images/ic_coins_3.png",
  //           type: InAppPurchaseModel.typeNormal,
  //           storeProduct: package.storeProduct,
  //           package: package,
  //           currency: package.storeProduct.currencyCode,
  //           currencySymbol: package.storeProduct.currencyCode);

  //       if (!inAppPurchaseList.contains(Config.credit100)) {
  //         inAppPurchaseList.add(credits100);
  //       }
  //     }

  //     if (package.identifier == Config.credit500) {
  //       InAppPurchaseModel credits500 = InAppPurchaseModel(
  //           id: Config.credit500,
  //           coins: 500,
  //           price: package.storeProduct.priceString,
  //           image: "assets/images/ic_coins_6.png",
  //           type: InAppPurchaseModel.typeNormal,
  //           storeProduct: package.storeProduct,
  //           discount: (package.storeProduct.price * 1.1).toStringAsFixed(2),
  //           package: package,
  //           currency: package.storeProduct.currencyCode,
  //           currencySymbol: package.storeProduct.currencyCode);

  //       if (!inAppPurchaseList.contains(Config.credit500)) {
  //         inAppPurchaseList.add(credits500);
  //       }
  //     }

  //     if (package.identifier == Config.credit2100) {
  //       InAppPurchaseModel credits2100 = InAppPurchaseModel(
  //           id: Config.credit2100,
  //           coins: 2100,
  //           price: package.storeProduct.priceString,
  //           discount: (package.storeProduct.price * 1.2).toStringAsFixed(2),
  //           image: "assets/images/ic_coins_5.png",
  //           type: InAppPurchaseModel.typeNormal,
  //           storeProduct: package.storeProduct,
  //           package: package,
  //           currency: package.storeProduct.currencyCode,
  //           currencySymbol: package.storeProduct.currencyCode);

  //       if (!inAppPurchaseList.contains(Config.credit2100)) {
  //         inAppPurchaseList.add(credits2100);
  //       }
  //     }

  //     if (package.identifier == Config.credit5250) {
  //       InAppPurchaseModel credits5250 = InAppPurchaseModel(
  //           id: Config.credit5250,
  //           coins: 5250,
  //           price: package.storeProduct.priceString,
  //           discount: (package.storeProduct.price * 1.3).toStringAsFixed(2),
  //           image: "assets/images/ic_coins_7.png",
  //           type: InAppPurchaseModel.typeNormal,
  //           storeProduct: package.storeProduct,
  //           package: package,
  //           currency: package.storeProduct.currencyCode,
  //           currencySymbol: package.storeProduct.currencyCode);

  //       if (!inAppPurchaseList.contains(Config.credit5250)) {
  //         inAppPurchaseList.add(credits5250);
  //       }
  //     }

  //     if (package.identifier == Config.credit10500) {
  //       InAppPurchaseModel credits10500 = InAppPurchaseModel(
  //           id: Config.credit10500,
  //           coins: 10500,
  //           price: package.storeProduct.priceString,
  //           discount: (package.storeProduct.price * 1.4).toStringAsFixed(2),
  //           image: "assets/images/ic_coins_2.png",
  //           type: InAppPurchaseModel.typeNormal,
  //           storeProduct: package.storeProduct,
  //           package: package,
  //           currency: package.storeProduct.currencyCode,
  //           currencySymbol: package.storeProduct.currencyCode);

  //       if (!inAppPurchaseList.contains(Config.credit10500)) {
  //         inAppPurchaseList.add(credits10500);
  //       }
  //     }
  //   }

  //   return inAppPurchaseList;
  // }

  Future<List<Package>> fetchOffers() async {
    final offerings = await PurchaseApi.fetchOffersByIds(Coins.allIds);

    if (offerings.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No Plans Found')));

      return [];
    } else {
      final offer = offerings.first;

      final packages = offerings
          .map((offer) => offer.availablePackages)
          .expand((pair) => pair)
          .toList();

      print('Offerrrrrrrrrr: $packages');

      final _d = packages.map((e) => e.storeProduct.title);

      print(['titles are => $_d']);
      return packages;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kPrimaryColor,
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/ic_coins_6.png',
                  height: 150,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "You have ${Provider.of<RevenueCatProvider>(context).coins} Coins",
                style: TextStyle(fontSize: 23, color: Colors.white),
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () async {
                  final packages = await fetchOffers();
                  showModalBottomSheet(
                      context: context,
                      builder: (context) => PaywallWidget(
                          packages: packages,
                          title: 'Upgrade to a new plan ',
                          // description: 'to enjoy more benefits',
                          onClickedPackege: (package) async {
                            final isSuccess =
                                await PurchaseApi.purchasePackage(package);

                            if (isSuccess) {
                              final provider = Provider.of<RevenueCatProvider>(
                                  context,
                                  listen: false);
                              provider.addCoinsPackage(package);
                            }
                            Navigator.pop(context);
                          }));
                },
                child: Container(
                  height: height * .08,
                  width: width,
                  decoration: BoxDecoration(
                      color: kWarninngColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                      child: Text(
                    'Get More Coins',
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  )),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              // InkWell(
              //   onTap: () {
              //     final provider =
              //         Provider.of<RevenueCatProvider>(context, listen: false);
              //     provider.spend10Coins();
              //   },
              //   child: Container(
              //     decoration: BoxDecoration(
              //         color: Color(0xffe94a05),
              //         borderRadius: BorderRadius.circular(10)),
              //     height: height * .08,
              //     width: width,
              //     child: Center(
              //         child: Text(
              //       'Spend 10 Coins',
              //       style: TextStyle(fontSize: 22, color: Colors.white),
              //     )),
              //   ),
              // )
            ],
          )),
    );
  }
}


  // showModalBottomSheet(
                //     context: context,
                //     builder: (BuildContext context) {
                //       return Container(
                //           color: Colors.amber,
                //           width: width,
                //           child: Padding(
                //             padding: const EdgeInsets.all(15),
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: [
                //                 Container(
                //                   height: height * .1,
                //                   width: width,
                //                   color: Colors.deepOrange,
                //                   child: Center(
                //                     child: Text(
                //                       'Buy \$ Coins.',
                //                       style: TextStyle(
                //                           fontSize: 23, color: Colors.white),
                //                     ),
                //                   ),
                //                 ),
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //                 Container(
                //                   height: height * .1,
                //                   width: width,
                //                   color: Colors.deepOrange,
                //                   child: Center(
                //                     child: Text(
                //                       'Buy \$ Coins.',
                //                       style: TextStyle(
                //                           fontSize: 23, color: Colors.white),
                //                     ),
                //                   ),
                //                 ),
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //                 Container(
                //                   height: height * .1,
                //                   width: width,
                //                   color: Colors.deepOrange,
                //                   child: Center(
                //                     child: Text(
                //                       'Buy \$ Coins.',
                //                       style: TextStyle(
                //                           fontSize: 23, color: Colors.white),
                //                     ),
                //                   ),
                //                 ),
                //                 SizedBox(
                //                   height: 20,
                //                 ),
                //                 Container(
                //                   height: height * .1,
                //                   width: width,
                //                   color: Colors.deepOrange,
                //                   child: Center(
                //                     child: Text(
                //                       'Buy \$ Coins.',
                //                       style: TextStyle(
                //                           fontSize: 23, color: Colors.white),
                //                     ),
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ));
                //     });
