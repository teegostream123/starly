import 'package:cached_network_image/cached_network_image.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teego/helpers/send_notifications.dart';
import 'package:teego/home/profile/user_profile_screen.dart';
import 'package:teego/models/LiveStreamingModel.dart';
import 'package:teego/models/NotificationsModel.dart';
import 'package:teego/models/PostsModel.dart';
import 'package:teego/models/ReportModel.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/widgets/AvatarInitials.dart';
import 'package:teego/widgets/need_resume.dart';
import 'package:flutter/material.dart';

import '../utils/colors.dart';

class QuickActions {


  static Widget avatarWidgetNotification({double? width, double? height, EdgeInsets? margin, String? imageUrl, UserModel? currentUser, }) {

    if(imageUrl != null) {
      return Container(
        margin: margin,
        width: width,
        height: height,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          //placeholder: (context, url) => _avatarInitials(currentUser),
          //errorWidget: (context, url, error) => _avatarInitials(currentUser),
        ),
      );
    } else if (currentUser != null && currentUser.getAvatar != null) {
      return Container(
        margin: margin,
        width: width,
        height: height,
        child: CachedNetworkImage(
          imageUrl: currentUser.getAvatar!.url!,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          placeholder: (context, url) => _avatarInitials(currentUser),
          errorWidget: (context, url, error) => _avatarInitials(currentUser),
        ),
      );
    }  else {
      return Container();
    }
  }

  static Widget avatarWidget(UserModel currentUser, {double? width, double? height, EdgeInsets? margin, String? imageUrl}) {
    if (currentUser.getAvatar != null) {
      return Container(
        margin: margin,
        width: width,
        height: height,
        child: CachedNetworkImage(
          imageUrl: currentUser.getAvatar!.url!,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          placeholder: (context, url) => _avatarInitials(currentUser),
          errorWidget: (context, url, error) => _avatarInitials(currentUser),
        ),
      );
    } else if(imageUrl != null) {
      return Container(
        margin: margin,
        width: width,
        height: height,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          //placeholder: (context, url) => _avatarInitials(currentUser),
          //errorWidget: (context, url, error) => _avatarInitials(currentUser),
        ),
      );
    } else {
      return _avatarInitials(currentUser);
    }
  }

  static Widget _avatarInitials(UserModel currentUser) {
    return AvatarInitials(
      name: '${currentUser.getFirstName}',
      textSize: 18,
      avatarRadius: 10,
      backgroundColor:
      QuickHelp.isDarkModeNoContext() ? Colors.white : kPrimaryColor,
      textColor: QuickHelp.isDarkModeNoContext()
          ? kContentColorLightTheme
          : kContentColorDarkTheme,
    );
  }

  static Widget photosWidget(String? imageUrl, {double? borderRadius = 8, BoxFit? fit = BoxFit.cover, double? width, double? height, EdgeInsets? margin}) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      child: CachedNetworkImage(
        imageUrl: imageUrl != null ? imageUrl : "",
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            //shape: boxShape!,
            borderRadius: BorderRadius.circular(borderRadius!),
            image: DecorationImage(image: imageProvider, fit: fit),
          ),
        ),
        placeholder: (context, url) => _loadingWidget(width: width, height: height, radius: borderRadius),
        errorWidget: (context, url, error) => _loadingWidget(width: width, height: height, radius: borderRadius),
      ),
    );
  }

  static Widget photosWidgetCircle(String imageUrl, {double? borderRadius = 8, BoxFit? fit = BoxFit.cover, double? width, double? height, EdgeInsets? margin, BoxShape? boxShape = BoxShape.rectangle, Widget? errorWidget}) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            shape: boxShape!,
            //borderRadius: BorderRadius.circular(borderRadius!),
            image: DecorationImage(image: imageProvider, fit: fit),
          ),
        ),
        placeholder: (context, url) => _loadingWidget(width: width, height: height, radius: borderRadius),
        errorWidget: (context, url, error) => _loadingWidget(width: width, height: height, radius: borderRadius),
      ),
    );
  }

  static Widget profileAvatar(String imageUrl, {double? borderRadius = 0, BoxFit? fit = BoxFit.cover, double? width, double? height, EdgeInsets? margin, BoxShape? boxShape = BoxShape.rectangle}) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            shape: boxShape!,
            //borderRadius: BorderRadius.circular(borderRadius!),
            image: DecorationImage(image: imageProvider, fit: fit),
          ),
        ),
        placeholder: (context, url) => _loadingWidget(width: width, height: height, radius: borderRadius),
        errorWidget: (context, url, error) => QuickActions.showSVGAsset("assets/svg/ic_avatar.svg"),
      ),
    );
  }

  static Widget profileCover(String imageUrl, {double? borderRadius = 0, BoxFit? fit = BoxFit.cover, double? width, double? height, EdgeInsets? margin}) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            //shape: boxShape!,
            borderRadius: BorderRadius.circular(borderRadius!),
            image: DecorationImage(image: imageProvider, fit: fit),
          ),
        ),
        placeholder: (context, url) => _loadingWidget(width: width, height: height, radius: borderRadius),
        errorWidget: (context, url, error) => Center(child: QuickActions.showSVGAsset("assets/svg/ic_avatar.svg"),),
      ),
    );
  }

  static Widget gifWidget(String imageUrl, {double? borderRadius = 8, BoxFit? fit = BoxFit.cover}) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          //shape: BoxShape.circle,
          borderRadius: BorderRadius.circular(borderRadius!),
          image: DecorationImage(image: imageProvider, fit: fit),
        ),
      ),
      placeholder: (context, url) => FadeShimmer(
        height: 80,
        width: 80,
        fadeTheme: QuickHelp.isDarkMode(context)
            ? FadeTheme.dark
            : FadeTheme.light,
        millisecondsDelay: 0,
      ),
      errorWidget: (context, url, error) => FadeShimmer(
        height: 80,
        width: 80,
        fadeTheme: QuickHelp.isDarkMode(context)
            ? FadeTheme.dark
            : FadeTheme.light,
        millisecondsDelay: 0,
      ),
    );
  }

  static Widget _loadingWidget({double? width, double? height, double? radius}){

   /* return FadeShimmer(
      width: width != null ? width : 60,
      height: height != null ? height : 60,
      radius: radius != null ? radius : 0,
      fadeTheme: QuickHelp.isDarkModeNoContext() ? FadeTheme.dark : FadeTheme.light,
    );*/
    return Center(child: CircularProgressIndicator.adaptive());
  }

  static showUserProfile(BuildContext context,UserModel currentUser, UserModel user, {ResumableState? resumeState} ){
    QuickHelp.goToNavigatorScreen(context, UserProfileScreen(currentUser: currentUser, mUser: user, isFollowing: currentUser.getFollowing!.contains(user.objectId)));
  }

  static Widget noContentFound(String title, String explain, String image,
      {MainAxisAlignment? mainAxisAlignment = MainAxisAlignment.center,
      CrossAxisAlignment? crossAxisAlignment = CrossAxisAlignment.center,
      double? imageWidth = 91,
      double? imageHeight = 91, Color? color}) {
    return Column(
      mainAxisAlignment: mainAxisAlignment!,
      crossAxisAlignment: crossAxisAlignment!,
      children: [
        ContainerCorner(
          height: imageHeight,
          width: imageWidth,
          marginBottom: 20,
          color: kTransparentColor,
          child: image.endsWith(".svg") ? QuickActions.showSVGAsset(image, color: color,) : Image.asset(image, color: color,),
        ),
        TextWithTap(
          title,
          marginBottom: 0,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.red,
        ),
        TextWithTap(
          explain,
          marginLeft: 10,
          marginRight: 10,
          marginBottom: 17,
          marginTop: 5,
          fontSize: 18,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w600,
          color: kGreyColor1,
        )
      ],
    );
  }

  static Widget noContentFoundReels(String title, String explain,
      {MainAxisAlignment? mainAxisAlignment = MainAxisAlignment.center,
        CrossAxisAlignment? crossAxisAlignment = CrossAxisAlignment.center,
        double? imageWidth = 91,
        double? imageHeight = 91}) {
    return Column(
      mainAxisAlignment: mainAxisAlignment!,
      crossAxisAlignment: crossAxisAlignment!,
      children: [
        ContainerCorner(
          height: imageHeight,
          width: imageWidth,
          marginBottom: 20,
          color: kTransparentColor,
          child: Icon(Icons.refresh_rounded, size: 90, color: Colors.white,),
        ),
        TextWithTap(
          title,
          marginBottom: 0,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        TextWithTap(
          explain,
          marginLeft: 10,
          marginRight: 10,
          marginBottom: 17,
          marginTop: 5,
          fontSize: 14,
          textAlign: TextAlign.center,
          color: Colors.white,
        )
      ],
    );
  }

  static Widget avatarBorder(UserModel user, {Function? onTap, double? width, double? height, EdgeInsets? avatarMargin, EdgeInsets? borderMargin, Color? borderColor = kPrimacyGrayColor, double? borderWidth = 1}){

    return GestureDetector(
      onTap: () => onTap as Function(),
      child: Center(
        child: Container(
          width: width, //160,
          height: height, //160,
          margin: borderMargin, //EdgeInsets.only(top: 10, bottom: 20, left: 30, right: 30),
          decoration: BoxDecoration(
            border: Border.all(
              width: borderWidth!,
              color: borderColor!,
            ),
            shape: BoxShape.circle,
          ),
          child: QuickActions.avatarWidget(user, width: width, height: height, margin: avatarMargin),
        ),
      ),
    );
  }

  static createOrDeleteNotification(UserModel currentUser, UserModel toUser, String type, {PostsModel? post, LiveStreamingModel? live}) async {

    QueryBuilder<NotificationsModel> queryBuilder = QueryBuilder<NotificationsModel>(NotificationsModel());
    queryBuilder.whereEqualTo(NotificationsModel.keyAuthor, currentUser);
    queryBuilder.whereEqualTo(NotificationsModel.keyNotificationType, type);
    if(post != null){
      queryBuilder.whereEqualTo(NotificationsModel.keyPost, post);
    }

    ParseResponse parseResponse = await queryBuilder.query();

    if(parseResponse.success){

      if(parseResponse.results != null){

        NotificationsModel notification = parseResponse.results!.first;
        await notification.delete();

      } else {

        NotificationsModel notificationsModel = NotificationsModel();
        notificationsModel.setAuthor = currentUser;
        notificationsModel.setAuthorId = currentUser.objectId!;

        notificationsModel.setReceiver = toUser;
        notificationsModel.setReceiverId = toUser.objectId!;

        notificationsModel.setNotificationType = type;
        notificationsModel.setRead = false;

        if(post != null){
          notificationsModel.setPost = post;
        }

        if(live != null){
          notificationsModel.setLive = live;
        }

        await notificationsModel.save();

        if(post != null){

          if(post.getAuthorId != currentUser.objectId){
            SendNotifications.sendPush(currentUser, toUser, type, objectId: post.objectId!);
          }

        } else if(live != null){
          SendNotifications.sendPush(currentUser, toUser, type, objectId: live.objectId!);
        } else {
          SendNotifications.sendPush(currentUser, toUser, type);
        }
      }
    }
  }

  static Future<ParseResponse> report({required String type, required String message, String? description, required UserModel accuser, required UserModel accused, LiveStreamingModel? liveStreamingModel, PostsModel? postsModel}) async {

    ReportModel reportModel = ReportModel();

    reportModel.setReportType = type;

    reportModel.setAccuser = accuser;
    reportModel.setAccuserId = accuser.objectId!;

    reportModel.setAccused = accused;
    reportModel.setAccusedId = accused.objectId!;

    if(liveStreamingModel != null) reportModel.setLiveStreaming = liveStreamingModel;
    if(postsModel != null) reportModel.setPost = postsModel;

    reportModel.setMessage = message;
    if(description != null) reportModel.setDescription = description;

    return await reportModel.save();

  }

  static Widget getVideoPlaceHolder(String url, {bool adaptive = false, bool showLoading = false}){
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (ctx, value){
        if(showLoading){
          return adaptive ? CircularProgressIndicator.adaptive() : CircularProgressIndicator();
        } else {
          return Container();
        }
      },
    );
  }
  static Widget getImageFeed(BuildContext context, PostsModel post, {bool? cache = true}){
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: cache!? CachedNetworkImage(
        imageUrl: post.isVideo!
            ? post.getVideoThumbnail!.url!
            : post.getImage!.url!,
        fit: BoxFit.contain,
        placeholder: (ctx, value){
          return FadeShimmer(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            fadeTheme: QuickHelp.isDarkMode(context) ? FadeTheme.dark : FadeTheme.light,
          );
        },

      ) : Image.network(
        post.isVideo!
            ? post.getVideoThumbnail!.url!
            : post.getImage!.url!,
        fit: BoxFit.contain,
        loadingBuilder:
            (context, child, loadingProgress) {

          if(loadingProgress != null){
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              child: Center(
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                ),
              ),
            );

          } else {
            return child;
          }
        },
      )
    );
  }

  static Widget getReelsImage(BuildContext context, PostsModel post, {bool? cache = true}){
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: cache!? CachedNetworkImage(
          imageUrl: post.isVideo!
              ? post.getVideoThumbnail!.url!
              : post.getImage!.url!,
          fit: BoxFit.contain,
          placeholder: (ctx, value){
            return FadeShimmer(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              fadeTheme: QuickHelp.isDarkMode(context) ? FadeTheme.dark : FadeTheme.light,
            );
          },

        ) : Image.network(
          post.isVideo!
              ? post.getVideoThumbnail!.url!
              : post.getImage!.url!,
          fit: BoxFit.contain,
          loadingBuilder:
              (context, child, loadingProgress) {

            if(loadingProgress != null){
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                child: Center(
                  child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ),
                ),
              );

            } else {
              return child;
            }
          },
        )
    );
  }

  static Widget getVideoPlayer(PostsModel post) {
    return Container();
  }
  static Widget showSVGAsset(String asset, {Color? color, double? width, double? height, double? size}){

    return SvgPicture.asset(
      asset,
      width: size != null ? size : width,
      height: size != null ? size : height,
      colorFilter: ColorFilter.mode(
        color != null ? color : Colors.transparent,
        color != null ? BlendMode.srcIn : BlendMode.dst,
      ),
    );
  }
}