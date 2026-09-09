import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/attachment_model.dart';
import '../../models/medical_record_model.dart';
import '../../services/firestore_service.dart';
import '../../services/medical_record_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/attachment_picker_widget.dart';

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
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  bool isLoading = false;
  DateTime visitDate = DateTime.now();
  List<PendingAttachment> pendingAttachments = [];

  @override
  void initState() {
    super.initState();
    _loadDoctorName();
  }

  Future<void> _loadDoctorName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final user = await _firestoreService.getUser(uid);
      if (user != null && user['name'] != null && mounted) {
        setState(() {
          doctorNameController.text = "Dr. ${user['name']}";
        });
      }
    }
  }

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
      final recordId = _service.newRecordId();

      // Upload pending attachments to Firebase Storage
      final List<AttachmentModel> uploadedAttachments = [];
      for (final pending in pendingAttachments) {
        final attachment = await _storageService.uploadAttachment(
          patientId: widget.patientId,
          category: 'medical_records',
          recordId: recordId,
          file: pending.file,
          originalName: pending.originalName,
          type: pending.type,
        );
        uploadedAttachments.add(attachment);
      }

      final record = MedicalRecordModel(
        id: recordId,
        patientId: widget.patientId,
        doctorName: doctorNameController.text.trim().isNotEmpty
            ? doctorNameController.text.trim()
            : "Doctor",
        diagnosis: diagnosisController.text.trim(),
        prescription: prescriptionController.text.trim(),
        notes: notesController.text.trim(),
        visitDate: visitDate,
        attachments: uploadedAttachments,
        createdAt: Timestamp.now(),
      );

      await _service.addRecord(record);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Medical Record Added Successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save medical record: $e"),
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

  Widget buildField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return "Please enter $label";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: "$label${isRequired ? ' *' : ''}",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Add Medical Record"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.blue.shade50,
                elevation: 2,
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
                  subtitle: const Text("Selected Patient"),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
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
                        label: "Prescription / Treatment Plan",
                        maxLines: 2,
                        isRequired: false,
                      ),

                      buildField(
                        controller: notesController,
                        label: "Doctor Notes & Remarks",
                        maxLines: 4,
                        isRequired: false,
                      ),

                      Card(
                        elevation: 0,
                        color: Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today,
                              color: Colors.blue),
                          title: Text(
                            "Visit Date: ${visitDate.day}/${visitDate.month}/${visitDate.year}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: OutlinedButton(
                            onPressed: pickDate,
                            child: const Text("Change"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Attachments Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AttachmentPickerWidget(
                    initialAttachments: pendingAttachments,
                    onAttachmentsChanged: (updated) {
                      setState(() {
                        pendingAttachments = updated;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: isLoading ? null : saveRecord,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    isLoading ? "Uploading & Saving..." : "Save Medical Record",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
