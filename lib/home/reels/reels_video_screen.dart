import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teego/app/constants.dart';
import 'package:teego/helpers/quick_actions.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/home/profile/profile_screen.dart';
import 'package:teego/home/reels/reels_saved_videos_screen.dart';
import 'package:teego/home/reels/reels_single_screen.dart';
import 'package:teego/models/PostsModel.dart';
import 'package:teego/ui/app_bar.dart';
import 'package:teego/ui/button_with_svg.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/utils/colors.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../app/setup.dart';
import '../../helpers/quick_cloud.dart';
import '../../models/NotificationsModel.dart';
import '../../models/ReportModel.dart';
import '../../models/UserModel.dart';
import '../../models/others/video_editor_model.dart';
import '../../ui/button_with_gradient.dart';
import '../../ui/button_with_icon.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/shared_manager.dart';
import 'video_editor_screen.dart';
import '../message/message_screen.dart';

import 'package:teego/widgets/dospace/dospace.dart' as dospace;

// ignore: must_be_immutable
class ReelsVideosScreen extends StatefulWidget {
  static String route = "/home/reels/videos";

  UserModel? currentUser, mUser;
  SharedPreferences? preferences;

  ReelsVideosScreen({this.currentUser, this.mUser, this.preferences});

  @override
  _ReelsVideosScreenState createState() => _ReelsVideosScreenState();
}

