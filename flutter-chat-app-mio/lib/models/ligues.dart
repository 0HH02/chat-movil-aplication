// To parse this JSON data, do
//
//     final posiblesLigues = posiblesLiguesFromJson(jsonString);

import 'dart:convert';

import 'package:chat/models/messages.dart';

PosiblesLigues posiblesLiguesFromJson(String str) =>
    PosiblesLigues.fromJson(json.decode(str));

String posiblesLiguesToJson(PosiblesLigues data) => json.encode(data.toJson());

class PosiblesLigues {
  PosiblesLigues({
    required this.online,
    required this.nombre,
    required this.uid,
    required this.photo,
  });

  bool online;
  String nombre;
  String photo;
  String uid;
  PrivateMessages? last_message;

  factory PosiblesLigues.fromJson(Map<String, dynamic> json) => PosiblesLigues(
        online: json["online"],
        nombre: json["nombre"],
        photo: json["photo"],
        uid: json["id"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "online": online,
        "nombre": nombre,
        "photo": photo,
        "uid": uid,
      };
}
