import 'package:chat/pages/chat/multimedia/camera_page.dart';
import 'package:chat/pages/prueba_page.dart';
import 'package:flutter/material.dart';

import 'package:chat/pages/chat/chat_page.dart';
import 'package:chat/pages/loading_page.dart';
import 'package:chat/pages/auth/login_page.dart';
import 'package:chat/pages/auth/register_page.dart';
import 'package:chat/pages/chat/usuarios_page.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  'usuarios': (_) => UsuariosPage(),
  'chat': (_) => ChatPage(),
  'login': (_) => LoginPage(),
  'register': (_) => RegisterPage(),
  'loading': (_) => LoadingPage(),
  'camera': (_) => CameraPage(),
  'prueba': (_) => PruebaPage(),
};
