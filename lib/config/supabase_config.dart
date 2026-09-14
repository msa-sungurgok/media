// Supabase API Konfigürasyonu

class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  static bool isConfigValid() {
    return supabaseUrl != 'YOUR_SUPABASE_URL' &&
        supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';
  }
}
