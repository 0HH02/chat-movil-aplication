import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:chat/models/messages.dart'; // Importa tu clase anotada

class HiveService {
  static final HiveService _instance = HiveService._internal();

  factory HiveService() {
    return _instance;
  }

  HiveService._internal();

  Box<Chats>? _messagesBox;
  Box<String>? _currentId;

  Future<void> initHive() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
    Hive.registerAdapter(ChatsAdapter());
    Hive.registerAdapter(PrivateMessagesAdapter());
    _messagesBox = await Hive.openBox<Chats>('personal_messages');
    _currentId = await Hive.openBox<String>('current_user_id');
  }

  void setId(String newId) {
    _currentId!.put('current_user_id', newId);
  }

  void deleteId() {
    _currentId!.delete('current_user_id');
  }

  Future<void> addMessage(PrivateMessages message, dynamic currentUser) async {
    currentUser = currentUser.toString();
    var box = _messagesBox!;

    // Buscar un chat existente con el remitente o receptor
    var chat = box.values.firstWhere(
        (chat) => chat.other == message.from || chat.other == message.to,
        orElse: () => Chats(
            other: message.to == currentUser ? message.from : message.to,
            messages: []));

    chat.messages.add(message);

    if (!box.values.contains(chat)) {
      await box.add(chat);
    } else {
      await chat.save();
    }
  }

  List<PrivateMessages> getMessagesForUser(String userId) {
    var box = _messagesBox!;
    var chats = box.values.where((chat) => chat.other == userId);
    if (chats.isNotEmpty) {
      return chats.first.messages.reversed.toList();
    }
    return [];
  }

  PrivateMessages getLastMessagesForUser(String userId) {
    var box = _messagesBox!;
    var chats = box.values.where((chat) => chat.other == userId);
    if (chats.isNotEmpty) {
      return chats.first.messages.last;
    }
    return PrivateMessages(from: "0", to: "0", messages: "");
  }

  Box<Chats> get messagesBox {
    if (_messagesBox == null) {
      throw Exception("Hive box not initialized");
    }
    return _messagesBox!;
  }

  String get currentId {
    if (_messagesBox == null) {
      throw Exception("Hive box not initialized");
    }
    return _currentId!.get('current_user_id')!;
  }
}
