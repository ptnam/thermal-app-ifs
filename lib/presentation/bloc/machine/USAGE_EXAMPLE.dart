/// =============================================================================
/// Example: How to use MachineSettingsBloc
/// =============================================================================

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:thermal_mobile/di/injection.dart';
// import 'package:thermal_mobile/presentation/bloc/machine/machine_settings_bloc.dart';
// import 'package:thermal_mobile/presentation/bloc/machine/machine_settings_event.dart';
// import 'package:thermal_mobile/presentation/bloc/machine/machine_settings_state.dart';

/// Example 1: Using MachineSettingsBloc with BlocProvider
/// 
/// class MachineSettingsScreen extends StatelessWidget {
///   const MachineSettingsScreen({Key? key}) : super(key: key);
///
///   @override
///   Widget build(BuildContext context) {
///     return BlocProvider(
///       create: (context) => getIt<MachineSettingsBloc>()
///         ..add(const LoadMachineSettingsEvent()),
///       child: Scaffold(
///         appBar: AppBar(title: const Text('Machine Settings')),
///         body: BlocBuilder<MachineSettingsBloc, MachineSettingsState>(
///           builder: (context, state) {
///             if (state.status == MachineSettingsStatus.loading) {
///               return const Center(child: CircularProgressIndicator());
///             }
///             
///             if (state.status == MachineSettingsStatus.failure) {
///               return Center(
///                 child: Text('Error: ${state.errorMessage}'),
///               );
///             }
///             
///             if (state.status == MachineSettingsStatus.success && 
///                 state.settings != null) {
///               final settings = state.settings!;
///               return ListView(
///                 padding: const EdgeInsets.all(16),
///                 children: [
///                   Text('User ID: ${settings.userId}'),
///                   Text('Area ID: ${settings.areaId}'),
///                   Text('Machine IDs: ${settings.machineIds}'),
///                   Text('Component IDs: ${settings.machineComponentIds}'),
///                 ],
///               );
///             }
///             
///             return const Center(child: Text('No settings found'));
///           },
///         ),
///       ),
///     );
///   }
/// }

/// Example 2: Using MachineSettingsBloc in an existing widget
/// 
/// class MyWidget extends StatelessWidget {
///   const MyWidget({Key? key}) : super(key: key);
///
///   @override
///   Widget build(BuildContext context) {
///     // Get the bloc instance from DI
///     final machineSettingsBloc = getIt<MachineSettingsBloc>();
///     
///     // Load settings
///     machineSettingsBloc.add(const LoadMachineSettingsEvent());
///     
///     return BlocListener<MachineSettingsBloc, MachineSettingsState>(
///       bloc: machineSettingsBloc,
///       listener: (context, state) {
///         if (state.status == MachineSettingsStatus.success) {
///           // Do something when settings are loaded
///           final settings = state.settings;
///           print('Settings loaded: $settings');
///         }
///       },
///       child: BlocBuilder<MachineSettingsBloc, MachineSettingsState>(
///         bloc: machineSettingsBloc,
///         builder: (context, state) {
///           // Your UI here
///           return Container();
///         },
///       ),
///     );
///   }
/// }

/// Example 3: Simple usage without UI
/// 
/// void loadMachineSettings() async {
///   final bloc = getIt<MachineSettingsBloc>();
///   bloc.add(const LoadMachineSettingsEvent());
///   
///   await for (final state in bloc.stream) {
///     if (state.status == MachineSettingsStatus.success) {
///       print('Settings: ${state.settings}');
///       break;
///     } else if (state.status == MachineSettingsStatus.failure) {
///       print('Error: ${state.errorMessage}');
///       break;
///     }
///   }
/// }
