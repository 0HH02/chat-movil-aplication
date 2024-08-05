// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatsAdapter extends TypeAdapter<Chats> {
  @override
  final int typeId = 1;

  @override
  Chats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Chats(
      other: fields[0] as String,
      messages: (fields[1] as List).cast<PrivateMessages>(),
    );
  }

  @override
  void write(BinaryWriter writer, Chats obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.other)
      ..writeByte(1)
      ..write(obj.messages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PrivateMessagesAdapter extends TypeAdapter<PrivateMessages> {
  @override
  final int typeId = 2;

  @override
  PrivateMessages read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrivateMessages(
      from: fields[0] as String,
      to: fields[1] as String,
      messages: fields[2] as String?,
      id: fields[3] as String?,
      reference: fields[4] as String?,
      multimedia: fields[5] as String?,
      mediaType: fields[6] as String?,
      liked: fields[7] as bool?,
      seen: fields[8] as bool?,
      date: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PrivateMessages obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.from)
      ..writeByte(1)
      ..write(obj.to)
      ..writeByte(2)
      ..write(obj.messages)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.reference)
      ..writeByte(5)
      ..write(obj.multimedia)
      ..writeByte(6)
      ..write(obj.mediaType)
      ..writeByte(7)
      ..write(obj.liked)
      ..writeByte(8)
      ..write(obj.seen)
      ..writeByte(9)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivateMessagesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
