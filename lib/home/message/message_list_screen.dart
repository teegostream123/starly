import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teego/helpers/quick_actions.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/models/MessageListModel.dart';
import 'package:teego/models/MessageModel.dart';
import 'package:teego/models/UserModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:teego/ui/button_widget.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:teego/utils/colors.dart';

import '../../app/constants.dart';
import '../../utils/utilsConstants.dart';

// ignore_for_file: must_be_immutable
class MessagesListScreen extends StatefulWidget {

  static const String route = '/home/messages';

  SharedPreferences? preferences;
   MessagesListScreen({Key? key, this.currentUser,  required this.preferences}) : super(key: key);
  final UserModel? currentUser;

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {

  late QueryBuilder<MessageListModel> queryBuilder;
  final LiveQuery liveQuery = LiveQuery();
  Subscription? subscription;
  List<dynamic> messagesResults = <dynamic>[];

  var _future;

  // Ads
  static final _kAdIndex = 4;

  AnchoredAdaptiveBannerAdSize? _size;

  @override
  void initState() {

    QuickHelp.saveCurrentRoute(route: MessagesListScreen.route);

    super.initState();
    _future = _loadMessagesList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initAdsSize();
  }

  initAdsSize() async {

    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    } else {
     setState(() {
       _size = size;
     });
      print('Got to get height of anchored banner.');
    }
  }

  disposeLiveQuery() {
    if (subscription != null) {
      liveQuery.client.unSubscribe(subscription!);
      subscription = null;
    }
  }

  Future<void> _objectUpdated(MessageListModel object) async {
    for (int i = 0; i < messagesResults.length; i++) {
      if (messagesResults[i].get<String>(keyVarObjectId) ==
          object.get<String>(keyVarObjectId)) {
        if (UtilsConstant.afterMessages(messagesResults[i], object) == null) {
          setState(() {
            // ignore: invalid_use_of_protected_member
            messagesResults[i] = object.clone(object.toJson(full: true));
          });
        }
        break;
      }
    }
  }

  Future<void> _objectDeleted(MessageListModel object) async {
    for (int i = 0; i < messagesResults.length; i++) {
      if (messagesResults[i].get<String>(keyVarObjectId) ==
          object.get<String>(keyVarObjectId)) {

        setState(() {
          // ignore: invalid_use_of_protected_member
          messagesResults.removeAt(i);
        });

        break;
      }
    }
  }

  setupLiveQuery() async {
    if (subscription == null) {
      subscription = await liveQuery.client.subscribe(queryBuilder);
    }

    subscription!.on(LiveQueryEvent.create, (MessageListModel messageListModel) async {
      await messageListModel.getAuthor!.fetch();
      await messageListModel.getReceiver!.fetch();
      /*if (post.getLastLikeAuthor != null) {
        await post.getLastLikeAuthor!.fetch();
      }*/

      if (!mounted) return;
      setState(() {
        messagesResults.add(messageListModel);
      });
    });

    subscription!.on(LiveQueryEvent.enter, (MessageListModel messageListModel) async {
      await messageListModel.getAuthor!.fetch();
      await messageListModel.getReceiver!.fetch();

      /*if (post.getLastLikeAuthor != null) {
        await post.getLastLikeAuthor!.fetch();
      }*/

      if (!mounted) return;
      setState(() {
        messagesResults.add(messageListModel);
      });
    });

    subscription!.on(LiveQueryEvent.update, (MessageListModel messageListModel) async {
      if (!mounted) return;

      await messageListModel.getAuthor!.fetch();
      await messageListModel.getReceiver!.fetch();
      /*if (post.getLastLikeAuthor != null) {
        await post.getLastLikeAuthor!.fetch();
      }*/

      _objectUpdated(messageListModel);
    });

    subscription!.on(LiveQueryEvent.delete, (MessageListModel post) {
      if (!mounted) return;

      _objectDeleted(post);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Expanded(
        child:
          loadMessages(),
        ),
      ],
    );
  }

  Widget getAd() {

    BannerAdListener bannerAdListener =
    BannerAdListener(onAdWillDismissScreen: (ad) {
      ad.dispose();
    }, onAdClosed: (ad) {
      ad.dispose();
      debugPrint("Ad Got Closeed");
    }, onAdFailedToLoad: (ad, error){
      ad.dispose();
    });


    BannerAd bannerAd = BannerAd(
      //size: AdSize.banner,
      size: _size!,
      adUnitId: Constants.getAdmobChatListBannerUnit(),
      listener: bannerAdListener,
      request: const AdRequest(),
    );

    bannerAd..load();

    return Container(
      height: _size != null ? _size!.height.roundToDouble() : 0,
      width: _size != null ? _size!.width.toDouble() : 0,
      key: UniqueKey(),
      alignment: Alignment.center,
      child: AdWidget(ad: bannerAd),);
  }

