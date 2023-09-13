import 'dart:math';

import 'package:flutter/material.dart';
import 'package:teego/helpers/quick_actions.dart';
import 'package:teego/home/feed/videoutils/video.dart';

import 'package:teego/home/feed/videoutils/video_item_config.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../helpers/quick_help.dart';
import 'default_video_info.dart';

class VideoItemWidget<V extends VideoInfo> extends StatefulWidget {
  final int pageIndex;
  final int currentPageIndex;
  final bool isPaused;

  /// Video ended callback
  ///
  final void Function()? videoEnded;

  final VideoItemConfig config;

  /// Video Information: like count, like, more, name song, ....
  ///
  final V videoInfo;

//  /// Video network url
//  ///
//  final String url;

  /// Video Info Customizable
  ///
  final Widget? customVideoInfoWidget;

  const VideoItemWidget(
      {
      /// video information
      required this.videoInfo,

      /// video config
      this.config = const VideoItemConfig(
          loop: true,
          itemLoadingWidget: CircularProgressIndicator(),
          autoPlayNextVideo: true),
      required this.pageIndex,
      required this.currentPageIndex,
      required this.isPaused,
      this.customVideoInfoWidget,
      this.videoEnded});

  @override
  State<StatefulWidget> createState() => _VideoItemWidgetState<V>();
}

