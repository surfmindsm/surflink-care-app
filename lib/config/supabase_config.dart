import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://plszfhrqrmigzpjssoif.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBsc3pmaHJxcm1pZ3pwanNzb2lmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk1MzU2NjIsImV4cCI6MjA2NTExMTY2Mn0.CGwkWkDwqPkPNqwo6WZCika-IpngKRqNszbMKQWlwUs';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      debug: false,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

// Supabase 클라이언트 전역 접근자
final supabase = SupabaseConfig.client;
