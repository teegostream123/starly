import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teego/app/setup.dart';
import 'package:teego/helpers/quick_actions.dart';
import 'package:teego/helpers/quick_cloud.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/home/coins/coins_payment_widget.dart';
import 'package:teego/home/live/live_preview.dart';
import 'package:teego/home/live/live_streaming_screen.dart';
import 'package:teego/home/live/select_screen.dart';
import 'package:teego/home/live/zego_live_stream.dart';
import 'package:teego/home/profile/profile_edit.dart';
import 'package:teego/home/profile/user_screen.dart';
import 'package:teego/models/GiftsSentModel.dart';
import 'package:teego/models/LiveStreamingModel.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import '../../models/LiveMessagesModel.dart';
import '../../models/ReportModel.dart';
import '../../ui/button_with_icon.dart';
import '../location_screen.dart';
import '../message/message_screen.dart';
import 'artist_screen.dart';
import 'live_party.dart';

// ignore: must_be_immutable
class LiveScreen extends StatefulWidget {
  static String route = "/home/live/all";

  UserModel? currentUser;
  SharedPreferences? preferences;

  LiveScreen({Key? key, this.currentUser, required this.preferences})
      : super(key: key);

  @override
  _LiveScreenState createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> with TickerProviderStateMixin {
  int tabsLength = 2;

  int tabTypeForYou = 0;
  int tabTypeNearby = 1;
  int tabTypeNew = 2;
  int tabTypePopular = 3;

  late TabController _tabController;
  int tabIndex = 0;

  int numberOfColumns = 2;

  List<dynamic> liveResults = <dynamic>[];
  late QueryBuilder<LiveStreamingModel> queryBuilder;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    checkUserRole();
  // baki null waghera da tan koi issue nhi aa na nazer tey nai aya filhal
    QuickHelp.saveCurrentRoute(route: LiveScreen.route);

    _tabController = TabController(
        vsync: this, length: tabsLength, initialIndex: tabTypeForYou)
      ..addListener(() {
        setState(() {
          tabIndex = _tabController.index;
        });

        updateLives();
      });

    updateLives();
  }

  updateLives() {
    print("LiveIndex: $tabIndex");
    // _future = _loadLive(tabIndex);
    _tabController.dispose();
  }

  Future<void> checkPermission(bool isBroadcaster,
      {String? channel, LiveStreamingModel? liveStreamingModel}) async {
    if (QuickHelp.isAndroidPlatform()) {
      PermissionStatus status = await Permission.storage.status;
      PermissionStatus status2 = await Permission.camera.status;
      PermissionStatus status3 = await Permission.microphone.status;
      print('Permission android');

      checkStatus(status, status2, status3, isBroadcaster,
          channel: channel, liveStreamingModel: liveStreamingModel);
    } else if (QuickHelp.isIOSPlatform()) {
      PermissionStatus status = await Permission.photos.status;
      PermissionStatus status2 = await Permission.camera.status;
      PermissionStatus status3 = await Permission.microphone.status;
      print('Permission ios');

      checkStatus(status, status2, status3, isBroadcaster,
          channel: channel, liveStreamingModel: liveStreamingModel);
    } else {
      print('Permission other device');
      _gotoLiveScreen(isBroadcaster,
          channel: channel, liveStreamingModel: liveStreamingModel);
    }
  }

  void checkStatus(PermissionStatus status, PermissionStatus status2,
      PermissionStatus status3, bool isBroadcaster,
      {String? channel, LiveStreamingModel? liveStreamingModel}) {
    if (status.isDenied || status2.isDenied || status3.isDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.

      QuickHelp.showDialogPermission(
          context: context,
          title: "permissions.photo_access".tr(),
          confirmButtonText: "permissions.okay_".tr().toUpperCase(),
          message: "permissions.photo_access_explain"
              .tr(namedArgs: {"app_name": Setup.appName}),
          onPressed: () async {
            QuickHelp.hideLoadingDialog(context);

            // You can request multiple permissions at once.
            Map<Permission, PermissionStatus> statuses = await [
              Permission.camera,
              Permission.photos,
              Permission.storage,
              Permission.microphone,
            ].request();

            if (statuses[Permission.camera]!.isGranted &&
                    statuses[Permission.photos]!.isGranted ||
                statuses[Permission.storage]!.isGranted ||
                statuses[Permission.microphone]!.isGranted) {
              _gotoLiveScreen(isBroadcaster,
                  channel: channel, liveStreamingModel: liveStreamingModel);
            }
          });
    } else if (status.isPermanentlyDenied ||
        status2.isPermanentlyDenied ||
        status3.isPermanentlyDenied) {
      QuickHelp.showDialogPermission(
          context: context,
          title: "permissions.photo_access_denied".tr(),
          confirmButtonText: "permissions.okay_settings".tr().toUpperCase(),
          message: "permissions.photo_access_denied_explain"
              .tr(namedArgs: {"app_name": Setup.appName}),
          onPressed: () {
            QuickHelp.hideLoadingDialog(context);

            openAppSettings();
          });
    } else if (status.isGranted && status2.isGranted && status3.isGranted) {
      //_uploadPhotos(ImageSource.gallery);
      _gotoLiveScreen(isBroadcaster,
          channel: channel, liveStreamingModel: liveStreamingModel);
    }

    print('Permission $status');
    print('Permission $status2');
    print('Permission $status3');
  }

