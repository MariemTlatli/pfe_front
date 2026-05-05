import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:front/presentation/provider/emotion_provider.dart';

// ─────────────────────────────────────────────
//  WRAPPER DRAGGABLE
// ─────────────────────────────────────────────

class DraggableEmotionCamera extends StatefulWidget {
  const DraggableEmotionCamera({Key? key}) : super(key: key);

  @override
  State<DraggableEmotionCamera> createState() => _DraggableEmotionCameraState();
}

class _DraggableEmotionCameraState extends State<DraggableEmotionCamera> {
  double _dx = -1;
  double _dy = -1;

  static const double _widgetWidth = 110;
  static const double _widgetHeight = 175;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    if (_dx < 0) _dx = screenW - _widgetWidth - 16;
    if (_dy < 0) _dy = screenH - _widgetHeight - 100;

    return Positioned(
      left: _dx,
      top: _dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _dx += details.delta.dx;
            _dy += details.delta.dy;
            _dx = _dx.clamp(0.0, screenW - _widgetWidth);
            _dy = _dy.clamp(0.0, screenH - _widgetHeight);
          });
        },
        child: const EmotionCameraWidget(captureIntervalSeconds: 5),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WIDGET CAMÉRA AVEC PROVIDER
// ─────────────────────────────────────────────

class EmotionCameraWidget extends StatefulWidget {
  final int captureIntervalSeconds;

  const EmotionCameraWidget({
    Key? key,
    this.captureIntervalSeconds = 5,
  }) : super(key: key);

  @override
  State<EmotionCameraWidget> createState() => _EmotionCameraWidgetState();
}

class _EmotionCameraWidgetState extends State<EmotionCameraWidget> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isActive = false;
  bool _isLoading = false;
  bool _hasPermission = false;
  String? _errorMessage;

  Timer? _captureTimer;

  static const double _windowWidth = 110;
  static const double _windowHeight = 145;

  @override
  void initState() {
    super.initState();
    // Vérifier la santé de l'API au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmotionProvider>().checkApiHealth();
    });
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  // ── Permissions ──────────────────────────────
  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    setState(() => _hasPermission = status.isGranted);
    if (!status.isGranted) {
      setState(() => _errorMessage = 'Permission refusée');
    }
  }

  // ── Init caméra ───────────────────────────────
  Future<void> _initCamera() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _requestPermission();
      if (!_hasPermission) {
        setState(() => _isLoading = false);
        return;
      }

      final cameras = await availableCameras();
      final frontCam = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCam,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isActive = true;
          _isLoading = false;
        });

        // Démarrer la capture automatique
        _startAutoCapture();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erreur caméra';
        });
      }
    }
  }

  // ── Stop caméra ───────────────────────────────
  Future<void> _stopCamera() async {
    _captureTimer?.cancel();
    await _controller?.dispose();
    _controller = null;
    if (mounted) {
      setState(() {
        _isInitialized = false;
        _isActive = false;
      });
    }
  }

  Future<void> _toggleCamera() async =>
      _isActive ? _stopCamera() : _initCamera();

  // ── Capture automatique ───────────────────────
  void _startAutoCapture() {
    _captureTimer?.cancel();
    _captureTimer = Timer.periodic(
      Duration(seconds: widget.captureIntervalSeconds),
      (_) => _captureAndPredict(),
    );
  }

  Future<void> _captureAndPredict() async {
    final emotionProvider = context.read<EmotionProvider>();
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (!emotionProvider.isAnalysisEnabled) return;
    if (emotionProvider.isLoading) return;

    try {
      final XFile image = await _controller!.takePicture();
      final Uint8List imageBytes = await image.readAsBytes();

      if (mounted) {
        await context
            .read<EmotionProvider>()
            .predictEmotion(imageBytes: imageBytes);
        var result = context.read<EmotionProvider>().currentEmotion;
        context.read<EmotionProvider>().addCaptureFromResult(result!);
      }
    } catch (e) {
      print('❌ Erreur capture: $e');
    }
  }

  // ── Build ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      width: _windowWidth,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _isActive
              ? Colors.green.withOpacity(0.7)
              : Colors.grey.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDragHandle(),
            SizedBox(
              width: _windowWidth,
              height: _windowHeight,
              child: _buildCameraPreview(),
            ),
            _buildControlBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: _windowWidth,
      height: 18,
      color: Colors.grey.shade900,
      child: Center(
        child: Container(
          width: 32,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.grey.shade600,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (!_isActive || !_isInitialized || _controller == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, color: Colors.grey, size: 28),
            SizedBox(height: 4),
            Text(
              'Caméra\ninactive',
              style: TextStyle(color: Colors.grey, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.previewSize?.height ?? _windowWidth,
            height: _controller!.value.previewSize?.width ?? _windowHeight,
            child: CameraPreview(_controller!),
          ),
        ),
        // Badge LIVE
        Positioned(
          top: 6,
          left: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.85),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Colors.white, size: 6),
                SizedBox(width: 3),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        // ── Emoji émotion (via Provider) ──
        Consumer<EmotionProvider>(
          builder: (context, provider, _) {
            // Loading indicator
            if (provider.isLoading) {
              return const Positioned(
                bottom: 6,
                right: 6,
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              );
            }

            // Emotion emoji
            final emotion = provider.currentEmotion;
            return Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: emotion != null
                      ? emotion.color.withOpacity(0.8)
                      : Colors.grey.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  emotion?.emoji ?? '😐',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          },
        ),
        // ── Badge erreur API ──
        Consumer<EmotionProvider>(
          builder: (context, provider, _) {
            if (!provider.isApiHealthy) {
              return Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildControlBar() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _isLoading ? null : _toggleCamera,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _isActive
                    ? Colors.green.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isActive ? Colors.green : Colors.grey,
                  width: 1,
                ),
              ),
              child: Text(
                _isActive ? '● ON' : '○ OFF',
                style: TextStyle(
                  color: _isActive ? Colors.green : Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}