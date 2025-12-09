import 'package:supabase_flutter/supabase_flutter.dart';
import 'SupabaseService.dart';
import 'package:glucotrack_app/models/GlucoseRecord.dart';

class Glucoserepository {
  final SupabaseClient supabase = SupabaseService.client;

  Future<bool> insertGlucoseRecord(Glucoserecord record) async {
    try {
      await supabase.from('glucose_records').insert(record.toMap());
      return true;
    } catch (e) {
      print('Error inserting glucose record: $e');
      return false;
    }
  }

  Future<List<Glucoserecord>> getAllGlucoseRecords(String userId) async {
    try {
      final response = await supabase
          .from('glucose_records')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false);
      return (response as List)
          .map((record) => Glucoserecord.fromMap(record))
          .toList();
    } catch (e) {
      print('Error fetching glucose records: $e');
      return [];
    }
  }

  Future<List<Glucoserecord>> getGlucoseRecordsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await supabase
          .from('glucose_records')
          .select()
          .eq('user_id', userId)
          .gte('timestamp', startDate.toIso8601String())
          .lte('timestamp', endDate.toIso8601String())
          .order('timestamp', ascending: false);
      return (response as List)
          .map((record) => Glucoserecord.fromMap(record))
          .toList();
    } catch (e) {
      print('Error fetching glucose records by date range: $e');
      return [];
    }
  }
  
  Future<Glucoserecord?> getGlucoseRecordById(String id) async {
    try {
      final response = await supabase
          .from('glucose_records')
          .select()
          .eq('id', id)
          .single();
      return Glucoserecord.fromMap(response);
    } catch (e) {
      print('Error fetching glucose record by ID: $e');
      return null;
    }
  }

  Future<Glucoserecord?> getLatestGlucoseRecord(String userId) async {
    try {
      final response = await supabase
          .from('glucose_records')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false)
          .limit(1)
          .single();
      return Glucoserecord.fromMap(response);
    } catch (e) {
      print('Error fetching latest glucose record: $e');
      return null;
    }
  }

  Future<List<Glucoserecord>> getGlucoseRecordsByCondition(
    String userId,
    GlucoseCondition condition,
  ) async {
    try {
      final conditionStr = condition == GlucoseCondition.beforeMeal
       ? 'beforeMeal' 
       : 'afterMeal';

      final response = await supabase
          .from('glucose_records')
          .select()
          .eq('user_id', userId)
          .eq('condition', conditionStr)
          .order('timestamp', ascending: false);
      return (response as List)
          .map((record) => Glucoserecord.fromMap(record))
          .toList();
    } catch (e) {
      print('Error fetching glucose records by condition: $e');
      return [];
    }
  }

  Future<List<Glucoserecord>> getIoTGlucoseRecords(String userId) async {
    try {
      final response = await supabase
          .from('glucose_records')
          .select()
          .eq('user_id', userId)
          .eq('is_from_iot', true)
          .order('timestamp', ascending: false);

      return (response as List)
          .map((record) => Glucoserecord.fromMap(record))
          .toList();
    } catch (e) {
      print('Error fetching IoT glucose records: $e');
      return [];
    }
  }

  Future<bool> updateGlucoseRecord(Glucoserecord record) async {
    try {
      await supabase
          .from('glucose_records')
          .update(record.toMap())
          .eq('id', record.id);
      return true;
    } catch (e) {
      print('Error updating glucose record: $e');
      return false;
    }
  }

  Future<bool> deleteGlucoseRecord(String id) async {
    try {
      await supabase.from('glucose_records').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting glucose record: $e');
      return false;
    }
  }

  Future<bool> deleteAllGlucoseRecords(String userId) async {
    try {
      await supabase.from('glucose_records').delete().eq('user_id', userId);
      return true;
    } catch (e) {
      print('Error deleting all glucose records: $e');
      return false;
    }
  }

   Future<double?> getAverageGlucoseLevel(String userId) async {
    try {
      final records = await getAllGlucoseRecords(userId);
      if (records.isEmpty) return null;

      final total = records.fold<double>(
        0,
        (sum, record) => sum + record.glucoseLevel,
      );
      return total / records.length;
    } catch (e) {
      print('Error calculating average glucose level: $e');
      return null;
    }
  }

  Future<int> getRecordsCount(String userId) async {
    try {
      final response = await supabase
          .from('glucose_records')
          .select()
          .eq('user_id', userId)
          .count();

      return response.count ?? 0;
    } catch (e) {
      print('Error getting records count: $e');
      return 0;
    }
  }

  Stream<List<Glucoserecord>> streamGlucoseRecords(String userId) {
    return supabase
        .from('glucose_records')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('timestamp', ascending: false)
        .map((data) => data.map((record) => Glucoserecord.fromMap(record)).toList());
  }
}