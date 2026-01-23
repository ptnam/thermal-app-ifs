import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thermal_mobile/core/constants/colors.dart';
import 'package:thermal_mobile/presentation/models/filter_params.dart';

/// Callback để load danh sách thiết bị theo areaId
typedef MachineItemsLoader =
    Future<List<DropdownMenuItem<int>>> Function(int? areaId);

/// Dialog filter cho tab Nhiệt độ vượt ngưỡng
class TemperatureFilterDialog extends StatefulWidget {
  final TemperatureFilterParams initialParams;
  final List<DropdownMenuItem<int>> areaItems;
  final List<DropdownMenuItem<int>> machineItems;
  final MachineItemsLoader? onAreaChanged;

  const TemperatureFilterDialog({
    super.key,
    required this.initialParams,
    required this.areaItems,
    required this.machineItems,
    this.onAreaChanged,
  });

  /// Show as bottom sheet
  static Future<TemperatureFilterParams?> show({
    required BuildContext context,
    required TemperatureFilterParams initialParams,
    required List<DropdownMenuItem<int>> areaItems,
    required List<DropdownMenuItem<int>> machineItems,
    MachineItemsLoader? onAreaChanged,
  }) {
    return showModalBottomSheet<TemperatureFilterParams>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TemperatureFilterDialog(
        initialParams: initialParams,
        areaItems: areaItems,
        machineItems: machineItems,
        onAreaChanged: onAreaChanged,
      ),
    );
  }

  @override
  State<TemperatureFilterDialog> createState() =>
      _TemperatureFilterDialogState();
}

class _TemperatureFilterDialogState extends State<TemperatureFilterDialog> {
  late DateTime fromTime;
  late DateTime toTime;
  int? areaId;
  int? machineId;
  int? notificationStatus;
  List<DropdownMenuItem<int>> _currentMachineItems = [];
  bool _isLoadingMachines = false;

  @override
  void initState() {
    super.initState();
    fromTime =
        widget.initialParams.fromTime ??
        DateTime.now().subtract(const Duration(days: 7));
    toTime = widget.initialParams.toTime ?? DateTime.now();
    areaId = widget.initialParams.areaId;
    machineId = widget.initialParams.machineId;
    notificationStatus = widget.initialParams.notificationStatus;
    _currentMachineItems = widget.machineItems;
  }

  Future<void> _onAreaChanged(int? newAreaId) async {
    setState(() {
      areaId = newAreaId;
      machineId = null;
      _currentMachineItems = [];
      _isLoadingMachines = true;
    });

    if (widget.onAreaChanged != null) {
      try {
        final newMachineItems = await widget.onAreaChanged!(newAreaId);
        if (mounted) {
          setState(() {
            _currentMachineItems = newMachineItems;
            _isLoadingMachines = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingMachines = false;
          });
        }
      }
    } else {
      setState(() {
        _isLoadingMachines = false;
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

  void _onReset() {
    setState(() {
      fromTime = DateTime.now().subtract(const Duration(days: 7));
      toTime = DateTime.now();
      areaId = null;
      machineId = null;
      notificationStatus = null;
      _currentMachineItems = [];
    });
  }

  void _onApply() {
    Navigator.of(context).pop(
      TemperatureFilterParams(
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
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.menuBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: AppColors.primaryDark),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Lọc Nhiệt độ vượt ngưỡng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,                        color: Colors.white,                      ),
                    ),
                  ),
                  TextButton(onPressed: _onReset, child: const Text('Đặt lại')),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade700),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Range
                    const Text(
                      'Khoảng thời gian',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _DatePickerField(
                            label: 'Từ ngày',
                            value: dateFormat.format(fromTime),
                            onTap: () => _pickDate(isFrom: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DatePickerField(
                            label: 'Đến ngày',
                            value: dateFormat.format(toTime),
                            onTap: () => _pickDate(isFrom: false),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Area
                    const Text(
                      'Khu vực',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _DropdownField<int>(
                      value: areaId,
                      hint: 'Chọn khu vực',
                      items: widget.areaItems,
                      onChanged: _onAreaChanged,
                    ),

                    // Machine
                    if (areaId != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Thiết bị',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_isLoadingMachines)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        _DropdownField<int>(
                          value: machineId,
                          hint: 'Chọn thiết bị',
                          items: _currentMachineItems,
                          onChanged: (v) => setState(() => machineId = v),
                        ),
                    ],

                    const SizedBox(height: 20),

                    // Status
                    const Text(
                      'Trạng thái',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _StatusChip(
                          label: 'Tất cả',
                          isSelected: notificationStatus == null,
                          onTap: () =>
                              setState(() => notificationStatus = null),
                        ),
                        _StatusChip(
                          label: 'Chưa xử lý',
                          color: Colors.orange,
                          isSelected: notificationStatus == 1,
                          onTap: () => setState(() => notificationStatus = 1),
                        ),
                        _StatusChip(
                          label: 'Đã xử lý',
                          color: Colors.green,
                          isSelected: notificationStatus == 2,
                          onTap: () => setState(() => notificationStatus = 2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade700)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Áp dụng'),
                    ),
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

// Date picker field widget
class _DatePickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          border: Border.all(color: Colors.grey.shade700),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                  Text(value, style: const TextStyle(fontSize: 14, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dropdown field widget
class _DropdownField<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border.all(color: Colors.grey.shade700),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade400)),
          isExpanded: true,
          dropdownColor: AppColors.menuBackground,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          iconEnabledColor: Colors.grey.shade400,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// Status chip widget
class _StatusChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.primaryDark).withOpacity(0.25)
              : AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? AppColors.primaryDark)
                : Colors.grey.shade700,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected
                    ? (color ?? AppColors.primaryDark)
                    : Colors.grey.shade300,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
