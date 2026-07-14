import 'package:flutter/material.dart';
import 'package:thermal_mobile/core/constants/colors.dart';
import 'package:thermal_mobile/core/error/error_mapper.dart';
import 'package:thermal_mobile/core/types/get_access_token.dart';
import 'package:thermal_mobile/data/network/area/area_api_service.dart';
import 'package:thermal_mobile/data/network/area/dto/area_tree_dto.dart';
import 'package:thermal_mobile/data/network/camera/camera_api_service.dart';
import 'package:thermal_mobile/data/network/camera/dto/camera_dto.dart';
import 'package:thermal_mobile/di/injection.dart';

/// Screen to pick which cameras are pinned, shown as the area tree.
/// Pushed from the camera list screen's settings button; pops with `true`
/// once the selection is saved so the caller can refresh its data.
class CameraPinSettingsScreen extends StatefulWidget {
  const CameraPinSettingsScreen({super.key});

  @override
  State<CameraPinSettingsScreen> createState() =>
      _CameraPinSettingsScreenState();
}

class _CameraPinSettingsScreenState extends State<CameraPinSettingsScreen> {
  final AreaApiService _areaApiService = getIt<AreaApiService>();
  final CameraApiService _cameraApiService = getIt<CameraApiService>();
  final GetAccessToken _getAccessToken = getIt<GetAccessToken>();

  bool _loading = true;
  bool _saving = false;
  String? _error;
  List<AreaTreeDto> _areas = [];
  final Set<int> _selectedCameraIds = {};

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final token = await _getAccessToken();
    final result = await _areaApiService.getAreaAllTree(accessToken: token);

    if (!mounted) return;

    result.fold(
      onFailure: (error) {
        setState(() {
          _error = ErrorMapper.mapErrorToUserMessage(error.message);
          _loading = false;
        });
      },
      onSuccess: (data) {
        final areas = data ?? [];
        setState(() {
          _areas = areas;
          _selectedCameraIds
            ..clear()
            ..addAll(_collectPinnedIds(areas));
          _loading = false;
        });
      },
    );
  }

  Set<int> _collectPinnedIds(List<AreaTreeDto> areas) {
    final ids = <int>{};
    void visit(AreaTreeDto area) {
      for (final camera in area.cameras) {
        if (camera.isPined && camera.id != null) {
          ids.add(camera.id!);
        }
      }
      for (final child in area.children) {
        visit(child);
      }
    }

    for (final area in areas) {
      visit(area);
    }
    return ids;
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final token = await _getAccessToken();
    final result = await _cameraApiService.savePinnedCameras(
      cameraIds: _selectedCameraIds.toList(),
      accessToken: token,
    );

    if (!mounted) return;

    result.fold(
      onFailure: (error) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMapper.mapErrorToUserMessage(error.message)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onSuccess: (_) {
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          'Ghim camera',
          style: textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: _loadAreas,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.push_pin,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Đã chọn: ${_selectedCameraIds.length} camera',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _areas.isEmpty
                      ? Center(
                          child: Text(
                            'Không có camera',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          children: _areas
                              .map((area) => _buildAreaNode(area, textTheme))
                              .toList(),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Lưu'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAreaNode(
    AreaTreeDto area,
    TextTheme textTheme, {
    int depth = 0,
  }) {
    final left = (depth * 16.0).clamp(0, 96.0).toDouble();
    final hasContent = area.children.isNotEmpty || area.cameras.isNotEmpty;

    if (!hasContent) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16 + left, 6, 16, 6),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white38, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                area.name,
                style: textTheme.bodyMedium?.copyWith(color: Colors.white54),
              ),
            ),
          ],
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: EdgeInsets.fromLTRB(16 + left, 0, 16, 0),
        iconColor: Colors.white70,
        collapsedIconColor: Colors.white70,
        leading: const Icon(Icons.folder_open, color: Colors.white70),
        title: Text(
          area.name,
          style: textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          ...area.cameras.map(
            (camera) => _buildCameraTile(camera, textTheme, depth + 1),
          ),
          ...area.children.map(
            (child) => _buildAreaNode(child, textTheme, depth: depth + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraTile(CameraDto camera, TextTheme textTheme, int depth) {
    final left = (depth * 16.0).clamp(0, 96.0).toDouble();
    final id = camera.id;
    final isSelected = id != null && _selectedCameraIds.contains(id);

    return CheckboxListTile(
      value: isSelected,
      onChanged: id == null
          ? null
          : (checked) {
              setState(() {
                if (checked == true) {
                  _selectedCameraIds.add(id);
                } else {
                  _selectedCameraIds.remove(id);
                }
              });
            },
      contentPadding: EdgeInsets.fromLTRB(16 + left, 0, 16, 0),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: const Color(0xFF5B6FE5),
      checkColor: Colors.white,
      secondary: const Icon(Icons.videocam_outlined, color: Colors.orange),
      title: Text(
        camera.name ?? 'N/A',
        style: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
      subtitle: camera.code != null
          ? Text(
              camera.code!,
              style: textTheme.labelSmall?.copyWith(color: Colors.white54),
            )
          : null,
    );
  }
}
