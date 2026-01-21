import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thermal_mobile/presentation/models/filter_params.dart';

/// Dialog filter cho tab Nhiệt độ vượt ngưỡng
class TemperatureFilterDialog extends StatefulWidget {
  final TemperatureFilterParams initialParams;
  final List<DropdownMenuItem<int>> areaItems;
  final List<DropdownMenuItem<int>> machineItems;
  final Future<List<DropdownMenuItem<int>>> Function(int?) getMachineItems;

  const TemperatureFilterDialog({
    Key? key,
    required this.initialParams,
    required this.areaItems,
    required this.machineItems,
    required this.getMachineItems,
  }) : super(key: key);

  @override
  State<TemperatureFilterDialog> createState() => _TemperatureFilterDialogState();
}

class _TemperatureFilterDialogState extends State<TemperatureFilterDialog> {
  late DateTime fromTime;
  late DateTime toTime;
  int? areaId;
  int? machineId;
  int? notificationStatus;

  late List<DropdownMenuItem<int>> _machineItems;
  bool _loadingMachines = false;

  @override
  void initState() {
    super.initState();
    fromTime = widget.initialParams.fromTime ?? DateTime.now().subtract(const Duration(days: 7));
    toTime = widget.initialParams.toTime ?? DateTime.now();
    areaId = widget.initialParams.areaId;
    machineId = widget.initialParams.machineId;
    notificationStatus = widget.initialParams.notificationStatus;

    // Initialize machine list from caller so reopening preserves previous selection.
    _machineItems = widget.machineItems;
    // If there is an area but no initial machines, load them.
    if (areaId != null && _machineItems.isEmpty) {
      _loadMachines(areaId);
    }
  }

  Future<void> _loadMachines(int? areaId) async {
    setState(() {
      _loadingMachines = true;
      _machineItems = [];
    });
    try {
      final machines = await widget.getMachineItems(areaId);
      setState(() {
        _machineItems = machines;
        // If the previously selected machine is not in the new list, clear selection.
        if (machineId != null && !_machineItems.any((m) => m.value == machineId)) {
          machineId = null;
        }
      });
    } catch (_) {
      // ignore errors and keep machines empty
    } finally {
      setState(() {
        _loadingMachines = false;
      });
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
        machineId: machineId,
        notificationStatus: notificationStatus,
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
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.filter_list,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Lọc Nhiệt độ vượt ngưỡng',
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
                        final changedArea = v;
                        setState(() {
                          areaId = changedArea;
                          machineId = null;
                        });
                        if (changedArea != null) {
                          await _loadMachines(changedArea);
                        } else {
                          setState(() {
                            _machineItems = [];
                          });
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
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                        prefixIcon: const Icon(Icons.location_on, color: Color(0xFF94A3B8), size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF94A3B8)),
                    ),
                    // Machine Section
                    if (areaId != null) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Thiết bị',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_loadingMachines)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2D2D),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF3D3D3D)),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        )
                      else if (_machineItems.isNotEmpty)
                        DropdownButtonFormField<int>(
                          value: machineId,
                          items: _machineItems,
                          onChanged: (v) => setState(() => machineId = v),
                          dropdownColor: const Color(0xFF2D2D2D),
                          decoration: InputDecoration(
                            hintText: 'Chọn thiết bị',
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
                              borderSide: const BorderSide(color: Colors.orange),
                            ),
                            prefixIcon: const Icon(Icons.precision_manufacturing, color: Color(0xFF94A3B8), size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF94A3B8)),
                        ),
                    ],                    // Status Section
                    const SizedBox(height: 20),
                    const Text(
                      'Trạng thái',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2D),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF3D3D3D)),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () => setState(() => notificationStatus = 1),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(
                                    notificationStatus == 1 ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                    color: notificationStatus == 1 ? Colors.orange : const Color(0xFF64748B),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Chưa xử lý',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(height: 1, color: const Color(0xFF3D3D3D)),
                          InkWell(
                            onTap: () => setState(() => notificationStatus = 2),
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(
                                    notificationStatus == 2 ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                    color: notificationStatus == 2 ? Colors.orange : const Color(0xFF64748B),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Đã xử lý',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
                      backgroundColor: Colors.orange,
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
