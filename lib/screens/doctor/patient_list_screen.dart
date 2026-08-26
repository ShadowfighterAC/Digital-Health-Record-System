import 'package:flutter/material.dart';

import '../../models/patient_model.dart';
import '../../services/firestore_service.dart';

import 'add_medical_record_screen.dart';
import 'add_appointment_screen.dart';
import 'add_prescription_screen.dart';
import 'add_lab_report_screen.dart';
import 'patient_details_screen.dart';

enum PatientListMode {
  viewDetails,
  addMedicalRecord,
  addAppointment,
  addPrescription,
  addLabReport,
}

class PatientListScreen extends StatefulWidget {
  final bool forAppointment;
  final PatientListMode mode;

  const PatientListScreen({
    super.key,
    this.forAppointment = false,
    this.mode = PatientListMode.viewDetails,
  });

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _searchQuery = "";

  PatientListMode get _effectiveMode {
    if (widget.forAppointment) {
      return PatientListMode.addAppointment;
    }
    return widget.mode;
  }

  String get _appBarTitle {
    switch (_effectiveMode) {
      case PatientListMode.addAppointment:
        return "Select Patient (Appointment)";
      case PatientListMode.addMedicalRecord:
        return "Select Patient (Medical Record)";
      case PatientListMode.addPrescription:
        return "Select Patient (Prescription)";
      case PatientListMode.addLabReport:
        return "Select Patient (Lab Report)";
      case PatientListMode.viewDetails:
        return "Patients Directory";
    }
  }

  void _handlePatientSelected(PatientModel patient) {
    switch (_effectiveMode) {
      case PatientListMode.addAppointment:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddAppointmentScreen(
              patientId: patient.uid,
              patientName: patient.name,
            ),
          ),
        );
        break;

      case PatientListMode.addMedicalRecord:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddMedicalRecordScreen(
              patientId: patient.uid,
              patientName: patient.name,
            ),
          ),
        );
        break;

      case PatientListMode.addPrescription:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddPrescriptionScreen(
              patientId: patient.uid,
              patientName: patient.name,
            ),
          ),
        );
        break;

      case PatientListMode.addLabReport:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddLabReportScreen(
              patientId: patient.uid,
              patientName: patient.name,
            ),
          ),
        );
        break;

      case PatientListMode.viewDetails:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatientDetailsScreen(patient: patient),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(_appBarTitle),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search patients by name or email...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<List<PatientModel>>(
              stream: _firestoreService.getPatients(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "Error loading patients: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final allPatients = snapshot.data ?? [];
                final patients = _searchQuery.isEmpty
                    ? allPatients
                    : allPatients.where((p) {
                        return p.name.toLowerCase().contains(_searchQuery) ||
                            p.email.toLowerCase().contains(_searchQuery);
                      }).toList();

                if (patients.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 70,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No Patients Found",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? "Try adjusting your search criteria."
                              : "Registered patients will appear here.",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            patient.name.isNotEmpty
                                ? patient.name[0].toUpperCase()
                                : "P",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        title: Text(
                          patient.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(
                              patient.email,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              "UID: ${patient.uid.length > 12 ? '${patient.uid.substring(0, 12)}...' : patient.uid}",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onTap: () => _handlePatientSelected(patient),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}