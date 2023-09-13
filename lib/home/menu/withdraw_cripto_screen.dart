// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
<<<<<<< HEAD
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
=======
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/utils/colors.dart';

import '../../models/WithdrawModel.dart';
import '../../ui/text_with_tap.dart';

class WithdrawCryptoScreen extends StatefulWidget {
  static String route = "/withdraw/crypto";
  UserModel? currentUser;
  SharedPreferences preferences;
<<<<<<< HEAD
  WithdrawCryptoScreen({Key? key, this.currentUser, required this.preferences})
      : super(key: key);
=======
  WithdrawCryptoScreen({ Key? key, this.currentUser, required this.preferences}) : super(key: key);
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081

  @override
  State<WithdrawCryptoScreen> createState() => _WithdrawCryptoScreenState();
}

class _WithdrawCryptoScreenState extends State<WithdrawCryptoScreen> {
  TextEditingController addressTextController = TextEditingController();
  TextEditingController amountTextController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String networkText = "withdraw_to_crypto.select_network".tr();
  String networkSelected = "";
  double totalMoney = 0.0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
<<<<<<< HEAD
    totalMoney = QuickHelp.convertDiamondsToMoney(
        widget.currentUser!.getDiamonds!, widget.preferences);
=======
    totalMoney = QuickHelp.convertDiamondsToMoney(widget.currentUser!.getDiamonds!, widget.preferences);
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
    return GestureDetector(
      onTap: () => QuickHelp.removeFocusOnTextField(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kTransparentColor,
          automaticallyImplyLeading: false,
<<<<<<< HEAD
          leading: BackButton(
            color: kGrayColor,
          ),
=======
          leading: BackButton(color: kGrayColor,),
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWithTap(
<<<<<<< HEAD
                    "withdraw_to_crypto.send_usdt".tr(),
=======
                      "withdraw_to_crypto.send_usdt".tr(),
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
                    fontSize: size.width / 15,
                    fontWeight: FontWeight.w900,
                  ),
                  TextWithTap(
<<<<<<< HEAD
                    "withdraw_to_crypto.send_usdt_address".tr(),
=======
                      "withdraw_to_crypto.send_usdt_address".tr(),
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
                    marginTop: 3,
                  ),
                  addressTextField(),
                  network(),
                  amountTextField()
<<<<<<< HEAD
                ],
=======
              ],
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
          child: ContainerCorner(
            color: kGreenColor,
            borderRadius: 50,
            height: 50,
<<<<<<< HEAD
            child: Center(
              child: TextWithTap(
                "withdraw_to_crypto.send_usdt".tr(),
                color: Colors.white,
              ),
            ),
            onTap: () {
              if (formKey.currentState!.validate()) {
                if (networkSelected.isEmpty) {
                  openNetworkChooser();
                } else if (double.parse(amountTextController.text) >
                    double.parse(totalMoney.toStringAsFixed(0))) {
=======
            child: Center(child: TextWithTap("withdraw_to_crypto.send_usdt".tr(), color: Colors.white,),),
            onTap: () {
              if (formKey.currentState!.validate()) {
                if(networkSelected.isEmpty){
                  openNetworkChooser();
                }else if(double.parse(amountTextController.text) > double.parse(totalMoney.toStringAsFixed(0))){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                "assets/svg/sad.svg",
                                height: 70,
                                width: 70,
                              ),
                              TextWithTap(
<<<<<<< HEAD
                                "get_money.not_enough".tr(namedArgs: {
                                  "money": totalMoney.toStringAsFixed(0)
                                }),
=======
                                "get_money.not_enough".tr(namedArgs: {"money": totalMoney.toStringAsFixed(0)}),
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
                                textAlign: TextAlign.center,
                                color: Colors.red,
                                marginTop: 20,
                              ),
                              SizedBox(
                                height: 35,
                              ),
                              Row(
<<<<<<< HEAD
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ContainerCorner(
                                    child: TextButton(
                                      child: TextWithTap(
                                        "cancel".tr().toUpperCase(),
=======
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ContainerCorner(
                                    child: TextButton(
                                      child: TextWithTap("cancel".tr().toUpperCase(),
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
<<<<<<< HEAD
                                      onPressed: () {
=======
                                      onPressed: (){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    color: kRedColor1,
                                    borderRadius: 10,
                                    marginLeft: 5,
                                    width: 125,
                                  ),
                                  ContainerCorner(
                                    child: TextButton(
<<<<<<< HEAD
                                      child: TextWithTap(
                                        "get_money.try_again"
                                            .tr()
                                            .toUpperCase(),
=======
                                      child: TextWithTap("get_money.try_again".tr().toUpperCase(),
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
<<<<<<< HEAD
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
=======
                                      onPressed: ()=> Navigator.of(context).pop(),
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
                                    ),
                                    color: kGreenColor,
                                    borderRadius: 10,
                                    marginRight: 5,
                                    width: 125,
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        );
                      });
<<<<<<< HEAD
                } else {
=======
                }else{
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
                  saveWithdraw();
                }
              }
            },
          ),
        ),
      ),
    );
  }

  void openNetworkChooser() {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showListOfNetWorks();
        });
  }

  Widget _showListOfNetWorks() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: const Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.1,
            maxChildSize: 1.0,
            builder: (_, controller) {
              return StatefulBuilder(builder: (context, setState) {
                Size size = MediaQuery.of(context).size;
                return Container(
                  decoration: const BoxDecoration(
                    color: kTransparentColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                  ),
                  child: Scaffold(
                    backgroundColor: kTransparentColor,
                    body: ContainerCorner(
                      borderRadius: 10,
<<<<<<< HEAD
                      color: QuickHelp.isDarkMode(context)
                          ? kContentColorDarkTheme
                          : Colors.white,
=======
                      color: QuickHelp.isDarkMode(context) ? kContentColorDarkTheme : Colors.white,
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          children: [
                            TextWithTap(
<<<<<<< HEAD
                              "withdraw_to_crypto.network_advise".tr(),
=======
                                "withdraw_to_crypto.network_advise".tr(),
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
                              alignment: Alignment.center,
                              textAlign: TextAlign.center,
                              marginRight: 10,
                              marginLeft: 10,
                              marginTop: 20,
                              marginBottom: 20,
                            ),
                            ContainerCorner(
                              height: 50,
                              color: kGrayColor.withOpacity(0.1),
                              marginBottom: 10,
                              borderRadius: 4,
<<<<<<< HEAD
                              onTap: () =>
                                  selectNetWork(WithdrawModel.ethereum),
                              child: Padding(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
=======
                              onTap: ()=> selectNetWork(WithdrawModel.ethereum),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 10,
                                    right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
                                  children: [
                                    TextWithTap(
                                      "withdraw_to_crypto.ethereum_".tr(),
                                      color: kGrayColor,
                                      fontSize: size.width / 23,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ContainerCorner(
                              height: 50,
                              color: kGrayColor.withOpacity(0.1),
                              marginBottom: 10,
                              borderRadius: 4,
<<<<<<< HEAD
                              onTap: () => selectNetWork(WithdrawModel.polygon),
                              child: Padding(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
=======
                              onTap: ()=> selectNetWork(WithdrawModel.polygon),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 10,
                                    right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
                                  children: [
                                    TextWithTap(
                                      "withdraw_to_crypto.polygon_".tr(),
                                      color: kGrayColor,
                                      fontSize: size.width / 23,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ContainerCorner(
                              height: 50,
                              marginBottom: 10,
                              color: kGrayColor.withOpacity(0.1),
                              borderRadius: 4,
<<<<<<< HEAD
                              onTap: () => selectNetWork(WithdrawModel.solana),
                              child: Padding(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
=======
                              onTap: ()=> selectNetWork(WithdrawModel.solana),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 10,
                                    right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
                                  children: [
                                    TextWithTap(
                                      "withdraw_to_crypto.solana_".tr(),
                                      color: kGrayColor,
                                      fontSize: size.width / 23,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ContainerCorner(
                              height: 50,
                              marginBottom: 10,
                              color: kGrayColor.withOpacity(0.1),
                              borderRadius: 4,
                              onTap: () => selectNetWork(WithdrawModel.tron),
                              child: Padding(
<<<<<<< HEAD
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
=======
                                padding: EdgeInsets.only(
                                    left: 10,
                                    right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
                                  children: [
                                    TextWithTap(
                                      "withdraw_to_crypto.tron_".tr(),
                                      color: kGrayColor,
                                      fontSize: size.width / 23,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }

  selectNetWork(String network) {
    setState(() {
      networkSelected = network;
    });
    QuickHelp.goBackToPreviousPage(context);
  }

<<<<<<< HEAD
=======


>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
  Widget addressTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWithTap(
          "withdraw_to_crypto.address_".tr(),
          marginTop: 20,
          marginBottom: 5,
        ),
        ContainerCorner(
          height: 50,
          color: kGrayColor.withOpacity(0.3),
          borderRadius: 4,
          child: Padding(
<<<<<<< HEAD
            padding: EdgeInsets.only(left: 10, right: 10),
=======
            padding: EdgeInsets.only(
                left: 10,
                right: 10),
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
            child: TextFormField(
              controller: addressTextController,
              keyboardType: TextInputType.text,
              cursorColor: kGrayColor,
              autocorrect: false,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "withdraw_to_crypto.address_hint".tr(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "withdraw_to_crypto.address_required".tr();
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget amountTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWithTap(
          "withdraw_to_crypto.amount".tr(),
          marginTop: 20,
          marginBottom: 5,
        ),
        ContainerCorner(
          height: 50,
          color: kGrayColor.withOpacity(0.3),
          borderRadius: 4,
          child: Padding(
<<<<<<< HEAD
            padding: EdgeInsets.only(left: 10, right: 10),
=======
            padding: EdgeInsets.only(
                left: 10,
                right: 10),
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
            child: TextFormField(
              controller: amountTextController,
              keyboardType: TextInputType.number,
              cursorColor: kGrayColor,
              autocorrect: false,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "withdraw_to_crypto.amount_hint".tr(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "withdraw_to_crypto.amount_required".tr();
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget network() {
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWithTap(
          "withdraw_to_crypto.network_".tr(),
          marginTop: 20,
          marginBottom: 5,
        ),
        ContainerCorner(
          height: 50,
          color: kGrayColor.withOpacity(0.3),
          borderRadius: 4,
          onTap: () => openNetworkChooser(),
          child: Padding(
<<<<<<< HEAD
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWithTap(
                  networkSelected.isEmpty ? networkText : networkSelected,
                  color: kGrayColor,
                  fontSize: size.width / 23,
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: kGrayColor,
                )
=======
            padding: EdgeInsets.only(
                left: 10,
                right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWithTap(networkSelected.isEmpty ?
                  networkText : networkSelected,
                  color: kGrayColor,
                  fontSize: size.width / 23,
                ),
                Icon(Icons.arrow_forward_ios, color: kGrayColor,)
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
              ],
            ),
          ),
        ),
      ],
    );
  }

<<<<<<< HEAD
  saveWithdraw() async {
=======
  saveWithdraw() async{
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
    QuickHelp.showLoadingDialog(context);

    WithdrawModel withdraw = WithdrawModel();
    withdraw.setAddress = addressTextController.text;
    withdraw.setNetWork = networkSelected;
    withdraw.setCredit = double.parse(amountTextController.text);
<<<<<<< HEAD
    int diamonds = QuickHelp.convertMoneyToDiamonds(
            double.parse(amountTextController.text), widget.preferences)
        .toInt();
=======
    int diamonds = QuickHelp.convertMoneyToDiamonds(double.parse(amountTextController.text), widget.preferences).toInt();
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
    withdraw.setAuthor = widget.currentUser!;
    withdraw.setStatus = WithdrawModel.PENDING;

    withdraw.setCompleted = false;
    withdraw.setMethod = WithdrawModel.USDT;
    withdraw.setDiamonds = diamonds;
    withdraw.setCurrency = WithdrawModel.CURRENCY;

    ParseResponse response = await withdraw.save();

<<<<<<< HEAD
    if (response.success && response.result != null) {
=======
    if(response.success && response.result != null){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      //sentToCloudCode();
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "withdraw_to_crypto.withdraw_succeed_title".tr(),
        context: context,
        message: "withdraw_to_crypto.withdraw_succeed_explain".tr(),
        isError: false,
      );
<<<<<<< HEAD
    } else {
=======

    }else{
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
          title: "withdraw_to_crypto.withdraw_failed_title".tr(),
          context: context,
<<<<<<< HEAD
          message: "withdraw_to_crypto.withdraw_failed_explain".tr());
=======
          message: "withdraw_to_crypto.withdraw_failed_explain".tr()
      );
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
    }
  }
}
