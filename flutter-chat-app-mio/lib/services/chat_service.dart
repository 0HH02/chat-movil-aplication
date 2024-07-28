import 'package:chat/models/mensajes_response.dart';
import 'package:chat/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:chat/global/environment.dart';
import 'package:chat/models/usuario.dart';

class ChatService with ChangeNotifier {
  late Usuario usuarioPara;

  Future<List<Mensaje>> getChat(String usuarioID) async {
    try {
      final uri = Uri.parse('${Environment.apiUrl}/mensajes/$usuarioID');
      final token = await AuthService.getToken();

      final resp = await http.get(
        uri,
        headers: {'Content-Type': 'application/json', 'x-token': token},
      );

      if (resp.statusCode == 200) {
        final mensajesResp = mensajesResponseFromJson(resp.body);
        return mensajesResp.mensajes;
      } else {
        // Maneja errores, por ejemplo, lanzando una excepción o devolviendo una lista vacía
        throw Exception('Failed to load chat messages');
      }
    } catch (e) {
      // Manejo de errores, como loguear el error o devolver una lista vacía
      print('Error en getChat: $e');
      return [];
    }
  }
}
