import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:chat/models/messages.dart';
import 'package:chat/pages/chat/multimedia/fullscreen_multimedia_page.dart';
import 'package:chat/widgets/bubble_chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:chat/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

// ignore: must_be_immutable
class ChatMessage extends StatefulWidget {
  final bool seen;
  final AnimationController animationController;
  final PrivateMessages message;

  ChatMessage({
    Key? key,
    required this.message,
    required this.animationController,
    this.seen = false,
  }) : super(key: key);

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  bool _isPlaying = false;
  double _currentPosition = 0.0;
  double _duration = 1.0;
  StreamSubscription<PlaybackDisposition>? _progressSubscription;
  FlutterSoundPlayer? _player;

  @override
  void initState() {
    super.initState();
    if (widget.message.mediaType == 'audio') {
      _player = FlutterSoundPlayer();
    }
  }

  Future<void> _initializePlayer() async {
    try {
      await _player!.openPlayer();

      _progressSubscription = _player!.onProgress!.listen((e) {
        _currentPosition = e.position.inSeconds.toDouble();
        _duration = e.duration.inSeconds.toDouble();
        if (_currentPosition >= _duration) {
          _currentPosition = _duration;
          _isPlaying = false;
        }
        print(_duration);
        print(e.duration.inSeconds.toDouble());
        print(
            '==========================================================================================================');
        setState(() {});
      });
      _progressSubscription!.onDone(() {
        print('Done');
      });
      _progressSubscription!.onData((data) {
        print('Data: $data');
      });
      _progressSubscription!.onError((error) {
        print(
            '=======================================================================================================');
        print('Error: $error');
      });
      print('todook');
    } catch (e) {
      print('Error initializing player: $e');
    }
  }

  @override
  void dispose() {
    if (widget.message.mediaType == 'audio') {
      _player?.closePlayer();
      // _progressSubscription!.cancel();
    }
    super.dispose();
  }

  void _onSliderChange(double value) async {
    print(_duration);
    if (_isPlaying) {
      await _player!.seekToPlayer(Duration(seconds: value.toInt()));
    } else {
      setState(() {
        _currentPosition = value;
      });
      await _player!.seekToPlayer(Duration(seconds: value.toInt()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final bool myMessage = this.widget.message.from == authService.usuario.uid;

    Widget messages;
    bool multimedia_aux = false;
    if (this.widget.message.mediaType == 'audio') {
      messages = _buildAudioMessage(context);
    } else if (this.widget.message.mediaType == 'image' ||
        this.widget.message.mediaType == 'video') {
      messages = _buildMultimediaMessage(context);
      multimedia_aux = true;
    } else {
      messages = Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
        ),
        child: Text(
          widget.message.messages,
          style: TextStyle(
            color: myMessage ? Colors.white : Colors.black,
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: widget.animationController,
      child: SizeTransition(
        sizeFactor: CurvedAnimation(
            parent: widget.animationController, curve: Curves.easeOut),
        child: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: BubbleChat(
              message: messages,
              seen: widget.seen,
              myMessage: myMessage,
              multimedia: multimedia_aux,
              messages: widget.message,
            )),
      ),
    );
  }

  Widget _buildMultimediaMessage(context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FullScreenMediaPage(filePath: widget.message.multimedia!),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 200,
              width: 200,
              child: FittedBox(
                fit: BoxFit.cover,
                child: widget.message.multimedia!.endsWith('.mp4')
                    ? FutureBuilder<List<int>?>(
                        future: _generateThumbnail(widget.message.multimedia!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return Hero(
                                tag:
                                    'imageHero_${widget.message.multimedia!}', // La misma etiqueta que en FullScreenMediaPage
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.memory(snapshot.data! as Uint8List),
                                    Icon(
                                      Icons.play_circle_fill,
                                      color: Colors.white,
                                      size: 250, // Tamaño del ícono
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Icon(Icons.video_collection,
                                  color: Colors.white);
                            }
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      )
                    : Hero(
                        tag: 'imageHero_${widget.message.multimedia!}',
                        child: Image.file(File(widget.message.multimedia!)),
                      ),
              ),
            ),
          ),
          widget.message.messages != ''
              ? SizedBox(height: 8)
              : SizedBox(), // Espacio entre el multimedia y el message.message
          widget.message.messages != ''
              ? Text(
                  widget.message.messages,
                  style: TextStyle(
                    color: Colors
                        .white, // Ajusta el color del message.message según tus necesidades
                    fontSize:
                        14, // Ajusta el tamaño del message.message según tus necesidades
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  Future<List<int>?> _generateThumbnail(String filePath) async {
    final List<int>? thumbnail = await VideoThumbnail.thumbnailData(
      video: filePath,
      imageFormat: ImageFormat.JPEG,
      quality: 100,
    );
    return thumbnail;
  }

  Widget _buildAudioMessage(context) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(_player!.isStopped || _player!.isPaused
                    ? Icons.play_arrow
                    : Icons.pause),
                onPressed: _player!.isStopped || _player!.isPaused
                    ? () async {
                        if (!(_player!.isOpen())) {
                          await _initializePlayer();
                        }
                        await _resumeAudio();
                      }
                    : () async {
                        await _pauseAudio();
                      },
                color: Colors.white,
              ),
              Container(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Audio message',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Slider(
            value: _currentPosition,
            min: 0.0,
            max: _duration,
            onChanged: _onSliderChange,
          ),
        ],
      ),
    );
  }

  Future<void> _pauseAudio() async {
    print(_duration);

    try {
      await _player!.pausePlayer();
      setState(() {});
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  Future<void> _resumeAudio() async {
    if (_player!.isStopped) {
      try {
        await _player!.startPlayer(fromURI: widget.message.multimedia!);
        setState(() {});
        return;
      } catch (e) {
        print('Error playing audio: $e');
        showAboutDialog(
            context: context,
            applicationName: 'Error playing audio',
            children: [Text('Error playing audio: $e')]);
        return;
      }
    }
    try {
      await _player!.resumePlayer();
      setState(() {});
    } catch (e) {
      print('Error resuming audio: $e');
    }
  }
}
