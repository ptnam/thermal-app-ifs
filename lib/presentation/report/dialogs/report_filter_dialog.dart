import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thermal_mobile/core/constants/colors.dart';
import 'package:thermal_mobile/presentation/models/filter_params.dart';

/// Callback để load danh sách thiết bị theo areaId
typedef MachineItemsLoader =
    Future<List<DropdownMenuItem<int>>> Function(int? areaId);

/// Callback để load danh sách bộ phận theo danh sách machineIds
typedef ComponentItemsLoader =
    Future<List<DropdownMenuItem<int>>> Function(List<int> machineIds);

/// Dialog filter cho màn Báo cáo (khu vực, thiết bị, bộ phận, khoảng thời gian)
class ReportFilterDialog extends StatefulWidget {
  final ReportFilterParams initialParams;
  final List<DropdownMenuItem<int>> areaItems;
  final List<DropdownMenuItem<int>> machineItems;
  final List<DropdownMenuItem<int>> componentItems;
  final MachineItemsLoader? onAreaChanged;
  final ComponentItemsLoader? onMachineChanged;

  const ReportFilterDialog({
    super.key,
    required this.initialParams,
    required this.areaItems,
    required this.machineItems,
    this.componentItems = const [],
    this.onAreaChanged,
    this.onMachineChanged,
  });

  /// Show as bottom sheet
  static Future<ReportFilterParams?> show({
    required BuildContext context,
    required ReportFilterParams initialParams,
    required List<DropdownMenuItem<int>> areaItems,
    required List<DropdownMenuItem<int>> machineItems,
    List<DropdownMenuItem<int>> componentItems = const [],
    MachineItemsLoader? onAreaChanged,
    ComponentItemsLoader? onMachineChanged,
  }) {
    return showModalBottomSheet<ReportFilterParams>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportFilterDialog(
        initialParams: initialParams,
        areaItems: areaItems,
        machineItems: machineItems,
        componentItems: componentItems,
        onAreaChanged: onAreaChanged,
        onMachineChanged: onMachineChanged,
      ),
    );
  }

  @override
  State<ReportFilterDialog> createState() => _ReportFilterDialogState();
}

class _ReportFilterDialogState extends State<ReportFilterDialog> {
  late DateTime fromTime;
  late DateTime toTime;
  int? areaId;
  Set<int> _selectedMachineIds = {};
  List<DropdownMenuItem<int>> _currentMachineItems = [];
  bool _isLoadingMachines = false;
  List<DropdownMenuItem<int>> _currentComponentItems = [];
  bool _isLoadingComponents = false;
  Set<int> _selectedComponentIds = {};

  @override
  void initState() {
    super.initState();
    fromTime =
        widget.initialParams.fromTime ??
        DateTime.now().subtract(const Duration(days: 2));
    toTime = widget.initialParams.toTime ?? DateTime.now();
    areaId = widget.initialParams.areaId;
    _selectedMachineIds = (widget.initialParams.machineIds ?? []).toSet();
    _currentMachineItems = widget.machineItems;
    _currentComponentItems = widget.componentItems;
    _selectedComponentIds = (widget.initialParams.machineComponentIds ?? [])
        .toSet();
  }

  Future<void> _onAreaChanged(int? newAreaId) async {
    setState(() {
      areaId = newAreaId;
      _selectedMachineIds = {};
      _currentMachineItems = [];
      _isLoadingMachines = true;
      _currentComponentItems = [];
      _selectedComponentIds = {};
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

  Future<void> _toggleMachine(int machineId) async {
    setState(() {
      if (_selectedMachineIds.contains(machineId)) {
        _selectedMachineIds.remove(machineId);
      } else {
        _selectedMachineIds.add(machineId);
      }
      _currentComponentItems = [];
      _selectedComponentIds = {};
      _isLoadingComponents = true;
    });

    if (widget.onMachineChanged != null) {
      try {
        final newComponentItems = await widget.onMachineChanged!(
          _selectedMachineIds.toList(),
        );
        if (mounted) {
          setState(() {
            _currentComponentItems = newComponentItems;
            _isLoadingComponents = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingComponents = false;
          });
        }
      }
    } else {
      setState(() {
        _isLoadingComponents = false;
      });
    }
  }

  void _toggleComponent(int componentId) {
    setState(() {
      if (_selectedComponentIds.contains(componentId)) {
        _selectedComponentIds.remove(componentId);
      } else {
        _selectedComponentIds.add(componentId);
      }
    });
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
      fromTime = DateTime.now().subtract(const Duration(days: 2));
      toTime = DateTime.now();
      areaId = null;
      _selectedMachineIds = {};
      _currentMachineItems = [];
      _currentComponentItems = [];
      _selectedComponentIds = {};
    });
  }

  void _onApply() {
    String? areaName;
    for (final item in widget.areaItems) {
      if (item.value == areaId) {
        areaName = (item.child as Text).data;
        break;
      }
    }

    final machineNames = <String>[];
    for (final item in _currentMachineItems) {
      if (_selectedMachineIds.contains(item.value)) {
        machineNames.add((item.child as Text).data ?? '');
      }
    }

    final componentNames = <String>[];
    for (final item in _currentComponentItems) {
      if (_selectedComponentIds.contains(item.value)) {
        componentNames.add((item.child as Text).data ?? '');
      }
    }

    Navigator.of(context).pop(
      ReportFilterParams(
        fromTime: fromTime,
        toTime: toTime,
        areaId: areaId,
        areaName: areaName,
        machineIds: _selectedMachineIds.isEmpty
            ? null
            : _selectedMachineIds.toList(),
        machineNames: machineNames.isEmpty ? null : machineNames,
        machineComponentIds: _selectedComponentIds.isEmpty
            ? null
            : _selectedComponentIds.toList(),
        machineComponentNames: componentNames.isEmpty ? null : componentNames,
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
                      'Lọc báo cáo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _onReset,
                    child: const Text(
                      'Đặt lại',
                      style: TextStyle(color: AppColors.primaryDark),
                    ),
                  ),
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
                    else if (_currentMachineItems.isEmpty)
                      Text(
                        'Chọn khu vực để xem danh sách thiết bị',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _currentMachineItems.map((item) {
                          final label = (item.child as Text).data ?? '';
                          return _ComponentChip(
                            label: label,
                            isSelected: _selectedMachineIds.contains(
                              item.value,
                            ),
                            onTap: () => _toggleMachine(item.value as int),
                          );
                        }).toList(),
                      ),

                    // Component (bộ phận)
                    const SizedBox(height: 16),
                    const Text(
                      'Bộ phận',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoadingComponents)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_selectedMachineIds.isEmpty)
                      Text(
                        'Chọn thiết bị để xem danh sách bộ phận',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      )
                    else if (_currentComponentItems.isEmpty)
                      Text(
                        'Thiết bị này không có bộ phận',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _currentComponentItems.map((item) {
                          final label = (item.child as Text).data ?? '';
                          return _ComponentChip(
                            label: label,
                            isSelected: _selectedComponentIds.contains(
                              item.value,
                            ),
                            onTap: () => _toggleComponent(item.value as int),
                          );
                        }).toList(),
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

// Multi-select chip for machine components
class _ComponentChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ComponentChip({
    required this.label,
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
              ? AppColors.primaryDark.withOpacity(0.25)
              : AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryDark : Colors.grey.shade700,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(
                Icons.check_circle,
                size: 14,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? AppColors.primaryDark : Colors.grey.shade300,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
                  Text(
                    value,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
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
