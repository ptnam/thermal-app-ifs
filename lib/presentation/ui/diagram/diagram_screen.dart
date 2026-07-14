import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:thermal_mobile/core/constants/colors.dart';
import 'package:thermal_mobile/core/constants/icons.dart';
import 'package:thermal_mobile/core/types/get_access_token.dart';
import 'package:thermal_mobile/core/utils/thermal_level_style.dart';
import 'package:thermal_mobile/data/local/storage/config_storage.dart';
import 'package:thermal_mobile/data/mappers/machine_thermal_mapper.dart';
import 'package:thermal_mobile/data/network/thermal_data/dto/machine_result_dto.dart';
import 'package:thermal_mobile/data/network/thermal_data/thermal_data_api_service.dart';
import 'package:thermal_mobile/data/network/thermal_data/thermal_data_hub_service.dart';
import 'package:thermal_mobile/di/injection.dart';
import 'package:thermal_mobile/domain/models/area_tree.dart';
import 'package:thermal_mobile/domain/models/machine_thermal_entity.dart';
import 'package:thermal_mobile/presentation/widgets/app_drawer_service.dart';

import '../../bloc/area/area_bloc.dart';

/// Screen showing a single, user-picked area schematic/diagram image
/// (mapTypeObject.id == 2, i.e. "Picture" areas). The chosen area is
/// persisted locally so it's remembered next time the screen opens.
class DiagramScreen extends StatefulWidget {
  const DiagramScreen({super.key});

  @override
  State<DiagramScreen> createState() => _DiagramScreenState();
}

class _DiagramScreenState extends State<DiagramScreen> {
  static const int _diagramMapTypeId = 2;

  final ConfigStorage _configStorage = getIt<ConfigStorage>();
  final ThermalDataHubService _hubService = getIt<ThermalDataHubService>();
  StreamSubscription<List<MachineLevelUpdate>>? _hubSubscription;

  List<AreaTree> _flattenedAreas = [];
  int? _selectedDiagramAreaId;
  int _rotationQuarterTurns = 0;

  List<MachineResultEntity> _devices = [];
  int? _devicesLoadedForAreaId;

  @override
  void initState() {
    super.initState();
    _selectedDiagramAreaId = _configStorage.getSelectedDiagramAreaId();
    _hubSubscription = _hubService.updates.listen(_applyLevelUpdates);
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

  @override
  void dispose() {
    _hubSubscription?.cancel();
    _hubService.disconnect();
    super.dispose();
  }

  /// Fetch device pins (machines + sensors) for the currently-shown area,
  /// then subscribe to realtime temperature-level updates for them via the
  /// backend's `ThermalDataHub` (SignalR) so pin status stays live without
  /// needing to re-fetch the area.
  Future<void> _loadDevicesForArea(int areaId) async {
    try {
      final accessToken = await getIt<GetAccessToken>()();
      final result = await getIt<ThermalDataApiService>()
          .getMachinesAndResultByArea(areaId: areaId, accessToken: accessToken);
      final devices = (result.data?.item1 ?? [])
          .map(MachineThermalMapper.toEntity)
          .toList();
      if (!mounted || areaId != _selectedDiagramAreaId) return;
      setState(() => _devices = devices);

      final machineIds = devices.map((d) => d.machineId).toSet();
      if (machineIds.isNotEmpty) {
        await _hubService.connect();
        await _hubService.registerMachines(machineIds);
      }
    } catch (e) {
      // Ignore — pins are a supplementary overlay, not critical to the screen.
    }
  }

  /// Merges incoming realtime level changes into the currently-shown pins,
  /// matched by [MachineResultEntity.key] (same "{id}_{deviceType}" key the
  /// hub uses).
  void _applyLevelUpdates(List<MachineLevelUpdate> updates) {
    if (!mounted || updates.isEmpty) return;
    final byKey = {for (final update in updates) update.key: update};
    var changed = false;
    final merged = _devices.map((device) {
      final update = byKey[device.key];
      if (update != null && update.level != device.level) {
        changed = true;
        return device.copyWith(level: update.level);
      }
      return device;
    }).toList();
    if (changed) setState(() => _devices = merged);
  }

  void _flattenAreas(List<AreaTree> areas) {
    _flattenedAreas = [];
    for (final area in areas) {
      _addAreaAndChildren(area);
    }
  }

  void _addAreaAndChildren(AreaTree area) {
    _flattenedAreas.add(area);
    for (final child in area.children) {
      _addAreaAndChildren(child);
    }
  }

  List<AreaTree> _getDiagramAreas() {
    return _flattenedAreas
        .where(
          (area) =>
              area.mapTypeId == _diagramMapTypeId &&
              area.photoPath != null &&
              area.photoPath!.isNotEmpty,
        )
        .toList();
  }

  AreaTree? _findSelected(List<AreaTree> diagrams) {
    for (final area in diagrams) {
      if (area.id == _selectedDiagramAreaId) return area;
    }
    return null;
  }

  Future<void> _openDiagramPicker() async {
    final diagrams = _getDiagramAreas();
    final selected = await showModalBottomSheet<AreaTree>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DiagramPickerSheet(
        diagrams: diagrams,
        selectedAreaId: _selectedDiagramAreaId,
      ),
    );
    if (selected != null) {
      await _configStorage.saveSelectedDiagramArea(
        id: selected.id,
        name: selected.name,
      );
      if (!mounted) return;
      setState(() {
        _selectedDiagramAreaId = selected.id;
        _devices = [];
      });
    }
  }

