import 'package:teego/models/GiftsModel.dart';
import 'package:teego/models/HashTagsModel.dart';
import 'package:teego/models/UserModel.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
<<<<<<< HEAD
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
=======
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081

import 'GiftSendersModel.dart';

class LiveStreamingModel extends ParseObject implements ParseCloneable {
<<<<<<< HEAD
  static final String keyTableName = "Streamings";
=======

  static final String keyTableName = "Streaming";
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081

  LiveStreamingModel() : super(keyTableName);
  LiveStreamingModel.clone() : this();

  @override
<<<<<<< HEAD
  LiveStreamingModel clone(Map<String, dynamic> map) =>
      LiveStreamingModel.clone()..fromJson(map);
=======
  LiveStreamingModel clone(Map<String, dynamic> map) => LiveStreamingModel.clone()..fromJson(map);
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081

  static final String privacyTypeAnyone = "anyone";
  static final String privacyTypeFriends = "friends";
  static final String privacyTypeNoOne = "none";

  static final String liveTypeParty = "party";
  static final String liveTypeGoLive = "live";
  static final String liveTypeBattle = "battle";

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "Author";
  static String keyAuthorId = "AuthorId";
  static String keyAuthorUid = "AuthorUid";

  static String keyViewsCount = "viewsCount";

  static String keyAuthorInvited = "AuthorInvited";
  static String keyAuthorInvitedUid = "AuthorInvitedUid";

<<<<<<< HEAD
  static final String keyViewersUid = "viewers_uid";
  static final String keyViewersId = "viewers_id";
=======
   static final String keyViewersUid = "viewers_uid";
   static final String keyViewersId = "viewers_id";
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081

  static final String keyViewersCountLive = "viewersCountLive";
  static final String keyStreamingPrivate = "private";

<<<<<<< HEAD
  static final String keyLiveImage = "image";
  static final String keyLiveGeoPoint = "geoPoint";
  static final String keyLiveTags = "live_tag";

  static final String keyStreaming = "streamings";
  static final String keyStreamingTime = "streaming_time";
  static final String keyStreamingDiamonds = "streaming_diamonds";
  static final String keyAuthorTotalDiamonds = "author_total_diamonds";

=======
   static final String keyLiveImage = "image";
  static final String keyLiveGeoPoint = "geoPoint";
  static final String keyLiveTags = "live_tag";

   static final String keyStreaming = "streaming";
   static final String keyStreamingTime = "streaming_time";
   static final String keyStreamingDiamonds = "streaming_diamonds";
  static final String keyAuthorTotalDiamonds = "author_total_diamonds";


>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
  static final String keyStreamingChannel = "streaming_channel";

  static final String keyStreamingCategory = "streaming_category";

  static final String keyCoHostAvailable = "coHostAvailable";
  static final String keyCoHostAuthor = "coHostAuthor";
  static final String keyCoHostAuthorUid = "coHostAuthorUid";

  static final String keyHashTags = "hash_tags";
  static final String keyHashTagsId = "hash_tags_id";

  static final String keyPrivateLiveGift = "privateLivePrice";
  static final String keyPrivateViewers = "privateViewers";

  static final String keyFirstLive = "firstLive";

  static final String keyGiftSenders = "giftSenders";
  static final String keyGiftSendersAuthor = "giftSenders.author";

  static final String keyGiftSendersPicture = "giftSendersPicture";

  static final String keyInvitedBroadCasterId = "invitedBroadCasterId";

  static final String keyInvitationAccepted = "InvitationAccepted";

  static final String keyCoHostUID = "coHostUID";
  static final String keyEndByAdmin = "endByAdmin";

  static final String keyInvitedPartyUid = "invitedPartyUid";
  static final String keyInvitedPartyLive = "invitedPartyLive";
  static final String keyInvitedPartyLiveAuthor = "invitedPartyLive.Author";

<<<<<<< HEAD
=======

>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  int? get getAuthorUid => get<int>(keyAuthorUid);
  set setAuthorUid(int authorUid) => set<int>(keyAuthorUid, authorUid);

  UserModel? get getCoHostAuthor => get<UserModel>(keyCoHostAuthor);
<<<<<<< HEAD
  set setCoHostAuthor(UserModel author) =>
      set<UserModel>(keyCoHostAuthor, author);

