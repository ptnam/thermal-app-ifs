import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../di/injection.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/logger/app_logger.dart';
import '../../../data/network/thermal_data/thermal_data_api_service.dart';

// Blocs
import '../../bloc/area/area_bloc.dart';
import '../../bloc/camera/camera_stream_bloc.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';
import '../../bloc/machine/machine_bloc.dart';
import '../../bloc/machine/machine_event.dart';
import '../../bloc/machine/machine_state.dart';
import '../../bloc/role/role_bloc.dart';
import '../../bloc/role/role_event.dart';
import '../../bloc/role/role_state.dart';
import '../../bloc/thermal_data/thermal_data_bloc.dart';
import '../../bloc/thermal_data/thermal_data_event.dart';
import '../../bloc/thermal_data/thermal_data_state.dart';

/// Model cho API test item
class ApiTestItem {
  final String name;
  final String description;
  final String method;
  final String endpoint;
  final Future<dynamic> Function(String accessToken) execute;

  const ApiTestItem({
    required this.name,
    required this.description,
    required this.method,
    required this.endpoint,
    required this.execute,
  });
}

/// Màn hình test API
class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final AppLogger _logger = AppLogger(tag: 'ApiTestPage');
  final List<String> _logs = [];
  final ScrollController _logScrollController = ScrollController();

  late final List<ApiTestItem> _apiTests;
  String? _selectedApiName;
  String _result = '';
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initApiTests();
    _addLog('Khởi tạo API Test Page');
  }

  void _initApiTests() {
    _apiTests = [
      // ═══════════════════════════════════════════════════════════════════════
      // ALL BLOC-BASED API TESTS
      // ═══════════════════════════════════════════════════════════════════════

      // ─────────────────────────────────────────────────────────────────────────
      // AREA BLOC
      // ─────────────────────────────────────────────────────────────────────────
      ApiTestItem(
        name: '[AreaBloc] Area Tree',
        description: 'Lấy cây khu vực qua AreaBloc',
        method: 'BLOC',
        endpoint: 'AreaBloc → FetchAreaTreeEvent',
        execute: (token) async {
          final bloc = getIt<AreaBloc>();
          bloc.add(const FetchAreaTreeEvent());

          await Future.delayed(const Duration(milliseconds: 800));

          final state = bloc.state;
          if (state is AreaTreeLoaded) {
            return {
              'status': 'success',
              'areaCount': state.areas.length,
              'areas': state.areas
                  .take(5)
                  .map((a) => {'id': a.id, 'name': a.name, 'code': a.code})
                  .toList(),
            };
          } else if (state is AreaError) {
            throw Exception(state.message);
          }
          return {'status': state.runtimeType.toString()};
        },
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // CAMERA STREAM BLOC
      // ─────────────────────────────────────────────────────────────────────────
      ApiTestItem(
        name: '[CameraStreamBloc] Get Stream',
        description: 'Lấy stream URL camera (ID=1)',
        method: 'BLOC',
        endpoint: 'CameraStreamBloc → FetchCameraStreamEvent',
        execute: (token) async {
          final bloc = getIt<CameraStreamBloc>();
          bloc.add(const FetchCameraStreamEvent(cameraId: 1));

          await Future.delayed(const Duration(milliseconds: 800));

          final state = bloc.state;
          if (state is CameraStreamLoaded) {
            return {
              'status': 'success',
              'streamUrl': state.cameraStream.streamUrl,
              'cameraId': state.cameraStream.cameraId,
            };
          } else if (state is CameraStreamError) {
            throw Exception(state.message);
          }
          return {'status': state.runtimeType.toString()};
        },
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // NOTIFICATION BLOC
      // ─────────────────────────────────────────────────────────────────────────
      ApiTestItem(
        name: '[NotificationBloc] List',
        description: 'Lấy danh sách thông báo',
        method: 'BLOC',
        endpoint: 'NotificationBloc → LoadNotificationsEvent',
        execute: (token) async {
          final bloc = getIt<NotificationBloc>();
          bloc.add(
            LoadNotificationsEvent(
              queryParameters: {
                'page': 1,
                'pageSize': 10,
                'fromTime': DateTime.now()
                    .subtract(const Duration(days: 30))
                    .toIso8601String(),
              },
            ),
          );

          await Future.delayed(const Duration(milliseconds: 800));

          final state = bloc.state;
          if (state is NotificationListLoaded) {
            return {
              'status': 'success',
              'totalRow': state.list.totalRow,
              'pageSize': state.list.pageSize,
              'itemCount': state.list.items.length,
            };
          } else if (state is NotificationError) {
            throw Exception(state.message);
          }
          return {'status': state.runtimeType.toString()};
        },
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // USER BLOC
      // ─────────────────────────────────────────────────────────────────────────
      ApiTestItem(
        name: '[UserBloc] Current User',
        description: 'Lấy thông tin user hiện tại',
        method: 'BLOC',
        endpoint: 'UserBloc → LoadCurrentUserEvent',
        execute: (token) async {
          final bloc = getIt<UserBloc>();
          bloc.add(const LoadCurrentUserEvent());

          await Future.delayed(const Duration(milliseconds: 800));

          final state = bloc.state;
          if (state.profileStatus == UserStatus.success) {
            final user = state.currentUser;
            return {
              'status': 'success',
              'user': user != null
                  ? {
                      'id': user.id,
                      'userName': user.userName,
                      'fullName': user.fullName,
                      'email': user.email,
                    }
                  : null,
            };
          } else if (state.profileStatus == UserStatus.failure) {
            throw Exception(state.errorMessage ?? 'Failed to load user');
          }
          return {'status': state.profileStatus.toString()};
        },
      ),

      ApiTestItem(
        name: '[UserBloc] All Users',
        description: 'Lấy tất cả users',
        method: 'BLOC',
        endpoint: 'UserBloc → LoadAllUsersEvent',
        execute: (token) async {
          final bloc = getIt<UserBloc>();
          bloc.add(const LoadAllUsersEvent());

          await Future.delayed(const Duration(milliseconds: 800));

          final state = bloc.state;
          if (state.listStatus == UserStatus.success) {
            return {
              'status': 'success',
              'count': state.users.length,
              'users': state.users
                  .take(5)
                  .map((u) => {'id': u.id, 'userName': u.userName})
                  .toList(),
            };
          } else if (state.listStatus == UserStatus.failure) {
            throw Exception(state.errorMessage ?? 'Failed to load users');
          }
          return {'status': state.listStatus.toString()};
        },
      ),

      ApiTestItem(
        name: '[UserBloc] User List',
        description: 'Lấy danh sách users phân trang',
        method: 'BLOC',
        endpoint: 'UserBloc → LoadUserListEvent',
        execute: (token) async {
          final bloc = getIt<UserBloc>();
          bloc.add(const LoadUserListEvent(page: 1, pageSize: 10));

          await Future.delayed(const Duration(milliseconds: 800));

          final state = bloc.state;
          if (state.listStatus == UserStatus.success) {
            return {
              'status': 'success',
              'totalRecords': state.totalRecords,
              'currentPage': state.currentPage,
              'totalPages': state.totalPages,
              'count': state.users.length,
            };
          } else if (state.listStatus == UserStatus.failure) {
            throw Exception(state.errorMessage ?? 'Failed to load user list');
          }
          return {'status': state.listStatus.toString()};
        },
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // MACHINE BLOC
      // ─────────────────────────────────────────────────────────────────────────
      ApiTestItem(
        name: '[MachineBloc] All Machines',
        description: 'Lấy tất cả machines',
        method: 'BLOC',
        endpoint: 'MachineBloc → LoadAllMachinesEvent',
        execute: (token) async {
          final bloc = getIt<MachineBloc>();
          bloc.add(const LoadAllMachinesEvent());

          await Future.delayed(const Duration(milliseconds: 800));

          final state = bloc.state;
          if (state.listStatus == MachineStatus.success) {
            return {
              'status': 'success',
              'count': state.machines.length,
              'machines': state.machines
                  .take(5)
                  .map((m) => {'id': m.id, 'name': m.name, 'code': m.code})
                  .toList(),
            };
          } else if (state.listStatus == MachineStatus.failure) {
            throw Exception(state.errorMessage ?? 'Failed to load machines');
          }
          return {'status': state.listStatus.toString()};
        },
      ),

      ApiTestItem(
        name: '[MachineBloc] Machine List',
        description: 'Lấy danh sách machines phân trang',
        method: 'BLOC',
        endpoint: 'MachineBloc → LoadMachineListEvent',
        execute: (token) async {
          final bloc = getIt<MachineBloc>();
          bloc.add(const LoadMachineListEvent(page: 1, pageSize: 10));

          await Future.delayed(const Duration(milliseconds: 800));

          final state = bloc.state;
          if (state.listStatus == MachineStatus.success) {
            return {
              'status': 'success',
              'totalRecords': state.totalRecords,
              'currentPage': state.currentPage,
              'count': state.machines.length,
            };
          } else if (state.listStatus == MachineStatus.failure) {
            throw Exception(
              state.errorMessage ?? 'Failed to load machine list',
            );
          }
          return {'status': state.listStatus.toString()};
        },
      ),

      ApiTestItem(
        name: '[MachineBloc] All Machine Types',
        description: 'Lấy tất cả loại máy',
        method: 'BLOC',
        endpoint: 'MachineBloc → LoadAllMachineTypesEvent',
        execute: (token) async {
          final bloc = getIt<MachineBloc>();
          bloc.add(const LoadAllMachineTypesEvent());

          await Future.delayed(const Duration(milliseconds: 800));

          final state = bloc.state;
          if (state.typeListStatus == MachineStatus.success) {
            return {
              'status': 'success',
              'count': state.machineTypes.length,
              'machineTypes': state.machineTypes
                  .take(5)
                  .map((t) => {'id': t.id, 'name': t.name})
                  .toList(),
            };
          } else if (state.typeListStatus == MachineStatus.failure) {
            throw Exception(
              state.errorMessage ?? 'Failed to load machine types',
            );
          }
          return {'status': state.typeListStatus.toString()};
        },
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // ROLE BLOC
      // ─────────────────────────────────────────────────────────────────────────
      ApiTestItem(
        name: '[RoleBloc] All Roles',
        description: 'Lấy tất cả roles',
        method: 'BLOC',
        endpoint: 'RoleBloc → LoadAllRolesEvent',
        execute: (token) async {
          final bloc = getIt<RoleBloc>();
          bloc.add(const LoadAllRolesEvent());

          await Future.delayed(const Duration(milliseconds: 800));

          final state = bloc.state;
          if (state.listStatus == RoleStatus.success) {
            return {
              'status': 'success',
              'count': state.allRoles.length,
              'roles': state.allRoles
                  .take(5)
                  .map((r) => {'id': r.id, 'name': r.name})
                  .toList(),
            };
          } else if (state.listStatus == RoleStatus.failure) {
            throw Exception(state.errorMessage ?? 'Failed to load roles');
          }
          return {'status': state.listStatus.toString()};
        },
      ),

      ApiTestItem(
        name: '[RoleBloc] Role List',
        description: 'Lấy danh sách roles phân trang',
        method: 'BLOC',
        endpoint: 'RoleBloc → LoadRoleListEvent',
        execute: (token) async {
          final bloc = getIt<RoleBloc>();
          bloc.add(const LoadRoleListEvent(page: 1, pageSize: 10));

          await Future.delayed(const Duration(milliseconds: 800));

          final state = bloc.state;
          if (state.listStatus == RoleStatus.success) {
            return {
              'status': 'success',
              'totalRecords': state.totalRecords,
              'currentPage': state.currentPage,
              'count': state.roles.length,
            };
          } else if (state.listStatus == RoleStatus.failure) {
            throw Exception(state.errorMessage ?? 'Failed to load role list');
          }
          return {'status': state.listStatus.toString()};
        },
      ),

      ApiTestItem(
        name: '[RoleBloc] All Features',
        description: 'Lấy tất cả features',
        method: 'BLOC',
        endpoint: 'RoleBloc → LoadAllFeaturesEvent',
        execute: (token) async {
          final bloc = getIt<RoleBloc>();
          bloc.add(const LoadAllFeaturesEvent());

          await Future.delayed(const Duration(milliseconds: 800));

          final state = bloc.state;
          if (state.featureStatus == RoleStatus.success) {
            return {
              'status': 'success',
              'count': state.allFeatures.length,
              'features': state.allFeatures
                  .take(5)
                  .map((f) => {'id': f.id, 'name': f.name})
                  .toList(),
            };
          } else if (state.featureStatus == RoleStatus.failure) {
            throw Exception(state.errorMessage ?? 'Failed to load features');
          }
          return {'status': state.featureStatus.toString()};
        },
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // THERMAL DATA BLOC
      // ─────────────────────────────────────────────────────────────────────────
      ApiTestItem(
        name: '[ThermalDataBloc] Dashboard',
        description: 'Lấy dashboard nhiệt độ',
        method: 'BLOC',
        endpoint: 'ThermalDataBloc → LoadDashboardEvent',
        execute: (token) async {
          final bloc = getIt<ThermalDataBloc>();
          bloc.add(const LoadDashboardEvent());

          await Future.delayed(const Duration(milliseconds: 800));

          final state = bloc.state;
          if (state.dashboardStatus == ThermalDataStatus.success) {
            final dashboard = state.dashboard;
            return {
              'status': 'success',
              'dashboard': dashboard != null
                  ? {
                      'totalMachines': dashboard.totalMachines,
                      'normalCount': dashboard.normalCount,
                      'warningCount': dashboard.warningCount,
                      'dangerCount': dashboard.dangerCount,
                    }
                  : null,
            };
          } else if (state.dashboardStatus == ThermalDataStatus.failure) {
            throw Exception(state.errorMessage ?? 'Failed to load dashboard');
          }
          return {'status': state.dashboardStatus.toString()};
        },
      ),

      ApiTestItem(
        name: '[ThermalDataBloc] Data List',
        description: 'Lấy danh sách dữ liệu nhiệt',
        method: 'BLOC',
        endpoint: 'ThermalDataBloc → LoadThermalDataListEvent',
        execute: (token) async {
          final bloc = getIt<ThermalDataBloc>();
          bloc.add(const LoadThermalDataListEvent(page: 1, pageSize: 10));

          await Future.delayed(const Duration(milliseconds: 800));

          final state = bloc.state;
          if (state.listStatus == ThermalDataStatus.success) {
            return {
              'status': 'success',
              'totalRecords': state.totalRecords,
              'currentPage': state.currentPage,
              'count': state.thermalDataList.length,
            };
          } else if (state.listStatus == ThermalDataStatus.failure) {
            throw Exception(
              state.errorMessage ?? 'Failed to load thermal data',
            );
          }
          return {'status': state.listStatus.toString()};
        },
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // THERMAL DATA API SERVICE (Direct API Calls)
      // ─────────────────────────────────────────────────────────────────────────
      ApiTestItem(
        name: '[ThermalDataApi] Environment Thermal',
        description: 'Lấy nhiệt độ môi trường theo khu vực (areaId=5)',
        method: 'GET',
        endpoint: '/api/ThermalDatas/environmentThermal',
        execute: (token) async {
          final apiService = getIt<ThermalDataApiService>();
          final result = await apiService.getEnvironmentThermal(
            areaId: 5,
            accessToken: token,
          );

          return result.fold(
            onSuccess: (data) => {
              'status': 'success',
              'temperature': data?.temperature,
              'frequency': data?.frequency,
            },
            onFailure: (error) => throw Exception(error.message),
          );
        },
      ),
    ];
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    setState(() {
      _logs.add('[$timestamp] $message');
    });
    _logger.info(message);

    // Auto scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollController.hasClients) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<String?> _getAccessToken() async {
    try {
      final authRepository = getIt<AuthRepository>();
      final tokens = await authRepository.read();
      if (tokens != null) {
        _addLog('Token tìm thấy, expiresIn: ${tokens.expiresIn}s');
        return tokens.accessToken;
      }
      _addLog('Không tìm thấy token đã lưu');
      return null;
    } catch (e) {
      _addLog('Lỗi lấy access token: $e');
      return null;
    }
  }

  Future<void> _runApiTest(ApiTestItem api) async {
    setState(() {
      _selectedApiName = api.name;
      _isLoading = true;
      _hasError = false;
      _result = '';
    });

    _addLog('─────────────────────────────');
    _addLog('Bắt đầu test: ${api.name}');
    _addLog('Method: ${api.method}');
    _addLog('Endpoint: ${api.endpoint}');

    final accessToken = await _getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      _addLog('❌ Không có access token - vui lòng đăng nhập lại');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _result = jsonEncode({'error': 'No access token available'});
      });
      return;
    }

    _addLog('Access token: ${accessToken.substring(0, 20)}...');

    final stopwatch = Stopwatch()..start();

    try {
      final result = await api.execute(accessToken);
      stopwatch.stop();

      final jsonResult = const JsonEncoder.withIndent('  ').convert(result);

      _addLog('✅ Thành công (${stopwatch.elapsedMilliseconds}ms)');
      _addLog('Response length: ${jsonResult.length} chars');

      setState(() {
        _isLoading = false;
        _hasError = false;
        _result = jsonResult;
      });
    } catch (e, stackTrace) {
      stopwatch.stop();
      _addLog('❌ Lỗi (${stopwatch.elapsedMilliseconds}ms): $e');
      _logger.error('API Test Error', error: e, stackTrace: stackTrace);

      setState(() {
        _isLoading = false;
        _hasError = true;
        _result = const JsonEncoder.withIndent('  ').convert({
          'error': e.toString(),
          'stackTrace': stackTrace.toString().split('\n').take(10).toList(),
        });
      });
    }
  }

  void _copyResult() {
    if (_result.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã copy kết quả'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
    _addLog('Logs đã được xóa');
  }

  @override
  void dispose() {
    _logScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearLogs,
            tooltip: 'Xóa logs',
          ),
        ],
      ),
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          // API List
          Container(
            height: 120,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _apiTests.length,
              itemBuilder: (context, index) {
                final api = _apiTests[index];
                final isSelected = _selectedApiName == api.name;

                return Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 12),
                  child: Card(
                    elevation: isSelected ? 4 : 1,
                    color: isSelected
                        ? colorScheme.primaryContainer
                        : colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outline.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: _isLoading ? null : () => _runApiTest(api),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getMethodColor(api.method),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    api.method,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (isSelected && _isLoading)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              api.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              api.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected
                                    ? colorScheme.onPrimaryContainer
                                          .withOpacity(0.7)
                                    : colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Result Section
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hasError
                      ? Colors.red.withOpacity(0.5)
                      : colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _hasError ? Icons.error_outline : Icons.code,
                          size: 18,
                          color: _hasError
                              ? Colors.red
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _hasError ? 'Error Response' : 'JSON Response',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _hasError
                                ? Colors.red
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        if (_result.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: _copyResult,
                            tooltip: 'Copy',
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _result.isEmpty
                        ? Center(
                            child: Text(
                              'Chọn một API để test',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(12),
                            child: SelectableText(
                              _result,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: _hasError
                                    ? Colors.red.shade700
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),

          // Log Section
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.terminal,
                          size: 18,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Logs',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_logs.length} entries',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade700),
                  Expanded(
                    child: ListView.builder(
                      controller: _logScrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        Color logColor = Colors.grey.shade300;

                        if (log.contains('✅')) {
                          logColor = Colors.green;
                        } else if (log.contains('❌')) {
                          logColor = Colors.red;
                        } else if (log.contains('Bắt đầu') ||
                            log.contains('─────')) {
                          logColor = Colors.cyan;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            log,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: logColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.blue;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      case 'PATCH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
