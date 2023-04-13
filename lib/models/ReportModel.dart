import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teego/models/LiveStreamingModel.dart';
import 'package:teego/models/PostsModel.dart';

import 'UserModel.dart';

class ReportModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "Report";

  ReportModel() : super(keyTableName);
  ReportModel.clone() : this();

  @override
  ReportModel clone(Map<String, dynamic> map) => ReportModel.clone()..fromJson(map);

  static String reportTypeProfile = "PROFILE";
  static String reportTypePost = "POST";
  static String reportTypeLiveStreaming = "LIVE";

  static String keyCreatedAt = "createdAt";
  static String keyUpdatedAt = "updatedAt";
  static String keyObjectId = "objectId";

  static String stateResolved = "resolved";
  static String statePending = "pending";

  static const THIS_POST_HAS_SEXUAL_CONTENTS = "SC";
  static const FAKE_PROFILE_SPAN = "FPS";
  static const INAPPROPRIATE_MESSAGE = "IM";
  static const UNDERAGE_USER = "UA";
  static const SOMEONE_IS_IN_DANGER = "SID";

  static String keyAccuser = "accuser";
  static String keyAccuserId = "accuserId";

  static String keyAccused = "accused";
  static String keyAccusedId = "accusedId";

  static String keyMessage = "message";

  static String keyDescription = "description";

  static String keyState = "state";
  static String keyReportType = "reportType";

  static String keyReportPost = "post";
  static String keyReportLiveStreaming = "live";

  String? get getReportType => get<String>(keyReportType);
  set setReportType(String reportType) => set<String>(keyReportType, reportType);

  UserModel? get getAccuser => get<UserModel>(keyAccuser);
  set setAccuser(UserModel author) => set<UserModel>(keyAccuser, author);

  String? get getAccuserId => get<String>(keyAccuserId);
  set setAccuserId(String authorId) => set<String>(keyAccuserId, authorId);

  UserModel? get getAccused => get<UserModel>(keyAccused);
  set setAccused(UserModel user) => set<UserModel>(keyAccused, user);

  String? get getAccusedId => get<String>(keyAccusedId);
  set setAccusedId(String userId) => set<String>(keyAccusedId, userId);

  String? get getMessage => get<String>(keyMessage);
  set setMessage(String message) => set<String>(keyMessage, message);

  String? get getDescription => get<String>(keyDescription);
  set setDescription(String description) => set<String>(keyDescription, description);

  String? get getState => get<String>(keyState);
  set setState(String state) => set<String>(keyState, state);

  PostsModel? get getPost => get<PostsModel>(keyReportPost);
  set setPost(PostsModel postsModel) => set<PostsModel>(keyReportPost, postsModel);

  LiveStreamingModel? get getLiveStreaming => get<LiveStreamingModel>(keyReportLiveStreaming);
  set setLiveStreaming(LiveStreamingModel liveStreamingModel) => set<LiveStreamingModel>(keyReportLiveStreaming, liveStreamingModel);

}