import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/medical_history_model.dart';
import '../../services/medical_history_service.dart';
import '../../widgets/attachment_view_widget.dart';

class PatientMedicalHistory extends StatelessWidget {
  const PatientMedicalHistory({super.key});

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'allergies':
        return Colors.red;
      case 'previous surgery':
        return Colors.deepOrange;
      case 'hospitalization':
        return Colors.amber.shade900;
      case 'previous diagnosis':
        return Colors.blue;
      case 'existing conditions':
        return Colors.purple;
      case 'previous medications':
        return Colors.teal;
      case 'family history':
        return Colors.indigo;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    final service = MedicalHistoryService();
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(l10n.medicalHistory),
        centerTitle: true,
      ),
      body: uid.isEmpty
          ? Center(child: Text(l10n.pleaseSignInHistory))
          : StreamBuilder<List<MedicalHistoryModel>>(
              stream: service.getPatientHistory(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "${l10n.isMarathi ? 'वैद्यकीय इतिहास लोड करता आला नाही' : 'Unable to load medical history'}: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final list = snapshot.data ?? [];

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_edu_outlined,
                          size: 70,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noMedicalHistoryRecorded,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.medicalHistoryAppearHere,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final catColor = _getCategoryColor(item.category);

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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: catColor.withAlpha(25),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: catColor.withAlpha(80),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.translateCategory(item.category),
                                    style: TextStyle(
                                      color: catColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Text(
                                  DateFormat("dd MMM yyyy")
                                      .format(item.historyDate),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item.description.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                item.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                            if (item.notes.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${l10n.isMarathi ? 'शेरा' : 'Remarks'}: ${item.notes}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ],
                            if (item.attachments.isNotEmpty) ...[
                              AttachmentViewWidget(
                                attachments: item.attachments,
                              ),
                            ],
                            const Divider(height: 20),
                            Row(
                              children: [
                                const Icon(
                                  Icons.medical_services_outlined,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.recordedBy(item.doctorName),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
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
