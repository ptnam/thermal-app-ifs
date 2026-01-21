import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../di/injection.dart';
import '../../bloc/area/area_bloc.dart';
import 'camera_screen.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AreaBloc>(
      create: (context) => getIt<AreaBloc>(),
      child: const CameraScreen(),
    );
  }
}