  void _rotateImage() {
    setState(() => _rotationQuarterTurns = (_rotationQuarterTurns + 1) % 4);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = context.watch<AreaBloc>().state;

    AreaTree? selected;
    if (state is AreaTreeLoaded) {
      _flattenAreas(state.areas);
      selected = _findSelected(_getDiagramAreas());
    }

    if (selected != null && selected.id != _devicesLoadedForAreaId) {
      _devicesLoadedForAreaId = selected.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadDevicesForArea(selected!.id);
      });
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 8 + 1),
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sơ đồ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (selected != null)
                  Text(
                    selected.name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            actions: [
              if (selected != null)
                _AppBarIconButton(
                  icon: Icons.rotate_right_rounded,
                  tooltip: 'Xoay hình',
                  onPressed: _rotateImage,
                ),
              _AppBarIconButton(
                icon: Icons.add,
                tooltip: 'Chọn sơ đồ',
                onPressed: _openDiagramPicker,
              ),
              const SizedBox(width: 12),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(16),
              child: SizedBox.shrink(),
            ),
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          if (state is AreaLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Đang tải sơ đồ...',
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
            final diagrams = _getDiagramAreas();

            if (diagrams.isEmpty) {
              return _buildGuideState(
                context,
                icon: Icons.map_outlined,
                title: 'Chưa có sơ đồ nào',
                subtitle: 'Khu vực chưa được cấu hình hình ảnh sơ đồ',
                showPickButton: false,
              );
            }

            if (selected == null) {
              return _buildGuideState(
                context,
                icon: Icons.touch_app_outlined,
                title: 'Chưa chọn sơ đồ để hiển thị',
                subtitle: 'Nhấn nút + ở trên để chọn sơ đồ muốn xem',
                showPickButton: true,
              );
            }

            return _DiagramImage(
              area: selected,
              quarterTurns: _rotationQuarterTurns,
              devices: selected.id == _devicesLoadedForAreaId ? _devices : const [],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildGuideState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool showPickButton,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
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
              child: Icon(icon, size: 48, color: colorScheme.outlineVariant),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (showPickButton) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _openDiagramPicker,
                icon: const Icon(Icons.add),
                label: const Text('Chọn sơ đồ'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Renders a single diagram image (SVG or raster) with pinch-to-zoom, an
/// optional 90°-step rotation, and device pins placed via longitude/latitude
/// (pixel coordinates in the *original* image's coordinate space).
class _DiagramImage extends StatefulWidget {
  final AreaTree area;
  final int quarterTurns;
  final List<MachineResultEntity> devices;

  const _DiagramImage({
    required this.area,
    required this.devices,
    this.quarterTurns = 0,
  });

  @override
  State<_DiagramImage> createState() => _DiagramImageState();
}

class _DiagramImageState extends State<_DiagramImage> {
  static final Map<String, Uint8List> _rasterCache = {};
  static final Map<String, Size> _rasterSizeCache = {};
  static final Map<String, ui.Picture> _svgPictureCache = {};
  static final Map<String, Size> _svgSizeCache = {};

  bool get _isSvg => (widget.area.photoPath ?? '')
      .toLowerCase()
      .split('?')
      .first
      .endsWith('.svg');

  String? _loadedForPath;
  Size? _naturalSize;
  ui.Picture? _svgPicture;
  Uint8List? _imageBytes;
  bool _hasError = false;

  /// Tracks the InteractiveViewer's live zoom so device pin markers can be
  /// counter-scaled to stay a fixed on-screen size (like map pins) while
  /// their position still tracks the image.
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant _DiagramImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.area.photoPath != widget.area.photoPath) {
      _resolveImage();
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  /// Fetches the diagram image via the app's shared [Dio] instance rather
  /// than [NetworkImage]/[SvgNetworkLoader] directly. Those use Flutter's
  /// default HttpClient, which doesn't go through the certificate-bypass
  /// adapter configured for [Dio] (see `injection.dart`) — so on a physical
  /// device validating the backend's certificate strictly, they could fail
  /// intermittently (or entirely) while the rest of the app's API calls,
  /// which do use Dio, kept working.
  Future<void> _resolveImage() async {
    final path = widget.area.photoPath;
    _loadedForPath = path;
    _naturalSize = null;
    _svgPicture = null;
    _imageBytes = null;
    _hasError = path == null || path.isEmpty;

    if (path == null || path.isEmpty) return;

    if (_isSvg) {
      final cachedPicture = _svgPictureCache[path];
      final cachedSize = _svgSizeCache[path];
      if (cachedPicture != null && cachedSize != null) {
        if (!mounted || _loadedForPath != path) return;
        setState(() {
          _naturalSize = cachedSize;
          _svgPicture = cachedPicture;
          _hasError = false;
        });
        return;
      }
    } else {
      final cachedBytes = _rasterCache[path];
      final cachedSize = _rasterSizeCache[path];
      if (cachedBytes != null && cachedSize != null) {
        if (!mounted || _loadedForPath != path) return;
        setState(() {
          _naturalSize = cachedSize;
          _imageBytes = cachedBytes;
          _hasError = false;
        });
        return;
      }
    }

    try {
      final response = await getIt<Dio>().get<List<int>>(
        path,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data ?? const []);
      if (!mounted || _loadedForPath != path) return;

      if (_isSvg) {
        final info = await vg.loadPicture(SvgBytesLoader(bytes), context);
        if (!mounted || _loadedForPath != path) return;
        _svgPictureCache[path] = info.picture;
        _svgSizeCache[path] = info.size;
        setState(() {
          _naturalSize = info.size;
          _svgPicture = info.picture;
          _hasError = false;
        });
      } else {
        final image = await decodeImageFromList(bytes);
        if (!mounted || _loadedForPath != path) return;
        final size = Size(image.width.toDouble(), image.height.toDouble());
        _rasterCache[path] = bytes;
        _rasterSizeCache[path] = size;
        setState(() {
          _naturalSize = size;
          _imageBytes = bytes;
          _hasError = false;
        });
      }
    } catch (e) {
      if (!mounted || _loadedForPath != path) return;
      setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) return _buildBrokenImage();

    final naturalSize = _naturalSize;
    if (naturalSize == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 5.0,
      transformationController: _transformationController,
      child: RotatedBox(
        quarterTurns: widget.quarterTurns,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boxSize = constraints.biggest;
            final fitted = applyBoxFit(BoxFit.contain, naturalSize, boxSize);
            final destRect = Alignment.center.inscribe(
              fitted.destination,
              Offset.zero & boxSize,
            );
            // The web admin's pin picker places pins on the image scaled
            // (preserving aspect ratio) into a max 1075×619 box — that
            // scaled-down size, not the image's native pixel size, is the
            // coordinate space longitude/latitude are expressed in.
            final pinCanvasSize = applyBoxFit(
              BoxFit.contain,
              naturalSize,
              const Size(1075, 619),
            ).destination;

            return AnimatedBuilder(
              animation: _transformationController,
              builder: (context, _) {
                final zoomScale = _transformationController.value
                    .getMaxScaleOnAxis();
                return Stack(
                  children: [
                    Positioned.fromRect(
                      rect: destRect,
                      child: _isSvg
                          ? CustomPaint(
                              size: destRect.size,
                              painter: _SvgPicturePainter(
                                _svgPicture!,
                                naturalSize,
                              ),
                            )
                          : Image.memory(
                              _imageBytes!,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildBrokenImage(),
                            ),
                    ),
                    for (final device in widget.devices)
                      ..._buildDevicePin(
                        device,
                        destRect,
                        pinCanvasSize,
                        zoomScale,
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildDevicePin(
    MachineResultEntity device,
    Rect destRect,
    Size pinCanvasSize,
    double zoomScale,
  ) {
    final nx = device.longitude / pinCanvasSize.width;
    // Pins were placed with Leaflet's CRS.Simple, where latitude increases
    // *upward* (like real geographic coordinates) — the opposite of
    // top-down screen/image pixel coordinates, so it must be inverted here.
    final ny = 1 - device.latitude / pinCanvasSize.height;
    if (nx < 0 || nx > 1 || ny < 0 || ny > 1) return const [];

    const markerSize = 24.0;
    final px = destRect.left + nx * destRect.width;
    final py = destRect.top + ny * destRect.height;

    return [
      Positioned(
        left: px - markerSize / 2,
        top: py - markerSize / 2,
        child: Transform.scale(
          // Counter-scale against the InteractiveViewer's zoom so the pin
          // stays a fixed on-screen size (like a map marker) while its
          // position still tracks the image underneath.
          scale: 1 / zoomScale,
          child: _DevicePinMarker(device: device),
        ),
      ),
    ];
  }

  Widget _buildBrokenImage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 12),
          Text(
            'Không thể tải sơ đồ',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// Paints a decoded SVG [ui.Picture] scaled from its natural size to fill
/// [size] — used instead of [SvgPicture] so we can reuse the same decode
/// (from [vg.loadPicture]) that gave us the diagram's natural size for pin
/// placement, rather than fetching/parsing the SVG a second time.
class _SvgPicturePainter extends CustomPainter {
  final ui.Picture picture;
  final Size naturalSize;

  _SvgPicturePainter(this.picture, this.naturalSize);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(
      size.width / naturalSize.width,
      size.height / naturalSize.height,
    );
    canvas.drawPicture(picture);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SvgPicturePainter oldDelegate) {
    return oldDelegate.picture != picture ||
        oldDelegate.naturalSize != naturalSize;
  }
}

/// Pin marker for a single device, positioned via [MachineResultEntity]'s
/// longitude/latitude. Background color reflects the device's current
/// temperature status ([ThermalLevelStyle]) — green/blue/yellow/red for
/// good/fair/average/bad — refreshed live over SignalR. Tap opens a bottom
/// sheet with the device's detailed thermal readings.
class _DevicePinMarker extends StatelessWidget {
  final MachineResultEntity device;

  const _DevicePinMarker({required this.device});

  @override
  Widget build(BuildContext context) {
    final style = ThermalLevelStyle.of(
      device.level,
      treatUndefinedAsGood: true,
    );
    final label = '${device.name} (${device.code}) · ${style.label}';
    return GestureDetector(
      onTap: () => _showDeviceDetailSheet(context, device),
      child: Tooltip(
        message: label,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: style.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.thermostat_rounded,
            size: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Opens a bottom sheet showing [device]'s detailed thermal readings,
/// fetched from `GET /api/ThermalDatas/thermalByComponent`.
void _showDeviceDetailSheet(BuildContext context, MachineResultEntity device) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _DeviceDetailSheet(device: device),
  );
}

/// Fetches and renders a device's thermal component readings (temperature,
/// min/max/average and per-comparison evaluation results) inside a bottom
/// sheet, opened by tapping a pin on the diagram.
class _DeviceDetailSheet extends StatefulWidget {
  final MachineResultEntity device;

  const _DeviceDetailSheet({required this.device});

  @override
  State<_DeviceDetailSheet> createState() => _DeviceDetailSheetState();
}

class _DeviceDetailSheetState extends State<_DeviceDetailSheet> {
  bool _loading = true;
  String? _error;
  Map<String, List<ThermalComponentDto>> _data = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final accessToken = await getIt<GetAccessToken>()();
      final result = await getIt<ThermalDataApiService>().getThermalByComponent(
        machineId: widget.device.machineId,
        id: widget.device.id,
        deviceType: widget.device.deviceType,
        accessToken: accessToken,
      );
      if (!mounted) return;
      setState(() {
        _data = result.data ?? const {};
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Không thể tải dữ liệu';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = _data.values.expand((list) => list).toList();
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Material(
          color: AppColors.menuBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.thermostat_rounded,
                        color: AppColors.primaryDark,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.device.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.device.code,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade700),
                Expanded(child: _buildBody(entries, scrollController)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    List<ThermalComponentDto> entries,
    ScrollController scrollController,
  ) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.white70)),
      );
    }
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'Không có dữ liệu',
          style: TextStyle(color: Colors.grey.shade400),
        ),
      );
    }
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: entries.length,
      itemBuilder: (context, index) =>
          _ComponentDetailCard(component: entries[index]),
    );
  }
}

/// Finds the worst (highest-severity) [CompareResultDto] among a component's
/// comparison results, used to color-code the card's overall status.
CompareResultDto? _worstCompareResult(ThermalComponentDto component) {
  CompareResultDto? worst;
  for (final result in component.dicThermalDataResults.values) {
    final compareResult = result.compareResultObject;
    if (compareResult == null) continue;
    if (worst == null || compareResult.id > worst.id) worst = compareResult;
  }
  return worst;
}

/// A single machine component's thermal reading card: current/min/max/avg
/// temperature plus a pill per comparison type (e.g. "So với môi trường" →
/// "Tốt"/"Khá"/"Trung bình"/"Xấu").
class _ComponentDetailCard extends StatelessWidget {
  final ThermalComponentDto component;

  const _ComponentDetailCard({required this.component});

  @override
  Widget build(BuildContext context) {
    final worst = _worstCompareResult(component);
    final style = ThermalLevelStyle.of(worst?.code);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      component.machineComponentName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      component.monitorPointCode,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${component.temperature.toStringAsFixed(1)}°C',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: style.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Min ${component.minTemperature.toStringAsFixed(1)}°C · '
            'TB ${component.aveTemperature.toStringAsFixed(1)}°C · '
            'Max ${component.maxTemperature.toStringAsFixed(1)}°C',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
          Text(
            '${component.dataSourceType} · ${component.timeData} '
            '${component.dateData}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          if (component.dicThermalDataResults.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: component.dicThermalDataResults.entries.map((entry) {
                final compareType = entry.value.compareTypeObject;
                final compareResult = entry.value.compareResultObject;
                return _ResultPill(
                  label: compareType?.name ?? entry.key,
                  resultLabel: compareResult?.name ?? '—',
                  style: ThermalLevelStyle.of(compareResult?.code),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small colored pill showing a comparison type's label and its resulting
/// status (e.g. "So với môi trường: Tốt"), colored via [ThermalLevelStyle].
class _ResultPill extends StatelessWidget {
  final String label;
  final String resultLabel;
  final ThermalLevelStyle style;

  const _ResultPill({
    required this.label,
    required this.resultLabel,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: style.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.color.withOpacity(0.5)),
      ),
      child: Text(
        '$label: $resultLabel',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: style.color,
        ),
      ),
    );
  }
}

/// Bottom sheet listing all available diagram areas for the user to pick.
class _DiagramPickerSheet extends StatelessWidget {
  final List<AreaTree> diagrams;
  final int? selectedAreaId;

  const _DiagramPickerSheet({
    required this.diagrams,
    required this.selectedAreaId,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.menuBackground,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.map_outlined, color: AppColors.primaryDark),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Chọn sơ đồ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade700),
            Flexible(
              child: diagrams.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Chưa có sơ đồ nào',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: diagrams.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: Colors.grey.shade800),
                      itemBuilder: (context, index) {
                        final area = diagrams[index];
                        final isSelected = area.id == selectedAreaId;
                        return ListTile(
                          onTap: () => Navigator.of(context).pop(area),
                          title: Text(
                            area.name,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primaryDark
                                  : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primaryDark,
                                )
                              : null,
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Small square icon button with a subtle background + border, used for
/// AppBar actions on the diagram screen (rotate / pick).
class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _AppBarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
