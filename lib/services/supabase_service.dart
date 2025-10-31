import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  static Future<void> initialize() async {
    const String supabaseUrl = 'https://qrmpyepklaetnhikxibr.supabase.co';
    const String supabaseAnonKey =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFybXB5ZXBrbGFldG5oaWt4aWJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzMzg1NTUsImV4cCI6MjA3NTkxNDU1NX0.StbSxi4uoJ6k6U7HpkhEUu91VtnZq1nw_TyxAeM7o5Y';

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

    _client = Supabase.instance.client;
  }

  SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return _client!;
  }

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return client.from('users').stream(primaryKey: ['id']);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await client.from('users').select();

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getUserByQrId(String qrId) async {
    final response =
        await client.from('users').select().eq('qr_id', qrId).maybeSingle();

    return response;
  }

  Future<void> updateUserStatus(String userId, String status) async {
    await client.from('users').update({'status': status}).eq('id', userId);
  }

  Future<void> updateUserFoodStatus(String userId, bool hadFood) async {
    await client.from('users').update({'hadFood': hadFood}).eq('id', userId);
  }
}
