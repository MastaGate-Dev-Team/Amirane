import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = SupabaseClient('your-supabase-url', 'your-supabase-key');

  Future<bool> isLoggedIn() async {
    final session = _client.auth.currentSession;
    return session != null;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> sendOTP(String phone) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  Future<AuthResponse> verifyOTP(String phone, String token) async {
   return  await  _client.auth.verifyOTP(
  type: OtpType.sms,
  token: token,
  phone: phone,
);
  }
}