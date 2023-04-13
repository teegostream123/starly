import 'package:blur/blur.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teego/helpers/quick_actions.dart';
import 'package:teego/helpers/quick_cloud.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/home/feed/comment_post_screen.dart';
import 'package:teego/home/message/message_screen.dart';
import 'package:teego/models/NotificationsModel.dart';
import 'package:teego/models/PostsModel.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/button_with_icon.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';

import '../../models/ReportModel.dart';
import '../../ui/app_bar.dart';

// ignore: must_be_immutable
class UserProfileScreen extends StatefulWidget {
  UserModel? currentUser, mUser;
  bool? isFollowing;

  UserProfileScreen({this.currentUser, this.mUser, this.isFollowing});

  static String route = '/user/profile';

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {

  int tabIndex = 0;

  SharedPreferences? preferences;

  _gotToChat(UserModel currentUser, UserModel mUser) {
    QuickHelp.goToNavigator(context, MessageScreen.route, arguments: {
      "currentUser": widget.currentUser,
      "mUser": widget.mUser,
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {

    init();
    super.initState();
  }

  init() async {
   preferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {

    return ToolBar(
      centerTitle: true,
      extendBodyBehindAppBar: true,
      iconColor: Colors.white,
      rightIconColor: Colors.white,
      rightButtonTwoIcon: Icons.more_vert,
      leftButtonIcon: QuickHelp.isIOSPlatform() ? Icons.arrow_back_ios : Icons.arrow_back,
      onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
      rightButtonTwoPress: () => openSheet(widget.mUser!, null),
      backgroundColor: Colors.black.withOpacity(0.5),
      child: SingleChildScrollView(
        child: Container(
          color: QuickHelp.isDarkMode(context) ? kTabIconDefaultColor.withOpacity(0.1) : kGreyColor0,
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 400,
                color: widget.mUser!.getAvatar == null
                    ? Colors.black
                    : Colors.transparent,
                child: Stack(
                  children: [
                    QuickActions.profileCover(
                        widget.mUser!.getAvatar != null
                            ? widget.mUser!.getAvatar!.url!
                            : "null",
                        borderRadius: 0),
                    Positioned(
                        bottom: 0,
                        child: ContainerCorner(
                          width: MediaQuery.of(context).size.width,
                          height: 100,
                          colors: [ Colors.black, Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,

                        ),
                    ),
                    Positioned(
                        bottom: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWithTap(
                              widget.mUser!.getFullName!,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              marginLeft: 10,
                              color: Colors.white,
                            ),
                            Row(
                              children: [
                                TextWithTap(
                                  QuickHelp.getGender(widget.mUser!),
                                  fontSize: 16,
                                  marginLeft: 10,
                                  color: Colors.white,
                                  marginBottom: 10,
                                ),
                                /*TextWithTap(
                                  ", ",
                                  fontSize: 16,
                                  color: Colors.white,
                                  marginBottom: 10,
                                ),
                                TextWithTap(
                                  widget.mUser!.getCity!,
                                  fontSize: 16,
                                  color: Colors.white,
                                  marginBottom: 10,
                                )*/
                              ],
                            ),
                          ],
                        ),
                    ),
                  ],
                ),
              ),
              Container(
                color: QuickHelp.isDarkMode(context) ? kContentColorLightTheme : kContentColorDarkTheme,
                margin: EdgeInsets.only(bottom: 7),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ContainerCorner(
                        width: MediaQuery.of(context).size.width - 100,
                        height: 60,
                        borderRadius: 50,
                        marginRight: 10,
                        onTap: () {
                          followOrUnfollow(!widget.isFollowing!);
                        },
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [kPrimaryColor, kSecondaryColor],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextWithTap(
                              widget.isFollowing! ? "-" : "+",
                              fontSize: 28,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                            TextWithTap(
                              widget.isFollowing! ? "live_streaming.live_unfollow".tr() :"live_streaming.live_follow".tr(),
                              fontSize: 18,
                              color: Colors.white,
                              marginLeft: 5,
                            ),
                          ],
                        ),
                      ),
                      ContainerCorner(
                        width: 60,
                        height: 60,
                        borderRadius: 50,
                        marginRight: 10,
                        onTap: () =>
                            _gotToChat(widget.currentUser!, widget.mUser!),
                        color: kPhotosGrayColor,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: ContainerCorner(
                            width: 10,
                            height: 10,
                            color: kTransparentColor,
                            child: QuickActions.showSVGAsset(
                              "assets/svg/ic_tab_chat_default.svg",
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ContainerCorner(
                color: QuickHelp.isDarkMode(context)
                    ? kContentColorLightTheme
                    : Colors.white,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 40, right: 40) ,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ContainerCorner(
                            color: QuickHelp.isDarkMode(context)
                                ? kContentColorLightTheme
                                : Colors.white,
                            height: 50,
                            //width: MediaQuery.of(context).size.width / 3,
                            child: Column(
                              children: [
                                TextWithTap(
                                  "profile_screen.followers_".tr(),
                                  marginTop: 3,
                                ),
                                TextWithTap(
                                  widget.mUser!.getFollowers!.length
                                      .toString(),
                                  marginTop: 2,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  marginRight: 20,
                                ),
                              ],
                            ),
                            onTap: ()=> widget.mUser!.getFollowers!.length > 0 ? openSheetFollow(false, widget.mUser!.getFollowers!) : null,
                          ),
                          Container(
                            color: QuickHelp.isDarkMode(context)
                                ? kContentColorLightTheme
                                : Colors.white,
                            height: 50,
                            //width: MediaQuery.of(context).size.width / 3,
                            child: Column(
                              children: [
                                //TextWithTap(""),
                                QuickActions.showSVGAsset(
                                  "assets/svg/ic_diamond.svg",
                                  height: 30,
                                  width: 30,
                                ),
                                TextWithTap(
                                  widget.mUser!.getDiamonds.toString(),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  //marginRight: 20,
                                )
                              ],
                            ),
                          ),
                          ContainerCorner(
                            color: QuickHelp.isDarkMode(context)
                                ? kContentColorLightTheme
                                : Colors.white,
                            height: 50,
                            //width: MediaQuery.of(context).size.width / 3 - 6,
                            child: Column(
                              children: [
                                TextWithTap(
                                  "profile_screen.following_".tr(),
                                  marginTop: 3,
                                ),
                                TextWithTap(
                                  widget.mUser!.getFollowing!.length
                                      .toString(),
                                  marginTop: 2,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  marginRight: 20,
                                ),
                              ],
                            ),
                            onTap: ()=> widget.mUser!.getFollowing!.length > 0 ? openSheetFollow(true, widget.mUser!.getFollowing!) : null,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      child: ContainerCorner(
                        marginLeft: 40,
                        marginRight: 40,
                        marginBottom: 20,
                        width: MediaQuery.of(context).size.width - 20,
                        borderRadius: 10,
                        color: QuickHelp.isDarkMode(context)
                            ? kDisabledGrayColor
                            : kGreyColor0,
                        child: TextWithTap(
                          widget.mUser!.getAboutYou!.isNotEmpty
                              ? widget.mUser!.getAboutYou!
                              : "profile_screen.profile_desc_hint".tr(),
                          marginRight: 10,
                          marginBottom: 10,
                          marginTop: 10,
                          marginLeft: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: ()=> indexTap(0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              QuickActions.showSVGAsset(
                                "assets/svg/ic_followers_active.svg",
                                color: tabIndex == 0 ? kPrimaryColor : kDisabledGrayColor,
                              ),
                              SizedBox(width: 5),
                              TextWithTap("feed.for_all".tr(),
                                fontSize: 16,
                                color: tabIndex == 0 ? kPrimaryColor : kDisabledGrayColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: ()=> indexTap(1),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              QuickActions.showSVGAsset(
                                "assets/svg/ic_gold_star_small.svg",
                                color: tabIndex == 1 ? kPrimaryColor : kDisabledGrayColor,
                              ),
                              SizedBox(width: 5),
                              TextWithTap("feed.exclusive_".tr(),
                                fontSize: 16,
                                color: tabIndex == 1 ? kPrimaryColor : kDisabledGrayColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IndexedStack(
                index: tabIndex,
                children: <Widget>[
                  initQuery(false),
                  initQuery(true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  indexTap(int index){
    setState(() {
      tabIndex = index;
    });
  }

  Future<List<dynamic>?> _loadFeeds(bool? isExclusive) async {
    QueryBuilder<PostsModel> queryBuilder =
    QueryBuilder<PostsModel>(PostsModel());
    queryBuilder.includeObject([
      PostsModel.keyAuthor,
      PostsModel.keyLastLikeAuthor,
      PostsModel.keyLastDiamondAuthor
    ]);
    //queryBuilder.whereEqualTo(PostsModel.keyPostType, false);
    queryBuilder.whereEqualTo(PostsModel.keyAuthor, widget.mUser);
    queryBuilder.whereEqualTo(PostsModel.keyExclusive, isExclusive);

    queryBuilder.whereNotContainedIn(
        PostsModel.keyObjectId, widget.currentUser!.getReportedPostIDs!);
    queryBuilder.whereValueExists(PostsModel.keyVideo, false);

    queryBuilder.orderByDescending(keyVarCreatedAt);

    ParseResponse apiResponse = await queryBuilder.query();
    if (apiResponse.success) {
      print("Lives count: ${apiResponse.results!.length}");
      if (apiResponse.results != null) {
        return apiResponse.results;
      } else {
        return AsyncSnapshot.nothing() as dynamic;
      }
    } else {
      return apiResponse.error as dynamic;
    }
  }

  Widget initQuery(bool isExclusive) {
    return FutureBuilder(
        future: _loadFeeds(isExclusive),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator.adaptive(
                backgroundColor: QuickHelp.isDarkMode(context)
                    ? kContentColorLightTheme
                    : Colors.white,
              ),
            );
          }
          if (snapshot.hasData) {
            if (widget.mUser != null) {
              widget.mUser = widget.mUser;
            }

            List<dynamic> results = snapshot.data! as List<dynamic>;

            return Column(
              children: List.generate(results.length, (index){

                PostsModel post = results[index];

                var liked = post.getLikes!.length > 0 &&
                    post.getLikes!.contains(widget.mUser!.objectId!);

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
                            ),
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
                          ? post.isVideo!
                          ? QuickActions.getImageFeed(context, post) //QuickActions.getVideoPlayer(post)
                          : QuickActions.getImageFeed(context, post)
                          : GestureDetector(
                        onTap: () => chargeUserAndShowImage(post),
                        //onTap: () => getPremiumSubs(),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Blur(
                              blurColor: Colors.transparent,
                              blur: 25,
                              child: QuickActions.getImageFeed(
                                  context, post),
                            ),
                            ContainerCorner(
                              //width: MediaQuery.of(context).size.width,
                              //height: MediaQuery.of(context).size.width,
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: 20,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                    post.removeLike = widget.currentUser!.objectId!;
                                    //post.unset(PostsModel.keyLastLikeAuthor);

                                    _deleteLike(post);
                                    post.save();
                                  } else {
                                    post.setLikes = widget.currentUser!.objectId!;
                                    post.setLastLikeAuthor = widget.currentUser!;

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
              }),
            );
          } else {
            return Center(
              child: QuickActions.noContentFound(
                  "feed.no_feed_title".tr(),
                  "feed.no_feed_explain".tr(),
                  "assets/svg/ic_tab_feed_selected.svg"),
            );
          }
        });
  }

  void followOrUnfollow(bool follow) async {
    setState(() {
      widget.isFollowing = !widget.isFollowing!;
    });

    if (widget.currentUser!.getFollowing!.contains(widget.mUser!.objectId)) {
      widget.currentUser!.removeFollowing = widget.mUser!.objectId!;
      await widget.currentUser!.save();
    } else {
      widget.currentUser!.setFollowing = widget.mUser!.objectId!;
      await widget.currentUser!.save();
    }
    ParseResponse parseResponse;

    if (follow) {
      parseResponse = await QuickCloudCode.followUser(
        isFollowing: false,
        author: widget.currentUser!,
        receiver: widget.mUser!,
      );
    } else {
      parseResponse = await QuickCloudCode.followUser(
        isFollowing: true,
        author: widget.currentUser!,
        receiver: widget.mUser!,
      );
    }

    if (parseResponse.success) {
      QuickActions.createOrDeleteNotification(widget.currentUser!,
          widget.mUser!, NotificationsModel.notificationTypeFollowers);
    }
  }

  _deleteLike(PostsModel postsModel) async {

    QuickActions.createOrDeleteNotification(widget.currentUser!,
        postsModel.getAuthor!, NotificationsModel.notificationTypeLikedPost,
        post: postsModel);
  }

  _likePost(PostsModel post) {
    QuickActions.createOrDeleteNotification(widget.currentUser!,
        post.getAuthor!, NotificationsModel.notificationTypeLikedPost,
        post: post);
  }

  void openSheetFollow(bool following, List<dynamic> usersIds) async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showFollow(following, usersIds);
        });
  }
  Widget _showFollow(bool following, List<dynamic> usersIds) {

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.1,
            maxChildSize: 0.9,
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
                    color: QuickHelp.isDarkMode(context) ? kContentColorLightTheme : Colors.white,
                    child: showFollowersAndFollowingWidget(usersIds),
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }

  ParseLiveListWidget showFollowersAndFollowingWidget(List<dynamic> usersIds){

    QueryBuilder<UserModel> queryBuilder = QueryBuilder<UserModel>(UserModel.forQuery());
    queryBuilder.whereContainedIn(UserModel.keyId, usersIds);

    return ParseLiveListWidget<UserModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      duration: Duration(seconds: 0),
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<UserModel> snapshot) {

        if (snapshot.hasData) {
          UserModel user = snapshot.loadedData as UserModel;
          return Padding(
            padding:  EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => QuickActions.showUserProfile(context, widget.currentUser!, user),
                  child: QuickActions.avatarWidget(user,
                    width: 50,
                    height: 50,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => QuickActions.showUserProfile(context, widget.currentUser!, user),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWithTap(
                                  user.getFullName!,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  marginLeft: 10,
                                  color: QuickHelp.isDarkMode(context)
                                      ? Colors.white
                                      : Colors.black,
                                  marginTop: 5,
                                  marginRight: 5,
                                ),
                                ContainerCorner(
                                  color: kTransparentColor,
                                  marginLeft: 10,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ContainerCorner(
                                        marginRight: 10,
                                        child: Row(
                                          children: [
                                            QuickActions.showSVGAsset(
                                              "assets/svg/ic_diamond.svg",
                                              height: 24,
                                            ),
                                            TextWithTap(
                                              user.getDiamonds.toString(),
                                              fontSize: 14,
                                              marginLeft: 3,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ],
                                        ),
                                      ),
                                      ContainerCorner(
                                        marginLeft: 10,
                                        child: Row(
                                          children: [
                                            QuickActions.showSVGAsset(
                                              "assets/svg/ic_tab_following_default.svg",
                                              color: kRedColor1,
                                              height: 18,
                                            ),
                                            TextWithTap(user.getFollowers!.length.toString(),
                                              fontSize: 12,
                                              marginRight: 15,
                                              marginLeft: 5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.currentUser!.objectId != user.objectId,
                  child: ContainerCorner(
                    borderRadius: 50,
                    height: 40,
                    width: 40,
                    color: widget.currentUser!.getFollowing!.contains(user.objectId) ? kTicketBlueColor :  kRedColor1,
                    child: Icon(
                      widget.currentUser!.getFollowing!.contains(user.objectId) ? Icons.chat_outlined : Icons.add,
                      color: Colors.white,
                    ),
                    onTap: (){
                      if(!widget.currentUser!.getFollowing!.contains(user.objectId)){
                        follow(user);
                      } else {
                        _gotToChat(widget.currentUser!, user);
                      }
                    },
                  ),
                )
              ],
            ),
          );
        } else {
          return Container();
        }
        /*if (snapshot.hasData) {

          UserModel user = snapshot.loadedData as UserModel;

          return ContainerCorner(
            color: kTransparentColor,
            marginLeft: 20,
            marginRight: 10,
            marginTop: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Row(
                          children: [
                            Stack(children: [
                              QuickActions.avatarWidget(user,
                                  width: 60, height: 60),
                              Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: ContainerCorner(
                                    width: 15,
                                    height: 15,
                                    borderRadius: 50,
                                    color: kRedColor1,
                                  )),
                            ]),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWithTap(
                                  user.getFullName!,
                                  marginLeft: 10,
                                  marginBottom: 5,
                                  fontWeight: FontWeight.bold,
                                  color: kGrayColor,
                                  fontSize: 16,
                                ),
                                ContainerCorner(
                                  color: kTransparentColor,
                                  marginLeft: 7,
                                  child: Row(
                                    children: [
                                      QuickActions.showSVGAsset(
                                        "assets/svg/ic_diamond.svg",
                                        width: 25,
                                        height: 25,
                                      ),
                                      TextWithTap(
                                        user.getDiamondsTotal.toString(),
                                        marginLeft: 2,
                                        color: kGrayColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
                    ContainerCorner(
                      borderRadius: 50,
                      height: 40,
                      width: 40,
                      color: widget.currentUser!.getFollowing!.contains(user.objectId) ? kTicketBlueColor :  kRedColor1,
                      child: Icon(
                        widget.currentUser!.getFollowing!.contains(user.objectId) ? Icons.done : Icons.add,
                        color: Colors.white,
                      ),
                      onTap: (){
                        if(!widget.currentUser!.getFollowing!.contains(user.objectId)){
                          //follow(user);
                        }
                      },
                    )
                  ],
                ),
                ContainerCorner(
                  color: kGrayColor.withOpacity(0.2),
                  height: 1,
                  marginLeft: 5,
                  marginRight: 5,
                  marginTop: 20,
                ),
              ],
            ),
          );

        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }*/

        //showChatBtn = !showFollowBtn;
      },
      listLoadingElement: Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }

  void follow(UserModel mUser)  async{
    QuickHelp.showLoadingDialog(context);

    ParseResponse parseResponseUser;

    widget.currentUser!.setFollowing = mUser.objectId!;
    parseResponseUser = await widget.currentUser!.save();

    if(parseResponseUser.success){

      if(parseResponseUser.results != null){
        QuickHelp.hideLoadingDialog(context);
        setState(() {
          widget.currentUser = parseResponseUser.results!.first as UserModel;
        });
      }
    }

    ParseResponse parseResponse;
    parseResponse = await QuickCloudCode.followUser(
        isFollowing: false,
        author: widget.currentUser!,
        receiver: mUser);

    if (parseResponse.success) {
      QuickActions.createOrDeleteNotification(widget.currentUser!,
          mUser, NotificationsModel.notificationTypeFollowers);
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
        QuickCloudCode.sendGift(author: post.getAuthor!, credits: post.getPaidAmount!, preferences: preferences!);

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

  void openSheet(UserModel author, PostsModel? post) async {
    showModalBottomSheet(
        context: (context),
        //isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showPostOptionsAndReportAuthor(author, post: post);
        });
  }

  Widget _showPostOptionsAndReportAuthor(UserModel author, {PostsModel? post}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: post != null ?
      ContainerCorner(
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
                  text: post.getExclusive! ? "feed.move_exclusive_post_pub".tr() : "feed.move_exclusive_post".tr(),
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
              Visibility(visible: widget.currentUser!.isAdmin!, child: Divider()),
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
                    _suspendUser(widget.mUser!);
                  },
                ),
              ),
              Visibility(visible: widget.currentUser!.isAdmin!, child: Divider()),
            ],
          ),
        ),
      ) :
      ContainerCorner(
        radiusTopRight: 20.0,
        radiusTopLeft: 20.0,
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                visible: true,
                child: ButtonWithIcon(
                  text: "feed.reels_user_report"
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
                    openReportUserMessage(author);
                  },
                ),
              ),
              Divider(),
              Visibility(
                visible: true,
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
                  visible: true,
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
                    _suspendUser(widget.mUser!);
                  },
                ),
              ),
              Visibility(visible: widget.currentUser!.isAdmin!, child: Divider()),
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

  _suspendUser(UserModel user) {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showDialogWithButtonCustom(
      context: context,
      title: "feed.suspend_user_alert".tr(),
      message: "feed.suspend_user_message".tr(),
      cancelButtonText: "no".tr(),
      confirmButtonText: "feed.yes_suspend".tr(),
      onPressed: () => _confirmSuspendUser(user),
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
      message: post.getExclusive! ? "feed.move_post_message_pub".tr()  : "feed.move_post_message".tr(),
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
        message: !postsModel.getExclusive! ? "feed.move_post_moved_pub".tr() : "feed.move_post_moved".tr(),
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

  void openReportUserMessage(UserModel author) async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showReportUserMessageBottomSheet(author);
        });
  }

  Widget _showReportUserMessageBottomSheet(UserModel author) {
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
                                    _saveUserReport(
                                        QuickHelp.getReportMessage(code), author);
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

  _saveUserReport(String reason, UserModel author) async {
    QuickHelp.showLoadingDialog(context);

    ParseResponse parseResponse = await QuickActions.report(
      type: ReportModel.reportTypeProfile,
      message: reason,
      accuser: widget.currentUser!,
      accused: author,
    );

    if (parseResponse.success) {
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "feed.post_report_success_title"
            .tr(namedArgs: {"name": author.getFullName!}),
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
}
