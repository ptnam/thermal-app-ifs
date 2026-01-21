import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thermal_mobile/core/constants/colors.dart';
import 'package:thermal_mobile/core/constants/icons.dart';
import 'package:thermal_mobile/presentation/bloc/user/user_bloc.dart';
import 'package:thermal_mobile/presentation/bloc/user/user_event.dart';
import 'package:thermal_mobile/presentation/bloc/user/user_state.dart';
import 'package:thermal_mobile/presentation/widgets/app_drawer_service.dart';
import 'package:thermal_mobile/presentation/ui/home/widget/area_dropdown.dart';
import 'package:thermal_mobile/di/injection.dart';
import 'package:thermal_mobile/data/local/storage/config_storage.dart';
import 'package:thermal_mobile/presentation/bloc/thermal_data/thermal_data_bloc.dart';
import 'package:thermal_mobile/presentation/bloc/thermal_data/thermal_data_event.dart';
import 'package:thermal_mobile/presentation/ui/home/widget/environment_temperature_card.dart';
import 'package:thermal_mobile/presentation/ui/home/widget/latest_alerts_card.dart';
import 'package:thermal_mobile/presentation/ui/home/widget/temperature_extreme_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ThermalDataBloc _thermalDataBloc;
  int? _selectedAreaId;

  @override
  void initState() {
    super.initState();

    // Create a single ThermalDataBloc instance for this page and provide events to it
    _thermalDataBloc = getIt<ThermalDataBloc>();

    // Load current user khi widget được khởi tạo
    context.read<UserBloc>().add(const LoadCurrentUserEvent());

    // Load environment thermal for saved selected area (if any)
    try {
      final savedId = getIt<ConfigStorage>().getSelectedAreaId();
      debugPrint('HomePage: init found saved selectedAreaId=$savedId');
      if (savedId != null) {
        _selectedAreaId = savedId;
        _thermalDataBloc.add(LoadEnvironmentThermalEvent(areaId: savedId));
        debugPrint(
          'HomePage: dispatched LoadEnvironmentThermalEvent for saved area $savedId',
        );
      }
    } catch (e) {
      debugPrint(
        'HomePage: error while triggering initial environment load: $e',
      );
    }
  }

  @override
  void dispose() {
    try {
      _thermalDataBloc.close();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
          kToolbarHeight + 8 + 1,
        ), // toolbar height + spacing + border
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.line.withOpacity(0.32),
                width: 1,
              ),
            ),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: InkWell(
              onTap: () {
                AppDrawerService.openDrawer();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SvgPicture.asset(
                  AppIcons.icMenu,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            title: AreaDropdown(
              onChanged: (area) {
                if (area != null) {
                  debugPrint(
                    'HomePage: area changed via AreaDropdown id=${area.id}, name=${area.name}',
                  );
                  setState(() {
                    _selectedAreaId = area.id;
                  });
                  try {
                    _thermalDataBloc.add(
                      LoadEnvironmentThermalEvent(areaId: area.id),
                    );
                    debugPrint(
                      'HomePage: dispatched LoadEnvironmentThermalEvent for area ${area.id}',
                    );
                  } catch (e) {
                    debugPrint(
                      'HomePage: error dispatching environment event: $e',
                    );
                  }
                }
              },
            ),
            // actions: [
            //   BlocBuilder<UserBloc, UserState>(
            //     builder: (context, state) {
            //       if (state.profileStatus == UserStatus.loading) {
            //         return const Padding(
            //           padding: EdgeInsets.all(16.0),
            //           child: Center(
            //             child: SizedBox(
            //               width: 24,
            //               height: 24,
            //               child: CircularProgressIndicator(
            //                 strokeWidth: 2,
            //                 color: Colors.white,
            //               ),
            //             ),
            //           ),
            //         );
            //       }

            //       final user = state.currentUser;
            //       final userName = user?.fullName ?? user?.userName ?? 'Unknown';
            //       final userRole = user?.roleName ?? user?.role?.name ?? 'User';
            //       final avatarUrl = user?.avatarUrl;

            //       return Row(
            //         children: [
            //           Column(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             crossAxisAlignment: CrossAxisAlignment.end,
            //             children: [
            //               Text(
            //                 userName,
            //                 style: const TextStyle(
            //                   fontSize: 16,
            //                   fontWeight: FontWeight.w700,
            //                   color: Colors.white,
            //                 ),
            //               ),
            //               const SizedBox(height: 4),
            //               Text(
            //                 userRole,
            //                 style: TextStyle(
            //                   fontSize: 12,
            //                   fontWeight: FontWeight.w400,
            //                   color: AppColors.text,
            //                 ),
            //               ),
            //             ],
            //           ),
            //           const SizedBox(width: 12),
            //           Padding(
            //             padding: const EdgeInsets.only(right: 16.0),
            //             child: UserAvatar(
            //               avatarUrl: avatarUrl,
            //               name: userName,
            //               radius: 20,
            //               borderColor: Colors.white,
            //               borderWidth: 2,
            //             ),
            //           ),
            //         ],
            //       );
            //     },
            //   ),
            // ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(16),
              child: SizedBox.shrink(),
            ),
          ),
        ),
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state.profileStatus == UserStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lỗi: ${state.errorMessage ?? "Không thể tải thông tin user"}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UserBloc>().add(
                        const LoadCurrentUserEvent(),
                      );
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return BlocProvider.value(
            value: _thermalDataBloc,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Environment temperature card for selected area
                  const EnvironmentTemperatureCard(),

                  // Temperature extremes (hottest/coldest machines)
                  TemperatureExtremeCard(
                    key: ValueKey('temp_extreme_$_selectedAreaId'),
                    areaId: _selectedAreaId,
                  ),

                  // Latest alerts section - give it a fixed height
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 300,
                    child: LatestAlertsCard(
                      key: ValueKey(_selectedAreaId),
                      areaId: _selectedAreaId,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
