import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/attachment_model.dart';
import '../../models/lab_report_model.dart';
import '../../services/firestore_service.dart';
import '../../services/lab_report_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_constants.dart';
import '../../widgets/attachment_picker_widget.dart';

class AddLabReportScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const AddLabReportScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<AddLabReportScreen> createState() => _AddLabReportScreenState();
}

class _AddLabReportScreenState extends State<AddLabReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final LabReportService _service = LabReportService();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  final testNameController = TextEditingController();
  final resultController = TextEditingController();
  final referenceRangeController = TextEditingController();
  final remarksController = TextEditingController();
  final doctorNameController = TextEditingController();

  DateTime reportDate = DateTime.now();
  bool isLoading = false;
  List<PendingAttachment> pendingAttachments = [];

  @override
  void initState() {
    super.initState();
    _loadDoctorName();
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

  @override
  void dispose() {
    testNameController.dispose();
    resultController.dispose();
    referenceRangeController.dispose();
    remarksController.dispose();
    doctorNameController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: reportDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        reportDate = picked;
      });
    }
  }

  Future<void> _saveLabReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";
      final reportId = _service.newReportId();

      // Upload pending attachments to Firebase Storage
      final List<AttachmentModel> uploadedAttachments = [];
      for (final pending in pendingAttachments) {
        final attachment = await _storageService.uploadAttachment(
          patientId: widget.patientId,
          category: 'lab_reports',
          recordId: reportId,
          file: pending.file,
          originalName: pending.originalName,
          type: pending.type,
        );
        uploadedAttachments.add(attachment);
      }

      final report = LabReportModel(
        id: reportId,
        patientId: widget.patientId,
        patientName: widget.patientName,
        doctorName: doctorNameController.text.trim(),
        doctorId: currentUid,
        testName: testNameController.text.trim(),
        result: resultController.text.trim(),
        referenceRange: referenceRangeController.text.trim(),
        remarks: remarksController.text.trim(),
        reportDate: reportDate,
        attachments: uploadedAttachments,
        createdAt: Timestamp.now(),
      );

      await _service.addLabReport(report);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lab Report saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save lab report: $e"),
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    IconData? icon,
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
          hintText: hintText,
          prefixIcon: icon != null ? Icon(icon) : null,
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
        title: const Text("New Lab Report"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildField(
                        controller: doctorNameController,
                        label: "Referring / Ordering Doctor",
                        hintText: "Dr. Full Name",
                        icon: Icons.medical_services_outlined,
                      ),

                      const Text(
                        "Quick Select Test:",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: AppConstants.commonLabTests.take(6).map((test) {
                          return ActionChip(
                            label: Text(test, style: const TextStyle(fontSize: 12)),
                            backgroundColor: Colors.blue.shade50,
                            onPressed: () {
                              setState(() {
                                testNameController.text = test;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),

                      _buildField(
                        controller: testNameController,
                        label: "Test Name",
                        hintText: "e.g., Complete Blood Count (CBC)",
                        icon: Icons.science_outlined,
                      ),

                      _buildField(
                        controller: resultController,
                        label: "Result / Finding",
                        hintText: "e.g., Hb: 13.5 g/dL, WBC: 7,500 /mcL",
                        icon: Icons.analytics_outlined,
                        maxLines: 2,
                      ),

                      _buildField(
                        controller: referenceRangeController,
                        label: "Reference Range / Normal Value",
                        hintText: "e.g., Hb: 12.0 - 15.5 g/dL",
                        icon: Icons.straighten_outlined,
                        isRequired: false,
                      ),

                      _buildField(
                        controller: remarksController,
                        label: "Doctor Remarks / Clinical Notes",
                        hintText: "e.g., Results are within normal limits.",
                        icon: Icons.note_outlined,
                        maxLines: 3,
                        isRequired: false,
                      ),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today, color: Colors.blue),
                        title: const Text("Report Date"),
                        subtitle: Text(
                          DateFormat("dd MMMM yyyy").format(reportDate),
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
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _saveLabReport,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    isLoading ? "Uploading & Saving..." : "Save Lab Report",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
