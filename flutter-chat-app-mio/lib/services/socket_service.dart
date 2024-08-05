import 'package:chat/global/environment.dart';
import 'package:chat/helpers/aux_functions.dart';
import 'package:chat/models/messages.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/hive_service.dart';
import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;
  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;

  void emit(String event, dynamic data) {
    if (socket.connected) {
      print('Emitiendo evento: $event con datos: $data');
      this._socket.emit(event, data);
    } else {
      print('Socket no conectado');
    }
  }

  void connect() async {
    try {
      final token = await AuthService.getToken();
      print('Token obtenido: $token'); // Verifica que se obtiene el token

      // Configuración del cliente Dart
      this._socket = IO.io(Environment.socketUrl, {
        'transports': ['websocket'],
        'autoConnect': true,
        'forceNew': true,
        'extraHeaders': {'x-token': token}
      });

      this._socket.on('connect', (_) {
        print('Conectado al servidor');
        this._serverStatus = ServerStatus.Online;
        notifyListeners();
      });

      this._socket.on('disconnect', (_) {
        print('Desconectado del servidor');
        this._serverStatus = ServerStatus.Offline;
        notifyListeners();
      });

      this._socket.on('mensaje-personal', (payload) async {
        try {
          print('Mensaje recibido: $payload');
          var currentId = HiveService().currentId;
          final mediaType = payload['mediaType'];
          final multimedia = payload['multimedia'];
          String filePath = '';
          if (multimedia.isNotEmpty) {
            filePath = await saveFile(mediaType, multimedia);
            print('File saved at: $filePath');
            // Usa filePath como necesites en tu aplicación
            print(payload['mid']);
          }
          PrivateMessages storage_message = PrivateMessages(
            from: payload['de'].toString(),
            to: currentId,
            messages: payload['mensaje'],
            id: payload['mid'],
            multimedia: filePath,
            mediaType: payload['mediaType'],
            reference: payload['reference'],
            date: payload['date'],
          );
          try {
            await HiveService().addMessage(storage_message, currentId);
          } catch (e) {
            print('Error al guardar mensaje en Hive: $e');
          }
          this.emit('confirmar-recepcion', {
            'mid': payload['mid'],
            'para': currentId,
            'de': payload['de'].toString()
          });
          notifyListeners();
        } catch (e) {
          print('Error saving file: $e');
        }
      });

      this._socket.on('confirmar-visto', (payload) async {
        print('visto recibido: $payload');
        HiveService().updateMessage(payload['mid']);

        this.emit('confirmar-visto', {
          'mid': payload['mid'],
          'para': payload['para'].toString(),
          'de': payload['de'].toString()
        });
        notifyListeners();
      });

      this._socket.on('connect_error', (error) {
        print(
            'Error de conexión: $error'); // Agrega este manejador para ver errores de conexión
      });

      this._socket.on('error', (error) {
        print(
            'Error general: $error'); // Agrega este manejador para errores generales
      });
    } catch (e) {
      print('Error en la conexión: $e');
    }
  }

  void disconnect() {
    this._socket.disconnect();
  }
}
