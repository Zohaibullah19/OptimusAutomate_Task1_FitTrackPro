import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Stream<DocumentSnapshot> getUserProfile() {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserWorkouts() {
    return _firestore
        .collection('workouts')
        .where(
          'userId',
          isEqualTo: _auth.currentUser!.uid,
        )
        .snapshots();
  }
}