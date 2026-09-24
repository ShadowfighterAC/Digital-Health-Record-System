import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';

class ChooseDoctorScreen extends StatefulWidget {
  const ChooseDoctorScreen({super.key});

  @override
  State<ChooseDoctorScreen> createState() => _ChooseDoctorScreenState();
}

class _ChooseDoctorScreenState extends State<ChooseDoctorScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _currentDoctorId;
  bool _loadingCurrentDoctor = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentDoctor();
  }

  Future<void> _loadCurrentDoctor() async {
    final user = _auth.currentUser;

    if (user == null) {
      setState(() {
        _loadingCurrentDoctor = false;
      });
      return;
    }

    try {
      final userData = await _firestoreService.getUser(user.uid);

      if (!mounted) return;

      setState(() {
        _currentDoctorId = userData?['currentDoctorId'];
        _loadingCurrentDoctor = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingCurrentDoctor = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load current doctor: $e'),
        ),
      );
    }
  }

  Future<void> _selectDoctor(UserModel doctor) async {
    final patient = _auth.currentUser;

    if (patient == null) {
      return;
    }

    final l10n = context.l10n;
    final isChangingDoctor =
        _currentDoctorId != null && _currentDoctorId != doctor.uid;

    if (isChangingDoctor) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(l10n.changeDoctorPrompt),
            content: Text(l10n.changeDoctorWarning),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.change),
              ),
            ],
          );
        },
      );

      if (confirmed != true) {
        return;
      }
    }

    setState(() {
      _saving = true;
    });

    try {
      await _firestoreService.updateCurrentDoctor(
        patient.uid,
        doctor.uid,
      );

      if (!mounted) return;

      setState(() {
        _currentDoctorId = doctor.uid;
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${doctor.name} selected as your doctor.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select doctor: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chooseDoctor),
      ),
      body: _loadingCurrentDoctor
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder<List<UserModel>>(
              stream: _firestoreService.getDoctors(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '${l10n.failedToLoadDoctors}\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final doctors = snapshot.data ?? [];

                if (doctors.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noDoctorsRegistered,
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        final doctor = doctors[index];
                        final isSelected = _currentDoctorId == doctor.uid;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                doctor.name.isNotEmpty
                                    ? doctor.name[0].toUpperCase()
                                    : 'D',
                              ),
                            ),
                            title: Text(
                              doctor.name.isNotEmpty
                                  ? doctor.name
                                  : l10n.doctor,
                            ),
                            subtitle: Text(doctor.email),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : ElevatedButton(
                                    onPressed: _saving
                                        ? null
                                        : () => _selectDoctor(doctor),
                                    child: Text(
                                      _currentDoctorId == null
                                          ? l10n.select
                                          : l10n.change,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    if (_saving)
                      const Positioned.fill(
                        child: ColoredBox(
                          color: Color(0x33000000),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}