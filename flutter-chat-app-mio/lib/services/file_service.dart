import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  List<String> _files = [];

  Future<File> saveFile(File file) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${file.path.split('/').last}';
    print('Saving file to $filePath');
    return file.copy(filePath);
  }

  Future<void> pickFiles() async {
    // Seleccionar archivos
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      // Obtener el directorio para la carpeta personalizada
      final directory =
          await getApplicationDocumentsDirectory(); // Obtener el directorio de la aplicación
      final multimediaDir = Directory('${directory.path}/multimedia');

      // Crear la carpeta si no existe
      if (!await multimediaDir.exists()) {
        await multimediaDir.create(recursive: true);
      }

      for (var file in result.files) {
        if (file.path != null) {
          final originalFile = File(file.path!);
          final newFilePath = '${multimediaDir.path}/${file.name}';

          // Mover el archivo a la nueva ubicación
          await originalFile.copy(newFilePath);

          print('Archivo movido a: $newFilePath');
          _files.add(newFilePath);
        }
      }
    }
  }
}
