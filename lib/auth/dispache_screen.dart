import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teego/auth/welcome_screen.dart';
import 'package:teego/home/home_screen.dart';
import 'package:teego/home/location_screen.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../home/profile/profile_edit_complete.dart';
import '../services/push_service.dart';

// ignore_for_file: must_be_immutable
class DispacheScreen extends StatefulWidget {

  static String route = "/check";

  UserModel? currentUser;
  SharedPreferences? preferences;

  DispacheScreen({Key? key, this.currentUser, required this.preferences}) : super(key: key);

  @override
  _DispacheScreenState createState() => _DispacheScreenState();
}

class _DispacheScreenState extends State<DispacheScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if(widget.currentUser != null){

      loginUserPurchase(widget.currentUser!.objectId!);

      if(widget.currentUser!.getFirstName == null
          || widget.currentUser!.getGender == null
          || widget.currentUser!.getBirthday == null){

        return ProfileCompleteEdit(currentUser: widget.currentUser, preferences: widget.preferences,);

      } else {

        PushService(
          currentUser: widget.currentUser,
          context: context,
          preferences: widget.preferences,
        ).initialise();

        return HomeScreen(currentUser: widget.currentUser, preferences: widget.preferences,);
      }

    } else {

      logoutUserPurchase();

      return WelcomeScreen();
    }
  }

  loginUserPurchase(String userId) async {
    LogInResult result = await Purchases.logIn(userId);
    if(result.created){
      print("purchase created");
    } else {
      print("purchase logged");
    }
  }

  Widget checkLocation(){

    Location location =  Location();

    return Scaffold(
      body: FutureBuilder<PermissionStatus>(
          future: location.hasPermission(),
          builder: (context, snapshot) {
            if(snapshot.hasData){

              PermissionStatus permissionStatus = snapshot.data as PermissionStatus;
              if (permissionStatus == PermissionStatus.granted || permissionStatus == PermissionStatus.grantedLimited) {
                return HomeScreen(currentUser: widget.currentUser, preferences: widget.preferences,);
              } else {
                return LocationScreen(currentUser: widget.currentUser,);
              }

            } else if(snapshot.hasError){
              return HomeScreen(currentUser: widget.currentUser, preferences: widget.preferences,);
              //return AddCityScreen(currentUser: widget.currentUser,);
            } else {
              return QuickHelp.appLoadingLogo();
            }
          }),
    );
  }

  logoutUserPurchase() async {
    await Purchases.logOut().then((value) => print("purchase logout"));
  }
}
