import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart' show OpacityTransition, SwipeTransition;
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/home/reels/video_crop_screen.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/utils/colors.dart';
import 'package:video_editor/video_editor.dart';

import '../../models/others/video_editor_model.dart';
import '../../ui/app_bar.dart';
import '../../ui/text_with_tap.dart';

class VideoEditorScreen extends StatefulWidget {
  const VideoEditorScreen({Key? key, required this.file}) : super(key: key);

  final File file;

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  final ValueNotifier<double> _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  bool _exported = false;
  String _exportText = "";
  late VideoEditorController _controller;

  @override
  void initState() {
    _controller = VideoEditorController.file(widget.file,
        maxDuration: const Duration(minutes: 3),
        cropStyle: CropGridStyle(
            //croppingBackground: Colors.black45,
            //background: kTransparentColor,
            //boundariesColor: kTransparentColor
            ),
        coverStyle: CoverSelectionStyle(
          selectedBorderColor: Colors.white,
          borderWidth: 2,
          borderRadius: 5,
        ),
        trimStyle: TrimSliderStyle(
          background: kTransparentColor,
          edgesType: TrimSliderEdgesType.bar,
          positionLineWidth: 8,
          lineWidth: 4,
          onTrimmedColor: kPrimaryColor,
          onTrimmingColor: kPrimaryColor,
        ))
      ..initialize().then((_) => setState(() {}));

    super.initState();
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _openCropScreen() => Navigator.push(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              CropScreen(controller: _controller)));

  void _exportVideo() async {
    _exportingProgress.value = 0;
    _isExporting.value = true;
    // NOTE: To use `-crf 1` and [VideoExportPreset] you need `ffmpeg_kit_flutter_min_gpl` package (with `ffmpeg_kit` only it won't work)
    //TODO: Export video;
    // await _controller.exportVideo(
    //   preset: VideoExportPreset.medium,
    //   customInstruction: "-crf 17",
    //   onProgress: (stats, value) => _exportingProgress.value = value,
    //   onError: (e, s) => _exportText = "Error on export video :(",
    //   onCompleted: (file) async {
    //     _isExporting.value = false;
    //      await _controller.extractCover(
    //        onError: (e, s) => _exportText = "Error on cover exportation :(",
    //        onCompleted: (cover) {
    //       if (!mounted) return;
    //          _exportText = "Cover exported! ${cover.path}";
    //          print("Exported cover ${cover.path}");
    //          print("Exported Video ${file.path}");
    //          VideoEditorModel videoEditorModel = VideoEditorModel();
    //          videoEditorModel.setCoverPath(cover.path);
    //          videoEditorModel.setVideoFile(file);
    //          QuickHelp.goBackToPreviousPage(context, result: videoEditorModel);
    //        },
    //     );
    //     _exportText = "Video success export!";
    //     setState(() => _exported = true);
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return ToolBar(
      title: "page_title.reels_edit_video".tr(),
      centerTitle: QuickHelp.isAndroidPlatform() ? true : false,
      leftButtonIcon: Icons.arrow_back_ios,
      onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
      rightButtonIcon: Icons.crop_rotate,
      rightButtonPress: _openCropScreen,
      rightButtonTwoIcon: Icons.check_sharp,
      rightButtonTwoPress: _exportVideo,
      backgroundColor: QuickHelp.isDarkModeNoContext()
          ? null
          : kColorsGrey300.withOpacity(0.5),
      child: _controller.initialized
          ? ContainerCorner(
              color: QuickHelp.isDarkModeNoContext()
                  ? null
                  : kColorsGrey300.withOpacity(0.5),
              padding: EdgeInsets.only(top: 10),
              child: Stack(children: [
                Column(children: [
                  //_topNavBar(),
                  Expanded(
                      child: DefaultTabController(
                          length: 2,
                          child: Column(children: [
                            Expanded(
                                child: TabBarView(
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                Stack(alignment: Alignment.center, children: [
                                  CropGridViewer.edit(
                                    controller: _controller,
                                    //showGrid: false,
                                  ),
                                  AnimatedBuilder(
                                    animation: _controller.video,
                                    builder: (_, __) => OpacityTransition(
                                      visible: !_controller.isPlaying,
                                      child: GestureDetector(
                                        onTap: _controller.video.play,
                                        onDoubleTap: _controller.video.pause,
                                        onLongPress: _controller.video.pause,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.play_arrow,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                                CoverViewer(controller: _controller)
                              ],
                            )),
                            ContainerCorner(
                                color: kPrimacyGrayColor.withOpacity(0.2),
                                radiusTopRight: 30,
                                radiusTopLeft: 30,
                                height: 200,
                                marginTop: 10,
                                child: Column(children: [
                                  TabBar(
                                    indicatorColor: Colors.white,
                                    tabs: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.all(5),
                                                child: Icon(Icons.cut_rounded)),
                                            Text('video_editor.video_editor_trim')
                                                .tr()
                                          ]),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Icon(
                                                  Icons.video_label_rounded)),
                                          Text('video_editor.video_editor_cover')
                                              .tr()
                                        ],
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                      children: [
                                        Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: _trimSlider()),
                                        Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [_coverSelection()]),
                                      ],
                                    ),
                                  )
                                ])),
                            _customSnackBar(),
                            ValueListenableBuilder(
                              valueListenable: _isExporting,
                              builder: (_, bool export, __) {
                                if (export) {
                                  return OpacityTransition(
                                    visible: export,
                                    child: AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: ValueListenableBuilder(
                                        valueListenable: _exportingProgress,
                                        builder: (_, double value, __) => Text(
                                          "video_editor.video_editor_rendering",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ).tr(namedArgs: {
                                          "percent": "${(value * 100).ceil()}"
                                        }),
                                      ),
                                    ),
                                  );
                                } else {
                                  // Return an empty container when not exporting.
                                  return Container();
                                }
                              },
                            )
                          ])))
                ])
              ]),
            )
          // : Container(
          //     height: 100,
          //     color: Colors.deepPurple,
          //   )
          : Center(child: QuickHelp.showLoadingAnimation()),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: _controller.video,
        builder: (_, __) {
          final duration = _controller.video.value.duration.inSeconds;
          final pos = _controller.trimPosition * duration;
          final start = _controller.minTrim * duration;
          final end = _controller.maxTrim * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              TextWithTap(
                formatter(Duration(seconds: pos.toInt())),
                color: null,
              ),
              const Expanded(child: SizedBox()),
              OpacityTransition(
                visible: true, //_controller.isTrimming,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  TextWithTap(
                    formatter(Duration(seconds: start.toInt())),
                    color: Colors.red,
                  ),
                  const SizedBox(width: 10),
                  TextWithTap(
                    formatter(Duration(seconds: end.toInt())),
                    color: null,
                  ),
                ]),
              )
            ]),
          );
        },
      ),
      Container(
        // color: Colors.green,
        //color: kTransparentColor,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
            controller: _controller,
            height: height,
            horizontalMargin: height / 4,
            child: TrimTimeline(
                textStyle: TextStyle(color: null),
                controller: _controller,
                padding: const EdgeInsets.only(top: 10, bottom: 10))),
      )
    ];
  }

  Widget _coverSelection() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: height / 4),
        child: CoverSelection(
          controller: _controller,
          //height: height,
          quantity: 8,
        ));
  }

  Widget _customSnackBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SwipeTransition(
        visible: _exported,
        axisAlignment: 1.0,
        child: Container(
          height: height,
          width: double.infinity,
          // color: Colors.deepOrange,
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: Text(_exportText,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
