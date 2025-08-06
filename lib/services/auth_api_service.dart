import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';

class AuthApiService {
  final ApiService _apiService = apiService;

  // 회원가입
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType, // 'freelancer' or 'customer'
  }) async {
    try {
      // Edge Function 호출로 회원가입
      final result = await _apiService.invokeFunction('auth-signup', body: {
        'email': email,
        'password': password,
        'user_type': userType,
        'name': name,
        'phone': phone,
      });

      // 성공시 로그인 처리
      if (result['success'] == true) {
        return await _apiService.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } else {
        throw Exception(result['error'] ?? '회원가입에 실패했습니다.');
      }
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  // 로그인
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  // 소셜 로그인 (구글) - 웹에서는 제한적
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // 웹 환경에서는 OAuth 로그인이 제한적이므로 임시 미구현
      throw UnimplementedError('구글 로그인은 모바일 환경에서만 지원됩니다.');
    } catch (e) {
      print('Google sign in error: $e');
      rethrow;
    }
  }

  // 소셜 로그인 (카카오) - 웹 환경에서는 제한적
  Future<AuthResponse> signInWithKakao() async {
    try {
      // 카카오 로그인은 별도 구현 필요 (웹에서는 제한적)
      throw UnimplementedError('카카오 로그인은 아직 구현되지 않았습니다.');
    } catch (e) {
      print('Kakao sign in error: $e');
      rethrow;
    }
  }

  // 비밀번호 재설정
  Future<void> resetPassword({required String email}) async {
    try {
      await _apiService.auth.resetPasswordForEmail(email);
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      await _apiService.auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // 현재 사용자 정보
  User? get currentUser => _apiService.auth.currentUser;

  // 인증 상태 스트림
  Stream<AuthState> get authStateChanges => _apiService.auth.onAuthStateChange;

  // 사용자 프로필 정보 가져오기
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final response = await _apiService.from('profiles')
          .select('*')
          .eq('id', user.id)
          .single();

      return response;
    } catch (e) {
      print('Get user profile error: $e');
      return null;
    }
  }

  // 사용자 프로필 업데이트
  Future<bool> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      await _apiService.from('profiles')
          .update({...profileData, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', user.id);

      return true;
    } catch (e) {
      print('Update user profile error: $e');
      return false;
    }
  }

  // 사용자 타입 확인
  Future<String?> getUserType() async {
    try {
      final profile = await getUserProfile();
      return profile?['user_type'];
    } catch (e) {
      print('Get user type error: $e');
      return null;
    }
  }

  // 토큰 갱신
  Future<AuthResponse?> refreshSession() async {
    try {
      return await _apiService.auth.refreshSession();
    } catch (e) {
      print('Refresh session error: $e');
      return null;
    }
  }
}
