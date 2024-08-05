import 'dart:async';
import 'dart:io';

import 'package:chat/helpers/aux_functions.dart';
import 'package:chat/models/messages.dart';
import 'package:chat/pages/chat/utils/colors.dart';
import 'package:chat/pages/chat/widgets/bottom_inset.dart';
import 'package:chat/pages/chat/widgets/emoji_picker_widget.dart';
import 'package:chat/services/audio_player.dart';
import 'package:chat/services/audio_service.dart';
import 'package:chat/services/file_service.dart';
import 'package:chat/services/hive_service.dart';
import 'package:chat/services/message_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
  late FileService fileService;
  late MessageService messageService;
  Timer? _timer;
  int _elapsedSeconds = 0;

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
    this.messageService = Provider.of<MessageService>(context, listen: false);

    audioPlayer = AudioPlayer();
    fileService = FileService();
    audioPlayer.initializeRecorderAndPlayer();

    _cargarHistorial(this.chatService.usuarioPara.uid);
  }

  void _cargarHistorial(String usuarioID) async {
    _messages.clear();
    List<PrivateMessages> chat = HiveService().getMessagesForUser(usuarioID);
    final history = chat.map((m) => new ChatMessage(
          message: m,
          animationController: new AnimationController(
              vsync: this, duration: Duration(milliseconds: 0))
            ..forward(),
          seen: m.seen,
        ));
    _messages.insertAll(0, history);
  }

  void _startTimer() {
    _elapsedSeconds = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _escucharMensajes() async {
    // PrivateMessages last_message =
    //     HiveService().getLastMessagesForUser(chatService.usuarioPara.uid);

    // if (_messages.isNotEmpty &&
    //     chatService.usuarioPara.uid == last_message.from &&
    //     (last_message.id != _messages.first.mid ||
    //         last_message.seen != _messages.first.seen)) {
    //   ChatMessage message = new ChatMessage(
    //     texto: last_message.messages,
    //     uid: last_message.from,
    //     animationController: AnimationController(
    //         vsync: this, duration: Duration(milliseconds: 300)),
    //     mid: last_message.id.toString(),
    //     rid: last_message.reference,
    //     mediaType: last_message.mediaType,
    //     multimedia: last_message.multimedia,
    //     seen: false,
    //     liked: false,
    //   );

    //   _messages.insert(0, message);

    //   message.animationController.forward();
    // }
  }

  void _sendAudioMessage(String path) async {
    try {
      final audioDir = await getDirectoryPath('Audio');

      String newPath = '';
      final file = File(path);
      if (await file.exists()) {
        final fileName = path.split('/').last;
        newPath = '$audioDir/$fileName';
        await file.copy(newPath);
        print('File saved to: $newPath');
      }

      final audioBytes = await file.readAsBytes();

      // Guardar el mensaje en la base de datos local
      PrivateMessages storageMessage = PrivateMessages(
        from: this.authService.usuario.uid,
        to: this.chatService.usuarioPara.uid,
        messages: '',
        multimedia: newPath,
        mediaType: 'audio',
      );
      HiveService().addMessage(storageMessage, authService.usuario.uid);

      // Emitir el mensaje al servidor a través del socket
      socketService.emit('mensaje-personal', {
        'de': this.authService.usuario.uid,
        'para': this.chatService.usuarioPara.uid,
        'mensaje': '',
        'mid': storageMessage.id,
        'rid': '',
        'mediaType': 'audio',
        'multimedia': audioBytes,
        'date': storageMessage.date,
      });

      // Crear el nuevo mensaje localmente
      final newMessage = ChatMessage(
        message: storageMessage,
        animationController: AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 200),
        ),
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: LigueColors.principal,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                child: Text(usuarioPara.nombre.substring(0, 2),
                    style: TextStyle(fontSize: 15)),
                backgroundColor: Colors.blue[100],
                maxRadius: 20,
              ),
              SizedBox(width: 10),
              Container(
                constraints: BoxConstraints(maxWidth: 100),
                child: Text(usuarioPara.nombre,
                    style: TextStyle(color: Colors.black87, fontSize: 15)),
              )
            ],
          ),
        ),
        actions: [
          Icon(
            Icons.more_horiz_outlined,
            color: LigueColors.principal,
            size: 50,
          ),
          SizedBox(
            width: 10,
          )
        ],
        centerTitle: true,
        elevation: 1,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Flexible(child: Consumer<SocketService>(
              builder: (context, socketService, _) {
                if (socketService.serverStatus == ServerStatus.Online) {
                  _cargarHistorial(this.chatService.usuarioPara.uid);
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
            Column(
              children: [
                Consumer<MessageService>(builder: (context, value, child) {
                  if (messageService.reference.from == '0' &&
                      messageService.reference.from == '0') {
                    return SizedBox();
                  } else {
                    print(messageService.reference.messages == '');
                    return Container(
                      constraints: BoxConstraints(
                        maxHeight: 75,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(left: 5),
                                decoration: BoxDecoration(
                                    border: Border(
                                        left: BorderSide(
                                            color: LigueColors.myBurbbleChat,
                                            width: 3))),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      messageService.reference.from ==
                                              authService.usuario.uid
                                          ? 'Tú'
                                          : usuarioPara.nombre,
                                      style: TextStyle(
                                          color: LigueColors.myBurbbleChat,
                                          fontSize: 15),
                                    ),
                                    Text(
                                      "${messageService.reference.messages}",
                                      softWrap: true,
                                      maxLines: 2,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  messageService.setReference(
                                      PrivateMessages(from: '0', to: '0'));
                                },
                                icon: Icon(Icons.close_rounded))
                          ],
                        ),
                      ),
                    );
                  }
                }),
                Container(
                  color: Colors.white,
                  child: _inputChat(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  bool _showEmojiPicker = false;
  Widget _inputChat() {
    return
        // AvoidBottomInset(
        //     padding: EdgeInsets.only(bottom: Platform.isAndroid ? 4.0 : 24.0),
        //     conditions: [_showEmojiPicker],
        //     offstage: Offstage(
        //       offstage: !_showEmojiPicker,
        //       child: CustomEmojiPicker(
        //         afterEmojiPlaced: (emoji) {},
        //         textController: _textController,
        //       ),
        //     ),
        // child:
        SafeArea(
      child: Stack(
        children: [
          Container(
            constraints: BoxConstraints(maxHeight: 125),
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.emoji_emotions_outlined),
                        onPressed: () {
                          _showEmojiPicker = !_showEmojiPicker;
                          setState(() {});
                        },
                      ),
                      Expanded(
                        child: Container(
                          margin:
                              EdgeInsets.only(left: 5, right: 0, bottom: 15),
                          child: TextField(
                            readOnly: false, // Cambia esto según sea necesario
                            controller: _textController,
                            focusNode: _focusNode,
                            onSubmitted: _handleSubmit,
                            onChanged: (texto) {
                              setState(() {
                                _estaEscribiendo = texto.trim().isNotEmpty;
                              });
                            },
                            decoration: InputDecoration.collapsed(
                                hintText: 'Escribe un mensaje...'),
                            maxLines: null, // Permite múltiples líneas
                            keyboardType: TextInputType
                                .multiline, // Permite múltiples líneas en el teclado
                          ),
                        ),
                      ),
                      _isRecording
                          ? SizedBox(
                              height: 48,
                            )
                          : Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, 'camera');
                                    },
                                    icon: Icon(Icons.camera_alt_outlined),
                                    color: Colors.blue,
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      if (_estaEscribiendo) {
                                        _handleSubmit(
                                            _textController.text.trim());
                                      } else {
                                        audioPlayer.startRecording();
                                        _startTimer();
                                        setState(() {
                                          _isRecording = true;
                                        });
                                      }
                                      ;
                                    },
                                    icon: _estaEscribiendo
                                        ? Icon(
                                            Icons.send,
                                            color: Colors.blue,
                                          )
                                        : Icon(
                                            Icons.mic,
                                            color: Colors.blue,
                                          ),
                                  )
                                ],
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _isRecording
              ? Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  _recordedFilePath =
                                      await audioPlayer.stopRecording();
                                  _sendAudioMessage(_recordedFilePath!);
                                  _recordedFilePath = null;
                                  setState(() {
                                    _isRecording = false;
                                  });
                                },
                                icon: Icon(
                                  Icons.send,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(),
          _isRecording
              ? Positioned(
                  top: 0,
                  left: 0,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          _recordedFilePath = await audioPlayer.stopRecording();
                          _stopTimer();
                          _recordedFilePath = null;
                          _isRecording = false;
                          setState(() {});
                        },
                        icon: Icon(
                          Icons.delete_outline_outlined,
                          color: Colors.red[300],
                        ),
                      ),
                      Icon(
                        Icons.fiber_manual_record,
                        color: Colors.red,
                        size: 15,
                      ),
                      SizedBox(width: 3),
                      // Reloj de grabación
                      Text(
                        _formatDuration(Duration(seconds: _elapsedSeconds)),
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                )
              : SizedBox(),
        ],
      ),
      // ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  _handleSubmit(String texto) {
    if (texto.length == 0) return;

    _textController.clear();
    _focusNode.requestFocus();
    print(DateTime.now().toString());
    PrivateMessages storage_message = PrivateMessages(
      from: this.authService.usuario.uid,
      to: this.chatService.usuarioPara.uid,
      messages: texto,
    );

    final newMessage = new ChatMessage(
      message: storage_message,
      animationController: AnimationController(
          vsync: this, duration: Duration(milliseconds: 200)),
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
      'rid': storage_message.reference,
      'mediaType': 'text',
      'multimedia': [],
      'date': storage_message.date,
    });
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }
    _timer?.cancel();
    _textController.dispose();
    audioPlayer.dispose();
    super.dispose();
  }
}
