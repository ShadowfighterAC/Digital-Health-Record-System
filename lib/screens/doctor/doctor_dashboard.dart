import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/firestore_service.dart';
import '../../widgets/info_card.dart';
import '../../widgets/language_selector_dialog.dart';
import '../auth/login_screen.dart';
import 'doctor_appointments_screen.dart';
import 'doctor_lab_reports_screen.dart';
import 'doctor_prescriptions_screen.dart';
import 'doctor_medical_history_screen.dart';
import 'doctor_profile_screen.dart';
import 'patient_list_screen.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic>? doctorData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final data = await _firestoreService.getUser(uid);
      if (mounted) {
        setState(() {
          doctorData = data;
          isLoading = false;
        });
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmLogout),
        content: Text(l10n.confirmLogoutDoctorPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildDashboardButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(35),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final doctorName = doctorData?["name"] ?? l10n.doctor;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(l10n.doctorDashboard),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: l10n.language,
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const LanguageSelectorDialog(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DoctorProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withAlpha(50),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${l10n.welcomeDoctor} 👨‍⚕️",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Dr. $doctorName",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.doctorSubtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Statistics Header
            Text(
              l10n.clinicOverview,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Real-time Firestore Stats
            StreamBuilder<DoctorDashboardStats>(
              stream: _firestoreService.getDoctorStats(),
              builder: (context, snapshot) {
                final stats = snapshot.data ?? DoctorDashboardStats();

                return Column(
                  children: [
                    Row(
                      children: [
                        InfoCard(
                          icon: Icons.people,
                          title: l10n.patients,
                          value: "${stats.totalPatients}",
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PatientListScreen(
                                  mode: PatientListMode.viewDetails,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        InfoCard(
                          icon: Icons.calendar_month,
                          title: l10n.appointments,
                          value: "${stats.totalAppointments}",
                          color: Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const DoctorAppointmentsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        InfoCard(
                          icon: Icons.folder_open,
                          title: l10n.records,
                          value: "${stats.totalRecords}",
                          color: Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PatientListScreen(
                                  mode: PatientListMode.addMedicalRecord,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        InfoCard(
                          icon: Icons.medication,
                          title: l10n.prescriptions,
                          value: "${stats.totalPrescriptions}",
                          color: Colors.purple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const DoctorPrescriptionsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Quick Actions & Management
            Text(
              l10n.managementAndFeatures,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _buildDashboardButton(
              icon: Icons.people_alt_outlined,
              title: l10n.patientsDirectory,
              subtitle: l10n.patientsDirectorySubtitle,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientListScreen(
                      mode: PatientListMode.viewDetails,
                    ),
                  ),
                );
              },
            ),

            _buildDashboardButton(
              icon: Icons.calendar_month,
              title: l10n.appointmentsManager,
              subtitle: l10n.appointmentsManagerSubtitle,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DoctorAppointmentsScreen(),
                  ),
                );
              },
            ),

            _buildDashboardButton(
              icon: Icons.medication_outlined,
              title: l10n.prescriptions,
              subtitle: l10n.prescriptionsManagerSubtitle,
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DoctorPrescriptionsScreen(),
                  ),
                );
              },
            ),

            _buildDashboardButton(
              icon: Icons.science_outlined,
              title: l10n.labReports,
              subtitle: l10n.labReportsManagerSubtitle,
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DoctorLabReportsScreen(),
                  ),
                );
              },
            ),

            _buildDashboardButton(
              icon: Icons.history_edu_outlined,
              title: l10n.medicalHistory,
              subtitle: l10n.medicalHistoryManagerSubtitle,
              color: Colors.indigo,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DoctorMedicalHistoryScreen(),
                  ),
                );
              },
            ),

            _buildDashboardButton(
              icon: Icons.note_add_outlined,
              title: l10n.addMedicalRecord,
              subtitle: l10n.addMedicalRecordSubtitle,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientListScreen(
                      mode: PatientListMode.addMedicalRecord,
                    ),
                  ),
                );
              },
            ),

            _buildDashboardButton(
              icon: Icons.person_outline,
              title: l10n.myProfile,
              subtitle: l10n.doctorProfileSettingsSubtitle,
              color: Colors.indigo,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DoctorProfileScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: Text(
                  l10n.logout,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}