  _gotoLiveScreen(bool isBroadcaster,
      {String? channel, LiveStreamingModel? liveStreamingModel}) async {
    if (widget.currentUser?.getAvatar == null) {
      QuickHelp.showDialogLivEend(
        context: context,
        dismiss: true,
        title: 'live_streaming.photo_needed'.tr(),
        confirmButtonText: 'live_streaming.add_photo'.tr(),
        message: 'live_streaming.photo_needed_explain'.tr(),
        onPressed: () {
          QuickHelp.goBackToPreviousPage(context);
          QuickHelp.goToNavigatorScreen(
              context,
              ProfileEdit(
                currentUser: widget.currentUser,
              ));
        },
      );
    } else if (widget.currentUser?.getGeoPoint == null) {
      QuickHelp.showDialogLivEend(
        context: context,
        dismiss: true,
        title: 'live_streaming.location_needed'.tr(),
        confirmButtonText: 'live_streaming.add_location'.tr(),
        message: 'live_streaming.location_needed_explain'.tr(),
        onPressed: () async {
          QuickHelp.goBackToPreviousPage(context);
          //QuickHelp.goToNavigator(context, LocationScreen.route, arguments: widget.currentUser);

          UserModel? user = await QuickHelp.goToNavigatorScreenForResult(
              context,
              LocationScreen(
                currentUser: widget.currentUser,
              ));
          if (user != null) {
            widget.currentUser = user;
          }
        },
      );
    } else {
      if (isBroadcaster) {
        QuickHelp.goToNavigatorScreen(
            context, LivePreviewScreen(currentUser: widget.currentUser));
      } else {
        if (liveStreamingModel!.getPrivate! && !widget.currentUser!.isAdmin!) {
          if (!liveStreamingModel.getPrivateViewersId!
              .contains(widget.currentUser!.objectId!)) {
            openPayPrivateLiveSheet(liveStreamingModel);
          } else {
            QuickHelp.goToNavigatorScreen(
                context,
                LiveStreamingScreen(
                  channelName: channel ?? '',
                  isBroadcaster: false,
                  currentUser: widget.currentUser ?? '' as UserModel,
                  preferences: widget.preferences,
                  mUser: liveStreamingModel.getAuthor,
                  isUserInvited: liveStreamingModel.getInvitedPartyUid!
                      .contains(widget.currentUser!.getUid!),
                  mLiveStreamingModel: liveStreamingModel,
                ));
          }
        } else {
          QuickHelp.goToNavigatorScreen(
              context,
              LiveStreamingScreen(
                channelName: channel!,
                isBroadcaster: false,
                currentUser: widget.currentUser!,
                preferences: widget.preferences,
                mUser: liveStreamingModel.getAuthor,
                isUserInvited: liveStreamingModel.getInvitedPartyUid!
                    .contains(widget.currentUser!.getUid!),
                mLiveStreamingModel: liveStreamingModel,
              ));
        }
      }
    }
  }

  String? userRole;

