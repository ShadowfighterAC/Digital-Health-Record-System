import 'package:flutter/material.dart';

import '../../models/patient_model.dart';
import '../../services/firestore_service.dart';

import 'add_medical_record_screen.dart';
import 'add_appointment_screen.dart';

class PatientListScreen extends StatelessWidget {
  final bool forAppointment;

  const PatientListScreen({
    super.key,
    this.forAppointment = false,
  });

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          forAppointment
              ? "Select Patient"
              : "Select Patient",
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<PatientModel>>(
        stream: firestoreService.getPatients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading patients."),
            );
          }

          final patients = snapshot.data ?? [];

          if (patients.isEmpty) {
            return const Center(
              child: Text(
                "No patients found.",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Colors.blue.shade100,
                    child: Text(
                      patient.name.isNotEmpty
                          ? patient.name[0]
                              .toUpperCase()
                          : "P",
                    ),
                  ),
                  title: Text(patient.name),
                  subtitle: Text(patient.email),
                  trailing:
                      const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    if (forAppointment) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddAppointmentScreen(
                            patientId: patient.uid,
                            patientName: patient.name,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddMedicalRecordScreen(
                            patientId: patient.uid,
                            patientName: patient.name,
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}