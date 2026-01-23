import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermal_mobile/core/constants/colors.dart';
import 'package:thermal_mobile/domain/models/area_tree.dart';
import 'package:thermal_mobile/di/injection.dart';
import 'package:thermal_mobile/data/local/storage/config_storage.dart';
import 'package:thermal_mobile/presentation/bloc/area/area_bloc.dart';

/// A compact area selector that shows only areas that are leaf nodes and contain cameras.
///
/// UI: a rounded card with a location icon, area name and small subtitle. Tapping opens
/// a modal list to choose a different area.
class AreaDropdown extends StatefulWidget {
  final AreaTree? initialArea;
  final ValueChanged<AreaTree?>? onChanged;

  const AreaDropdown({super.key, this.initialArea, this.onChanged});

  @override
  State<AreaDropdown> createState() => _AreaDropdownState();
}

class _AreaDropdownState extends State<AreaDropdown> {
  AreaTree? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialArea;
    // Trigger area load
    try {
      getIt<AreaBloc>().add(const FetchAreaTreeEvent());
    } catch (_) {}
  }

  List<AreaTree> _collectLeafAreas(List<AreaTree> areas) {
    final result = <AreaTree>[];
    void visit(AreaTree node) {
      if (node.children.isEmpty) {
        if (node.cameras.isNotEmpty) result.add(node);
        return;
      }
      for (var c in node.children) visit(c);
    }

    for (var a in areas) visit(a);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AreaBloc, AreaState>(
      bloc: getIt<AreaBloc>(),
      builder: (context, state) {
        if (state is AreaLoading) {
          return const SizedBox(
            height: 52,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (state is AreaTreeLoaded) {
          final leafAreas = _collectLeafAreas(state.areas);
          if (leafAreas.isEmpty) return const SizedBox.shrink();

          // Try to restore previously selected area from storage if not set
          if (_selected == null) {
            final savedId = getIt<ConfigStorage>().getSelectedAreaId();
            debugPrint('AreaDropdown: restoring selectedAreaId=$savedId');
            if (savedId != null) {
              final found = leafAreas.firstWhere(
                (a) => a.id == savedId,
                orElse: () => leafAreas.first,
              );
              _selected = found;
            } else {
              _selected = leafAreas.first;
            }
          }

          return GestureDetector(
            onTap: () => _showAreaPicker(context, leafAreas),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    _selected?.name ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.expand_more, color: Colors.white),
              ],
            ),
          );
        }

        if (state is AreaError) {
          return const SizedBox.shrink();
        }

        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _showAreaPicker(
    BuildContext context,
    List<AreaTree> areas,
  ) async {
    final selected = await showModalBottomSheet<AreaTree>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A2332),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                Container(
                  height: 56,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFF3B82F6),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Chọn khu vực',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade700),
                SizedBox(
                  height: 360,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final a = areas[index];
                      final isSelected = _selected?.id == a.id;
                      return InkWell(
                        onTap: () => Navigator.of(context).pop(a),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF3B82F6).withOpacity(0.15)
                                : Colors.transparent,
                            border: Border(
                              left: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF3B82F6)
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF3B82F6).withOpacity(0.2)
                                      : const Color(0xFF2D3748),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: isSelected
                                      ? const Color(0xFF3B82F6)
                                      : Colors.grey.shade400,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? const Color(0xFF3B82F6)
                                            : Colors.white,
                                      ),
                                    ),
                                    if (a.levelName != null) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        a.levelName!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF3B82F6),
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: areas.length,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selected = selected;
      });
      // Persist selection
      try {
        getIt<ConfigStorage>().saveSelectedArea(id: selected.id, name: selected.name);
        debugPrint('AreaDropdown: saved selectedArea id=${selected.id}, name=${selected.name}');
      } catch (e) {
        debugPrint('AreaDropdown: failed to save selection: $e');
      }
      widget.onChanged?.call(_selected);
    }
  }
}
