import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/lab_report_model.dart';
import '../../services/lab_report_service.dart';
import '../../widgets/attachment_view_widget.dart';

class PatientLabReports extends StatelessWidget {
  const PatientLabReports({super.key});

  @override
  Widget build(BuildContext context) {
    final service = LabReportService();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(l10n.labAndDiagnosticReports),
        centerTitle: true,
      ),
      body: uid.isEmpty
          ? Center(child: Text(l10n.pleaseSignInLab))
          : StreamBuilder<List<LabReportModel>>(
              stream: service.getPatientLabReports(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "${l10n.isMarathi ? 'लॅब अहवाल लोड करता आले नाहीत' : 'Unable to load lab reports'}: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final reports = snapshot.data ?? [];

                if (reports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.science_outlined,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.noLabReportsFound,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.labReportsAppearHere,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
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
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.teal.shade100,
                                      child: const Icon(
                                        Icons.science,
                                        color: Colors.teal,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      report.testName,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  DateFormat("dd MMM yyyy")
                                      .format(report.reportDate),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50.withAlpha(80),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.teal.shade100),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${l10n.resultFinding}:",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    report.result,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (report.referenceRange.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      "${l10n.referenceRangeNormal}: ${report.referenceRange}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            if (report.remarks.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                "${l10n.doctorRemarksClinicalNotes}: ${report.remarks}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],

                            if (report.attachments.isNotEmpty) ...[
                              AttachmentViewWidget(
                                attachments: report.attachments,
                              ),
                            ],

                            const Divider(height: 20),

                            Row(
                              children: [
                                const Icon(Icons.medical_services_outlined,
                                    size: 14, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.reportedBy(report.doctorName),
                                  style: TextStyle(
                                    fontSize: 12,
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
