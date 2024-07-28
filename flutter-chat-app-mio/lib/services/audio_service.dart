import 'dart:io';
import 'package:chat/global/environment.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:convert';

class AudioService with ChangeNotifier {
  static Future<String> uploadAudio(String filePath) async {
    final File file = File(filePath);
    final String fileName = basename(file.path);

    var request = http.MultipartRequest('POST', Uri.parse(Environment.apiUrl));
    request.files.add(await http.MultipartFile.fromPath('file', file.path,
        filename: fileName));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);
      return jsonResponse[
          'url']; // Asegúrate de que el servidor devuelve la URL del archivo subido en este campo
    } else {
      throw Exception('Error al subir el archivo');
    }
  }
}
