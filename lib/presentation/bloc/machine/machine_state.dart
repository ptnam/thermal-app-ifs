/// =============================================================================
/// File: machine_state.dart
/// Description: Machine BLoC states
/// 
/// Purpose:
/// - Define all possible states for MachineBloc
/// - Supports Machine, MachineType, MachinePart states
/// =============================================================================

import 'package:equatable/equatable.dart';
import 'package:thermal_mobile/domain/models/machine_entity.dart';

/// Status of async operations
enum MachineStatus {
  initial,
  loading,
  success,
  failure,
}

/// State class for Machine BLoC
class MachineState extends Equatable {
  // ─────────────────────────────────────────────────────────────────────────
  // Status Flags
  // ─────────────────────────────────────────────────────────────────────────

  /// Machine list status
  final MachineStatus listStatus;

  /// Machine detail status
  final MachineStatus detailStatus;

  /// Machine operation status (CRUD)
  final MachineStatus operationStatus;

  /// Machine type list status
  final MachineStatus typeListStatus;

  /// Machine part tree status
  final MachineStatus partTreeStatus;

  /// Component list status
  final MachineStatus componentStatus;

  // ─────────────────────────────────────────────────────────────────────────
  // Machine Data
  // ─────────────────────────────────────────────────────────────────────────

  /// List of machines
  final List<MachineEntity> machines;

  /// Selected machine for detail view
  final MachineEntity? selectedMachine;

  /// Machine components
  final List<MachineComponentEntity> components;

  // ─────────────────────────────────────────────────────────────────────────
  // Machine Type Data
  // ─────────────────────────────────────────────────────────────────────────

  /// List of machine types
  final List<MachineTypeEntity> machineTypes;

  // ─────────────────────────────────────────────────────────────────────────
  // Machine Part Data
  // ─────────────────────────────────────────────────────────────────────────

  /// Machine part tree
  final List<MachinePartEntity> machinePartTree;

  // ─────────────────────────────────────────────────────────────────────────
  // Pagination
  // ─────────────────────────────────────────────────────────────────────────

  final int currentPage;
  final int pageSize;
  final int totalRecords;
  final int totalPages;
  final bool hasMore;

  // ─────────────────────────────────────────────────────────────────────────
  // Filters
  // ─────────────────────────────────────────────────────────────────────────

  final String? filterName;
  final int? filterAreaId;
  final int? filterMachineTypeId;
  final int? filterStatus;

  // ─────────────────────────────────────────────────────────────────────────
  // Messages
  // ─────────────────────────────────────────────────────────────────────────

  final String? errorMessage;
  final String? successMessage;

  const MachineState({
    this.listStatus = MachineStatus.initial,
    this.detailStatus = MachineStatus.initial,
    this.operationStatus = MachineStatus.initial,
    this.typeListStatus = MachineStatus.initial,
    this.partTreeStatus = MachineStatus.initial,
    this.componentStatus = MachineStatus.initial,
    this.machines = const [],
    this.selectedMachine,
    this.components = const [],
    this.machineTypes = const [],
    this.machinePartTree = const [],
    this.currentPage = 1,
    this.pageSize = 10,
    this.totalRecords = 0,
    this.totalPages = 0,
    this.hasMore = false,
    this.filterName,
    this.filterAreaId,
    this.filterMachineTypeId,
    this.filterStatus,
    this.errorMessage,
    this.successMessage,
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Computed Properties
  // ─────────────────────────────────────────────────────────────────────────

  bool get isLoading =>
      listStatus == MachineStatus.loading ||
      detailStatus == MachineStatus.loading ||
      operationStatus == MachineStatus.loading;

  bool get isEmpty => machines.isEmpty && listStatus == MachineStatus.success;
  bool get hasError => errorMessage != null;
  bool get hasSelectedMachine => selectedMachine != null;

  MachineState copyWith({
    MachineStatus? listStatus,
    MachineStatus? detailStatus,
    MachineStatus? operationStatus,
    MachineStatus? typeListStatus,
    MachineStatus? partTreeStatus,
    MachineStatus? componentStatus,
    List<MachineEntity>? machines,
    MachineEntity? selectedMachine,
    List<MachineComponentEntity>? components,
    List<MachineTypeEntity>? machineTypes,
    List<MachinePartEntity>? machinePartTree,
    int? currentPage,
    int? pageSize,
    int? totalRecords,
    int? totalPages,
    bool? hasMore,
    String? filterName,
    int? filterAreaId,
    int? filterMachineTypeId,
    int? filterStatus,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelectedMachine = false,
  }) {
    return MachineState(
      listStatus: listStatus ?? this.listStatus,
      detailStatus: detailStatus ?? this.detailStatus,
      operationStatus: operationStatus ?? this.operationStatus,
      typeListStatus: typeListStatus ?? this.typeListStatus,
      partTreeStatus: partTreeStatus ?? this.partTreeStatus,
      componentStatus: componentStatus ?? this.componentStatus,
      machines: machines ?? this.machines,
      selectedMachine: clearSelectedMachine ? null : (selectedMachine ?? this.selectedMachine),
      components: components ?? this.components,
      machineTypes: machineTypes ?? this.machineTypes,
      machinePartTree: machinePartTree ?? this.machinePartTree,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalRecords: totalRecords ?? this.totalRecords,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      filterName: filterName ?? this.filterName,
      filterAreaId: filterAreaId ?? this.filterAreaId,
      filterMachineTypeId: filterMachineTypeId ?? this.filterMachineTypeId,
      filterStatus: filterStatus ?? this.filterStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        listStatus,
        detailStatus,
        operationStatus,
        typeListStatus,
        partTreeStatus,
        componentStatus,
        machines,
        selectedMachine,
        components,
        machineTypes,
        machinePartTree,
        currentPage,
        pageSize,
        totalRecords,
        totalPages,
        hasMore,
        filterName,
        filterAreaId,
        filterMachineTypeId,
        filterStatus,
        errorMessage,
        successMessage,
      ];
}
