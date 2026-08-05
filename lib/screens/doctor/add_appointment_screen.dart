import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';

class AddAppointmentScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const AddAppointmentScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<AddAppointmentScreen> createState() =>
      _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final doctorController = TextEditingController();
  final reasonController = TextEditingController();

  final AppointmentService _service = AppointmentService();

  bool isLoading = false;

  DateTime appointmentDate = DateTime.now();
  TimeOfDay appointmentTime = TimeOfDay.now();

  @override
  void dispose() {
    doctorController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  Future<void> chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: appointmentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        appointmentDate = picked;
      });
    }
  }

  Future<void> chooseTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: appointmentTime,
    );

    if (picked != null) {
      setState(() {
        appointmentTime = picked;
      });
    }
  }

  Future<void> saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final appointment = AppointmentModel(
        id: "",
        patientId: widget.patientId,
        doctorName: doctorController.text.trim(),
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime.format(context),
        reason: reasonController.text.trim(),
        status: "Scheduled",
        createdAt: Timestamp.now(),
      );

      await _service.addAppointment(appointment);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Appointment Created Successfully"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Please enter $label";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule Appointment"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.blue.shade50,
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(widget.patientName),
                  subtitle: Text(widget.patientId),
                ),
              ),

              const SizedBox(height: 20),

              buildField(
                controller: doctorController,
                label: "Doctor Name",
              ),

              buildField(
                controller: reasonController,
                label: "Reason",
              ),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Text(
                          "${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),

                      ElevatedButton(
                        onPressed: chooseDate,
                        child: const Text("Select"),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Text(
                          appointmentTime.format(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),

                      ElevatedButton(
                        onPressed: chooseTime,
                        child: const Text("Select"),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : saveAppointment,
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Create Appointment",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}