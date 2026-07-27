import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUser(String uid) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return doc.data() as Map<String, dynamic>;
  }
}