class _VideoItemWidgetState<V extends VideoInfo>
    extends State<VideoItemWidget<V>> {
  late VideoPlayerController? _videoPlayerController;
  bool initialized = false;
  bool actualDisposed = false;
  bool isEnded = false;

  bool isPauseClicked = false;
  bool isBuffering = true;
  bool isVideoPlaying = false;

  ///
  ///
  @override
  void initState() {
    super.initState();
    _initVideoController();
  }

  ///
  ///
  @override
  Widget build(BuildContext context) {
    bool isLandscape = false;
    _pauseAndPlayVideo();
    if (initialized && _videoPlayerController!.value.isInitialized) {
      isLandscape = _videoPlayerController!.value.size.width >
          _videoPlayerController!.value.size.height;
    }

    return GestureDetector(
      onTap: playAndPayBtn,
      child: Center(
        child: Stack(
          children: [
            initialized
                ? isLandscape
                    ? _renderLandscapeVideo()
                    : _renderPortraitVideo()
                : Stack(
                    children: [
                      Center(
                        child: QuickActions.getVideoPlaceHolder(
                          widget.videoInfo.postModel!.getVideoThumbnail!.url!,
                          showLoading: false,
                        ),
                      ),
                    ],
                  ),
            _renderVideoInfo(),
            Align(
              alignment: Alignment.bottomCenter,
              child: VideoProgressIndicator(
                _videoPlayerController!,
                allowScrubbing: true,
                padding: EdgeInsets.only(top: 5),
                colors: VideoProgressColors(
                    backgroundColor: Colors.white.withOpacity(0.3),
                    bufferedColor: Colors.white.withOpacity(0.5),
                    playedColor: Colors.white),
              ),
            ),
            Visibility(
              visible: isBuffering && !isVideoPlaying,
              child: QuickHelp.showLoadingAnimation(),
            ),
            Visibility(
              visible: getPlayAndPauseBtn(),
              child: Center(
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white.withOpacity(0.5),
                  size: 80,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void playAndPayBtn() {
    setState(() {
      print("Play and pause clicked");
      if (widget.pageIndex == widget.currentPageIndex) {
        isPauseClicked = true;

        if (initialized &&
            _videoPlayerController != null &&
            _videoPlayerController!.value.isPlaying) {
          _videoPlayerController?.pause().then((value) {});
        } else if (initialized &&
            _videoPlayerController != null &&
            !_videoPlayerController!.value.isPlaying) {
          _videoPlayerController?.play().then((value) {});
        }
      } else {
        isPauseClicked = false;
      }
    });
  }

  bool getPlayAndPauseBtn() {
    if (isPauseClicked &&
        !_videoPlayerController!.value.isPlaying &&
        _videoPlayerController!.value.isInitialized) {
      return true;
    } else {
      return false;
    }
  }

  ///
  ///
  @override
  void dispose() {
    if (initialized && _videoPlayerController != null) {
      _videoPlayerController!.removeListener(_videoListener);
      _videoPlayerController!.dispose();
      _videoPlayerController = null;
    }

    actualDisposed = true;
    super.dispose();
  }

  /// Video initialization
  ///
  void _initVideoController() {
    if (widget.videoInfo.url == null) return;
    // Init video from network url
    _videoPlayerController = VideoPlayerController.network(
      widget.videoInfo.url!,
    );
    _videoPlayerController!.addListener(_videoListener);
    _videoPlayerController!.initialize().then((_) {
      if (!mounted) return;

      setState(() {
        _videoPlayerController!.setLooping(widget.config.loop);
        initialized = true;
      });
    });
  }

  /// Video controller listener

  void _videoListener() {
    if (!initialized) return;

    if (widget.pageIndex == widget.currentPageIndex &&
        _videoPlayerController!.value.isBuffering) {
      if (!isBuffering) {
        setState(() {
          isBuffering = true;
          isVideoPlaying = false;
        });

        print("This video is isBuffering: ${widget.videoInfo.url!}");
      }
    } else if (widget.pageIndex == widget.currentPageIndex &&
        _videoPlayerController!.value.isPlaying) {
      if (!isVideoPlaying) {
        setState(() {
          isVideoPlaying = true;
          isBuffering = false;
        });

        print("This video is isPlaying: ${widget.videoInfo.url!}");
      }
    }

    if (_videoPlayerController?.value.position != null &&
        _videoPlayerController?.value.duration != null) {
      /// check if video has ended
      ///
      if (_videoPlayerController!.value.position >=
          _videoPlayerController!.value.duration) {
        if (widget.config.autoPlayNextVideo &&
            widget.videoEnded != null &&
            !isEnded) {
          isEnded = true;
          widget.videoEnded!();
        }
      }
    }
  }

  void _pauseAndPlayVideo() {
    if (initialized && _videoPlayerController != null) {
      if (widget.pageIndex == widget.currentPageIndex &&
          !widget.isPaused &&
          initialized) {
        if (isPauseClicked) {
          return;
        }
        _videoPlayerController?.play().then((value) {});
      } else {
        _videoPlayerController?.pause().then((value) {});
      }
    }
  }

  Widget _renderLandscapeVideo() {
    if (!initialized) return Container();
    if (_videoPlayerController == null) return Container();
    return Center(
      child: AspectRatio(
        child: VisibilityDetector(
            child: VideoPlayer(_videoPlayerController!),
            onVisibilityChanged: _handleVisibilityDetector,
            key: Key('key_${widget.currentPageIndex}')),
        aspectRatio: _videoPlayerController!.value.aspectRatio,
      ),
    );
  }

  Widget _renderPortraitVideo() {
    if (!initialized) return Container();
    if (_videoPlayerController == null) return Container();

    var tmp = MediaQuery.of(context).size;

    var screenH = max(tmp.height, tmp.width);
    var screenW = min(tmp.height, tmp.width);
    tmp = _videoPlayerController!.value.size;

    var previewH = max(tmp.height, tmp.width);
    var previewW = min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return Center(
      child: OverflowBox(
        child: VisibilityDetector(
            onVisibilityChanged: _handleVisibilityDetector,
            key: Key('key_${widget.currentPageIndex}'),
            child: VideoPlayer(_videoPlayerController!)),
        maxHeight: screenRatio > previewRatio
            ? screenH
            : screenW / previewW * previewH,
        maxWidth: screenRatio > previewRatio
            ? screenH / previewH * previewW
            : screenW,
      ),
    );
  }

  Widget _renderVideoInfo() {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Container(
      width: w,
      height: h,
      child: widget.customVideoInfoWidget != null
          ? widget.customVideoInfoWidget
          : DefaultVideoInfoWidget(
              /*name: widget.videoInfo.userName,
              time: widget.videoInfo.dateTime,
              liked: widget.videoInfo.liked,
              text: widget.videoInfo.songName,
              likes: widget.videoInfo.likes,*/
              postModel: widget.videoInfo.postModel,
              currentUser: widget.videoInfo.currentUser,
            ),
    );
  }

  void _handleVisibilityDetector(VisibilityInfo info) {
    var visiblePercentage = info.visibleFraction * 100;

    if (widget.currentPageIndex == widget.pageIndex &&
        _videoPlayerController != null &&
        !actualDisposed) {
      if (visiblePercentage == 0.0) {
        print("CHECK VIDEO STATE VISIBLE $visiblePercentage");
        _videoPlayerController?.pause().then((value) {});
      } else {
        _videoPlayerController?.play().then((value) {
          setState(() {});
          print("CHECK VIDEO STATE INVISIBLE");
        });
      }
    } else if (_videoPlayerController != null &&
        !actualDisposed &&
        !widget.isPaused) {
      _videoPlayerController?.pause().then((value) {});
    }
  }
}
