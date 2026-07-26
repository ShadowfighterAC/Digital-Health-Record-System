import 'package:flutter/material.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Dashboard"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Welcome Patient!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}