import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:thermal_mobile/core/configs/app_config.dart';
import 'package:thermal_mobile/core/constants/colors.dart';
import 'package:thermal_mobile/core/constants/icons.dart';
import 'package:thermal_mobile/di/injection.dart';
import 'package:thermal_mobile/domain/models/area_tree.dart';
import 'package:thermal_mobile/domain/models/camera_entity.dart';
import 'package:thermal_mobile/presentation/widgets/app_drawer_service.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../bloc/area/area_bloc.dart';
import '../../bloc/camera/camera_stream_bloc.dart';
import 'camera_stream_page.dart';

/// Global controller to manage all camera tiles
class CameraScreenController {
  static final CameraScreenController _instance =
      CameraScreenController._internal();
  factory CameraScreenController() => _instance;
  CameraScreenController._internal();

  final List<_CameraTileState> _tiles = [];

  void registerTile(_CameraTileState tile) {
    _tiles.add(tile);
  }

  void unregisterTile(_CameraTileState tile) {
    _tiles.remove(tile);
  }

  void pauseAll() {
    for (var tile in _tiles) {
      tile._pauseAllVideos();
    }
  }

  void resumeAll() {
    for (var tile in _tiles) {
      tile._resumeVideos();
    }
  }
}

/// Camera Screen - Displays area tree with cameras
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  AreaTree? _selectedArea;
  List<AreaTree> _flattenedAreas = [];

  @override
  void initState() {
    super.initState();
    // Fetch area tree when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          context.read<AreaBloc>().add(const FetchAreaTreeEvent());
        } catch (e) {
          // BLoC already closed, ignore
        }
      }
    });
  }

  /// Flatten area tree to get all areas (including nested)
  void _flattenAreas(List<AreaTree> areas) {
    _flattenedAreas = [];
    for (var area in areas) {
      _addAreaAndChildren(area);
    }
    // Set first area as selected by default
    if (_flattenedAreas.isNotEmpty && _selectedArea == null) {
      _selectedArea = _flattenedAreas.first;
    }
  }

  void _addAreaAndChildren(AreaTree area) {
    _flattenedAreas.add(area);
    for (var child in area.children) {
      _addAreaAndChildren(child);
    }
  }

  /// Get cameras for selected area
  List<CameraEntity> _getCamerasForArea(AreaTree area) {
    List<CameraEntity> cameras = [];
    cameras.addAll(area.cameras);
    // Also include cameras from child areas
    for (var child in area.children) {
      cameras.addAll(_getCamerasForArea(child));
    }
    return cameras;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
          kToolbarHeight + 8 + 1,
        ), // toolbar height + spacing + border
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.line.withOpacity(0.32),
                width: 1,
              ),
            ),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: InkWell(
              onTap: () {
                AppDrawerService.openDrawer();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SvgPicture.asset(
                  AppIcons.icMenu,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            title: Text(
              'Camera',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(16),
              child: SizedBox.shrink(),
            ),
          ),
        ),
      ),
      body: BlocBuilder<AreaBloc, AreaState>(
        builder: (context, state) {
          if (state is AreaLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Đang tải danh sách camera...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is AreaError) {
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
                        color: colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 48,
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Có lỗi xảy ra',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.tonal(
                      onPressed: () {
                        context.read<AreaBloc>().add(
                          const FetchAreaTreeEvent(),
                        );
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is AreaTreeLoaded) {
            // Flatten areas when loaded
            if (_flattenedAreas.isEmpty) {
              _flattenAreas(state.areas);
            }

            if (_flattenedAreas.isEmpty) {
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
                          color: colorScheme.outline.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.videocam_off,
                          size: 48,
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Không tìm thấy camera',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Không có khu vực camera nào được tìm thấy',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.tonal(
                        onPressed: () {
                          context.read<AreaBloc>().add(
                            const FetchAreaTreeEvent(),
                          );
                        },
                        child: const Text('Làm mới'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final cameras = _selectedArea != null
                ? _getCamerasForArea(_selectedArea!)
                : <CameraEntity>[];

            return Column(
              children: [
                // Horizontal area selector
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.line.withOpacity(0.32),
                        width: 1,
                      ),
                    ),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: _flattenedAreas.length,
                    itemBuilder: (context, index) {
                      final area = _flattenedAreas[index];
                      final isSelected = _selectedArea?.id == area.id;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _AreaChip(
                          area: area,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedArea = area;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                // Camera list for selected area
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<AreaBloc>().add(const FetchAreaTreeEvent());
                      _flattenedAreas = [];
                    },
                    color: colorScheme.primary,
                    child: cameras.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: colorScheme.outline.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.videocam_off,
                                      size: 48,
                                      color: colorScheme.outlineVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Không có camera',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: colorScheme.onSurface,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Khu vực "${_selectedArea?.name}" chưa có camera nào',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            key: ValueKey(_selectedArea?.id),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            itemCount: cameras.length,
                            itemBuilder: (context, index) {
                              return CameraTile(
                                key: ValueKey(cameras[index].id),
                                camera: cameras[index],
                                areaName: _selectedArea?.name,
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          }

          return Center(
            child: Text(
              'Unknown state',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        },
      ),
    );
  }
}

/// Area Chip Widget - displays area as a selectable chip
class _AreaChip extends StatelessWidget {
  final AreaTree area;
  final bool isSelected;
  final VoidCallback onTap;

  const _AreaChip({
    required this.area,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryDark
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.backgroundDark
                  : colorScheme.outline.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 18,
                color: isSelected ? Colors.white : colorScheme.onSurface,
              ),
              const SizedBox(width: 6),
              Text(
                area.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected ? Colors.white : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hierarchical Area Tree Tile Widget - Material Design 3
/// (Kept for backward compatibility but not used in new UI)
class AreaTreeTile extends StatefulWidget {
  final AreaTree area;

  const AreaTreeTile({super.key, required this.area});

  @override
  State<AreaTreeTile> createState() => _AreaTreeTileState();
}

class _AreaTreeTileState extends State<AreaTreeTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotateAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasChildren = widget.area.children.isNotEmpty;
    final hasCameras = widget.area.cameras.isNotEmpty;
    final isExpandable = hasChildren || hasCameras;

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (isExpandable) {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                  if (_isExpanded) {
                    _animationController.forward();
                  } else {
                    _animationController.reverse();
                  }
                } else {
                  // If no children (leaf node/camera), navigate to stream page
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CameraStreamPage(
                        cameraId: widget.area.id,
                        cameraName: widget.area.name,
                      ),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Leading Icon
                    if (isExpandable)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: RotationTransition(
                          turns: _rotateAnimation,
                          child: Icon(
                            Icons.expand_more_rounded,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.videocam_rounded,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                    const SizedBox(width: 12),
                    // Title & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.area.name,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'ID: ${widget.area.id}',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.area.code,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              if (isExpandable)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${widget.area.children.length + widget.area.cameras.length}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          widget.area.status,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        widget.area.status,
                        style: TextStyle(
                          color: _getStatusColor(widget.area.status),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Nested children and cameras
        if (_isExpanded && isExpandable)
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              children: [
                // Child areas
                ...widget.area.children.map(
                  (childArea) => AreaTreeTile(area: childArea),
                ),
                // Cameras in this area
                ...widget.area.cameras.map(
                  (camera) => CameraTile(camera: camera),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'online':
        return Colors.green;
      case 'inactive':
      case 'offline':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

/// Camera Tile Widget - displays individual camera with video stream
class CameraTile extends StatefulWidget {
  final CameraEntity camera;
  final String? areaName;

  const CameraTile({super.key, required this.camera, this.areaName});

  @override
  State<CameraTile> createState() => _CameraTileState();
}

class _CameraTileState extends State<CameraTile>
    with WidgetsBindingObserver, RouteAware {
  late CameraStreamBloc _cameraStreamBloc;
  late AppConfig _appConfig;
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isVisible = false;
  bool _isActive = true; // Track if tile should be active
  String? _pendingStreamUrl; // Store stream URL until visible
  bool _isDisposed = false; // Track if widget is disposed

  @override
  void initState() {
    super.initState();
    _appConfig = getIt<AppConfig>();
    _cameraStreamBloc = CameraStreamBloc(getCameraStreamUseCase: getIt());
    _cameraStreamBloc.add(FetchCameraStreamEvent(cameraId: widget.camera.id));
    WidgetsBinding.instance.addObserver(this);
    CameraScreenController().registerTile(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // App in background, dispose video
      _disposeVideo();
    } else if (state == AppLifecycleState.resumed && _isVisible && _isActive) {
      // App resumed, reinitialize if we have stream URL
      if (_pendingStreamUrl != null && !_isInitialized) {
        _initializeVideo(_pendingStreamUrl!);
      }
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    // Don't process if widget is disposed
    if (_isDisposed) return;

    final visiblePercentage = info.visibleFraction * 100;

    // Consider visible if more than 20% is shown (increased threshold)
    if (visiblePercentage > 20) {
      if (!_isVisible) {
        _isVisible = true;
        // Initialize video only when visible
        if (_isActive &&
            _pendingStreamUrl != null &&
            !_isInitialized &&
            _videoController == null) {
          _initializeVideo(_pendingStreamUrl!);
        } else if (_isActive && _videoController?.value.isInitialized == true) {
          _videoController?.play();
        }
      }
    } else {
      if (_isVisible) {
        _isVisible = false;
        // Dispose video completely when not visible to free resources
        _disposeVideo();
      }
    }
  }

  void _disposeVideo() {
    // Don't process if widget is already disposed
    if (_isDisposed) return;

    // Check if controller exists and is not already disposed
    final controller = _videoController;
    if (controller != null) {
      // Set to null first to prevent double disposal
      _videoController = null;

      try {
        // Only pause if controller is still usable
        if (controller.value.isInitialized) {
          controller.pause();
        }
      } catch (e) {
        // Controller might already be disposed, ignore
      } finally {
        // Always try to dispose
        try {
          controller.dispose();
        } catch (e) {
          // Already disposed, ignore
        }
      }

      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  Future<void> _initializeVideo(String streamUrl) async {
    // Don't initialize if not visible or not active
    if (!_isVisible || !_isActive) {
      _pendingStreamUrl = streamUrl;
      return;
    }

    final hlsUrl = '${_appConfig.streamUrl}$streamUrl';

    try {
      // Dispose any existing controller first
      if (_videoController != null) {
        await _videoController!.dispose();
        _videoController = null;
      }

      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(hlsUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      );

      await _videoController!.initialize();

      if (mounted && _isVisible && _isActive) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
        _videoController!.play();
        _videoController!.setLooping(true);
      } else {
        // If conditions changed during init, dispose
        _disposeVideo();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _pauseAllVideos() {
    setState(() {
      _isActive = false;
    });
    // Dispose instead of just pause
    _disposeVideo();
  }

  void _resumeVideos() {
    setState(() {
      _isActive = true;
    });
    // Reinitialize if visible and we have stream URL
    if (_isVisible &&
        _pendingStreamUrl != null &&
        !_isInitialized &&
        _videoController == null) {
      _initializeVideo(_pendingStreamUrl!);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    CameraScreenController().unregisterTile(this);
    WidgetsBinding.instance.removeObserver(this);

    // Safely dispose video controller
    final controller = _videoController;
    _videoController = null;
    try {
      controller?.dispose();
    } catch (e) {
      // Already disposed, ignore
    }

    _cameraStreamBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<CameraStreamBloc, CameraStreamState>(
      bloc: _cameraStreamBloc,
      listener: (context, state) {
        if (state is CameraStreamLoaded) {
          // Store stream URL but don't initialize yet
          _pendingStreamUrl =
              state.cameraStream.streamUrl ?? state.cameraStream.cameraName;
          // Only initialize if visible and active
          if (_isVisible && _isActive && !_isInitialized) {
            _initializeVideo(_pendingStreamUrl!);
          }
        }
      },
      child: VisibilityDetector(
        key: Key('camera_tile_${widget.camera.id}'),
        onVisibilityChanged: _onVisibilityChanged,
        child: Card(
          color: Color(0xFF343E4F),
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                // Pause ALL videos in the screen before navigating
                CameraScreenController().pauseAll();

                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CameraStreamPage(
                      cameraId: widget.camera.id,
                      cameraName: widget.camera.name,
                    ),
                  ),
                );

                // Resume ALL videos when coming back
                if (mounted) {
                  CameraScreenController().resumeAll();
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video Preview
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.black,
                      child: _buildVideoPreview(),
                    ),
                  ),
                  // Camera Info
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Title & Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.camera.name,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.areaName ?? 'Chưa có trạm',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: AppColors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Arrow icon
                        Icon(
                          Icons.fullscreen,
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (_hasError) {
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[300], size: 40),
              const SizedBox(height: 8),
              Text(
                'Lỗi tải video',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _videoController == null) {
      return BlocBuilder<CameraStreamBloc, CameraStreamState>(
        bloc: _cameraStreamBloc,
        builder: (context, state) {
          if (state is CameraStreamError) {
            return Container(
              color: Colors.grey[900],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_off, color: Colors.grey[600], size: 40),
                    const SizedBox(height: 8),
                    Text(
                      'Không có stream',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            color: Colors.grey[900],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Đang tải...',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    if (_videoController!.value.isInitialized) {
      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      color: Colors.grey[900],
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ),
    );
  }

  Color _getStatusColor(bool isActive) {
    return isActive ? Colors.green : Colors.red;
  }
}
