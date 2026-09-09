import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/appointment_model.dart';
import '../../models/lab_report_model.dart';
import '../../models/medical_history_model.dart';
import '../../models/medical_record_model.dart';
import '../../models/patient_model.dart';
import '../../models/prescription_model.dart';
import '../../services/appointment_service.dart';
import '../../services/lab_report_service.dart';
import '../../services/medical_history_service.dart';
import '../../services/medical_record_service.dart';
import '../../services/prescription_service.dart';
import '../../widgets/attachment_view_widget.dart';
import 'add_appointment_screen.dart';
import 'add_lab_report_screen.dart';
import 'add_medical_history_screen.dart';
import 'add_medical_record_screen.dart';
import 'add_prescription_screen.dart';

class PatientDetailsScreen extends StatefulWidget {
  final PatientModel patient;

  const PatientDetailsScreen({
    super.key,
    required this.patient,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final MedicalRecordService _recordService = MedicalRecordService();
  final MedicalHistoryService _historyService = MedicalHistoryService();
  final PrescriptionService _prescriptionService = PrescriptionService();
  final LabReportService _labReportService = LabReportService();
  final AppointmentService _appointmentService = AppointmentService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha(80)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 3),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsTab() {
    return StreamBuilder<List<MedicalRecordModel>>(
      stream: _recordService.getPatientRecords(widget.patient.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final records = snapshot.data ?? [];
        if (records.isEmpty) {
          return const Center(
            child: Text("No medical records for this patient."),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final rec = records[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rec.diagnosis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (rec.prescription.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text("Prescription: ${rec.prescription}"),
                    ],
                    if (rec.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        "Notes: ${rec.notes}",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                    if (rec.attachments.isNotEmpty) ...[
                      AttachmentViewWidget(attachments: rec.attachments),
                    ],
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Dr: ${rec.doctorName}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          DateFormat("dd MMM yyyy").format(rec.visitDate),
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
    );
  }

  Widget _buildHistoryTab() {
    return StreamBuilder<List<MedicalHistoryModel>>(
      stream: _historyService.getPatientHistory(widget.patient.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final historyList = snapshot.data ?? [];
        if (historyList.isEmpty) {
          return const Center(
            child: Text("No medical history recorded for this patient."),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            final history = historyList[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.teal.shade200),
                          ),
                          child: Text(
                            history.category,
                            style: TextStyle(
                              color: Colors.teal.shade800,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat("dd MMM yyyy").format(history.historyDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      history.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (history.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        history.description,
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ],
                    if (history.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        "Doctor Remarks: ${history.notes}",
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    if (history.attachments.isNotEmpty) ...[
                      AttachmentViewWidget(attachments: history.attachments),
                    ],
                    const Divider(height: 16),
                    Text(
                      "Recorded by: ${history.doctorName}",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPrescriptionsTab() {
    return StreamBuilder<List<PrescriptionModel>>(
      stream: _prescriptionService.getPatientPrescriptions(widget.patient.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data ?? [];
        if (list.isEmpty) {
          return const Center(
            child: Text("No prescriptions for this patient."),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final rx = list[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Prescription (${DateFormat('dd MMM yyyy').format(rx.prescriptionDate)})",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...rx.medicines.map(
                      (m) => Text(
                        "• ${m.medicineName} (${m.dosage}) - ${m.frequency} for ${m.duration}",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    if (rx.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        "Advice: ${rx.notes}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLabReportsTab() {
    return StreamBuilder<List<LabReportModel>>(
      stream: _labReportService.getPatientLabReports(widget.patient.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data ?? [];
        if (list.isEmpty) {
          return const Center(
            child: Text("No lab reports for this patient."),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final lab = list[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lab.testName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Result: ${lab.result}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (lab.referenceRange.isNotEmpty)
                      Text(
                        "Normal: ${lab.referenceRange}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    if (lab.remarks.isNotEmpty)
                      Text(
                        "Remarks: ${lab.remarks}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    if (lab.attachments.isNotEmpty) ...[
                      AttachmentViewWidget(attachments: lab.attachments),
                    ],
                    const Divider(height: 14),
                    Text(
                      DateFormat("dd MMM yyyy").format(lab.reportDate),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAppointmentsTab() {
    return StreamBuilder<List<AppointmentModel>>(
      stream: _appointmentService.getPatientAppointments(widget.patient.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data ?? [];
        if (list.isEmpty) {
          return const Center(
            child: Text("No appointments scheduled for this patient."),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final appt = list[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                title: Text(
                  appt.reason,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${DateFormat('dd MMM yyyy').format(appt.appointmentDate)} at ${appt.appointmentTime}",
                ),
                trailing: Chip(
                  label: Text(
                    appt.status,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.patient.name),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        widget.patient.name.isNotEmpty
                            ? widget.patient.name[0].toUpperCase()
                            : "P",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.patient.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.patient.email,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Quick action buttons row
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.note_add,
                      label: "+ Record",
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddMedicalRecordScreen(
                              patientId: widget.patient.uid,
                              patientName: widget.patient.name,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    _buildActionButton(
                      icon: Icons.history_edu,
                      label: "+ History",
                      color: Colors.teal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddMedicalHistoryScreen(
                              patientId: widget.patient.uid,
                              patientName: widget.patient.name,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    _buildActionButton(
                      icon: Icons.medication,
                      label: "+ Rx",
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddPrescriptionScreen(
                              patientId: widget.patient.uid,
                              patientName: widget.patient.name,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    _buildActionButton(
                      icon: Icons.science,
                      label: "+ Lab",
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddLabReportScreen(
                              patientId: widget.patient.uid,
                              patientName: widget.patient.name,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    _buildActionButton(
                      icon: Icons.calendar_month,
                      label: "+ Appt",
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddAppointmentScreen(
                              patientId: widget.patient.uid,
                              patientName: widget.patient.name,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: "Records"),
                Tab(text: "History"),
                Tab(text: "Prescriptions"),
                Tab(text: "Lab Tests"),
                Tab(text: "Appointments"),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecordsTab(),
                _buildHistoryTab(),
                _buildPrescriptionsTab(),
                _buildLabReportsTab(),
                _buildAppointmentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
