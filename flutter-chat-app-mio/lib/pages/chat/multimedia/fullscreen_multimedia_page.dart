import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenMediaPage extends StatefulWidget {
  final String filePath;

  FullScreenMediaPage({required this.filePath});

  @override
  _FullScreenMediaPageState createState() => _FullScreenMediaPageState();
}

class _FullScreenMediaPageState extends State<FullScreenMediaPage> {
  VideoPlayerController? _controller;
  bool _showPlayIcon = true;
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();
    if (widget.filePath.contains('mp4')) {
      _isVideo = true;
      _controller = VideoPlayerController.file(File(widget.filePath))
        ..initialize().then((_) {
          setState(() {});
          _controller!.play(); // Empieza la reproducción automáticamente
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller?.pause();
      } else {
        _controller?.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _isVideo && _controller!.value.isInitialized
                ? FutureBuilder(
                    future: _controller!.initialize(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _showPlayIcon = !_showPlayIcon;
                            });
                            _togglePlayPause();
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Hero(
                                tag: widget
                                    .filePath, // La misma etiqueta que en el widget de miniatura
                                child: VideoPlayer(_controller!),
                              ),
                              if (_showPlayIcon)
                                AnimatedOpacity(
                                  opacity: _showPlayIcon ? 1.0 : 0.0,
                                  duration: Duration(milliseconds: 300),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 100,
                                  ),
                                ),
                            ],
                          ),
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  )
                : Hero(
                    tag:
                        'imageHero_${widget.filePath}', // Debe coincidir con la etiqueta del widget de miniatura
                    child: Image.file(File(widget.filePath)),
                  ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
