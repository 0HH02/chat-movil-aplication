import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> getDirectoryPath(String subDir) async {
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/$subDir';
  final dir = Directory(path);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return path;
}

Future<String> saveFile(String mediaType, List<dynamic> multimedia) async {
  String path = '';

  // Definir el nombre del archivo según el tipo de medio
  String fileName;
  if (mediaType == 'image') {
    fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    path = await getDirectoryPath('Photos');
  } else if (mediaType == 'video') {
    fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    path = await getDirectoryPath('Videos');
  } else if (mediaType == 'audio') {
    fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    path = await getDirectoryPath('Audio');
  } else {
    throw Exception('Unsupported media type');
  }

  final filePath = '$path/$fileName';

  final file = File(filePath);
  await file.writeAsBytes(multimedia as List<int>);

  return filePath;
}
