import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
=======
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/home/reels/reels_single_screen.dart';
import 'package:teego/ui/app_bar.dart';

import '../../helpers/quick_actions.dart';
import '../../models/PostsModel.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';

// ignore: must_be_immutable
class ReelsSavedVideosScreen extends StatefulWidget {
<<<<<<< HEAD
=======

>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
  static String route = "/home/reels/videos/saved";

  UserModel? currentUser;

  ReelsSavedVideosScreen({this.currentUser});

  @override
  _ReelsSavedVideosScreenState createState() => _ReelsSavedVideosScreenState();
}

<<<<<<< HEAD
class _ReelsSavedVideosScreenState extends State<ReelsSavedVideosScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

=======
class _ReelsSavedVideosScreenState extends State<ReelsSavedVideosScreen> with SingleTickerProviderStateMixin {

  AnimationController? _animationController;


>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
  @override
  void initState() {
    _animationController = AnimationController.unbounded(vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ToolBar(
<<<<<<< HEAD
      title: "page_title.reels_saved_videos_title".tr(),
=======
        title: "page_title.reels_saved_videos_title".tr(),
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      centerTitle: QuickHelp.isAndroidPlatform() ? true : false,
      leftButtonIcon: Icons.arrow_back_ios,
      onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
      child: loadVideosList(),
    );
  }

  Widget loadVideosList() {
    QueryBuilder<PostsModel> queryBuilder = QueryBuilder(PostsModel());
<<<<<<< HEAD
    queryBuilder.whereContains(
        PostsModel.keySaves, widget.currentUser!.objectId!);
=======
    queryBuilder.whereContains(PostsModel.keySaves, widget.currentUser!.objectId!);
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
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
<<<<<<< HEAD
          onTap: () {
            QuickHelp.goToNavigatorScreen(
                context,
                ReelsSingleScreen(
                  currentUser: widget.currentUser,
                  post: post,
                ));
=======
          onTap: (){
            QuickHelp.goToNavigatorScreen(context, ReelsSingleScreen(currentUser: widget.currentUser, post: post,));
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
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
}
