import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermal_mobile/core/configs/app_config.dart';
import 'package:thermal_mobile/presentation/widgets/ptz_dpad_controller.dart';
import 'package:video_player/video_player.dart';
import '../../bloc/camera/camera_control_bloc.dart';
import '../../bloc/camera/camera_stream_bloc.dart';
import '../../../di/injection.dart';

/// Camera Stream Page - Displays stream information
class CameraStreamPage extends StatefulWidget {
  final int cameraId;
  final String cameraName;
  final bool isPtzCamera;

  const CameraStreamPage({
    super.key,
    required this.cameraId,
    required this.cameraName,
    this.isPtzCamera = false,
  });

  @override
  State<CameraStreamPage> createState() => _CameraStreamPageState();
}

class _CameraStreamPageState extends State<CameraStreamPage> {
  // Native HLS init (ExoPlayer/AVPlayer) isn't covered by Dio's timeouts,
  // so without this it can hang indefinitely on a slow/unresponsive stream.
  static const _videoInitTimeout = Duration(seconds: 15);

  late CameraStreamBloc _cameraStreamBloc;
  late CameraControlBloc _cameraControlBloc;
  late AppConfig _appConfig;
  VideoPlayerController? _videoController;
  String? _videoError;
  StreamSubscription<CameraControlState>? _cameraControlSubscription;
  bool _isSendingPtzCommand = false;
  int? _queuedPtzCommand;
  int? _queuedPtzSpeed;
  int? _queuedPtzPreCommand;
  String? _lastStreamUrl;

  @override
  void initState() {
    super.initState();
    _appConfig = getIt<AppConfig>();
    _cameraStreamBloc = CameraStreamBloc(getCameraStreamUseCase: getIt());
    _cameraControlBloc = getIt<CameraControlBloc>();
    _cameraControlSubscription = _cameraControlBloc.stream.listen(
      _onCameraControlStateChanged,
    );

    _cameraStreamBloc.add(FetchCameraStreamEvent(cameraId: widget.cameraId));
  }

  Future<void> _initializeVideo(String streamUrl) async {
    final hlsUrl = '${_appConfig.streamUrl}$streamUrl';
    debugPrint('Initializing video with URL: $hlsUrl');

    _lastStreamUrl = streamUrl;
    final failedController = _videoController;
    _videoController = null;
    setState(() => _videoError = null);
    await failedController?.dispose();

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(hlsUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      );

      await controller.initialize().timeout(_videoInitTimeout);

      if (mounted) {
        setState(() => _videoController = controller);
        controller.play();
      } else {
        await controller.dispose();
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _videoError =
              'Tải stream quá lâu, vui lòng kiểm tra kết nối và thử lại.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _videoError = 'Lỗi tải video: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.cameraName,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<CameraStreamBloc, CameraStreamState>(
        bloc: _cameraStreamBloc,
        builder: (context, state) {
          if (state is CameraStreamLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }

          if (state is CameraStreamError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi tải stream',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        _cameraStreamBloc.add(
                          FetchCameraStreamEvent(cameraId: widget.cameraId),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is CameraStreamLoaded) {
            final streamUrl =
                state.cameraStream.streamUrl ?? state.cameraStream.cameraName;
            // Initialize video khi dữ liệu tải xong (retry chỉ qua nút bấm,
            // tránh vòng lặp gọi lại liên tục khi stream đang lỗi)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_videoController == null &&
                  _videoError == null &&
                  _lastStreamUrl != streamUrl) {
                _initializeVideo(streamUrl);
              }
            });

            return _buildFullscreenVideo(context, streamUrl);
          }

          return const Center(
            child: Text(
              'Không có dữ liệu',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoArea(BuildContext context, String streamUrl) {
    if (_videoError != null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 40),
            const SizedBox(height: 12),
            Text(
              _videoError!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _initializeVideo(streamUrl),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_videoController != null && _videoController!.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        const SizedBox(height: 16),
        Text(
          'Đang tải video...',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildFullscreenVideo(BuildContext context, String streamUrl) {
    return Stack(
      children: [
        Center(child: _buildVideoArea(context, streamUrl)),
        if (widget.isPtzCamera)
          PtzDpadController(
            initiallyVisible: false,
            initialSpeed: 30,
            onMove: (direction, speed) {
              _handlePtzMove(direction, speed);
            },
            onStop: () {
              _handlePtzStop();
            },
          ),
      ],
    );
  }

  Future<void> _handlePtzMove(PtzDirection direction, double speed) async {
    final command = _mapPtzDirectionToCommand(direction);
    final apiSpeed = _mapPtzSpeed(speed);
    final preCommand = _mapPreCommand(command);

    _sendPtzCommand(command: command, speed: apiSpeed, preCommand: preCommand);
  }

  Future<void> _handlePtzStop() async {
    _sendPtzCommand(command: 0, speed: 0);
  }

  int _mapPtzDirectionToCommand(PtzDirection direction) {
    switch (direction) {
      case PtzDirection.up:
        return 1;
      case PtzDirection.down:
        return 2;
      case PtzDirection.left:
        return 3;
      case PtzDirection.right:
        return 4;
      case PtzDirection.zoomIn:
        return 9;
      case PtzDirection.zoomOut:
        return 10;
    }
  }

  int _mapPtzSpeed(double speed) {
    // Backend PTZ speed is in range 0..63; current UI sends 0..60.
    final scaled = (speed * 63 / 60).round();
    return scaled.clamp(0, 63);
  }

  int? _mapPreCommand(int command) {
    if (command == 9) {
      return 10;
    }
    if (command == 10) {
      return 9;
    }
    return null;
  }

  void _sendPtzCommand({
    required int command,
    required int speed,
    int? preCommand,
  }) async {
    if (_isSendingPtzCommand) {
      // Keep the latest intent while a command is in-flight.
      _queuedPtzCommand = command;
      _queuedPtzSpeed = speed;
      _queuedPtzPreCommand = preCommand;
      return;
    }

    _isSendingPtzCommand = true;
    _cameraControlBloc.add(
      SendCameraControlEvent(
        cameraId: widget.cameraId,
        speed: speed,
        command: command,
        preCommand: preCommand,
      ),
    );
  }

  void _onCameraControlStateChanged(CameraControlState state) {
    if (state is CameraControlSending) {
      return;
    }

    if (state is CameraControlFailure) {
      debugPrint('PTZ API error: ${state.message}');
    }

    _isSendingPtzCommand = false;
    _dispatchQueuedPtzCommand();
  }

  void _dispatchQueuedPtzCommand() {
    if (_queuedPtzCommand == null || _queuedPtzSpeed == null) {
      return;
    }

    final nextCommand = _queuedPtzCommand!;
    final nextSpeed = _queuedPtzSpeed!;
    final nextPreCommand = _queuedPtzPreCommand;

    _queuedPtzCommand = null;
    _queuedPtzSpeed = null;
    _queuedPtzPreCommand = null;

    _sendPtzCommand(
      command: nextCommand,
      speed: nextSpeed,
      preCommand: nextPreCommand,
    );
  }

  // String _formatDuration(Duration duration) {
  //   String twoDigits(int n) => n.toString().padLeft(2, '0');
  //   String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  //   String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  //   if (duration.inHours > 0) {
  //     return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  //   }
  //   return '$twoDigitMinutes:$twoDigitSeconds';
  // }

  @override
  void dispose() {
    _cameraControlSubscription?.cancel();
    _videoController?.dispose();
    _cameraControlBloc.close();
    _cameraStreamBloc.close();
    super.dispose();
  }
}
