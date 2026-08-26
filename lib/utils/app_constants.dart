class AppConstants {
  AppConstants._();

  // Firestore Collections
  static const String usersCollection = "users";
  static const String medicalRecordsCollection = "medical_records";
  static const String appointmentsCollection = "appointments";
  static const String prescriptionsCollection = "prescriptions";
  static const String labReportsCollection = "lab_reports";

  // User Roles
  static const String roleDoctor = "Doctor";
  static const String rolePatient = "Patient";

  // Appointment Statuses
  static const String statusScheduled = "Scheduled";
  static const String statusCompleted = "Completed";
  static const String statusCancelled = "Cancelled";

  static const List<String> appointmentStatuses = [
    statusScheduled,
    statusCompleted,
    statusCancelled,
  ];

  // Common Medicine Frequencies
  static const List<String> medicineFrequencies = [
    "Once daily (OD)",
    "Twice daily (BD)",
    "Thrice daily (TDS)",
    "Four times daily (QDS)",
    "Every 4 hours",
    "Every 6 hours",
    "Every 8 hours",
    "As needed (PRN)",
    "Before meals (AC)",
    "After meals (PC)",
    "At bedtime (HS)",
  ];

  // Common Lab Tests
  static const List<String> commonLabTests = [
    "Complete Blood Count (CBC)",
    "Lipid Profile",
    "Liver Function Test (LFT)",
    "Kidney Function Test (KFT)",
    "Blood Glucose (Fasting)",
    "Blood Glucose (Post Prandial)",
    "HbA1c",
    "Thyroid Profile (T3, T4, TSH)",
    "Urine Routine & Microscopy",
    "Serum Electrolytes",
    "Chest X-Ray",
    "ECG / EKG",
  ];
}
