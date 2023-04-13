import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:teego/app/Config.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/utils/colors.dart';

import '../../helpers/quick_actions.dart';
import '../../models/PaymentsModel.dart';
import '../../models/others/in_app_model.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';

// ignore: must_be_immutable
class CoinsScreen extends StatefulWidget {

  static String route = "/home/coins/purchase";

  UserModel? currentUser;

  CoinsScreen({this.currentUser});

  @override
  _CoinsScreenState createState() => _CoinsScreenState();
}

class _CoinsScreenState extends State<CoinsScreen> {

  void getUser() async{
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

  List<InAppPurchaseModel> getInAppList() {

    List<Package> myProductList = offerings.current!.availablePackages;

    List<InAppPurchaseModel> inAppPurchaseList = [];

    for (Package package in myProductList) {

      if (package.identifier == Config.credit200) {
        InAppPurchaseModel credits200 = InAppPurchaseModel(
            id: Config.credit200,
            coins: 200,
            price: package.storeProduct.priceString,
            image: "assets/images/ic_coins_4.png",
            type: InAppPurchaseModel.typeNormal,
            storeProduct: package.storeProduct,
            package: package,
            currency: package.storeProduct.currencyCode,
            currencySymbol: package.storeProduct.currencyCode);

        if (!inAppPurchaseList.contains(Config.credit200)) {
          inAppPurchaseList.add(credits200);
        }
      }

      if (package.identifier == Config.credit1000) {
        InAppPurchaseModel credits1000 = InAppPurchaseModel(
            id: Config.credit1000,
            coins: 1000,
            price: package.storeProduct.priceString,
            image: "assets/images/ic_coins_1.png",
            discount: (package.storeProduct.price*1.1).toStringAsFixed(2),
            type: InAppPurchaseModel.typeNormal,
            storeProduct: package.storeProduct,
            package: package,
            currency: package.storeProduct.currencyCode,
            currencySymbol: package.storeProduct.currencyCode);

        if (!inAppPurchaseList.contains(Config.credit1000)) {
          inAppPurchaseList.add(credits1000);
        }
      }

      if (package.identifier == Config.credit100) {
        InAppPurchaseModel credits100 = InAppPurchaseModel(
            id: Config.credit100,
            coins: 100,
            price: package.storeProduct.priceString,
            image: "assets/images/ic_coins_3.png",
            type: InAppPurchaseModel.typeNormal,
            storeProduct: package.storeProduct,
            package: package,
            currency: package.storeProduct.currencyCode,
            currencySymbol: package.storeProduct.currencyCode);

        if (!inAppPurchaseList.contains(Config.credit100)) {
          inAppPurchaseList.add(credits100);
        }
      }

      if (package.identifier == Config.credit500) {
        InAppPurchaseModel credits500 = InAppPurchaseModel(
            id: Config.credit500,
            coins: 500,
            price: package.storeProduct.priceString,
            image: "assets/images/ic_coins_6.png",
            type: InAppPurchaseModel.typeNormal,
            storeProduct: package.storeProduct,
            discount: (package.storeProduct.price*1.1).toStringAsFixed(2),
            package: package,
            currency: package.storeProduct.currencyCode,
            currencySymbol: package.storeProduct.currencyCode);

        if (!inAppPurchaseList.contains(Config.credit500)) {
          inAppPurchaseList.add(credits500);
        }
      }

      if (package.identifier == Config.credit2100) {
        InAppPurchaseModel credits2100 = InAppPurchaseModel(
            id: Config.credit2100,
            coins: 2100,
            price: package.storeProduct.priceString,
            discount: (package.storeProduct.price*1.2).toStringAsFixed(2),
            image: "assets/images/ic_coins_5.png",
            type: InAppPurchaseModel.typeNormal,
            storeProduct: package.storeProduct,
            package: package,
            currency: package.storeProduct.currencyCode,
            currencySymbol: package.storeProduct.currencyCode);

        if (!inAppPurchaseList.contains(Config.credit2100)) {
          inAppPurchaseList.add(credits2100);
        }
      }

      if (package.identifier == Config.credit5250) {
        InAppPurchaseModel credits5250 = InAppPurchaseModel(
            id: Config.credit5250,
            coins: 5250,
            price: package.storeProduct.priceString,
            discount: (package.storeProduct.price*1.3).toStringAsFixed(2),
            image: "assets/images/ic_coins_7.png",
            type: InAppPurchaseModel.typeNormal,
            storeProduct: package.storeProduct,
            package: package,
            currency: package.storeProduct.currencyCode,
            currencySymbol: package.storeProduct.currencyCode);

        if (!inAppPurchaseList.contains(Config.credit5250)) {
          inAppPurchaseList.add(credits5250);
        }
      }

      if (package.identifier == Config.credit10500) {
        InAppPurchaseModel credits10500 = InAppPurchaseModel(
            id: Config.credit10500,
            coins: 10500,
            price: package.storeProduct.priceString,
            discount: (package.storeProduct.price*1.4).toStringAsFixed(2),
            image: "assets/images/ic_coins_2.png",
            type: InAppPurchaseModel.typeNormal,
            storeProduct: package.storeProduct,
            package: package,
            currency: package.storeProduct.currencyCode,
            currencySymbol: package.storeProduct.currencyCode);

        if (!inAppPurchaseList.contains(Config.credit10500)) {
          inAppPurchaseList.add(credits10500);
        }
      }
    }

    return inAppPurchaseList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      QuickHelp.isDarkMode(context) ? kContentColorLightTheme : kGreyColor0,
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Container(
                    //color: Colors.white,
                    height: 40,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(children: [
                            TextSpan(
                              style: TextStyle(
                                fontSize: 20,
                                color: QuickHelp.isDarkMode(context)
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              text: "coins.get_coins".tr(),
                            ),
                            TextSpan(
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              text: "  ",
                            ),
                            TextSpan(
                              style: TextStyle(
                                fontSize: 16,
                                color: kGrayColor,
                              ),
                              text: "coins.to_support".tr(),
                            )
                          ])),
                    ),
                  )),
            ],
          ),
          Expanded(child: getBody()),
        ],
      ),
    );
  }


  Widget getBody() {

    if (_loading) {
      return QuickHelp.appLoading();
    } else if (_isAvailable) {

      return getProductList();

    } else {
      return QuickActions.noContentFound(
          "in_app_purchases.no_product_found_title".tr(),
          "in_app_purchases.no_product_found_explain".tr(),
          "assets/svg/ic_tab_coins_default.svg");
    }
  }

  Widget getProductList() {
    var size = MediaQuery.of(context).size;

    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: 100),
      children: [
        SizedBox(
          height: 3,
        ),
        Padding(
          padding: EdgeInsets.only(left: 5.0, right: 5),
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: List.generate(getInAppList().length, (index) {
              InAppPurchaseModel inApp = getInAppList()[index];

              return GestureDetector(
                onTap: () {
                  _inAppPurchaseModel = inApp;
                  _purchaseProduct(inApp);
                },
                child: Container(
                  padding: EdgeInsets.all(0.8),
                  width: (size.width - 15) / 2,
                  height: 260,
                  child: Stack(
                    children: [
                      Container(
                        width: (size.width - 15) / 2,
                        height: 260,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      ContainerCorner(
                          width: (size.width - 15) / 2,
                          borderColor: QuickHelp.isDarkMode(context)
                              ? kContentColorDarkTheme
                              : kTransparentColor,
                          height: 260,
                          borderRadius: 10,
                          color: QuickHelp.isDarkMode(context)
                              ? kContentColorLightTheme
                              : kContentColorDarkTheme,
                          child: Stack(
                              alignment: AlignmentDirectional.bottomEnd,
                              children: [
                                if (inApp.type == InAppPurchaseModel.typePopular)
                                  Image.asset(
                                      "assets/images/cashier_popular.png"),
                                if (inApp.type == InAppPurchaseModel.typeHot)
                                  Image.asset("assets/images/cashier_hot.png"),
                                Positioned(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      ContainerCorner(
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/svg/ic_coin_with_star.svg",
                                              width: 24,
                                              height: 24,
                                            ),
                                            TextWithTap(
                                              inApp.coins.toString(),
                                              marginLeft: 10,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ],
                                        ),
                                        color: kTransparentColor,
                                        marginTop: 20,
                                      ),
                                      ContainerCorner(
                                        height: 100,
                                        width: 150,
                                        color: kTransparentColor,
                                        marginTop: 20,
                                        marginBottom: index < 2 ? 3 : 10,
                                        child: Image.asset(inApp.image!),
                                      ),
                                      TextWithTap(
                                        inApp.price!,
                                        marginTop: inApp.type == InAppPurchaseModel.typePopular || inApp.type == InAppPurchaseModel.typeHot
                                            ? 2
                                            : 20,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                      inApp.discount != null
                                          ? TextWithTap(
                                        "${inApp.currencySymbol} ${inApp.discount}",
                                        marginTop: 2,
                                        color: kGrayColor,
                                        fontSize: 16,
                                        decoration:
                                        TextDecoration.lineThrough,
                                      )
                                          : Container(),
                                      if (inApp.type == InAppPurchaseModel.typePopular)
                                        TextWithTap(
                                          'coins.popular_'.tr(),
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          marginTop: 30,
                                        ),
                                      if (inApp.type == InAppPurchaseModel.typeHot)
                                        TextWithTap(
                                          'coins.hot_'.tr(),
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          marginTop: 30,
                                        )
                                    ],
                                  ),
                                ),
                              ]))
                    ],
                  ),
                ),
              );
            }),
          ),
        )
      ],
    );
  }

  _purchaseProduct(InAppPurchaseModel inAppPurchaseModel) async{

    QuickHelp.showLoadingDialog(context);

    try {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(context:context,
        user: widget.currentUser,
        title: "in_app_purchases.coins_purchased".tr(namedArgs: {"coins" : _inAppPurchaseModel!.coins!.toString()}),
        message: "in_app_purchases.coins_added_to_account".tr(),
        isError: false,
      );

    } on PlatformException catch (e) {

      var errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {

        QuickHelp.hideLoadingDialog(context);

        QuickHelp.showAppNotificationAdvanced(
          context:context,
          user: widget.currentUser,
          title: "in_app_purchases.purchase_cancelled_title".tr(),
          message: "in_app_purchases.purchase_cancelled".tr(),
        );

      } else if (errorCode != PurchasesErrorCode.invalidReceiptError) {

       _handleInvalidPurchase();

      } else {
        handleError(e);
      }
    }
  }

  void _handleInvalidPurchase() {

    QuickHelp.showAppNotification(context:context, title: "in_app_purchases.invalid_purchase".tr());
    QuickHelp.hideLoadingDialog(context);
  }

  void registerPayment(CustomerInfo customerInfo, InAppPurchaseModel productDetails) async {

    // Save all payment information
    PaymentsModel paymentsModel = PaymentsModel();
    paymentsModel.setAuthor = widget.currentUser!;
    paymentsModel.setAuthorId = widget.currentUser!.objectId!;
    paymentsModel.setPaymentType = PaymentsModel.paymentTypeConsumible;

    paymentsModel.setId = productDetails.id!;
    paymentsModel.setTitle = productDetails.storeProduct!.title;
    paymentsModel.setTransactionId = customerInfo.originalPurchaseDate!;
    paymentsModel.setCurrency = productDetails.currency!.toUpperCase();
    paymentsModel.setPrice = productDetails.price.toString();
    paymentsModel.setMethod = QuickHelp.isAndroidPlatform()? "Google Play" : QuickHelp.isIOSPlatform() ? "App Store" : "";
    paymentsModel.setStatus = PaymentsModel.paymentStatusCompleted;

    await paymentsModel.save();
  }

  void handleError(PlatformException error) {

    QuickHelp.hideLoadingDialog(context);
    QuickHelp.showAppNotification(context:context, title: error.message);
  }
}
