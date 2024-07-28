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
  final String messages;

  @HiveField(3)
  final String id;

  @HiveField(4)
  final bool isAudio;

  @HiveField(5)
  final List<int>? audioData; // Campo para almacenar los bytes del audio

  PrivateMessages({
    required this.from,
    required this.to,
    required this.messages,
    this.audioData,
    String? id,
  })  : id = id ?? Uuid().v4(),
        isAudio = audioData != null;

  @override
  String toString() {
    return 'id: $id from: $from to: $to say: $messages';
  }
}
