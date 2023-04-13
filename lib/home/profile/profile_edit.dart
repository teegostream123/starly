import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:teego/app/setup.dart';
import 'package:teego/components/DateTextFormatter.dart';
import 'package:teego/components/FirstUpperCaseTextFormatter.dart';
import 'package:teego/helpers/quick_actions.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/app_bar.dart';
import 'package:teego/ui/button_rounded.dart';
import 'package:teego/ui/button_rounded_outline.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/rounded_input_field.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

// ignore: must_be_immutable
class ProfileEdit extends StatefulWidget {

  static String route = "/ProfileEdit";

  UserModel? currentUser;

  ProfileEdit({Key? key, this.currentUser}) : super(key: key);

  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController fullNameEditingController = TextEditingController();
  TextEditingController aboutYouTitleEditingController =
      TextEditingController();
  TextEditingController birthdayEditingController = TextEditingController();

  String typeName = "name";
  String typeBirthday = "birthday";
  String typeGender = "gender";

  bool isValidBirthday = false;
  bool isValidGender = false;
  String myBirthday = "";
  String mySelectedGender = "";
  String userBirthday = "";
  String userGender = "";

  String userAvatar = "";
  String userCover = "";

  ParseFileBase? parseFile;

  @override
  void dispose() {
    fullNameEditingController.dispose();
    aboutYouTitleEditingController.dispose();
    birthdayEditingController.dispose();
    super.dispose();
  }

  _getUser() async {

    fullNameEditingController.text = widget.currentUser!.getFullName!;
    aboutYouTitleEditingController.text = widget.currentUser!.getAboutYou!;
    userBirthday = widget.currentUser!.getBirthday != null
        ? QuickHelp.getBirthdayFromDate(widget.currentUser!.getBirthday!)
        : "profile_screen.invalid_date".tr();

    if (widget.currentUser!.getBirthday != null) {
      isValidBirthday = true;
      birthdayEditingController.text =
          QuickHelp.getBirthdayFromDate(widget.currentUser!.getBirthday!);
    }

    if (widget.currentUser!.getGender != null) {
      isValidGender = true;

      mySelectedGender = widget.currentUser!.getGender!;
    }

    userGender = widget.currentUser!.getGender != null
        ? QuickHelp.getGender(widget.currentUser!)
        : "profile_screen.gender_invalid".tr();

    setState(() {
      userAvatar = widget.currentUser!.getAvatar != null ? widget.currentUser!.getAvatar!.url! : "";
      userCover = widget.currentUser!.getCover != null ? widget.currentUser!.getCover!.url! : "";
    });
  }

