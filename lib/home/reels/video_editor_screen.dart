import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart' show OpacityTransition, SwipeTransition;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:teego/helpers/quick_help.dart';
import 'package:teego/home/reels/video_crop_screen.dart';
import 'package:teego/models/others/video_editor_model.dart';
import 'package:teego/ui/container_with_corner.dart';
import 'package:teego/utils/colors.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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
    initVideo();
    super.initState();
  }

  Future initVideo() async {
    try {
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
        ..initialize().then((_) {
          print('video has been initilized');
          setState(() {});
        });
    } catch (e, t) {
      print(['Error for video exporting ', e, t]);
    }
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

  Future _exportVideo() async {
    print('export video ta[p]');
    _exportingProgress.value = 0;
    _isExporting.value = true;

    final config = VideoFFmpegVideoEditorConfig(_controller);

    final FFmpegVideoEditorExecute execute = await config.getExecuteConfig();

    setState(() {
      _exportingProgress.value = 1;
      _exported = true;
    });

    final path = execute.outputPath;

    final thumbnail = await generateThumbnail(path);

    if (thumbnail == null) {
      QuickHelp.showAppNotification(
        context: context,
        title: 'Error while building thumbnail',
      );
      return;
    }

    final VideoEditorModel videoEditorModel = VideoEditorModel(
      videoFile: File(path),
      coverPath: thumbnail,
    );

    QuickHelp.goBackToPreviousPage(context, result: videoEditorModel);
  }

  Future<String> generateThumbnail(String path) async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxHeight:
          64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 75,
    );

    if (fileName == null) {
      throw Exception('Could not generate thumbnail');
    }

    return fileName;
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
            padding: const EdgeInsets.only(top: 10, bottom: 10),
          ),
        ),
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
      ),
    );
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
