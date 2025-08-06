import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://eeprrrbqhufhduvbzftv.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVlcHJycmJxaHVmaGR1dmJ6ZnR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0NTUwNTQsImV4cCI6MjA3MDAzMTA1NH0.Bt5eTr4ZYT9jpYex_wFFqLr4rk9_yZBi5So-o9K0m9w';

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
