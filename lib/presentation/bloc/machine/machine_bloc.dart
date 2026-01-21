/// =============================================================================
/// File: machine_bloc.dart
/// Description: Machine BLoC for machine management
/// 
/// Purpose:
/// - Handle machine, machine type, machine part operations
/// - Support CRUD, pagination, filtering
/// =============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/machine_repository.dart';
import '../../../core/logger/app_logger.dart';
import 'machine_event.dart';
import 'machine_state.dart';

/// BLoC for managing Machine operations
/// 
/// Handles:
/// - Machine CRUD with pagination
/// - Machine Type management
/// - Machine Part tree management
/// - Machine Component loading
class MachineBloc extends Bloc<MachineEvent, MachineState> {
  MachineBloc({
    required IMachineRepository machineRepository,
    AppLogger? logger,
  })  : _machineRepository = machineRepository,
        _logger = logger ?? AppLogger(tag: 'MachineBloc'),
        super(const MachineState()) {
    // Machine handlers
    on<LoadAllMachinesEvent>(_onLoadAllMachines);
    on<LoadMachineListEvent>(_onLoadMachineList);
    on<LoadMoreMachinesEvent>(_onLoadMoreMachines);
    on<LoadMachineByIdEvent>(_onLoadMachineById);
    on<CreateMachineEvent>(_onCreateMachine);
    on<UpdateMachineEvent>(_onUpdateMachine);
    on<DeleteMachineEvent>(_onDeleteMachine);
    on<LoadMachineComponentsEvent>(_onLoadMachineComponents);

    // Machine Type handlers
    on<LoadAllMachineTypesEvent>(_onLoadAllMachineTypes);
    on<LoadMachineTypeListEvent>(_onLoadMachineTypeList);
    on<CreateMachineTypeEvent>(_onCreateMachineType);
    on<UpdateMachineTypeEvent>(_onUpdateMachineType);
    on<DeleteMachineTypeEvent>(_onDeleteMachineType);

    // Machine Part handlers
    on<LoadMachinePartTreeEvent>(_onLoadMachinePartTree);
    on<CreateMachinePartEvent>(_onCreateMachinePart);
    on<UpdateMachinePartEvent>(_onUpdateMachinePart);
    on<DeleteMachinePartEvent>(_onDeleteMachinePart);

    // Common handlers
    on<ClearSelectedMachineEvent>(_onClearSelectedMachine);
    on<RefreshMachineListEvent>(_onRefreshMachineList);
  }

  final IMachineRepository _machineRepository;
  final AppLogger _logger;

