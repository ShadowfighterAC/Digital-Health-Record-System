import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/prescription_model.dart';
import '../../services/prescription_service.dart';
import 'patient_list_screen.dart';

class DoctorPrescriptionsScreen extends StatefulWidget {
  const DoctorPrescriptionsScreen({super.key});

  @override
  State<DoctorPrescriptionsScreen> createState() =>
      _DoctorPrescriptionsScreenState();
}

class _DoctorPrescriptionsScreenState extends State<DoctorPrescriptionsScreen> {
  final PrescriptionService _service = PrescriptionService();
  String _searchQuery = "";

  void _confirmDelete(BuildContext context, String id) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Prescription"),
        content: const Text(
          "Are you sure you want to delete this prescription? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await _service.deletePrescription(id);
              messenger.showSnackBar(
                const SnackBar(content: Text("Prescription deleted")),
              );
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Prescriptions"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("New Prescription"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PatientListScreen(
                mode: PatientListMode.addPrescription,
              ),
            ),
          );
        },
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by patient or doctor name...",
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

          // List of Prescriptions
          Expanded(
            child: StreamBuilder<List<PrescriptionModel>>(
              stream: _service.getAllPrescriptions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "Unable to load prescriptions: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final allPrescriptions = snapshot.data ?? [];
                final prescriptions = _searchQuery.isEmpty
                    ? allPrescriptions
                    : allPrescriptions.where((p) {
                        return p.patientName.toLowerCase().contains(_searchQuery) ||
                            p.doctorName.toLowerCase().contains(_searchQuery);
                      }).toList();

                if (prescriptions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medication_liquid_outlined,
                          size: 70,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No Prescriptions Found",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? "Try adjusting your search criteria."
                              : "Tap 'New Prescription' to issue a prescription.",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                  itemCount: prescriptions.length,
                  itemBuilder: (context, index) {
                    final rx = prescriptions[index];
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rx.patientName.isNotEmpty
                                            ? rx.patientName
                                            : "Patient (${rx.patientId.substring(0, 6)}...)",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Prescribed by: ${rx.doctorName}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _confirmDelete(context, rx.id),
                                ),
                              ],
                            ),

                            const Divider(height: 20),

                            Text(
                              "Medicines (${rx.medicines.length}):",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 8),

                            ...rx.medicines.map(
                              (med) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50.withAlpha(80),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.circle,
                                          size: 8, color: Colors.blue),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              med.medicineName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "Dosage: ${med.dosage}  •  Frequency: ${med.frequency}  •  Duration: ${med.duration}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade800,
                                              ),
                                            ),
                                            if (med.instructions.isNotEmpty)
                                              Text(
                                                "Note: ${med.instructions}",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.blue.shade900,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            if (rx.notes.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                "Advice: ${rx.notes}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],

                            const SizedBox(height: 10),

                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 14, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat("dd MMM yyyy")
                                      .format(rx.prescriptionDate),
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
          ),
        ],
      ),
    );
  }
}
