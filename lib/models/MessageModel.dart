import 'package:teego/models/CallsModel.dart';
import 'package:teego/models/MessageListModel.dart';
import 'package:teego/models/UserModel.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class MessageModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "Message";

  MessageModel() : super(keyTableName);
  MessageModel.clone() : this();

  @override
  MessageModel clone(Map<String, dynamic> map) => MessageModel.clone()..fromJson(map);

  static String messageTypeText = "text";
  static String messageTypeGif = "gif";
  static String messageTypePicture = "picture";
  static String messageTypeCall = "call";

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "Author";
  static String keyAuthorId = "AuthorId";

  static String keyReceiver = "Receiver";
  static String keyReceiverId = "ReceiverId";

  static final String keyText = "text";
  static final String keyMessageFile = "messageFile";
  static final String keyIsMessageFile = "isMessageFile";

  static final String keyRead = "read";

  static final String keyListMessage = "messageList";
  static final String keyListMessageId = "messageListId";

  static final String keyGifMessage = "gifMessage";
  static final String keyPictureMessage = "pictureMessage";

  static final String keyMessageType= "messageType";

  static final String keyCall= "call";

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  UserModel? get getReceiver => get<UserModel>(keyReceiver);
  set setReceiver(UserModel author) => set<UserModel>(keyReceiver, author);

  String? get getReceiverId => get<String>(keyReceiverId);
  set setReceiverId(String authorId) => set<String>(keyReceiverId, authorId);

  String? get getDuration => get<String>(keyText);
  set setDuration(String message) => set<String>(keyText, message);

  ParseFileBase? get getMessageFile => get<ParseFileBase>(keyMessageFile);
  set setMessageFile(ParseFileBase messageFile) => set<ParseFileBase>(keyMessageFile, messageFile);

  bool? get isMessageFile => get<bool>(keyMessageFile);
  set setIsMessageFile(bool isMessageFile) => set<bool>(keyMessageFile, isMessageFile);

  bool? get isRead => get<bool>(keyRead);
  set setIsRead(bool isRead) => set<bool>(keyRead, isRead);

  MessageListModel? get getMessageList => get<MessageListModel>(keyListMessage);
  set setMessageList(MessageListModel messageListModel) => set<MessageListModel>(keyListMessage, messageListModel);

  String? get getMessageListId => get<String>(keyListMessageId);
  set setMessageListId(String messageListId) => set<String>(keyListMessageId, messageListId);

  ParseFileBase? get getGifMessage => get<ParseFileBase>(keyGifMessage);
  set setGifMessage(ParseFileBase gifMessage) => set<ParseFileBase>(keyGifMessage, gifMessage);

  String? get getMessageType => get<String>(keyMessageType);
  set setMessageType(String messageType) => set<String>(keyMessageType, messageType);

  ParseFileBase? get getPictureMessage => get<ParseFileBase>(keyPictureMessage);
  set setPictureMessage(ParseFileBase pictureMessage) => set<ParseFileBase>(keyPictureMessage, pictureMessage);

  CallsModel? get getCall => get<CallsModel>(keyCall);
  set setCall(CallsModel call) => set<CallsModel>(keyCall, call);

}