import 'package:flutter/material.dart';

class AdminReportPage extends StatelessWidget {
  const AdminReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Reports'),
      ),
      body: Center(
        child: Text('Admin Report Page Content'),
      ),
    );
  }
}
