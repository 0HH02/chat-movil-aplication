import 'package:http/http.dart' as http;
import 'package:chat/models/usuario.dart';
import 'package:chat/models/usuarios_response.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/global/environment.dart';

class UsuariosService {
  Future<List<Usuario>> getUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse('${Environment.apiUrl}/usuarios'), // Convertir a Uri
        headers: {
          'Content-Type': 'application/json',
          'x-token': await AuthService.getToken(),
        },
      );

      if (response.statusCode == 200) {
        final usuariosResponse = usuariosResponseFromJson(response.body);
        return usuariosResponse.usuarios;
      } else {
        // Manejo de errores basado en el código de estado HTTP
        print('Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // Manejo de excepciones
      print('Exception: $e');
      return [];
    }
  }
}
