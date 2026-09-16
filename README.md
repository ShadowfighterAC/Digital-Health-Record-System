# Digital Health Record System (DHRS)

A Flutter-based Android application designed to digitally manage and access patient health records. The system provides separate interfaces for patients and doctors, with role-based access to medical information and features such as doctor assignment, appointments, prescriptions, lab reports, medical history, and secure medical file storage.

## Features

### Patient
- Patient registration and login
- Choose and change assigned doctor
- View medical records
- View prescriptions
- View lab reports
- View medical history
- Book appointments with the currently assigned doctor
- View appointment status
- Cancel scheduled appointments
- View medical images and PDF documents

### Doctor
- Doctor registration and login
- View currently assigned patients
- Manage patient medical records
- Add and manage prescriptions
- Add and manage lab reports
- Add and manage medical history
- Manage patient appointments
- Update appointment status
- Upload medical images and PDF documents

## Technology Stack

### Frontend
- Flutter
- Dart
- Material UI
- Provider / ChangeNotifier

### Backend
- Firebase Authentication
- Cloud Firestore
- Supabase Storage

### Security
- Firebase Authentication for user authentication
- Firestore Security Rules for role-based access control
- Patient-doctor assignment based access control
- Private Supabase Storage for medical files
- Separate permissions for Doctors and Patients

## System Architecture

```text
                Digital Health Record System
                           |
                    Flutter Android App
                           |
          +----------------+----------------+
          |                                 |
          v                                 v
 Firebase Authentication             Cloud Firestore
                                            |
                         +------------------+------------------+
                         |                  |                  |
                       Users          Medical Records     Appointments
                         |
                  Doctor Assignment
                                            |
                                            v
                                   Supabase Storage
                                            |
                                  Medical Files
                                  (PDFs / Images)
