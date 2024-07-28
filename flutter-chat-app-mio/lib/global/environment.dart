import 'dart:io';

class Environment {
  static String apiUrl = Platform.isAndroid
      ? 'http://192.168.130.209:3000/api'
      : 'http://localhost:3000/api';
  static String socketUrl = Platform.isAndroid
      ? 'http://192.168.130.209:3000'
      : 'http://localhost:3000';

  // static String apiUrl = 'http://localhost:3000/api';
  // static String socketUrl = 'http://localhost:3000';
}