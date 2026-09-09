import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _setClaimFunctionUrl =
      'https://tuektzinaytyxdaambbu.supabase.co/functions/v1/set-claim';

  /// Ensures that the Firebase ID token contains the `role: "authenticated"` claim
  /// required by Supabase Storage Third-Party Auth.
  Future<void> syncSupabaseAuthClaim(User user) async {
    // 1. Check existing claims in the current cached token
    final initialResult = await user.getIdTokenResult(false);
    if (initialResult.claims?['role'] == 'authenticated') {
      return; // Claim is already set; skip network calls
    }

    // 2. Obtain current Firebase ID token for authentication
    final idToken = await user.getIdToken(false);
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Unable to obtain Firebase ID token for claim synchronization.');
    }

    // 3. Call the deployed set-claim Edge Function
    // (Sends the token in the Authorization header; never sends UID or secrets in body)
    final response = await http.post(
      Uri.parse(_setClaimFunctionUrl),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Server returned status ${response.statusCode} while synchronizing authentication claim.',
      );
    }

    // 4. Force-refresh the Firebase ID token to receive the newly minted claim
    await user.getIdToken(true);

    // 5. Verify locally using the Firebase client SDK that the claim is present
    final refreshedResult = await user.getIdTokenResult(true);
    if (refreshedResult.claims?['role'] != 'authenticated') {
      throw Exception(
        'Token refreshed but "role: authenticated" claim was not confirmed.',
      );
    }
  }

  Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final authUser = userCredential.user;
      if (authUser == null) {
        throw Exception('User account creation failed; no user returned.');
      }

      // 1. Write the user profile to Firestore first so the set-claim Edge Function
      // can verify the application role from /users/{uid}.
      UserModel user = UserModel(
        uid: authUser.uid,
        name: name.trim(),
        email: email.trim(),
        role: role,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toMap());

      // 2. Synchronize Supabase authentication claims (role: "authenticated", app_role: role)
      await syncSupabaseAuthClaim(authUser);

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Ensure the logged-in Firebase user has role: "authenticated"
      if (userCredential.user != null) {
        await syncSupabaseAuthClaim(userCredential.user!);
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  Future<String> getUserRole(String uid) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(uid).get();

    return doc['role'];
  }
}
