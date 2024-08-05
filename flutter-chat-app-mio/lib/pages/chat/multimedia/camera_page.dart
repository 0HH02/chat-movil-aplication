import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:chat/pages/chat/multimedia/preview_camera_page.dart';

class CameraPage extends StatefulWidget {
  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  late final List<CameraDescription> _cameras;
  bool isTakingPicture = true;
  bool _backCamera = true;
  List<File> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initCamera();
  }

  Future<void> initCamera() async {
    _cameras = await availableCameras();
    // Initialize the camera with the first camera in the list
    await onNewCameraSelected(_cameras.first);
  }

  Future<void> onNewCameraSelected(CameraDescription description) async {
    final previousCameraController = _controller;

    await previousCameraController?.dispose();
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      description,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
    }
    // Dispose the previous controller

    // Replace with the new controller
    if (mounted) {
      setState(() {
        _controller = cameraController;
        _isCameraInitialized = _controller!.value.isInitialized;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _switchCamera() async {
    if (_cameras.length > 1) {
      // Switch the value of _frontCamera
      setState(() {
        _isCameraInitialized = false;
        _backCamera = !_backCamera;
      });

      // Select the correct camera
      await onNewCameraSelected(_backCamera ? _cameras[0] : _cameras[1]);
    } else {
      debugPrint('No secondary camera found');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<XFile?> capturePhoto() async {
    final CameraController? cameraController = _controller;
    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      await cameraController.setFlashMode(FlashMode.off); //optional
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  void _onTakePhotoPressed() async {
    final navigator = Navigator.of(context);
    final xFile = await capturePhoto();
    if (xFile != null) {
      if (xFile.path.isNotEmpty) {
        print("Path: " + xFile.path);
        navigator.push(
          MaterialPageRoute(
            builder: (context) => PreviewPage(
              filePaths: [xFile.path],
            ),
          ),
        );
      }
    }
  }

  void toggleMode() {
    setState(() {
      isTakingPicture = !isTakingPicture;
    });
  }

  Future<XFile?> captureVideo() async {
    final CameraController? cameraController = _controller;
    try {
      await cameraController?.startVideoRecording();
      final video = await cameraController?.stopVideoRecording();

      return video;
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  void _onStopRecordVideoPressed(XFile xFile) async {
    final navigator = Navigator.of(context);
    if (xFile.path.isNotEmpty) {
      navigator.push(
        MaterialPageRoute(
          builder: (context) => PreviewPage(
            filePaths: [xFile.path],
          ),
        ),
      );
    }
  }

  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.media,
    );
    if (result != null) {
      _selectedFiles = result.files.map((file) => File(file.path!)).toList();
      final navigator = Navigator.of(context);
      navigator.push(
        MaterialPageRoute(
          builder: (context) => PreviewPage(
            filePaths: _selectedFiles.map((file) => file.path).toList(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCameraInitialized) {
      return SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
              ),
              Positioned(
                top: 20, // Ajusta según tu diseño
                left: 10, // Ajusta según tu diseño
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Positioned(
                bottom: 75,
                left: 20,
                child: IconButton(
                  icon: Icon(Icons.flip_camera_ios_outlined),
                  onPressed: _switchCamera,
                  color: Colors.white,
                  iconSize: 25,
                ),
              ),
              Positioned(
                bottom: 70,
                right: MediaQuery.of(context).size.width / 2 - 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: IconButton(
                            icon: Icon(
                              isTakingPicture
                                  ? Icons.camera_alt
                                  : Icons.videocam,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: isTakingPicture
                                ? _onTakePhotoPressed
                                : () async {
                                    if (!(_controller!
                                        .value.isRecordingVideo)) {
                                      await _controller!.startVideoRecording();
                                    } else {
                                      final video = await _controller!
                                          .stopVideoRecording();
                                      _onStopRecordVideoPressed(video);
                                    }
                                  }),
                      ),
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(
                        isTakingPicture ? Icons.videocam : Icons.camera_alt,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        toggleMode();
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 75,
                right: 20,
                child: IconButton(
                  icon: Icon(Icons.photo_library_sharp),
                  onPressed: _pickMedia,
                  color: Colors.white,
                  iconSize: 25,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
