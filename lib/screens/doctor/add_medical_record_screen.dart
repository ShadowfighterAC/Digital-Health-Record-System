import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/medical_record_model.dart';
import '../../services/medical_record_service.dart';

class AddMedicalRecordScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const AddMedicalRecordScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<AddMedicalRecordScreen> createState() =>
      _AddMedicalRecordScreenState();
}

class _AddMedicalRecordScreenState extends State<AddMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  final doctorNameController = TextEditingController();
  final diagnosisController = TextEditingController();
  final prescriptionController = TextEditingController();
  final notesController = TextEditingController();

  final MedicalRecordService _service = MedicalRecordService();

  bool isLoading = false;
  DateTime visitDate = DateTime.now();

  @override
  void dispose() {
    doctorNameController.dispose();
    diagnosisController.dispose();
    prescriptionController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: visitDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        visitDate = picked;
      });
    }
  }

  Future<void> saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final record = MedicalRecordModel(
        id: "",
        patientId: widget.patientId,
        doctorName: doctorNameController.text.trim(),
        diagnosis: diagnosisController.text.trim(),
        prescription: prescriptionController.text.trim(),
        notes: notesController.text.trim(),
        visitDate: visitDate,
        createdAt: Timestamp.now(),
      );

      await _service.addRecord(record);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Medical Record Added Successfully"),
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
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
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
        title: const Text("Add Medical Record"),
        centerTitle: true,
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
                controller: doctorNameController,
                label: "Doctor Name",
              ),

              buildField(
                controller: diagnosisController,
                label: "Diagnosis",
              ),

              buildField(
                controller: prescriptionController,
                label: "Prescription",
              ),

              buildField(
                controller: notesController,
                label: "Notes",
                maxLines: 4,
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    "${visitDate.day}/${visitDate.month}/${visitDate.year}",
                  ),
                  trailing: ElevatedButton(
                    onPressed: pickDate,
                    child: const Text("Change"),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : saveRecord,
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Save Medical Record",
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