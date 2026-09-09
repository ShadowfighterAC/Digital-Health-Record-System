import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/attachment_model.dart';
import '../../models/medical_history_model.dart';
import '../../services/firestore_service.dart';
import '../../services/medical_history_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_constants.dart';
import '../../widgets/attachment_picker_widget.dart';

class AddMedicalHistoryScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const AddMedicalHistoryScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<AddMedicalHistoryScreen> createState() =>
      _AddMedicalHistoryScreenState();
}

class _AddMedicalHistoryScreenState extends State<AddMedicalHistoryScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final notesController = TextEditingController();
  final doctorNameController = TextEditingController();

  final MedicalHistoryService _historyService = MedicalHistoryService();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  String selectedCategory = AppConstants.medicalHistoryCategories.first;
  DateTime historyDate = DateTime.now();
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
    titleController.dispose();
    descriptionController.dispose();
    notesController.dispose();
    doctorNameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: historyDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        historyDate = picked;
      });
    }
  }

  Future<void> _saveHistory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    // 7.a Generate the Medical History document ID using MedicalHistoryService.newHistoryId()
    final historyId = _historyService.newHistoryId();

    final List<AttachmentModel> uploadedAttachments = [];
    final List<String> uploadedStoragePaths = [];

    try {
      // 7.b-d Upload each selected attachment using StorageService.uploadAttachment()
      for (final pending in pendingAttachments) {
        final attachment = await _storageService.uploadAttachment(
          patientId: widget.patientId,
          category: 'medical_history',
          recordId: historyId,
          file: pending.file,
          originalName: pending.originalName,
          type: pending.type,
        );
        uploadedAttachments.add(attachment);
        uploadedStoragePaths.add(attachment.storagePath);
      }

      // 7.e Create the MedicalHistoryModel containing those attachments
      final history = MedicalHistoryModel(
        id: historyId,
        patientId: widget.patientId,
        doctorId: currentUid,
        doctorName: doctorNameController.text.trim().isNotEmpty
            ? doctorNameController.text.trim()
            : "Doctor",
        category: selectedCategory,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        historyDate: historyDate,
        notes: notesController.text.trim(),
        attachments: uploadedAttachments,
        createdAt: Timestamp.now(),
      );

      // 7.f Save the MedicalHistoryModel to Firestore
      await _historyService.addHistory(history);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Medical History added successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      // 8. FAILURE HANDLING:
      // If one or more uploads fail or saving fails:
      // - Do NOT save a Medical History record containing missing attachments.
      // - Attempt to delete any files that were already uploaded to Supabase Storage.
      for (final path in uploadedStoragePaths) {
        try {
          await _storageService.deleteAttachment(path);
        } catch (_) {
          // Best-effort cleanup of orphan storage files
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to save medical history: ${e.toString().replaceAll('Exception: ', '')}",
          ),
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
        title: const Text("Add Medical History"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected Patient Card
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

              // Category Selector
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
                        "History Category *",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        items: AppConstants.medicalHistoryCategories
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedCategory = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // History Details Form
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
                        controller: titleController,
                        label: "Title / Condition",
                        hintText: "e.g. Type 2 Diabetes, Appendectomy, Penicillin Allergy",
                        icon: Icons.title,
                      ),

                      _buildField(
                        controller: doctorNameController,
                        label: "Recording Doctor",
                        hintText: "Dr. Full Name",
                        icon: Icons.medical_services_outlined,
                      ),

                      // History Date Picker
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Occurrence / Diagnosis Date",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat("dd MMM yyyy").format(historyDate),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            OutlinedButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: const Text("Change"),
                            ),
                          ],
                        ),
                      ),

                      _buildField(
                        controller: descriptionController,
                        label: "Description & Past Treatment",
                        hintText: "Details about symptoms, prior treatment, surgeries, hospitalizations, or medications...",
                        icon: Icons.description_outlined,
                        maxLines: 3,
                        isRequired: false,
                      ),

                      _buildField(
                        controller: notesController,
                        label: "Doctor Notes / Remarks",
                        hintText: "Clinical observations, follow-up instructions, or warnings...",
                        icon: Icons.note_alt_outlined,
                        maxLines: 3,
                        isRequired: false,
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

              // Save Button
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
                  onPressed: isLoading ? null : _saveHistory,
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
                    isLoading ? "Uploading & Saving..." : "Save Medical History",
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
