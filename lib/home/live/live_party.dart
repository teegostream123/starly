import 'package:easy_localization/easy_localization.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:teego/home/live/zego_live_stream.dart';
import 'package:teego/models/UserModel.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/ui/text_with_tap.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../utils/colors.dart';
import '../search/search_creen.dart';
import 'artist_screen.dart';
import 'constant.dart';

class LivePartyScreen extends StatefulWidget {
  const LivePartyScreen({super.key});

  @override
  State<LivePartyScreen> createState() => _LivePartyScreenState();
}

class _LivePartyScreenState extends State<LivePartyScreen> {
// int tabTypeForYou = 0;
//   int tabTypeNearby = 1;
//   int tabTypeNew = 2;
//   int tabTypePopular = 3;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // Future<dynamic> _loadLive(int? category) async {
  //   try {
  //     print('loading available stream');
  //     // QueryBuilder<UserModel> queryUsers = QueryBuilder(UserModel.forQuery());
  //     // queryUsers.whereValueExists(UserModel.keyUserStatus, true);
  //     // queryUsers.whereEqualTo(UserModel.keyUserStatus, true);

  //     queryBuilder = QueryBuilder<LiveStreamingModel>(LiveStreamingModel());

  //     print('query builder init');

  //     // queryBuilder.whereEqualTo(LiveStreamingModel.keyStreaming, true);
  //     // queryBuilder.whereNotEqualTo(
  //     //     LiveStreamingModel.keyAuthorUid, widget.currentUser!.getUid);
  //     // queryBuilder.whereNotContainedIn(
  //     //     LiveStreamingModel.keyAuthor, widget.currentUser!.getBlockedUsers!);
  //     // queryBuilder.whereValueExists(LiveStreamingModel.keyAuthor, true);
  //     // queryBuilder.whereDoesNotMatchQuery(
  //     //     LiveStreamingModel.keyAuthor, queryUsers);

  //     // if (category == tabTypeForYou) {
  //     //queryBuilder.orderByDescending(keyVarCreatedAt);
  //     // queryBuilder.orderByDescending(LiveStreamingModel.keyAuthorTotalDiamonds);
  //     // } else if (category == tabTypeNearby) {
  //     // Nearby
  //     // if (widget.currentUser!.getGeoPoint != null) {
  //     //   queryBuilder.whereWithinKilometers(LiveStreamingModel.keyLiveGeoPoint,
  //     //       widget.currentUser!.getGeoPoint!, Setup.maxDistanceToNearBy);
  //     //   queryBuilder.orderByDescending(LiveStreamingModel.keyLiveGeoPoint);
  //     // }
  //     // } else if (category == tabTypeNew) {
  //     // New
  //     // queryBuilder.whereEqualTo(LiveStreamingModel.keyFirstLive, true);
  //     // queryBuilder.orderByDescending(LiveStreamingModel.keyCreatedAt);
  //     // } else if (category == tabTypePopular) {
  //     // Popular
  //     // queryBuilder.whereGreaterThanOrEqualsTo(
  //     //     LiveStreamingModel.keyStreamingDiamonds,
  //     //     Setup.minimumDiamondsToPopular);
  //     // queryBuilder.orderByDescending(LiveStreamingModel.keyAuthorTotalDiamonds);
  //     // }

  //     // queryBuilder.setLimit(25);
  //     // queryBuilder.includeObject([
  //     //   LiveStreamingModel.keyAuthor,
  //     //   LiveStreamingModel.keyAuthorInvited,
  //     //   LiveStreamingModel.keyPrivateLiveGift
  //     // ]);

  //     ParseResponse apiResponse = await queryBuilder.query();

  //     print(['api res is ', apiResponse.result]);
  //     if (apiResponse.success) {
  //       if (apiResponse.results != null) {
  //         //setupLiveQuery();

  //         setState(() {
  //           liveResults.clear();
  //         });

  //         return apiResponse.results;
  //       } else {
  //         return [];
  //       }
  //     } else {
  //       return null;
  //     }
  //   } catch (e, t) {
  //     print(e);
  //     print(t);
  //     rethrow;
  //   }
  // }

