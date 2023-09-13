import 'package:easy_localization/easy_localization.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../profile/user_screen.dart';
import '../search/search_creen.dart';

class ArtistScreen extends StatefulWidget {
  const ArtistScreen({super.key});

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<List<ParseObject>> doUserQuery() async {
    print('gettting artists');
    QueryBuilder<UserModel> queryUsers =
        QueryBuilder<UserModel>(UserModel.forQuery());

    // Add query constraints (optional)
    queryUsers.whereEqualTo('role', 'artist');
    final ParseResponse apiResponse = await queryUsers.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder<List<ParseObject>>(
            future: doUserQuery(),
            builder: (context, snapshot) {
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
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Error...: ${snapshot.error.toString()}"),
                );
              } else if (snapshot.data!.isEmpty) {
                return Center(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: QuickActions.noContentFound(
                    "No Artist for now".tr(),
                    "Stay tuned with us".tr(),
                    "assets/svg/ic_tab_live_default.svg",
                  ),
                ));
              } else {
                return RefreshIndicator(
                  key: _refreshIndicatorKey,
                  color: Colors.white,
                  backgroundColor: kPrimaryColor,
                  strokeWidth: 2.0,
                  onRefresh: () {
                    _refreshIndicatorKey.currentState?.show(atTop: true);
                    return doUserQuery();
                  },
                  child: GridView.custom(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    childrenDelegate: SliverChildBuilderDelegate(
                      childCount: snapshot.data!.length,
                      (BuildContext context, int index) {
                        final user = snapshot.data![index] as UserModel;

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (builder) => UserScreen(
                                      userModel: user,
                                    )));
                            // Navigator.push(context, MaterialPageRoute(builder: (_) => SelectScreen()));

                            // Navigator.of(context).push(MaterialPageRoute(
                            //     builder: ((context) => MyWidget(
                            //       userID: 'ugu',
                            //       userName: 'Ali',
                            //       liveID: '100',
                            //       config: ZegoUIKitPrebuiltLiveStreamingConfig.audience(),
                            //       // isHost: host,
                            //     ))));
                          },
                          child: Stack(children: [
                            ContainerCorner(
                              color: kTransparentColor,
                              // color : Colors.red,
                              child: QuickActions.photosWidget(
                                  user.getAvatar == null
                                      ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRuk4zd55uaQfv6DaY9RpS8a4lVNnVcyKf2YVHO5z3IAzZypmoFzSG4wSSuimSvjc_L-fk&usqp=CAU'
                                      : user.getAvatar!.url,
                                  borderRadius: 5),
                            ),
                            // Positioned(
                            //   top: 0,
                            //   child: ContainerCorner(
                            //     radiusTopLeft: 5,
                            //     radiusTopRight: 5,
                            //     height: 40,
                            //     width: (MediaQuery.of(context).size.width /
                            //             numberOfColumns) -
                            //         5,
                            //     alignment: Alignment.center,
                            //     colors: [
                            //       Colors.black,
                            //       Colors.black.withOpacity(0.05)
                            //     ],
                            //     begin: Alignment.topCenter,
                            //     end: Alignment.bottomCenter,
                            //     child: ContainerCorner(
                            //       color: kTransparentColor,
                            //       marginLeft: 10,
                            //       child: Row(
                            //         mainAxisAlignment:
                            //             MainAxisAlignment.spaceBetween,
                            //         children: [
                            //           Row(
                            //             children: [
                            //               // TextWithTap(
                            //               //   'View Profile'.toString(),
                            //               //   color: Colors.white,
                            //               //   fontSize: 14,
                            //               //   marginRight: 15,
                            //               //   marginLeft: 5,
                            //               // ),
                            //               // QuickActions.showSVGAsset(
                            //               //   "assets/svg/ic_diamond.svg",
                            //               //   height: 24,
                            //               // ),
                            //               // TextWithTap(
                            //               //   liveStreaming
                            //               //       .getAuthor!.getDiamondsTotal!
                            //               //       .toString(),
                            //               //   color: Colors.white,
                            //               //   fontSize: 14,
                            //               //   marginLeft: 3,
                            //               // ),
                            //             ],
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),
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
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Row(
                                    children: [
                                      QuickActions.showSVGAsset(
                                        "assets/svg/ic_small_viewers.svg",
                                        height: 18,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextWithTap(
                                            user.getFullName!,
                                            color: Colors.white,
                                            overflow: TextOverflow.ellipsis,
                                            marginLeft: 10,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        );
                      },
                    ),
                  ),
                );
              }
            }));
  }
}
