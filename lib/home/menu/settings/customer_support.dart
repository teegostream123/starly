import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teego/app/config.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/ui/app_bar.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/utils/colors.dart';

import '../../../models/UserModel.dart';
import '../../message/message_screen.dart';

// ignore: must_be_immutable
class CustomerSupportScreen extends StatefulWidget {
  UserModel? currentUser;

  CustomerSupportScreen({ Key? key, this.currentUser}) : super(key: key);
  static String route = "/menu/settings/CustomerSupport";

  @override
  _CustomerSupportScreenState createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  @override
  Widget build(BuildContext context) {
    return ToolBar(
      rightButtonIcon: Icons.close,
      rightButtonPress: () => QuickHelp.goBackToPreviousPage(context),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 35,top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/logo.png"),
                      )
                    ),
                  ),
                  
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "customer_support.hi_".tr(namedArgs: {"name" : widget.currentUser!.getFirstName!}),
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "customer_support.ask_share_feedback".tr(),
                    style: TextStyle(
                      color: kSecondaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                ]
              ),
            ),
            Center(
              child: ContainerCorner(
                width: MediaQuery.of(context).size.width * 0.90,
                borderColor: defaultColor,
                marginTop: 15,
                borderRadius: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "customer_support.how_to_help".tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 5,),
                      Text(
                        "customer_support.tell_us_what_you_need".tr(),
                        style: TextStyle(
                          fontSize: 12,
                          color: defaultColor
                        ),
                      ),
                      SizedBox(height: 20,),
                      Container(
                  child: ContainerCorner(
                    color: kPrimaryColor.withOpacity(0.8),
                    width: 160,
                    borderRadius: 30,
                    onTap: ()=> checkSupportUser(Config.supportId),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment:CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.question_answer,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 5,),
                          Text(
                            "customer_support.ask_a_question".tr(),
                            style: TextStyle(
                                color: Colors.white
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  checkSupportUser(String objectId) async {
    QuickHelp.showLoadingDialog(context);

    QueryBuilder<UserModel>? queryUser = QueryBuilder<UserModel>(
        UserModel.forQuery());
    queryUser.whereEqualTo(keyVarObjectId, objectId);

    ParseResponse response = await queryUser.query();

    if (response.success) {
      if (response.results != null) {
        QuickHelp.hideLoadingDialog(context);

        UserModel user = response.results!.first as UserModel;

        //QuickActions.showUserProfile(context, widget.currentUser!, user);

         QuickHelp.goToNavigator(context, MessageScreen.route, arguments: {
          "currentUser": widget.currentUser,
          "mUser": user,
        });

      } else {
        QuickHelp.hideLoadingDialog(context);

        QuickHelp.showAppNotificationAdvanced(context: context,
          title: "error".tr(),
          message: "try_again_later".tr(),
        );
      }
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(context: context,
        title: "error".tr(),
        message: "try_again_later".tr(),
      );
    }
  }
}