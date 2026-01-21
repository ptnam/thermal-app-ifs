import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thermal_mobile/presentation/models/filter_params.dart';

/// Dialog filter cho tab Cảnh báo AI
class AIWarningFilterDialog extends StatefulWidget {
  final AIWarningFilterParams initialParams;
  final List<DropdownMenuItem<int>> areaItems;
  final List<DropdownMenuItem<int>> cameraItems;
  final List<DropdownMenuItem<int>> warningEventItems;

  const AIWarningFilterDialog({
    Key? key,
    required this.initialParams,
    required this.areaItems,
    required this.cameraItems,
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
    return AlertDialog(
      title: const Text('Lọc Cảnh báo AI'),
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
              value: cameraId,
              items: widget.cameraItems,
              onChanged: (v) => setState(() => cameraId = v),
              decoration: const InputDecoration(labelText: 'Camera'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: warningEventId,
              items: widget.warningEventItems,
              onChanged: (v) => setState(() => warningEventId = v),
              decoration: const InputDecoration(labelText: 'Loại cảnh báo'),
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
