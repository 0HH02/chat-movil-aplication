import 'dart:io';

import 'package:chat/models/messages.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:chat/services/hive_service.dart';
import 'package:chat/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PreviewPage extends StatefulWidget {
  final List<String> filePaths; // Lista de rutas de archivos

  const PreviewPage({Key? key, required this.filePaths}) : super(key: key);

  @override
  State<PreviewPage> createState() => PreviewPageState();
}

class PreviewPageState extends State<PreviewPage> {
  List<VideoPlayerController?> _controllers = [];
  late List<TextEditingController> _textControllers;
  AuthService? authService;
  ChatService? chatService;
  SocketService? socketService;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    this.authService = Provider.of<AuthService>(context, listen: false);
    this.chatService = Provider.of<ChatService>(context, listen: false);
    this.socketService = Provider.of<SocketService>(context, listen: false);
    _textControllers = List.generate(widget.filePaths.length, (index) {
      return TextEditingController();
    });
    _initializeVideoControllers();
  }

  Future<void> _initializeVideoControllers() async {
    for (var path in widget.filePaths) {
      if (path.endsWith('.mp4')) {
        final controller = VideoPlayerController.file(File(path));
        await controller.initialize();
        await controller.setLooping(true);
        _controllers.add(controller);
      } else {
        _controllers.add(null); // Placeholder for non-video items
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller?.dispose();
    }
    _textControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<String> _getDirectoryPath(String subDir) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$subDir';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  Future<List<String>> _saveFiles(List<String> filePaths) async {
    final photosDir = await _getDirectoryPath('Photos');
    final videosDir = await _getDirectoryPath('Videos');

    List<String> newPaths = [];
    for (var path in filePaths) {
      final file = File(path);
      if (await file.exists()) {
        final fileName = path.split('/').last;
        final newPath = path.endsWith('.mp4')
            ? '$videosDir/$fileName'
            : '$photosDir/$fileName';
        await file.copy(newPath);
        print('File saved to: $newPath');
        newPaths.add(newPath);
      }
    }

    return newPaths;
  }

  Future<void> _upLoadFiles(List<String> filePaths) async {
    int index = 0;
    for (var filePath in filePaths) {
      try {
        // Leer el archivo multimedia
        final file = File(filePath);
        final mediaBytes = await file.readAsBytes();
        final mediaType = file.path.endsWith('.mp4') ? 'video' : 'image';

        // Guardar el mensaje en la base de datos local
        PrivateMessages storageMessage = PrivateMessages(
          from: authService!.usuario.uid,
          to: chatService!.usuarioPara.uid,
          messages: _textControllers[index].text,
          multimedia: filePath,
          mediaType: mediaType,
          reference: '',
        );
        await HiveService()
            .addMessage(storageMessage, authService!.usuario.uid);

        // Emitir el mensaje al servidor a través del socket
        socketService!.emit('mensaje-personal', {
          'de': authService!.usuario.uid,
          'para': chatService!.usuarioPara.uid,
          'mensaje': _textControllers[index].text,
          'mid': storageMessage.id,
          'rid': '',
          'mediaType': mediaType,
          'multimedia': mediaBytes,
          'date': storageMessage.date,
        });
      } catch (e) {
        // Manejar cualquier error que ocurra durante la lectura o emisión del archivo
        print('Error al enviar el mensaje de media: $e');
      }
      index += 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controllers.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                PageView.builder(
                  itemCount: widget.filePaths.length,
                  onPageChanged: (index) {
                    // Detener el video en la página actual
                    if (_controllers[_currentIndex] != null) {
                      _controllers[_currentIndex]!.pause();
                    }

                    // Actualizar el índice actual
                    setState(() {
                      _currentIndex = index;
                    });

                    // Reproducir el video en la nueva página
                    if (_controllers[_currentIndex] != null) {
                      _controllers[_currentIndex]!.play();
                    }
                  },
                  itemBuilder: (context, index) {
                    final path = widget.filePaths[index];
                    final controller = _controllers[index];
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        if (path.endsWith('.mp4')) {
                          final aspectRatio =
                              controller?.value.aspectRatio ?? 16 / 9;
                          return Center(
                            child: Container(
                              width: constraints.maxWidth,
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: SizedBox(
                                  width: constraints.maxWidth,
                                  height: constraints.maxWidth / aspectRatio,
                                  child: controller != null
                                      ? VideoPlayer(controller)
                                      : const SizedBox(),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Image.file(
                            File(path),
                            fit: BoxFit.contain,
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                          );
                        }
                      },
                    );
                  },
                ),
                Positioned(
                  top: 20,
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textControllers[_currentIndex],
                          decoration: InputDecoration(
                            hintText: "Description...",
                            filled: true,
                            fillColor: Color.fromARGB(95, 203, 203, 203)
                                .withOpacity(0.7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.blue),
                        onPressed: () async {
                          List<String> newPaths =
                              await _saveFiles(widget.filePaths);
                          await _upLoadFiles(newPaths);
                          widget.filePaths.forEach((path) {
                            print("Sending file: $path");
                          });
                          Navigator.popUntil(
                              context, ModalRoute.withName('chat'));
                          Navigator.popAndPushNamed(context, 'chat');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