class _ReelsVideosScreenState extends State<ReelsVideosScreen>
    with TickerProviderStateMixin {
  UserModel? user;
  int? videoCount = 0;
  bool following = false;
  AnimationController? _animationController;
  TextEditingController postContent = TextEditingController();

  String? uploadPhoto;
  ParseFileBase? parseFile;
  ParseFileBase? parseFileThumbnail;
  bool? isVideo = false;
  File? videoFile;

  @override
  void initState() {
    if (widget.mUser != null) {
      user = widget.mUser;

      if (widget.currentUser!.getFollowing!.contains(user!.objectId!)) {
        setState(() {
          following = true;
        });
      } else {
        following = false;
      }
    } else {
      user = widget.currentUser;
    }

    countVideos();
    _animationController = AnimationController.unbounded(vsync: this);
    super.initState();
  }

  countVideos() async {
    QueryBuilder<PostsModel> queryBuilder = QueryBuilder(PostsModel());
    queryBuilder.whereEqualTo(PostsModel.keyAuthorId, user!.objectId!);
    queryBuilder.whereValueExists(PostsModel.keyVideo, true);

    ParseResponse response = await queryBuilder.count();
    if (response.success) {
      setState(() {
        videoCount = response.count;
      });
    }
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
                        child: SafeArea(
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
                                  child: uploadPhoto != null
                                      ? Image.file(File(uploadPhoto!))
                                      : Icon(
                                    Icons.video_library_outlined,
                                    color: kPrimaryColor,
                                    size: 80,
                                  ),
                                  onTap: () => _pickFile(setState),
                                ),
                              ),
                              Column(
                                children: [
                                  ButtonWithGradient(
                                    marginTop: 10,
                                    height: 50,
                                    borderRadius: 20,
                                    text: "feed.post_reels_video".tr(),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    textColor: Colors.white,
                                    onTap: () {
                                      if (isVideo!) {

                                        if(Constants.isSelfHosted){

                                          initDoSpaces(
                                            videoFile,
                                            text: postContent.text,
                                          );

                                        } else {

                                          initFileUpload(
                                            videoFile,
                                            text: postContent.text,
                                          );
                                        }

                                      } else {
                                        if (parseFile != null &&
                                            uploadPhoto != null) {
                                          savePost(text: postContent.text);
                                        }
                                      }
                                    },
                                    beginColor: kPrimaryColor,
                                    endColor: kPrimaryColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
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

  _pickFile(StateSetter setState) async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 1,
        //gridCount: 3,
        requestType: RequestType.video,
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
        //cropPhoto(file.path, setState);
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

      parseFileThumbnail = ParseFile(File(videoEditorModel.coverPath!), name: "thumbnail.jpg");
      setState(() {
        uploadPhoto = videoEditorModel.coverPath!;
      });
    }
  }



  initDoSpaces(File? videoFile, {String? text}) async {

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
  }

  initFileUpload(File? videoFile, {String? text}) async {

    QuickHelp.showLoadingDialog(context);

    parseFile = ParseFile(
      videoFile,
      //url: videoFile!.absolute.path,
      name: "video.mp4",
    );

    savePost(text: text);

  }

  savePost({String? text}) async {

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

    postsModel.setExclusive = false;
    postsModel.setPostType = PostsModel.postTypeVideo;

    //QuickHelp.showLoadingDialog(context);

    ParseResponse response = await postsModel.save();
    if (response.success) {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.hideLoadingDialog(context);

      parseFile = null;
      parseFileThumbnail = null;
      uploadPhoto = null;
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

  @override
  Widget build(BuildContext context) {
    return ToolBar(
      title: "page_title.reels_videos_title"
          .tr(namedArgs: {"name": user!.getFullName!}),
      centerTitle: QuickHelp.isAndroidPlatform() ? true : false,
      leftButtonIcon: QuickHelp.isAndroidPlatform() ? Icons.arrow_back_outlined : Icons.arrow_back_ios,
      rightButtonTwoPress:
          widget.mUser != null ? () => openSheet(widget.mUser!) : null,
      rightButtonTwoIcon: widget.mUser != null
          ? Icons.more_vert
          : null,
      onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
      child: reelsScreen(),
      elevation: 1,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: Visibility(
        visible: widget.mUser == null,
        child: FloatingActionButton.extended(
          //materialTapTargetSize: MaterialTapTargetSize.padded,
          isExtended: true,
          backgroundColor: kPrimaryColor,
          onPressed: () => checkPermission(),
          label: TextWithTap(
            "feed.reels_new_video".tr(),
            marginLeft: 5,
            textAlign: TextAlign.center,
            alignment: Alignment.center,
            fontSize: 16,
            color: Colors.white,
          ),
          icon: Icon(
            Icons.video_library_outlined,
            size: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget reelsScreen() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  QuickActions.avatarWidget(user!, width: 60, height: 60),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWithTap(
                        user!.getFullName!,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        marginLeft: 10,
                      ),
                      TextWithTap(
                        "feed.reels_profile_video_followers".tr(
                          namedArgs: {
                            "video_count":
                                QuickHelp.convertNumberToK(videoCount!),
                            "followers_count": QuickHelp.convertNumberToK(
                                user!.getFollowers!.length)
                          },
                        ),
                        fontSize: 15,
                        color: kGrayColor,
                        marginLeft: 10,
                      ),
                    ],
                  ),
                ],
              ),
              widget.mUser != null
                  ? Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            child: ButtonWithSvg(
                              text: following
                                  ? "feed.reels_unfollow_user".tr()
                                  : "feed.reels_follow_user".tr(),
                              color: following ? kPrimaryColor : kPrimacyGrayColor,
                              svgName: 'ic_menu_followers',
                              borderRadius: 5,
                              fontSize: 16,
                              svgHeight: 22,
                              svgWidth: 22,
                              svgColor: following ? Colors.white : Colors.white,
                              textColor:
                                  following ? Colors.white : Colors.white,
                              fontWeight: FontWeight.bold,
                              press: () => followOrUnfollow(),
                            ),
                          ),
                          Flexible(
                            child: ButtonWithSvg(
                              text: "feed.reels_send_message".tr(),
                              marginLeft: 10,
                              borderRadius: 5,
                              fontSize: 16,
                              svgHeight: 26,
                              svgWidth: 26,
                              svgName: 'ic_tab_chat_default',
                              color: kBlueColor1,
                              svgColor: Colors.white,
                              textColor: Colors.white,
                              fontWeight: FontWeight.bold,
                              press: () {
                                QuickHelp.goToNavigator(
                                    context, MessageScreen.route,
                                    arguments: {
                                      "currentUser": widget.currentUser,
                                      "mUser": widget.mUser,
                                    });
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            child: ButtonWithIcon(
                              text: "feed.reels_saved_videos".tr(),
                              backgroundColor: Colors.black12,
                              borderRadius: 5,
                              fontSize: 16,
                              textColor: Colors.black,
                              fontWeight: FontWeight.bold,
                              onTap: ()=> QuickHelp.goToNavigatorScreenForResult(context, ReelsSavedVideosScreen(currentUser: widget.currentUser)),
                            ),
                          ),
                          ButtonWithIcon(
                            text: null,
                            marginLeft: 10,
                            borderRadius: 5,
                            icon: Icons.more_horiz_outlined,
                            backgroundColor: Colors.black12,
                            iconColor: Colors.black,
                            onTap: () => widget.mUser == null
                                ? QuickHelp.goToNavigatorScreen(
                                    context,
                                    ProfileScreen(
                                      currentUser: widget.currentUser,
                                    ),
                                  )
                                : QuickActions.showUserProfile(context,
                                    widget.currentUser!, widget.mUser!),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
        Expanded(
          child: loadVideosList(),
        ),
      ],
    );
  }

  Widget loadVideosList() {
    QueryBuilder<PostsModel> queryBuilder = QueryBuilder(PostsModel());
    queryBuilder.whereEqualTo(PostsModel.keyAuthorId, user!.objectId!);
    queryBuilder.whereValueExists(PostsModel.keyVideo, true);
    queryBuilder.orderByDescending(keyVarCreatedAt);

    return ParseLiveGridWidget<PostsModel>(
      query: queryBuilder,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
      lazyLoading: false,
      childAspectRatio: 1 / 1.8,
      shrinkWrap: true,
      listenOnAllSubItems: true,
      animationController: _animationController,
      childBuilder: (ctx, snapshot) {
        PostsModel post = snapshot.loadedData as PostsModel;

        return GestureDetector(
          onTap: (){
            QuickHelp.goToNavigatorScreen(context, ReelsSingleScreen(currentUser: widget.currentUser, post: post,));
          },
          child: Stack(
            children: [
              Center(child: QuickActions.getImageFeed(context, post)),
              Align(
                alignment: Alignment.bottomCenter,
                child: ContainerCorner(
                  height: 35,
                  colors: [Colors.black, Colors.black.withOpacity(0.1)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  margin: EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      TextWithTap(
                        QuickHelp.convertNumberToK(post.getViews),
                        marginLeft: 2,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      gridLoadingElement: Center(child: QuickHelp.showLoadingAnimation()),
      queryEmptyElement: Center(
        child: QuickActions.noContentFound(
            "feed.reels_empty_videos_title".tr(),
            "feed.reels_empty_videos_message".tr(),
            "assets/images/ic_home_reels.png"),
      ),
    );
  }

  void openSheet(UserModel author) async {
    showModalBottomSheet(
        context: (context),
        //isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showPostOptionsAndReportAuthor(author);
        });
  }

  Widget _showPostOptionsAndReportAuthor(UserModel author) {
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
              Divider(),
              Visibility(
                visible: true,
                child: ButtonWithIcon(
                  text: "feed.reels_goto_profile".tr(),
                  //iconURL: "assets/svg/ic_blocked_menu.svg",
                  icon: Icons.account_circle_outlined,
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
                    QuickHelp.goBackToPreviousPage(context);
                    QuickActions.showUserProfile(
                        context, widget.currentUser!, widget.mUser!);
                  },
                ),
              ),
              Divider(),
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
                    //_suspendUser(post!.getAuthor!);
                  },
                ),
              ),
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

  void followOrUnfollow() async {
    if (widget.currentUser!.getFollowing!.contains(widget.mUser!.objectId)) {
      widget.currentUser!.removeFollowing = widget.mUser!.objectId!;

      setState(() {
        following = false;
      });
    } else {
      widget.currentUser!.setFollowing = widget.mUser!.objectId!;

      setState(() {
        following = true;
      });
    }

    await widget.currentUser!
        .save()
        .then((value) => widget.currentUser = value.result as UserModel);

    ParseResponse parseResponse = await QuickCloudCode.followUser(
        isFollowing: false,
        author: widget.currentUser!,
        receiver: widget.mUser!);

    if (parseResponse.success) {
      QuickActions.createOrDeleteNotification(widget.currentUser!,
          widget.mUser!, NotificationsModel.notificationTypeFollowers);
    }
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
              Permission.videos,
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
}
