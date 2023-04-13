import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teego/helpers/quick_actions.dart';
import 'package:teego/helpers/quick_cloud.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/home/calls/voice_call_screen.dart';
import 'package:teego/home/coins/coins_payment_widget.dart';
import 'package:teego/models/CallsModel.dart';
import 'package:teego/models/GiftsModel.dart';
import 'package:teego/models/MessageListModel.dart';
import 'package:teego/models/MessageModel.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/app_bar_center_widget.dart';
import 'package:teego/ui/button_with_gradient.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';
import 'package:teego/utils/utilsConstants.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../app/setup.dart';
import '../../helpers/send_notifications.dart';
import '../calls/video_call_screen.dart';

// ignore_for_file: must_be_immutable
class MessageScreen extends StatefulWidget {
  static String route = '/messages/chat';

  SharedPreferences? preferences;
  UserModel? currentUser, mUser;

  MessageScreen({Key? key, this.currentUser, this.mUser,  required this.preferences}): super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {

  SharedPreferences? preferences;
  TextEditingController messageController = TextEditingController();

  UserModel? currentUser, mUser;

  String? sendButtonIcon = "assets/svg/ic_menu_gifters.svg";
  Color sendButtonBackground = kColorsBlue400;

  var uploadPhoto;
  ParseFileBase? parseFile;
  int? _countSelectedPictures = 0;

  int currentView = 0;
  List<Widget>? pages;

  var initialLoad;

  //Live query stuff
  late QueryBuilder<MessageModel> queryBuilder;
  final LiveQuery liveQuery = LiveQuery();
  Subscription? subscription;
  List<dynamic> results = <dynamic>[];

  GroupedItemScrollController listScrollController =
      GroupedItemScrollController();

  void openPicture(ParseFileBase picture) async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showMessagePictureBottomSheet(picture);
        });
  }

  _choosePhoto(StateSetter setState) async {
    /*final ImagePicker _picker = ImagePicker();

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      cropPhoto(image.path, setState);
    } else {
      print("Photos null");
    }

    */

    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
          maxAssets: 1,
          requestType: RequestType.image,
          filterOptions: FilterOptionGroup(
            containsLivePhotos: false,
          )),
    );

    if (result != null && result.length > 0) {
      final File? image = await result.first.file;
      cropPhoto(image!.path, setState);
    } else {
      print("Photos null");
    }
  }

  void cropPhoto(String path, StateSetter setState) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: path,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: "edit_photo".tr(),
              toolbarColor: kPrimaryColor,
              toolbarWidgetColor: Colors.white,
              lockAspectRatio: false),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
          )
        ]);

    if (croppedFile != null) {
      compressImage(croppedFile.path, setState);
    }
  }

  void compressImage(String path, StateSetter setState) {

    QuickHelp.showLoadingAnimation();

    Future.delayed(Duration(seconds: 1), () async{
      var result = await QuickHelp.compressImage(path);

      if(result != null){

        uploadFile(result, setState);

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



  uploadFile(File imageFile, StateSetter setState) async {

    if(imageFile.absolute.path.isNotEmpty){
      parseFile = ParseFile(File(imageFile.absolute.path), name: "avatar.jpg");

      //print("Image path ${imageFile.absolute.path}");

      setState(() {
        uploadPhoto = imageFile.absolute.path;
      });

    } else {

      setState(() {
        uploadPhoto = imageFile.readAsBytes();
      });

      parseFile = ParseWebFile(imageFile.readAsBytesSync(), name: "avatar.jpg");
    }

    QuickHelp.showLoadingDialog(context);

    ParseResponse parseResponse = await parseFile!.save();
    if (parseResponse.success) {
      QuickHelp.hideLoadingDialog(context);
    } else {
      QuickHelp.showLoadingDialog(context);
      QuickHelp.showAppNotification(
          context: context, title: parseResponse.error!.message);

    }
  }

  void changeButtonIcon(String text) {
    setState(() {
      if (text.isNotEmpty) {
        sendButtonIcon = "assets/svg/ic_send_message.svg";
        sendButtonBackground = kPrimaryColor;
      } else {
        sendButtonIcon = "assets/svg/ic_menu_gifters.svg";
        sendButtonBackground = kColorsBlue400;
      }
    });
  }

  @override
  void dispose() {
    messageController.dispose();

    if (subscription != null) {
      liveQuery.client.unSubscribe(subscription!);
    }

    super.dispose();
  }

  @override
  void initState() {

    Future.delayed(Duration(microseconds: 100), (){
      setState(() {
        initialLoad = _loadMessages();
      });
    });

    if(widget.currentUser != null && widget.mUser != null){
      currentUser = widget.currentUser;
      mUser = widget.mUser;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if(ModalRoute.of(context)!.settings.arguments != null){
      final users = ModalRoute.of(context)!.settings.arguments as Map;

      currentUser = users['currentUser'];
      mUser = users['mUser'];
    }

    return GestureDetector(
      onTap: () {
        FocusScopeNode focusScopeNode = FocusScope.of(context);
        if (!focusScopeNode.hasPrimaryFocus &&
            focusScopeNode.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: ToolBarCenterWidget(
        elevation: 1,
        centerTitle: false,
        leftButtonIcon: Icons.arrow_back,
        leftButtonPress: () => QuickHelp.goBackToPreviousPage(context),
        centerWidget: GestureDetector(
          onTap: (){
            QuickActions.showUserProfile(context, currentUser!, mUser!);
          },
          child: Row(
            children: [
              QuickActions.avatarWidget(mUser!, width: 40, height: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWithTap(
                    mUser!.getFirstName!,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: QuickHelp.isDarkMode(context)
                        ? Colors.white
                        : Colors.black,
                    marginLeft: 10,
                    marginRight: 10,
                  ),
                  TextWithTap(
                    QuickHelp.isUserOnlineChat(mUser!),
                    color: QuickHelp.isUserOnline(mUser!)
                        ? Colors.green
                        : kGrayColor,
                    marginLeft: 10,
                    fontSize: 12,
                  )
                ],
              ),
            ],
          ),
        ),
        rightButtonWidget: Visibility(
          visible: !mUser!.isAdmin!,
          child: Row(
            children: [
              ContainerCorner(
                color: kTransparentColor,
                child: Icon(
                  Icons.add_call,
                  color: kPrimaryColor,
                ),
                marginRight: 20,
                onTap: () {
                  checkPermission(false);
                },
              ),
              ContainerCorner(
                color: kTransparentColor,
                child: Icon(
                  Icons.videocam,
                  color: kPrimaryColor,
                  size: 35,
                ),
                width: 35,
                height: 35,
                marginRight: 10,
                onTap: () {
                  checkPermission(true);
                },
              )
            ],
          ),
        ),
        child: _messageSpace(context),
      ),
    );
  }

  checkPermission(bool isVideoCall) async {
    if (await Permission.camera.isGranted &&
        await Permission.microphone.isGranted) {
      startCall(isVideoCall);
    } else if (await Permission.camera.isDenied ||
        await Permission.microphone.isDenied) {
      QuickHelp.showDialogPermission(
          context: context,
          title: "permissions.call_access".tr(),
          confirmButtonText: "permissions.okay_".tr().toUpperCase(),
          message: "permissions.call_access_explain"
              .tr(namedArgs: {"app_name": Setup.appName}),
          onPressed: () async {
            QuickHelp.hideLoadingDialog(context);

            // You can request multiple permissions at once.
            Map<Permission, PermissionStatus> statuses = await [
              Permission.camera,
              Permission.microphone,
            ].request();

            if (statuses[Permission.camera]!.isGranted &&
                statuses[Permission.microphone]!.isGranted) {
              startCall(isVideoCall);
            } else {
              QuickHelp.showAppNotificationAdvanced(
                  title: "permissions.call_access_denied".tr(),
                  message: "permissions.call_access_denied_explain"
                      .tr(namedArgs: {"app_name": Setup.appName}),
                  context: context,
                  isError: true);
            }
          });
    } else if (await Permission.camera.isPermanentlyDenied ||
        await Permission.microphone.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  startCall(bool isVideoCall) {
    if (isVideoCall) {
      if (currentUser!.getCredits! >= Setup.coinsNeededForVideoCallPerMinute) {
        QuickHelp.showDialogWithButtonCustom(
            context: context,
            title: "video_call.video_call_price".tr(),
            message: "video_call.video_explain".tr(namedArgs: {
              "coins": Setup.coinsNeededForVideoCallPerMinute.toString(),
              "name": mUser!.getFirstName!
            }),
            cancelButtonText: "cancel".tr(),
            confirmButtonText: "continue".tr(),
            onPressed: () async {
              QuickHelp.hideLoadingDialog(context);
              UserModel? userModel = await QuickHelp.goToNavigatorScreenForResult(
                  context,
                  VideoCallScreen(
                    key: Key(QuickHelp.generateUId().toString()),
                    currentUser: currentUser,
                    mUser: mUser,
                    preferences: widget.preferences,
                    channel: currentUser!.objectId,
                    isCaller: true,
                  ));

              currentUser = userModel;
            });
      } else {
        QuickHelp.showAppNotificationAdvanced(
            title: "video_call.no_coins".tr(),
            message: "video_call.no_coins_video".tr(namedArgs: {
              "coins": Setup.coinsNeededForVideoCallPerMinute.toString()
            }),
            context: context,
            isError: true);

        CoinsFlowPayment(
            context: context,
            currentUser: currentUser!,
            showOnlyCoinsPurchase: true,
            onCoinsPurchased: (coins) {
              print("onCoinsPurchased: $coins new: ${currentUser!.getCredits}");
              startCall(true);
            });
      }
    } else {
      if (currentUser!.getCredits! >= Setup.coinsNeededForVoiceCallPerMinute) {
        QuickHelp.showDialogWithButtonCustom(
            context: context,
            title: "video_call.voice_call_price".tr(),
            message: "video_call.voice_explain".tr(namedArgs: {
              "coins": Setup.coinsNeededForVoiceCallPerMinute.toString(),
              "name": mUser!.getFirstName!
            }),
            cancelButtonText: "cancel".tr(),
            confirmButtonText: "continue".tr(),
            onPressed: () {
              QuickHelp.hideLoadingDialog(context);


              QuickHelp.goToNavigatorScreen(
                  context,
                  VoiceCallScreen(
                    key: Key(QuickHelp.generateUId().toString()),
                    mUser: mUser,
                    preferences: widget.preferences,
                    currentUser: currentUser,
                    channel: currentUser!.objectId,
                    isCaller: true,
                  ));
            });
      } else {
        QuickHelp.showAppNotificationAdvanced(
            title: "video_call.no_coins".tr(),
            message: "video_call.no_coins_voice".tr(namedArgs: {
              "coins": Setup.coinsNeededForVoiceCallPerMinute.toString()
            }),
            context: context,
            isError: true);

        CoinsFlowPayment(
            context: context,
            currentUser: currentUser!,
            showOnlyCoinsPurchase: true,
            onCoinsPurchased: (coins) {
              print("onCoinsPurchased: $coins new: ${currentUser!.getCredits}");
              startCall(false);
            });
      }
    }
  }

  _updateMessageList(MessageListModel messageListModel) async {
    messageListModel.setIsRead = true;
    messageListModel.setCounter = 0;
    await messageListModel.save();
  }

  _updateMessageStatus(MessageModel messageModel) async {
    messageModel.setIsRead = true;
    await messageModel.save();
  }

  Future<void> _objectUpdated(MessageModel object) async {
    for (int i = 0; i < results.length; i++) {
      if (results[i].get<String>(keyVarObjectId) ==
          object.get<String>(keyVarObjectId)) {
        if (UtilsConstant.after(results[i], object) == null) {
          setState(() {
            // ignore: invalid_use_of_protected_member
            results[i] = object.clone(object.toJson(full: true));
          });
        }
        break;
      }
    }
  }

  setupLiveQuery() async {
    if (subscription == null) {
      subscription = await liveQuery.client.subscribe(queryBuilder);
    }

    subscription!.on(LiveQueryEvent.create, (MessageModel message) {
      if (message.getAuthorId == mUser!.objectId) {
        setState(() {
          results.add(message);
        });
      } else {
        setState(() {});
      }
    });

    subscription!.on(LiveQueryEvent.update, (MessageModel message) {
      _objectUpdated(message);
    });
  }

  Future<List<dynamic>?> _loadMessages() async {

    QueryBuilder<MessageModel> queryFrom =
        QueryBuilder<MessageModel>(MessageModel());

    queryFrom.whereEqualTo(MessageModel.keyAuthor, currentUser!);

    queryFrom.whereEqualTo(MessageModel.keyReceiver, mUser!);

    QueryBuilder<MessageModel> queryTo =
        QueryBuilder<MessageModel>(MessageModel());
    queryTo.whereEqualTo(MessageModel.keyAuthor, mUser!);
    queryTo.whereEqualTo(MessageModel.keyReceiver, currentUser!);

    queryBuilder = QueryBuilder.or(MessageModel(), [queryFrom, queryTo]);
    queryBuilder.orderByDescending(MessageModel.keyCreatedAt);

    setupLiveQuery();

    queryBuilder.includeObject([
      MessageModel.keyCall,
      MessageModel.keyAuthor,
      MessageModel.keyReceiver,
      MessageModel.keyListMessage,
    ]);

    ParseResponse apiResponse = await queryBuilder.query();
    if (apiResponse.success) {
      print("Messages count: ${apiResponse.results!.length}");
      if (apiResponse.results != null) {
        return apiResponse.results;
      } else {
        return AsyncSnapshot.nothing() as dynamic;
      }
    } else {
      return apiResponse.error as dynamic;
    }
  }

  scrollToBottom(
      {required int position,
      bool? animated = false,
      int? duration = 3,
      Curve? curve = Curves.easeOut}) {
    if (listScrollController.isAttached) {
      if (animated = true) {
        listScrollController.scrollTo(
            index: position,
            duration: Duration(seconds: duration!),
            curve: curve!);
      } else {
        listScrollController.jumpTo(index: position, automaticAlignment: false);
      }
    }
  }

  Widget _messageSpace(BuildContext showContext) {

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: FutureBuilder<List<dynamic>?>(
                future: initialLoad,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    results = snapshot.data as List<dynamic>;
                    var reversedList = results.reversed.toList();

                    return StickyGroupedListView<dynamic, DateTime>(
                      elements: reversedList,
                      reverse: true,
                      order: StickyGroupedListOrder.DESC,
                      // Check first
                      groupBy: (dynamic message) {
                        if (message.createdAt != null) {
                          return DateTime(message.createdAt!.year,
                              message.createdAt!.month, message.createdAt!.day);
                        } else {
                          return DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day);
                        }
                      },
                      floatingHeader: true,
                      groupComparator: (DateTime value1, DateTime value2) {
                        return value1.compareTo(value2);
                      },
                      itemComparator: (dynamic element1, dynamic element2) {
                        if (element1.createdAt != null &&
                            element2.createdAt != null) {
                          return element1.createdAt!
                              .compareTo(element2.createdAt!);
                        } else if (element1.createdAt == null &&
                            element2.createdAt != null) {
                          return DateTime.now().compareTo(element2.createdAt!);
                        } else if (element1.createdAt != null &&
                            element2.createdAt == null) {
                          return element1.createdAt!.compareTo(DateTime.now());
                        } else {
                          return DateTime.now().compareTo(DateTime.now());
                        }
                      },
                      groupSeparatorBuilder: (dynamic element) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 0, top: 3),
                          child: TextWithTap(
                            QuickHelp.getMessageTime(element.createdAt != null
                                ? element.createdAt!
                                : DateTime.now()),
                            textAlign: TextAlign.center,
                            color: kGreyColor1,
                            fontSize: 12,
                          ),
                        );
                      },
                      itemBuilder: (context, dynamic chatMessage) {
                        bool isMe =
                            chatMessage.getAuthorId! == currentUser!.objectId!
                                ? true
                                : false;
                        if (!isMe && !chatMessage.isRead!) {
                          _updateMessageStatus(chatMessage);
                        }

                        if (chatMessage.getMessageList != null &&
                            chatMessage.getMessageList!.getAuthorId ==
                                mUser!.objectId) {
                          MessageListModel chatList =
                              chatMessage.getMessageList as MessageListModel;

                          if (!chatList.isRead! &&
                              chatList.objectId ==
                                  chatMessage.getMessageListId) {
                            _updateMessageList(chatMessage.getMessageList!);
                          }
                        }

                        return Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Container(
                            padding: EdgeInsets.only(top: 20),
                            child: isMe
                                ? Align(
                                    alignment: Alignment.centerRight,
                                    child: Column(
                                      children: [
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypeCall)
                                          ContainerCorner(
                                            radiusBottomLeft: 10,
                                            radiusTopLeft: 10,
                                            radiusTopRight: 10,
                                            marginTop: 10,
                                            marginBottom: 10,
                                            color: kColorsLightBlue300,
                                            child: callMessage(chatMessage, true),
                                          ),
                                        if (chatMessage.getMessageType == MessageModel.messageTypeText)
                                          ContainerCorner(
                                            radiusBottomLeft: 10,
                                            radiusTopLeft: 10,
                                            radiusTopRight: 10,
                                            colors: [
                                              kPrimaryColor,
                                              kSecondaryColor
                                            ],
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [

                                                TextWithTap(
                                                  chatMessage.getDuration!,
                                                  marginBottom: 5,
                                                  marginTop: 10,
                                                  color: Colors.white,
                                                  marginLeft: 10,
                                                  marginRight: 10,
                                                  fontSize: 14,
                                                  overflow: TextOverflow.ellipsis,
                                                  selectableText: true,
                                                  urlDetectable: true,
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    TextWithTap(
                                                      chatMessage.createdAt !=
                                                              null
                                                          ? QuickHelp
                                                              .getMessageTime(
                                                                  chatMessage
                                                                      .createdAt!,
                                                                  time: true)
                                                          : "sending_".tr(),
                                                      color: Colors.white
                                                          .withOpacity(0.7),
                                                      fontSize: 12,
                                                      marginRight: 10,
                                                      marginLeft: 10,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 3),
                                                      child: Icon(
                                                        chatMessage.createdAt !=
                                                                null
                                                            ? Icons.done_all
                                                            : Icons
                                                                .access_time_outlined,
                                                        color:
                                                            chatMessage.isRead!
                                                                ? kBlueColor1
                                                                : Colors.white,
                                                        size: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypeGif)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              gifMessage(
                                                  chatMessage.getGifMessage),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  TextWithTap(
                                                    chatMessage.createdAt !=
                                                            null
                                                        ? QuickHelp
                                                            .getMessageTime(
                                                                chatMessage
                                                                    .createdAt!,
                                                                time: true)
                                                        : "sending_".tr(),
                                                    color: kGrayColor,
                                                    fontSize: 12,
                                                    marginRight: 10,
                                                    marginLeft: 10,
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    child: Icon(
                                                      chatMessage.createdAt !=
                                                              null
                                                          ? Icons.done_all
                                                          : Icons
                                                              .access_time_outlined,
                                                      color: chatMessage.isRead!
                                                          ? kBlueColor1
                                                          : kGrayColor,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypePicture)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              pictureMessage(chatMessage
                                                  .getPictureMessage),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  TextWithTap(
                                                    chatMessage.createdAt !=
                                                            null
                                                        ? QuickHelp
                                                            .getMessageTime(
                                                                chatMessage
                                                                    .createdAt!,
                                                                time: true)
                                                        : "sending_".tr(),
                                                    color: kGrayColor,
                                                    fontSize: 12,
                                                    marginRight: 10,
                                                    marginLeft: 10,
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    child: Icon(
                                                      chatMessage.createdAt !=
                                                              null
                                                          ? Icons.done_all
                                                          : Icons
                                                              .access_time_outlined,
                                                      color: chatMessage.isRead!
                                                          ? kBlueColor1
                                                          : kGrayColor,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                      ],
                                    ),
                                  )
                                : Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypeCall)
                                          ContainerCorner(
                                            radiusTopLeft: 10,
                                            radiusTopRight: 10,
                                            radiusBottomRight: 10,
                                            marginTop: 10,
                                            marginBottom: 10,
                                            color: kGreyColor0,
                                            child: callMessage(chatMessage, false),
                                          ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypeText)
                                          ContainerCorner(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                QuickActions.avatarWidget(
                                                    mUser!,
                                                    width: 25,
                                                    height: 25),
                                                Flexible(
                                                  child: GestureDetector(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        ContainerCorner(
                                                          radiusTopLeft: 10,
                                                          radiusTopRight: 10,
                                                          radiusBottomRight: 10,
                                                          marginRight: 10,
                                                          marginLeft: 5,
                                                          color: kGreyColor0,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              TextWithTap(
                                                                chatMessage.getDuration!,
                                                                marginBottom: 10,
                                                                marginTop: 10,
                                                                color: Colors.black,
                                                                marginLeft: 10,
                                                                marginRight: 10,
                                                                fontSize: 14,
                                                                selectableText: true,
                                                                urlDetectable: true,
                                                              ),
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  TextWithTap(
                                                                    chatMessage.createdAt !=
                                                                            null
                                                                        ? QuickHelp.getMessageTime(
                                                                            chatMessage
                                                                                .createdAt!,
                                                                            time:
                                                                                true)
                                                                        : "sending_"
                                                                            .tr(),
                                                                    color:
                                                                        kGrayColor,
                                                                    fontSize:
                                                                        12,
                                                                    marginRight:
                                                                        10,
                                                                    marginLeft:
                                                                        10,
                                                                    marginBottom:
                                                                        5,
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypeGif)
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              QuickActions.avatarWidget(mUser!,
                                                  width: 25, height: 25),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  gifMessage(chatMessage
                                                      .getGifMessage),
                                                  TextWithTap(
                                                    chatMessage.createdAt !=
                                                            null
                                                        ? QuickHelp
                                                            .getMessageTime(
                                                                chatMessage
                                                                    .createdAt!,
                                                                time: true)
                                                        : "sending_".tr(),
                                                    color: kGrayColor,
                                                    fontSize: 12,
                                                    marginRight: 10,
                                                    marginLeft: 10,
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypePicture)
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              QuickActions.avatarWidget(mUser!,
                                                  width: 25, height: 25),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  pictureMessage(chatMessage
                                                      .getPictureMessage),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      TextWithTap(
                                                        chatMessage.createdAt !=
                                                                null
                                                            ? QuickHelp
                                                                .getMessageTime(
                                                                    chatMessage
                                                                        .createdAt!,
                                                                    time: true)
                                                            : "sending_".tr(),
                                                        color: kGrayColor,
                                                        fontSize: 12,
                                                        marginRight: 10,
                                                        marginLeft: 10,
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                          ),
                        );
                      },
                      // optional
                      itemScrollController: listScrollController, // optional
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: QuickActions.noContentFound(
                          "message_screen.no_chat_title".tr(),
                          "message_screen.no_chat_explain".tr(),
                          "assets/svg/ic_tab_chat_default.svg"),
                    );
                  } else {
                    return Center(
                      child: QuickHelp.showLoadingAnimation(),
                    );
                  }
                }),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: chatInputField(),
        ),
      ],
    );
  }

  Widget chatInputField() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 20 / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 32,
            color: Color(0xFF087949).withOpacity(0.08),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.attach_file,
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .color!
                  .withOpacity(0.6),
              size: 35,
            ),
            onPressed: () => _showBottomSheet(context),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20 * 0.75,
              ),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autocorrect: false,
                      keyboardType: TextInputType.multiline,
                      onChanged: (text) {
                        setState(() {
                          changeButtonIcon(text);
                        });
                      },
                      maxLines: null,
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: "message_screen.type_message".tr(),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ContainerCorner(
            marginLeft: 10,
            color: sendButtonBackground,
            child: ContainerCorner(
              color: kTransparentColor,
              marginAll: 5,
              height: 30,
              width: 30,
              child: QuickActions.showSVGAsset(
                sendButtonIcon!,
                color: Colors.white,
                height: 10,
                width: 30,
              ),
            ),
            borderRadius: 50,
            height: 45,
            width: 45,
            onTap: () {
              if (messageController.text.isNotEmpty) {
                _saveMessage(messageController.text,
                    messageType: MessageModel.messageTypeText);
                setState(() {
                  messageController.text = "";
                  changeButtonIcon("");
                });
              } else {
                CoinsFlowPayment(
                  context: context,
                  currentUser: currentUser!,
                  showOnlyCoinsPurchase: false,
                  onCoinsPurchased: (coins) {
                    print(
                        "onCoinsPurchased: $coins new: ${currentUser!.getCredits}");
                  },
                  onGiftSelected: (gift) {
                    print("onGiftSelected called ${gift.getCoins}");
                    _checkAndSendGift(gift);
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  _checkAndSendGift(GiftsModel gift) async {
    if (currentUser!.getCredits! >= gift.getCoins!) {
      currentUser!.removeCredit = gift.getCoins!;
      ParseResponse saved = await currentUser!.save();
      if (saved.success) {
        QuickCloudCode.sendGift(author: mUser!, credits: gift.getCoins!, preferences: widget.preferences!);
        currentUser = saved.results!.first! as UserModel;

        _saveMessage(MessageModel.messageTypeGif,
            gif: gift.getFile!, messageType: MessageModel.messageTypeGif);
      }
    }
  }

  // Save the message
  _saveMessage(String messageText,
      {ParseFileBase? gif,
      required String messageType,
      ParseFileBase? pictureFile}) async {
    if (messageText.isNotEmpty) {
      MessageModel message = MessageModel();

      message.setAuthor = currentUser!;
      message.setAuthorId = currentUser!.objectId!;

      if (pictureFile != null) {
        message.setPictureMessage = pictureFile;
      }

      message.setReceiver = mUser!;
      message.setReceiverId = mUser!.objectId!;

      message.setDuration = messageText;
      message.setIsMessageFile = false;

      message.setMessageType = messageType;

      message.setIsRead = false;

      if (gif != null) {
        message.setGifMessage = gif;
      }

      setState(() {
        this.results.insert(0, message as dynamic);
      });

      await message.save();
      _saveList(message);

      SendNotifications.sendPush(
          currentUser!, mUser!, SendNotifications.typeChat,
          message: getMessageType(messageType, currentUser!.getFullName!,
              message: messageText));
    }
  }

  String getMessageType(String type, String name, {String? message}) {
    if (type == MessageModel.messageTypeGif) {
      return "push_notifications.new_gif_title".tr(namedArgs: {"name": name});
    } else if (type == MessageModel.messageTypePicture) {
      return "push_notifications.new_picture_title"
          .tr(namedArgs: {"name": name});
    } else {
      return message!;
    }
  }

  // Update or Create message list
  _saveList(MessageModel messageModel) async {
    QueryBuilder<MessageListModel> queryFrom =
        QueryBuilder<MessageListModel>(MessageListModel());
    queryFrom.whereEqualTo(
        MessageListModel.keyListId, currentUser!.objectId! + mUser!.objectId!);

    QueryBuilder<MessageListModel> queryTo =
        QueryBuilder<MessageListModel>(MessageListModel());
    queryTo.whereEqualTo(
        MessageListModel.keyListId, mUser!.objectId! + currentUser!.objectId!);

    QueryBuilder<MessageListModel> queryBuilder =
        QueryBuilder.or(MessageListModel(), [queryFrom, queryTo]);

    ParseResponse parseResponse = await queryBuilder.query();

    if (parseResponse.success) {
      if (parseResponse.results != null) {
        MessageListModel messageListModel = parseResponse.results!.first;

        messageListModel.setAuthor = currentUser!;
        messageListModel.setAuthorId = currentUser!.objectId!;

        messageListModel.setReceiver = mUser!;
        messageListModel.setReceiverId = mUser!.objectId!;

        messageListModel.setMessage = messageModel;
        messageListModel.setMessageId = messageModel.objectId!;
        messageListModel.setText = messageModel.getDuration!;
        messageListModel.setIsMessageFile = false;

        messageListModel.setMessageType = messageModel.getMessageType!;

        messageListModel.setIsRead = false;
        messageListModel.setListId = currentUser!.objectId! + mUser!.objectId!;

        messageListModel.incrementCounter = 1;
        await messageListModel.save();

        messageModel.setMessageList = messageListModel;
        messageModel.setMessageListId = messageListModel.objectId!;

        await messageModel.save();
      } else {
        MessageListModel messageListModel = MessageListModel();

        messageListModel.setAuthor = currentUser!;
        messageListModel.setAuthorId = currentUser!.objectId!;

        messageListModel.setReceiver = mUser!;
        messageListModel.setReceiverId = mUser!.objectId!;

        messageListModel.setMessage = messageModel;
        messageListModel.setMessageId = messageModel.objectId!;
        messageListModel.setText = messageModel.getDuration!;
        messageListModel.setIsMessageFile = false;

        messageListModel.setMessageType = messageModel.getMessageType!;

        messageListModel.setListId = currentUser!.objectId! + mUser!.objectId!;
        messageListModel.setIsRead = false;

        messageListModel.incrementCounter = 1;
        await messageListModel.save();

        messageModel.setMessageList = messageListModel;
        messageModel.setMessageListId = messageListModel.objectId!;
        await messageModel.save();
      }
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Color.fromRGBO(0, 0, 0, 0.001),
            child: GestureDetector(
              onTap: () {},
              child: DraggableScrollableSheet(
                initialChildSize: 0.67,
                minChildSize: 0.1,
                maxChildSize: 1.0,
                builder: (_, controller) {
                  return StatefulBuilder(builder: (context, setState) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(25.0),
                          topRight: const Radius.circular(25.0),
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Icon(
                              Icons.remove,
                              color: Colors.grey[600],
                            ),
                            ContainerCorner(
                              color: kGreyColor0,
                              width: 400,
                              height: 400,
                              borderRadius: 10,
                              child: uploadPhoto == null
                                  ? Icon(
                                      Icons.camera_alt,
                                      color: kPrimaryColor,
                                      size: 80,
                                    ) : uploadPhoto is File ? Image.file(File(uploadPhoto)) : Image.memory(uploadPhoto),
                              onTap: () => _choosePhoto(setState),
                            ),
                            Column(
                              children: [
                                ButtonWithGradient(
                                  marginTop: 10,
                                  height: 50,
                                  borderRadius: 20,
                                  text: "message_screen.send_".tr() +
                                      " " +
                                      _countSelectedPictures.toString() +
                                      " " +
                                      "message_screen.file_".tr(),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  textColor: Colors.white,
                                  onTap: () {
                                    if (parseFile != null) {
                                      _saveMessage(
                                          MessageModel.messageTypePicture,
                                          messageType:
                                              MessageModel.messageTypePicture,
                                          pictureFile: parseFile);
                                      parseFile = null;
                                      uploadPhoto = null;
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  beginColor: kWarninngColor,
                                  endColor: kPrimaryColor,
                                ),
                                ContainerCorner(
                                  height: 50,
                                  color: kTransparentColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget gifMessage(ParseFileBase? gifMessage) {
    return Column(
      children: [
        ContainerCorner(
          color: kTransparentColor,
          borderRadius: 20,
          child: Column(
            children: [
              ContainerCorner(
                color: kTransparentColor,
                marginTop: 5,
                marginLeft: 5,
                marginRight: 5,
                height: 160,
                width: 170,
                marginBottom: 5,
                borderRadius: 20,
                child: Lottie.network(gifMessage!.url!,
                    width: 170, height: 160, animate: true, repeat: true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String voiceStatus(CallsModel call) {
    String response = "";

    if (!call.getAccepted! && call.getAuthorId! != currentUser!.objectId!) {
      response = "message_screen.missed_call".tr();
    } else if (call.getAuthorId != currentUser!.objectId!) {
      response = "message_screen.out_going_call".tr();
    } else if (call.getAuthorId == currentUser!.objectId!) {
      response = "message_screen.incoming_call".tr();
    }
    return response;
  }

  Widget callMessage(MessageModel messageModel, bool isMe) {
    return Column(
      children: [
        ContainerCorner(
          color: kTransparentColor,
          borderRadius: 20,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ContainerCorner(
                marginRight: 50,
                marginLeft: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: !messageModel.getCall!.getAccepted! &&
                          messageModel.getCall!.getAuthorId! != currentUser!.objectId!,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.call_received,
                            color: Colors.red,
                          ),
                          TextWithTap(
                            "message_screen.missed_call".tr(),
                            color: Colors.red,
                            marginLeft: 10,
                          )
                        ],
                      ),
                    ),
                    Visibility(
                      visible: !messageModel.getCall!.getAccepted! &&
                          messageModel.getCall!.getAuthorId! == currentUser!.objectId!,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.call_made,
                            color: Colors.red,
                          ),
                          TextWithTap(
                            "message_screen.missed_call".tr(),
                            color: Colors.red,
                            marginLeft: 10,
                          )
                        ],
                      ),
                    ),
                    Visibility(
                      visible: messageModel.getCall!.getAccepted! && messageModel.getCall!.getAuthorId == currentUser!.objectId!,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.call_made,
                            color: isMe ? Colors.white : Colors.black,
                          ),
                          TextWithTap(
                            "message_screen.out_going_call".tr(),
                            color: Colors.white,
                            marginLeft: 10,
                          )
                        ],
                      ),
                    ),
                    Visibility(
                      visible: messageModel.getCall!.getAccepted! && messageModel.getCall!.getAuthorId != currentUser!.objectId!,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.call_received,
                            color: isMe ? Colors.white : Colors.black,
                          ),
                          TextWithTap("message_screen.incoming_call".tr(),
                            color: isMe ? Colors.white : Colors.black,
                            marginLeft: 10,
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        TextWithTap(
                          QuickHelp.getMessageTime(messageModel.createdAt!, time: true),
                          marginRight: 10,
                          color: isMe ? Colors.white : Colors.black,
                        ),
                        Visibility(
                          visible: messageModel.getCall!.getAccepted!,
                          child: TextWithTap(
                            messageModel.getCall!.getDuration!,
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              ContainerCorner(
                color: kGrayColor,
                height: 50,
                marginBottom: 5,
                marginRight: 2,
                marginTop: 5,
                borderRadius: 70,
                child: Center(
                    child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(
                    messageModel.getCall!.getIsVoiceCall! ? Icons.phone : Icons.videocam,
                    color: Colors.white,
                    size: 25,
                  ),
                )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget callInfo(bool appear, IconData icon, String text){
    return Visibility(
      visible: appear,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.red,
          ),
          TextWithTap(
            text,
            color: Colors.red,
            marginLeft: 10,
          )
        ],
      ),
    );
  }

  Widget pictureMessage(ParseFileBase picture) {
    return Column(
      children: [
        ContainerCorner(
          color: kTransparentColor,
          borderRadius: 20,
          onTap: () => openPicture(picture),
          child: Column(
            children: [
              ContainerCorner(
                color: kTransparentColor,
                marginTop: 5,
                marginLeft: 5,
                marginRight: 5,
                height: 200,
                width: 200,
                marginBottom: 5,
                child: QuickActions.photosWidget(
                    picture.saved ? picture.url : "",
                    borderRadius: 20,
                    fit: BoxFit.cover,
                    width: 200,
                    height: 200),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _showMessagePictureBottomSheet(ParseFileBase picture) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: DraggableScrollableSheet(
            initialChildSize: 1.0,
            minChildSize: 0.1,
            maxChildSize: 1.0,
            builder: (_, controller) {
              return StatefulBuilder(builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                  ),
                  child: ContainerCorner(
                    color: kTransparentColor,
                    height: MediaQuery.of(context).size.height - 200,
                    child: QuickActions.photosWidget(picture.url,
                        borderRadius: 5, fit: BoxFit.contain),
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }
}
