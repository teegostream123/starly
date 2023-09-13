import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teego/helpers/quick_actions.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/models/LeadersModel.dart';
import 'package:teego/models/others/leaders_count_model.dart';
import 'package:teego/ui/app_bar.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';

import '../../helpers/quick_cloud.dart';
import '../../models/GiftsSentModel.dart';
import '../../models/NotificationsModel.dart';
import '../../models/UserModel.dart';
import '../message/message_screen.dart';

// ignore: must_be_immutable
class GiftersScreen extends StatefulWidget {

  static String route = "/menu/gifters";

  UserModel? currentUser;
  GiftersScreen({this.currentUser});

  @override
  _GiftersScreenState createState() => _GiftersScreenState();
}

class _GiftersScreenState extends State<GiftersScreen> {

  List<LeadersCountModel> leadersList = [];

  String giftersPeriodDaily = "daily";
  String giftersPeriodWeekly = "weekly";
  String giftersPeriodAllTime = "all";

  @override
  Widget build(BuildContext context) {
    return ToolBar(
      title: "page_title.gifters_title".tr(),
      centerTitle: QuickHelp.isAndroidPlatform() ? false : true,
      leftButtonIcon: Icons.arrow_back_ios,
      onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
      child: SafeArea(
        child: body(),
      ),
    );
  }

