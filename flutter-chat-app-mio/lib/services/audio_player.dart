import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioPlayer {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  Future<void> initializeRecorderAndPlayer() async {
    await _recorder.openRecorder();
    await _player.openPlayer();
  }

  Future<void> startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      //unique Name
      String path = DateTime.now().millisecondsSinceEpoch.toString() + '.aac';
      await _recorder.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
      );
    }
  }

  Future<String> stopRecording() async {
    String? recordedFilePath = await _recorder.stopRecorder();

    if (recordedFilePath != null) {
      // _sendAudioMessage(path);
    }
    return recordedFilePath!;
  }

  Future<void> playRecording(
      String recordedFilePath, Function onFinished) async {
    await _player.startPlayer(
      fromURI: recordedFilePath,
      codec: Codec.aacADTS,
      whenFinished: onFinished(),
    );
  }

  Future<void> stopPlaying() async {
    await _player.stopPlayer();
  }

  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
  }
}
