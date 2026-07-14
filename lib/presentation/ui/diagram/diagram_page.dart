import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../di/injection.dart';
import '../../bloc/area/area_bloc.dart';
import 'diagram_screen.dart';

class DiagramPage extends StatelessWidget {
  const DiagramPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AreaBloc>(
      create: (context) => getIt<AreaBloc>(),
      child: const DiagramScreen(),
    );
  }
}