  @override
  void initState() {
    _getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    userAvatar = widget.currentUser!.getAvatar != null ? widget.currentUser!.getAvatar!.url! : "";
    userCover = widget.currentUser!.getCover != null ? widget.currentUser!.getCover!.url! : "";

    return GestureDetector(
      onTap: (){
        FocusScopeNode focusScopeNode = FocusScope.of(context);
        if (!focusScopeNode.hasPrimaryFocus &&
            focusScopeNode.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: ToolBar(
        title: "page_title.edit_profile_title".tr(),
        leftButtonIcon: Icons.arrow_back,
        onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context, result: widget.currentUser),
        child: ContainerCorner(
          color: QuickHelp.isDarkMode(context) ? kContentColorLightTheme : kContentColorDarkTheme,
          child: ListView(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ContainerCorner(
                    borderWidth: 0,
                    color: kTransparentColor,
                    height: 200,
                    //imageDecoration: "assets/images/ic_location_permission.png",
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.black.withOpacity(0.2),
                        child: QuickActions.profileCover(userCover),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: 1,
                    right: 1,
                    child: Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            child: QuickActions.profileAvatar(
                              userAvatar,
                              boxShape: BoxShape.circle,
                              width: 120,
                              height: 120,
                              borderRadius: 0,
                              margin: EdgeInsets.only(
                                bottom: 0,
                                top: 0,
                                left: 10,
                                right: 5,
                              ),
                            ),
                            onTap: ()=> checkPermission(true),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 55,
                            //right: 40,
                            child: ContainerCorner(
                              color: kGrayColor.withOpacity(0.5),
                              height: 30,
                              width: 30,
                              borderRadius: 50,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 22,
                              ),
                              onTap: ()=> checkPermission(true),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ContainerCorner(
                      color: kGrayColor.withOpacity(0.5),
                      height: 30,
                      width: 30,
                      borderRadius: 50,
                      marginTop: 155,
                      marginRight: 5,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 22,
                      ),
                      onTap: () => checkPermission(false),
                    ),
                  ),
                ],
              ),
              ContainerCorner(
                marginTop: 80,
                color: kTransparentColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWithTap(
                      "profile_screen.name_".tr(),
                      marginLeft: 10,
                      marginBottom: 5,
                    ),
                    TextWithTap(
                      widget.currentUser!.getFullName!,
                      marginRight: 5,
                      marginLeft: 10,
                      color: kGrayColor,
                    ),
                    ContainerCorner(
                      marginTop: 20,
                      color: QuickHelp.isDarkMode(context) ? kGreyColor2: kGreyColor0,
                      height: 1,
                    )
                  ],
                ),
                onTap: () => _changeName(),
              ),
              ContainerCorner(
                marginTop: 10,
                color: kTransparentColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWithTap(
                      "profile_screen.about_me".tr(),
                      marginLeft: 10,
                      marginBottom: 5,
                    ),
                    ContainerCorner(
                      marginLeft: 10,
                      marginRight: 10,
                      width: MediaQuery.of(context).size.width - 20,
                      borderRadius: 10,
                      color: QuickHelp.isDarkMode(context) ? kGreyColor2: kGreyColor0,
                      child: TextWithTap(
                        widget.currentUser!.getAboutYou!.isNotEmpty
                            ? widget.currentUser!.getAboutYou!
                            : "profile_screen.profile_desc_hint".tr(),
                        marginRight: 10,
                        marginBottom: 10,
                        marginTop: 10,
                        marginLeft: 10,
                      ),
                    ),
                    ContainerCorner(
                      marginTop: 20,
                      color: QuickHelp.isDarkMode(context) ? kGreyColor2: kGreyColor0,
                      height: 1,
                    )
                  ],
                ),
              ),
              ContainerCorner(
                marginTop: 10,
                color: kTransparentColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWithTap(
                      "profile_screen.birthday_".tr(),
                      marginLeft: 10,
                      marginBottom: 5,
                    ),
                    TextWithTap(
                      userBirthday,
                      color: kGrayColor,
                      marginLeft: 10,
                      marginBottom: 5,
                      fontSize: 12,
                    ),
                    ContainerCorner(
                      marginTop: 10,
                      color: QuickHelp.isDarkMode(context) ? kGreyColor2: kGreyColor0,
                      height: 1,
                    )
                  ],
                ),
                onTap: () => _changeName(),
              ),
              ContainerCorner(
                marginTop: 10,
                color: kTransparentColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWithTap(
                      "profile_screen.gender_".tr(),
                      marginLeft: 10,
                      marginBottom: 5,
                    ),
                    TextWithTap(
                      userGender,
                      color: kGrayColor,
                      marginLeft: 10,
                      marginBottom: 5,
                      fontSize: 12,
                    ),
                    ContainerCorner(
                      marginTop: 10,
                      color: QuickHelp.isDarkMode(context) ? kGreyColor2: kGreyColor0,
                      height: 1,
                    )
                  ],
                ),
                onTap: () => _changeName(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _changeName() {
    showModalBottomSheet(
      backgroundColor: QuickHelp.isDarkMode(context)
          ? kContentColorLightTheme
          : kContentColorDarkTheme,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(25.0),
          topRight: const Radius.circular(25.0),
        ),
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return GestureDetector(
            onTap: (){
              FocusScopeNode focusScopeNode = FocusScope.of(context);
              if (!focusScopeNode.hasPrimaryFocus &&
                  focusScopeNode.focusedChild != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.remove,
                            color: Colors.grey[600],
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                margin: EdgeInsets.only(
                                    top: 10, bottom: 20, left: 30, right: 30),
                                child: QuickActions.avatarWidget(widget.currentUser!),
                              ),
                            ],
                          ),
                          TextWithTap(
                            widget.currentUser!.getFullName!,
                            fontSize: 22,
                            marginBottom: 5,
                            marginTop: 5,
                            fontWeight: FontWeight.bold,
                          ),
                          TextWithTap(
                            "profile_screen.update_your_profile".tr(),
                            fontSize: 18,
                            marginBottom: 5,
                            marginRight: 20,
                            marginLeft: 20,
                            textAlign: TextAlign.center,
                            marginTop: 5,
                          ),
                          builderTextField(setState),
                        ],
                      ),
                      ButtonRounded(
                        text: "update_".tr(),
                        marginLeft: 20,
                        marginRight: 20,
                        color: kPrimaryColor,
                        textColor: Colors.white,
                        fontSize: 16,
                        borderRadius: 10,
                        height: 45,
                        marginTop: 30,
                        marginBottom: 30,
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            _updateNow();
                          } else if(!isValidBirthday){
                            QuickHelp.showAppNotification(context: context, title: "profile_screen.choose_birthday".tr());
                          } else if(!isValidGender){
                            QuickHelp.showAppNotification(context: context, title: "profile_screen.gender_invalid_select".tr());
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget builderTextField(StateSetter setState) {
    String? _validateFullName(String value) {
      int firstSpace = value.indexOf(" ");

      if (value.isEmpty) {
        return "profile_screen.no_full_name".tr();
      }
       else if (firstSpace < 1) {
        return "profile_screen.full_name_please".tr();
      } else if (fullNameEditingController.text.endsWith(" ")) {
        return "profile_screen.full_name_please".tr();
      }
       /*else if (fullNameEditingController.text == widget.currentUser!.getFullName!) {
        return "settings_screen.same_name_inserted".tr();
      }*/
      else {
        return null;
      }
    }

    String? _validateBirthday(String value) {
      isValidBirthday = false;
      if (value.isEmpty) {
        return "profile_screen.choose_birthday".tr();
      } else if (!QuickHelp.isValidDateBirth(value, QuickHelp.dateFormatDmy)) {
        return "profile_screen.invalid_date".tr();
      } else if (!QuickHelp.minimumAgeAllowed(value, QuickHelp.dateFormatDmy)) {
        return "profile_screen.mim_age_required"
            .tr(namedArgs: {'age': Setup.minimumAgeToRegister.toString()});
      } else {
        isValidBirthday = true;
        myBirthday = value;
        return null;
      }
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RoundedInputField(
            // Full name
            inputFormatters: [FirstUpperCaseTextFormatter()],
            isNodeNext: false,
            textInputAction: TextInputAction.done,
            hintText: "auth.full_name_hint".tr(),
            controller: fullNameEditingController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              return _validateFullName(value!);
            },
          ),
          ContainerCorner(
            marginLeft: 25,
            marginRight: 25,
            width: MediaQuery.of(context).size.width - 20,
            borderRadius: 10,
            color: kGreyColor0,
            child: TextFormField(
              controller: aboutYouTitleEditingController,
              maxLength: 500,
              minLines: 1,
              maxLines: 100,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style: TextStyle(
                color: kGreyColor2,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              keyboardType: TextInputType.multiline,
              validator: (value) {
                return null;
                /*if (value!.isEmpty) {
                  return "profile_screen.hint_about_you".tr();
                } else {
                  return null;
                }*/
              },
              decoration: InputDecoration(
                hintText: "profile_screen.hint_about_you".tr(),
                focusedBorder: InputBorder.none,
                border: InputBorder.none,
                //errorText: "profile_screen.hint_about_you".tr(),
                hintStyle: TextStyle(
                  color: kGreyColor2,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          RoundedInputField(
            // Birthday
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp("[0-9/]")),
              LengthLimitingTextInputFormatter(10),
              DateFormatter(),
            ],
            textInputType: TextInputType.datetime,
            isNodeNext: false,
            textInputAction: TextInputAction.done,
            hintText: "profile_screen.birthday_hint".tr(),
            //icon: Icons.calendar_today,
            //hintText: QuickHelp.toOriginalFormatString(new DateTime.now()),
            onChanged: (value) {
              setState(() {
                _validateBirthday(value);
              });
            },
            controller: birthdayEditingController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              return _validateBirthday(value!);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonRoundedOutline(
                text: "female_".tr().toUpperCase(),
                borderRadius: 60,
                //width: 250,
                height: 46,
                fontSize: 17,
                borderWidth: 1,
                marginRight: 10,
                marginLeft: 10,
                borderColor: mySelectedGender == UserModel.keyGenderFemale
                    ? kPrimaryColor
                    : kPrimacyGrayColor,
                textColor: mySelectedGender == UserModel.keyGenderFemale
                    ? kPrimaryColor
                    : kPrimacyGrayColor,
                onTap: () {
                  setState(() {
                    isValidGender = true;
                    mySelectedGender = UserModel.keyGenderFemale;
                  });
                },
              ),
              ButtonRoundedOutline(
                text: "male_".tr().toUpperCase(),
                borderRadius: 60,
                //width: 250,
                //MediaQuery.of(context).size.width * 0.4,
                height: 46,
                fontSize: 17,
                borderWidth: 1,
                marginRight: 10,
                marginLeft: 10,
                //marginTop: 15,
                borderColor: mySelectedGender == UserModel.keyGenderMale
                    ? kPrimaryColor
                    : kPrimacyGrayColor,
                textColor: mySelectedGender == UserModel.keyGenderMale
                    ? kPrimaryColor
                    : kPrimacyGrayColor,
                onTap: () {
                  setState(() {
                    isValidGender = true;
                    mySelectedGender = UserModel.keyGenderMale;
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _updateNow() async {
    QuickHelp.showLoadingDialog(context);

    String fullName = fullNameEditingController.text.trim();
    String firstName = "";
    String lastName = "";

    if (fullName.contains(" ")) {
      int firstSpace = fullName.indexOf(" ");
      firstName = fullName.substring(0, firstSpace);
      lastName = fullName.substring(firstSpace).trim();
    } else {
      firstName = fullName;
    }

    String username = fullName.replaceAll(" ", "");

    /*if(widget.currentUser!.getFullName! != fullNameEditingController.text.trim()){
      widget.currentUser!.setNeedsChangeName = false;
    }*/

    widget.currentUser!.setFullName = fullName;
    widget.currentUser!.setFirstName = firstName;
    widget.currentUser!.setLastName = lastName;
    widget.currentUser!.setGender = mySelectedGender;
    widget.currentUser!.username = username.toLowerCase();
    widget.currentUser!.setBirthday = QuickHelp.getDate(birthdayEditingController.text);

    if(aboutYouTitleEditingController.text.isNotEmpty){
      widget.currentUser!.setAboutYou = aboutYouTitleEditingController.text;
    }

    ParseResponse userResult = await widget.currentUser!.save();

    if (userResult.success) {
      QuickHelp.hideLoadingDialog(context, result: userResult.results!.first as UserModel);
      QuickHelp.hideLoadingDialog(context, result: userResult.results!.first as UserModel);

      widget.currentUser = userResult.results!.first as UserModel;

      _getUser();
    } else if (userResult.error!.code == 100) {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
          context: context, title: "error".tr(), message: "not_connected".tr());
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "error".tr(),
          message: "try_again_later".tr());
    }
  }

  Future<void> checkPermission(bool isAvatar) async {
    if (QuickHelp.isAndroidPlatform()) {
      PermissionStatus status = await Permission.storage.status;
      PermissionStatus status2 = await Permission.camera.status;
      print('Permission android');

      checkStatus(status, status2, isAvatar);
    } else if (QuickHelp.isIOSPlatform()) {
      PermissionStatus status = await Permission.photos.status;
      PermissionStatus status2 = await Permission.camera.status;
      print('Permission ios');

      checkStatus(status, status2, isAvatar);
    } else {
      print('Permission other device');

      _choosePhoto(isAvatar);
    }
  }

  void checkStatus(
      PermissionStatus status, PermissionStatus status2, bool isAvatar) {
    if (status.isDenied || status2.isDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.

      QuickHelp.showDialogPermission(
          context: context,
          title: "permissions.photo_access".tr(),
          confirmButtonText: "permissions.okay_".tr().toUpperCase(),
          message: "permissions.photo_access_explain"
              .tr(namedArgs: {"app_name": Setup.appName}),
          onPressed: () async {
            QuickHelp.hideLoadingDialog(context);

            //if (await Permission.camera.request().isGranted) {
            // Either the permission was already granted before or the user just granted it.
            //}

            // You can request multiple permissions at once.
            Map<Permission, PermissionStatus> statuses = await [
              Permission.camera,
              Permission.photos,
              Permission.storage,
            ].request();

            if (statuses[Permission.camera]!.isGranted &&
                    statuses[Permission.photos]!.isGranted ||
                statuses[Permission.storage]!.isGranted) {
              _choosePhoto(isAvatar);
            }
          });
    } else if (status.isPermanentlyDenied || status2.isPermanentlyDenied) {
      QuickHelp.showDialogPermission(
          context: context,
          title: "permissions.photo_access_denied".tr(),
          confirmButtonText: "permissions.okay_settings".tr().toUpperCase(),
          message: "permissions.photo_access_denied_explain"
              .tr(namedArgs: {"app_name": Setup.appName}),
          onPressed: () {
            QuickHelp.hideLoadingDialog(context);

            openAppSettings();
          });
    } else if (status.isGranted && status2.isGranted) {
      //_uploadPhotos(ImageSource.gallery);
      _choosePhoto(isAvatar);
    }

    print('Permission $status');
    print('Permission $status2');
  }

  _choosePhoto(bool isAvatar) async {

    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
          maxAssets: 1,
          //gridCount: 3,
          //pageSize: ,
          requestType: RequestType.image,
          filterOptions: FilterOptionGroup(
            containsLivePhotos: false,
          )),
    );

    if (result != null && result.length > 0) {
      final File? image = await result.first.file;
      cropPhoto(image!.path, isAvatar);
    } else {
      print("Photos null");
    }
  }

  void cropPhoto(String path, bool isAvatar) async {
    QuickHelp.showLoadingDialog(context);

    CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: path,
        aspectRatioPresets: [
          isAvatar == true ? CropAspectRatioPreset.square : CropAspectRatioPreset.ratio16x9,
        ],
        //maxHeight: 480,
        //maxWidth: 740,
        aspectRatio: isAvatar == true ? CropAspectRatio(ratioX: 4, ratioY: 4) : CropAspectRatio(ratioX: 16, ratioY: 9),
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: "edit_photo".tr(),
              toolbarColor: kPrimaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: isAvatar == true ? CropAspectRatioPreset.square : CropAspectRatioPreset.ratio16x9,
              lockAspectRatio: false),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
          )
        ]);

    if (croppedFile != null) {

      //compressImage(QuickHelp.asImageFile(croppedFile), isAvatar);
      compressImage(croppedFile.path, isAvatar);
    } else {
      QuickHelp.hideLoadingDialog(context);
      return;
    }
  }

  void compressImage(String path, bool isAvatar) {

    QuickHelp.showLoadingAnimation();
    //QuickHelp.showLoadingDialogWithText(context, description: "crop_image_scree.optimizing_image".tr(), useLogo: true);

    Future.delayed(Duration(seconds: 1), () async{
      var result = await QuickHelp.compressImage(path);

      if(result != null){

        //QuickHelp.hideLoadingDialog(context);
        //QuickHelp.showLoadingDialogWithText(context, description: "crop_image_scree.optimizing_image_uploading".tr());

        uploadFile(result, isAvatar);

      } else {

        QuickHelp.hideLoadingDialog(context);

        QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "crop_image_scree.cancelled_by_user".tr(),
          message: "crop_image_scree.image_not_cropped_error".tr(),
        );
      }
    });

  }

  uploadFile(File imageFile, bool isAvatar) async {

    if(imageFile.absolute.path.isNotEmpty){
      parseFile = ParseFile(File(imageFile.absolute.path), name: "avatar.jpg");
    } else {
      parseFile = ParseWebFile(imageFile.readAsBytesSync(), name: "avatar.jpg");
    }

    if (isAvatar == true) {
      widget.currentUser!.setAvatar = parseFile!;
    } else {
      widget.currentUser!.setCover = parseFile!;
    }

    ParseResponse parseResponse = await widget.currentUser!.save();

    if(parseResponse.success){
      widget.currentUser = parseResponse.results!.first as UserModel;
      QuickHelp.hideLoadingDialog(context);
      _getUser();
    } else {
      QuickHelp.hideLoadingDialog(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "try_again_later".tr(),
      );
    }
  }
}
