import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mime/mime.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teego/app/constants.dart';
import 'package:teego/app/setup.dart';
import 'package:teego/helpers/quick_actions.dart';
import 'package:teego/helpers/quick_cloud.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/home/feed/comment_post_screen.dart';
import 'package:teego/home/reels/video_editor_screen.dart';
import 'package:teego/home/profile/profile_screen.dart';
import 'package:teego/models/NotificationsModel.dart';
import 'package:teego/models/PostsModel.dart';
import 'package:teego/models/ReportModel.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/app_bar.dart';
import 'package:teego/ui/button_with_gradient.dart';
import 'package:teego/ui/button_with_icon.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:teego/utils/shared_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../models/others/video_editor_model.dart';
import '../../utils/utilsConstants.dart';
import 'package:teego/widgets/dospace/dospace.dart' as dospace;

// ignore: must_be_immutable
class FeedHomeScreen extends StatefulWidget {
  UserModel? currentUser;
  SharedPreferences? preferences;

  FeedHomeScreen({this.currentUser, required this.preferences});

  @override
  _FeedHomeScreenState createState() => _FeedHomeScreenState();
}

class _FeedHomeScreenState extends State<FeedHomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int tabIndex = 0;

  var _future;

  // Ads
  static final _kAdIndex = 2;

  late QueryBuilder<PostsModel> queryBuilder;
  final LiveQuery liveQuery = LiveQuery();
  Subscription? subscription;
  List<dynamic> postsResults = <dynamic>[];

  String uploadPhoto = "";
  ParseFileBase? parseFile;
  ParseFileBase? parseFileThumbnail;
  bool? isVideo = false;
  File? videoFile;

  savePost({String? text}) async {
    QuickHelp.hideLoadingDialog(context);

    PostsModel postsModel = PostsModel();
    postsModel.setAuthor = widget.currentUser!;
    postsModel.setAuthorId = widget.currentUser!.objectId!;
    if (text != null) postsModel.setText = text;

    if (isVideo!) {
      postsModel.setVideoThumbnail = parseFileThumbnail!;
      postsModel.setVideo = parseFile!;
      postsModel.setImage = parseFileThumbnail!;
    } else {
      postsModel.setImage = parseFile!;
    }

    postsModel.setExclusive = isSwitchedForPremium;
    postsModel.setPostType = PostsModel.postTypeImage;

    QuickHelp.showLoadingDialog(context);

    ParseResponse response = await postsModel.save();
    if (response.success) {
      QuickHelp.hideLoadingDialog(context);

      parseFile = null;
      parseFileThumbnail = null;
      uploadPhoto = "";
      postContent.clear();

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "feed.post_posted_title".tr(),
        message: "feed.post_posted".tr(),
        isError: false,
      );
    } else {
      QuickHelp.hideLoadingDialog(context);

      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "feed.post_not_posted".tr(),
          message: response.error!.message,
          isError: true,
          user: widget.currentUser);
    }
  }

  bool isSwitchedForPremium = false;
  TextEditingController postContent = TextEditingController();

  @override
  void initState() {
    super.initState();

    _future = _loadFeeds(isExclusive: false);

    _tabController = TabController(vsync: this, length: 2, initialIndex: 0)
      ..addListener(() {
        switch (_tabController.index) {
          case 0:
            setState(() {
              tabIndex = 0;
            });

            _future = _loadFeeds(isExclusive: false);
            break;
          case 1:
            setState(() {
              tabIndex = 1;
            });

            _future = _loadFeeds(isExclusive: true);
            break;
        }
      });
  }

  _deleteLike(PostsModel postsModel) async {
    QueryBuilder<NotificationsModel> queryBuilder =
        QueryBuilder<NotificationsModel>(NotificationsModel());
    queryBuilder.whereEqualTo(NotificationsModel.keyAuthor, widget.currentUser);
    queryBuilder.whereEqualTo(NotificationsModel.keyPost, postsModel);

    ParseResponse parseResponse = await queryBuilder.query();

    if (parseResponse.success && parseResponse.results != null) {
      NotificationsModel notification = parseResponse.results!.first;
      await notification.delete();
    }
  }

  _likePost(PostsModel post) {
    QuickActions.createOrDeleteNotification(widget.currentUser!,
        post.getAuthor!, NotificationsModel.notificationTypeLikedPost,
        post: post);
  }

  void openSheet(UserModel author, PostsModel post) async {
    showModalBottomSheet(
        context: (context),
        //isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showPostOptionsAndReportAuthor(author, post);
        });
  }

  @override
  void dispose() {
    _tabController.dispose();
    disposeLiveQuery();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToolBar(
      leftButtonIcon: Icons.arrow_back_ios,
      onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
      child: TabBarView(
        controller: _tabController,
        children: [
          initQuery(false),
          initQuery(true),
        ],
      ),
      titleChild: TabBar(
        isScrollable: true,
        enableFeedback: false,
        controller: _tabController,
        indicatorColor: Colors.transparent,
        unselectedLabelColor: kTabIconDefaultColor,
        labelColor: kTabIconSelectedColor,
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        tabs: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tabIndex == 0)
                QuickActions.showSVGAsset(
                  "assets/svg/ic_followers_active.svg",
                  color: kPrimaryColor,
                ),
              SizedBox(width: 8),
              Text("feed.for_all".tr()),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tabIndex == 1)
                QuickActions.showSVGAsset(
                  "assets/svg/ic_gold_star_small.svg",
                  color: kPrimaryColor,
                ),
              SizedBox(width: 8),
              Text("feed.exclusive_".tr()),
            ],
          ),
        ],
      ),
      floatingActionButton: GestureDetector(
        onTap: () => checkPermission(),
        child: ContainerCorner(
          onTap: () => checkPermission(),
          child: FloatingActionButton(
              backgroundColor: kPrimaryColor,
              onPressed: () => checkPermission(),
              child: Icon(
                Icons.add,
                color: Colors.white,
              )),
        ),
      ),
    );
  }

  disposeLiveQuery() {
    if (subscription != null) {
      liveQuery.client.unSubscribe(subscription!);
      subscription = null;
    }
  }

  Future<void> _objectUpdated(PostsModel object) async {
    for (int i = 0; i < postsResults.length; i++) {
      if (postsResults[i].get<String>(keyVarObjectId) ==
          object.get<String>(keyVarObjectId)) {
        if (UtilsConstant.afterPosts(postsResults[i], object) == null) {
          setState(() {
            // ignore: invalid_use_of_protected_member
            postsResults[i] = object.clone(object.toJson(full: true));
          });
        }
        break;
      }
    }
  }

  Future<void> _objectDeleted(PostsModel object) async {
    for (int i = 0; i < postsResults.length; i++) {
      if (postsResults[i].get<String>(keyVarObjectId) ==
          object.get<String>(keyVarObjectId)) {
        setState(() {
          // ignore: invalid_use_of_protected_member
          postsResults.removeAt(i);
        });

        break;
      }
    }
  }

  setupLiveQuery(bool isExclusive) async {
    QueryBuilder<PostsModel> queryBuilderLive =
        QueryBuilder<PostsModel>(PostsModel());

    queryBuilderLive.whereEqualTo(PostsModel.keyExclusive, isExclusive);

    queryBuilderLive.whereNotContainedIn(
        PostsModel.keyAuthorId, widget.currentUser!.getBlockedUsersIDs!);
    queryBuilderLive.whereNotContainedIn(
        PostsModel.keyObjectId, widget.currentUser!.getReportedPostIDs!);

    if (subscription == null) {
      subscription = await liveQuery.client.subscribe(queryBuilderLive);
    }

    subscription!.on(LiveQueryEvent.create, (PostsModel post) async {
      await post.getAuthor!.fetch();
      if (post.getLastLikeAuthor != null) {
        await post.getLastLikeAuthor!.fetch();
      }

      if (!mounted) return;
      setState(() {
        postsResults.add(post);
      });
    });

    subscription!.on(LiveQueryEvent.enter, (PostsModel post) async {
      await post.getAuthor!.fetch();
      if (post.getLastLikeAuthor != null) {
        await post.getLastLikeAuthor!.fetch();
      }

      if (!mounted) return;
      setState(() {
        postsResults.add(post);
      });
    });

    subscription!.on(LiveQueryEvent.update, (PostsModel post) async {
      if (!mounted) return;

      await post.getAuthor!.fetch();
      if (post.getLastLikeAuthor != null) {
        await post.getLastLikeAuthor!.fetch();
      }

      _objectUpdated(post);
    });

    subscription!.on(LiveQueryEvent.delete, (PostsModel post) {
      if (!mounted) return;

      _objectDeleted(post);
    });
  }

  Future<dynamic> _loadFeeds({bool? isExclusive}) async {
    //print("IndexPint $isExclusive");

    disposeLiveQuery();

    QueryBuilder<UserModel> queryUsers = QueryBuilder(UserModel.forQuery());
    queryUsers.whereValueExists(UserModel.keyUserStatus, true);
    queryUsers.whereEqualTo(UserModel.keyUserStatus, true);

    queryBuilder = QueryBuilder<PostsModel>(PostsModel());

    queryBuilder.whereEqualTo(PostsModel.keyExclusive, isExclusive);

    queryBuilder.whereNotContainedIn(
        PostsModel.keyAuthorId, widget.currentUser!.getBlockedUsersIDs!);
    queryBuilder.whereNotContainedIn(
        PostsModel.keyObjectId, widget.currentUser!.getReportedPostIDs!);
    queryBuilder.whereValueExists(PostsModel.keyVideo, false);

    queryBuilder.whereDoesNotMatchQuery(PostsModel.keyAuthor, queryUsers);

    queryBuilder.orderByDescending(PostsModel.keyCreatedAt);

    queryBuilder.includeObject([
      PostsModel.keyAuthor,
      PostsModel.keyAuthorName,
      PostsModel.keyLastLikeAuthor,
      PostsModel.keyLastDiamondAuthor
    ]);

    queryBuilder.setLimit(50);
    ParseResponse apiResponse = await queryBuilder.query();
    if (apiResponse.success) {
      if (apiResponse.results != null) {
        setupLiveQuery(isExclusive!);

        return apiResponse.results;
      } else {
        return [];
      }
    } else {
      return null;
    }
  }

  Widget initQuery(bool isExclusive) {
    return FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: QuickHelp.showLoadingAnimation(),
            );
          } else if (snapshot.hasData) {
            postsResults = snapshot.data! as List<dynamic>;

            if (postsResults.isNotEmpty) {
              return ListView.separated(
                itemCount: postsResults.length,
                itemBuilder: (context, index) {
                  final PostsModel post = postsResults[index] as PostsModel;

                  var liked = post.getLikes!.length > 0 &&
                      post.getLikes!.contains(widget.currentUser!.objectId!);

                  return ContainerCorner(
                    //height: 450,
                    color: QuickHelp.isDarkMode(context)
                        ? kContentColorLightTheme
                        : Colors.white,
                    marginTop: 7,
                    marginBottom: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ContainerCorner(
                                  marginTop: 10,
                                  color: QuickHelp.isDarkMode(context)
                                      ? kContentColorLightTheme
                                      : Colors.white,
                                  child: Row(
                                    children: [
                                      QuickActions.avatarWidget(post.getAuthor!,
                                          width: 50, height: 50),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextWithTap(
                                            post.getAuthor!.getFullName!,
                                            marginLeft: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          TextWithTap(
                                            QuickHelp.getTimeAgoForFeed(
                                                post.createdAt!),
                                            marginLeft: 10,
                                            marginTop: 8,
                                            color: kGrayColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  marginLeft: 15,
                                  onTap: () {
                                    if (post.getAuthorId ==
                                        widget.currentUser!.objectId!) {
                                      QuickHelp.goToNavigatorScreen(
                                          context,
                                          ProfileScreen(
                                            currentUser: widget.currentUser,
                                          ));
                                    } else {
                                      QuickActions.showUserProfile(context,
                                          widget.currentUser!, post.getAuthor!);
                                    }
                                  }),
                            ),
                            ButtonWithIcon(
                              text: "",
                              iconURL: "assets/svg/ic_post_config.svg",
                              iconColor: kGrayColor,
                              backgroundColor: QuickHelp.isDarkMode(context)
                                  ? kContentColorLightTheme
                                  : Colors.white,
                              onTap: () => openSheet(post.getAuthor!, post),
                              borderRadius: 50,
                              width: 50,
                              height: 50,
                              urlIconColor: kGrayColor,
                            ),
                          ],
                        ),
                        Visibility(
                          visible: post.getText!.isNotEmpty,
                          child: TextWithTap(
                            post.getText!,
                            textAlign: TextAlign.start,
                            marginTop: 10,
                            marginBottom: 5,
                            marginLeft: 10,
                          ),
                        ),
                        Divider(
                          height: 5,
                          color: kTransparentColor,
                        ),
                        showPost(post)
                            ? QuickActions.getImageFeed(context, post)
                            : GestureDetector(
                                onTap: () => chargeUserAndShowImage(post),
                                //onTap: () => getPremiumSubs(),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    /*Blur(
                                      blurColor: Colors.transparent,
                                      blur: 25,
                                      child: QuickActions.getImageFeed(
                                          context, post),
                                    ),*/
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.width,
                                      child: Image.asset("assets/images/blurred_image.jpg"),
                                    ),
                                    ContainerCorner(
                                      color: Colors.white.withOpacity(0.5),
                                      borderRadius: 20,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            QuickActions.showSVGAsset(
                                              "assets/svg/ic_coin_with_star.svg",
                                              width: 24,
                                              height: 24,
                                            ),
                                            TextWithTap(
                                              "feed.post_cost_exclusive".tr(
                                                  namedArgs: {
                                                    "coins": post.getPaidAmount!
                                                        .toString()
                                                  }),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              marginLeft: 6,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        Visibility(
                          visible: post.getLikes!.length > 0 ||
                              post.getLastDiamondAuthor != null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ContainerCorner(
                                marginLeft: 10,
                                marginTop: 15,
                                color: kTransparentColor,
                                child: Row(
                                  children: [
                                    post.getLastLikeAuthor != null
                                        ? QuickActions.avatarWidget(
                                            post.getLastLikeAuthor!,
                                            width: 24,
                                            height: 24)
                                        : Container(),
                                    TextWithTap(
                                      post.getLikes!.length.toString() +
                                          " " +
                                          "feed.people_like_this".tr(),
                                      color: kTabIconDefaultColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      marginLeft: 10,
                                    ),
                                  ],
                                ),
                              ),
                              ContainerCorner(
                                color: kTransparentColor,
                                marginRight: 10,
                                marginTop: 15,
                                child: Row(
                                  children: [
                                    post.getLastDiamondAuthor != null
                                        ? QuickActions.avatarWidget(
                                            post.getLastDiamondAuthor!,
                                            width: 24,
                                            height: 24)
                                        : Container(),
                                    TextWithTap(""),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ContainerCorner(
                          marginTop: 20,
                          height: 1,
                          marginLeft: 15,
                          marginRight: 15,
                          color: QuickHelp.isDarkMode(context)
                              ? kTabIconDefaultColor.withOpacity(0.4)
                              : kTabIconDefaultColor.withOpacity(0.4),
                        ),
                        Visibility(
                          visible: showPost(post),
                          child: ContainerCorner(
                            color: QuickHelp.isDarkMode(context)
                                ? kContentColorLightTheme
                                : Colors.white,
                            child: Row(
                              children: [
                                ButtonWithIcon(
                                  marginLeft: 10,
                                  text: post.getLikes!.length.toString(),
                                  textColor: kTabIconDefaultColor,
                                  iconURL: liked
                                      ? null
                                      : "assets/svg/ic_post_like.svg",
                                  urlIconColor: liked
                                      ? kTabIconSelectedColor
                                      : kTabIconDefaultColor,
                                  icon: liked ? Icons.favorite : null,
                                  iconColor: liked
                                      ? kTabIconSelectedColor
                                      : kTabIconDefaultColor,
                                  backgroundColor: QuickHelp.isDarkMode(context)
                                      ? kContentColorLightTheme
                                      : Colors.white,
                                  onTap: () {
                                    if (liked) {
                                      post.removeLike =
                                          widget.currentUser!.objectId!;
                                      //post.unset(PostsModel.keyLastLikeAuthor);

                                      _deleteLike(post);
                                      post.save();
                                    } else {
                                      post.setLikes =
                                          widget.currentUser!.objectId!;
                                      post.setLastLikeAuthor =
                                          widget.currentUser!;

                                      post.save();
                                      _likePost(post);
                                    }
                                  },
                                ),
                                ButtonWithIcon(
                                  text: post.getComments!.length.toString(),
                                  textColor: kTabIconDefaultColor,
                                  urlIconColor: kTabIconDefaultColor,
                                  iconURL: "assets/svg/ic_post_comment.svg",
                                  onTap: () => QuickHelp.goToNavigator(
                                      context, CommentPostScreen.route,
                                      arguments: {
                                        "currentUser": widget.currentUser,
                                        "post": post
                                      }),
                                  backgroundColor: QuickHelp.isDarkMode(context)
                                      ? kContentColorLightTheme
                                      : Colors.white,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  if (index % _kAdIndex == 0) {
                    return getAdsFuture();
                  } else {
                    return Container();
                  }
                },
              );
            } else {
              return Center(
                child: QuickActions.noContentFound(
                    "feed.no_feed_title".tr(),
                    "feed.no_feed_explain".tr(),
                    "assets/svg/ic_tab_feed_default.svg"),
              );
            }
          } else {
            return Center(
              child: QuickActions.noContentFound(
                  "feed.no_feed_title".tr(),
                  "feed.no_feed_explain".tr(),
                  "assets/svg/ic_tab_feed_default.svg"),
            );
          }
        });
  }

  Widget getAdsFuture(){

    return FutureBuilder(
        future: QuickHelp.isIOSPlatform() ? loadAds() : loadNativeAds(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: QuickHelp.showLoadingAnimation(),
            );
          } else if (snapshot.hasData) {

            AdWithView ad = snapshot.data as AdWithView;

            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              color: QuickHelp.isDarkMode(context)
                  ? kContentColorLightTheme
                  : Colors.white,
              margin: EdgeInsets.only(top: 7),
              child: AdWidget(ad: ad, key: Key(
                ad.hashCode.toString(),
              ),),
            );
          } else {
            return Container();
          }
        }
    );
  }

  Future<dynamic> loadNativeAds() async {

    NativeAd _listAd = NativeAd(
      adUnitId: Constants.getAdmobFeedNativeUnit(),
      factoryId: "listTile",
      request: const AdRequest(),
      listener: NativeAdListener(onAdLoaded: (ad) {
        if (kDebugMode) {
          print("Ad Got onAdLoaded");
        }
      }, onAdFailedToLoad: (ad, error) {
        debugPrint("Ad Got onAdFailedToLoad ${error.message}");
        ad.dispose();
      }, onAdClosed: (ad) {
        debugPrint("Ad Got onAdClosed");
        ad.dispose();
      }, onAdWillDismissScreen: (ad) {
        debugPrint("Ad Got onAdWillDismissScreen");
        ad.dispose();
      }),
    );
    return _listAd..load();
  }

  Future<dynamic> loadAds() async {

    BannerAdListener bannerAdListener = BannerAdListener(
      onAdWillDismissScreen: (ad) {
        debugPrint("Ad Got onAdWillDismissScreen");
        ad.dispose();
      },
      onAdClosed: (ad) {
        debugPrint("Ad Got Closed");
        ad.dispose();
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint("Ad Got onAdFailedToLoad");
        ad.dispose();
      },
      onAdLoaded: (ad) {
        debugPrint("Ad Got onAdLoaded");
      },
    );

    BannerAd bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: Constants.getAdmobFeedNativeUnit(),
      listener: bannerAdListener,
      request: const AdRequest(),
    );

    return bannerAd..load();
  }

  void openVideo(PostsModel post) async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showFeedVideoBottomSheet(post);
        });
  }

  _showFeedVideoBottomSheet(PostsModel post) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: DraggableScrollableSheet(
            initialChildSize: 1.0,
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
                  child: ContainerCorner(
                    color: kTransparentColor,
                    height: MediaQuery.of(context).size.height - 200,
                    /*child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: BetterPlayer.network(
                        post.getVideo!.url!,
                        betterPlayerConfiguration: BetterPlayerConfiguration(
                          aspectRatio: 1 / 1,
                        ),
                      ),
                    ),*/
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }

  Future<void> checkPermission() async {
    if (QuickHelp.isAndroidPlatform()) {
      PermissionStatus status = await Permission.storage.status;
      PermissionStatus status2 = await Permission.camera.status;
      print('Permission android');

      checkStatus(status, status2);
    } else if (QuickHelp.isIOSPlatform()) {
      PermissionStatus status = await Permission.photos.status;
      PermissionStatus status2 = await Permission.camera.status;
      print('Permission ios');

      checkStatus(status, status2);
    } else {
      print('Permission other device');
      _showCreatePostBottomSheet(context);
    }
  }

  void checkStatus(PermissionStatus status, PermissionStatus status2) {
    if (status.isDenied || status2.isDenied) {
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
            ].request();

            if (statuses[Permission.camera]!.isGranted &&
                    statuses[Permission.photos]!.isGranted ||
                statuses[Permission.storage]!.isGranted) {
              _showCreatePostBottomSheet(context);
            }
          });
    } else if (status.isPermanentlyDenied || status2.isPermanentlyDenied) {
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
    } else if (status.isGranted && status2.isGranted) {
      //_uploadPhotos(ImageSource.gallery);
      _showCreatePostBottomSheet(context);
    }

    print('Permission $status');
    print('Permission $status2');
  }

  void _showCreatePostBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            color: Color.fromRGBO(0, 0, 0, 0.001),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: DraggableScrollableSheet(
                initialChildSize: 0.9,
                minChildSize: 0.1,
                maxChildSize: 1.0,
                builder: (_, controller) {
                  return StatefulBuilder(builder: (context, setState) {
                    return Container(
                      decoration: BoxDecoration(
                        color: QuickHelp.isDarkMode(context)
                            ? kContentColorLightTheme
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25.0),
                          topRight: Radius.circular(25.0),
                        ),
                      ),
                      child: Container(
                        color: QuickHelp.isDarkMode(context)
                            ? kContentColorLightTheme
                            : Colors.white,
                        margin: EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Icon(
                              Icons.remove,
                              color: Colors.grey[600],
                            ),
                            ContainerCorner(
                              color: kGreyColor0,
                              borderRadius: 10,
                              height: 80,
                              marginTop: 20,
                              marginBottom: 10,
                              child: TextFormField(
                                minLines: 1,
                                maxLines: 100,
                                controller: postContent,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                style: TextStyle(
                                  color: kGreyColor2,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                keyboardType: TextInputType.multiline,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "";
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: "feed.whats_new".tr(),
                                  focusedBorder: InputBorder.none,
                                  border: InputBorder.none,
                                  //errorText: "edit_profile.hint_about_you".tr(),
                                  contentPadding: EdgeInsets.only(left: 10),
                                  hintStyle: TextStyle(
                                    color: kGreyColor2,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ContainerCorner(
                                color: kGreyColor0,
                                width: 400,
                                height: 400,
                                borderRadius: 10,
                                child: uploadPhoto.isNotEmpty
                                    ? Image.file(File(uploadPhoto))
                                    : Icon(
                                        Icons.image_outlined,
                                        color: kPrimaryColor,
                                        size: 80,
                                      ),
                                onTap: () => _pickFile(setState),
                              ),
                            ),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Switch.adaptive(
                                        activeColor: kPrimaryColor,
                                        value: isSwitchedForPremium,
                                        onChanged: (bool value) {
                                          setState(() {
                                            isSwitchedForPremium = value;
                                          });
                                        }),
                                    Visibility(
                                      visible: false,
                                      child: TextWithTap(
                                        "feed.for_".tr(),
                                        marginRight: 10,
                                        color: isSwitchedForPremium
                                            ? kPrimaryColor
                                            : QuickHelp.isDarkModeNoContext()
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                    TextWithTap(
                                      "feed.for_subscriber_only".tr(namedArgs: {
                                        "coins": Setup
                                            .coinsNeededToForExclusivePost
                                            .toString()
                                      }),
                                      marginLeft: 10,
                                      color: isSwitchedForPremium
                                          ? kPrimaryColor
                                          : QuickHelp.isDarkModeNoContext()
                                              ? Colors.white
                                              : Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                    QuickActions.showSVGAsset(
                                      "assets/svg/ic_coin_active.svg",
                                      width: 30,
                                      height: 30,
                                      //color: kPrimaryColor,
                                    ),
                                  ],
                                ),
                                Visibility(
                                  visible: true,
                                  child: TextWithTap(
                                    isSwitchedForPremium
                                        ? "feed.for_subscriber_only_explain_exc"
                                            .tr(namedArgs: {
                                            "coins": Setup
                                                .coinsNeededToForExclusivePost
                                                .toString()
                                          })
                                        : "feed.for_subscriber_only_explain".tr(
                                            namedArgs: {
                                                "coins": Setup
                                                    .coinsNeededToForExclusivePost
                                                    .toString()
                                              }),
                                    marginLeft: 10,
                                    color: isSwitchedForPremium
                                        ? kPrimaryColor
                                        : kPrimacyGrayColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                ContainerCorner(
                                  height: 50,
                                  color: kTransparentColor,
                                ),
                                ButtonWithGradient(
                                  marginTop: 10,
                                  height: 50,
                                  borderRadius: 20,
                                  text: isSwitchedForPremium
                                      ? "feed.post_exclusive".tr()
                                      : "feed.post_".tr(),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  textColor: Colors.white,
                                  onTap: () {
                                    if (isVideo!) {
                                      initDoSpaces(videoFile,
                                          text: postContent.text);
                                    } else {
                                      if (parseFile != null &&
                                          uploadPhoto.isNotEmpty) {
                                        savePost(text: postContent.text);
                                      }
                                    }
                                  },
                                  beginColor: isSwitchedForPremium
                                      ? kWarninngColor
                                      : kPrimaryColor,
                                  endColor: isSwitchedForPremium
                                      ? kPrimaryColor
                                      : kPrimaryColor,
                                ),
                              ],
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
      },
    );
  }

  Widget _showPostOptionsAndReportAuthor(UserModel author, PostsModel post) {
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
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                visible: widget.currentUser!.objectId != post.getAuthorId,
                child: ButtonWithIcon(
                  text: "feed.report_post"
                      .tr(namedArgs: {"name": author.getFullName!}),
                  //iconURL: "assets/svg/ic_blocked_menu.svg",
                  icon: Icons.report_problem_outlined,
                  iconColor: kPrimaryColor,
                  iconSize: 26,
                  height: 60,
                  radiusTopLeft: 25.0,
                  radiusTopRight: 25.0,
                  backgroundColor: Colors.white,
                  mainAxisAlignment: MainAxisAlignment.start,
                  textColor: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  onTap: () {
                    openReportMessage(author, post);
                  },
                ),
              ),
              Visibility(
                  visible: widget.currentUser!.objectId != post.getAuthorId,
                  child: Divider()),
              Visibility(
                visible: widget.currentUser!.objectId != post.getAuthorId,
                child: ButtonWithIcon(
                  text: "feed.block_user"
                      .tr(namedArgs: {"name": author.getFullName!}),
                  textColor: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  //iconURL: "assets/images/ic_block_user.png",
                  icon: Icons.block,
                  iconColor: kPrimaryColor,
                  iconSize: 26,
                  onTap: () {
                    Navigator.of(context).pop();
                    QuickHelp.showDialogWithButtonCustom(
                      context: context,
                      title: "feed.post_block_title".tr(),
                      message: "feed.post_block_message"
                          .tr(namedArgs: {"name": author.getFullName!}),
                      cancelButtonText: "cancel".tr(),
                      confirmButtonText: "feed.post_block_confirm".tr(),
                      onPressed: () => _blockUser(author),
                    );
                  },
                  height: 60,
                  backgroundColor: Colors.white,
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
              ),
              Visibility(
                  visible: widget.currentUser!.objectId != post.getAuthorId,
                  child: Divider()),
              Visibility(
                visible: widget.currentUser!.objectId == post.getAuthorId ||
                    widget.currentUser!.isAdmin!,
                child: ButtonWithIcon(
                  text: post.getExclusive!
                      ? "feed.move_exclusive_post_pub".tr()
                      : "feed.move_exclusive_post".tr(),
                  iconURL: "assets/svg/config.svg",
                  height: 60,
                  radiusTopLeft: 25.0,
                  radiusTopRight: 25.0,
                  backgroundColor: Colors.white,
                  mainAxisAlignment: MainAxisAlignment.start,
                  textColor: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  onTap: () {
                    _moveExclusivePost(post);
                  },
                ),
              ),
              Visibility(
                  visible: widget.currentUser!.isAdmin!, child: Divider()),
              Visibility(
                visible: widget.currentUser!.objectId == post.getAuthorId ||
                    widget.currentUser!.isAdmin!,
                child: ButtonWithIcon(
                  text: "feed.delete_post".tr(),
                  iconURL: "assets/svg/config.svg",
                  height: 60,
                  radiusTopLeft: 25.0,
                  radiusTopRight: 25.0,
                  backgroundColor: Colors.white,
                  mainAxisAlignment: MainAxisAlignment.start,
                  textColor: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  onTap: () {
                    _deletePost(post);
                  },
                ),
              ),
              Visibility(
                  visible: widget.currentUser!.objectId == post.getAuthorId ||
                      widget.currentUser!.isAdmin!,
                  child: Divider()),
              Visibility(
                visible: widget.currentUser!.isAdmin!,
                child: ButtonWithIcon(
                  text: "feed.suspend_user".tr(),
                  iconURL: "assets/svg/config.svg",
                  height: 60,
                  radiusTopLeft: 25.0,
                  radiusTopRight: 25.0,
                  backgroundColor: Colors.white,
                  mainAxisAlignment: MainAxisAlignment.start,
                  textColor: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  onTap: () {
                    _suspendUser(post);
                  },
                ),
              ),
              Visibility(
                  visible: widget.currentUser!.isAdmin!, child: Divider()),
            ],
          ),
        ),
      ),
    );
  }

  _blockUser(UserModel author) async {
    Navigator.of(context).pop();
    QuickHelp.showLoadingDialog(context);

    widget.currentUser!.setBlockedUser = author;
    widget.currentUser!.setBlockedUserIds = author.objectId!;

    ParseResponse response = await widget.currentUser!.save();
    if (response.success) {
      widget.currentUser = response.results!.first as UserModel;
      _future = _loadFeeds(isExclusive: false);

      QuickHelp.hideLoadingDialog(context);
      //QuickHelp.goToNavigator(context, BlockedUsersScreen.route);
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "feed.post_block_success_title"
            .tr(namedArgs: {"name": author.getFullName!}),
        message: "feed.post_block_success_message".tr(),
        isError: false,
      );
    } else {
      QuickHelp.hideLoadingDialog(context);
    }
  }

  void openReportMessage(UserModel author, PostsModel post) async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showReportMessageBottomSheet(author, post);
        });
  }

  Widget _showReportMessageBottomSheet(UserModel author, PostsModel post) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.45,
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
                          "feed.report_".tr(),
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          marginBottom: 50,
                        ),
                        Column(
                          children: List.generate(
                              QuickHelp.getReportCodeMessageList().length,
                              (index) {
                            String code =
                                QuickHelp.getReportCodeMessageList()[index];

                            return TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                print("Message: " +
                                    QuickHelp.getReportMessage(code));
                                Navigator.of(context).pop();
                                _saveReport(
                                    QuickHelp.getReportMessage(code), post);
                              },
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
              });
            },
          ),
        ),
      ),
    );
  }

  _saveReport(String reason, PostsModel post) async {
    QuickHelp.showLoadingDialog(context);

    widget.currentUser?.setReportedPostIDs = post.objectId;
    widget.currentUser?.setReportedPostReason = reason;

    ParseResponse response = await widget.currentUser!.save();
    if (response.success) {
      QuickHelp.hideLoadingDialog(context);
      setState(() {});
    } else {
      QuickHelp.hideLoadingDialog(context);
    }

    ParseResponse parseResponse = await QuickActions.report(
        type: ReportModel.reportTypePost,
        message: reason,
        accuser: widget.currentUser!,
        accused: post.getAuthor!,
        postsModel: post);

    if (parseResponse.success) {
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "feed.post_report_success_title"
            .tr(namedArgs: {"name": post.getAuthor!.getFullName!}),
        message: "feed.post_report_success_message".tr(),
        isError: false,
      );
    } else {
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "try_again_later".tr(),
      );
    }
  }

  _pickFile(StateSetter setState) async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 1,
        //gridCount: 3,
        //pageSize: ,
        requestType: RequestType.image,
        //specialPickerType: SpecialPickerType.wechatMoment,
        filterOptions: FilterOptionGroup(
          containsLivePhotos: true,
        ),
        //pickerTheme: themeDataPicker(kPrimaryColor, light: !QuickHelp.isDarkModeNoContext()),
      ),
    );

    if (result != null && result.length > 0) {
      final File? file = await result.first.file;
      final preview = await result.first.thumbnailData;

      print(preview != null ? "selected video" : "Selected Image");

      String? mimeStr = lookupMimeType(file!.path);
      var fileType = mimeStr!.split('/');

      print('Selected file type $fileType');

      if (fileType.contains("video")) {
        isVideo = true;
        print('Selected file is video $isVideo');
        //uploadVideo(file.path, preview!, setState);
        prepareVideo(file, preview!, setState);
      } else if (fileType.contains("image")) {
        isVideo = false;
        print('Selected file is video $isVideo');
        cropPhoto(file.path, setState);
      }
    }
  }

  prepareVideo(File file, Uint8List previewPath, StateSetter setState) async {
    VideoEditorModel? videoEditorModel =
        await QuickHelp.goToNavigatorScreenForResult(
            context, VideoEditorScreen(file: file));

    if (videoEditorModel != null) {
      print("Exported cover received ${videoEditorModel.coverPath}");
      print("Exported Video received ${videoEditorModel.getVideoFile()!.path}");

      //uploadVideo(videoFile.getVideoFile()!.path, videoFile.getCoverPath()!, setState);
      //initDoSpaces(videoFile.getVideoFile(), videoFile.getCoverPath()!, setState);
      videoFile = videoEditorModel.getVideoFile();

      parseFileThumbnail =
          ParseFile(File(videoEditorModel.coverPath!), name: "thumbnail.jpg");
      setState(() {
        uploadPhoto = videoEditorModel.coverPath!;
      });
    }
  }

  initDoSpaces(File? videoFile, {String? text}) async {
    QuickHelp.hideLoadingDialog(context);

    QuickHelp.showLoadingDialog(context);

    dospace.Spaces spaces = new dospace.Spaces(
      region: SharedManager().getS3Region(widget.preferences),
      accessKey: SharedManager().getS3AccessKey(widget.preferences),
      secretKey: SharedManager().getS3SecretKey(widget.preferences),
    );

    String fileName =
        "video_file_${widget.currentUser!.objectId!}_${DateTime.now().toLocal().millisecond}_${QuickHelp.generateUId()}.mp4";
    String url = "${SharedManager().getS3Url(widget.preferences)}$fileName";
    String? etag = await spaces
        .bucket(SharedManager().getS3Bucket(widget.preferences))
        .uploadFile(
          fileName,
          videoFile,
          'video/mp4',
          dospace.Permissions.public,
        );

    print('upload: $etag');
    print('Url: $url');

    await spaces.close();

    parseFile = ParseFile(
      null,
      url: url,
      name: fileName,
    );

    savePost(text: text);
    //uploadVideo(url, coverPath, setState);
  }

  uploadVideo(String videoPath, String coverPath, StateSetter setState) async {

    if (QuickHelp.isWebPlatform()) {
      ParseWebFile file = ParseWebFile(null, name: "video.mp4", url: videoPath);
      ParseWebFile thumbnail =
          ParseWebFile(null, name: "thumbnail.jpg", url: coverPath);

      await file.download();
      await thumbnail.download();

      parseFile = ParseWebFile(file.file, name: file.name);
      parseFileThumbnail = ParseWebFile(thumbnail.file, name: thumbnail.name);
    } else {

      parseFile = ParseFile(
        null,
        url: videoPath,
        name: "video.mp4",
      );

      parseFileThumbnail = ParseFile(File(coverPath), name: "thumbnail.jpg");
    }

    setState(() {
      uploadPhoto = coverPath;
    });
  }

  void cropPhoto(String path, StateSetter setState) async {
    CroppedFile? croppedFile =
        await ImageCropper().cropImage(sourcePath: path, uiSettings: [
      AndroidUiSettings(
          toolbarTitle: "edit_photo".tr(),
          toolbarColor: kPrimaryColor,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false),
      IOSUiSettings(
        minimumAspectRatio: 1.0,
      )
    ]);

    if (croppedFile != null) {
      if (QuickHelp.isWebPlatform()) {
        //Seems weird, but this lets you get the data from the selected file as an Uint8List very easily.
        ParseWebFile file =
            ParseWebFile(null, name: "avatar.jpg", url: croppedFile.path);
        await file.download();
        parseFile = ParseWebFile(file.file, name: file.name);
      } else {
        parseFile = ParseFile(File(croppedFile.path), name: "avatar.jpg");
      }

      setState(() {
        uploadPhoto = croppedFile.path;
      });
    }
  }

  _deletePost(PostsModel post) {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showDialogWithButtonCustom(
      context: context,
      title: "feed.delete_post_alert".tr(),
      message: "feed.delete_post_message".tr(),
      cancelButtonText: "no".tr(),
      confirmButtonText: "feed.yes_delete".tr(),
      onPressed: () => _confirmDeletePost(post),
    );
  }

  _suspendUser(PostsModel post) {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showDialogWithButtonCustom(
      context: context,
      title: "feed.suspend_user_alert".tr(),
      message: "feed.suspend_user_message".tr(),
      cancelButtonText: "no".tr(),
      confirmButtonText: "feed.yes_suspend".tr(),
      onPressed: () => _confirmSuspendUser(post.getAuthor!),
    );
  }

  _confirmSuspendUser(UserModel userModel) async {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showLoadingDialog(context);

    userModel.setActivationStatus = true;
    ParseResponse parseResponse =
        await QuickCloudCode.suspendUSer(objectId: userModel.objectId!);
    if (parseResponse.success) {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "suspended".tr(),
        message: "feed.user_suspended".tr(),
        user: userModel,
        isError: null,
      );
    } else {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "feed.user_not_suspended".tr(),
        user: userModel,
        isError: true,
      );
    }
  }

  _confirmDeletePost(PostsModel postsModel) async {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showLoadingDialog(context);

    ParseResponse parseResponse = await postsModel.delete();
    if (parseResponse.success) {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "deleted".tr(),
        message: "feed.post_deleted".tr(),
        user: postsModel.getAuthor,
        isError: null,
      );
    } else {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "feed.post_not_deleted".tr(),
        user: postsModel.getAuthor,
        isError: true,
      );
    }
  }

  _moveExclusivePost(PostsModel post) {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showDialogWithButtonCustom(
      context: context,
      title: "feed.move_post_alert".tr(),
      message: post.getExclusive!
          ? "feed.move_post_message_pub".tr()
          : "feed.move_post_message".tr(),
      cancelButtonText: "no".tr(),
      confirmButtonText: "feed.move_post_yes_move".tr(),
      onPressed: () => _confirmMoveExclusivePost(post),
    );
  }

  _confirmMoveExclusivePost(PostsModel postsModel) async {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showLoadingDialog(context);

    postsModel.setExclusive = !postsModel.getExclusive!;
    ParseResponse parseResponse = await postsModel.save();
    if (parseResponse.success) {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "moved".tr(),
        message: !postsModel.getExclusive!
            ? "feed.move_post_moved_pub".tr()
            : "feed.move_post_moved".tr(),
        user: postsModel.getAuthor,
        isError: null,
      );
    } else {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "feed.post_not_moved".tr(),
        user: postsModel.getAuthor,
        isError: true,
      );
    }
  }

  bool showPost(PostsModel post) {
    if (post.getExclusive!) {
      if (post.getAuthorId == widget.currentUser!.objectId) {
        return true;
      } else if (post.getPaidBy!.contains(widget.currentUser!.objectId)) {
        return true;
      } else if (widget.currentUser!.isAdmin!) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  void chargeUserAndShowImage(PostsModel post) async {
    if (widget.currentUser!.getCredits! >= post.getPaidAmount!) {
      QuickHelp.showLoadingDialog(context);

      widget.currentUser!.removeCredit = post.getPaidAmount!;
      ParseResponse saved = await widget.currentUser!.save();
      if (saved.success) {
        QuickCloudCode.sendGift(
            author: post.getAuthor!,
            credits: post.getPaidAmount!,
            preferences: widget.preferences!);

        widget.currentUser = saved.results!.first! as UserModel;

        post.setPaidBy = widget.currentUser!.objectId!;
        ParseResponse savedPost = await post.save();
        if (savedPost.success) {
          QuickHelp.hideLoadingDialog(context);
        } else {
          QuickHelp.hideLoadingDialog(context);
          QuickHelp.showAppNotification(
              title: "error".tr(), context: context, isError: true);
        }
      } else {
        QuickHelp.hideLoadingDialog(context);
        QuickHelp.showAppNotification(
            title: "error".tr(), context: context, isError: true);
      }
    } else {
      QuickHelp.showAppNotification(
          title: "video_call.no_coins".tr(), context: context, isError: true);
    }
  }
}
