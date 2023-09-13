import 'package:teego/models/MessageModel.dart';
import 'package:teego/models/UserModel.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'CallsModel.dart';

class MessageListModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "MessageList";

  MessageListModel() : super(keyTableName);
  MessageListModel.clone() : this();

  @override
  MessageListModel clone(Map<String, dynamic> map) => MessageListModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyListId = "listId";

  static String keyAuthor = "Author";
  static String keyAuthorId = "AuthorId";

  static String keyReceiver = "Receiver";
  static String keyReceiverId = "ReceiverId";

  static String keyMessageCounter = "Counter";

  static final String keyText = "text";
  static final String keyMessageFile = "messageFile";
  static final String keyIsMessageFile = "isMessageFile";

  static final String keyRead = "read";

  static final String keyMessage = "message";
  static final String keyMessageId = "messageId";

  static final String keyMessageType= "messageType";
  static final String keyCall= "call";

  CallsModel? get getCall => get<CallsModel>(keyCall);
  set setCall(CallsModel call) => set<CallsModel>(keyCall, call);

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  UserModel? get getReceiver => get<UserModel>(keyReceiver);
  set setReceiver(UserModel author) => set<UserModel>(keyReceiver, author);

  String? get getReceiverId => get<String>(keyReceiverId);
  set setReceiverId(String authorId) => set<String>(keyReceiverId, authorId);

  String? get getText => get<String>(keyText);
  set setText(String text) => set<String>(keyText, text);

  String? get getMessageId => get<String>(keyMessageId);
  set setMessageId(String messageId) => set<String>(keyMessageId, messageId);

  String? get getListId => get<String>(keyListId);
  set setListId(String listId) => set<String>(keyListId, listId);

  ParseFileBase? get getMessageFile => get<ParseFileBase>(keyMessageFile);
  set setMessageFile(ParseFileBase messageFile) => set<ParseFileBase>(keyMessageFile, messageFile);

  bool? get isMessageFile => get<bool>(keyMessageFile);
  set setIsMessageFile(bool isMessageFile) => set<bool>(keyMessageFile, isMessageFile);

  bool? get isRead => get<bool>(keyRead);
  set setIsRead(bool isRead) => set<bool>(keyRead, isRead);

  MessageModel? get getMessage => get<MessageModel>(keyMessage);
  set setMessage(MessageModel messageModel) => set<MessageModel>(keyMessage, messageModel);

  String? get getMessageType => get<String>(keyMessageType);
  set setMessageType(String messageType) => set<String>(keyMessageType, messageType);

  int? get getCounter => get<int>(keyMessageCounter);
  set setCounter(int count) => set<int>(keyMessageCounter, count);
  set incrementCounter(int count) => setIncrement(keyMessageCounter, count);
}