  Widget body(){
    return ContainerCorner(
      color: kTransparentColor,
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  ContainerCorner(
                    color: kTransparentColor,
                    height: 30,
                    child: TabBar(
                      isScrollable: true,
                      enableFeedback: false,
                      indicatorColor: kPrimaryColor,
                      indicatorWeight: 2,
                      unselectedLabelColor: kGrayColor,
                      labelColor: Colors.black,
                      tabs: [
                        TextWithTap("leaders.menu_daily".tr()),
                        TextWithTap("leaders.menu_weekly".tr()),
                        TextWithTap("leaders.menu_all_times".tr()),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ContainerCorner(
                      height: MediaQuery.of(context).size.height,
                      color: kTransparentColor,
                      child: TabBarView(children: [
                        initQuery(giftersPeriodDaily),
                        initQuery(giftersPeriodWeekly),
                        initQuery(giftersPeriodAllTime),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>?> _loadLeaders(String type) async {

    QueryBuilder<GiftsSentModel> queryBuilderGifts = QueryBuilder<GiftsSentModel>(GiftsSentModel());
    queryBuilderGifts.whereEqualTo(GiftsSentModel.keyReceiverId, widget.currentUser!.objectId!);


    if(type == giftersPeriodDaily){
      queryBuilderGifts.whereGreaterThanOrEqualsTo(GiftsSentModel.keyCreatedAt, DateTime.now().subtract(Duration(days: 1)));

    } else if(type == giftersPeriodWeekly){
      queryBuilderGifts.whereGreaterThanOrEqualsTo(GiftsSentModel.keyCreatedAt, DateTime.now().subtract(Duration(days: 7)));

    } else if(type == giftersPeriodAllTime){
      queryBuilderGifts.whereValueExists(GiftsSentModel.keyDiamondsQuantity, true);
    }

    queryBuilderGifts.includeObject([
      LeadersModel.keyAuthor,
    ]);

    queryBuilderGifts.orderByDescending(GiftsSentModel.keyCreatedAt);

    ParseResponse apiResponse = await queryBuilderGifts.query();
    if (apiResponse.success) {
      //print("Messages count: ${apiResponse.results!.length}");
      if (apiResponse.results != null) {

        return apiResponse.results;

      } else {
        return apiResponse.result;
      }
    } else {
      return apiResponse.error as dynamic;
    }
  }


  Widget initQuery(String type) {

    /*QueryBuilder<GiftsSentModel> queryBuilderGifts = QueryBuilder<GiftsSentModel>(GiftsSentModel());
    //queryBuilderGifts.whereEqualTo(GiftsSentModel.keyReceiverId, widget.currentUser!.objectId!);


    if(type == giftersPeriodDaily){
      queryBuilderGifts.whereGreaterThanOrEqualsTo(GiftsSentModel.keyCreatedAt, DateTime.now().subtract(Duration(days: 1)));

    } else if(type == giftersPeriodWeekly){
      queryBuilderGifts.whereGreaterThanOrEqualsTo(GiftsSentModel.keyCreatedAt, DateTime.now().subtract(Duration(days: 7)));

    } else if(type == giftersPeriodAllTime){
      queryBuilderGifts.whereValueExists(GiftsSentModel.keyDiamondsQuantity, true);
    }

    queryBuilderGifts.includeObject([
      LeadersModel.keyAuthor,
    ]);

    queryBuilderGifts.orderByDescending(GiftsSentModel.keyCreatedAt);

    return ParseLiveListWidget<GiftsSentModel>(
      query: queryBuilderGifts,
      reverse: false,
      lazyLoading: false,
      duration: Duration(seconds: 0),
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<GiftsSentModel> snapshot) {
        if (snapshot.hasData) {

          GiftsSentModel leader = snapshot.loadedData!;

          return ContainerCorner(
            color: kTransparentColor,
            marginLeft: 20,
            marginRight: 10,
            marginTop: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Row(
                          children: [
                            Stack(children: [
                              QuickActions.avatarWidget(leader.getAuthor!,
                                  width: 40, height: 40),
                              Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: ContainerCorner(
                                    width: 15,
                                    height: 15,
                                    borderRadius: 50,
                                    color: kRedColor1,
                                  )),
                            ]),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWithTap(
                                  leader.getAuthor!.getFullName!,
                                  marginLeft: 10,
                                  marginBottom: 5,
                                  fontWeight: FontWeight.bold,
                                  color: kGrayColor,
                                  fontSize: 16,
                                ),
                                ContainerCorner(
                                  color: kTransparentColor,
                                  marginLeft: 7,
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        "assets/svg/ic_diamond.svg",
                                        width: 25,
                                        height: 25,
                                      ),
                                      TextWithTap(
                                        leader.getDiamondsQuantity!.toString(),
                                        marginLeft: 2,
                                        color: kGrayColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
                    ContainerCorner(
                      borderRadius: 50,
                      height: 40,
                      width: 40,
                      color: widget.currentUser!.getFollowing!.contains(leader.getAuthor!.objectId) ? kTicketBlueColor :  kRedColor1,
                      child: Icon(
                        widget.currentUser!.getFollowing!.contains(leader.getAuthor!.objectId) ? Icons.chat_outlined : Icons.add,
                        color: Colors.white,
                      ),
                      onTap: (){
                        if(!widget.currentUser!.getFollowing!.contains(leader.getAuthor!.objectId)){
                          follow(leader.getAuthor!);
                        } else {
                          _gotToChat(widget.currentUser!, leader.getAuthor!);
                        }
                      },
                    )
                  ],
                ),
                ContainerCorner(
                  color: kGrayColor.withOpacity(0.2),
                  height: 1,
                  marginLeft: 5,
                  marginRight: 5,
                  marginTop: 20,
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
      queryEmptyElement: Center(
        child: QuickActions.noContentFound("menu_settings.no_gifters_title".tr(),
            "menu_settings.no_gifters_explain".tr(), "assets/svg/ic_menu_gifters.svg"),
      ),
      listLoadingElement: Center(
        child: CircularProgressIndicator(),
      ),
    );*/

    return FutureBuilder(
        future: _loadLeaders(type),
        builder: (BuildContext context, AsyncSnapshot snapshot){

          if(snapshot.connectionState == ConnectionState.waiting ){
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            var results = snapshot.data as List<dynamic>;

            return ListView.builder(
              itemCount: results.length,
              shrinkWrap: true,
              itemBuilder: (context, index){

                GiftsSentModel leaders = results[index];

                return ContainerCorner(
                  color: kTransparentColor,
                  marginLeft: 20,
                  marginRight: 10,
                  marginTop: 20,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Row(
                                children: [
                                  Stack(children: [
                                    GestureDetector(
                                      onTap: ()=> QuickActions.showUserProfile(context, widget.currentUser!, leaders.getAuthor!),
                                      child: QuickActions.avatarWidget(leaders.getAuthor!,
                                          width: 40, height: 40),
                                    ),
                                    Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: ContainerCorner(
                                          width: 15,
                                          height: 15,
                                          borderRadius: 50,
                                          color: kRedColor1,
                                        )),
                                  ]),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextWithTap(
                                        leaders.getAuthor!.getFullName!,
                                        marginLeft: 10,
                                        marginBottom: 5,
                                        fontWeight: FontWeight.bold,
                                        color: kGrayColor,
                                        fontSize: 16,
                                      ),
                                      ContainerCorner(
                                        color: kTransparentColor,
                                        marginLeft: 7,
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              "assets/svg/ic_diamond.svg",
                                              width: 25,
                                              height: 25,
                                            ),
                                            TextWithTap(
                                              leaders.getDiamondsQuantity!.toString(),
                                              marginLeft: 2,
                                              color: kGrayColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          ContainerCorner(
                            borderRadius: 50,
                            height: 40,
                            width: 40,
                            color: widget.currentUser!.getFollowing!.contains(leaders.getAuthor!.objectId) ? kTicketBlueColor :  kRedColor1,
                            child: Icon(
                              widget.currentUser!.getFollowing!.contains(leaders.getAuthor!.objectId) ? Icons.chat_outlined : Icons.add,
                              color: Colors.white,
                            ),
                            onTap: (){
                              if(!widget.currentUser!.getFollowing!.contains(leaders.getAuthor!.objectId)){
                                follow(leaders.getAuthor!);
                              } else {
                                _gotToChat(widget.currentUser!,leaders.getAuthor!);
                              }
                            },
                          )
                        ],
                      ),
                      ContainerCorner(
                        color: kGrayColor.withOpacity(0.2),
                        height: 1,
                        marginLeft: 5,
                        marginRight: 5,
                        marginTop: 20,
                      ),
                    ],
                  ),
                );
              },
            );

          } else {
            return Center(
              child: QuickActions.noContentFound("menu_settings.no_gifters_title".tr(),
                  "menu_settings.no_gifters_explain".tr(), "assets/svg/ic_menu_gifters.svg"),
            );
          }
        });
  }

  void follow(UserModel mUser)  async{
    QuickHelp.showLoadingDialog(context);

    ParseResponse parseResponseUser;

    widget.currentUser!.setFollowing = mUser.objectId!;
    parseResponseUser = await widget.currentUser!.save();

    if(parseResponseUser.success){

      if(parseResponseUser.results != null){
        QuickHelp.hideLoadingDialog(context);
        setState(() {
          widget.currentUser = parseResponseUser.results!.first as UserModel;
        });
      }
    }

    ParseResponse parseResponse;
    parseResponse = await QuickCloudCode.followUser(
        isFollowing: false,
        author: widget.currentUser!,
        receiver: mUser);

    if (parseResponse.success) {
      QuickActions.createOrDeleteNotification(widget.currentUser!,
          mUser, NotificationsModel.notificationTypeFollowers);
    }

  }

  _gotToChat(UserModel currentUser, UserModel mUser) {
    QuickHelp.goToNavigator(context, MessageScreen.route, arguments: {
      "currentUser": widget.currentUser,
      "mUser": mUser,
    });
  }
}
