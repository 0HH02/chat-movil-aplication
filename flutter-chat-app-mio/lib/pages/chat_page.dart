import 'dart:io';

import 'package:chat/models/messages.dart';
import 'package:chat/services/audio_player.dart';
import 'package:chat/services/audio_service.dart';
import 'package:chat/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:chat/services/socket_service.dart';

import 'package:chat/widgets/chat_message.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = new TextEditingController();
  final _focusNode = new FocusNode();

  late ChatService chatService;
  late SocketService socketService;
  late AuthService authService;
  late AudioService audioService;
  late AudioPlayer audioPlayer;

  List<ChatMessage> _messages = [];

  bool _estaEscribiendo = false;

  bool _isRecording = false;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();

    this.chatService = Provider.of<ChatService>(context, listen: false);
    this.socketService = Provider.of<SocketService>(context, listen: false);
    this.authService = Provider.of<AuthService>(context, listen: false);
    this.audioService = Provider.of<AudioService>(context, listen: false);
    audioPlayer = AudioPlayer();
    audioPlayer.initializeRecorderAndPlayer();

    _cargarHistorial(this.chatService.usuarioPara.uid);
  }

  void _cargarHistorial(String usuarioID) async {
    List<PrivateMessages> chat = HiveService().getMessagesForUser(usuarioID);
    chat.forEach((data) {
      print(data);
    });
    final history = chat.map((m) => new ChatMessage(
          texto: m.messages,
          uid: m.from,
          animationController: new AnimationController(
              vsync: this, duration: Duration(milliseconds: 0))
            ..forward(),
          mid: m.id,
          audioData: m.audioData,
          isAudio: m.audioData != null,
        ));

    setState(() {
      _messages.insertAll(0, history);
    });
  }

  void _escucharMensajes() {
    PrivateMessages last_message =
        HiveService().getLastMessagesForUser(chatService.usuarioPara.uid);
    if (chatService.usuarioPara.uid == last_message.from &&
        last_message.id != _messages.first.mid) {
      ChatMessage message = new ChatMessage(
        texto: last_message.messages,
        uid: last_message.from,
        animationController: AnimationController(
            vsync: this, duration: Duration(milliseconds: 300)),
        mid: last_message.id,
        audioData: last_message.audioData,
        isAudio: last_message.audioData != null,
      );

      _messages.insert(0, message);

      message.animationController.forward();
    }
  }

  void _sendAudioMessage(String path) async {
    try {
      // Leer el archivo de audio
      final file = File(path);
      final audioBytes = await file.readAsBytes();

      // Guardar el mensaje en la base de datos local
      PrivateMessages storageMessage = PrivateMessages(
        from: this.authService.usuario.uid,
        to: this.chatService.usuarioPara.uid,
        messages: '',
        audioData: audioBytes,
      );
      HiveService().addMessage(storageMessage, authService.usuario.uid);

      // Emitir el mensaje al servidor a través del socket
      socketService.emit('mensaje-personal', {
        'de': this.authService.usuario.uid,
        'para': this.chatService.usuarioPara.uid,
        'mensaje': '',
        'mid': storageMessage.id,
        'isAudio': true,
        'audioData': audioBytes,
      });

      // Crear el nuevo mensaje localmente
      final newMessage = ChatMessage(
        uid: authService.usuario.uid,
        animationController: AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 200),
        ),
        mid: storageMessage.id,
        isAudio: true,
        audioData: audioBytes,
      );

      setState(() {
        _messages.insert(0, newMessage);
      });

      newMessage.animationController.forward();
    } catch (e) {
      // Manejar cualquier error que ocurra durante la lectura o emisión del archivo
      print('Error al enviar el mensaje de audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuarioPara = chatService.usuarioPara;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          children: <Widget>[
            CircleAvatar(
              child: Text(usuarioPara.nombre.substring(0, 2),
                  style: TextStyle(fontSize: 12)),
              backgroundColor: Colors.blue[100],
              maxRadius: 14,
            ),
            SizedBox(height: 3),
            Text(usuarioPara.nombre,
                style: TextStyle(color: Colors.black87, fontSize: 12))
          ],
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Flexible(child: Consumer<SocketService>(
              builder: (context, socketService, _) {
                if (socketService.serverStatus == ServerStatus.Online) {
                  _escucharMensajes();
                }
                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: _messages.length,
                  itemBuilder: (_, i) => _messages[i],
                  reverse: true,
                );
              },
            )),
            Divider(height: 1),
            Container(
              color: Colors.white,
              child: _inputChat(),
            )
          ],
        ),
      ),
    );
  }

  Widget _inputChat() {
    return SafeArea(
        child: Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
              child: TextField(
            readOnly: _recordedFilePath != null,
            controller: _textController,
            onSubmitted: _handleSubmit,
            onChanged: (texto) {
              setState(() {
                if (texto.trim().length > 0) {
                  _estaEscribiendo = true;
                } else {
                  _estaEscribiendo = false;
                }
              });
            },
            decoration: InputDecoration.collapsed(hintText: 'Enviar mensaje'),
            focusNode: _focusNode,
          )),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  color: _isRecording ? Colors.red : Colors.blue,
                  onPressed: _isRecording
                      ? () async {
                          _recordedFilePath = await audioPlayer.stopRecording();
                          setState(() {
                            _isRecording = false;
                            _estaEscribiendo =
                                _textController.text.trim().isNotEmpty;
                          });
                        }
                      : () {
                          audioPlayer.startRecording();
                          setState(() {
                            _isRecording = true;
                            _estaEscribiendo = true;
                          });
                        },
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  color: Colors.blue,
                  onPressed: _estaEscribiendo || _recordedFilePath != null
                      ? _handleSend
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  void _handleSend() {
    if (_recordedFilePath != null) {
      _sendAudioMessage(_recordedFilePath!);
      _recordedFilePath = null;
    } else if (_textController.text.trim().isNotEmpty) {
      _handleSubmit(_textController.text.trim());
    }
  }

  _handleSubmit(String texto) {
    if (texto.length == 0) return;

    _textController.clear();
    _focusNode.requestFocus();

    PrivateMessages storage_message = PrivateMessages(
      from: this.authService.usuario.uid,
      to: this.chatService.usuarioPara.uid,
      messages: texto,
    );

    final newMessage = new ChatMessage(
      uid: authService.usuario.uid,
      texto: texto,
      animationController: AnimationController(
          vsync: this, duration: Duration(milliseconds: 200)),
      mid: storage_message.id,
    );
    _messages.insert(0, newMessage);
    newMessage.animationController.forward();

    setState(() {
      _estaEscribiendo = false;
    });
    HiveService().addMessage(storage_message, authService.usuario.uid);

    this.socketService.emit('mensaje-personal', {
      'de': this.authService.usuario.uid,
      'para': this.chatService.usuarioPara.uid,
      'mensaje': texto,
      'mid': storage_message.id,
    });
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }
    _textController.dispose();
    audioPlayer.dispose();
    super.dispose();
  }
}