  Future<void> _loadLiveUpdate() async {
    return null;
  }
  // function to load all the streams from parser db
  // then show the list in the live party tab
  // on tap of the ite

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(2),
      child: FutureBuilder(
          future: getAllLive(),
          builder: (BuildContext context, snapshot) {
            print([
              'snapshot connection state',
              snapshot.connectionState,
            ]);
            if (snapshot.connectionState == ConnectionState.waiting) {
              return GridView.custom(
                physics: const AlwaysScrollableScrollPhysics(),
                primary: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                childrenDelegate: SliverChildBuilderDelegate(
                  childCount: 8,
                  (BuildContext context, int index) {
                    return FadeShimmer(
                      height: 60,
                      width: 60,
                      radius: 4,
                      fadeTheme: QuickHelp.isDarkModeNoContext()
                          ? FadeTheme.dark
                          : FadeTheme.light,
                    );
                  },
                ),
              );
            } else if (snapshot.hasData) {
              final liveResults = snapshot.data as List<dynamic>;

              if (liveResults.isNotEmpty) {
                print('inside liver result is not empty');
                return RefreshIndicator(
                  key: _refreshIndicatorKey,
                  color: Colors.white,
                  backgroundColor: kPrimaryColor,
                  strokeWidth: 2.0,
                  onRefresh: () {
                    _refreshIndicatorKey.currentState?.show(atTop: true);
                    return _loadLiveUpdate();
                  },
                  child: GridView.custom(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    childrenDelegate: SliverChildBuilderDelegate(
                      childCount: liveResults.length,
                      // childCount: 3,
                      (BuildContext context, int index) {
                        print(['available live index is', index]);
                        final liveStreaming = liveResults[index];

                        final author = liveStreaming['Author'] as UserModel;

                        print(['item config', liveStreaming]);

                        return GestureDetector(
                          onLongPress: () {
                            // if (liveStreaming.getAuthorId !=
                            //     widget.currentUser!.objectId) {
                            //   openSheet(
                            //       liveStreaming.getAuthor!, liveStreaming);
                            // }

                            // showDialog(
                            //   context: context,
                            //   builder: (BuildContext context) {
                            //     return AlertDialog(
                            //       title: Text('Live Streaming'),
                            //       content: Text(
                            //           'This is the content for Live Streaming.'),
                            //       actions: <Widget>[
                            //         TextButton(
                            //           child: Text('Close'),
                            //           onPressed: () {
                            //             // Close the dialog when the button is tapped
                            //             Navigator.of(context).pop();
                            //           },
                            //         ),
                            //         TextButton(
                            //             onPressed: () async {
                            //               UserModel? user =
                            //                   await ParseUser.currentUser();
                            //               Navigator.of(context).push(
                            //                   MaterialPageRoute(
                            //                       builder: ((context) =>
                            //                           MyWidget(
                            //                             userID:
                            //                                 (user?.getUid ?? '')
                            //                                     .toString(),
                            //                             userName:
                            //                                 user?.username ??
                            //                                     'no user',
                            //                             liveID: liveStreaming[
                            //                                 'liveID'],
                            //                             config:
                            //                                 ZegoUIKitPrebuiltLiveStreamingConfig
                            //                                     .host(),
                            //                             // isHost: host,
                            //                           ))));
                            //             },
                            //             child: Text('Create'))
                            //       ],
                            //     );
                            //   },
                            // );
                          },
                          onTap: () async {
                            UserModel? user = await ParseUser.currentUser();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: ((context) => MyWidget(
                                      userID: (user?.getUid ?? '').toString(),
                                      userName: user?.username ?? 'no user',
                                      liveID: liveStreaming['liveID'],
                                      config: audienceConfig,
                                      // isHost: host,
                                    ))));

                            // checkPermission(false,
                            //     channel: liveStreaming.getStreamingChannel,
                            //     liveStreamingModel: liveStreaming);
                          },
                          child: Stack(children: [
                            ContainerCorner(
                              color: kTransparentColor,
                              child: QuickActions.photosWidget(
                                  liveStreaming['imageUrl'],
                                  borderRadius: 5),
                            ),
                            Positioned(
                              top: 0,
                              child: ContainerCorner(
                                radiusTopLeft: 5,
                                radiusTopRight: 5,
                                height: 40,
                                width: MediaQuery.of(context).size.width / 2.01,
                                alignment: Alignment.center,
                                colors: [
                                  Colors.black,
                                  Colors.black.withOpacity(0.05)
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                child: ContainerCorner(
                                  color: kTransparentColor,
                                  marginLeft: 10,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          QuickActions.showSVGAsset(
                                            "assets/svg/ic_small_viewers.svg",
                                            height: 18,
                                          ),
                                          TextWithTap(
                                            '0',
                                            color: Colors.white,
                                            fontSize: 14,
                                            marginRight: 15,
                                            marginLeft: 5,
                                          ),
                                          QuickActions.showSVGAsset(
                                            "assets/svg/ic_diamond.svg",
                                            height: 24,
                                          ),
                                          TextWithTap(
                                            '0',
                                            color: Colors.white,
                                            fontSize: 14,
                                            marginLeft: 3,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: false,
                              child: Center(
                                child: Icon(
                                  Icons.vpn_key,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              child: ContainerCorner(
                                radiusBottomLeft: 5,
                                radiusBottomRight: 5,
                                height: 40,
                                width: MediaQuery.of(context).size.width / 2.01,
                                alignment: Alignment.center,
                                colors: [
                                  Colors.black,
                                  Colors.black.withOpacity(0.05)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                child: Row(
                                  children: [
                                    QuickActions.avatarWidget(author,
                                        height: 30,
                                        width: 30,
                                        margin: EdgeInsets.only(
                                            left: 5, bottom: 5)),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextWithTap(
                                          author.getFullName ?? 'no name',
                                          color: Colors.white,
                                          overflow: TextOverflow.ellipsis,
                                          marginLeft: 10,
                                        ),
                                        Visibility(
                                          visible: false,
                                          child: TextWithTap(
                                            'tag',
                                            color: Colors.white,
                                            overflow: TextOverflow.ellipsis,
                                            marginLeft: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]),
                        );
                      },
                    ),
                  ),
                );
              } else {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: QuickActions.noContentFound(
                      "live_streaming.no_live_title".tr(),
                      "live_streaming.no_live_explain".tr(),
                      "assets/svg/ic_tab_live_default.svg",
                    ),
                  ),
                );
              }
            } else {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: QuickActions.noContentFound(
                    "live_streaming.no_live_title".tr(),
                    "live_streaming.no_live_explain".tr(),
                    "assets/svg/ic_tab_live_default.svg",
                  ),
                ),
              );
            }
          }),
    );

    /*if(_isLoading){

      return GridView.custom(
        physics: const AlwaysScrollableScrollPhysics(),
        primary: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        childrenDelegate: SliverChildBuilderDelegate(
          childCount: 8, (BuildContext context, int index) {
          return FadeShimmer(
            height: 60,
            width: 60,
            radius: 4,
            fadeTheme: QuickHelp.isDarkModeNoContext() ? FadeTheme.dark : FadeTheme.light,
          );
        },
        ),
      );

    } else if(liveResults.isNotEmpty) {

      return RefreshIndicator(
        key: _refreshIndicatorKey,
        color: Colors.white,
        backgroundColor: kPrimaryColor,
        strokeWidth: 2.0,
        onRefresh: () {
          _refreshIndicatorKey.currentState?.show(atTop: true);
          return _loadLiveUpdate(tabIndex);
        },
        child: StaggeredGridView.countBuilder(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          itemCount: liveResults.length,
          itemBuilder: (BuildContext context, int index) {

            if (liveResults[index] is LiveStreamingModel){

              final LiveStreamingModel liveStreaming = liveResults[index] as LiveStreamingModel;
              return GestureDetector(
                onTap: (){
                  checkPermission(false, channel: liveStreaming.getStreamingChannel, liveStreamingModel: liveStreaming);
                },
                child: Stack(children: [
                  ContainerCorner(
                    color: kTransparentColor,
                    child: QuickActions.photosWidget(liveStreaming.getImage!.url!, borderRadius: 5),
                  ),
                  Positioned(
                    top: 0,
                    child: ContainerCorner(
                      radiusTopLeft: 5,
                      radiusTopRight: 5,
                      height: 40,
                      width: (MediaQuery.of(context).size.width / numberOfColumns) - 5,
                      alignment: Alignment.center,
                      colors: [
                        Colors.black,
                        Colors.black.withOpacity(0.05)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      child: ContainerCorner(
                        color: kTransparentColor,
                        marginLeft: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                QuickActions.showSVGAsset(
                                  "assets/svg/ic_small_viewers.svg",
                                  height: 18,
                                ),
                                TextWithTap(liveStreaming.getViewersCount.toString(),
                                  color: Colors.white,
                                  fontSize: 14,
                                  marginRight: 15,
                                  marginLeft: 5,
                                ),
                                QuickActions.showSVGAsset(
                                  "assets/svg/ic_diamond.svg",
                                  height: 24,
                                ),
                                TextWithTap(
                                  liveStreaming.getAuthor!.getDiamondsTotal!.toString(),
                                  color: Colors.white,
                                  fontSize: 14,
                                  marginLeft: 3,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: liveStreaming.getPrivate!,
                    child: Center(
                      child: Icon(Icons.vpn_key, color: Colors.white, size: 35,),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: ContainerCorner(
                      radiusBottomLeft: 5,
                      radiusBottomRight: 5,
                      height: 40,
                      width: (MediaQuery.of(context).size.width / numberOfColumns) - 5,
                      alignment: Alignment.center,
                      colors: [
                        Colors.black,
                        Colors.black.withOpacity(0.05)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      child: Row(
                        children: [
                          QuickActions.avatarWidget(
                              liveStreaming.getAuthor!, height: 30, width: 30,
                              margin: EdgeInsets.only(left: 5, bottom: 5)
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextWithTap(
                                liveStreaming.getAuthor!.getFullName!,
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis,
                                marginLeft: 10,
                              ),
                              Visibility(
                                visible: liveStreaming.getStreamingTags!.isNotEmpty,
                                child: TextWithTap(
                                  liveStreaming.getStreamingTags!,
                                  color: Colors.white,
                                  overflow: TextOverflow.ellipsis,
                                  marginLeft: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              );

            } else {

              return FutureBuilder(
                  future: getNativeAdTest(context: context),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasData) {
                      AdWidget ad = snapshot.data as AdWidget;

                      final Container adContainer = Container(
                        alignment: Alignment.center,
                        color: Colors.white,
                        child: ad,
                      );

                      return adContainer;

                    } else {
                      return Container(
                          alignment: Alignment.topCenter,
                          margin: const EdgeInsets.only(top: 20),
                          child: const CircularProgressIndicator(
                            value: 0.8,
                          ));
                    }
                  });
            }
          },
          staggeredTileBuilder: (int index){

            if (liveResults[index] is LiveStreamingModel){ //if (index % _kAdIndex == 0) {
              return StaggeredTile.count(1, 1);
            } else {
              return StaggeredTile.count(2, 3);
            }

          },
        ),
      );

    } else {

      return Center(
        child: Padding(
          padding:  EdgeInsets.all(8.0),
          child: QuickActions.noContentFound(
            "live_streaming.no_live_title".tr(),
            "live_streaming.no_live_explain".tr(),
            "assets/svg/ic_tab_live_default.svg",
          ),
        ),
      );
    }*/
  }

  Future<List> getAllLive() async {
    final snap = ParseObject('Streamings');
    final res = await snap.getAll();

    print(res);
    if (res.success && res.results != null) {
      print('success');

      print(res.results);

      return res.results ?? [];
    }
    return [];
  }
}

final hostConfig = ZegoUIKitPrebuiltLiveStreamingConfig.host(
  plugins: [ZegoUIKitSignalingPlugin()],
)..audioVideoViewConfig.foregroundBuilder = hostAudioVideoViewForegroundBuilder;

final audienceConfig = ZegoUIKitPrebuiltLiveStreamingConfig.audience(
  plugins: [ZegoUIKitSignalingPlugin()],
)
  ..onCameraTurnOnByOthersConfirmation = (BuildContext context) {
    return onTurnOnAudienceDeviceConfirmation(
      context,
      isCameraOrMicrophone: true,
    );
  }
  ..onMicrophoneTurnOnByOthersConfirmation = (BuildContext context) {
    return onTurnOnAudienceDeviceConfirmation(
      context,
      isCameraOrMicrophone: false,
    );
  }
  ..background = Badge(
    child: Image.asset(
      'assets/images/ic_coins_2.png',
      height: 30,
    ),
  );

Future<bool> onTurnOnAudienceDeviceConfirmation(
  BuildContext context, {
  required bool isCameraOrMicrophone,
}) async {
  const textStyle = TextStyle(
    fontSize: 10,
    color: Colors.white70,
  );
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Stack(
        alignment: Alignment.topRight, // Adjust the alignment as needed
        children: [
          AlertDialog(
            backgroundColor: Colors.blue[900]!.withOpacity(0.9),
            title: Text(
              "You have a request to turn on your ${isCameraOrMicrophone ? "camera" : "microphone"}",
              style: textStyle,
            ),
            content: Text(
              "Do you agree to turn on the ${isCameraOrMicrophone ? "camera" : "microphone"}?",
              style: textStyle,
            ),
            actions: [
              ElevatedButton(
                child: const Text('Cancel', style: textStyle),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                child: const Text('OK', style: textStyle),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
          Positioned(
            top: 100, // Adjust the position as needed
            right: 20, // Adjust the position as needed
            child: Image.asset(
              'assets/images/ic_coins_3.png', // Replace with the image for the audience
              height: 30,
              width: 30,
            ),
          ),
        ],
      );
    },
  );
}

Image prebuiltImage(String name) {
  return Image.asset(name, package: 'zego_uikit_prebuilt_live_streaming');
}

Widget hostAudioVideoViewForegroundBuilder(
  BuildContext context,
  Size size,
  ZegoUIKitUser? user,
  Map<String, dynamic> extraInfo,
) {
  if (user == null || user.id == localUserID) {
    return Container();
  }

  const toolbarCameraNormal = 'assets/icons/toolbar_camera_normal.png';
  const toolbarCameraOff = 'assets/icons/toolbar_camera_off.png';
  const toolbarMicNormal = 'assets/icons/toolbar_mic_normal.png';
  const toolbarMicOff = 'assets/icons/toolbar_mic_off.png';
  return Positioned(
    top: 15,
    right: 0,
    child: Row(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: ZegoUIKit().getCameraStateNotifier(user.id),
          builder: (context, isCameraEnabled, _) {
            return GestureDetector(
              onTap: () {
                ZegoUIKit().turnCameraOn(!isCameraEnabled, userID: user.id);
              },
              child: SizedBox(
                width: size.width * 0.4,
                height: size.width * 0.4,
                child: prebuiltImage(
                  isCameraEnabled ? toolbarCameraNormal : toolbarCameraOff,
                ),
              ),
            );
          },
        ),
        SizedBox(width: size.width * 0.1),
        ValueListenableBuilder<bool>(
          valueListenable: ZegoUIKit().getMicrophoneStateNotifier(user.id),
          builder: (context, isMicrophoneEnabled, _) {
            return GestureDetector(
              onTap: () {
                ZegoUIKit().turnMicrophoneOn(
                  !isMicrophoneEnabled,
                  userID: user.id,

                  ///  if you don't want to stop co-hosting automatically when both camera and microphone are off,
                  ///  set the [muteMode] parameter to true.
                  ///
                  ///  However, in this case, your [ZegoUIKitPrebuiltLiveStreamingConfig.stopCoHostingWhenMicCameraOff]
                  ///  should also be set to false.
                  muteMode: true,
                );
              },
              child: SizedBox(
                width: size.width * 0.4,
                height: size.width * 0.4,
                child: prebuiltImage(
                  isMicrophoneEnabled ? toolbarMicNormal : toolbarMicOff,
                ),
              ),
            );
          },
        )
      ],
    ),
  );
}