  checkUserRole() async {
    UserModel user = await ParseUser.currentUser();
    print("HERE USER ROLE ${user.getUserRole}");
    setState(() {
      userRole = user.getUserRole;
    });

    // return user.getUserRole;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButton: userRole == "artist"
            ? FloatingActionButton(
                onPressed: () => checkPermission(true),
                child: ContainerCorner(
                  onTap: () => checkPermission(true),
                  height: 60,
                  width: 60,
                  colors: [kPrimaryColor, kSecondaryColor],
                  borderRadius: 10,
                  shadowColor: kPrimaryColor,
                  shadowColorOpacity: 0.3,
                  setShadowToBottom: true,
                  blurRadius: 10,
                  spreadRadius: 3,
                  child: Container(
                    width: 20,
                    height: 20,
                    margin: EdgeInsets.all(12),
                    child: QuickActions.showSVGAsset(
                      "assets/svg/ic_tab_live_selected.svg",
                      color: Colors.white,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              )
            : SizedBox.shrink(),
        appBar: AppBar(
          centerTitle: true,
          title: TabBar(
            isScrollable: true,
            enableFeedback: false,
            // controller: _tabController,
            indicatorColor: Colors.transparent,
            unselectedLabelColor: kTabIconDefaultColor,
            labelColor: kTabIconSelectedColor,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            labelPadding: EdgeInsets.only(right: 14),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
            tabs: [
              tabsRows(
                  "Artist",
                  tabTypeForYou,
                  Icon(
                    Icons.people,
                    size: 18,
                    // color: Colors.red,
                    color: kPrimaryColor,
                  )),
              tabsRows(
                  "Live Party",
                  tabTypeNearby,
                  Icon(
                    Icons.music_note,
                    size: 18,
                    color: kPrimaryColor,
                  )),
            ],
          ),
          backgroundColor: kTransparentColor,
          //bottom:
        ),
        body: TabBarView(
          // controller: _tabController,
          children: [
            // artistWidget(),
            ArtistScreen(),
            LivePartyScreen(),
            // controller da panga ay
            // initQuery(tabTypeForYou),
          ],
          //children: List.generate(tabsLength, (index) => initQuery(index)),
        ),
      ),
    );
  }

  Future<void> _loadLiveUpdate() async {
    ParseResponse apiResponse = await queryBuilder.query();
    if (apiResponse.success) {
      if (apiResponse.results != null) {
        setState(() {
          liveResults.clear();
          liveResults.addAll(apiResponse.results!);
        });

        return Future(() => null);
      }
    } else {
      return Future(() => null);
    }
    return null;
  }
  // function to load all the streams from parser db
  // then show the list in the live party tab
  // on tap of the item will join the stream as a audience

  Future<dynamic> _loadLive(int? category) async {
    try {
      print('loading available stream');
      // QueryBuilder<UserModel> queryUsers = QueryBuilder(UserModel.forQuery());
      // queryUsers.whereValueExists(UserModel.keyUserStatus, true);
      // queryUsers.whereEqualTo(UserModel.keyUserStatus, true);

      queryBuilder = QueryBuilder<LiveStreamingModel>(LiveStreamingModel());

      print('query builder init');

      // queryBuilder.whereEqualTo(LiveStreamingModel.keyStreaming, true);
      // queryBuilder.whereNotEqualTo(
      //     LiveStreamingModel.keyAuthorUid, widget.currentUser!.getUid);
      // queryBuilder.whereNotContainedIn(
      //     LiveStreamingModel.keyAuthor, widget.currentUser!.getBlockedUsers!);
      // queryBuilder.whereValueExists(LiveStreamingModel.keyAuthor, true);
      // queryBuilder.whereDoesNotMatchQuery(
      //     LiveStreamingModel.keyAuthor, queryUsers);

      if (category == tabTypeForYou) {
        //queryBuilder.orderByDescending(keyVarCreatedAt);
        // queryBuilder.orderByDescending(LiveStreamingModel.keyAuthorTotalDiamonds);
      } else if (category == tabTypeNearby) {
        // Nearby
        // if (widget.currentUser!.getGeoPoint != null) {
        //   queryBuilder.whereWithinKilometers(LiveStreamingModel.keyLiveGeoPoint,
        //       widget.currentUser!.getGeoPoint!, Setup.maxDistanceToNearBy);
        //   queryBuilder.orderByDescending(LiveStreamingModel.keyLiveGeoPoint);
        // }
      } else if (category == tabTypeNew) {
        // New
        // queryBuilder.whereEqualTo(LiveStreamingModel.keyFirstLive, true);
        // queryBuilder.orderByDescending(LiveStreamingModel.keyCreatedAt);
      } else if (category == tabTypePopular) {
        // Popular
        // queryBuilder.whereGreaterThanOrEqualsTo(
        //     LiveStreamingModel.keyStreamingDiamonds,
        //     Setup.minimumDiamondsToPopular);
        // queryBuilder.orderByDescending(LiveStreamingModel.keyAuthorTotalDiamonds);
      }

      // queryBuilder.setLimit(25);
      // queryBuilder.includeObject([
      //   LiveStreamingModel.keyAuthor,
      //   LiveStreamingModel.keyAuthorInvited,
      //   LiveStreamingModel.keyPrivateLiveGift
      // ]);

      ParseResponse apiResponse = await queryBuilder.query();

      print(['api res is ', apiResponse.result]);
      if (apiResponse.success) {
        if (apiResponse.results != null) {
          //setupLiveQuery();

          setState(() {
            liveResults.clear();
          });

          return apiResponse.results;
        } else {
          return [];
        }
      } else {
        return null;
      }
    } catch (e, t) {
      print(e);
      print(t);
      rethrow;
    }
  }

  Future<List<ParseObject>> doUserQuery() async {
    QueryBuilder<UserModel> queryUsers =
        QueryBuilder<UserModel>(UserModel.forQuery());

    // Add query constraints (optional)
    queryUsers.whereEqualTo('role', 'artist');
    final ParseResponse apiResponse = await queryUsers.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  // Widget artistWidget() {
  //   return Container(
  //       child: FutureBuilder<List<ParseObject>>(
  //           future: doUserQuery(),
  //           builder: (context, snapshot) {
  //             if (snapshot.connectionState == ConnectionState.waiting) {
  //               return GridView.custom(
  //                 physics: const AlwaysScrollableScrollPhysics(),
  //                 primary: true,
  //                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //                   crossAxisCount: 2,
  //                   crossAxisSpacing: 2,
  //                   mainAxisSpacing: 2,
  //                 ),
  //                 childrenDelegate: SliverChildBuilderDelegate(
  //                   childCount: 8,
  //                   (BuildContext context, int index) {
  //                     return FadeShimmer(
  //                       height: 60,
  //                       width: 60,
  //                       radius: 4,
  //                       fadeTheme: QuickHelp.isDarkModeNoContext()
  //                           ? FadeTheme.dark
  //                           : FadeTheme.light,
  //                     );
  //                   },
  //                 ),
  //               );
  //             } else if (snapshot.hasError) {
  //               return Center(
  //                 child: Text("Error...: ${snapshot.error.toString()}"),
  //               );
  //             } else if (snapshot.data!.isEmpty) {
  //               return Center(
  //                   child: Padding(
  //                 padding: EdgeInsets.all(8.0),
  //                 child: QuickActions.noContentFound(
  //                   "No Artist for now".tr(),
  //                   "Stay tuned with us".tr(),
  //                   "assets/svg/ic_tab_live_default.svg",
  //                 ),
  //               ));
  //             } else {
  //               return RefreshIndicator(
  //                 key: _refreshIndicatorKey,
  //                 color: Colors.white,
  //                 backgroundColor: kPrimaryColor,
  //                 strokeWidth: 2.0,
  //                 onRefresh: () {
  //                   _refreshIndicatorKey.currentState?.show(atTop: true);
  //                   return doUserQuery();
  //                 },
  //                 child: GridView.custom(
  //                   gridDelegate:
  //                       const SliverGridDelegateWithFixedCrossAxisCount(
  //                     crossAxisCount: 2,
  //                     crossAxisSpacing: 2,
  //                     mainAxisSpacing: 2,
  //                   ),
  //                   childrenDelegate: SliverChildBuilderDelegate(
  //                     childCount: snapshot.data!.length,
  //                     (BuildContext context, int index) {
  //                       final user = snapshot.data![index] as UserModel;
  //
  //                       return GestureDetector(
  //                         onTap: () {
  //                           Navigator.of(context).push(MaterialPageRoute(
  //                               builder: (builder) => UserScreen(
  //                                     userModel: user,
  //                                   )));
  //                           // Navigator.push(context, MaterialPageRoute(builder: (_) => SelectScreen()));
  //
  //                           // Navigator.of(context).push(MaterialPageRoute(
  //                           //     builder: ((context) => MyWidget(
  //                           //       userID: 'ugu',
  //                           //       userName: 'Ali',
  //                           //       liveID: '100',
  //                           //       config: ZegoUIKitPrebuiltLiveStreamingConfig.audience(),
  //                           //       // isHost: host,
  //                           //     ))));
  //                         },
  //                         child: Stack(children: [
  //                           ContainerCorner(
  //                             color: kTransparentColor,
  //                             // color : Colors.red,
  //                             child: QuickActions.photosWidget(
  //                                 user.getAvatar == null
  //                                     ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRuk4zd55uaQfv6DaY9RpS8a4lVNnVcyKf2YVHO5z3IAzZypmoFzSG4wSSuimSvjc_L-fk&usqp=CAU'
  //                                     : user.getAvatar!.url,
  //                                 borderRadius: 5),
  //                           ),
  //                           Positioned(
  //                             top: 0,
  //                             child: ContainerCorner(
  //                               radiusTopLeft: 5,
  //                               radiusTopRight: 5,
  //                               height: 40,
  //                               width: (MediaQuery.of(context).size.width /
  //                                       numberOfColumns) -
  //                                   5,
  //                               alignment: Alignment.center,
  //                               colors: [
  //                                 Colors.black,
  //                                 Colors.black.withOpacity(0.05)
  //                               ],
  //                               begin: Alignment.topCenter,
  //                               end: Alignment.bottomCenter,
  //                               child: ContainerCorner(
  //                                 color: kTransparentColor,
  //                                 marginLeft: 10,
  //                                 child: Row(
  //                                   mainAxisAlignment:
  //                                       MainAxisAlignment.spaceBetween,
  //                                   children: [
  //                                     Row(
  //                                       children: [
  //                                         // TextWithTap(
  //                                         //   'View Profile'.toString(),
  //                                         //   color: Colors.white,
  //                                         //   fontSize: 14,
  //                                         //   marginRight: 15,
  //                                         //   marginLeft: 5,
  //                                         // ),
  //                                         // QuickActions.showSVGAsset(
  //                                         //   "assets/svg/ic_diamond.svg",
  //                                         //   height: 24,
  //                                         // ),
  //                                         // TextWithTap(
  //                                         //   liveStreaming
  //                                         //       .getAuthor!.getDiamondsTotal!
  //                                         //       .toString(),
  //                                         //   color: Colors.white,
  //                                         //   fontSize: 14,
  //                                         //   marginLeft: 3,
  //                                         // ),
  //                                       ],
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           Positioned(
  //                             bottom: 0,
  //                             child: ContainerCorner(
  //                               radiusBottomLeft: 5,
  //                               radiusBottomRight: 5,
  //                               height: 40,
  //                               width: (MediaQuery.of(context).size.width /
  //                                       numberOfColumns) -
  //                                   5,
  //                               alignment: Alignment.center,
  //                               colors: [
  //                                 Colors.black,
  //                                 Colors.black.withOpacity(0.05)
  //                               ],
  //                               begin: Alignment.bottomCenter,
  //                               end: Alignment.topCenter,
  //                               child: Padding(
  //                                 padding: const EdgeInsets.only(left: 8.0),
  //                                 child: Row(
  //                                   children: [
  //                                     QuickActions.showSVGAsset(
  //                                       "assets/svg/ic_small_viewers.svg",
  //                                       height: 18,
  //                                     ),
  //                                     Column(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.center,
  //                                       children: [
  //                                         TextWithTap(
  //                                           user.getFullName!,
  //                                           color: Colors.white,
  //                                           overflow: TextOverflow.ellipsis,
  //                                           marginLeft: 10,
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ]),
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               );
  //             }
  //           }));
  // }