  int? get getCoHostAuthorUid => get<int>(keyCoHostAuthorUid);
  set setCoHostAuthorUid(int authorUid) =>
      set<int>(keyCoHostAuthorUid, authorUid);

  bool? get getCoHostAuthorAvailable => get<bool>(keyCoHostAvailable);
  set setCoHostAvailable(bool coHostAvailable) =>
      set<bool>(keyCoHostAvailable, coHostAvailable);
=======
  set setCoHostAuthor(UserModel author) => set<UserModel>(keyCoHostAuthor, author);

  int? get getCoHostAuthorUid => get<int>(keyCoHostAuthorUid);
  set setCoHostAuthorUid(int authorUid) => set<int>(keyCoHostAuthorUid, authorUid);

  bool? get getCoHostAuthorAvailable => get<bool>(keyCoHostAvailable);
  set setCoHostAvailable(bool coHostAvailable) => set<bool>(keyCoHostAvailable, coHostAvailable);
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  String? get getInvitedBroadCasterId => get<String>(keyInvitedBroadCasterId);
<<<<<<< HEAD
  set setInvitedBroadCasterId(String authorId) =>
      set<String>(keyInvitedBroadCasterId, authorId);

  UserModel? get getAuthorInvited => get<UserModel>(keyAuthorInvited);
  set setAuthorInvited(UserModel invitedAuthor) =>
      set<UserModel>(keyAuthorInvited, invitedAuthor);

  int? get getAuthorInvitedUid => get<int>(keyAuthorInvitedUid);
  set setAuthorInvitedUid(int invitedAuthorUid) =>
      set<int>(keyAuthorInvitedUid, invitedAuthorUid);

