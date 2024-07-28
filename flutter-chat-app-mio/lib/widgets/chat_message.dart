import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chat/services/auth_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart';

class ChatMessage extends StatelessWidget {
  final String texto;
  final String uid;
  final String mid;
  final bool isAudio;
  final List<int>? audioData;
  final AnimationController animationController;

  const ChatMessage({
    Key? key,
    this.texto = '',
    required this.uid,
    required this.mid,
    required this.animationController,
    this.isAudio = false,
    this.audioData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return FadeTransition(
      opacity: animationController,
      child: SizeTransition(
        sizeFactor:
            CurvedAnimation(parent: animationController, curve: Curves.easeOut),
        child: Container(
          child: this.uid == authService.usuario.uid
              ? _myMessage()
              : _notMyMessage(),
        ),
      ),
    );
  }

  Widget _myMessage() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.only(right: 5, bottom: 5, left: 50),
        child: isAudio ? _buildAudioMessage() : _buildTextMessage(),
        decoration: BoxDecoration(
            color: Color(0xff4D9EF6), borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _notMyMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.only(left: 5, bottom: 5, right: 50),
        child: isAudio ? _buildAudioMessage() : _buildTextMessage(),
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 182, 186, 197),
            borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildTextMessage() {
    return Text(
      this.texto,
      style: TextStyle(color: isAudio ? Colors.black87 : Colors.white),
    );
  }

  Widget _buildAudioMessage() {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: () => _playAudio(),
          color: Colors.white,
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Audio message',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _playAudio() async {
    final FlutterSoundPlayer _player = FlutterSoundPlayer();
    if (audioData != null) {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
          '${tempDir.path}/temp_audio.wav'); // Usa la extensión adecuada para tu formato de audio

      await tempFile.writeAsBytes(audioData!);

      await _player.openPlayer();
      await _player.startPlayer(fromURI: tempFile.path);
    } else {
      print('No audio data');
    }
  }
}