  Widget initQuery(int category) {
    return Container(
      margin: EdgeInsets.all(2),
      child: FutureBuilder(
          future: _loadLive(tabIndex),
          builder: (BuildContext context, snapshot) {
            print([
              'snapshot connection state',
              snapshot.connectionState,
            ]);
            if (snapshot.connectionState == ConnectionState.waiting) {
              return GridView.custom(
                physics: const AlwaysScrollableScrollPhysics(),
                primary: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                childrenDelegate: SliverChildBuilderDelegate(
                  childCount: 8,
                  (BuildContext context, int index) {
                    return FadeShimmer(
                      height: 60,
                      width: 60,
                      radius: 4,
                      fadeTheme: QuickHelp.isDarkModeNoContext()
                          ? FadeTheme.dark
                          : FadeTheme.light,
                    );
                  },
                ),
              );
            } else if (snapshot.hasData) {
              liveResults = snapshot.data! as List<dynamic>;

              if (liveResults.isNotEmpty) {
                print('inside liver result is not empty');
                return RefreshIndicator(
                  key: _refreshIndicatorKey,
                  color: Colors.white,
                  backgroundColor: kPrimaryColor,
                  strokeWidth: 2.0,
                  onRefresh: () {
                    _refreshIndicatorKey.currentState?.show(atTop: true);
                    return _loadLiveUpdate();
                  },
                  child: GridView.custom(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    childrenDelegate: SliverChildBuilderDelegate(
                      childCount: liveResults.length,
                      // childCount: 3,
                      (BuildContext context, int index) {
                        print(['available live index is', index]);
                        final LiveStreamingModel liveStreaming =
                            liveResults[index] as LiveStreamingModel;

                        // return Container(
                        //   width: 100,
                        //   height: 100,
                        //   color: Colors.red,
                        // );

                        // return GestureDetector(
                        //   onLongPress: () {
                        //     if (liveStreaming.getAuthorId !=
                        //         widget.currentUser!.objectId) {
                        //       openSheet(
                        //           liveStreaming.getAuthor!, liveStreaming);
                        //     }
                        //   },
                        //   onTap: () {
                        //     checkPermission(false,
                        //         channel: liveStreaming.getStreamingChannel,
                        //         liveStreamingModel: liveStreaming);
                        //   },
                        //   child: Stack(children: [
                        //     ContainerCorner(
                        //       color: kTransparentColor,
                        //       child: QuickActions.photosWidget(
                        //           liveStreaming.getImage?.url,
                        //           borderRadius: 5),
                        //     ),
                        //     Positioned(
                        //       top: 0,
                        //       child: ContainerCorner(
                        //         radiusTopLeft: 5,
                        //         radiusTopRight: 5,
                        //         height: 40,
                        //         width: (MediaQuery.of(context).size.width /
                        //                 numberOfColumns) -
                        //             5,
                        //         alignment: Alignment.center,
                        //         colors: [
                        //           Colors.black,
                        //           Colors.black.withOpacity(0.05)
                        //         ],
                        //         begin: Alignment.topCenter,
                        //         end: Alignment.bottomCenter,
                        //         child: ContainerCorner(
                        //           color: kTransparentColor,
                        //           marginLeft: 10,
                        //           child: Row(
                        //             mainAxisAlignment:
                        //                 MainAxisAlignment.spaceBetween,
                        //             children: [
                        //               Row(
                        //                 children: [
                        //                   QuickActions.showSVGAsset(
                        //                     "assets/svg/ic_small_viewers.svg",
                        //                     height: 18,
                        //                   ),
                        //                   TextWithTap(
                        //                     liveStreaming.getViewersCount
                        //                         .toString(),
                        //                     color: Colors.white,
                        //                     fontSize: 14,
                        //                     marginRight: 15,
                        //                     marginLeft: 5,
                        //                   ),
                        //                   QuickActions.showSVGAsset(
                        //                     "assets/svg/ic_diamond.svg",
                        //                     height: 24,
                        //                   ),
                        //                   TextWithTap(
                        //                     liveStreaming
                        //                         .getAuthor!.getDiamondsTotal!
                        //                         .toString(),
                        //                     color: Colors.white,
                        //                     fontSize: 14,
                        //                     marginLeft: 3,
                        //                   ),
                        //                 ],
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //     Visibility(
                        //       visible: liveStreaming.getPrivate!,
                        //       child: Center(
                        //         child: Icon(
                        //           Icons.vpn_key,
                        //           color: Colors.white,
                        //           size: 35,
                        //         ),
                        //       ),
                        //     ),
                        //     Positioned(
                        //       bottom: 0,
                        //       child: ContainerCorner(
                        //         radiusBottomLeft: 5,
                        //         radiusBottomRight: 5,
                        //         height: 40,
                        //         width: (MediaQuery.of(context).size.width /
                        //                 numberOfColumns) -
                        //             5,
                        //         alignment: Alignment.center,
                        //         colors: [
                        //           Colors.black,
                        //           Colors.black.withOpacity(0.05)
                        //         ],
                        //         begin: Alignment.bottomCenter,
                        //         end: Alignment.topCenter,
                        //         child: Row(
                        //           children: [
                        //             QuickActions.avatarWidget(
                        //                 liveStreaming.getAuthor!,
                        //                 height: 30,
                        //                 width: 30,
                        //                 margin: EdgeInsets.only(
                        //                     left: 5, bottom: 5)),
                        //             Column(
                        //               mainAxisAlignment:
                        //                   MainAxisAlignment.center,
                        //               children: [
                        //                 TextWithTap(
                        //                   liveStreaming.getAuthor!.getFullName!,
                        //                   color: Colors.white,
                        //                   overflow: TextOverflow.ellipsis,
                        //                   marginLeft: 10,
                        //                 ),
                        //                 Visibility(
                        //                   visible: liveStreaming
                        //                       .getStreamingTags!.isNotEmpty,
                        //                   child: TextWithTap(
                        //                     liveStreaming.getStreamingTags!,
                        //                     color: Colors.white,
                        //                     overflow: TextOverflow.ellipsis,
                        //                     marginLeft: 10,
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //   ]),
                        // );
                      },
                    ),
                  ),
                );
              } else {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: QuickActions.noContentFound(
                      "live_streaming.no_live_title".tr(),
                      "live_streaming.no_live_explain".tr(),
                      "assets/svg/ic_tab_live_default.svg",
                    ),
                  ),
                );
              }
            } else {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: QuickActions.noContentFound(
                    "live_streaming.no_live_title".tr(),
                    "live_streaming.no_live_explain".tr(),
                    "assets/svg/ic_tab_live_default.svg",
                  ),
                ),
              );
            }
          }),
    );

    /*if(_isLoading){

      return GridView.custom(
        physics: const AlwaysScrollableScrollPhysics(),
        primary: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        childrenDelegate: SliverChildBuilderDelegate(
          childCount: 8, (BuildContext context, int index) {
          return FadeShimmer(
            height: 60,
            width: 60,
            radius: 4,
            fadeTheme: QuickHelp.isDarkModeNoContext() ? FadeTheme.dark : FadeTheme.light,
          );
        },
        ),
      );

    } else if(liveResults.isNotEmpty) {

      return RefreshIndicator(
        key: _refreshIndicatorKey,
        color: Colors.white,
        backgroundColor: kPrimaryColor,
        strokeWidth: 2.0,
        onRefresh: () {
          _refreshIndicatorKey.currentState?.show(atTop: true);
          return _loadLiveUpdate(tabIndex);
        },
        child: StaggeredGridView.countBuilder(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          itemCount: liveResults.length,
          itemBuilder: (BuildContext context, int index) {

            if (liveResults[index] is LiveStreamingModel){

              final LiveStreamingModel liveStreaming = liveResults[index] as LiveStreamingModel;
              return GestureDetector(
                onTap: (){
                  checkPermission(false, channel: liveStreaming.getStreamingChannel, liveStreamingModel: liveStreaming);
                },
                child: Stack(children: [
                  ContainerCorner(
                    color: kTransparentColor,
                    child: QuickActions.photosWidget(liveStreaming.getImage!.url!, borderRadius: 5),
                  ),
                  Positioned(
                    top: 0,
                    child: ContainerCorner(
                      radiusTopLeft: 5,
                      radiusTopRight: 5,
                      height: 40,
                      width: (MediaQuery.of(context).size.width / numberOfColumns) - 5,
                      alignment: Alignment.center,
                      colors: [
                        Colors.black,
                        Colors.black.withOpacity(0.05)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      child: ContainerCorner(
                        color: kTransparentColor,
                        marginLeft: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                QuickActions.showSVGAsset(
                                  "assets/svg/ic_small_viewers.svg",
                                  height: 18,
                                ),
                                TextWithTap(liveStreaming.getViewersCount.toString(),
                                  color: Colors.white,
                                  fontSize: 14,
                                  marginRight: 15,
                                  marginLeft: 5,
                                ),
                                QuickActions.showSVGAsset(
                                  "assets/svg/ic_diamond.svg",
                                  height: 24,
                                ),
                                TextWithTap(
                                  liveStreaming.getAuthor!.getDiamondsTotal!.toString(),
                                  color: Colors.white,
                                  fontSize: 14,
                                  marginLeft: 3,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: liveStreaming.getPrivate!,
                    child: Center(
                      child: Icon(Icons.vpn_key, color: Colors.white, size: 35,),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: ContainerCorner(
                      radiusBottomLeft: 5,
                      radiusBottomRight: 5,
                      height: 40,
                      width: (MediaQuery.of(context).size.width / numberOfColumns) - 5,
                      alignment: Alignment.center,
                      colors: [
                        Colors.black,
                        Colors.black.withOpacity(0.05)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      child: Row(
                        children: [
                          QuickActions.avatarWidget(
                              liveStreaming.getAuthor!, height: 30, width: 30,
                              margin: EdgeInsets.only(left: 5, bottom: 5)
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextWithTap(
                                liveStreaming.getAuthor!.getFullName!,
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis,
                                marginLeft: 10,
                              ),
                              Visibility(
                                visible: liveStreaming.getStreamingTags!.isNotEmpty,
                                child: TextWithTap(
                                  liveStreaming.getStreamingTags!,
                                  color: Colors.white,
                                  overflow: TextOverflow.ellipsis,
                                  marginLeft: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              );

            } else {

              return FutureBuilder(
                  future: getNativeAdTest(context: context),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasData) {
                      AdWidget ad = snapshot.data as AdWidget;

                      final Container adContainer = Container(
                        alignment: Alignment.center,
                        color: Colors.white,
                        child: ad,
                      );

                      return adContainer;

                    } else {
                      return Container(
                          alignment: Alignment.topCenter,
                          margin: const EdgeInsets.only(top: 20),
                          child: const CircularProgressIndicator(
                            value: 0.8,
                          ));
                    }
                  });
            }
          },
          staggeredTileBuilder: (int index){

            if (liveResults[index] is LiveStreamingModel){ //if (index % _kAdIndex == 0) {
              return StaggeredTile.count(1, 1);
            } else {
              return StaggeredTile.count(2, 3);
            }

          },
        ),
      );

    } else {

      return Center(
        child: Padding(
          padding:  EdgeInsets.all(8.0),
          child: QuickActions.noContentFound(
            "live_streaming.no_live_title".tr(),
            "live_streaming.no_live_explain".tr(),
            "assets/svg/ic_tab_live_default.svg",
          ),
        ),
      );
    }*/
  }

  // Future<List> getAllLive() async {
  //   final snap = ParseObject('Streamings');
  //   final res = await snap.getAll();

  //   print(res);
  //   if (res.success && res.results != null) {
  //     print('success');

  //     print(res.results);

  //     return res.results ?? [];
  //   }
  //   return [];
  // }

  String distanceValue(double distance) {
    //QuickHelp.distanceInKilometersTo(liveStreaming.getStreamingGeoPoint!, widget.currentUser!.getGeoPoint!)
    if (distance >= 1.0) {
      return "${num.parse(distance.toStringAsFixed(2))} km";
    } else {
      return "${num.parse((distance * 1000).toStringAsFixed(2))} m";
    }
  }

  void openPayPrivateLiveSheet(LiveStreamingModel live) async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showPayPrivateLiveBottomSheet(live);
        });
  }

  Widget _showPayPrivateLiveBottomSheet(LiveStreamingModel live) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.1,
            maxChildSize: 1.0,
            builder: (_, controller) {
              return StatefulBuilder(builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                  ),
                  child: Scaffold(
                    appBar: AppBar(
                      toolbarHeight: 35.0,
                      backgroundColor: kTransparentColor,
                      automaticallyImplyLeading: false,
                      elevation: 0,
                      actions: [
                        IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(Icons.close)),
                      ],
                    ),
                    backgroundColor: kTransparentColor,
                    body: Column(
                      children: [
                        Center(
                            child: TextWithTap(
                          "live_streaming.private_live".tr(),
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 25,
                          marginBottom: 15,
                        )),
                        Center(
                          child: TextWithTap(
                            "live_streaming.private_live_explain".tr(),
                            color: Colors.white,
                            fontSize: 16,
                            marginLeft: 20,
                            marginRight: 20,
                            marginTop: 20,
                          ),
                        ),
                        Expanded(
                            child: Lottie.network(
                                live.getPrivateGift!.getFile!.url!,
                                width: 150,
                                height: 150,
                                animate: true,
                                repeat: true)),
                        ContainerCorner(
                          color: kTransparentColor,
                          marginTop: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              QuickActions.showSVGAsset(
                                "assets/svg/ic_coin_with_star.svg",
                                width: 24,
                                height: 24,
                              ),
                              TextWithTap(
                                live.getPrivateGift!.getCoins.toString(),
                                color: Colors.white,
                                fontSize: 18,
                                marginLeft: 5,
                              )
                            ],
                          ),
                        ),
                        ContainerCorner(
                          borderRadius: 10,
                          height: 50,
                          width: 150,
                          color: kPrimaryColor,
                          onTap: () {
                            if (widget.currentUser!.getCredits! >=
                                live.getPrivateGift!.getCoins!) {
                              _payForPrivateLive(live);
                              //sendGift(live);
                            } else {
                              CoinsFlowPayment(
                                context: context,
                                currentUser: widget.currentUser!,
                                showOnlyCoinsPurchase: true,
                                onCoinsPurchased: (coins) {
                                  print(
                                      "onCoinsPurchased: $coins new: ${widget.currentUser!.getCredits}");

                                  if (widget.currentUser!.getCredits! >=
                                      live.getPrivateGift!.getCoins!) {
                                    _payForPrivateLive(live);
                                    //sendGift(live);
                                  }
                                },
                              );
                            }
                          },
                          marginTop: 15,
                          marginBottom: 40,
                          child: Center(
                            child: TextWithTap(
                              "live_streaming.pay_for_live".tr(),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }

  _payForPrivateLive(LiveStreamingModel live) async {
    QuickHelp.showLoadingDialog(context);

    GiftsSentModel giftsSentModel = new GiftsSentModel();
    giftsSentModel.setAuthor = widget.currentUser!;
    giftsSentModel.setAuthorId = widget.currentUser!.objectId!;

    giftsSentModel.setReceiver = live.getAuthor!;
    giftsSentModel.setReceiverId = live.getAuthor!.objectId!;

    giftsSentModel.setGift = live.getPrivateGift!;
    giftsSentModel.setGiftId = live.getPrivateGift!.objectId!;
    giftsSentModel.setCounterDiamondsQuantity = live.getPrivateGift!.getCoins!;

    await giftsSentModel.save();

    ParseResponse response = await QuickCloudCode.sendGift(
        author: live.getAuthor!,
        credits: live.getPrivateGift!.getCoins!,
        preferences: widget.preferences!);

    if (response.success) {
      updateCurrentUserCredit(
          live.getPrivateGift!.getCoins!, live, giftsSentModel);
    } else {
      QuickHelp.hideLoadingDialog(context);
    }
  }

  updateCurrentUserCredit(
      int coins, LiveStreamingModel live, GiftsSentModel sentModel) async {
    widget.currentUser!.removeCredit = coins;
    ParseResponse userResponse = await widget.currentUser!.save();
    if (userResponse.success) {
      widget.currentUser = userResponse.results!.first as UserModel;

      sendMessage(live, sentModel);
    } else {
      QuickHelp.hideLoadingDialog(context);
    }
  }

  sendMessage(LiveStreamingModel live, GiftsSentModel giftsSentModel) async {
    live.addDiamonds = QuickHelp.getDiamondsForReceiver(
        live.getPrivateGift!.getCoins!, widget.preferences!);
    await live.save();

    LiveMessagesModel liveMessagesModel = new LiveMessagesModel();
    liveMessagesModel.setAuthor = widget.currentUser!;
    liveMessagesModel.setAuthorId = widget.currentUser!.objectId!;

    liveMessagesModel.setLiveStreaming = live;
    liveMessagesModel.setLiveStreamingId = live.objectId!;

    liveMessagesModel.setGiftSent = giftsSentModel;
    liveMessagesModel.setGiftSentId = giftsSentModel.objectId!;
    liveMessagesModel.setGiftId = giftsSentModel.getGiftId!;

    liveMessagesModel.setMessage = "";
    liveMessagesModel.setMessageType = LiveMessagesModel.messageTypeGift;

    ParseResponse response = await liveMessagesModel.save();
    if (response.success) {
      QuickHelp.goToNavigatorScreen(
          context,
          LiveStreamingScreen(
            channelName: live.getStreamingChannel!,
            isBroadcaster: false,
            preferences: widget.preferences,
            currentUser: widget.currentUser!,
            mUser: live.getAuthor,
            mLiveStreamingModel: live,
          ));
    } else {
      QuickHelp.hideLoadingDialog(context);
    }
  }

  Widget tabsRows(String title, int position, Widget icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tabIndex == position) icon,
        SizedBox(width: 6),
        Text(title.tr()),
      ],
    );
  }

  void openSheet(UserModel author, LiveStreamingModel live) async {
    showModalBottomSheet(
        context: (context),
        //isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showPostOptionsAndReportAuthor(author, live);
        });
  }

  Widget _showPostOptionsAndReportAuthor(
      UserModel author, LiveStreamingModel live) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: ContainerCorner(
        radiusTopRight: 20.0,
        radiusTopLeft: 20.0,
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Visibility(
              visible: !widget.currentUser!.isAdmin!,
              child: ButtonWithIcon(
                text: "live_streaming.report_live".tr(),
                iconURL: "assets/svg/ic_blocked_menu.svg",
                height: 60,
                radiusTopLeft: 25.0,
                radiusTopRight: 25.0,
                backgroundColor: Colors.white,
                mainAxisAlignment: MainAxisAlignment.start,
                textColor: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                onTap: () {
                  openReportMessage(author, live, true);
                },
              ),
            ),
            Visibility(
                visible: !widget.currentUser!.isAdmin!, child: Divider()),
            Visibility(
              visible: !widget.currentUser!.isAdmin!,
              child: ButtonWithIcon(
                text: "live_streaming.report_live_user"
                    .tr(namedArgs: {"name": author.getFullName!}),
                iconURL: "assets/svg/ic_blocked_menu.svg",
                height: 60,
                backgroundColor: Colors.white,
                mainAxisAlignment: MainAxisAlignment.start,
                textColor: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                onTap: () {
                  openReportMessage(author, live, false);
                },
              ),
            ),
            Visibility(
                visible: !widget.currentUser!.isAdmin!, child: Divider()),
            Visibility(
              visible: widget.currentUser!.isAdmin!,
              child: ButtonWithIcon(
                text: "live_streaming.live_option_suspend".tr(),
                textColor: Colors.black,
                fontSize: 18,
                radiusTopLeft: 25.0,
                radiusTopRight: 25.0,
                fontWeight: FontWeight.w500,
                iconURL: "assets/svg/ic_blocked_menu.svg",
                onTap: () => _suspendUser(live),
                height: 60,
                backgroundColor: Colors.white,
                mainAxisAlignment: MainAxisAlignment.start,
              ),
            ),
            Visibility(visible: widget.currentUser!.isAdmin!, child: Divider()),
            Visibility(
              visible: widget.currentUser!.isAdmin!,
              child: ButtonWithIcon(
                text: "live_streaming.live_option_terminate".tr(),
                iconURL: "assets/svg/ic_blocked_menu.svg",
                height: 60,
                backgroundColor: Colors.white,
                mainAxisAlignment: MainAxisAlignment.start,
                textColor: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                // onTap: () {
                //   _terminateLive(live);
                // },
              ),
            ),
            Visibility(visible: widget.currentUser!.isAdmin!, child: Divider()),
            Visibility(
              visible: widget.currentUser!.isAdmin!,
              child: ButtonWithIcon(
                text: "live_streaming.live_option_change".tr(),
                iconURL: "assets/svg/ic_blocked_menu.svg",
                height: 60,
                backgroundColor: Colors.white,
                mainAxisAlignment: MainAxisAlignment.start,
                textColor: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                onTap: () => _changePicture(live, terminate: false),
              ),
            ),
            Visibility(visible: widget.currentUser!.isAdmin!, child: Divider()),
            Visibility(
              visible: widget.currentUser!.isAdmin!,
              child: ButtonWithIcon(
                text: "live_streaming.live_option_change_terminate".tr(),
                iconURL: "assets/svg/ic_blocked_menu.svg",
                height: 60,
                backgroundColor: Colors.white,
                mainAxisAlignment: MainAxisAlignment.start,
                textColor: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                onTap: () => _changePicture(live, terminate: true),
              ),
            ),
            Visibility(visible: widget.currentUser!.isAdmin!, child: Divider()),
            Visibility(
              visible: widget.currentUser!.isAdmin!,
              child: ButtonWithIcon(
                text: "live_streaming.live_option_chat".tr(),
                iconURL: "assets/svg/ic_blocked_menu.svg",
                height: 60,
                backgroundColor: Colors.white,
                mainAxisAlignment: MainAxisAlignment.start,
                textColor: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                onTap: () {
                  _gotToChat(widget.currentUser!, live.getAuthor!);
                },
              ),
            ),
            Visibility(visible: widget.currentUser!.isAdmin!, child: Divider()),
          ],
        ),
      ),
    );
  }

  void openReportMessage(UserModel author,
      LiveStreamingModel liveStreamingModel, bool isStreamer) async {
    showModalBottomSheet(
        context: (context),
        //isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showReportMessageBottomSheet(
              author, liveStreamingModel, isStreamer);
        });
  }

  Widget _showReportMessageBottomSheet(
      UserModel author, LiveStreamingModel streamingModel, bool isStreamer) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: ContainerCorner(
        radiusTopRight: 20.0,
        radiusTopLeft: 20.0,
        color: QuickHelp.isDarkMode(context)
            ? kContentColorLightTheme
            : Colors.white,
        child: Column(
          children: [
            ContainerCorner(
              color: kGreyColor1,
              width: 50,
              marginTop: 5,
              borderRadius: 50,
              marginBottom: 10,
            ),
            TextWithTap(
              isStreamer
                  ? "live_streaming.report_live".tr()
                  : "live_streaming.report_live_user"
                      .tr(namedArgs: {"name": author.getFirstName!}),
              fontWeight: FontWeight.w900,
              fontSize: 20,
              marginBottom: 50,
            ),
            Column(
              children: List.generate(
                  QuickHelp.getReportCodeMessageList().length, (index) {
                String code = QuickHelp.getReportCodeMessageList()[index];

                return TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    print("Message: " + QuickHelp.getReportMessage(code));
                    _saveReport(QuickHelp.getReportMessage(code), author,
                        live: isStreamer ? streamingModel : null);
                  },
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWithTap(
                            QuickHelp.getReportMessage(code),
                            color: kGrayColor,
                            fontSize: 15,
                            marginBottom: 5,
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: kGrayColor,
                          ),
                        ],
                      ),
                      Divider(
                        height: 1.0,
                      )
                    ],
                  ),
                );
              }),
            ),
            ContainerCorner(
              marginTop: 30,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: TextWithTap(
                  "cancel".tr().toUpperCase(),
                  color: kGrayColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _saveReport(String reason, UserModel? user,
      {LiveStreamingModel? live}) async {
    QuickHelp.showLoadingDialog(context);

    ParseResponse response = await QuickActions.report(
        type: ReportModel.reportTypeLiveStreaming,
        message: reason,
        accuser: widget.currentUser!,
        accused: user!,
        liveStreamingModel: live);
    if (response.success) {
      QuickHelp.hideLoadingDialog(context);

      QuickHelp.showAppNotificationAdvanced(
          context: context,
          user: widget.currentUser,
          title: "live_streaming.report_done".tr(),
          message: "live_streaming.report_done_explain".tr(),
          isError: false);
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "error".tr(),
          message: "live_streaming.report_live_error".tr(),
          isError: true);
    }
  }

  // _terminateLive(LiveStreamingModel live) {
  //   QuickHelp.goBackToPreviousPage(context);
  //
  //   QuickHelp.showDialogWithButtonCustom(
  //     context: context,
  //     title: "live_streaming.live_option_terminate".tr(),
  //     message: "live_streaming.live_option_terminate_ask".tr(),
  //     cancelButtonText: "no".tr(),
  //     confirmButtonText: "live_streaming.live_option_terminate_ask_yes".tr(),
  //     onPressed: () => _confirmTerminateLive(live),
  //   );
  // }

  _suspendUser(LiveStreamingModel live) {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showDialogWithButtonCustom(
      context: context,
      title: "feed.suspend_user_alert".tr(),
      message: "feed.suspend_user_message".tr(),
      cancelButtonText: "no".tr(),
      confirmButtonText: "feed.yes_suspend".tr(),
      onPressed: () => _confirmSuspendUser(live),
    );
  }

  _confirmSuspendUser(LiveStreamingModel live) async {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showLoadingDialog(context);

    live.setTerminatedByAdmin = true;
    live.setStreaming = false;
    await live.save();

    ParseResponse parseResponse =
        await QuickCloudCode.suspendUSer(objectId: live.getAuthor!.objectId!);
    if (parseResponse.success) {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "suspended".tr(),
        message: "feed.user_suspended".tr(),
        user: live.getAuthor,
        isError: null,
      );
    } else {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "feed.user_not_suspended".tr(),
        user: live.getAuthor,
        isError: true,
      );
    }
  }

  // _confirmTerminateLive(LiveStreamingModel live) async {
  //   QuickHelp.goBackToPreviousPage(context);
  //
  //   QuickHelp.showLoadingDialog(context);
  //
  //   live.setTerminatedByAdmin = true;
  //   ParseResponse parseResponse = await live.save();
  //
  //   if (parseResponse.success) {
  //     QuickHelp.goBackToPreviousPage(context);
  //
  //     QuickHelp.showAppNotificationAdvanced(
  //       context: context,
  //       title: "live_streaming.live_option_terminate".tr(),
  //       message: "live_streaming.live_option_terminated".tr(),
  //       user: live.getAuthor,
  //       isError: null,
  //     );
  //   } else {
  //     QuickHelp.goBackToPreviousPage(context);
  //
  //     QuickHelp.showAppNotificationAdvanced(
  //       context: context,
  //       title: "error".tr(),
  //       message: "live_streaming.live_option_not_terminated".tr(),
  //       user: live.getAuthor,
  //       isError: true,
  //     );
  //   }
  // }

  _gotToChat(UserModel currentUser, UserModel mUser) {
    QuickHelp.goToNavigator(context, MessageScreen.route, arguments: {
      "currentUser": currentUser,
      "mUser": mUser,
    });
  }

  _changePicture(LiveStreamingModel live, {bool? terminate = false}) {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showDialogWithButtonCustom(
      context: context,
      title: "live_streaming.live_option_change".tr(),
      message: terminate == true
          ? "live_streaming.live_option_change_photo_ask".tr()
          : "live_streaming.live_option_change_photo_normal_ask".tr(),
      cancelButtonText: "no".tr(),
      confirmButtonText: "live_streaming.live_option_change_photo_ask_yes".tr(),
      onPressed: () => _confirmChangePicture(live, terminate),
    );
  }

  _confirmChangePicture(LiveStreamingModel live, terminate) async {
    QuickHelp.goBackToPreviousPage(context);
    QuickHelp.showLoadingDialog(context);

    List<String> keywords = [];

    if (live.getAuthor!.getGender! == UserModel.keyGenderMale) {
      keywords = ["sexy male", "male model"];
    } else if (live.getAuthor!.getGender! == UserModel.keyGenderFemale) {
      keywords = ["sexy female", "female model"];
    } else {
      keywords = ["model", "sexy"];
    }

    var faker = Faker();
    String imageUrl = faker.image
        .image(width: 640, height: 640, keywords: keywords, random: true);

    File avatar = await QuickHelp.downloadFile(imageUrl, "avatar.jpeg") as File;

    if (terminate) {
      live.setTerminatedByAdmin = true;
      live.setStreaming = false;
      await live.save();
    } else {
      ParseFileBase parseFile;
      if (QuickHelp.isWebPlatform()) {
        //Seems weird, but this lets you get the data from the selected file as an Uint8List very easily.
        ParseWebFile file =
            ParseWebFile(null, name: "avatar.jpeg", url: avatar.path);
        await file.download();
        parseFile = ParseWebFile(file.file, name: file.name);
      } else {
        parseFile = ParseFile(File(avatar.path));
      }

      live.setImage = parseFile;
      await live.save();
    }

    ParseResponse parseResponse = await QuickCloudCode.changePicture(
        user: live.getAuthor!, parseFile: avatar.readAsBytesSync());
    if (parseResponse.success) {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "live_streaming.live_option_change".tr(),
        message: "live_streaming.live_option_changed_photo".tr(),
        user: live.getAuthor,
        isError: null,
      );
    } else {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "live_streaming.live_option_not_changed_photo".tr(),
        user: live.getAuthor,
        isError: true,
      );
    }
  }
}
