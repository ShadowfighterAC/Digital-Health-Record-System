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

class _AddAppointmentScreenState
    extends State<AddAppointmentScreen> {
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
        content: Text("Appointment Created"),
      ),
    );

    Navigator.pop(context);
  }

  Widget buildField(
    TextEditingController controller,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        validator: (value) =>
            value!.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
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
                doctorController,
                "Doctor Name",
              ),

              buildField(
                reasonController,
                "Reason",
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    "${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}",
                  ),
                  trailing: ElevatedButton(
                    onPressed: chooseDate,
                    child: const Text("Date"),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(
                    appointmentTime.format(context),
                  ),
                  trailing: ElevatedButton(
                    onPressed: chooseTime,
                    child: const Text("Time"),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      isLoading ? null : saveAppointment,
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Create Appointment",
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