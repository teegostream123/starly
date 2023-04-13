import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:teego/ui/app_bar.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/utils/colors.dart';

class ConnectedAccountsScreen extends StatefulWidget {
   ConnectedAccountsScreen({ Key? key }) : super(key: key);
  static String route = "/menu/settings/ConnectedAccounts";

  @override
  _ConnectedAccountsScreenState createState() => _ConnectedAccountsScreenState();
}

class _ConnectedAccountsScreenState extends State<ConnectedAccountsScreen> {

  bool isFacebookAccountConnected = false;
  bool isGoogleAccountConnected = true;
  bool isInstagramAccountConnected = false;

  String facebookConnectedAccountCode = "123212343546464204623";
  String googleConnectedAccountCode = "123212343546464644677";
  String instagramConnectedAccountCode = "123212343546464638267";

  @override
  Widget build(BuildContext context) {

    return ToolBar(
      title: "connected_accounts.screen_title".tr(),
      leftButtonWidget: BackButton(),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        settingsWidget("facebook_".tr(),isFacebookAccountConnected),
        settingsWidget("google_".tr(),isGoogleAccountConnected),
        settingsWidget("instagram_".tr(),isInstagramAccountConnected),
      ],
    ),);
  }

  Widget settingsWidget(String type, bool isConnected) {
    //String image = _getImage(type);
    _getImage(type);
    String code = isConnected ? _getCode(type):"";

    return ContainerCorner(
      width: double.infinity,
      color: kTransparentColor,
      borderColor: defaultColor.withOpacity(0.3),
      borderWidth: 0.5,
      onTap:(){
        setState(() {
          _onPressEvent(type, isConnected);
        });
      },
      child: Padding(
        padding:  EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration:  BoxDecoration(
                    shape: BoxShape.rectangle,
                  ),
                  child: Icon(Icons.facebook, color: kBlueColor1, size: 30,),
                ),
                 SizedBox(width: 4,),
                Text(
                  type,
                  style: TextStyle(
                    //color: kSecondaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            isConnected
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "connected_accounts.click_to_copy".tr(),
                    style: TextStyle(
                      color: defaultColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700
                    ),
                  ),
                  Text(
                    code,
                    style:  TextStyle(
                      color: defaultColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              )
            :Container(
              padding:  EdgeInsets.symmetric(vertical:1),
              width: MediaQuery.of(context).size.width * 0.26,
              height: 26,
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                "connect_".tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onPressEvent(String type,bool isConnected){
    switch (type) {
      case "Facebook":
          // facebook connect account or copy code goes here
          isFacebookAccountConnected = !isConnected ? !isFacebookAccountConnected:isFacebookAccountConnected;
      break;

      case "Instagram":
        // instagram connect account or copy code goes here
        isInstagramAccountConnected = !isConnected ? !isInstagramAccountConnected:isInstagramAccountConnected;
      break;

      default:
        // google connect account or copy code goes here
        isGoogleAccountConnected = !isConnected ? !isGoogleAccountConnected:isGoogleAccountConnected;
    }
  }

  String _getImage(type){
    switch (type) {
      case "Facebook":
        return "assets/images/facebook.png";
      case "Instagram":
        return "assets/images/instagram.png";
      default:
        return "assets/images/google.png";
    }
  }

  String _getCode(type){
    switch (type) {
      case "Facebook":
        return facebookConnectedAccountCode;
      case "Instagram":
        return instagramConnectedAccountCode;
      default:
        return googleConnectedAccountCode;
    }
  }
}