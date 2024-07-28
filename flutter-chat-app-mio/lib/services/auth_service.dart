import 'dart:convert';

import 'package:chat/services/hive_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:chat/global/environment.dart';
import 'package:chat/models/login_response.dart';
import 'package:chat/models/usuario.dart';

class AuthService with ChangeNotifier {
  late Usuario usuario;
  bool _autenticando = false;

  final _storage = FlutterSecureStorage();

  bool get autenticando => this._autenticando;
  set autenticando(bool valor) {
    this._autenticando = valor;
    notifyListeners();
  }

  // Getters del token de forma estática
  static Future<String> getToken() async {
    final _storage = FlutterSecureStorage();
    final token = await _storage.read(key: 'token');
    return token ?? ''; // Maneja el caso en que el token es null
  }

  static Future<void> deleteToken() async {
    try {
      FlutterSecureStorage().delete(key: 'token');
    } catch (error) {
      print(
          "Ocurrió un error mientras se intentaba borrar el currentId de la bd interna. Error en la función: deleteToken() de auth_service.dart");
    }
  }

  Future<bool> login(String email, String password) async {
    this.autenticando = true;

    final data = {'email': email, 'password': password};

    final uri = Uri.parse('${Environment.apiUrl}/login');
    final resp = await http.post(uri,
        body: jsonEncode(data), headers: {'Content-Type': 'application/json'});

    this.autenticando = false;

    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      this.usuario = loginResponse.usuario;
      HiveService().setId(this.usuario.uid);
      await this._guardarToken(loginResponse.token);
      return true;
    } else {
      return false;
    }
  }

  Future<dynamic> register(String nombre, String email, String password) async {
    this.autenticando = true;

    final data = {'nombre': nombre, 'email': email, 'password': password};

    final uri = Uri.parse('${Environment.apiUrl}/login/new');
    final resp = await http.post(uri,
        body: jsonEncode(data), headers: {'Content-Type': 'application/json'});

    this.autenticando = false;

    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      this.usuario = loginResponse.usuario;
      HiveService().setId(this.usuario.uid);
      await this._guardarToken(loginResponse.token);
      return true;
    } else {
      final respBody = jsonDecode(resp.body);
      return respBody['msg'];
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await this._storage.read(key: 'token');

    final uri = Uri.parse('${Environment.apiUrl}/login/renew');
    final resp = await http.get(uri,
        headers: {'Content-Type': 'application/json', 'x-token': token ?? ''});
    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      this.usuario = loginResponse.usuario;
      await this._guardarToken(loginResponse.token);

      return true;
    } else {
      this.logout();
      return false;
    }
  }

  Future<void> _guardarToken(String token) async {
    return await _storage.write(key: 'token', value: token);
  }

  Future<void> logout() async {
    try {
      HiveService().deleteId();
    } catch (error) {
      print(
          "Ocurrió un error mientras se intentaba borrar el currentId de la bd interna. Error en la función: logout() de auth_service.dart");
    }
    await _storage.delete(key: 'token');
  }
}
