import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:teego/helpers/quick_actions.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/home/profile/profile_screen.dart';
import 'package:teego/models/CommentsModel.dart';
import 'package:teego/models/NotificationsModel.dart';
import 'package:teego/models/PostsModel.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/button_with_icon.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';

import '../../helpers/quick_cloud.dart';
import '../../models/ReportModel.dart';

class CommentPostScreen extends StatefulWidget {
  static String route = "/post/comment";

  @override
  _CommentPostScreenState createState() => _CommentPostScreenState();
}

class _CommentPostScreenState extends State<CommentPostScreen> {
  UserModel? currentUser;
  PostsModel? post;

  late FocusNode? commentTextFieldFocusNode;

  TextEditingController commentController = TextEditingController();

  _deleteLike(PostsModel postsModel) async{

    QueryBuilder<NotificationsModel> queryBuilder = QueryBuilder<NotificationsModel>(NotificationsModel());
    queryBuilder.whereEqualTo(NotificationsModel.keyAuthor, currentUser);
    queryBuilder.whereEqualTo(NotificationsModel.keyPost, postsModel);

    ParseResponse parseResponse = await queryBuilder.query();

    if(parseResponse.success && parseResponse.results != null){
      NotificationsModel notification = parseResponse.results!.first;
      await notification.delete();
    }
  }

  _likePost(PostsModel post){

    QuickActions.createOrDeleteNotification(currentUser!, post.getAuthor!, NotificationsModel.notificationTypeLikedPost, post: post);
  }

  _createComment(PostsModel post, String text) async {

    CommentsModel comment = CommentsModel();
    comment.setAuthor = currentUser!;
    comment.setText = text;
    comment.setAuthorId = currentUser!.objectId!;
    comment.setPostId = post.objectId!;
    comment.setPost = post;

    await comment.save();

    post.setComments = comment.objectId!;
    await post.save();

    QuickActions.createOrDeleteNotification(currentUser!, post.getAuthor!, NotificationsModel.notificationTypeCommentPost, post: post);
  }

