import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    final instance = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return instance ?? AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  bool get isMarathi => locale.languageCode == 'mr';

  // ─────────────────────────────────────────────────────────────────────────
  // General & Common
  // ─────────────────────────────────────────────────────────────────────────
  String get appTitle => isMarathi ? "डिजिटल आरोग्य नोंद प्रणाली" : "Digital Health Record System";
  String get ok => isMarathi ? "ठीक आहे" : "OK";
  String get cancel => isMarathi ? "रद्द करा" : "Cancel";
  String get save => isMarathi ? "जतन करा" : "Save";
  String get delete => isMarathi ? "हटवा" : "Delete";
  String get edit => isMarathi ? "संपादित करा" : "Edit";
  String get change => isMarathi ? "बदला" : "Change";
  String get select => isMarathi ? "निवडा" : "Select";
  String get search => isMarathi ? "शोधा" : "Search";
  String get close => isMarathi ? "बंद करा" : "Close";
  String get back => isMarathi ? "मागे" : "Back";
  String get retry => isMarathi ? "पुन्हा प्रयत्न करा" : "Retry";
  String get loading => isMarathi ? "लोड होत आहे..." : "Loading...";
  String get requiredField => isMarathi ? "आवश्यक" : "Required";
  String get optional => isMarathi ? "पर्यायी" : "Optional";
  String get notSpecified => isMarathi ? "नमूद केलेले नाही" : "Not specified";
  String get language => isMarathi ? "भाषा" : "Language";
  String get selectLanguage => isMarathi ? "भाषा निवडा" : "Select Language";
  String get chooseLanguagePrompt =>
      isMarathi ? "तुमची पसंतीची भाषा निवडा" : "Choose your preferred language";
  String get english => "English";
  String get marathi => "मराठी";

  // ─────────────────────────────────────────────────────────────────────────
  // Authentication (Login & Register)
  // ─────────────────────────────────────────────────────────────────────────
  String get login => isMarathi ? "लॉग इन" : "Login";
  String get register => isMarathi ? "नोंदणी करा" : "Register";
  String get createAccount => isMarathi ? "नवीन खाते तयार करा" : "Create Account";
  String get createYourAccount => isMarathi ? "तुमचे खाते तयार करा" : "Create Your Account";
  String get email => isMarathi ? "ईमेल" : "Email";
  String get emailAddress => isMarathi ? "ईमेल पत्ता" : "Email Address";
  String get enterEmail => isMarathi ? "तुमचा ईमेल टाका" : "Enter your email";
  String get enterEmailAddress => isMarathi ? "ईमेल पत्ता टाका" : "Enter email address";
  String get password => isMarathi ? "पासवर्ड" : "Password";
  String get enterPassword => isMarathi ? "तुमचा पासवर्ड टाका" : "Enter your password";
  String get createPasswordHint =>
      isMarathi ? "पासवर्ड तयार करा (किमान ६ अक्षरे)" : "Create password (min 6 chars)";
  String get confirmPassword => isMarathi ? "पासवर्डची पुष्टी करा" : "Confirm Password";
  String get reenterPasswordHint => isMarathi ? "पासवर्ड पुन्हा टाका" : "Re-enter password";
  String get fullName => isMarathi ? "पूर्ण नाव" : "Full Name";
  String get enterFullName => isMarathi ? "पूर्ण नाव टाका" : "Enter full name";
  String get selectRole => isMarathi ? "भूमिका निवडा" : "Select Role";
  String get patient => isMarathi ? "रुग्ण" : "Patient";
  String get doctor => isMarathi ? "डॉक्टर" : "Doctor";
  String get accessHealthRecords => isMarathi ? "आरोग्य नोंदी पहा" : "Access Health Records";
  String get managePatients => isMarathi ? "रुग्णांचे व्यवस्थापन करा" : "Manage Patients";
  String get dontHaveAccount => isMarathi ? "खाते नाही का?" : "Don't have an account?";
  String get alreadyHaveAccount =>
      isMarathi ? "आधीच खाते आहे? लॉग इन करा" : "Already have an account? Login";
  String get secureMedicalRecords => isMarathi ? "सुरक्षित वैद्यकीय नोंदी" : "Secure Medical Records";
  String get manageRecordsSecurely =>
      isMarathi ? "तुमच्या आरोग्य नोंदी सुरक्षितपणे ठेवा" : "Manage your health records securely";
  String get pleaseEnterEmailPassword =>
      isMarathi ? "कृपया ईमेल आणि पासवर्ड टाका" : "Please enter email and password";
  String get pleaseFillAllFields => isMarathi ? "कृपया सर्व माहिती भरा" : "Please fill all fields";
  String get pleaseEnterValidEmail =>
      isMarathi ? "कृपया वैध ईमेल पत्ता टाका" : "Please enter a valid email address";
  String get passwordsDoNotMatch => isMarathi ? "पासवर्ड जुळत नाहीत" : "Passwords do not match";
  String get passwordMinLength =>
      isMarathi ? "पासवर्ड किमान ६ अक्षरांचा असावा" : "Password must be at least 6 characters";
  String get accountCreatedSuccess => isMarathi
      ? "खाते यशस्वीरित्या तयार झाले! कृपया लॉग इन करा."
      : "Account created successfully! Please login.";
  String get confirmLogout => isMarathi ? "लॉग आउट खात्री करा" : "Confirm Logout";
  String get confirmLogoutPrompt =>
      isMarathi ? "तुम्हाला नक्की लॉग आउट करायचे आहे का?" : "Are you sure you want to sign out?";
  String get confirmLogoutDoctorPrompt => isMarathi
      ? "तुम्हाला नक्की डॉक्टर डॅशबोर्डमधून बाहेर पडायचे आहे का?"
      : "Are you sure you want to log out of Doctor Dashboard?";
  String get logout => isMarathi ? "लॉग आउट" : "Logout";

  // ─────────────────────────────────────────────────────────────────────────
  // Patient Dashboard & Navigation
  // ─────────────────────────────────────────────────────────────────────────
  String get patientDashboard => isMarathi ? "रुग्ण डॅशबोर्ड" : "Patient Dashboard";
  String get welcome => isMarathi ? "स्वागत आहे" : "Welcome";
  String get personalPortalSubtitle =>
      isMarathi ? "तुमचे वैयक्तिक आरोग्य नोंद पोर्टल" : "Your Personal Health Records Portal";
  String get healthSummary => isMarathi ? "आरोग्य सारांश" : "Health Summary";
  String get myHealthHub => isMarathi ? "माझे आरोग्य केंद्र" : "My Health Hub";
  String get myDoctor => isMarathi ? "माझे डॉक्टर" : "My Doctor";
  String get myDoctorSubtitle =>
      isMarathi ? "तुमचे नियुक्त डॉक्टर निवडा किंवा बदला" : "Choose or change your assigned doctor";
  String get medicalRecords => isMarathi ? "वैद्यकीय नोंदी" : "Medical Records";
  String get medicalRecordsSubtitle => isMarathi
      ? "निदान इतिहास आणि डॉक्टर भेटीच्या नोंदी पहा"
      : "View diagnosis history and doctor visit notes";
  String get medicalHistory => isMarathi ? "वैद्यकीय इतिहास" : "Medical History";
  String get medicalHistorySubtitle => isMarathi
      ? "मागील आजार, शस्त्रक्रिया, परिस्थिती आणि ॲलर्जी"
      : "Previous diagnoses, surgeries, conditions, and allergies";
  String get myAppointments => isMarathi ? "माझ्या अपॉइंटमेंट्स" : "My Appointments";
  String get myAppointmentsSubtitle =>
      isMarathi ? "पुढील आणि मागील भेटीच्या तारखा पहा" : "Check upcoming and past consultation dates";
  String get prescriptionsAndMedicines =>
      isMarathi ? "प्रिस्क्रिप्शन आणि औषधे" : "Prescriptions & Medicines";
  String get prescriptionsSubtitle => isMarathi
      ? "चालू औषधे, डोस आणि डॉक्टरांचा सल्ला"
      : "Active medicines, dosages, and doctor advice";
  String get labAndDiagnosticReports =>
      isMarathi ? "लॅब आणि तपासणी अहवाल" : "Lab & Diagnostic Reports";
  String get labReportsSubtitle => isMarathi
      ? "चाचणी निकाल आणि डॉक्टरांचे अभिप्राय तपासा"
      : "Review clinical test results and remarks";
  String get myProfile => isMarathi ? "माझी प्रोफाइल" : "My Profile";
  String get myProfileSubtitle =>
      isMarathi ? "खात्याचा तपशील आणि वैयक्तिक माहिती" : "Account details and personal information";
  String get noRecordsYet =>
      isMarathi ? "अद्याप कोणत्याही वैद्यकीय नोंदी नाहीत" : "No Medical Records Yet";
  String get recordsAppearHere =>
      isMarathi ? "तुमच्या वैद्यकीय नोंदी येथे दिसतील." : "Your medical records will appear here.";
  String get noPrescriptionsFound =>
      isMarathi ? "प्रिस्क्रिप्शन सापडले नाही" : "No Prescriptions Found";
  String get prescriptionsAppearHere => isMarathi
      ? "तुमची लिहून दिलेली औषधे येथे दिसतील."
      : "Your prescribed medicines will appear here.";
  String get noLabReportsFound => isMarathi ? "लॅब अहवाल सापडले नाहीत" : "No Lab Reports Found";
  String get labReportsAppearHere => isMarathi
      ? "तपासणी आणि प्रयोगशाळेचे अहवाल येथे दिसतील."
      : "Diagnostic and laboratory reports will appear here.";
  String get noAppointmentsFound =>
      isMarathi ? "कोणतीही अपॉइंटमेंट आढळली नाही" : "No Appointments Found";
  String get bookAppointmentWithDoctor => isMarathi
      ? "तुमच्या नियुक्त डॉक्टरांकडे अपॉइंटमेंट बुक करा."
      : "Book an appointment with your assigned doctor.";
  String get bookAppointment => isMarathi ? "अपॉइंटमेंट बुक करा" : "Book Appointment";
  String get noMedicalHistoryRecorded =>
      isMarathi ? "वैद्यकीय इतिहास नोंदवलेला नाही" : "No Medical History Recorded";
  String get medicalHistoryAppearHere => isMarathi
      ? "मागील आजार, शस्त्रक्रिया आणि ॲलर्जी डॉक्टरांनी नोंदवल्यानंतर येथे दिसतील."
      : "Your past diagnoses, surgeries, and allergies\nwill appear here once recorded by your doctor.";
  String get pleaseSignInRecords => isMarathi
      ? "वैद्यकीय नोंदी पाहण्यासाठी कृपया साइन इन करा."
      : "Please sign in to view records.";
  String get pleaseSignInLab => isMarathi
      ? "लॅब अहवाल पाहण्यासाठी कृपया साइन इन करा."
      : "Please sign in to view lab reports.";
  String get pleaseSignInHistory => isMarathi
      ? "वैद्यकीय इतिहास पाहण्यासाठी कृपया साइन इन करा."
      : "Please sign in to view your medical history.";
  String get somethingWentWrong =>
      isMarathi ? "काहीतरी चूक झाली." : "Something went wrong.";

  // ─────────────────────────────────────────────────────────────────────────
  // Doctor Dashboard & Clinic Management
  // ─────────────────────────────────────────────────────────────────────────
  String get doctorDashboard => isMarathi ? "डॉक्टर डॅशबोर्ड" : "Doctor Dashboard";
  String get welcomeDoctor => isMarathi ? "स्वागत आहे डॉक्टर" : "Welcome Doctor";
  String get doctorSubtitle => isMarathi
      ? "इलेक्ट्रॉनिक आरोग्य नोंदी आणि रुग्ण सेवा"
      : "Electronic Health Records & Patient Care";
  String get clinicOverview => isMarathi ? "दवाखाना सारांश" : "Clinic Overview";
  String get patients => isMarathi ? "रुग्ण" : "Patients";
  String get records => isMarathi ? "नोंदी" : "Records";
  String get prescriptions => isMarathi ? "प्रिस्क्रिप्शन" : "Prescriptions";
  String get labReports => isMarathi ? "लॅब अहवाल" : "Lab Reports";
  String get appointments => isMarathi ? "अपॉइंटमेंट्स" : "Appointments";
  String get managementAndFeatures =>
      isMarathi ? "व्यवस्थापन आणि सुविधा" : "Management & Features";
  String get patientsDirectory => isMarathi ? "रुग्ण निर्देशिका" : "Patients Directory";
  String get patientsDirectorySubtitle =>
      isMarathi ? "सर्व रुग्ण आणि त्यांचा वैद्यकीय इतिहास पहा" : "View all patients and individual EHR history";
  String get appointmentsManager =>
      isMarathi ? "अपॉइंटमेंट व्यवस्थापक" : "Appointments Manager";
  String get appointmentsManagerSubtitle =>
      isMarathi ? "अपॉइंटमेंट्स व्यवस्थापित किंवा पूर्ण करा" : "Manage, reschedule, or complete appointments";
  String get prescriptionsManagerSubtitle =>
      isMarathi ? "रुग्णांसाठी प्रिस्क्रिप्शन तयार करा आणि तपासा" : "Issue and review patient prescriptions";
  String get labReportsManagerSubtitle =>
      isMarathi ? "चाचणी निष्कर्ष नोंदवा आणि तपासा" : "Record and review diagnostic test findings";
  String get medicalHistoryManagerSubtitle => isMarathi
      ? "मागील आजार, शस्त्रक्रिया, परिस्थिती व फाईल्स तपासा"
      : "Review diagnoses, surgeries, conditions & document files";
  String get addMedicalRecord => isMarathi ? "वैद्यकीय नोंद जोडा" : "Add Medical Record";
  String get addMedicalRecordSubtitle => isMarathi
      ? "निदान आणि उपचार नोंदवण्यासाठी रुग्ण निवडा"
      : "Select a patient to document diagnosis & treatment";
  String get doctorProfileSettingsSubtitle =>
      isMarathi ? "डॉक्टर ओळखपत्र आणि सेटिंग्ज पहा" : "View doctor credentials and settings";
  String get newPrescription => isMarathi ? "नवीन प्रिस्क्रिप्शन" : "New Prescription";
  String get newLabReport => isMarathi ? "नवीन लॅब अहवाल" : "New Lab Report";
  String get addHistory => isMarathi ? "इतिहास जोडा" : "Add History";
  String get schedule => isMarathi ? "नियोजन करा" : "Schedule";
  String get scheduleAppointment => isMarathi ? "अपॉइंटमेंट निश्चित करा" : "Schedule Appointment";

  // ─────────────────────────────────────────────────────────────────────────
  // Patient Directory & Selection
  // ─────────────────────────────────────────────────────────────────────────
  String get searchPatientsHint => isMarathi
      ? "नाव किंवा ईमेलने रुग्ण शोधा..."
      : "Search patients by name or email...";
  String get noPatientsAssigned => isMarathi ? "कोणतेही रुग्ण नियुक्त नाहीत" : "No Patients Assigned";
  String get patientsAssignPrompt => isMarathi
      ? "रुग्णांनी तुम्हाला डॉक्टर म्हणून निवडल्यानंतर ते येथे दिसतील."
      : "Patients will appear here after they select you as their doctor.";
  String get noPatientsFound => isMarathi ? "रुग्ण सापडले नाहीत" : "No Patients Found";
  String get tryAdjustingSearch =>
      isMarathi ? "कृपया शोध निकष बदलून पुन्हा प्रयत्न करा." : "Try adjusting your search criteria.";
  String get selectPatientAppointment =>
      isMarathi ? "रुग्ण निवडा (अपॉइंटमेंट)" : "Select Patient (Appointment)";
  String get selectPatientRecord =>
      isMarathi ? "रुग्ण निवडा (वैद्यकीय नोंद)" : "Select Patient (Medical Record)";
  String get selectPatientHistory =>
      isMarathi ? "रुग्ण निवडा (वैद्यकीय इतिहास)" : "Select Patient (Medical History)";
  String get selectPatientPrescription =>
      isMarathi ? "रुग्ण निवडा (प्रिस्क्रिप्शन)" : "Select Patient (Prescription)";
  String get selectPatientLab =>
      isMarathi ? "रुग्ण निवडा (लॅब अहवाल)" : "Select Patient (Lab Report)";
  String get selectedPatient => isMarathi ? "निवडलेला रुग्ण" : "Selected Patient";
  String get tabRecords => isMarathi ? "नोंदी" : "Records";
  String get tabHistory => isMarathi ? "इतिहास" : "History";
  String get tabPrescriptions => isMarathi ? "प्रिस्क्रिप्शन" : "Prescriptions";
  String get tabLabTests => isMarathi ? "लॅब चाचण्या" : "Lab Tests";
  String get tabAppointments => isMarathi ? "अपॉइंटमेंट्स" : "Appointments";
  String get addRecordShort => isMarathi ? "+ नोंद" : "+ Record";
  String get addHistoryShort => isMarathi ? "+ इतिहास" : "+ History";
  String get addRxShort => isMarathi ? "+ औषध" : "+ Rx";
  String get addLabShort => isMarathi ? "+ लॅब" : "+ Lab";
  String get addApptShort => isMarathi ? "+ भेट" : "+ Appt";

  // ─────────────────────────────────────────────────────────────────────────
  // Choose Doctor Screen
  // ─────────────────────────────────────────────────────────────────────────
  String get chooseDoctor => isMarathi ? "डॉक्टर निवडा" : "Choose Doctor";
  String get changeDoctorPrompt => isMarathi ? "डॉक्टर बदलायचे आहेत का?" : "Change Doctor?";
  String get changeDoctorWarning => isMarathi
      ? "डॉक्टर बदलल्याने तुमच्या आरोग्य नोंदी कोण पाहू शकते ते बदलेल."
      : "Changing your doctor will change which doctor can access your EHR.";
  String get noDoctorsRegistered =>
      isMarathi ? "सध्या कोणतेही डॉक्टर नोंदणीकृत नाहीत." : "No doctors are currently registered.";
  String get failedToLoadDoctors =>
      isMarathi ? "डॉक्टरांची माहिती लोड होऊ शकली नाही." : "Failed to load doctors.";

  // ─────────────────────────────────────────────────────────────────────────
  // Appointments
  // ─────────────────────────────────────────────────────────────────────────
  String get appointmentManager =>
      isMarathi ? "अपॉइंटमेंट व्यवस्थापक" : "Appointment Manager";
  String get appointmentDate => isMarathi ? "भेटीची तारीख" : "Appointment Date";
  String get appointmentTime => isMarathi ? "भेटीची वेळ" : "Appointment Time";
  String get reasonForVisit => isMarathi ? "भेटीचे कारण" : "Reason for Visit";
  String get enterReasonHint =>
      isMarathi ? "अपॉइंटमेंटचे कारण लिहा" : "Enter the reason for your appointment";
  String get selectDate => isMarathi ? "तारीख निवडा" : "Select a date";
  String get selectTime => isMarathi ? "वेळ निवडा" : "Select a time";
  String get cancelAppointment => isMarathi ? "अपॉइंटमेंट रद्द करा" : "Cancel Appointment";
  String get keepAppointment => isMarathi ? "अपॉइंटमेंट चालू ठेवा" : "Keep Appointment";
  String get cancelAppointmentPrompt => isMarathi
      ? "तुम्हाला नक्की ही अपॉइंटमेंट रद्द करायची आहे का?"
      : "Are you sure you want to cancel this appointment?";
  String get updateAppointmentStatus =>
      isMarathi ? "अपॉइंटमेंट स्थिती बदला" : "Update Appointment Status";
  String get deleteAppointment => isMarathi ? "अपॉइंटमेंट हटवा" : "Delete Appointment";
  String get deleteAppointmentPrompt => isMarathi
      ? "तुम्हाला ही अपॉइंटमेंट नक्की हटवायची आहे का?"
      : "Are you sure you want to delete this appointment?";
  String get appointmentBookedSuccess =>
      isMarathi ? "अपॉइंटमेंट यशस्वीरित्या बुक झाली" : "Appointment booked successfully";
  String get appointmentCancelled =>
      isMarathi ? "अपॉइंटमेंट रद्द करण्यात आली" : "Appointment cancelled";
  String get appointmentDeleted =>
      isMarathi ? "अपॉइंटमेंट हटवली गेली" : "Appointment deleted";
  String get appointmentCreatedSuccess =>
      isMarathi ? "अपॉइंटमेंट यशस्वीरित्या तयार झाली" : "Appointment Created Successfully";
  String get pleaseFillDateTimeReason => isMarathi
      ? "कृपया तारीख, वेळ निवडा आणि कारण टाका."
      : "Please select a date, time and enter a reason.";
  String get all => isMarathi ? "सर्व" : "All";
  String get scheduled => isMarathi ? "नियोजित" : "Scheduled";
  String get completed => isMarathi ? "पूर्ण झाले" : "Completed";
  String get cancelled => isMarathi ? "रद्द केले" : "Cancelled";

  // ─────────────────────────────────────────────────────────────────────────
  // Medical Records Form & Details
  // ─────────────────────────────────────────────────────────────────────────
  String get diagnosis => isMarathi ? "निदान" : "Diagnosis";
  String get prescriptionTreatmentPlan =>
      isMarathi ? "प्रिस्क्रिप्शन / उपचार योजना" : "Prescription / Treatment Plan";
  String get doctorNotesRemarks =>
      isMarathi ? "डॉक्टरांच्या नोंदी व शेरा" : "Doctor Notes & Remarks";
  String get visitDate => isMarathi ? "भेटीची तारीख" : "Visit Date";
  String get saveMedicalRecord => isMarathi ? "वैद्यकीय नोंद जतन करा" : "Save Medical Record";
  String get uploadingAndSaving => isMarathi ? "अपलोड व जतन होत आहे..." : "Uploading & Saving...";
  String get medicalRecordAddedSuccess =>
      isMarathi ? "वैद्यकीय नोंद यशस्वीरित्या जोडली गेली" : "Medical Record Added Successfully";

  // ─────────────────────────────────────────────────────────────────────────
  // Medical History Form & Details
  // ─────────────────────────────────────────────────────────────────────────
  String get titleCondition => isMarathi ? "शीर्षक / आजार" : "Title / Condition";
  String get titleConditionHint => isMarathi
      ? "उदा. प्रकार २ मधुमेह, अपेंडिक्स शस्त्रक्रिया, ॲलर्जी"
      : "e.g. Type 2 Diabetes, Appendectomy, Penicillin Allergy";
  String get recordingDoctor => isMarathi ? "नोंद करणारे डॉक्टर" : "Recording Doctor";
  String get historyCategory => isMarathi ? "इतिहास श्रेणी" : "History Category";
  String get occurrenceDiagnosisDate =>
      isMarathi ? "आजार उद्भवल्याची / निदानाची तारीख" : "Occurrence / Diagnosis Date";
  String get descriptionPastTreatment =>
      isMarathi ? "तपशील आणि मागील उपचार" : "Description & Past Treatment";
  String get descriptionPastTreatmentHint => isMarathi
      ? "लक्षणे, मागील उपचार, शस्त्रक्रिया किंवा औषधांविषयी तपशील..."
      : "Details about symptoms, prior treatment, surgeries, hospitalizations, or medications...";
  String get doctorRemarksNotes => isMarathi ? "डॉक्टरांचा शेरा / नोंदी" : "Doctor Notes / Remarks";
  String get doctorRemarksNotesHint => isMarathi
      ? "वैद्यकीय निरीक्षणे, सूचना किंवा इशारे..."
      : "Clinical observations, follow-up instructions, or warnings...";
  String get saveMedicalHistory => isMarathi ? "वैद्यकीय इतिहास जतन करा" : "Save Medical History";
  String get deleteMedicalHistory => isMarathi ? "वैद्यकीय इतिहास हटवा" : "Delete Medical History";
  String get deleteHistoryPrompt => isMarathi
      ? "तुम्हाला ही वैद्यकीय नोंद आणि त्यासोबतची कागदपत्रे नक्की हटवायची आहेत का? ही क्रिया पूर्ववत करता येणार नाही."
      : "Are you sure you want to delete this medical history entry and its attachments? This action cannot be undone.";
  String get medicalHistoryAddedSuccess =>
      isMarathi ? "वैद्यकीय इतिहास यशस्वीरित्या जोडला गेला!" : "Medical History added successfully!";
  String get medicalHistoryDeleted =>
      isMarathi ? "वैद्यकीय इतिहास हटवला गेला" : "Medical history entry deleted";

  // ─────────────────────────────────────────────────────────────────────────
  // Prescriptions Form & Details
  // ─────────────────────────────────────────────────────────────────────────
  String get createPrescription => isMarathi ? "प्रिस्क्रिप्शन तयार करा" : "Create Prescription";
  String get prescriptionDetails => isMarathi ? "प्रिस्क्रिप्शन तपशील" : "Prescription Details";
  String get doctorPrescriberName =>
      isMarathi ? "डॉक्टर / प्रिस्क्राइबरचे नाव" : "Doctor / Prescriber Name";
  String get prescriptionDate => isMarathi ? "प्रिस्क्रिप्शन तारीख" : "Prescription Date";
  String get prescribedMedicines => isMarathi ? "दिलेली औषधे" : "Prescribed Medicines";
  String get addMedicine => isMarathi ? "औषध जोडा" : "Add Medicine";
  String get medicine => isMarathi ? "औषध" : "Medicine";
  String get medicineName => isMarathi ? "औषधाचे नाव" : "Medicine Name";
  String get dosage => isMarathi ? "डोस" : "Dosage";
  String get frequency => isMarathi ? "वारंवारता / वेळा" : "Frequency";
  String get duration => isMarathi ? "कालावधी" : "Duration";
  String get instructionsOptional => isMarathi ? "सूचना (पर्यायी)" : "Instructions (optional)";
  String get instructionsHint =>
      isMarathi ? "उदा. जेवणानंतर कोमट पाण्यासोबत घ्या" : "e.g., Take after meals with warm water";
  String get doctorsAdviceNotes =>
      isMarathi ? "डॉक्टरांचा सल्ला आणि अतिरिक्त नोंदी" : "Doctor's Advice & Additional Notes";
  String get adviceHint =>
      isMarathi ? "उदा. भरपूर पाणी प्या आणि विश्रांती घ्या." : "e.g. Drink plenty of water and rest well.";
  String get saveAndIssuePrescription =>
      isMarathi ? "प्रिस्क्रिप्शन जतन व जारी करा" : "Save & Issue Prescription";
  String get deletePrescription => isMarathi ? "प्रिस्क्रिप्शन हटवा" : "Delete Prescription";
  String get deletePrescriptionPrompt => isMarathi
      ? "तुम्हाला हे प्रिस्क्रिप्शन नक्की हटवायचे आहे का? ही क्रिया पूर्ववत करता येणार नाही."
      : "Are you sure you want to delete this prescription? This action cannot be undone.";
  String get prescriptionSavedSuccess =>
      isMarathi ? "प्रिस्क्रिप्शन यशस्वीरित्या जतन झाले!" : "Prescription saved successfully!";
  String get prescriptionDeleted => isMarathi ? "प्रिस्क्रिप्शन हटवले गेले" : "Prescription deleted";
  String get prescriptionMustHaveOneMed => isMarathi
      ? "प्रिस्क्रिप्शनमध्ये किमान एक औषध असणे आवश्यक आहे"
      : "A prescription must have at least one medicine";

  // ─────────────────────────────────────────────────────────────────────────
  // Lab Reports Form & Details
  // ─────────────────────────────────────────────────────────────────────────
  String get referringOrderingDoctor =>
      isMarathi ? "तपासणी सांगणारे डॉक्टर" : "Referring / Ordering Doctor";
  String get quickSelectTest => isMarathi ? "चाचणी पटकन निवडा:" : "Quick Select Test:";
  String get testName => isMarathi ? "चाचणीचे नाव" : "Test Name";
  String get testNameHint =>
      isMarathi ? "उदा. कम्प्लीट ब्लड काउन्ट (CBC)" : "e.g., Complete Blood Count (CBC)";
  String get resultFinding => isMarathi ? "निकाल / निष्कर्ष" : "Result / Finding";
  String get resultFindingHint =>
      isMarathi ? "उदा. Hb: 13.5 g/dL, WBC: 7,500 /mcL" : "e.g., Hb: 13.5 g/dL, WBC: 7,500 /mcL";
  String get referenceRangeNormal =>
      isMarathi ? "संदर्भ मर्यादा / सामान्य प्रमाण" : "Reference Range / Normal Value";
  String get referenceRangeHint =>
      isMarathi ? "उदा. Hb: 12.0 - 15.5 g/dL" : "e.g., Hb: 12.0 - 15.5 g/dL";
  String get doctorRemarksClinicalNotes =>
      isMarathi ? "डॉक्टरांचे अभिप्राय / वैद्यकीय शेरा" : "Doctor Remarks / Clinical Notes";
  String get doctorRemarksHint =>
      isMarathi ? "उदा. सर्व चाचण्या सामान्य मर्यादेत आहेत." : "e.g., Results are within normal limits.";
  String get reportDate => isMarathi ? "अहवाल तारीख" : "Report Date";
  String get saveLabReport => isMarathi ? "लॅब अहवाल जतन करा" : "Save Lab Report";
  String get deleteLabReport => isMarathi ? "लॅब अहवाल हटवा" : "Delete Lab Report";
  String get deleteLabReportPrompt => isMarathi
      ? "तुम्हाला हा लॅब अहवाल नक्की हटवायचा आहे का? ही क्रिया पूर्ववत करता येणार नाही."
      : "Are you sure you want to delete this lab report? This action cannot be undone.";
  String get labReportSavedSuccess =>
      isMarathi ? "लॅब अहवाल यशस्वीरित्या जतन झाला!" : "Lab Report saved successfully!";
  String get labReportDeleted => isMarathi ? "लॅब अहवाल हटवला गेला" : "Lab report deleted";

  // ─────────────────────────────────────────────────────────────────────────
  // Attachments & Viewers
  // ─────────────────────────────────────────────────────────────────────────
  String get documentAttachments => isMarathi ? "दस्तऐवज / फाईल्स" : "Document Attachments";
  String get attached => isMarathi ? "जोडले" : "attached";
  String get photoLimit => isMarathi ? "फोटो (≤10MB)" : "Photo (≤10MB)";
  String get pdfLimit => isMarathi ? "पीडीएफ (≤20MB)" : "PDF (≤20MB)";
  String get attachPhoto => isMarathi ? "फोटो जोडा" : "Attach Photo";
  String get takePhotoCamera => isMarathi ? "कॅमेऱ्याने फोटो काढा" : "Take Photo (Camera)";
  String get chooseFromGallery => isMarathi ? "गॅलरीमधून निवडा" : "Choose from Gallery";
  String get openPdf => isMarathi ? "पीडीएफ उघडा" : "Open PDF";
  String get openingPdf => isMarathi ? "पीडीएफ उघडत आहे..." : "Opening PDF...";
  String get failedToLoadImage => isMarathi ? "फोटो लोड होऊ शकला नाही" : "Failed to load image";
  String get loadingSecureImage =>
      isMarathi ? "सुरक्षित फोटो लोड होत आहे..." : "Loading secure image...";
  String get couldNotLaunchPdf => isMarathi
      ? "या डिव्हाइसवर बाह्य पीडीएफ व्ह्यूअर उघडू शकलो नाही."
      : "Could not launch external PDF viewer on this device.";

  // ─────────────────────────────────────────────────────────────────────────
  // Profile Screen
  // ─────────────────────────────────────────────────────────────────────────
  String get editProfileName => isMarathi ? "नाव संपादित करा" : "Edit Profile Name";
  String get editDoctorName => isMarathi ? "डॉक्टरचे नाव संपादित करा" : "Edit Doctor Name";
  String get systemRole => isMarathi ? "प्रणालीतील भूमिका" : "System Role";
  String get role => isMarathi ? "भूमिका" : "Role";
  String get nameUpdatedSuccess =>
      isMarathi ? "नाव यशस्वीरित्या अद्ययावत केले" : "Name updated successfully";
  String get profileUpdatedSuccess =>
      isMarathi ? "प्रोफाइल यशस्वीरित्या अद्ययावत केली" : "Profile updated successfully";

  // Additional Common / Doctor / Patient Helpers
  String get noAppointments => isMarathi ? "कोणतीही अपॉइंटमेंट नाही" : "No Appointments";
  String get appointmentsAppearHere => isMarathi
      ? "तुमच्या रुग्णांच्या अपॉइंटमेंट्स येथे दिसतील."
      : "Appointments for your assigned patients will appear here.";
  String get appointmentsAfterSelectDoctor => isMarathi
      ? "रुग्णांनी तुम्हाला डॉक्टर म्हणून निवडल्यानंतर अपॉइंटमेंट्स येथे दिसतील."
      : "Appointments will appear here after patients select you as their doctor.";
  String get pleaseLogInPatients => isMarathi
      ? "रुग्ण पाहण्यासाठी कृपया पुन्हा लॉग इन करा."
      : "Please log in again to view your patients.";
  String get noRecordsForPatient =>
      isMarathi ? "या रुग्णासाठी कोणतीही वैद्यकीय नोंद नाही." : "No medical records for this patient.";
  String get noHistoryForPatient => isMarathi
      ? "या रुग्णासाठी कोणताही वैद्यकीय इतिहास नोंदवलेला नाही."
      : "No medical history recorded for this patient.";
  String get noPrescriptionsForPatient => isMarathi
      ? "या रुग्णासाठी कोणतेही प्रिस्क्रिप्शन दिलेले नाही."
      : "No prescriptions issued for this patient.";
  String get noLabReportsForPatient => isMarathi
      ? "या रुग्णासाठी कोणतेही लॅब अहवाल सापडले नाहीत."
      : "No lab reports found for this patient.";
  String get noAppointmentsForPatient =>
      isMarathi ? "या रुग्णासाठी कोणतीही अपॉइंटमेंट नाही." : "No appointments for this patient.";
  String get fillRequiredMedicineFields => isMarathi
      ? "कृपया सर्व आवश्यक औषध माहिती भरा"
      : "Please fill all required medicine fields";
  String get noPrescriptionsTitle => isMarathi ? "प्रिस्क्रिप्शन नाहीत" : "No Prescriptions";
  String get prescriptionsForPatientsAppearHere => isMarathi
      ? "तुमच्या रुग्णांसाठी जारी केलेली प्रिस्क्रिप्शन येथे दिसतील."
      : "Prescriptions for your assigned patients will appear here.";
  String get searchPatientDoctorHint => isMarathi
      ? "रुग्ण किंवा डॉक्टरच्या नावाने शोधा..."
      : "Search by patient or doctor name...";
  String get searchPatientTestHint => isMarathi
      ? "रुग्ण किंवा चाचणीच्या नावाने शोधा..."
      : "Search by patient or test name...";
  String get searchHistoryHint => isMarathi
      ? "आजार, शीर्षक किंवा नोंदी शोधा..."
      : "Search condition, title, notes...";
  String get historyAppearForPatients => isMarathi
      ? "तुमच्या रुग्णांचा वैद्यकीय इतिहास येथे दिसेल."
      : "Medical history will appear here for your assigned patients.";
  String get noMedicalHistoryFound =>
      isMarathi ? "वैद्यकीय इतिहास सापडला नाही" : "No Medical History Found";
  String get labReportsAppearForPatients => isMarathi
      ? "तुमच्या रुग्णांचे लॅब अहवाल येथे दिसतील."
      : "Lab reports will appear here for your assigned patients.";
  String get failedToRenderImage =>
      isMarathi ? "फोटो प्रदर्शित करण्यात अयशस्वी" : "Failed to render image content";
  String get removeAttachment => isMarathi ? "काढून टाका" : "Remove attachment";
  String get unableToLoadAppointments =>
      isMarathi ? "अपॉइंटमेंट्स लोड होऊ शकल्या नाहीत." : "Unable to load appointments.";
  String get unableToUpdateStatus =>
      isMarathi ? "अपॉइंटमेंट स्थिती बदलता आली नाही." : "Unable to update appointment status.";
  String get unableToDeleteAppointment =>
      isMarathi ? "अपॉइंटमेंट हटवता आली नाही." : "Unable to delete appointment.";
  String get unableToDeletePrescription =>
      isMarathi ? "प्रिस्क्रिप्शन हटवता आले नाही." : "Unable to delete prescription.";
  String get unableToDeleteLabReport =>
      isMarathi ? "लॅब अहवाल हटवता आला नाही." : "Unable to delete lab report.";
  String get unableToDeleteMedicalHistory =>
      isMarathi ? "वैद्यकीय इतिहास हटवता आला नाही." : "Unable to delete medical history.";
  String get unableToAccessPdf =>
      isMarathi ? "निवडलेली पीडीएफ फाईल उघडता येत नाही." : "Unable to access the selected PDF.";

  String patientLabel(String name) => isMarathi ? "रुग्ण: $name" : "Patient: $name";
  String doctorLabel(String name) => isMarathi ? "डॉक्टर: $name" : "Doctor: $name";
  String medicineNumber(int index) => isMarathi ? "औषध #$index" : "Medicine #$index";
  String itemsCount(int count) => isMarathi ? "$count औषधे" : "$count item(s)";
  String attachedCount(int count) => isMarathi ? "$count जोडले" : "$count attached";
  String appointmentMarked(String st) =>
      isMarathi ? "अपॉइंटमेंट ${translateStatus(st)} म्हणून नोंदवली" : "Appointment marked as $st";
  String prescribedBy(String doctor) =>
      isMarathi ? "डॉक्टरांनी दिलेले: $doctor" : "Prescribed by $doctor";
  String reportedBy(String doctor) =>
      isMarathi ? "अहवाल देणारे: $doctor" : "Reported by: $doctor";
  String recordedBy(String doctor) =>
      isMarathi ? "नोंद करणारे: $doctor" : "Recorded by: $doctor";
  String pleaseEnter(String field) => isMarathi ? "कृपया $field टाका" : "Please enter $field";
  String get notes => isMarathi ? "नोंदी" : "Notes";
  String get advice => isMarathi ? "सल्ला" : "Advice";
  String get result => isMarathi ? "निकाल" : "Result";
  String get normal => isMarathi ? "सामान्य" : "Normal";
  String get remarks => isMarathi ? "शेरा" : "Remarks";
  String get atTime => isMarathi ? "वाजता" : "at";
  String get patientAppointment => isMarathi ? "रुग्ण अपॉइंटमेंट" : "Patient Appointment";
  String get patientRecord => isMarathi ? "रुग्ण नोंद" : "Patient Record";
  String get createAppointment => isMarathi ? "अपॉइंटमेंट तयार करा" : "Create Appointment";
  String get unableToLoadLabReportsPrompt => isMarathi
      ? "लॅब अहवाल लोड करण्यात अयशस्वी.\nतुम्ही फक्त तुम्हाला नियुक्त केलेल्या रुग्णांचे लॅब अहवाल पाहू शकता."
      : "Unable to load lab reports.\nYou can only view lab reports of patients currently assigned to you.";
  String get unableToLoadMedicalHistoryPrompt => isMarathi
      ? "वैद्यकीय इतिहास लोड करण्यात अयशस्वी.\nतुम्ही फक्त तुम्हाला नियुक्त केलेल्या रुग्णांचा वैद्यकीय इतिहास पाहू शकता."
      : "Unable to load medical history.\nYou can only view medical history of patients currently assigned to you.";
  String failedToSave(String item, Object err) =>
      isMarathi ? "$item जतन करण्यात अयशस्वी: $err" : "Failed to save $item: $err";
  String failedToDelete(String item, Object err) =>
      isMarathi ? "$item हटवण्यात अयशस्वी: $err" : "Failed to delete $item: $err";


  // ─────────────────────────────────────────────────────────────────────────
  // Dynamic Helpers (Category, Status, Role, Frequency)
  // ─────────────────────────────────────────────────────────────────────────
  String translateCategory(String category) {
    if (!isMarathi) return category;
    switch (category.toLowerCase()) {
      case 'allergies':
        return "ॲलर्जी";
      case 'previous surgery':
        return "मागील शस्त्रक्रिया";
      case 'hospitalization':
        return "रुग्णालयात दाखल";
      case 'previous diagnosis':
        return "मागील निदान";
      case 'previous treatment':
        return "मागील उपचार";
      case 'existing conditions':
        return "सध्याचे आजार";
      case 'previous medications':
        return "मागील औषधे";
      case 'family history':
        return "कौटुंबिक इतिहास";
      case 'other history':
        return "इतर इतिहास";
      default:
        return category;
    }
  }

  String translateStatus(String status) {
    if (!isMarathi) return status;
    switch (status.toLowerCase()) {
      case 'scheduled':
        return "नियोजित";
      case 'completed':
        return "पूर्ण झाले";
      case 'cancelled':
        return "रद्द केले";
      default:
        return status;
    }
  }

  String translateRole(String role) {
    if (!isMarathi) return role;
    switch (role.toLowerCase()) {
      case 'patient':
        return "रुग्ण";
      case 'doctor':
        return "डॉक्टर";
      default:
        return role;
    }
  }

  String translateFrequency(String frequency) {
    if (!isMarathi) return frequency;
    switch (frequency) {
      case "Once daily (OD)":
        return "दिवसातून एकदा (OD)";
      case "Twice daily (BD)":
        return "दिवसातून दोनदा (BD)";
      case "Thrice daily (TDS)":
        return "दिवसातून तीनदा (TDS)";
      case "Four times daily (QDS)":
        return "दिवसातून चारदा (QDS)";
      case "Every 4 hours":
        return "दर ४ तासांनी";
      case "Every 6 hours":
        return "दर ६ तासांनी";
      case "Every 8 hours":
        return "दर ८ तासांनी";
      case "As needed (PRN)":
        return "गरजेनुसार (PRN)";
      case "Before meals (AC)":
        return "जेवणापूर्वी (AC)";
      case "After meals (PC)":
        return "जेवणानंतर (PC)";
      case "At bedtime (HS)":
        return "झोपताना (HS)";
      default:
        return frequency;
    }
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'mr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
