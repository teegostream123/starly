
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:teego/app/config.dart';
import 'package:teego/app/setup.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/home/menu/settings/qr_code_scanner.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/app_bar.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/utils/colors.dart';

class MyAppCodeScreen extends StatefulWidget {
   MyAppCodeScreen({ Key? key }) : super(key: key);
  static String route = "/menu/settings/MyAppCodeScreen";

  @override
  _MyAppCodeScreenState createState() => _MyAppCodeScreenState();
}

class _MyAppCodeScreenState extends State<MyAppCodeScreen> {
  UserModel? currentUser;

  bool isReceiveChatRequest = false;

  @override
  Widget build(BuildContext context) {
    currentUser = ModalRoute.of(context)!.settings.arguments as UserModel;

    return ToolBar(
      backgroundColor: QuickHelp.isDarkMode(context) ? kContentColorLightTheme : Colors.white,
      title: "application_code.screen_title".tr(namedArgs: {"app_name": Config.appName}),
      //rightButtonIcon: Icons.share,
      //rightButtonPress: ()=> _showDialog(),
      leftButtonWidget: BackButton(),
      child: SafeArea(
        child: Center(
        child: Padding(
          padding:  EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment:CrossAxisAlignment.center,
            children: [
              Spacer(flex: 2,),
              Text("application_code.scan_to_chat".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
               Spacer(),
              Container(
                width: 210,
                height: 210,
                decoration:  BoxDecoration(
                  color: Colors.white,
                ),
                child:  Column(
                  children: [
                    /*QrImage(
                      data: currentUser!.objectId!,
                      version: QrVersions.auto,
                      size: 200.0,
                      embeddedImage: AssetImage("assets/images/ic_logo.png"),
                      embeddedImageStyle: QrEmbeddedImageStyle(
                        size: Size(80, 80),
                      ),
                    ),*/
                  ],
                ),
              ),
               Spacer(),
               Text(
                currentUser!.getFullName!,
                style: TextStyle(
                  color: QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
               Spacer(flex: 2,),
              ContainerCorner(
                width: 120,
                height: 40,
                borderRadius: 20,
                borderColor: kPrimaryColor,
                borderWidth: 1.5,
                onTap: () async{
                  var status = await Permission.camera.status;
                  if(status.isDenied){
                    requestCameraPermission();
                  }else if(status.isGranted){
                    QuickHelp.goToNavigatorScreen(context, QRViewScanner(currentUser: currentUser,));
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical:8),
                  child: Text(
                    "scanner_".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:kPrimaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
               Spacer(),
            ],
          ),
        ),
    ),
      ),);

  }

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      QuickHelp.showDialogPermission(
          context: context,
          title: "permissions.camera_access_qrcode_title".tr(),
          message: "permissions.camera_access_qrcode"
              .tr(namedArgs: {"app_name": Setup.appName}),
          confirmButtonText: "permissions.okay_".tr().toUpperCase(),
          onPressed: () async {
            QuickHelp.hideLoadingDialog(context);

            await Permission.camera.request();
          });
    } else if (status.isPermanentlyDenied) {
      QuickHelp.showDialogPermission(
          context: context,
          title: "permissions.camera_access_qrcode_title".tr(),
          confirmButtonText: "permissions.okay_settings".tr().toUpperCase(),
          message: "permissions.camera_access_qrcode_denied"
              .tr(namedArgs: {"app_name": Setup.appName}),
          onPressed: () {
            QuickHelp.hideLoadingDialog(context);

            openAppSettings();
          });
    } else if (status.isGranted) {
      print("Permission: $status");
    }
  }
}