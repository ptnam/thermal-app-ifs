import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thermal_mobile/presentation/models/filter_params.dart';

/// Dialog filter cho tab Nhiệt độ vượt ngưỡng
class TemperatureFilterDialog extends StatefulWidget {
  final TemperatureFilterParams initialParams;
  final List<DropdownMenuItem<int>> areaItems;
  final List<DropdownMenuItem<int>> machineItems;

  const TemperatureFilterDialog({
    Key? key,
    required this.initialParams,
    required this.areaItems,
    required this.machineItems,
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

  @override
  void initState() {
    super.initState();
    fromTime = widget.initialParams.fromTime ?? DateTime.now().subtract(const Duration(days: 7));
    toTime = widget.initialParams.toTime ?? DateTime.now();
    areaId = widget.initialParams.areaId;
    machineId = widget.initialParams.machineId;
    notificationStatus = widget.initialParams.notificationStatus;
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
    return AlertDialog(
      title: const Text('Lọc Nhiệt độ vượt ngưỡng'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(isFrom: true),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Từ ngày'),
                      child: Text(dateFormat.format(fromTime)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(isFrom: false),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Đến ngày'),
                      child: Text(dateFormat.format(toTime)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: areaId,
              items: widget.areaItems,
              onChanged: (v) => setState(() => areaId = v),
              decoration: const InputDecoration(labelText: 'Khu vực'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: machineId,
              items: widget.machineItems,
              onChanged: (v) => setState(() => machineId = v),
              decoration: const InputDecoration(labelText: 'Thiết bị'),
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Trạng thái'),
              child: Row(
                children: [
                  Expanded(
                    child: RadioListTile<int>(
                      value: 1,
                      groupValue: notificationStatus,
                      onChanged: (v) => setState(() => notificationStatus = v),
                      title: const Text('Chưa xử lý'),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<int>(
                      value: 2,
                      groupValue: notificationStatus,
                      onChanged: (v) => setState(() => notificationStatus = v),
                      title: const Text('Đã xử lý'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _onApply,
          child: const Text('Áp dụng'),
        ),
      ],
    );
  }
}