  // ─────────────────────────────────────────────────────────────────────────
  // Machine Handlers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onLoadAllMachines(
    LoadAllMachinesEvent event,
    Emitter<MachineState> emit,
  ) async {
    _logger.info('Loading all machines');
    emit(state.copyWith(listStatus: MachineStatus.loading, clearError: true));

    final result = await _machineRepository.getAllMachines(
      areaId: event.areaId,
      machineTypeId: event.machineTypeId,
      status: event.status,
    );

    result.fold(
      (error) {
        _logger.error('Failed to load machines: ${error.message}');
        emit(state.copyWith(
          listStatus: MachineStatus.failure,
          errorMessage: error.message,
        ));
      },
      (machines) {
        _logger.info('Loaded ${machines.length} machines');
        emit(state.copyWith(
          listStatus: MachineStatus.success,
          machines: machines,
        ));
      },
    );
  }

  Future<void> _onLoadMachineList(
    LoadMachineListEvent event,
    Emitter<MachineState> emit,
  ) async {
    _logger.info('Loading machine list: page=${event.page}');
    emit(state.copyWith(
      listStatus: MachineStatus.loading,
      filterName: event.name,
      filterAreaId: event.areaId,
      filterMachineTypeId: event.machineTypeId,
      filterStatus: event.status,
      clearError: true,
    ));

    final result = await _machineRepository.getMachineList(
      page: event.page,
      pageSize: event.pageSize,
      name: event.name,
      areaId: event.areaId,
      machineTypeId: event.machineTypeId,
      status: event.status,
    );

    result.fold(
      (error) {
        _logger.error('Failed to load machine list: ${error.message}');
        emit(state.copyWith(
          listStatus: MachineStatus.failure,
          errorMessage: error.message,
        ));
      },
      (response) {
        _logger.info('Loaded ${response.data.length} machines');
        emit(state.copyWith(
          listStatus: MachineStatus.success,
          machines: response.data,
          currentPage: response.currentPage,
          pageSize: response.pageSize,
          totalRecords: response.totalRecords,
          totalPages: response.totalPages,
          hasMore: response.currentPage < response.totalPages,
        ));
      },
    );
  }

  Future<void> _onLoadMoreMachines(
    LoadMoreMachinesEvent event,
    Emitter<MachineState> emit,
  ) async {
    if (!state.hasMore || state.listStatus == MachineStatus.loading) return;

    final nextPage = state.currentPage + 1;
    _logger.info('Loading more machines: page=$nextPage');

    final result = await _machineRepository.getMachineList(
      page: nextPage,
      pageSize: state.pageSize,
      name: state.filterName,
      areaId: state.filterAreaId,
      machineTypeId: state.filterMachineTypeId,
      status: state.filterStatus,
    );

    result.fold(
      (error) => emit(state.copyWith(errorMessage: error.message)),
      (response) {
        emit(state.copyWith(
          machines: [...state.machines, ...response.data],
          currentPage: response.currentPage,
          hasMore: response.currentPage < response.totalPages,
        ));
      },
    );
  }

  Future<void> _onLoadMachineById(
    LoadMachineByIdEvent event,
    Emitter<MachineState> emit,
  ) async {
    _logger.info('Loading machine: id=${event.machineId}');
    emit(state.copyWith(detailStatus: MachineStatus.loading, clearError: true));

    final result = await _machineRepository.getMachineById(event.machineId);

    result.fold(
      (error) {
        _logger.error('Failed to load machine: ${error.message}');
        emit(state.copyWith(
          detailStatus: MachineStatus.failure,
          errorMessage: error.message,
        ));
      },
      (machine) {
        _logger.info('Machine loaded: ${machine.name}');
        emit(state.copyWith(
          detailStatus: MachineStatus.success,
          selectedMachine: machine,
        ));
      },
    );
  }

  Future<void> _onCreateMachine(
    CreateMachineEvent event,
    Emitter<MachineState> emit,
  ) async {
    _logger.info('Creating machine: ${event.machine.name}');
    emit(state.copyWith(operationStatus: MachineStatus.loading, clearError: true));

    final result = await _machineRepository.createMachine(event.machine);

    result.fold(
      (error) {
        _logger.error('Failed to create machine: ${error.message}');
        emit(state.copyWith(
          operationStatus: MachineStatus.failure,
          errorMessage: error.message,
        ));
      },
      (machine) {
        _logger.info('Machine created: ${machine.name}');
        emit(state.copyWith(
          operationStatus: MachineStatus.success,
          machines: [machine, ...state.machines],
          successMessage: 'Machine created successfully',
        ));
      },
    );
  }

  Future<void> _onUpdateMachine(
    UpdateMachineEvent event,
    Emitter<MachineState> emit,
  ) async {
    _logger.info('Updating machine: id=${event.machineId}');
    emit(state.copyWith(operationStatus: MachineStatus.loading, clearError: true));

    final result = await _machineRepository.updateMachine(
      event.machineId,
      event.machine,
    );

    result.fold(
      (error) {
        _logger.error('Failed to update machine: ${error.message}');
        emit(state.copyWith(
          operationStatus: MachineStatus.failure,
          errorMessage: error.message,
        ));
      },
      (machine) {
        _logger.info('Machine updated: ${machine.name}');
        final updatedMachines = state.machines.map((m) {
          return m.id == event.machineId ? machine : m;
        }).toList();

        emit(state.copyWith(
          operationStatus: MachineStatus.success,
          machines: updatedMachines,
          selectedMachine: machine,
          successMessage: 'Machine updated successfully',
        ));
      },
    );
  }

  Future<void> _onDeleteMachine(
    DeleteMachineEvent event,
    Emitter<MachineState> emit,
  ) async {
    _logger.info('Deleting machine: id=${event.machineId}');
    emit(state.copyWith(operationStatus: MachineStatus.loading, clearError: true));

    final result = await _machineRepository.deleteMachine(event.machineId);

    result.fold(
      (error) {
        _logger.error('Failed to delete machine: ${error.message}');
        emit(state.copyWith(
          operationStatus: MachineStatus.failure,
          errorMessage: error.message,
        ));
      },
      (_) {
        _logger.info('Machine deleted');
        final updatedMachines = state.machines
            .where((m) => m.id != event.machineId)
            .toList();

        emit(state.copyWith(
          operationStatus: MachineStatus.success,
          machines: updatedMachines,
          clearSelectedMachine: true,
          successMessage: 'Machine deleted successfully',
        ));
      },
    );
  }

  Future<void> _onLoadMachineComponents(
    LoadMachineComponentsEvent event,
    Emitter<MachineState> emit,
  ) async {
    _logger.info('Loading components for machine: ${event.machineId}');
    emit(state.copyWith(componentStatus: MachineStatus.loading));

    final result = await _machineRepository.getMachineComponents(event.machineId);

    result.fold(
      (error) {
        _logger.error('Failed to load components: ${error.message}');
        emit(state.copyWith(
          componentStatus: MachineStatus.failure,
          errorMessage: error.message,
        ));
      },
      (components) {
        _logger.info('Loaded ${components.length} components');
        emit(state.copyWith(
          componentStatus: MachineStatus.success,
          components: components,
        ));
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Machine Type Handlers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onLoadAllMachineTypes(
    LoadAllMachineTypesEvent event,
    Emitter<MachineState> emit,
  ) async {
    _logger.info('Loading all machine types');
    emit(state.copyWith(typeListStatus: MachineStatus.loading));

    final result = await _machineRepository.getAllMachineTypes(status: event.status);

    result.fold(
      (error) {
        _logger.error('Failed to load machine types: ${error.message}');
        emit(state.copyWith(
          typeListStatus: MachineStatus.failure,
          errorMessage: error.message,
        ));
      },
      (types) {
        _logger.info('Loaded ${types.length} machine types');
        emit(state.copyWith(
          typeListStatus: MachineStatus.success,
          machineTypes: types,
        ));
      },
    );
  }

  Future<void> _onLoadMachineTypeList(
    LoadMachineTypeListEvent event,
    Emitter<MachineState> emit,
  ) async {
    _logger.info('Loading machine type list: page=${event.page}');
    emit(state.copyWith(typeListStatus: MachineStatus.loading));

    final result = await _machineRepository.getMachineTypeList(
      page: event.page,
      pageSize: event.pageSize,
      name: event.name,
      status: event.status,
    );

    result.fold(
      (error) {
        emit(state.copyWith(
          typeListStatus: MachineStatus.failure,
          errorMessage: error.message,
        ));
      },
      (response) {
        emit(state.copyWith(
          typeListStatus: MachineStatus.success,
          machineTypes: response.data,
        ));
      },
    );
  }

  Future<void> _onCreateMachineType(
    CreateMachineTypeEvent event,
    Emitter<MachineState> emit,
  ) async {
    _logger.info('Creating machine type: ${event.machineType.name}');
    emit(state.copyWith(operationStatus: MachineStatus.loading, clearError: true));

    final result = await _machineRepository.createMachineType(event.machineType);

    result.fold(
      (error) => emit(state.copyWith(
        operationStatus: MachineStatus.failure,
        errorMessage: error.message,
      )),
      (type) => emit(state.copyWith(
        operationStatus: MachineStatus.success,
        machineTypes: [type, ...state.machineTypes],
        successMessage: 'Machine type created successfully',
      )),
    );
  }

  Future<void> _onUpdateMachineType(
    UpdateMachineTypeEvent event,
    Emitter<MachineState> emit,
  ) async {
    _logger.info('Updating machine type: id=${event.machineTypeId}');
    emit(state.copyWith(operationStatus: MachineStatus.loading, clearError: true));

    final result = await _machineRepository.updateMachineType(
      event.machineTypeId,
      event.machineType,
    );

    result.fold(
      (error) => emit(state.copyWith(
        operationStatus: MachineStatus.failure,
        errorMessage: error.message,
      )),
      (type) {
        final updatedTypes = state.machineTypes.map((t) {
          return t.id == event.machineTypeId ? type : t;
        }).toList();

        emit(state.copyWith(
          operationStatus: MachineStatus.success,
          machineTypes: updatedTypes,
          successMessage: 'Machine type updated successfully',
        ));
      },
    );
  }

  Future<void> _onDeleteMachineType(
    DeleteMachineTypeEvent event,
    Emitter<MachineState> emit,
  ) async {
    _logger.info('Deleting machine type: id=${event.machineTypeId}');
    emit(state.copyWith(operationStatus: MachineStatus.loading, clearError: true));

    final result = await _machineRepository.deleteMachineType(event.machineTypeId);

    result.fold(
      (error) => emit(state.copyWith(
        operationStatus: MachineStatus.failure,
        errorMessage: error.message,
      )),
      (_) {
        final updatedTypes = state.machineTypes
            .where((t) => t.id != event.machineTypeId)
            .toList();

        emit(state.copyWith(
          operationStatus: MachineStatus.success,
          machineTypes: updatedTypes,
          successMessage: 'Machine type deleted successfully',
        ));
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Machine Part Handlers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onLoadMachinePartTree(
    LoadMachinePartTreeEvent event,
    Emitter<MachineState> emit,
  ) async {
    _logger.info('Loading machine part tree');
    emit(state.copyWith(partTreeStatus: MachineStatus.loading));

    final result = await _machineRepository.getMachinePartTree();

    result.fold(
      (error) {
        _logger.error('Failed to load machine parts: ${error.message}');
        emit(state.copyWith(
          partTreeStatus: MachineStatus.failure,
          errorMessage: error.message,
        ));
      },
      (parts) {
        _logger.info('Loaded ${parts.length} root machine parts');
        emit(state.copyWith(
          partTreeStatus: MachineStatus.success,
          machinePartTree: parts,
        ));
      },
    );
  }

  Future<void> _onCreateMachinePart(
    CreateMachinePartEvent event,
    Emitter<MachineState> emit,
  ) async {
    _logger.info('Creating machine part: ${event.machinePart.name}');
    emit(state.copyWith(operationStatus: MachineStatus.loading, clearError: true));

    final result = await _machineRepository.createMachinePart(event.machinePart);

    result.fold(
      (error) => emit(state.copyWith(
        operationStatus: MachineStatus.failure,
        errorMessage: error.message,
      )),
      (part) {
        emit(state.copyWith(
          operationStatus: MachineStatus.success,
          successMessage: 'Machine part created successfully',
        ));
        // Reload tree to get updated structure
        add(const LoadMachinePartTreeEvent());
      },
    );
  }

  Future<void> _onUpdateMachinePart(
    UpdateMachinePartEvent event,
    Emitter<MachineState> emit,
  ) async {
    _logger.info('Updating machine part: id=${event.machinePartId}');
    emit(state.copyWith(operationStatus: MachineStatus.loading, clearError: true));

    final result = await _machineRepository.updateMachinePart(
      event.machinePartId,
      event.machinePart,
    );

    result.fold(
      (error) => emit(state.copyWith(
        operationStatus: MachineStatus.failure,
        errorMessage: error.message,
      )),
      (part) {
        emit(state.copyWith(
          operationStatus: MachineStatus.success,
          successMessage: 'Machine part updated successfully',
        ));
        add(const LoadMachinePartTreeEvent());
      },
    );
  }

  Future<void> _onDeleteMachinePart(
    DeleteMachinePartEvent event,
    Emitter<MachineState> emit,
  ) async {
    _logger.info('Deleting machine part: id=${event.machinePartId}');
    emit(state.copyWith(operationStatus: MachineStatus.loading, clearError: true));

    final result = await _machineRepository.deleteMachinePart(event.machinePartId);

    result.fold(
      (error) => emit(state.copyWith(
        operationStatus: MachineStatus.failure,
        errorMessage: error.message,
      )),
      (_) {
        emit(state.copyWith(
          operationStatus: MachineStatus.success,
          successMessage: 'Machine part deleted successfully',
        ));
        add(const LoadMachinePartTreeEvent());
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Common Handlers
  // ─────────────────────────────────────────────────────────────────────────

  void _onClearSelectedMachine(
    ClearSelectedMachineEvent event,
    Emitter<MachineState> emit,
  ) {
    emit(state.copyWith(clearSelectedMachine: true));
  }

  void _onRefreshMachineList(
    RefreshMachineListEvent event,
    Emitter<MachineState> emit,
  ) {
    add(LoadMachineListEvent(
      page: 1,
      pageSize: state.pageSize,
      name: state.filterName,
      areaId: state.filterAreaId,
      machineTypeId: state.filterMachineTypeId,
      status: state.filterStatus,
    ));
  }
}