  @override
  void initState() {
    super.initState();

    commentTextFieldFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {

    final users = ModalRoute.of(context)!.settings.arguments as Map;
    currentUser = users['currentUser'];
    post = users['post'];

    var liked = post!.getLikes!.length > 0 && post!.getLikes!.contains(currentUser!.objectId!);

    return GestureDetector(
      onTap: (){
        FocusScopeNode focusScopeNode = FocusScope.of(context);
        if (!focusScopeNode.hasPrimaryFocus &&
            focusScopeNode.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Scaffold(
        body: NestedScrollView(
          floatHeaderSlivers: true,
          physics: ScrollPhysics(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                elevation: 2,
                automaticallyImplyLeading: false,
                leading: BackButton(
                  color: QuickHelp.isDarkMode(context) ? kContentColorDarkTheme : kContentColorLightTheme,
                ),
                backgroundColor:  QuickHelp.isDarkMode(context) ? kContentColorLightTheme : kContentColorDarkTheme,
                title: TextWithTap("comment_post.post_comments".tr(),
                  fontSize: 20,
                  color:  QuickHelp.isDarkMode(context) ? kContentColorDarkTheme : kContentColorLightTheme,
                ),
                centerTitle: true,
              ),
            ];
          },
          body: Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ContainerCorner(
                          shadowColor: kGrayColor,
                          shadowColorOpacity: 0.3,
                          marginRight: 10,
                          marginLeft: 10,
                          marginTop: 5,
                          color: QuickHelp.isDarkMode(context) ? kContentColorLightTheme : Colors.white,
                          marginBottom: 5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: ContainerCorner(
                                      marginTop: 7,
                                        child: Row(
                                          children: [
                                            QuickActions.avatarWidget(post!.getAuthor!,
                                                width: 50, height: 50),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                TextWithTap(
                                                  post!.getAuthor!.getFullName!,
                                                  marginLeft: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                TextWithTap(
                                                  QuickHelp.getTimeAgoForFeed(post!.createdAt!),
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
                                        onTap: (){
                                          if(post!.getAuthorId == currentUser!.objectId!){
                                            QuickHelp.goToNavigatorScreen(context, ProfileScreen(currentUser: currentUser,));
                                          } else {
                                            QuickActions.showUserProfile(context, currentUser!, post!.getAuthor!);
                                          }
                                        }
                                    ),
                                  ),
                                  ButtonWithIcon(
                                    text: "",
                                    iconURL: "assets/svg/ic_post_config.svg",
                                    iconColor: kGrayColor,
                                    backgroundColor: QuickHelp.isDarkMode(context)
                                        ? kContentColorLightTheme
                                        : Colors.white,
                                    onTap: () => openSheet(post!.getAuthor!, post!),
                                    borderRadius: 50,
                                    width: 50,
                                    height: 50,
                                    urlIconColor: kGrayColor,
                                  ),
                                ],
                              ),
                              Visibility(
                                visible: post!.getText!.isNotEmpty,
                                child: TextWithTap(
                                  post!.getText!,
                                  textAlign: TextAlign.start,
                                  marginTop: 10,
                                  marginBottom: 5,
                                  marginLeft: 10,
                                ),
                              ),
                              Container(
                                height: 300,
                                margin: EdgeInsets.only(top: 5),
                                child: QuickActions.photosWidget(
                                    post!.getImage!.url!,
                                    borderRadius: 0,
                                    fit: BoxFit.contain
                                ),
                              ),
                              Visibility(
                                visible: post!.getLikes!.length > 0 ||
                                    post!.getLastDiamondAuthor != null,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ContainerCorner(
                                      marginLeft: 10,
                                      marginTop: 15,
                                      color: kTransparentColor,
                                      child: Row(
                                        children: [
                                          post!.getLastLikeAuthor != null
                                              ? QuickActions.avatarWidget(
                                              post!.getLastLikeAuthor!,
                                              width: 24,
                                              height: 24)
                                              : Container(),
                                          TextWithTap(
                                            post!.getLikes!.length.toString() +
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
                                          post!.getLastDiamondAuthor != null
                                              ? QuickActions.avatarWidget(
                                              post!.getLastDiamondAuthor!,
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
                                    text: post!.getLikes!.length.toString(),
                                    textColor: kTabIconDefaultColor,
                                    iconURL:
                                    liked ? null : "assets/svg/ic_post_like.svg",
                                    urlIconColor:
                                    liked ? kTabIconSelectedColor : kTabIconDefaultColor,
                                    icon: liked ? Icons.favorite : null,
                                    iconColor:
                                    liked ? kTabIconSelectedColor : kTabIconDefaultColor,
                                    backgroundColor: QuickHelp.isDarkMode(context) ? kContentColorLightTheme : Colors.white,
                                    onTap: () {
                                      if (liked) {
                                        post!.removeLike = currentUser!.objectId!;
                                        //post.unset(PostsModel.keyLastLikeAuthor);

                                        _deleteLike(post!);
                                        post!.save();

                                      } else {

                                        post!.setLikes = currentUser!.objectId!;
                                        post!.setLastLikeAuthor = currentUser!;

                                        post!.save();
                                        _likePost(post!);
                                      }

                                    },
                                  ),
                                  ButtonWithIcon(
                                    text: post!.getComments!.length.toString(),
                                    textColor: kTabIconDefaultColor,
                                    urlIconColor: kTabIconDefaultColor,
                                    iconURL: "assets/svg/ic_post_comment.svg",
                                    onTap: () => commentTextFieldFocusNode!.requestFocus(),
                                    backgroundColor: QuickHelp.isDarkMode(context) ? kContentColorLightTheme : Colors.white,
                                  ),
                                  /*ButtonWithIcon(
                                    text: "",
                                    textColor: kTabIconDefaultColor,
                                    urlIconColor: null,
                                    iconURL: "assets/svg/ic_tips_gift.svg",
                                    ontap: () {},
                                    backgroundColor: QuickHelp.isDarkMode(context) ? kContentColorLightTheme : Colors.white,
                                  ),*/
                                ],
                              )
                            ],
                          ),
                        ),
                        initQuery(),
                      ],
                    ),
                  )
              ),
              commentInputField(),
            ],
          ),
          ),
      ),
    );
  }
  Widget initQuery() {

    QueryBuilder<CommentsModel> queryBuilder = QueryBuilder<CommentsModel>(CommentsModel());
    queryBuilder.whereEqualTo(CommentsModel.keyPost, post);

    queryBuilder.includeObject([
      CommentsModel.keyAuthor,
      CommentsModel.keyPost,
    ]);

    return ParseLiveListWidget<CommentsModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      duration: Duration(seconds: 0),
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<ParseObject> snapshot) {

        if (snapshot.hasData) {

          CommentsModel commentsModel = snapshot.loadedData as CommentsModel;

          return Padding(
            padding: const EdgeInsets.only(left: 15,top: 10),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    QuickActions.avatarWidget(commentsModel.getAuthor!,
                        width: 60, height: 60
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWithTap(commentsModel.getAuthor!.getFullName!,
                            marginLeft: 10,
                            marginBottom: 5,
                            fontWeight: FontWeight.bold,
                            color: kGrayColor,
                            fontSize: 16,
                          ),
                          TextWithTap(commentsModel.getText!,
                            marginLeft: 10,
                            marginRight: 10,
                            color: kGrayColor,
                          ),
                          TextWithTap(QuickHelp.getTimeAgoForFeed(commentsModel.createdAt!),
                            marginLeft: 10,
                            color: kGrayColor,
                            marginTop: 10,
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ),
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
        }
      },
      queryEmptyElement: Center(
        child: QuickActions.noContentFound("feed.no_feed_title".tr(),
            "feed.no_feed_explain".tr(), "assets/svg/ic_tab_feed_default.svg"),
      ),
      listLoadingElement: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget commentInputField() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 20 / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 32,
            color: Color(0xFF087949).withOpacity(0.08),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20 * 0.75,
              ),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      onChanged: (text) {},
                      focusNode: commentTextFieldFocusNode,
                      maxLines: null,
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: "comment_post.leave_comment".tr(),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ContainerCorner(
            marginLeft: 10,
            color: kBlueColor1,
            child: ContainerCorner(
              color: kTransparentColor,
              marginAll: 5,
              height: 30,
              width: 30,
              child: QuickActions.showSVGAsset(
                "assets/svg/ic_send_message.svg",
                color: Colors.white,
                height: 10,
                width: 30,
              ),
            ),
            borderRadius: 50,
            height: 45,
            width: 45,
            onTap: () {
              if (commentController.text.isNotEmpty) {
                _createComment(post!, commentController.text);
                setState(() {
                  commentController.text = "";
                });
              }
            },
          ),
        ],
      ),
    );
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
                visible: currentUser!.objectId != post.getAuthorId,
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
                  visible: currentUser!.objectId != post.getAuthorId,
                  child: Divider()),
              Visibility(
                visible: currentUser!.objectId != post.getAuthorId,
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
                  visible: currentUser!.objectId != post.getAuthorId,
                  child: Divider()),
              Visibility(
                visible: currentUser!.objectId == post.getAuthorId ||
                    currentUser!.isAdmin!,
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
              Visibility(visible: currentUser!.isAdmin!, child: Divider()),
              Visibility(
                visible: currentUser!.objectId == post.getAuthorId ||
                    currentUser!.isAdmin!,
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
                  visible: currentUser!.objectId == post.getAuthorId ||
                      currentUser!.isAdmin!,
                  child: Divider()),
              Visibility(
                visible: currentUser!.isAdmin!,
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
              Visibility(visible: currentUser!.isAdmin!, child: Divider()),
            ],
          ),
        ),
      ),
    );
  }

  _blockUser(UserModel author) async {
    Navigator.of(context).pop();
    QuickHelp.showLoadingDialog(context);

    currentUser!.setBlockedUser = author;
    currentUser!.setBlockedUserIds = author.objectId!;

    ParseResponse response = await currentUser!.save();
    if (response.success) {
      currentUser = response.results!.first as UserModel;

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

    currentUser?.setReportedPostIDs = post.objectId;
    currentUser?.setReportedPostReason = reason;

    ParseResponse response = await currentUser!.save();
    if (response.success) {
      QuickHelp.hideLoadingDialog(context);
      setState(() {});
    } else {
      QuickHelp.hideLoadingDialog(context);
    }

    ParseResponse parseResponse = await QuickActions.report(
        type: ReportModel.reportTypePost,
        message: reason,
        accuser: currentUser!,
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
}


