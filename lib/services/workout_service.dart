import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // Add Workout
  Future<String?> addWorkout({
    required String exercise,
    required int duration,
    required int calories,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return "User not logged in";
      }

      await _firestore.collection('workouts').add({
        'userId': user.uid,
        'exercise': exercise,
        'duration': duration,
        'calories': calories,
        'createdAt': Timestamp.now(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Get User Workouts
  Stream<QuerySnapshot> getUserWorkouts() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('workouts')
        .where(
          'userId',
          isEqualTo: user.uid,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  // Update Workout
  Future<void> updateWorkout({
    required String documentId,
    required String exercise,
    required int duration,
    required int calories,
  }) async {
    await _firestore
        .collection('workouts')
        .doc(documentId)
        .update({
      'exercise': exercise,
      'duration': duration,
      'calories': calories,
    });
  }

  // Delete Workout
  Future<void> deleteWorkout(
    String documentId,
  ) async {
    await _firestore
        .collection('workouts')
        .doc(documentId)
        .delete();
  }
}