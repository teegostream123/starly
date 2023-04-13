import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/config.dart';
import '../app/constants.dart';
import '../helpers/quick_help.dart';
import '../models/InvitedUsersModel.dart';
import '../models/UserModel.dart';
import '../utils/shared_manager.dart';

class DynamicLinkService {

  Future<Uri?>? createDynamicLink(String? id) async {
    try {

      final DynamicLinkParameters parameters = DynamicLinkParameters(
        // The Dynamic Link URI domain. You can view created URIs on your Firebase console
        uriPrefix: Config.uriPrefix,
        // The deep Link passed to your application which you can use to affect change
        //link: Uri.parse("${Config.link.replaceAll("/", "")}/?${Config.inviteSuffix}=$id"),
        link: Uri.parse("${Config.link}/${Config.inviteSuffix}=$id"),
        // Android application details needed for opening correct app on device/Play Store
        androidParameters: AndroidParameters(
          packageName: Constants.appPackageName(),
          minimumVersion: 1,
        ),
        // iOS application details needed for opening correct app on device/App Store
        iosParameters: IOSParameters(
          bundleId: Constants.appPackageName(),
          appStoreId: Config.iosAppStoreId,
          minimumVersion: '1',
        ),
      );

      final ShortDynamicLink shortDynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
      final Uri uri = shortDynamicLink.shortUrl;
      return uri;

    } catch (e) {

      return null;
    }
  }

  Future<void> retrieveDynamicLink(BuildContext context) async {

    try {
      final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
      Uri? deepLink = data?.link;

      if (deepLink != null) {
        if (deepLink.queryParameters.containsKey(Config.inviteSuffix)) {
          String? preLink = deepLink.queryParameters[Config.inviteSuffix];
          String id = preLink!.replaceAll("/${Config.inviteSuffix}", "");

          print("DeepLink invited by: $preLink");
          print("DeepLink invited by: $id");
        }

        print("DeepLink found : ${deepLink.toString()}");
      } else {
        print("DeepLink not found");
      }

    } catch (e) {
      print("DeepLink invited by Error: $e");
    }
  }

  listenDynamicLink(BuildContext context) async{
    print("DeepLink listenDynamicLink");

    SharedPreferences preferences = await SharedPreferences.getInstance();

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      print("DeepLink Listen invited by: ${dynamicLinkData.link.path}");

      String id = dynamicLinkData.link.path.replaceAll("/${Config.inviteSuffix}=", "");

      SharedManager().setInvitee(preferences, id);

      print("DeepLink ID invited by: $id");

    }).onError((error) {
      print("DeepLink listen by Error: $error");
      // Handle errors
    });
  }

  registerInviteBy(UserModel currentUser, String inviteeId, BuildContext context ) async {

    QuickHelp.showLoadingDialog(context);

    QueryBuilder<UserModel> queryFrom = QueryBuilder<UserModel>(UserModel.forQuery());

    queryFrom.whereEqualTo(UserModel.keyId, inviteeId);

    ParseResponse apiResponse = await queryFrom.query();

    if (apiResponse.success) {

      if (apiResponse.results != null) {

        InvitedUsersModel invitedUsersModel = InvitedUsersModel();

        invitedUsersModel.setAuthor = currentUser;
        invitedUsersModel.setAuthorId = currentUser.objectId!;

        invitedUsersModel.setInvitedBy = apiResponse.results!.first! as UserModel;
        invitedUsersModel.setInvitedById = inviteeId;

        invitedUsersModel.setValidUntil = DateTime.now().add(Duration(days: 730));
        ParseResponse response = await invitedUsersModel.save();

        if(response.success){

          currentUser.setInvitedByAnswer = true;
          currentUser.setInvitedByUser = inviteeId;

          ParseResponse user = await currentUser.save();
          if(user.success){
           currentUser = user.results!.first! as UserModel;
          }
        }
      }
    }
  }
}