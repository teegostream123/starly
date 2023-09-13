import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';

// ignore: must_be_immutable
class QRViewScanner extends StatefulWidget {
  UserModel? currentUser;

  static String route = "/menu/settings/scanner";

   QRViewScanner({Key? key, this.currentUser}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewScannerState();
}

class _QRViewScannerState extends State<QRViewScanner> {


  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: QuickHelp.isDarkMode(context) ? kContentColorLightTheme : Colors.white,
        leading: BackButton(
          color: kGrayColor,
        ),
        title: TextWithTap("scanner_qrcode.screen_title".tr(), color: kGrayColor,),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(flex: 4, child: _buildQrView(context)),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {

    return Container();
  }

  @override
  void dispose() {
    super.dispose();
  }
}