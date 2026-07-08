import 'package:flutter/material.dart';

class AddCameraScreen extends StatelessWidget {
  const AddCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm camera'),
      ),
      body: const Center(
        child: Text('Màn thêm camera'),
      ),
    );
  }
}
