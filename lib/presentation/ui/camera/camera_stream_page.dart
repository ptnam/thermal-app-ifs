import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermal_mobile/core/configs/app_config.dart';
import 'package:thermal_mobile/domain/models/camera_stream.dart';
import 'package:thermal_mobile/presentation/widgets/ptz_dpad_controller.dart';
import 'package:video_player/video_player.dart';
import '../../bloc/camera/camera_stream_bloc.dart';
import '../../../di/injection.dart';

/// Camera Stream Page - Displays stream information
class CameraStreamPage extends StatefulWidget {
  final int cameraId;
  final String cameraName;

  const CameraStreamPage({
    super.key,
    required this.cameraId,
    required this.cameraName,
  });

  @override
  State<CameraStreamPage> createState() => _CameraStreamPageState();
}

class _CameraStreamPageState extends State<CameraStreamPage> {
  late CameraStreamBloc _cameraStreamBloc;
  late AppConfig _appConfig;
  VideoPlayerController? _videoController;  

  @override
  void initState() {
    super.initState();
    _appConfig = getIt<AppConfig>();
    _cameraStreamBloc = CameraStreamBloc(
      getCameraStreamUseCase: getIt(),
    );
    _cameraStreamBloc.add(
      FetchCameraStreamEvent(cameraId: widget.cameraId),
    );
  }

  Future<void> _initializeVideo(String streamUrl) async {
    final hlsUrl = '${_appConfig.streamUrl}$streamUrl';
    print('Initializing video with URL: $hlsUrl');
    
    try {
      _videoController?.dispose();
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(hlsUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false, allowBackgroundPlayback: false),
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      );

      await _videoController!.initialize();
      
      if (mounted) {
        setState(() {
        });
        _videoController!.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải video: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[400],
                          ),
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
            // Initialize video khi dữ liệu tải xong
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_videoController == null) {
                _initializeVideo(state.cameraStream.streamUrl ?? state.cameraStream.cameraName);
              }
            });

            return _buildFullscreenVideo(context);
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

  Widget _buildFullscreenVideo(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: _videoController != null && _videoController!.value.isInitialized
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(_videoController!),
                    ),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Đang tải video...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[400],
                          ),
                    ),
                  ],
                ),
        ),
        // PTZ D-Pad Controller
        PtzDpadController(
          initiallyVisible: false,
          initialSpeed: 0.5,
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

  void _handlePtzMove(PtzDirection direction, double speed) {
    // TODO: Implement PTZ API call
    // Example: Call camera PTZ API with direction and speed
    debugPrint('PTZ Move: $direction at speed $speed');
  }

  void _handlePtzStop() {
    // TODO: Implement PTZ stop API call
    debugPrint('PTZ Stop');
  }

  Widget _buildStreamContent(BuildContext context, CameraStream stream) {
    // final hlsUrl = '${_appConfig.streamUrl}${stream.streamUrl}';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player
          Container(
            width: double.infinity,
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _videoController != null && _videoController!.value.isInitialized
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(_videoController!),
                      ],
                    )
                  : Container(
                      color: Colors.grey[900],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Đang tải video...',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[400],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          // Status Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: stream.status == 'online'
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        stream.status == 'online'
                            ? Icons.circle
                            : Icons.error,
                        color: stream.status == 'online'
                            ? Colors.green
                            : Colors.orange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trạng thái',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stream.status == 'online'
                                ? 'Đang trực tuyến'
                                : 'Ngoại tuyến',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Stream Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin stream',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  context,
                  'Tên camera',
                  stream.cameraName,
                  Icons.videocam,
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                if (stream.streamUrl != null && stream.streamUrl!.isNotEmpty)
                  _buildInfoCard(
                    context,
                    'Stream ID',
                    stream.streamUrl!,
                    Icons.link,
                    Colors.teal,
                    onCopy: () => _copyToClipboard(stream.streamUrl!),
                  ),
                const SizedBox(height: 12),
                if (stream.rtspUrl != null && stream.rtspUrl!.isNotEmpty)
                  _buildInfoCard(
                    context,
                    'RTSP URL',
                    stream.rtspUrl!,
                    Icons.videocam,
                    Colors.orange,
                    onCopy: () => _copyToClipboard(stream.rtspUrl!),
                  ),
                const SizedBox(height: 12),
                if (stream.dashUrl != null && stream.dashUrl!.isNotEmpty)
                  _buildInfoCard(
                    context,
                    'DASH URL',
                    stream.dashUrl!,
                    Icons.video_library,
                    Colors.indigo,
                    onCopy: () => _copyToClipboard(stream.dashUrl!),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onCopy,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: Colors.grey[700],
                        ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onCopy != null)
                  TextButton.icon(
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Sao chép'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép vào clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _cameraStreamBloc.close();
    super.dispose();
  }
}
