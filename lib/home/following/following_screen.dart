import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teego/app/setup.dart';
import 'package:teego/home/live/live_preview.dart';
import 'package:teego/home/live/live_streaming_screen.dart';
import 'package:teego/home/location_screen.dart';
import 'package:teego/home/profile/profile_edit.dart';
import 'package:teego/models/LiveStreamingModel.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';
import 'package:teego/helpers/quick_actions.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../../helpers/quick_cloud.dart';
import '../../models/GiftsSentModel.dart';
import '../../models/LiveMessagesModel.dart';
import '../coins/coins_payment_widget.dart';

// ignore: must_be_immutable
class FollowingScreen extends StatefulWidget {
  static const String route = '/home/following';

  UserModel? currentUser;
  SharedPreferences? preferences;

  FollowingScreen({this.currentUser, required this.preferences});

  @override
  _FollowingScreenState createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen>
    with TickerProviderStateMixin {
  int numberOfColumns = 2;

  List<dynamic> liveResults = <dynamic>[];
  var _future;

  @override
  void initState() {

    QuickHelp.saveCurrentRoute(route: FollowingScreen.route);

    super.initState();
    _future = _loadLive();
  }

  @override
  Widget build(BuildContext context) {
    QuickHelp.setWebPageTitle(context, "page_title.following_title".tr());

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: FloatingActionButton(
        onPressed: () => checkPermission(true),
        child: ContainerCorner(
          height: 60,
          width: 60,
          onTap: () => checkPermission(true),
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
      ),
      body: ContainerCorner(
        marginAll: 2,
        color: kTransparentColor,
        borderColor: kTransparentColor,
        child: initQuery(),
      ),
    );
  }

  Future<dynamic> _loadLive() async {

    QueryBuilder<UserModel> queryUsers = QueryBuilder(UserModel.forQuery());
    queryUsers.whereValueExists(UserModel.keyUserStatus, true);
    queryUsers.whereEqualTo(UserModel.keyUserStatus, true);

    QueryBuilder<LiveStreamingModel> queryBuilder =
        QueryBuilder<LiveStreamingModel>(LiveStreamingModel());

    queryBuilder.includeObject([
      LiveStreamingModel.keyAuthor,
      LiveStreamingModel.keyAuthorInvited,
      LiveStreamingModel.keyPrivateLiveGift
    ]);

    queryBuilder.whereEqualTo(LiveStreamingModel.keyStreaming, true);
    queryBuilder.whereContainedIn(
        LiveStreamingModel.keyAuthorId, widget.currentUser!.getFollowing!);

    queryBuilder.whereDoesNotMatchQuery(LiveStreamingModel.keyAuthor, queryUsers);

    queryBuilder.setLimit(30);

    ParseResponse apiResponse = await queryBuilder.query();
    if (apiResponse.success) {
      if (apiResponse.results != null) {
        return apiResponse.results;
      } else {
        return [];
      }
    } else {
      return null;
    }
  }

  Widget initQuery() {
    return FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return GridView.custom(
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
              return GridView.custom(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                childrenDelegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final LiveStreamingModel liveStreaming = liveResults[index];

                    return GestureDetector(
                      onTap: () {
                        checkPermission(false,
                            channel: liveStreaming.getStreamingChannel,
                            liveStreamingModel: liveStreaming);
                      },
                      child: Stack(children: [
                        ContainerCorner(
                          color: kTransparentColor,
                          child: QuickActions.photosWidget(
                            liveStreaming.getImage!.url!,
                            borderRadius: 5,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          child: ContainerCorner(
                            radiusTopLeft: 5,
                            radiusTopRight: 5,
                            height: 40,
                            width: (MediaQuery.of(context).size.width /
                                    numberOfColumns) -
                                5,
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
                                children: [
                                  QuickActions.showSVGAsset(
                                    "assets/svg/ic_small_viewers.svg",
                                    height: 18,
                                  ),
                                  TextWithTap(
                                    liveStreaming.getViewersCount.toString(),
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
                                    liveStreaming.getAuthor!.getDiamondsTotal!
                                        .toString(),
                                    color: Colors.white,
                                    fontSize: 14,
                                    marginLeft: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: liveStreaming.getPrivate!,
                          child: Center(
                            child: Icon(
                              Icons.vpn_key,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: ContainerCorner(
                            radiusBottomLeft: 5,
                            radiusBottomRight: 5,
                            height: 40,
                            width: (MediaQuery.of(context).size.width /
                                    numberOfColumns) -
                                5,
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
                                    liveStreaming.getAuthor!,
                                    height: 30,
                                    width: 30,
                                    margin:
                                        EdgeInsets.only(left: 5, bottom: 5)),
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
                                      visible: liveStreaming
                                          .getStreamingTags!.isNotEmpty,
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
                  },
                  childCount: liveResults.length,
                  findChildIndexCallback: (Key key) {
                    // Re-use elements.
                    if (key is ValueKey<int>) {
                      return key.value;
                    }
                    return null;
                  },
                ),
              );
            } else {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: QuickActions.noContentFound(
                      "following_screen.no_follow_title".tr(),
                      "following_screen.no_follow_explain".tr(),
                      "assets/svg/ic_family_menu.svg"),
                ),
              );
            }
          } else {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: QuickActions.noContentFound(
                    "following_screen.no_follow_title".tr(),
                    "following_screen.no_follow_explain".tr(),
                    "assets/svg/ic_family_menu.svg"),
              ),
            );
          }
        });
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

            //if (await Permission.camera.request().isGranted) {
            // Either the permission was already granted before or the user just granted it.
            //}

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
    if (widget.currentUser!.getAvatar == null) {
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
    } else if (widget.currentUser!.getGeoPoint == null) {
      QuickHelp.showDialogLivEend(
        context: context,
        dismiss: true,
        title: 'live_streaming.location_needed'.tr(),
        confirmButtonText: 'live_streaming.add_location'.tr(),
        message: 'live_streaming.location_needed_explain'.tr(),
        onPressed: () async {
          QuickHelp.goBackToPreviousPage(context);

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
            context, LivePreviewScreen(currentUser: widget.currentUser!));
      } else {
        if (liveStreamingModel!.getPrivate!) {
          if (!liveStreamingModel.getPrivateViewersId!
              .contains(widget.currentUser!.objectId!)) {
            openPayPrivateLiveSheet(liveStreamingModel);
          } else {
            QuickHelp.goToNavigatorScreen(
                context,
                LiveStreamingScreen(
                  channelName: channel!,
                  isBroadcaster: false,
                  currentUser: widget.currentUser!,
                  mUser: liveStreamingModel.getAuthor,
                  preferences: widget.preferences,
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
                mLiveStreamingModel: liveStreamingModel,
              ));
        }
      }
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
        author: live.getAuthor!, credits: live.getPrivateGift!.getCoins!, preferences: widget.preferences!);

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
    live.addDiamonds =
        QuickHelp.getDiamondsForReceiver(live.getPrivateGift!.getCoins!, widget.preferences!);
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
            currentUser: widget.currentUser!,
            mUser: live.getAuthor,
            preferences: widget.preferences,
            mLiveStreamingModel: live,
          ));
    } else {
      QuickHelp.hideLoadingDialog(context);
    }
  }
}
