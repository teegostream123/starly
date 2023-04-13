import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teego/home/feed/comment_post_screen.dart';
import 'package:teego/models/LiveStreamingModel.dart';
import 'package:teego/models/NotificationsModel.dart';
import 'package:teego/models/PostsModel.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/app_bar.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';
import 'package:teego/helpers/quick_actions.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../live/live_streaming_screen.dart';
import '../reels/reels_single_screen.dart';

// ignore_for_file: must_be_immutable
class NotificationsScreen extends StatefulWidget {
  static const String route = '/home/notifications';

  UserModel? currentUser;
  SharedPreferences? preferences;

  NotificationsScreen({this.currentUser, required this.preferences});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    QuickHelp.setWebPageTitle(context, "page_title.notifications_title".tr());

    QueryBuilder<NotificationsModel> queryBuilder =
        QueryBuilder<NotificationsModel>(NotificationsModel());
    queryBuilder.whereEqualTo(NotificationsModel.keyReceiver, widget.currentUser!);
    queryBuilder.orderByDescending(NotificationsModel.keyCreatedAt);

    queryBuilder.includeObject([
      NotificationsModel.keyAuthor,
      NotificationsModel.keyReceiver,
      NotificationsModel.keyPost,
      NotificationsModel.keyLive,
      NotificationsModel.keyLiveAuthor,
      NotificationsModel.keyPostAuthor,
    ]);

    queryBuilder.whereNotEqualTo(NotificationsModel.keyAuthor, widget.currentUser!);

    return ToolBar(
        title: "page_title.notifications_title".tr(),
        centerTitle: QuickHelp.isAndroidPlatform() ? true : false,
        leftButtonIcon: Icons.arrow_back_ios,
        onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
        elevation: QuickHelp.isAndroidPlatform() ? 2 : 1,
        child: SafeArea(
          child: ContainerCorner(
            marginAll: 10,
            color: kTransparentColor,
            borderColor: kTransparentColor,
            child: ParseLiveListWidget<NotificationsModel>(
              query: queryBuilder,
              reverse: false,
              lazyLoading: false,
              duration: Duration(seconds: 0),
              childBuilder: (BuildContext context,
                  ParseLiveListElementSnapshot<ParseObject> snapshot) {
                if (snapshot.failed) {
                  return Text('not_connected'.tr());
                } else if (snapshot.hasData) {
                  NotificationsModel notifications = snapshot.loadedData! as NotificationsModel;

                  return Column(
                    children: [
                      Row(
                        children: [
                          ContainerCorner(
                            color: kTransparentColor,
                            height: 40,
                            width: 40,
                            child: QuickActions.avatarWidget(
                              notifications.getAuthor!,
                            ),
                            onTap: () => _goToProfile(
                              notifications.getAuthor!,
                            ),
                          ),
                          buidNotify(
                            notifications.getAuthor!,
                            notifications.getNotificationType!,
                            post: notifications.getPost,
                            notification: notifications,
                            live: notifications.getLive,
                          ),
                        ],
                      ),
                      Divider()
                    ],
                  );
                } else {
                  return Container();
                }
              },
              listLoadingElement: Center(
                child: CircularProgressIndicator(),
              ),
              queryEmptyElement: Center(
                  child: QuickActions.noContentFound(
                      "notifications_screen.no_notif_title".tr(),
                      "notifications_screen.no_notif_explain".tr(),
                      "assets/svg/ic_notification_bell.svg")),
            ),
            //onTap: () => _goToProfile(user!),
          ),
        ));
  }

  _goToProfile(UserModel user) {
    QuickActions.showUserProfile(context, widget.currentUser!, user);
  }

  Widget buidNotify(UserModel user, String type,
      {PostsModel? post, LiveStreamingModel? live, NotificationsModel? notification}) {
    String description = "";

    if (type == NotificationsModel.notificationTypeFollowers) {
      description = "notifications_screen.started_follow_you".tr();
    } else if (type == NotificationsModel.notificationTypeLikedPost) {
      description = "notifications_screen.liked_your_post".tr();
    } else if (type == NotificationsModel.notificationTypeCommentPost) {
      description = "notifications_screen.commented_post".tr();
    } else if (type == NotificationsModel.notificationTypeLiveInvite) {
      description = "notifications_screen.commented_post".tr();
    } else if (type == NotificationsModel.notificationTypeLikedReels) {
      description = "notifications_screen.liked_reels".tr();
    } else if (type == NotificationsModel.notificationTypeCommentReels) {
      description = "notifications_screen.commented_reels".tr();
    }

    return TextWithTap(
      '${user.getFullName! + " " + description}',
      marginLeft: 10,
      fontWeight: notification!.isRead! ? FontWeight.normal : FontWeight.bold,
      onTap: () {

        _saveRead(notification);

        if (type == NotificationsModel.notificationTypeFollowers) {
          QuickActions.showUserProfile(context, widget.currentUser!, user);

        } else if (type == NotificationsModel.notificationTypeCommentPost) {

          if(post == null){
            return;
          }

          if(post.isVideo!){
            QuickHelp.goToNavigatorScreen(context, ReelsSingleScreen(currentUser: widget.currentUser, post: post,));
          } else {
            QuickHelp.goToNavigator(context, CommentPostScreen.route,
                arguments: {"currentUser": widget.currentUser, "post": post});
          }

        } else if (type == NotificationsModel.notificationTypeLikedReels ||
            type == NotificationsModel.notificationTypeCommentReels) {

          if (post == null) {
            return;
          }

          QuickHelp.goToNavigatorScreen(context, ReelsSingleScreen(currentUser: widget.currentUser, post: post,));

        } else if (type == NotificationsModel.notificationTypeLikedPost) {

          if(post == null){
            return;
          }

          if(post.isVideo!){
            QuickHelp.goToNavigatorScreen(context, ReelsSingleScreen(currentUser: widget.currentUser, post: post,));
          } else {
            QuickHelp.goToNavigator(context, CommentPostScreen.route,
                arguments: {"currentUser": widget.currentUser, "post": post});
          }

        } else if (type == NotificationsModel.notificationTypeLiveInvite) {
          QuickHelp.goToNavigatorScreen(context,
              LiveStreamingScreen(
                channelName: live!.getStreamingChannel!,
                isBroadcaster: false,
                currentUser: widget.currentUser!,
                mUser: live.getAuthor!,
                preferences: widget.preferences,
                mLiveStreamingModel: live,
              ),
          );
        }
      },
    );
  }

  _saveRead(NotificationsModel notifications) async {
    notifications.setRead = true;
    await notifications.save();

  }
}
