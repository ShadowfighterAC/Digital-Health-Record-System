class PatientModel {
  final String uid;
  final String name;
  final String email;

  PatientModel({
    required this.uid,
    required this.name,
    required this.email,
  });

  factory PatientModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return PatientModel(
      uid: id,
      name: map["name"] ?? "",
      email: map["email"] ?? "",
    );
  }
}