import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/GlucoseRecord.dart';

class GlucoseRecordService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> addRecord(Glucoserecord record) async {
    try {
      await db.collection('glucose_records').add(record.toMap());
    } catch (e) {
      print('Error adding glucose record: $e');
      rethrow;
    }
  }

  Future<List<Glucoserecord>> getRecordsByUser(String userId) async {
    try {
      final querySnapshot = await db
      .collection('glucose_records')
      .where('userId', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .get();

      return querySnapshot.docs.map((doc) => Glucoserecord.fromMap(
        doc.id,
        doc.data()
      )).toList();
    } catch (e) {
      print('Error fetching glucose record: $e');
      return [];
    }
  }
}