import 'package:supabase_flutter/supabase_flutter.dart';

class MedicineService {
  static final _db = Supabase.instance.client;

  static String _uid() {
    final user = _db.auth.currentUser;
    if (user == null) throw Exception("Not logged in");
    return user.id;
  }

  static Future<List<Map<String, dynamic>>> fetchMedicines() async {
    final uid = _uid();
    final res = await _db
        .from('medicines')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false);

    return (res as List).cast<Map<String, dynamic>>();
  }

  // ✅ CREATE
  static Future<void> addMedicine({
    required String name,
    required String dosage,
    required String notes,
    required int timesPerDay,
  }) async {
    final uid = _uid();
    await _db.from('medicines').insert({
      'user_id': uid,
      'name': name,
      'dosage': dosage,
      'notes': notes,
      'times_per_day': timesPerDay,
    });
  }

  // ✅ UPDATE (CRUD added here)
  static Future<void> updateMedicine({
    required int id,
    required String name,
    required String dosage,
    required String notes,
    required int timesPerDay,
  }) async {
    final uid = _uid();
    await _db
        .from('medicines')
        .update({
          'name': name,
          'dosage': dosage,
          'notes': notes,
          'times_per_day': timesPerDay,
        })
        .eq('id', id)
        .eq('user_id', uid);
  }

  // ✅ DELETE
  static Future<void> deleteMedicine(int id) async {
    final uid = _uid();
    await _db.from('medicines').delete().eq('id', id).eq('user_id', uid);
  }

  // ✅ EXTRA: log taken
  static Future<void> logTaken(int medicineId) async {
    final uid = _uid();
    await _db.from('medicine_logs').insert({
      'user_id': uid,
      'medicine_id': medicineId,
    });
  }
}
