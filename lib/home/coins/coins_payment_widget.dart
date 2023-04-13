import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:teego/helpers/quick_actions.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/models/GiftsModel.dart';
import 'package:teego/models/PaymentsModel.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/models/others/in_app_model.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';

import '../../app/config.dart';

class CoinsFlowPayment {
  CoinsFlowPayment(
      {required BuildContext context,
      required UserModel currentUser,
      Function(GiftsModel giftsModel)? onGiftSelected,
      Function(int coins)? onCoinsPurchased,
      bool isDismissible = true,
      bool enableDrag = true,
      bool isScrollControlled = false,
      bool showOnlyCoinsPurchase = false,
      Color backgroundColor = Colors.transparent}) {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: isScrollControlled,
        backgroundColor: backgroundColor,
        enableDrag: enableDrag,
        isDismissible: isDismissible,
        builder: (context) {
          return _CoinsFlowWidget(
            currentUser: currentUser,
            onCoinsPurchased: onCoinsPurchased,
            onGiftSelected: onGiftSelected,
            showOnlyCoinsPurchase: showOnlyCoinsPurchase,
          );
        });
  }
}

// ignore: must_be_immutable
class _CoinsFlowWidget extends StatefulWidget {
  final Function? onCoinsPurchased;
  final Function? onGiftSelected;
  final bool? showOnlyCoinsPurchase;
  UserModel currentUser;

  _CoinsFlowWidget({
    required this.currentUser,
    this.onCoinsPurchased,
    this.onGiftSelected,
    this.showOnlyCoinsPurchase = false,
  });

  @override
  State<_CoinsFlowWidget> createState() => _CoinsFlowWidgetState();
}

