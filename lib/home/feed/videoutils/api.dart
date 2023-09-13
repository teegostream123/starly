import 'package:teego/home/feed/videoutils/video.dart';

abstract class VideoNewFeedApi<V extends VideoInfo> {
  Future<List<V>> getListVideo();

  Future<List<V>> loadMore(List<V> currentList);
}