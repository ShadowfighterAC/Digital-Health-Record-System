import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/prescription_model.dart';
import '../../services/firestore_service.dart';
import '../../services/prescription_service.dart';
import '../../utils/app_constants.dart';

class AddPrescriptionScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const AddPrescriptionScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<AddPrescriptionScreen> createState() => _AddPrescriptionScreenState();
}

class _AddPrescriptionScreenState extends State<AddPrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();

  final doctorNameController = TextEditingController();
  final notesController = TextEditingController();

  final PrescriptionService _service = PrescriptionService();
  final FirestoreService _firestoreService = FirestoreService();

  DateTime prescriptionDate = DateTime.now();
  bool isLoading = false;

  final List<Map<String, TextEditingController>> _medicineControllers = [];

  @override
  void initState() {
    super.initState();
    _loadDoctorName();
    _addMedicineRow();
  }

  Future<void> _loadDoctorName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final data = await _firestoreService.getUser(uid);
      if (data != null && data['name'] != null && mounted) {
        setState(() {
          doctorNameController.text = "Dr. ${data['name']}";
        });
      }
    }
  }

  void _addMedicineRow() {
    setState(() {
      _medicineControllers.add({
        'name': TextEditingController(),
        'dosage': TextEditingController(),
        'frequency': TextEditingController(text: AppConstants.medicineFrequencies[1]), // default BD
        'duration': TextEditingController(),
        'instructions': TextEditingController(text: "After meals"),
      });
    });
  }

  void _removeMedicineRow(int index) {
    if (_medicineControllers.length > 1) {
      setState(() {
        final controllers = _medicineControllers.removeAt(index);
        for (var c in controllers.values) {
          c.dispose();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("A prescription must have at least one medicine"),
        ),
      );
    }
  }

  @override
  void dispose() {
    doctorNameController.dispose();
    notesController.dispose();
    for (var m in _medicineControllers) {
      for (var c in m.values) {
        c.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: prescriptionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        prescriptionDate = picked;
      });
    }
  }

  Future<void> _savePrescription() async {
    if (!_formKey.currentState!.validate()) return;

    final List<MedicineItem> medicines = [];
    for (var m in _medicineControllers) {
      final name = m['name']!.text.trim();
      final dosage = m['dosage']!.text.trim();
      final frequency = m['frequency']!.text.trim();
      final duration = m['duration']!.text.trim();
      final instructions = m['instructions']!.text.trim();

      if (name.isEmpty || dosage.isEmpty || frequency.isEmpty || duration.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please fill all required medicine fields"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      medicines.add(
        MedicineItem(
          medicineName: name,
          dosage: dosage,
          frequency: frequency,
          duration: duration,
          instructions: instructions,
        ),
      );
    }

    setState(() {
      isLoading = true;
    });

    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

      final prescription = PrescriptionModel(
        id: "",
        patientId: widget.patientId,
        patientName: widget.patientName,
        doctorName: doctorNameController.text.trim(),
        doctorId: currentUid,
        medicines: medicines,
        prescriptionDate: prescriptionDate,
        notes: notesController.text.trim(),
        createdAt: Timestamp.now(),
      );

      await _service.addPrescription(prescription);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Prescription saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save prescription: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Create Prescription"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Patient summary card
              Card(
                elevation: 2,
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.person, color: Colors.blue),
                  ),
                  title: Text(
                    widget.patientName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Patient ID: ${widget.patientId}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Doctor Name & Date
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Prescription Details",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: doctorNameController,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? "Enter doctor name" : null,
                        decoration: InputDecoration(
                          labelText: "Doctor / Prescriber Name",
                          prefixIcon: const Icon(Icons.medical_services_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today, color: Colors.blue),
                        title: const Text("Prescription Date"),
                        subtitle: Text(
                          DateFormat("dd MMMM yyyy").format(prescriptionDate),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: OutlinedButton(
                          onPressed: _chooseDate,
                          child: const Text("Change"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Medicines Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Prescribed Medicines",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _addMedicineRow,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add Medicine"),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _medicineControllers.length,
                itemBuilder: (context, index) {
                  final medicine = _medicineControllers[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Medicine #${index + 1}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const Spacer(),
                              if (_medicineControllers.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _removeMedicineRow(index),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: medicine['name'],
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? "Required" : null,
                            decoration: InputDecoration(
                              labelText: "Medicine Name *",
                              hintText: "e.g., Amoxicillin / Paracetamol",
                              prefixIcon: const Icon(Icons.medication),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: medicine['dosage'],
                                  validator: (v) => (v == null || v.trim().isEmpty)
                                      ? "Required"
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: "Dosage *",
                                    hintText: "e.g., 500mg / 1 tab",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: medicine['duration'],
                                  validator: (v) => (v == null || v.trim().isEmpty)
                                      ? "Required"
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: "Duration *",
                                    hintText: "e.g., 5 days / 1 wk",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: AppConstants.medicineFrequencies
                                    .contains(medicine['frequency']!.text)
                                ? medicine['frequency']!.text
                                : AppConstants.medicineFrequencies[1],
                            decoration: InputDecoration(
                              labelText: "Frequency *",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: AppConstants.medicineFrequencies
                                .map(
                                  (f) => DropdownMenuItem(
                                    value: f,
                                    child: Text(f, style: const TextStyle(fontSize: 13)),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                medicine['frequency']!.text = val;
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: medicine['instructions'],
                            decoration: InputDecoration(
                              labelText: "Instructions (optional)",
                              hintText: "e.g., Take after meals with warm water",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              // General Doctor Advice / Notes
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Doctor's Advice & Additional Notes",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "e.g. Drink plenty of water and rest well.",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _savePrescription,
                  icon: isLoading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.check_circle_outline),
                  label: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Save & Issue Prescription",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
