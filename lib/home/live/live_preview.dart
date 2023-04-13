import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mime/mime.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teego/helpers/quick_actions.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/models/HashTagsModel.dart';
import 'package:teego/models/LiveStreamingModel.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/app_bar.dart';
import 'package:teego/ui/button_with_gradient.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../app/constants.dart';
import '../../app/setup.dart';
import 'live_streaming_screen.dart';

// ignore: must_be_immutable
class LivePreviewScreen extends StatefulWidget {
  UserModel? currentUser;

  LivePreviewScreen({
    Key? key,
    this.currentUser,
  }) : super(key: key);

  static String route = "/live/preview";

  @override
  _LivePreviewScreenState createState() => _LivePreviewScreenState();
}

class _LivePreviewScreenState extends State<LivePreviewScreen>
    with TickerProviderStateMixin {
  String? _privacySelection = LiveStreamingModel.privacyTypeAnyone;

  List<dynamic> list = [], selected = [];
  List<HashTagModel> selectedHashTags = [];

  //List<dynamic> hashTagsListFromServer = <dynamic>[];
  //List<HashTagModel> hashTagsListPointer = <HashTagModel>[];

  TextEditingController hashTagsEditTextController = TextEditingController();

  bool partyBtnSelected = false;
  bool goLiveBtnSelected = true;
  bool battleBtnSelected = false;

  bool isFirstTime = false;

  ParseFileBase? parseFile;
  String? parseFileUrl;

  late SharedPreferences preferences;

  @override
  void initState() {
    super.initState();

    initSharedPref();

    isFirstLive();
  }

  Future<List<dynamic>?> loadHashTags() async {
    QueryBuilder<HashTagModel> queryBuilder =
        QueryBuilder<HashTagModel>(HashTagModel());
    queryBuilder.orderByDescending(HashTagModel.keyCount);
    queryBuilder.whereNotContainedIn(HashTagModel.keyTag, selected);
    queryBuilder.setLimit(40);

    ParseResponse response = await queryBuilder.query();

    if (response.success) {
      print("HasTags count: ${response.results!.length}");
      if (response.results != null) {
        list = response.results!;
        return response.results;
      } else {
        return AsyncSnapshot.nothing() as dynamic;
      }
    } else {
      return response.error as dynamic;
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    void openTags() async {
      showModalBottomSheet(
          context: (context),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          enableDrag: true,
          isDismissible: true,
          builder: (context) {
            return _showTagsBottomSheet();
          });
    }

    return ToolBar(
      backgroundColor: kTransparentColor,
      extendBodyBehindAppBar: true,
      leftButtonIcon:
          QuickHelp.isIOSPlatform() ? Icons.arrow_back_ios : Icons.arrow_back,
      onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
      //rightButtonAsset: "ic_settings_menu.svg",
      //rightButtonPress: () => openSettingsOptions(),
      child: Stack(children: [
        ContainerCorner(
          borderWidth: 0,
          color: kTransparentColor,
          child: QuickActions.photosWidget(
              widget.currentUser!.getAvatar != null
                  ? widget.currentUser!.getAvatar!.url!
                  : "null",
              borderRadius: 10),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ContainerCorner(
            height: size.height / 3,
            width: size.width,
            colors: [
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.01)
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        Center(
          child: ContainerCorner(
            onTap: () => checkPermission(true),
            color:  Colors.white,
            child: Stack(
              children: [
                Center(
                  child: parseFileUrl != null ? QuickActions.photosWidget(
                    parseFileUrl,
                    borderRadius: 8,
                  ) : Container(
                    child: Icon(Icons.image, size: 100,),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ContainerCorner(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: 20,
                        marginTop: 5,
                        marginBottom: 5,
                        child: TextWithTap(
                          "change_".tr(),
                          marginLeft: 10,
                          marginRight: 10,
                          marginBottom: 5,
                          marginTop: 5,
                          color: Colors.white,
                          fontSize: 16,
                          onTap: () => checkPermission(true),
                        ),
                      ),
                      Divider(),
                      Visibility(
                        visible: false,
                        child: ContainerCorner(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: 20,
                          marginTop: 5,
                          marginBottom: 5,
                          onTap: () => _randomImage(),
                          child: TextWithTap(
                            "random_".tr(),
                            marginLeft: 10,
                            marginRight: 10,
                            marginBottom: 5,
                            marginTop: 5,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            borderRadius: 10,
            height: 200,
            width: 200,
            marginRight: 15,
            marginLeft: 10,
            shadowColor: Colors.black,
            shadowColorOpacity: 0.4,
          ),
        ),
        Positioned(
          bottom: 50,
          child: Column(
            children: [
              Container(
                alignment: Alignment.bottomCenter,
                width: size.width,
                child: ContainerCorner(
                  marginTop: 10,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Visibility(
                          visible: selected.isEmpty,
                          child: Column(
                            children: [
                              ContainerCorner(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: 20,
                                onTap: () {
                                  openTags();
                                },
                                child: TextWithTap(
                                  "live_streaming.add_hashtag".tr(),
                                  color: Colors.white,
                                  marginLeft: 15,
                                  marginRight: 15,
                                  marginTop: 5,
                                  marginBottom: 5,
                                ),
                              ),
                              TextWithTap(
                                "live_streaming.to_get_more_viewers".tr(),
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: selected.isNotEmpty,
                          child: Wrap(
                              crossAxisAlignment:
                                  WrapCrossAlignment.start,
                              spacing: 5,
                              runSpacing: 1,
                              children: selected.map((s) {
                                return TextWithTap(
                                  "#" + s,
                                  fontSize: 16,
                                  color: Colors.white,
                                  onTap: () => openTags(),
                                );
                              }).toList()),
                        ),
                        Visibility(
                          visible: selected.isNotEmpty,
                          child: Container(
                            margin: EdgeInsets.only(right: 20),
                            child: TextField(
                              autocorrect: false,
                              readOnly: true,
                              onTap: () => openTags(),
                              decoration: InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.edit,
                                    color: Colors.white.withOpacity(0.5),
                                    size: 18,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white
                                            .withOpacity(0.3)),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white
                                            .withOpacity(0.3)),
                                  ),
                                  focusColor: Colors.white,
                                  fillColor: Colors.white,
                                  hintStyle: TextStyle(
                                      color:
                                          Colors.white.withOpacity(0.5))),
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  /*ContainerCorner(
                    height: 40,
                    borderRadius: 50,
                    marginTop: 10,
                    marginRight: 10,
                    onTap: () {
                      selectButton(LiveStreamingModel.liveTypeParty);
                    },
                    colors: [
                      partyBtnSelected ? kWarninngColor : kTransparentColor,
                      partyBtnSelected ? kPrimaryColor : kTransparentColor,
                    ],
                    child: TextButton(
                      onPressed: (){
                        selectButton(LiveStreamingModel.liveTypeParty);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(partyBtnSelected)
                          Icon(Icons.camera_alt_outlined, color: Colors.white,size: 18,),
                          TextWithTap("live_streaming.btn_party".tr().toUpperCase(),color: Colors.white, marginLeft: 10,)
                        ],
                      ),
                    ),
                  ),*/
                  ButtonWithGradient(
                    height: 50,
                    width: size.width / 2,
                    marginTop: 10,
                    marginRight: 10,
                    borderRadius: 50,
                    svgURL: "assets/svg/ic_tab_live_selected.svg",
                    onTap: () {
                      if (parseFileUrl != null) {
                        createLive();
                      } else {
                        QuickHelp.showAppNotificationAdvanced(
                            context: context,
                            title: "live_streaming.live_set_cover_photo".tr(),
                            message:
                                "live_streaming.live_set_cover_photo_add".tr(),
                            isError: true);
                      }

                      //selectButton(LiveStreamingModel.liveTypeGoLive);
                    },
                    text: "live_streaming.btn_go_live".tr().toUpperCase(),
                    beginColor:
                        goLiveBtnSelected ? kWarninngColor : kTransparentColor,
                    endColor:
                        goLiveBtnSelected ? kPrimaryColor : kTransparentColor,
                    /*colors: [
                      goLiveBtnSelected ? kWarninngColor : kTransparentColor,
                      goLiveBtnSelected ? kPrimaryColor : kTransparentColor,
                    ],*/
                    /*child: TextButton(
                      onPressed: (){
                        selectButton(LiveStreamingModel.liveTypeGoLive);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(goLiveBtnSelected)
                          //Icon(Icons.camera_alt_outlined, color: Colors.white,size: 18,),
                            SvgPicture.asset("assets/svg/ic_tab_live_selected.svg", color: Colors.white,),
                          TextWithTap("live_streaming.btn_go_live".tr().toUpperCase(),color: Colors.white, marginLeft: 10, marginRight: 10,)
                        ],
                      ),
                    ),*/
                  ),
                  /*ContainerCorner(
                    height: 40,
                    borderRadius: 50,
                    marginTop: 10,
                    marginRight: 10,
                    onTap: (){
                      selectButton(LiveStreamingModel.liveTypeBattle);
                    },
                    colors: [
                      battleBtnSelected ? kWarninngColor : kTransparentColor,
                      battleBtnSelected ? kPrimaryColor : kTransparentColor,
                    ],
                    child: TextButton(
                      onPressed: (){
                        selectButton(LiveStreamingModel.liveTypeBattle);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(battleBtnSelected)
                          //Icon(Icons.camera_alt_outlined, color: Colors.white,size: 18,),
                            SvgPicture.asset("assets/svg/ic_tab_live_selected.svg", color: Colors.white,),
                          TextWithTap("live_streaming.btn_battle".tr().toUpperCase(),color: Colors.white, marginLeft: 10,)
                        ],
                      ),
                    ),
                  ),*/
                ],
              )
            ],
          ),
        ),
      ]),
    );
  }

  Widget _showTagsBottomSheet() {
    return GestureDetector(
      onTap: () {
        //Navigator.of(context).pop();
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: DraggableScrollableSheet(
            initialChildSize: 0.96,
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
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: Scaffold(
                      appBar: AppBar(
                        backgroundColor: kTransparentColor,
                        automaticallyImplyLeading: true,
                        leading: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 18,
                          ),
                        ),
                      ),
                      backgroundColor: kTransparentColor,
                      body: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ContainerCorner(
                            color: kTransparentColor,
                            child: QuickActions.photosWidget(
                                parseFileUrl != null
                                    ? parseFileUrl
                                    : widget.currentUser!.getAvatar!.url!,
                                borderRadius: 10),
                            borderRadius: 10,
                            height: 100,
                            width: 100,
                            marginRight: 15,
                            marginLeft: 10,
                          ),
                          Expanded(
                            child: ContainerCorner(
                              marginTop: 10,
                              child: Column(
                                  //mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Visibility(
                                          visible: selected.isNotEmpty,
                                          child: Wrap(
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.start,
                                              spacing: 5,
                                              runSpacing: 1,
                                              children: selected.map((s) {
                                                return Chip(
                                                    backgroundColor:
                                                        Colors.black,
                                                    clipBehavior: Clip.none,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              70),
                                                    ),
                                                    label: Text("#" + s,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                    deleteIcon: Icon(
                                                        Icons.close,
                                                        size: 15),
                                                    deleteIconColor: Colors
                                                        .white
                                                        .withOpacity(0.5),
                                                    onDeleted: () {
                                                      this.setState(() {
                                                        selected = selected;
                                                        //list = list;
                                                      });

                                                      setState(() {
                                                        selected.remove(s);
                                                        //list.add(s);
                                                      });
                                                    });
                                              }).toList()),
                                        ),
                                        TextField(
                                          autocorrect: false,
                                          controller:
                                              hashTagsEditTextController,
                                          obscureText: false,
                                          textInputAction: TextInputAction.send,
                                          onChanged: (text) {
                                            if (text.isNotEmpty &&
                                                text.startsWith(" ")) {
                                              hashTagsEditTextController
                                                  .clear();
                                            } else if (text.isNotEmpty &&
                                                text.length > 1 &&
                                                text.contains(" ")) {
                                              updateStatesTextField(setState);
                                            }
                                          },
                                          decoration: InputDecoration(
                                              hintText:
                                                  "live_streaming.hint_add_hashtag"
                                                      .tr(),
                                              prefix: TextWithTap(
                                                "#",
                                                color: Colors.white,
                                              ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white
                                                        .withOpacity(0.3)),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white
                                                        .withOpacity(0.3)),
                                              ),
                                              focusColor: Colors.white,
                                              fillColor: Colors.white,
                                              hintStyle: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.5))),
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                          onEditingComplete: () {
                                            _saveHashTags(
                                                hashTagsEditTextController
                                                    .text);
                                            updateStatesTextField(setState);
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      margin: EdgeInsets.only(right: 10),
                                      child: FutureBuilder<List<dynamic>?>(
                                        future: loadHashTags(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot snapshot) {
                                          if (snapshot.hasData) {
                                            return Wrap(
                                              spacing: 10.0,
                                              // gap between adjacent chips
                                              runSpacing: 15.0,
                                              alignment: WrapAlignment.start,
                                              children: List.generate(
                                                  list.length, (index) {
                                                String hashtag =
                                                    list[index]["hashtag"];
                                                HashTagModel hashtagModel =
                                                    list[index];

                                                return TextWithTap(
                                                  "#" + hashtag,
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                  fontSize: 16,
                                                  onTap: () {
                                                    this.setState(() {
                                                      selected = selected;
                                                    });

                                                    setState(() {
                                                      if (selected
                                                          .contains(hashtag)) {
                                                        selectedHashTags.remove(
                                                            hashtagModel);
                                                        selected
                                                            .remove(hashtag);
                                                        _incrementTagsCount(
                                                            hashtag, true);
                                                      } else {
                                                        selected.add(hashtag);
                                                        selectedHashTags
                                                            .add(hashtagModel);
                                                        _incrementTagsCount(
                                                            hashtag, false);
                                                      }
                                                    });
                                                  },
                                                );
                                              }),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        },
                                      ),
                                    ),
                                  ]),
                            ),
                          )
                        ],
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

  _saveHashTags(String hashTag) async {
    HashTagModel hashTagsModel = HashTagModel();

    QueryBuilder<HashTagModel> queryOldTags =
        QueryBuilder<HashTagModel>(HashTagModel());
    queryOldTags.whereEqualTo(HashTagModel.keyTag, hashTag);

    ParseResponse response = await queryOldTags.query();

    if (response.success) {
      if (response.results == null) {
        hashTagsModel.setHashTag = hashTag;
        hashTagsModel.setCount = 1;
        hashTagsModel.setActive = true;

        await hashTagsModel.save();
      }
    }
  }

  _incrementTagsCount(String hashTag, bool remove) async {
    QueryBuilder<HashTagModel> queryOldTags =
        QueryBuilder<HashTagModel>(HashTagModel());
    queryOldTags.whereEqualTo(HashTagModel.keyTag, hashTag);

    ParseResponse response = await queryOldTags.query();

    if (response.success) {
      if (response.results != null) {
        HashTagModel hashTagModel = response.results!.first;

        if (remove == true) {
          hashTagModel.removeCount = 1;
        } else {
          hashTagModel.setCount = 1;
        }

        hashTagModel.setActive = true;
        await hashTagModel.save();
      }
    }
  }

  updateStatesTextField(StateSetter setState) {
    setState(() {
      if (hashTagsEditTextController.text.isNotEmpty &&
          !selected.contains(hashTagsEditTextController.text)) {
        selected.add(hashTagsEditTextController.text.replaceAll("#", ""));
        hashTagsEditTextController.clear();
      }
    });

    this.setState(() {
      selected = selected;
    });
  }

  Row whoCanSeeFilters(String gender, String text, String selected) {
    return Row(
      children: [
        Radio(
            activeColor: kPrimaryColor,
            value: gender,
            groupValue: _privacySelection,
            onChanged: (String? value) {
              setState(() {
                _privacySelection = value;
                widget.currentUser!.setGender = gender;
                //currentUser!.save();
              });
            }),
        SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _privacySelection = gender;
              widget.currentUser!.setGender = gender;
              //currentUser!.save();
            });
          },
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: selected == gender ? Colors.white : kGrayColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void isFirstLive() async {
    QueryBuilder<LiveStreamingModel> queryBuilder =
        QueryBuilder(LiveStreamingModel());
    queryBuilder.whereEqualTo(
        LiveStreamingModel.keyAuthorId, widget.currentUser!.objectId);

    ParseResponse parseResponse = await queryBuilder.count();

    if (parseResponse.success) {
      if (parseResponse.count > 0) {
        isFirstTime = false;
      } else {
        isFirstTime = true;
      }
    }
  }

  void createLive() async {
    QuickHelp.showLoadingDialog(context, isDismissible: false);

    QueryBuilder<LiveStreamingModel> queryBuilder =
        QueryBuilder(LiveStreamingModel());
    queryBuilder.whereEqualTo(
        LiveStreamingModel.keyAuthorId, widget.currentUser!.objectId);
    queryBuilder.whereEqualTo(LiveStreamingModel.keyStreaming, true);

    ParseResponse parseResponse = await queryBuilder.query();
    if (parseResponse.success) {
      if (parseResponse.results != null) {
        LiveStreamingModel live =
            parseResponse.results!.first! as LiveStreamingModel;

        live.setStreaming = false;
        await live.save();

        createLiveFinish();
      } else {
        createLiveFinish();
      }
    } else {
      QuickHelp.hideLoadingDialog(context);

      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "live_streaming.live_set_cover_error".tr(),
          message: parseResponse.error!.message,
          isError: true,
          user: widget.currentUser);
    }
  }

  createLiveFinish() async {
    LiveStreamingModel streamingModel = LiveStreamingModel();
    if( Setup.isDebug) print("Check live 1");
    streamingModel.setStreamingChannel = widget.currentUser!.objectId! + widget.currentUser!.getUid!.toString();
    if( Setup.isDebug) print("Check live 2");
    streamingModel.setAuthor = widget.currentUser!;
    if( Setup.isDebug) print("Check live 3");
    streamingModel.setAuthorId = widget.currentUser!.objectId!;
    if( Setup.isDebug) print("Check live 4");
    streamingModel.setAuthorUid = widget.currentUser!.getUid!;
    if( Setup.isDebug) print("Check live 5");
    streamingModel.addAuthorTotalDiamonds =
        widget.currentUser!.getDiamondsTotal!;
    if( Setup.isDebug) print("Check live 6");
    streamingModel.setFirstLive = isFirstTime;
    if( Setup.isDebug) print("Check live 7");

    streamingModel.setImage = parseFile!;
    if( Setup.isDebug) print("Check live 8");

    if (widget.currentUser!.getGeoPoint != null) {
      if( Setup.isDebug) print("Check live 9");
      streamingModel.setStreamingGeoPoint = widget.currentUser!.getGeoPoint!;
    }

    if( Setup.isDebug) print("Check live 10");
    if (selected.length > 0){
      if( Setup.isDebug) print("Check live 11");
      streamingModel.setHashtags = selectedHashTags; //List<HashTagModel>;
    }

    if( Setup.isDebug) print("Check live 12");
    streamingModel.setPrivate = false;
    if( Setup.isDebug) print("Check live 3");
    streamingModel.setStreaming = false;
    if( Setup.isDebug) print("Check live 14");
    streamingModel.addViewersCount = 0;
    if( Setup.isDebug) print("Check live 15");
    streamingModel.addDiamonds = 0;
    if( Setup.isDebug) print("Check live 16");

    streamingModel.save().then((value){
      if( Setup.isDebug) print("Check live 17");

      if (value.success) {

        LiveStreamingModel liveStreaming = value.results!.first!;

        QuickHelp.hideLoadingDialog(context);

        QuickHelp.goToNavigatorScreen(
          context,
          LiveStreamingScreen(
            channelName: streamingModel.getStreamingChannel!,
            isBroadcaster: true,
            preferences: preferences,
            currentUser: widget.currentUser!,
            mLiveStreamingModel: liveStreaming,
          ),
        );

        selected.clear();
        selectedHashTags.clear();
      } else {

        QuickHelp.hideLoadingDialog(context);

        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "live_streaming.live_set_cover_error".tr(),
            message: value.error!.message,
            isError: true,
            user: widget.currentUser);

      }

      if( Setup.isDebug) print("Check live 17 (1)");
    }).onError((ParseError error, stackTrace) {
      if (Setup.isDebug) print("Check live 18");

      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "live_streaming.live_set_cover_error".tr(),
          message: "unknown_error".tr(),
          isError: true,
          user: widget.currentUser);

    }).catchError((err) {
      if (Setup.isDebug) print("Check live 19: $err");

      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "live_streaming.live_set_cover_error".tr(),
          message: "unknown_error".tr(),
          isError: true,
          user: widget.currentUser);
    });
  }

  _randomImage() async {
    QuickHelp.showLoadingDialog(context);

    List<String> keywords = [];

    if (widget.currentUser!.getGender! == UserModel.keyGenderMale) {
      keywords = ["sexy male", "male model"];
    } else if (widget.currentUser!.getGender! == UserModel.keyGenderFemale) {
      keywords = ["sexy female", "female model"];
    } else {
      keywords = ["model", "sexy"];
    }

    var faker = Faker();
    String imageUrl = faker.image
        .image(width: 640, height: 640, keywords: keywords, random: true);

    File avatar = await QuickHelp.downloadFile(imageUrl, "avatar.jpeg") as File;

    if (QuickHelp.isWebPlatform()) {
      //Seems weird, but this lets you get the data from the selected file as an Uint8List very easily.
      ParseWebFile file =
          ParseWebFile(null, name: "avatar.jpeg", url: avatar.path);
      await file.download();
      parseFile = ParseWebFile(file.file, name: file.name);
    } else {
      parseFile = ParseFile(File(avatar.path));
    }

    QuickHelp.hideLoadingDialog(context);

    setState(() {
      parseFileUrl = imageUrl;
    });
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

      _pickFile(isAvatar);
      //_choosePhoto(isAvatar);
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
              //_choosePhoto(isAvatar);
              _pickFile(isAvatar);
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
      //_choosePhoto(isAvatar);
      _pickFile(isAvatar);
    }

    print('Permission $status');
    print('Permission $status2');
  }

 /* _choosePhoto(bool isAvatar) async {
    final ImagePicker _picker = ImagePicker();

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      cropPhoto(image.path, isAvatar);
    } else {
      print("Photos null");
    }
  }*/

  _pickFile(bool isAvatar) async {
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
      final File? file = await result.first.file;
      final preview = await result.first.thumbnailData;

      print(preview != null ? "selected video" : "Selected Image");

      String? mimeStr = lookupMimeType(file!.path);
      var fileType = mimeStr!.split('/');

      print('Selected file type $fileType');

      if (fileType.contains("video")) {
        //isVideo = true;
        //print('Selected file is video $isVideo');
        //uploadVideo(file.path, preview!, setState);
        //prepareVideo(file, preview!, setState);
      } else if (fileType.contains("image")) {
        //isVideo = false;
        //print('Selected file is video $isVideo');
        cropPhoto(file.path, isAvatar);
      }
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

      compressImage(croppedFile.path, isAvatar);

    } else {
      QuickHelp.hideLoadingDialog(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "crop_image_scree.cancelled_by_user".tr(),
        message: "crop_image_scree.image_not_cropped_error".tr(),
      );

      return;
    }
  }

  void compressImage(String path, bool isAvatar) {

    QuickHelp.showLoadingAnimation();

    Future.delayed(Duration(seconds: 1), () async{
      var result = await QuickHelp.compressImage(path);

      if(result != null){

        if (QuickHelp.isWebPlatform()) {
          //Seems weird, but this lets you get the data from the selected file as an Uint8List very easily.
          ParseWebFile file =
          ParseWebFile(null, name: "avatar.jpg", url: result.absolute.path);
          await file.download();
          parseFile = ParseWebFile(file.file, name: file.name);
        } else {
          parseFile = ParseFile(File(result.absolute.path), name: "avatar.jpg");
        }

        ParseResponse parseResponse = await parseFile!.save();

        if(parseResponse.success){

          QuickHelp.hideLoadingDialog(context);

          setState(() {
            parseFileUrl = parseFile!.url;
          });

        } else {

          QuickHelp.hideLoadingDialog(context);
          QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "try_again_later".tr(),
          );
        }

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

  initSharedPref() async {
    preferences = await SharedPreferences.getInstance();
    Constants.queryParseConfig(preferences);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
