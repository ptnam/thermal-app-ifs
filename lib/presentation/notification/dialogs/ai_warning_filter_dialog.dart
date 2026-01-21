import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thermal_mobile/presentation/models/filter_params.dart';

/// Dialog filter cho tab Cảnh báo AI
class AIWarningFilterDialog extends StatefulWidget {
  final AIWarningFilterParams initialParams;
  final List<DropdownMenuItem<int>> areaItems;
  final List<DropdownMenuItem<int>> cameraItems;
  final Future<List<DropdownMenuItem<int>>> Function(int? areaId) getCameraItems;
  final List<DropdownMenuItem<int>> warningEventItems;

  const AIWarningFilterDialog({
    Key? key,
    required this.initialParams,
    required this.areaItems,
    required this.cameraItems,
    required this.getCameraItems,
    required this.warningEventItems,
  }) : super(key: key);

  @override
  State<AIWarningFilterDialog> createState() => _AIWarningFilterDialogState();
}

class _AIWarningFilterDialogState extends State<AIWarningFilterDialog> {
  late DateTime fromTime;
  late DateTime toTime;
  int? areaId;
  int? cameraId;
  int? warningEventId;

  @override
  void initState() {
    super.initState();
    fromTime = widget.initialParams.fromTime ?? DateTime.now().subtract(const Duration(days: 7));
    toTime = widget.initialParams.toTime ?? DateTime.now();
    areaId = widget.initialParams.areaId;
    cameraId = widget.initialParams.cameraId;
    warningEventId = widget.initialParams.warningEventId;
    _loadInitialCameraItems();
  }

  List<DropdownMenuItem<int>> _currentCameraItems = [];

  List<DropdownMenuItem<int>> _uniqueItems(List<DropdownMenuItem<int>> items) {
    final seen = <int?>{};
    final out = <DropdownMenuItem<int>>[];
    for (final item in items) {
      if (!seen.contains(item.value)) {
        seen.add(item.value);
        out.add(item);
      }
    }
    return out;
  }

  Future<void> _loadInitialCameraItems() async {
    if (areaId != null) {
      try {
        final items = await widget.getCameraItems(areaId);
        _currentCameraItems = _uniqueItems(items);
        setState(() {});
      } catch (_) {
        _currentCameraItems = [];
      }
    } else {
      _currentCameraItems = _uniqueItems(widget.cameraItems);
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? fromTime : toTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromTime = picked;
        } else {
          toTime = picked;
        }
      });
    }
  }

  void _onApply() {
    Navigator.of(context).pop(
      widget.initialParams.copyWith(
        fromTime: fromTime,
        toTime: toTime,
        areaId: areaId,
        cameraId: cameraId,
        warningEventId: warningEventId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.filter_list,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Lọc Cảnh báo AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Range Section
                    const Text(
                      'Khoảng thời gian',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickDate(isFrom: true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D2D2D),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF3D3D3D)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16, color: Color(0xFF94A3B8)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Từ ngày',
                                          style: TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          dateFormat.format(fromTime),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickDate(isFrom: false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D2D2D),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF3D3D3D)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16, color: Color(0xFF94A3B8)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Đến ngày',
                                          style: TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          dateFormat.format(toTime),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
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
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Area Section
                    const Text(
                      'Khu vực',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: areaId,
                      items: widget.areaItems,
                      onChanged: (v) async {
                        setState(() {
                          areaId = v;
                          cameraId = null;
                          _currentCameraItems = [];
                        });
                        if (v != null) {
                          try {
                            final items = await widget.getCameraItems(v);
                            setState(() => _currentCameraItems = _uniqueItems(items));
                          } catch (_) {
                            setState(() => _currentCameraItems = []);
                          }
                        }
                      },
                      dropdownColor: const Color(0xFF2D2D2D),
                      decoration: InputDecoration(
                        hintText: 'Chọn khu vực',
                        hintStyle: const TextStyle(color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: const Color(0xFF2D2D2D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF3D3D3D)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF3D3D3D)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        prefixIcon: const Icon(Icons.location_on, color: Color(0xFF94A3B8), size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF94A3B8)),
                    ),
                    // Camera Section
                    if (areaId != null) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Camera',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: cameraId,
                        items: _currentCameraItems,
                        onChanged: (v) => setState(() => cameraId = v),
                        dropdownColor: const Color(0xFF2D2D2D),
                        decoration: InputDecoration(
                          hintText: 'Chọn camera',
                          hintStyle: const TextStyle(color: Color(0xFF64748B)),
                          filled: true,
                          fillColor: const Color(0xFF2D2D2D),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF3D3D3D)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF3D3D3D)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                          prefixIcon: const Icon(Icons.camera_alt, color: Color(0xFF94A3B8), size: 20),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF94A3B8)),
                      ),
                    ],
                    const SizedBox(height: 20),
                    // Warning Event Section
                    const Text(
                      'Loại cảnh báo',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: warningEventId,
                      items: widget.warningEventItems,
                      onChanged: (v) => setState(() => warningEventId = v),
                      dropdownColor: const Color(0xFF2D2D2D),
                      decoration: InputDecoration(
                        hintText: 'Chọn loại cảnh báo',
                        hintStyle: const TextStyle(color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: const Color(0xFF2D2D2D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF3D3D3D)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF3D3D3D)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        prefixIcon: const Icon(Icons.warning, color: Color(0xFF94A3B8), size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF3D3D3D))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF94A3B8),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Hủy', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _onApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Áp dụng', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
