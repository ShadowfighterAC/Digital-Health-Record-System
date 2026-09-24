import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/medical_record_model.dart';
import '../../services/medical_record_service.dart';
import '../../widgets/attachment_view_widget.dart';

class PatientRecords extends StatelessWidget {
  const PatientRecords({super.key});

  @override
  Widget build(BuildContext context) {
    final service = MedicalRecordService();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medicalRecords),
        centerTitle: true,
      ),
      body: uid.isEmpty
          ? Center(child: Text(l10n.pleaseSignInRecords))
          : StreamBuilder<List<MedicalRecordModel>>(
              stream: service.getPatientRecords(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(l10n.somethingWentWrong),
                  );
                }

                final records = snapshot.data ?? [];

                if (records.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.noRecordsYet,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.recordsAppearHere,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.diagnosis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.person, size: 18),
                                const SizedBox(width: 8),
                                Text(record.doctorName),
                              ],
                            ),
                            if (record.prescription.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.medication, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(record.prescription),
                                  ),
                                ],
                              ),
                            ],
                            if (record.notes.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.notes, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(record.notes),
                                  ),
                                ],
                              ),
                            ],
                            if (record.attachments.isNotEmpty) ...[
                              AttachmentViewWidget(
                                attachments: record.attachments,
                              ),
                            ],
                            const Divider(height: 28),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat("dd MMM yyyy")
                                      .format(record.visitDate),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
