import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/home/coins/coins_rc_screen.dart';
import 'package:teego/ui/app_bar.dart';

import '../../models/UserModel.dart';

// ignore: must_be_immutable
class RefillCoinsScreen extends StatefulWidget {
<<<<<<< HEAD
=======

>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
  static String route = "/menu/refill";

  UserModel? currentUser;

  RefillCoinsScreen({this.currentUser});

  @override
  _RefillCoinsScreenState createState() => _RefillCoinsScreenState();
}

class _RefillCoinsScreenState extends State<RefillCoinsScreen> {
<<<<<<< HEAD
=======

>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
  @override
  Widget build(BuildContext context) {
    return ToolBar(
      title: "page_title.refill_coins_title".tr(),
      centerTitle: QuickHelp.isAndroidPlatform() ? true : false,
      leftButtonIcon: Icons.arrow_back_ios,
      onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
<<<<<<< HEAD
      child: CoinsRcScreen(
        currentUser: widget.currentUser,
      ),
=======
      child: CoinsScreen(currentUser: widget.currentUser,),
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
    );
  }
}