  int? get getViewersCount {
    int? viewersCount = get<int>(keyViewersCountLive);
    if (viewersCount != null) {
=======
  set setInvitedBroadCasterId(String authorId) => set<String>(keyInvitedBroadCasterId, authorId);

  UserModel? get getAuthorInvited => get<UserModel>(keyAuthorInvited);
  set setAuthorInvited(UserModel invitedAuthor) => set<UserModel>(keyAuthorInvited, invitedAuthor);

  int? get getAuthorInvitedUid => get<int>(keyAuthorInvitedUid);
  set setAuthorInvitedUid(int invitedAuthorUid) => set<int>(keyAuthorInvitedUid, invitedAuthorUid);

  int? get getViewersCount{

    int? viewersCount = get<int>(keyViewersCountLive);
    if(viewersCount != null){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      return viewersCount;
    } else {
      return 0;
    }
  }
<<<<<<< HEAD

  set addViewersCount(int viewersCount) =>
      setIncrement(keyViewersCountLive, viewersCount);
  set removeViewersCount(int viewersCount) {
    if (getViewersCount! > 0) {
=======
  set addViewersCount(int viewersCount) => setIncrement(keyViewersCountLive, viewersCount);
  set removeViewersCount(int viewersCount) {

    if(getViewersCount! > 0){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      setDecrement(keyViewersCountLive, viewersCount);
    }
  }

<<<<<<< HEAD
  ParseFileBase? get getImage => get<ParseFileBase>(keyLiveImage);
  set setImage(ParseFileBase imageFile) =>
      set<ParseFileBase>(keyLiveImage, imageFile);

  String? get getImageUrl => get<String>('imageUrl');

  set setGifSenderImage(ParseFileBase imageFile) =>
      setAddUnique(keyGiftSendersPicture, imageFile);

  List<dynamic>? get getGifSenderImage {
    List<dynamic>? images = get<List<dynamic>>(keyGiftSendersPicture);
    if (images != null && images.length > 0) {
      return images;
    } else {
=======

  ParseFileBase? get getImage => get<ParseFileBase>(keyLiveImage);
  set setImage(ParseFileBase imageFile) => set<ParseFileBase>(keyLiveImage, imageFile);


  set setGifSenderImage(ParseFileBase imageFile) => setAddUnique(keyGiftSendersPicture, imageFile);

  List<dynamic>? get getGifSenderImage {

    List<dynamic>? images = get<List<dynamic>>(keyGiftSendersPicture);
    if(images != null && images.length > 0){
      return images;
    }else{
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      return [];
    }
  }

<<<<<<< HEAD
  List<dynamic>? get getCoHostUiD {
    List<dynamic>? coHostUiD = get<List<dynamic>>(keyCoHostUID);
    if (coHostUiD != null && coHostUiD.length > 0) {
=======
  List<dynamic>? get getCoHostUiD{

    List<dynamic>? coHostUiD = get<List<dynamic>>(keyCoHostUID);
    if(coHostUiD != null && coHostUiD.length > 0){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      return coHostUiD;
    } else {
      return [];
    }
  }
<<<<<<< HEAD

  set setCoHostUID(int coHostUiD) => setAddUnique(keyCoHostUID, coHostUiD);

  List<dynamic>? get getViewers {
    List<dynamic>? viewers = get<List<dynamic>>(keyViewersUid);
    if (viewers != null && viewers.length > 0) {
=======
  set setCoHostUID(int coHostUiD) => setAddUnique(keyCoHostUID, coHostUiD);


  List<dynamic>? get getViewers{

    List<dynamic>? viewers = get<List<dynamic>>(keyViewersUid);
    if(viewers != null && viewers.length > 0){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      return viewers;
    } else {
      return [];
    }
  }
<<<<<<< HEAD

  set setViewers(int viewerUid) => setAddUnique(keyViewersUid, viewerUid);

  List<dynamic>? get getViewersId {
    List<dynamic>? viewersId = get<List<dynamic>>(keyViewersId);
    if (viewersId != null && viewersId.length > 0) {
=======
  set setViewers(int viewerUid) => setAddUnique(keyViewersUid, viewerUid);

  List<dynamic>? get getViewersId{

    List<dynamic>? viewersId = get<List<dynamic>>(keyViewersId);
    if(viewersId != null && viewersId.length > 0){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      return viewersId;
    } else {
      return [];
    }
  }
<<<<<<< HEAD

  set setViewersId(String viewerAuthorId) =>
      setAddUnique(keyViewersId, viewerAuthorId);
=======
  set setViewersId(String viewerAuthorId) => setAddUnique(keyViewersId, viewerAuthorId);
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081

  int? get getDiamonds => get<int>(keyStreamingDiamonds);
  set addDiamonds(int diamonds) => setIncrement(keyStreamingDiamonds, diamonds);

  int? get getAuthorTotalDiamonds => get<int>(keyAuthorTotalDiamonds);
<<<<<<< HEAD
  set addAuthorTotalDiamonds(int diamonds) =>
      setIncrement(keyAuthorTotalDiamonds, diamonds);
=======
  set addAuthorTotalDiamonds(int diamonds) => setIncrement(keyAuthorTotalDiamonds, diamonds);
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081

  bool? get getStreaming => get<bool>(keyStreaming);
  set setStreaming(bool isStreaming) => set<bool>(keyStreaming, isStreaming);

  bool? get getFirstLive {
    var isFirstTime = get<bool>(keyFirstLive);

<<<<<<< HEAD
    if (isFirstTime != null) {
      return isFirstTime;
    } else {
=======
    if(isFirstTime != null){
      return isFirstTime;
    }else{
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      return false;
    }
  }

  set setFirstLive(bool isFirstLive) => set<bool>(keyFirstLive, isFirstLive);

<<<<<<< HEAD
  String? get getStreamingTime => get<String>(keyStreamingTime);
  set setStreamingTime(String streamingTime) =>
      set<String>(keyStreamingTime, streamingTime);

  String? get getStreamingCategory => get<String>(keyStreamingCategory);
  set setStreamingCategory(String streamingCategory) =>
      set<String>(keyStreamingCategory, streamingCategory);

  String? get getStreamingTags {
    String? text = get<String>(keyLiveTags);
    if (text != null) {
=======


  String? get getStreamingTime => get<String>(keyStreamingTime);
  set setStreamingTime(String streamingTime) => set<String>(keyStreamingTime, streamingTime);

  String? get getStreamingCategory => get<String>(keyStreamingCategory);
  set setStreamingCategory(String streamingCategory) => set<String>(keyStreamingCategory, streamingCategory);

  String? get getStreamingTags {
    String? text = get<String>(keyLiveTags);
    if(text != null){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      return text;
    } else {
      return "";
    }
  }

  set setStreamingTags(String text) => set<String>(keyLiveTags, text);

  String? get getStreamingChannel => get<String>(keyStreamingChannel);
<<<<<<< HEAD
  set setStreamingChannel(String streamingChannel) =>
      set<String>(keyStreamingChannel, streamingChannel);

  ParseGeoPoint? get getStreamingGeoPoint =>
      get<ParseGeoPoint>(keyLiveGeoPoint);
  set setStreamingGeoPoint(ParseGeoPoint liveGeoPoint) =>
      set<ParseGeoPoint>(keyLiveGeoPoint, liveGeoPoint);

  bool? get getPrivate {
    bool? private = get<bool>(keyStreamingPrivate);
    if (private != null) {
=======
  set setStreamingChannel(String streamingChannel) => set<String>(keyStreamingChannel, streamingChannel);

  ParseGeoPoint? get getStreamingGeoPoint => get<ParseGeoPoint>(keyLiveGeoPoint);
  set setStreamingGeoPoint(ParseGeoPoint liveGeoPoint) => set<ParseGeoPoint>(keyLiveGeoPoint, liveGeoPoint);

  bool? get getPrivate{
    bool? private = get<bool>(keyStreamingPrivate);
    if(private != null){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      return private;
    } else {
      return false;
    }
  }
<<<<<<< HEAD

  set setPrivate(bool private) => set<bool>(keyStreamingPrivate, private);

  bool? get getInvitationAccepted {
    bool? accepted = get<bool>(keyInvitationAccepted);
    if (accepted != null) {
=======
  set setPrivate(bool private) => set<bool>(keyStreamingPrivate, private);

  bool? get getInvitationAccepted{
    bool? accepted = get<bool>(keyInvitationAccepted);
    if(accepted != null){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      return accepted;
    } else {
      return false;
    }
  }
<<<<<<< HEAD

  set setInvitationAccepted(bool accepted) =>
      set<bool>(keyInvitationAccepted, accepted);

  List<String>? get getHashtags {
    var arrayString = get<List<dynamic>>(keyHashTagsId);

    if (arrayString != null) {
=======
  set setInvitationAccepted(bool accepted) => set<bool>(keyInvitationAccepted, accepted);




  List<String>? get getHashtags{

    var arrayString =  get<List<dynamic>>(keyHashTagsId);

    if(arrayString != null){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      List<String> users = new List<String>.from(arrayString);
      return users;
    } else {
      return [];
    }
<<<<<<< HEAD
  }

  List<dynamic>? get getHashtagsForQuery {
    var arrayString = get<List<dynamic>>(keyHashTags);

    if (arrayString != null) {
=======

  }

  List<dynamic>? get getHashtagsForQuery{

    var arrayString =  get<List<dynamic>>(keyHashTags);

    if(arrayString != null){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      List<String> users = new List<String>.from(arrayString);
      return users;
    } else {
      return [];
    }
<<<<<<< HEAD
  }

  set setHashtags(List<HashTagModel> hashtags) {
    List<String> hashTagsList = [];

    for (HashTagModel hashTag in hashtags) {
=======

  }

  set setHashtags(List<HashTagModel> hashtags) {

    List<String> hashTagsList = [];

    for(HashTagModel hashTag in hashtags){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      hashTagsList.add(hashTag.objectId!);
    }

    setAddAllUnique(keyHashTags, hashtags);
    setAddAllUnique(keyHashTagsId, hashTagsList);
  }

  GiftsModel? get getPrivateGift => get<GiftsModel>(keyPrivateLiveGift);
<<<<<<< HEAD
  set setPrivateLivePrice(GiftsModel privateLivePrice) =>
      set<GiftsModel>(keyPrivateLiveGift, privateLivePrice);
  set removePrice(GiftsModel privateLivePrice) =>
      setRemove(keyPrivateLiveGift, privateLivePrice);

  List<dynamic>? get getPrivateViewersId {
    List<dynamic>? viewersId = get<List<dynamic>>(keyPrivateViewers);
    if (viewersId != null && viewersId.length > 0) {
=======
  set setPrivateLivePrice(GiftsModel privateLivePrice) => set<GiftsModel>(keyPrivateLiveGift, privateLivePrice);
  set removePrice(GiftsModel privateLivePrice) => setRemove(keyPrivateLiveGift, privateLivePrice);

  List<dynamic>? get getPrivateViewersId{

    List<dynamic>? viewersId = get<List<dynamic>>(keyPrivateViewers);
    if(viewersId != null && viewersId.length > 0){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      return viewersId;
    } else {
      return [];
    }
  }
<<<<<<< HEAD

  set setPrivateViewersId(String viewerAuthorId) =>
      setAddUnique(keyPrivateViewers, viewerAuthorId);

  set setPrivateListViewersId(List viewersId) {
    List<String> listViewersId = [];

    for (String privateViewer in viewersId) {
=======
  set setPrivateViewersId(String viewerAuthorId) => setAddUnique(keyPrivateViewers, viewerAuthorId);

  set setPrivateListViewersId(List viewersId) {

    List<String> listViewersId = [];

    for(String privateViewer in viewersId){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      listViewersId.add(privateViewer);
    }
    setAddAllUnique(keyPrivateViewers, listViewersId);
  }

<<<<<<< HEAD
  List<dynamic>? get getGiftsSenders {
    List<dynamic>? giftSenders = get<List<dynamic>>(keyGiftSenders);
    if (giftSenders != null && giftSenders.length > 0) {
=======
  List<dynamic>? get getGiftsSenders{

    List<dynamic>? giftSenders = get<List<dynamic>>(keyGiftSenders);
    if(giftSenders != null && giftSenders.length > 0){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      return giftSenders;
    } else {
      return [];
    }
  }
<<<<<<< HEAD

  set addGiftsSenders(GiftsSenderModel giftsSenderModel) =>
      setAddUnique(keyGiftSenders, giftsSenderModel);

  bool? get isLiveCancelledByAdmin {
    bool? cancelled = get<bool>(keyEndByAdmin);
    if (cancelled != null) {
=======
  set addGiftsSenders(GiftsSenderModel giftsSenderModel) => setAddUnique(keyGiftSenders, giftsSenderModel);

  bool? get isLiveCancelledByAdmin{
    bool? cancelled = get<bool>(keyEndByAdmin);
    if(cancelled != null){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      return cancelled;
    } else {
      return false;
    }
  }

  set setTerminatedByAdmin(bool yes) => set<bool>(keyEndByAdmin, yes);

<<<<<<< HEAD
  List<dynamic>? get getInvitedPartyUid {
    List<dynamic>? invitedUid = get<List<dynamic>>(keyInvitedPartyUid);
    if (invitedUid != null && invitedUid.length > 0) {
=======
  List<dynamic>? get getInvitedPartyUid{

    List<dynamic>? invitedUid = get<List<dynamic>>(keyInvitedPartyUid);
    if(invitedUid != null && invitedUid.length > 0){
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
      return invitedUid;
    } else {
      return [];
    }
  }
<<<<<<< HEAD

  set addInvitedPartyUid(List<dynamic> uidList) =>
      setAddAllUnique(keyInvitedPartyUid, uidList);

  set removeInvitedPartyUid(int uid) => setRemove(keyInvitedPartyUid, uid);

  LiveStreamingModel? get getInvitationLivePending =>
      get<LiveStreamingModel>(keyInvitedPartyLive);

  set setInvitationLivePending(LiveStreamingModel live) =>
      set<LiveStreamingModel>(keyInvitedPartyLive, live);

  removeInvitationLivePending() => unset(keyInvitedPartyLive);
}
=======
  set addInvitedPartyUid(List<dynamic> uidList) => setAddAllUnique(keyInvitedPartyUid, uidList);

  set removeInvitedPartyUid(int uid) => setRemove(keyInvitedPartyUid, uid);

  LiveStreamingModel? get getInvitationLivePending => get<LiveStreamingModel>(keyInvitedPartyLive);

  set setInvitationLivePending(LiveStreamingModel live) => set<LiveStreamingModel>(keyInvitedPartyLive, live);

  removeInvitationLivePending() => unset(keyInvitedPartyLive);
}
>>>>>>> c9f3eb7d525e0c1c8d131cfd46809dc908299081
