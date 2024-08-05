import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

part 'messages.g.dart';

@HiveType(typeId: 1)
class Chats extends HiveObject {
  Chats({required this.other, required this.messages});

  @HiveField(0)
  String other;

  @HiveField(1)
  List<PrivateMessages> messages;

  @override
  String toString() {
    return 'message from: $other say: $messages';
  }
}

@HiveType(typeId: 2)
class PrivateMessages {
  @HiveField(0)
  final String from;

  @HiveField(1)
  final String to;

  @HiveField(2)
  String messages;

  @HiveField(3)
  final String id;

  @HiveField(4)
  final String reference;

  @HiveField(5)
  String? multimedia;

  @HiveField(6)
  String mediaType;

  @HiveField(7)
  bool liked;

  @HiveField(8)
  bool seen;

  @HiveField(9)
  String date;

  PrivateMessages(
      {required this.from,
      required this.to,
      String? messages,
      String? id,
      String? reference,
      String? multimedia,
      String? mediaType,
      bool? liked,
      bool? seen,
      String? date})
      : messages = messages ?? '',
        id = id ?? Uuid().v4(),
        reference = reference ?? '',
        multimedia = multimedia ?? '',
        mediaType = mediaType ?? 'text',
        liked = liked ?? false,
        seen = seen ?? false,
        date = DateTime.now().toString();

  @override
  String toString() {
    return 'id: $id from: $from to: $to say: $messages, multimedia: $multimedia, mediaType: $mediaType, liked: $liked, seen: $seen, date: $date';
  }
}
