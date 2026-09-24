import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/firestore_service.dart';
import '../../widgets/info_card.dart';
import '../../widgets/language_selector_dialog.dart';
import '../auth/login_screen.dart';
import 'choose_doctor_screen.dart';
import 'patient_records.dart';
import 'patient_medical_history.dart';
import 'patient_appointments.dart';
import 'patient_prescriptions.dart';
import 'patient_lab_reports.dart';
import 'patient_profile.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final FirestoreService _firestoreService = FirestoreService();

  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final data = await _firestoreService.getUser(uid);
      if (mounted) {
        setState(() {
          userData = data;
          isLoading = false;
        });
      }
    }
  }

  Future<void> logout() async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmLogout),
        content: Text(l10n.confirmLogoutPrompt),
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
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildActionCard({
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    final patientName = userData?["name"] ?? l10n.patient;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(l10n.patientDashboard),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: l10n.selectLanguage,
            onPressed: () => showLanguageSelectorDialog(context),
          ),
          IconButton(
            icon: const Icon(
              Icons.account_circle_outlined,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PatientProfile(),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1976D2),
                    Color(0xFF1565C0),
                  ],
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
                    "${l10n.welcome} 👋",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    patientName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.personalPortalSubtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              l10n.healthSummary,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            StreamBuilder<PatientDashboardStats>(
              stream: _firestoreService.getPatientStats(uid),
              builder: (context, snapshot) {
                final stats = snapshot.data ?? PatientDashboardStats();

                return Column(
                  children: [
                    Row(
                      children: [
                        InfoCard(
                          icon: Icons.description,
                          title: l10n.records,
                          value: "${stats.recordsCount}",
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PatientRecords(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        InfoCard(
                          icon: Icons.medication,
                          title: l10n.prescriptions,
                          value: "${stats.prescriptionsCount}",
                          color: Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PatientPrescriptions(),
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
                          icon: Icons.science,
                          title: l10n.labReports,
                          value: "${stats.labReportsCount}",
                          color: Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PatientLabReports(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        InfoCard(
                          icon: Icons.calendar_today,
                          title: l10n.appointments,
                          value: "${stats.appointmentsCount}",
                          color: Colors.purple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PatientAppointments(),
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

            Text(
              l10n.myHealthHub,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _buildActionCard(
              icon: Icons.medical_services_outlined,
              title: l10n.myDoctor,
              subtitle: l10n.myDoctorSubtitle,
              color: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChooseDoctorScreen(),
                  ),
                );
              },
            ),

            _buildActionCard(
              icon: Icons.folder_open,
              title: l10n.medicalRecords,
              subtitle: l10n.medicalRecordsSubtitle,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientRecords(),
                  ),
                );
              },
            ),

            _buildActionCard(
              icon: Icons.history_edu,
              title: l10n.medicalHistory,
              subtitle: l10n.medicalHistorySubtitle,
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientMedicalHistory(),
                  ),
                );
              },
            ),

            _buildActionCard(
              icon: Icons.calendar_today,
              title: l10n.myAppointments,
              subtitle: l10n.myAppointmentsSubtitle,
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientAppointments(),
                  ),
                );
              },
            ),

            _buildActionCard(
              icon: Icons.medication,
              title: l10n.prescriptionsAndMedicines,
              subtitle: l10n.prescriptionsSubtitle,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientPrescriptions(),
                  ),
                );
              },
            ),

            _buildActionCard(
              icon: Icons.science,
              title: l10n.labAndDiagnosticReports,
              subtitle: l10n.labReportsSubtitle,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientLabReports(),
                  ),
                );
              },
            ),

            _buildActionCard(
              icon: Icons.person_outline,
              title: l10n.myProfile,
              subtitle: l10n.myProfileSubtitle,
              color: Colors.indigo,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientProfile(),
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
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: Text(
                  l10n.logout,
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
    );
  }
}