import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firestore helper for common read/write operations.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<Map<String, dynamic>>> getCollection({
    required String collectionPath,
    String? orderBy,
    bool descending = true,
    int? limit,
  }) async {
    if (Firebase.apps.isEmpty) return <Map<String, dynamic>>[];

    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

      if (orderBy != null && orderBy.isNotEmpty) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      debugPrint('Firestore getCollection error: $e');
      return <Map<String, dynamic>>[];
    }
  }

  Stream<List<Map<String, dynamic>>> watchCollection({
    required String collectionPath,
    String? orderBy,
    bool descending = true,
    int? limit,
  }) {
    if (Firebase.apps.isEmpty) {
      return Stream.value(<Map<String, dynamic>>[]);
    }

    Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

    if (orderBy != null && orderBy.isNotEmpty) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null && limit > 0) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
          .toList(),
    );
  }

  Future<Map<String, dynamic>?> getDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    if (Firebase.apps.isEmpty) return null;

    try {
      final doc = await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .get();

      if (!doc.exists || doc.data() == null) return null;

      return <String, dynamic>{'id': doc.id, ...doc.data()!};
    } catch (e) {
      debugPrint('Firestore getDocument error: $e');
      return null;
    }
  }

  Future<void> setDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    if (Firebase.apps.isEmpty) return;

    try {
      await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .set(data, SetOptions(merge: merge));
    } catch (e) {
      debugPrint('Firestore setDocument error: $e');
    }
  }
}