class _CoinsFlowWidgetState extends State<_CoinsFlowWidget>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  int bottomSheetCurrentIndex = 0;

  late Offerings offerings;
  bool _isAvailable = false;
  bool _loading = true;
  InAppPurchaseModel? _inAppPurchaseModel;


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
  void initState() {
    super.initState();

    _animationController = AnimationController.unbounded(vsync: this);

    initProducts();
  }

  initProducts() async {
    try {
      offerings = await Purchases.getOfferings();

      if (offerings.current!.availablePackages.length > 0) {
        // Display packages for sale

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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _showGiftAndGetCoinsBottomSheet();
  }

  _purchaseProduct(InAppPurchaseModel inAppPurchaseModel) async{

    QuickHelp.showLoadingDialog(context);

    try {

      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        user: widget.currentUser,
        title: "in_app_purchases.coins_purchased"
            .tr(namedArgs: {"coins": _inAppPurchaseModel!.coins!.toString()}),
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
    paymentsModel.setAuthor = widget.currentUser;
    paymentsModel.setAuthorId = widget.currentUser.objectId!;
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

  showPendingUI() {
    QuickHelp.showLoadingDialog(context);
    print("InAppPurchase showPendingUI");
  }

  Widget _showGiftAndGetCoinsBottomSheet() {

    return StatefulBuilder(builder: (context, setState) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(25.0),
            topRight: const Radius.circular(25.0),
          ),
        ),
        child: ContainerCorner(
          color: kTransparentColor,
          child: IndexedStack(
            index: widget.showOnlyCoinsPurchase!
                ? 1
                : bottomSheetCurrentIndex,
            children: [
              Scaffold(
                backgroundColor: kTransparentColor,
                appBar: AppBar(
                  actions: [
                    ContainerCorner(
                      height: 30,
                      borderRadius: 50,
                      marginRight: 10,
                      marginTop: 10,
                      marginBottom: 10,
                      color: kWarninngColor,
                      onTap: () {
                        setState(() {
                          bottomSheetCurrentIndex = 1;
                        });
                      },
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: SvgPicture.asset(
                              "assets/svg/coin.svg",
                              width: 20,
                              height: 20,
                            ),
                          ),
                          TextWithTap(
                            "message_screen.get_coins".tr(),
                            marginRight: 10,
                          )
                        ],
                      ),
                    )
                  ],
                  backgroundColor: kTransparentColor,
                  centerTitle: true,
                  title: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/svg/ic_coin_with_star.svg",
                        width: 20,
                        height: 20,
                      ),
                      TextWithTap(
                        widget.currentUser.getCredits.toString(),
                        color: Colors.white,
                        fontSize: 16,
                        marginLeft: 5,
                      )
                    ],
                  ),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      ContainerCorner(
                          color: kTransparentColor,
                          child: _tabSection(context, setState)),
                    ],
                  ),
                ),
              ),
              Scaffold(
                backgroundColor: kTransparentColor,
                appBar: AppBar(
                  actions: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          "assets/svg/ic_coin_with_star.svg",
                          width: 20,
                          height: 20,
                        ),
                        TextWithTap(
                          widget.currentUser.getCredits.toString(),
                          color: Colors.white,
                          marginLeft: 5,
                          marginRight: 15,
                        )
                      ],
                    ),
                  ],
                  backgroundColor: kTransparentColor,
                  title: TextWithTap(
                    "message_screen.get_coins".tr(),
                    marginRight: 10,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  leading: BackButton(
                    onPressed: () {
                      if (widget.showOnlyCoinsPurchase!) {
                        Navigator.of(this.context).pop();
                      } else {
                        setState(() {
                          bottomSheetCurrentIndex = 0;
                        });
                      }
                    },
                  ),
                ),
                body: getBody(),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _tabSection(BuildContext context, StateSetter stateSetter) {
    return DefaultTabController(
      length: 9,
      child: Column(
        children: [
          Container(
            child: TabBar(
                isScrollable: true,
                enableFeedback: false,
                unselectedLabelColor: Colors.white.withOpacity(0.5),
                labelColor: Colors.white,
                indicatorColor: kTransparentColor,
                indicatorWeight: 0.005,
                tabs: [
                  gefTab("gift_tabs.tab_classic".tr(),
                      "assets/images/ic_gift_tab_classic.png"),
                  gefTab("gift_tabs.tab_3D".tr(),
                      "assets/images/ic_gift_tab_3b.png"),
                  gefTab("gift_tabs.tab_vip".tr(),
                      "assets/images/ic_gift_tab_vip.png"),
                  gefTab("gift_tabs.tab_love".tr(),
                      "assets/images/ic_gift_tab_love.png"),
                  gefTab("gift_tabs.tab_moods".tr(),
                      "assets/images/ic_gift_tab_moods.png"),
                  gefTab("gift_tabs.tab_artists".tr(),
                      "assets/images/ic_gift_tab_artist.png"),
                  gefTab("gift_tabs.tab_collectibles".tr(),
                      "assets/images/ic_gift_tab_collectibles.png"),
                  gefTab("gift_tabs.tab_games".tr(),
                      "assets/images/ic_gift_tab_games.png"),
                  gefTab("gift_tabs.tab_family".tr(),
                      "assets/images/ic_gift_tab_family.png"),
                ]),
          ),
          Container(
            //Add this to give height
            height: MediaQuery.of(context).size.height,
            child: TabBarView(children: [
              getGifts(GiftsModel.giftCategoryTypeClassic, stateSetter),
              getGifts(GiftsModel.giftCategoryType3D, stateSetter),
              getGifts(GiftsModel.giftCategoryTypeVIP, stateSetter),
              getGifts(GiftsModel.giftCategoryTypeLove, stateSetter),
              getGifts(GiftsModel.giftCategoryTypeMoods, stateSetter),
              getGifts(GiftsModel.giftCategoryTypeArtists, stateSetter),
              getGifts(GiftsModel.giftCategoryTypeCollectibles, stateSetter),
              getGifts(GiftsModel.giftCategoryTypeGames, stateSetter),
              getGifts(GiftsModel.giftCategoryTypeFamily, stateSetter),
            ]),
          ),
        ],
      ),
    );
  }

  Widget getGifts(String category, StateSetter setState) {
    QueryBuilder<GiftsModel> giftQuery = QueryBuilder<GiftsModel>(GiftsModel());
    giftQuery.whereValueExists(GiftsModel.keyGiftCategories, true);
    giftQuery.whereEqualTo(GiftsModel.keyGiftCategories, category);

    return ContainerCorner(
      color: kTransparentColor,
      child: ParseLiveGridWidget<GiftsModel>(
        query: giftQuery,
        crossAxisCount: 4,
        reverse: false,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        lazyLoading: false,
        //childAspectRatio: 1.0,
        shrinkWrap: true,
        listenOnAllSubItems: true,
        duration: Duration(seconds: 0),
        animationController: _animationController,
        childBuilder: (BuildContext context,
            ParseLiveListElementSnapshot<GiftsModel> snapshot) {
          GiftsModel gift = snapshot.loadedData!;
          return GestureDetector(
            onTap: () => _checkCredits(gift, setState),
            child: Column(
              children: [
                Lottie.network(gift.getFile!.url!,
                    width: 60, height: 60, animate: true, repeat: true),
                ContainerCorner(
                  color: kTransparentColor,
                  marginTop: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/svg/ic_coin_with_star.svg",
                        width: 18,
                        height: 18,
                      ),
                      TextWithTap(
                        gift.getCoins.toString(),
                        color: Colors.white,
                        fontSize: 14,
                        marginLeft: 5,
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        queryEmptyElement: Padding(
          padding: EdgeInsets.all(8.0),
          child: QuickActions.noContentFound(
              "live_streaming.no_gift_title".tr(),
              "live_streaming.no_gift_explain".tr(),
              "assets/svg/ic_menu_gifters.svg",
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center),
        ),
        gridLoadingElement: Container(
          margin: EdgeInsets.only(top: 50),
          alignment: Alignment.topCenter,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Tab gefTab(String name, String image) {
    return Tab(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            image,
            color: Colors.white.withOpacity(0.7),
            width: 20,
            height: 20,
          ),
          TextWithTap(
            name,
            fontSize: 12,
            marginTop: 5,
          ),
        ],
      ),
    );
  }

  Widget getBody() {

    if (_loading) {
      return QuickHelp.appLoading();
    } else if (_isAvailable) {
      return ContainerCorner(
        color: kTransparentColor,
        marginLeft: 5,
        marginRight: 5,
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.6,
          children: List.generate(
            getInAppList().length,
                (index) {
              InAppPurchaseModel inApp = getInAppList()[index];

              return GestureDetector(
                onTap: () {
                  _inAppPurchaseModel = inApp;
                  _purchaseProduct(inApp);
                },
                child: ContainerCorner(
                    color: Colors.black.withOpacity(0.6),
                    height: 250,
                    borderRadius: 10,
                    child: Stack(
                        alignment: AlignmentDirectional.bottomEnd,
                        children: [
                          if (inApp.type == InAppPurchaseModel.typePopular)
                            Image.asset("assets/images/cashier_popular.png"),
                          if (inApp.type == InAppPurchaseModel.typeHot)
                            Image.asset("assets/images/cashier_hot.png"),
                          Positioned(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextWithTap(
                                  inApp.coins.toString(),
                                  marginLeft: 10,
                                  marginBottom: 10,
                                  marginTop: 5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                                Image.asset(
                                  inApp.image!,
                                  width: 400,
                                  height: 70,
                                ),
                                TextWithTap(
                                  inApp.price!,
                                  marginTop: 10,
                                  marginBottom: 5,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.white,
                                ),
                                inApp.discount != null
                                    ? TextWithTap(
                                  "${inApp.currencySymbol} ${inApp.discount}",
                                  marginBottom: 5,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  decoration:
                                  TextDecoration.lineThrough,
                                  color: kGrayColor,
                                )
                                    : Container(),
                                TextWithTap(
                                  inApp.type == InAppPurchaseModel.typePopular
                                      ? 'coins.popular_'.tr()
                                      : inApp.type ==
                                      InAppPurchaseModel.typeHot
                                      ? 'coins.hot_'.tr()
                                      : "",
                                  color: Colors.white,
                                  fontSize: 17,
                                  marginTop: 3,
                                  fontWeight: FontWeight.bold,
                                  //marginTop: 5,
                                ),
                              ],
                            ),
                          ),
                        ])),
              );
            },
          ),
        ),
      );
    } else {
      return QuickActions.noContentFound(
          "in_app_purchases.no_product_found_title".tr(),
          "in_app_purchases.no_product_found_explain".tr(),
          "assets/svg/ic_tab_coins_default.svg");
    }
  }

  _checkCredits(GiftsModel gift, StateSetter setState) {
    if (widget.currentUser.getCredits! >= gift.getCoins!) {
      if (widget.onGiftSelected != null) {
        widget.onGiftSelected!(gift) as void Function()?;
        Navigator.of(context).pop();
      }
    } else {
      setState(() {
        bottomSheetCurrentIndex = 1;
      });
    }
  }
}
