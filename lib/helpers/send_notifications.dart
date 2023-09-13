import 'package:easy_localization/easy_localization.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teego/models/UserModel.dart';

class SendNotifications {

  static final String pushNotificationSendParam = "sendPush";

  static final String pushNotificationInstallation = "installation";
  static final String pushNotificationSender = "senderId";
  static final String pushNotificationSenderName = "senderName";
  static final String pushNotificationReceiver = "receiverId";
  static final String pushNotificationTitle = "title";
  static final String pushNotificationAlert = "alert";
  static final String pushNotificationSenderAvatar = "avatar";
  static final String pushNotificationChat = "chat";
  static final String pushNotificationType = "type";
  static final String pushNotificationObjectId = "objectId";
  static final String pushNotificationViewGroup = "view";
  static final String pushNotificationFollowers = "followers";

  static final String typeChat = "chat";
  static final String typeMissedCall = "missedCall";
  static final String typeLive = "live";
  static final String typeLiveInvite = "liveInvite";
  static final String typeLike = "postLiked";
  static final String typeComment = "postComment";
  static final String typeFollow = "followers";
  static final String typeGift = "postGift";
  static final String typeLikedReels = "reelsLiked";
  static final String typeCommentReels = "reelsComment";


  static void sendPush(UserModel fromUser, UserModel toUser, String type,
      {String? message, String? objectId}) async{


    ParseCloudFunction function = ParseCloudFunction(pushNotificationSendParam);

    Map<String, dynamic> params = <String, dynamic> {
      pushNotificationReceiver: toUser.objectId,
      pushNotificationSender: fromUser.objectId,
      pushNotificationSenderName : fromUser.getFullName,
      pushNotificationSenderAvatar: fromUser.getAvatar != null ? fromUser.getAvatar?.url: "",
      pushNotificationTitle: getTitle(type, name: fromUser.getFullName),
      pushNotificationAlert: getMessage(type, name: fromUser.getFullName, chat: message),
      pushNotificationViewGroup: getViewGroup(type),
      pushNotificationChat: message != null ? message : "",
      pushNotificationType: type,
      pushNotificationObjectId: objectId != null ? objectId : "",
      pushNotificationFollowers: fromUser.getFollowers,
    };

    if(type == typeLive && toUser.getLiveNotification!){
      await function.execute(parameters: params);

    } else {
      await function.execute(parameters: params);
    }
  }

  static String getTitle(String type, {String? name}){

    if(type == typeChat){
      return "push_notifications.new_message".tr(namedArgs: {"name": name!});

    } else if(type == typeLive){
      return "push_notifications.started_new_title".tr(namedArgs: {"name": name!});

    } else if(type == typeLike){
      return "push_notifications.new_like".tr();

    } else if(type == typeComment){
      return "push_notifications.new_comment".tr();

    } else if(type == typeFollow){
      return "push_notifications.new_follow_title".tr();

    } else if(type == typeLiveInvite){
      return "push_notifications.invited_you_title".tr();

    } else if(type == typeMissedCall){
      return "push_notifications.missed_call_title".tr();

    } else if(type == typeLikedReels){
      return "push_notifications.new_like_reels".tr();

    } else if(type == typeCommentReels){
      return "push_notifications.new_comment_reels".tr();

    }

    return "";
  }

  static String getMessage(String type, {String? name, String? chat}){

    if(type == typeChat){
      return chat!;

    } else if(type == typeLive){
      return "push_notifications.started_live".tr(namedArgs: {"name": name!});

    } else if(type == typeLike){
      return "push_notifications.liked_your_post".tr(namedArgs: {"name": name!});

    } else if(type == typeComment){
      return "push_notifications.commented_post".tr(namedArgs: {"name": name!});

    } else if(type == typeFollow){
      return "push_notifications.started_follow_you".tr(namedArgs: {"name": name!});

    } else if(type == typeLiveInvite){
      return "push_notifications.invited_you".tr(namedArgs: {"name": name!});

    } else if(type == typeMissedCall){
      return "push_notifications.missed_call".tr(namedArgs: {"name": name!});

    } else if(type == typeLikedReels){
      return "push_notifications.liked_your_reels".tr(namedArgs: {"name": name!});

    } else if(type == typeCommentReels){
      return "push_notifications.commented_reels".tr(namedArgs: {"name": name!});

    }

    return "";
  }

  static String getViewGroup(String type){

    if(type == typeChat){
      return type;

    } else if(type == typeLive){
      return type;

    } else if(type == typeLike){
      return type;

    } else if(type == typeComment){
      return type;

    } else if(type == typeFollow){
      return type;

    } else if(type == typeLiveInvite){
      return type;

    }  else if(type == typeMissedCall){
      return type;

    } else if(type == typeLikedReels){
      return type;

    } else if(type == typeCommentReels){
      return type;

    }

    return "";
  }
}