  Future<dynamic> _loadMessagesList() async {
    //print("IndexPint 1");

    disposeLiveQuery();

    QueryBuilder<MessageListModel> queryFrom = QueryBuilder<MessageListModel>(MessageListModel());
    queryFrom.whereEqualTo(MessageListModel.keyAuthorId, widget.currentUser!.objectId!);

    QueryBuilder<MessageListModel> queryTo = QueryBuilder<MessageListModel>(MessageListModel());
    queryTo.whereEqualTo(MessageListModel.keyReceiverId, widget.currentUser!.objectId!);

    queryBuilder = QueryBuilder.or(MessageListModel(), [queryFrom, queryTo]);
    queryBuilder.orderByDescending(keyVarUpdatedAt);

    queryBuilder.includeObject([MessageListModel.keyAuthor, MessageListModel.keyReceiver, MessageListModel.keyMessage, MessageListModel.keyCall]);

    queryBuilder.setLimit(50);
    ParseResponse apiResponse = await queryBuilder.query();
    if (apiResponse.success) {
      if (apiResponse.results != null) {

        setupLiveQuery();

        return apiResponse.results;
      } else {
        return [];
      }
    } else {
      return null;
    }
  }

  Widget loadMessages() {

    Size size = MediaQuery.of(context).size;

    return FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {

            return ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index){

                  final delay = (index * 300);

                  return Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        FadeShimmer.round(
                          size: 60,
                          fadeTheme: QuickHelp.isDarkMode(context) ? FadeTheme.dark : FadeTheme.light,
                          millisecondsDelay: delay,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeShimmer(
                              height: 8,
                              width: size.width /2,
                              radius: 4,
                              millisecondsDelay: delay,
                              fadeTheme:
                              QuickHelp.isDarkMode(context) ? FadeTheme.dark : FadeTheme.light,
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            FadeShimmer(
                              height: 8,
                              millisecondsDelay: delay,
                              width:  size.width /1.5,
                              radius: 4,
                              fadeTheme:
                              QuickHelp.isDarkMode(context) ? FadeTheme.dark : FadeTheme.light,
                            ),
                          ],
                        )
                      ],
                    ),
                  );

            });

          } else if (snapshot.hasData) {

            messagesResults = snapshot.data! as List<dynamic>;

            if (messagesResults.isNotEmpty) {
              return ListView.separated(
                  itemCount: messagesResults.length,
                  itemBuilder: (context, index) {

                      MessageListModel chatMessage = messagesResults[index];

                      UserModel chatUser = chatMessage.getAuthorId! == widget.currentUser!.objectId! ? chatMessage.getReceiver! : chatMessage.getAuthor!;
                      bool isMe = chatMessage.getAuthorId! == widget.currentUser!.objectId! ? true : false;

                      //print("CHAT MESSAGE: ${chatUser.objectId} and ${widget.currentUser!.objectId}");

                      return ButtonWidget(
                        height: 50,
                        onTap: ()=> QuickHelp.gotoChat(context, currentUser: widget.currentUser, mUser: chatUser, preferences: widget.preferences!),
                        child: Padding(
                          padding:  EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              QuickActions.avatarWidget(
                                chatUser,
                                width: 50,
                                height: 50,
                              ),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TextWithTap(
                                              chatUser.getFullName!,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              marginLeft: 10,
                                              color: QuickHelp.isDarkMode(context)
                                                  ? Colors.white
                                                  : Colors.black,
                                              marginTop: 5,
                                              marginRight: 5,
                                            ),
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                  EdgeInsets.only(left: 10, top: 5),
                                                  child: getTextIcon(chatMessage),
                                                ),
                                                if (chatMessage.getMessageType ==
                                                    MessageModel.messageTypeText)
                                                  ContainerCorner(
                                                    width: 230,
                                                    child: TextWithTap(
                                                      chatMessage.getText!,
                                                      marginTop: 5,
                                                      marginLeft: 10,
                                                      maxLines: 1,
                                                      color: !chatMessage.isRead! && !isMe
                                                          ? Colors.redAccent
                                                          : kGrayColor,
                                                      overflow: TextOverflow.ellipsis,
                                                      fontWeight:
                                                      !chatMessage.isRead! && !isMe
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                    ),
                                                  ),
                                                if (chatMessage.getMessageType == MessageModel.messageTypeGif)
                                                  ContainerCorner(
                                                    child: Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                          EdgeInsets.only(left: 5),
                                                          child: Icon(
                                                            Icons.wallet_giftcard_sharp,
                                                            size: 20,
                                                            color: kGrayColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                if (chatMessage.getMessageType == MessageModel.messageTypePicture)
                                                  ContainerCorner(
                                                    child: Row(
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets.only(
                                                              top: 8, left: 5),
                                                          child: Icon(Icons.photo_camera, size: 20, color: kGrayColor,),
                                                        ),
                                                        TextWithTap(
                                                          MessageModel.messageTypePicture,
                                                          marginTop: 5,
                                                          marginLeft: 5,
                                                          color: !chatMessage.isRead! &&
                                                              !isMe
                                                              ? Colors.redAccent
                                                              : kGrayColor,
                                                          overflow: TextOverflow.ellipsis,
                                                          fontSize: 17,
                                                          fontWeight:
                                                          !chatMessage.isRead! &&
                                                              !isMe
                                                              ? FontWeight.bold
                                                              : FontWeight.normal,
                                                        ),
                                                      ],
                                                    ),
                                                  ), if (chatMessage.getMessageType == MessageModel.messageTypeCall)
                                                  ContainerCorner(
                                                    child: Row(
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets.only(
                                                              top: 8, left: 5),
                                                          child: Icon(chatMessage.getCall!.getAuthorId == widget.currentUser!.objectId! ? Icons.call_made : Icons.call_received, size: 20, color: kGrayColor,),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.only(
                                                              top: 8, left: 5),
                                                          child: Icon(chatMessage.getCall!.getIsVoiceCall! ? Icons.call : Icons.videocam, size: 24, color: kGrayColor,),
                                                        ),
                                                        TextWithTap(
                                                          chatMessage.getCall!.getAccepted!? chatMessage.getCall!.getDuration!:
                                                          "push_notifications.missed_call_title".tr(),
                                                          marginTop: 5,
                                                          marginLeft: 5,
                                                          color: !chatMessage.isRead! &&
                                                              !isMe
                                                              ? Colors.redAccent
                                                              : kGrayColor,
                                                          overflow: TextOverflow.ellipsis,
                                                          fontSize: 17,
                                                          fontWeight:
                                                          !chatMessage.isRead! &&
                                                              !isMe
                                                              ? FontWeight.bold
                                                              : FontWeight.normal,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                              ],
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      TextWithTap(QuickHelp.getMessageListTime(chatMessage.updatedAt!),
                                        marginLeft: 5,
                                        marginRight: 5,
                                        marginBottom: 5,
                                        color: kGrayColor,
                                      ),
                                    ],
                                  ),
                                  !chatMessage.isRead! && !isMe ?
                                  ContainerCorner(
                                    borderRadius: 100,
                                    color: kRedColor1,
                                    marginRight: 5,
                                    child: TextWithTap(chatMessage.getCounter.toString(),
                                      color: Colors.white,
                                      marginRight: 5,
                                      marginTop: 2,
                                      marginLeft: 5,
                                      marginBottom: 2,
                                      fontSize: 11,
                                    ),
                                  ) : Container(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );

                  }, separatorBuilder: (BuildContext context, int index) {

                if (index % _kAdIndex == 0) {

                  if(_size != null){
                    return getAd();
                  } else {
                    return Container();
                  }
                }
                  return Container();
                },
              );

            } else {
              return Center(
                child: QuickActions.noContentFound("message_screen.no_message_title".tr(),
                    "message_screen.no_message_explain".tr(), "assets/svg/ic_tab_chat_default.svg"),
              );
            }
          } else {
            return Center(
              child: QuickActions.noContentFound("message_screen.no_message_title".tr(),
                  "message_screen.no_message_explain".tr(), "assets/svg/ic_tab_chat_default.svg"),
            );
          }
        });
  }

  Widget getTextIcon(MessageListModel chatMessage){

    if(chatMessage.getAuthorId == widget.currentUser!.objectId){

      return Icon(Icons.done_all_outlined, color: chatMessage.isRead!? Colors.blue: kGrayColor, size: 20,);

    } else {

      return Visibility(
        visible: false,
          child: Container(),
      );
    }
  }
}