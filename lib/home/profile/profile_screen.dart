import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:teego/helpers/quick_actions.dart';
import 'package:teego/helpers/quick_cloud.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/home/feed/comment_post_screen.dart';
import 'package:teego/home/live/live_preview.dart';
import 'package:teego/home/location_screen.dart';
import 'package:teego/home/profile/profile_edit.dart';
import 'package:teego/models/NotificationsModel.dart';
import 'package:teego/models/PostsModel.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/button_with_icon.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';

import '../../app/setup.dart';
import '../../ui/app_bar.dart';
import '../message/message_screen.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  static String route = '/profile';
  UserModel? currentUser;

  ProfileScreen({this.currentUser});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int tabIndex = 0;

  @override
  void initState() {

    QuickHelp.saveCurrentRoute(route: ProfileScreen.route);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToolBar(
      centerTitle: true,
      extendBodyBehindAppBar: true,
      iconColor: Colors.white,
      rightIconColor: Colors.white,
      rightButtonIcon: Icons.edit,
      leftButtonIcon:
          QuickHelp.isIOSPlatform() ? Icons.arrow_back_ios : Icons.arrow_back,
      onLeftButtonTap: () =>
          QuickHelp.goBackToPreviousPage(context, result: widget.currentUser),
      rightButtonPress: () async {
        UserModel? user = await QuickHelp.goToNavigatorScreenForResult(
            context,
            ProfileEdit(
              currentUser: widget.currentUser,
            ));

        if (user != null) {
          widget.currentUser = user;
        }
      },
      backgroundColor: Colors.black.withOpacity(0.5),
      child: SingleChildScrollView(
        child: Container(
          color: QuickHelp.isDarkMode(context)
              ? kTabIconDefaultColor.withOpacity(0.1)
              : kGreyColor0,
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 400,
                color: widget.currentUser!.getAvatar == null
                    ? Colors.black
                    : Colors.transparent,
                child: Stack(
                  children: [
                    QuickActions.profileCover(
                        widget.currentUser!.getAvatar != null
                            ? widget.currentUser!.getAvatar!.url!
                            : "null",
                        borderRadius: 0),
                    Positioned(
                      bottom: 0,
                      child: ContainerCorner(
                        width: MediaQuery.of(context).size.width,
                        height: 100,
                        colors: [Colors.black, Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        margin: EdgeInsets.all(8),
                        child: FloatingActionButton(
                          child: ContainerCorner(
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
                          onPressed: () => checkPermission(),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWithTap(
                            widget.currentUser!.getFullName!,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            marginLeft: 10,
                            color: Colors.white,
                          ),
                          Row(
                            children: [
                              TextWithTap(
                                QuickHelp.getGender(widget.currentUser!),
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
                                widget.currentUser!.getCity!,
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
              ContainerCorner(
                color: QuickHelp.isDarkMode(context)
                    ? kContentColorLightTheme
                    : Colors.white,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 40, right: 40),
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
                                  widget.currentUser!.getFollowers!.length
                                      .toString(),
                                  marginTop: 2,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  marginRight: 20,
                                ),
                              ],
                            ),
                            onTap: () =>
                                widget.currentUser!.getFollowers!.length > 0
                                    ? openSheetFollow(false,
                                        widget.currentUser!.getFollowers!)
                                    : null,
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
                                  widget.currentUser!.getDiamonds.toString(),
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
                                  widget.currentUser!.getFollowing!.length
                                      .toString(),
                                  marginTop: 2,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  marginRight: 20,
                                ),
                              ],
                            ),
                            onTap: () =>
                                widget.currentUser!.getFollowing!.length > 0
                                    ? openSheetFollow(
                                        true, widget.currentUser!.getFollowing!)
                                    : null,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        UserModel? user =
                            await QuickHelp.goToNavigatorScreenForResult(
                                context,
                                ProfileEdit(
                                  currentUser: widget.currentUser,
                                ));

                        if (user != null) {
                          widget.currentUser = user;
                        }
                      },
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
                          widget.currentUser!.getAboutYou!.isNotEmpty
                              ? widget.currentUser!.getAboutYou!
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

  /*Widget initQuery(bool isExclusive) {
    QueryBuilder<PostsModel> queryBuilder =
        QueryBuilder<PostsModel>(PostsModel());
    queryBuilder.includeObject([
      PostsModel.keyAuthor,
      PostsModel.keyLastLikeAuthor,
      PostsModel.keyLastDiamondAuthor
    ]);
    queryBuilder.whereEqualTo(PostsModel.keyAuthor, widget.currentUser);
    queryBuilder.whereEqualTo(PostsModel.keyExclusive, isExclusive);

    queryBuilder.orderByDescending(keyVarCreatedAt);

    return ParseLiveListWidget<PostsModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      primary: false,
      duration: Duration(seconds: 0),
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<ParseObject> snapshot) {
        if (snapshot.hasData) {
          PostsModel post = snapshot.loadedData! as PostsModel;
          var liked = post.getLikes!.length > 0 &&
              post.getLikes!.contains(widget.currentUser!.objectId!);

          return ContainerCorner(
            //height: 450,
            color: QuickHelp.isDarkMode(context)
                ? kContentColorLightTheme
                : kContentColorDarkTheme,
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
                        child: Row(
                          children: [
                            QuickActions.avatarWidget(
                                post.getAuthor!,
                                width: 50,
                                height: 50,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWithTap(
                                  post.getAuthor!.getFullName!,
                                  marginLeft: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                TextWithTap(
                                  QuickHelp.getTimeAgoForFeed(post.createdAt!),
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
                        color: kTransparentColor,
                      ),
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
                Container(
                  height: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(top: 5),
                  child: QuickActions.photosWidget(post.getImage!.url!,
                          borderRadius: 0, fit: BoxFit.contain)
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
                  color: kTabIconDefaultColor.withOpacity(0.4),
                ),
                Row(
                  children: [
                    ButtonWithIcon(
                      marginLeft: 10,
                      text: post.getLikes!.length.toString(),
                      textColor: kTabIconDefaultColor,
                      iconURL: liked ? null : "assets/svg/ic_post_like.svg",
                      urlIconColor:
                          liked ? kTabIconSelectedColor : kTabIconDefaultColor,
                      icon: liked ? Icons.favorite : null,
                      iconColor:
                          liked ? kTabIconSelectedColor : kTabIconDefaultColor,
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
                          context, CommentPostScreen.route, arguments: {
                        "currentUser": widget.currentUser,
                        "post": post
                      }),
                      backgroundColor: QuickHelp.isDarkMode(context)
                          ? kContentColorLightTheme
                          : Colors.white,
                    ),
                  ],
                )
              ],
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }*/

  Future<List<dynamic>?> _loadFeeds(bool? isExclusive) async {
    QueryBuilder<PostsModel> queryBuilder =
    QueryBuilder<PostsModel>(PostsModel());
    queryBuilder.includeObject([
      PostsModel.keyAuthor,
      PostsModel.keyLastLikeAuthor,
      PostsModel.keyLastDiamondAuthor
    ]);
    queryBuilder.whereEqualTo(PostsModel.keyAuthor, widget.currentUser);
    queryBuilder.whereEqualTo(PostsModel.keyExclusive, isExclusive);
    queryBuilder.orderByDescending(PostsModel.keyCreatedAt);

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
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              child: Center(
                child: CircularProgressIndicator.adaptive(
                  backgroundColor: QuickHelp.isDarkMode(context)
                      ? kContentColorLightTheme
                      : Colors.white,
                ),
              ),
            );
          }
          if (snapshot.hasData) {
            if (widget.currentUser != null) {
              widget.currentUser = widget.currentUser;
            }

            List<dynamic> results = snapshot.data! as List<dynamic>;

            return Column(
              children: List.generate(results.length, (index){

                PostsModel post = results[index];

                var liked = post.getLikes!.length > 0 &&
                    post.getLikes!.contains(widget.currentUser!.objectId!);

                return ContainerCorner(
                  color: QuickHelp.isDarkMode(context)
                      ? kContentColorLightTheme
                      : Colors.white,
                  marginTop: 0,
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
                      Stack(
                        children: [
                          post.isVideo!
                              ? QuickActions.getVideoPlayer(post)
                              : QuickActions.getImageFeed(context, post),
                          Visibility(
                            visible: isExclusive,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width,
                              child: Center(
                                child: QuickActions.showSVGAsset(
                                  "assets/svg/ic_tarred.svg",
                                  color: kDisabledGrayColor,
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                            ),
                          ),
                        ],
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
                        visible: true,
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

  checkPermission() async {
    if (await Permission.camera.isGranted &&
        await Permission.microphone.isGranted) {
      _gotoLiveScreen();
    } else if (await Permission.camera.isDenied ||
        await Permission.microphone.isDenied) {
      QuickHelp.showDialogPermission(
          context: context,
          title: "permissions.call_access".tr(),
          confirmButtonText: "permissions.okay_".tr().toUpperCase(),
          message: "permissions.photo_access_explain"
              .tr(namedArgs: {"app_name": Setup.appName}),
          onPressed: () async {
            QuickHelp.hideLoadingDialog(context);

            // You can request multiple permissions at once.
            Map<Permission, PermissionStatus> statuses = await [
              Permission.camera,
              Permission.microphone,
            ].request();

            if (statuses[Permission.camera]!.isGranted &&
                statuses[Permission.microphone]!.isGranted) {
              _gotoLiveScreen();
            } else {
              QuickHelp.showAppNotificationAdvanced(
                  title: "permissions.call_access_denied".tr(),
                  message: "permissions.call_access_denied_explain"
                      .tr(namedArgs: {"app_name": Setup.appName}),
                  context: context,
                  isError: true);
            }
          });
    } else if (await Permission.camera.isPermanentlyDenied ||
        await Permission.microphone.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  _gotoLiveScreen() async {
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
      QuickHelp.goToNavigatorScreen(
          context, LivePreviewScreen(currentUser: widget.currentUser!));
    }
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
                    color: QuickHelp.isDarkMode(context)
                        ? kContentColorLightTheme
                        : Colors.white,
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

  ParseLiveListWidget showFollowersAndFollowingWidget(List<dynamic> usersIds) {
    QueryBuilder<UserModel> queryBuilder =
        QueryBuilder<UserModel>(UserModel.forQuery());
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
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => QuickActions.showUserProfile(
                      context, widget.currentUser!, user),
                  child: QuickActions.avatarWidget(
                    user,
                    width: 50,
                    height: 50,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => QuickActions.showUserProfile(
                        context, widget.currentUser!, user),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                        TextWithTap(
                                          user.getFollowers!.length.toString(),
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
                        )),
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
                    color: widget.currentUser!.getFollowing!
                            .contains(user.objectId)
                        ? kTicketBlueColor
                        : kRedColor1,
                    child: Icon(
                      widget.currentUser!.getFollowing!.contains(user.objectId)
                          ? Icons.chat_outlined
                          : Icons.add,
                      color: Colors.white,
                    ),
                    onTap: () {
                      if (!widget.currentUser!.getFollowing!
                          .contains(user.objectId)) {
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
      },
      listLoadingElement: Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }

  void follow(UserModel mUser) async {
    QuickHelp.showLoadingDialog(context);

    ParseResponse parseResponseUser;

    widget.currentUser!.setFollowing = mUser.objectId!;
    parseResponseUser = await widget.currentUser!.save();

    if (parseResponseUser.success) {
      if (parseResponseUser.results != null) {
        QuickHelp.hideLoadingDialog(context);
        setState(() {
          widget.currentUser = parseResponseUser.results!.first as UserModel;
        });
      }
    }

    ParseResponse parseResponse;
    parseResponse = await QuickCloudCode.followUser(
        isFollowing: false, author: widget.currentUser!, receiver: mUser);

    if (parseResponse.success) {
      QuickActions.createOrDeleteNotification(widget.currentUser!, mUser,
          NotificationsModel.notificationTypeFollowers);
    }
  }

  _gotToChat(UserModel currentUser, UserModel mUser) {
    QuickHelp.goToNavigator(context, MessageScreen.route, arguments: {
      "currentUser": widget.currentUser,
      "mUser": mUser,
    });
  }
}
