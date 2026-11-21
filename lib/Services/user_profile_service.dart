import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Keeps the signed-in user's profile in Firestore at users/{uid}.
/// The realtime server reads/merges the same document (presence, lastSeen).
class UserProfileService {
  UserProfileService._();
  static final UserProfileService instance = UserProfileService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String uid) => _db.collection('users').doc(uid);

  /// Create or update the profile after sign-in.
  Future<void> saveSignedInUser({String? studentId, String? role}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = _doc(user.uid);
    final snap = await ref.get();
    await ref.set({
      'uid': user.uid,
      'email': user.email ?? '',
      'displayName': user.displayName ?? user.email ?? '',
      'photoURL': user.photoURL ?? '',
      if (studentId != null) 'studentId': studentId,
      if (role != null) 'role': role,
      'lastLoginAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (!snap.exists) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getProfile(String uid) async {
    final snap = await _doc(uid).get();
    return snap.data();
  }

  Stream<Map<String, dynamic>?> watchProfile(String uid) => _doc(uid).snapshots().map((s) => s.data());

  Future<void> updateProfile(Map<String, dynamic> fields) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _doc(user.uid).set({...fields, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }
}
