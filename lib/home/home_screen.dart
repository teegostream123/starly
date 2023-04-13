import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teego/app/constants.dart';
import 'package:teego/helpers/quick_actions.dart';
import 'package:teego/home/reels/reels_home_screen.dart';
import 'package:teego/home/message/message_list_screen.dart';
import 'package:teego/home/coins/coins_rc_screen.dart';
import 'package:teego/home/feed/feed_home_screen.dart';
import 'package:teego/home/following/following_screen.dart';
import 'package:teego/home/profile/profile_edit.dart';
import 'package:teego/home/profile/profile_menu_screen.dart';
import 'package:teego/home/search/search_creen.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/providers/calls_providers.dart';
import 'package:teego/ui/app_bar_left_widget.dart';
import 'package:teego/ui/button_widget.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/utils/shared_manager.dart';
import 'package:teego/widgets/component.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../auth/welcome_screen.dart';
import 'admob/AppLifecycleReactor.dart';
import 'admob/AppOpenAdManager.dart';
import 'coins/refill_coins_screen.dart';
import 'live/live_screen.dart';
import 'notifications/notifications_screen.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  static const String route = '/home';

  UserModel? currentUser;
  SharedPreferences? preferences;

  HomeScreen({this.currentUser, required this.preferences});

  /* static of(BuildContext context, {bool root = false}) => root
      ? context.findRootAncestorStateOfType<_HomeScreenState>()
      : context.findAncestorStateOfType<_HomeScreenState>();*/

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late AppLifecycleReactor _appLifecycleReactor;

  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  @override
  void dispose() {
    super.dispose();
    _anchoredAdaptiveAd?.dispose();
  }

  Future<void> _loadAd() async {
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final AnchoredAdaptiveBannerAdSize? size =
    await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    } else {
      print('Got to get height of anchored banner.');
    }

    _anchoredAdaptiveAd = BannerAd(
      // TODO: replace these test ad units with your own ad unit.
      adUnitId: Constants.getAdmobHomeBannerUnit(),
      size: size,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$ad loaded: ${ad.responseInfo}');
          setState(() {
            // When the ad is loaded, get the ad size and use it to set
            // the height of the ad container.
            _anchoredAdaptiveAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Anchored adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    return _anchoredAdaptiveAd!.load();
  }

  TextEditingController inviteTextController = TextEditingController();
  bool hasNotification = false;

  int _selectedIndex = 0;
  double iconSize = 30;

  static bool appTrackingDialogShowing = false;

  double _getElevation() {
    if (_selectedIndex == 0) {
      return 0;
    } else {
      return 8;
    }
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    //getUser(updateLocation: false);
  }

  List<Widget> _widgetOptions() {
    //_checkNotifications();

    List<Widget> widgets = [
      LiveScreen(
        currentUser: widget.currentUser != null
            ? widget.currentUser
            : widget.currentUser,
        preferences: widget.preferences,
      ),
      FollowingScreen(
        currentUser: widget.currentUser != null
            ? widget.currentUser
            : widget.currentUser, preferences: widget.preferences,
      ),
      CoinsScreen(
        currentUser: widget.currentUser != null
            ? widget.currentUser
            : widget.currentUser,
      ),
      MessagesListScreen(
        currentUser: widget.currentUser != null
            ? widget.currentUser
            : widget.currentUser,
        preferences: widget.preferences,

      ),
     ReelsHomeScreen(
        currentUser: widget.currentUser != null
            ? widget.currentUser
            : widget.currentUser,
        preferences: widget.preferences,
      ),
      //ReelsPage(),
      /*FeedHomeScreen(
        currentUser: widget.currentUser != null
            ? widget.currentUser
            : widget.currentUser,
        preferences: widget.preferences,
      ),*/
    ];

    return widgets;
  }

  BottomNavigationBar bottomNavBar() {
    Color bgColor = QuickHelp.isDarkMode(context)
        ? kContentColorLightTheme
        : kContentColorDarkTheme;
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            backgroundColor: bgColor,
            icon: Component.buildNavIcon(
                QuickActions.showSVGAsset(
                  _selectedIndex == 0
                      ? 'assets/svg/ic_tab_live_selected.svg'
                      : 'assets/svg/ic_tab_live_default.svg',
                  height: iconSize,
                  width: iconSize,
                  color: _selectedIndex == 0 ? kTabIconSelectedColor : _selectedIndex == 4 ? Colors.white : QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
                ),
                0,
                false,
                context),
            label: "bottom_menu.menu_live".tr()),
        BottomNavigationBarItem(
            backgroundColor: bgColor,
            icon: Component.buildNavIcon(
                QuickActions.showSVGAsset(
                  _selectedIndex == 1
                      ? 'assets/svg/ic_tab_following_selected.svg'
                      : 'assets/svg/ic_tab_following_default.svg',
                  height: iconSize,
                  width: iconSize,
                  color: _selectedIndex == 1 ? kTabIconSelectedColor : _selectedIndex == 4 ? Colors.white : QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
                ),
                1,
                false,
                context,
                badge: 12),
            label: "bottom_menu.menu_following".tr()),
        BottomNavigationBarItem(
            backgroundColor: bgColor,
            icon: Component.buildNavIcon(
                Image.asset(
                  _selectedIndex == 2
                      ? 'assets/images/ic_home_coins.png' //'assets/svg/ic_tab_coins_selected.svg'
                      : 'assets/images/ic_home_coins.png',//'assets/svg/ic_tab_coins_default.svg',
                  height: iconSize,
                  width: iconSize,
                  color: _selectedIndex == 2 ? kTabIconSelectedColor : _selectedIndex == 4 ? Colors.white : QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
                ),
                2,
                false,
                context,
                color: 0xFF27E150,
                badge: 15),
            label: "bottom_menu.menu_coins".tr()),
        BottomNavigationBarItem(
          backgroundColor: bgColor,
          icon: Component.buildNavIcon(
              QuickActions.showSVGAsset(
                _selectedIndex == 3
                    ? 'assets/svg/ic_tab_chat_selected.svg'
                    : 'assets/svg/ic_tab_chat_default.svg',
                height: iconSize,
                width: iconSize,
                color: _selectedIndex == 3 ? kTabIconSelectedColor : _selectedIndex == 4 ? Colors.white : QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
              ),
              3,
              false,
              context),
          label: "bottom_menu.menu_chat".tr(),
        ),
        BottomNavigationBarItem(
          backgroundColor: bgColor,
          label: "bottom_menu.menu_feed".tr(),
          icon: Component.buildNavIcon(
              Image.asset(
                _selectedIndex == 4
                    ? 'assets/images/ic_home_reels.png' //'assets/svg/ic_tab_feed_selected.svg'
                    : 'assets/images/ic_home_reels.png', //'assets/svg/ic_tab_feed_default.svg',
                height: iconSize,
                width: iconSize,
                color: _selectedIndex == 4 ? kTabIconSelectedColor : QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
              ),
              3,
              false,
              context),
        ),
      ],
      type: BottomNavigationBarType.fixed,
      elevation: _getElevation(),
      currentIndex: _selectedIndex,
      selectedItemColor: kPrimaryColor,
      backgroundColor: _selectedIndex == 4 ? kContentColorLightTheme : bgColor,
      unselectedItemColor: _selectedIndex == 4 ? Colors.white : QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
      selectedLabelStyle: TextStyle(
          color: kPrimaryColor, fontSize: 12, fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(
          color: _selectedIndex == 4 ? Colors.white : QuickHelp.isDarkMode(context) ? Colors.white : Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
      onTap: (index) => onItemTapped(index),
    );
  }


  checkUser() async {

    CustomerInfo customerInfo = await Purchases.getCustomerInfo();

    if(widget.currentUser!.getFullName!.isNotEmpty){
      Purchases.setDisplayName(widget.currentUser!.getFullName!);
    }

    if(widget.currentUser!.getEmail != null){
      Purchases.setEmail(widget.currentUser!.getEmail!);
    }

    if(widget.currentUser!.getGender != null){
      Map<String, String> params = <String, String>{
        "Gender": widget.currentUser!.getGender!,
      };
      Purchases.setAttributes(params);
    }

    if(widget.currentUser!.getAge != null){
      Map<String, String> params = <String, String>{
        "Age": widget.currentUser!.getAge.toString(),
      };
      Purchases.setAttributes(params);
    }

    if(widget.currentUser!.getBirthday != null){
      Map<String, String> params = <String, String>{
        "Birthday": QuickHelp.getBirthdayFromDate(widget.currentUser!.getBirthday!),
      };
      Purchases.setAttributes(params);
    }

    print("USER PURCHASES: $customerInfo");
  }

  @override
  void initState() {
    super.initState();

    QuickHelp.saveCurrentRoute(route: HomeScreen.route);
    initSharedPref();
    checkUser();

    Future.delayed(Duration(seconds: 2), (){
      if(QuickHelp.isIOSPlatform()){

        if(!mounted) return; // Try
        showAppTrackingPermission(context);
      }
    });

    AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd();
    _appLifecycleReactor = AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    _appLifecycleReactor.listenToAppStateChanges();
  }

  bool checkHomeBannerAdReels(){

    if(SharedManager().isBannerAdsOnHomeReelsEnabled(widget.preferences)){
      return true;
    } else {
      if(_selectedIndex == 4){
        return false;
      } else {
        return true;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    if (widget.currentUser != null) {
      widget.currentUser = widget.currentUser;

      context.read<CallsProvider>().isAgoraUserLogged(widget.currentUser);
    } else if (ModalRoute.of(context)!.settings.arguments != null) {
      widget.currentUser =
      ModalRoute.of(context)!.settings.arguments as UserModel;

      context.read<CallsProvider>().isAgoraUserLogged(widget.currentUser);
    }

    return ToolBarLeftWidget(
      //backgroundColor: _selectedIndex == 4 ? Colors.transparent : null,
      //extendBodyBehindAppBar: _selectedIndex == 4 ? false : true,
      enableAppBar: _selectedIndex == 4 ? false : true,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _widgetOptions().elementAt(_selectedIndex),),
          if (_anchoredAdaptiveAd != null && _isLoaded && checkHomeBannerAdReels())
            Container(
              //color: Colors.green,
              width: _anchoredAdaptiveAd!.size.width.toDouble(),
              height: _anchoredAdaptiveAd!.size.height.toDouble(),
              child: AdWidget(ad: _anchoredAdaptiveAd!),
            )
          //Container(height: 50, color: Colors.purpleAccent,)
        ],
      ), //_widgetOptions().elementAt(_selectedIndex),
      leftWidget: QuickActions.avatarWidget(
        widget.currentUser!,
        width: 45,
        height: 45,
        margin: EdgeInsets.only(bottom: 0, top: 0, left: 10, right: 5),
      ),
      actionsIcons: [
        "assets/svg/ic_tab_feed_default.svg",
        "assets/svg/ic_top_menu_search.svg",
        //Icon(Icons.search),
        hasNotification
            ? Icon(Icons.notifications_rounded, size: 26,)
            : Image.asset("assets/images/ic_home_notification_bell.png",
          width: 22,
          height: 22,
          color: kPrimaryColor,
        )
      ],
      onTapActions: [
            () => QuickHelp.goToNavigatorScreen(context, FeedHomeScreen(currentUser: widget.currentUser, preferences: widget.preferences,)), //QuickHelp.goToNavigatorScreen(context, LeadersPage(currentUser: widget.currentUser,)),
            () => QuickHelp.goToNavigatorScreen(
            context,
            SearchPage(
              preferences: widget.preferences,
              currentUser: widget.currentUser,
            )),
            () => QuickHelp.goToNavigatorScreen(context, NotificationsScreen(currentUser: widget.currentUser, preferences: widget.preferences,),),
      ],
      actionsIconsSize: 30,
      coinIconSize: 20,
      actionsColor: kPrimaryColor,
      coinsIcon: "assets/svg/ic_coin_with_star.svg",
      coins: GestureDetector(
        onTap: () => QuickHelp.goToNavigatorScreen(context, RefillCoinsScreen(currentUser: widget.currentUser)),
        child: getCoinsWidget(
          coinIconSize: 20,
          coinsColor: QuickHelp.isDarkMode(context)
              ? kContentColorDarkTheme
              : kContentColorLightTheme,
          coinsIcon: "assets/svg/ic_coin_with_star.svg",
        ),
      ),
     avatarTap: () => QuickHelp.goToNavigatorScreen(
          context,
          ProfileMenuScreen(
            userModel: widget.currentUser != null
                ? widget.currentUser
                : widget.currentUser,
            preferences: widget.preferences,
          )),
      bottomNavigationBar: bottomNavBar(),
    );
  }

  Widget getCoinsWidget({double? coinIconSize, Color? coinsColor, String? coinsIcon}){

    QueryBuilder<UserModel> queryBuilder =
    QueryBuilder<UserModel>(UserModel.forQuery());
    queryBuilder.whereEqualTo(keyVarObjectId, widget.currentUser!.objectId!);

    return ParseLiveListWidget<UserModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      duration: Duration(seconds: 0),
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<ParseObject> snapshot) {
        if (snapshot.hasData) {

          UserModel updatedUser = snapshot.loadedData! as UserModel;
          widget.currentUser = updatedUser;

          if (QuickHelp.isAccountDisabled(updatedUser)) {
            print("User updated accountDisabled true");

            widget.currentUser!.logout(deleteLocalUserData: true).then((value) {
              QuickHelp.goToPageWithClear(
                context,
                WelcomeScreen(),
              );
            }).onError(
              (error, stackTrace) {},
            );
          } else {
            print("User updated accountDisabled false");
          }

          //print("User updated, old value: ${widget.currentUser!.getCredits.toString()}");
          //print("User updated, new value: ${updatedUser.getCredits.toString()}");

          return coinsWidget(
            coinIconSize: coinIconSize,
            coinsColor: coinsColor,
            coinsIcon: coinsIcon,
            coins: updatedUser.getCredits.toString(),
          );

        } else {
          return coinsWidget(
            coinIconSize: coinIconSize,
            coinsColor: coinsColor,
            coinsIcon: coinsIcon,
            coins: "...",
          );
        }
      },
      queryEmptyElement: coinsWidget(
        coinIconSize: coinIconSize,
        coinsColor: coinsColor,
        coinsIcon: coinsIcon,
        coins: "",
      ),
      listLoadingElement: coinsWidget(
        coinIconSize: coinIconSize,
        coinsColor: coinsColor,
        coinsIcon: coinsIcon,
        coins: "...",
      ),
    );
  }

  Widget coinsWidget({double? coinIconSize, Color? coinsColor, String? coinsIcon, String? coins}){

    return Row(
      children: [
        QuickActions.showSVGAsset(coinsIcon!,
            width: coinIconSize, height: coinIconSize),
        TextWithTap(
          coins!,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          marginLeft: 6,
          color: coinsColor,
        ),
      ],
    );
  }

  void showNameModal() {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        isDismissible: false,
        builder: (context) {
          return _showBottomSheetUpdateName();
        });
  }

  Widget _showBottomSheetUpdateName() {
    return Container(
      color: Color.fromRGBO(0, 0, 0, 0.001),
      child: GestureDetector(
        onTap: () {},
        child: DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.1,
          maxChildSize: 1.0,
          builder: (_, controller) {
            return StatefulBuilder(
              builder: (context, setState) {
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
                    child: SafeArea(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                TextWithTap(
                                  "profile_screen.change_name_title".tr(),
                                  marginTop: 10,
                                  marginBottom: 20,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                TextWithTap(
                                  "profile_screen.change_name_explain".tr(),
                                  fontSize: 16,
                                  textAlign: TextAlign.center,
                                  marginLeft: 20,
                                  marginRight: 20,
                                ),
                              ],
                            ),
                            ButtonWidget(
                              width: 100,
                              height: 30,
                              padding: EdgeInsets.only(left: 10, right: 10),
                              marginBottom: 20,
                              borderRadiusAll: 30,
                              color: kPrimaryColor,
                              child: TextWithTap(
                                "profile_screen.change_btn".tr(),
                                color: Colors.white,
                              ),
                              onTap: () async {
                                QuickHelp.hideLoadingDialog(context);

                                UserModel? user = await QuickHelp.goToNavigatorScreenForResult(
                                    context,
                                    ProfileEdit(
                                      currentUser: widget.currentUser,
                                    ));

                                if(user != null){
                                  widget.currentUser = user;
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  showAppTrackingPermission(BuildContext context) async {
    // Show tracking authorization dialog and ask for permission
    try {
      // If the system can show an authorization request dialog
      TrackingStatus status = await AppTrackingTransparency.trackingAuthorizationStatus;

      if(status == TrackingStatus.notSupported){

        print("TrackingPermission notSupported");

      } else if (status == TrackingStatus.notDetermined) {
        // Show a custom explainer dialog before the system dialog

        if(!appTrackingDialogShowing){
          appTrackingDialogShowing = true;

          QuickHelp.showDialogPermission(
              context: context,
              dismissible: false,
              confirmButtonText: "permissions.allow_tracking".tr().toUpperCase(),
              title: "permissions.allow_app_tracking".tr(),
              message: "permissions.app_tracking_explain".tr(),
              onPressed: () async {
                QuickHelp.goBackToPreviousPage(context);
                appTrackingDialogShowing = false;
                await AppTrackingTransparency.requestTrackingAuthorization().then((value) async {

                  if(status == TrackingStatus.authorized){
                    await FacebookAuth.i.autoLogAppEventsEnabled(true);
                  }
                });
              });
        }
      }
    } on PlatformException {
      // Unexpected exception was thrown
    }
  }

  showError(int code){
    QuickHelp.hideLoadingDialog(context);
    QuickHelp.showErrorResult(context, code);
  }

  initSharedPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Constants.queryParseConfig(preferences);
  }
}