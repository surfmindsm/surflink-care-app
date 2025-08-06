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
      // 입력값 검증
      if (email.trim().isEmpty || !email.contains('@')) {
        throw Exception('유효한 이메일 주소를 입력해주세요.');
      }
      if (password.length < 6) {
        throw Exception('비밀번호는 최소 6자 이상이어야 합니다.');
      }
      if (name.trim().isEmpty) {
        throw Exception('이름을 입력해주세요.');
      }
      if (!['freelancer', 'customer'].contains(userType)) {
        throw Exception('올바른 사용자 유형을 선택해주세요.');
      }

      // Edge Function 호출을 위한 요청 데이터 준비
      final requestData = {
        'email': email.trim(),
        'password': password,
        'user_type': userType,
        'name': name.trim(),
        'phone': phone.trim().isEmpty ? '' : phone.trim(), // null 대신 빈 문자열 사용
      };
      
      print('회원가입 요청 데이터: $requestData');
      
      try {
        // Edge Function 호출로 회원가입 시도
        final result = await _apiService.invokeFunction('auth-signup', body: requestData);
        
        print('Edge Function 응답: $result');

        // 성공시 로그인 처리
        if (result['success'] == true) {
          print('회원가입 성공, 자동 로그인 시도...');
          return await _apiService.auth.signInWithPassword(
            email: email.trim(),
            password: password,
          );
        } else {
          final errorMessage = result['error'] ?? result['message'] ?? '회원가입에 실패했습니다.';
          print('회원가입 실패: $errorMessage');
          throw Exception(errorMessage);
        }
      } catch (edgeFunctionError) {
        print('Edge Function 실패, Supabase 기본 Auth API로 대체 시도: $edgeFunctionError');
        
        // Edge Function이 실패하면 Supabase 기본 auth API 사용
        final authResponse = await _apiService.auth.signUp(
          email: email.trim(),
          password: password,
        );
        
        if (authResponse.user != null) {
          print('Supabase 기본 Auth로 회원가입 성공');
          print('사용자 ID: ${authResponse.user!.id}');
          print('이메일: ${authResponse.user!.email}');
          print('이메일 확인 상태: ${authResponse.user!.emailConfirmedAt}');
          print('세션 존재: ${authResponse.session != null}');
          
          try {
            // 사용자 프로필 생성 시도
            await _apiService.from('profiles').insert({
              'id': authResponse.user!.id,
              'name': name.trim(),
              'phone': phone.trim().isEmpty ? '' : phone.trim(),
              'user_type': userType,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
            print('사용자 프로필 생성 성공');
          } catch (profileError) {
            print('프로필 생성 실패 (무시하고 계속): $profileError');
            // profiles 테이블이 없어도 회원가입은 성공으로 처리
          }
          
          // Supabase signUp은 자동으로 로그인 세션을 생성하므로 바로 반환
          return authResponse;
        } else {
          print('Supabase 기본 Auth도 실패');
          throw Exception('회원가입에 실패했습니다.');
        }
      }
    } on Exception catch (e) {
      print('회원가입 에러 (Exception): $e');
      rethrow;
    } catch (e) {
      print('회원가입 에러 (기타): $e');
      // FunctionException 또는 기타 Supabase 에러 처리
      if (e.toString().contains('FunctionException')) {
        if (e.toString().contains('Failed to create user account')) {
          throw Exception('이미 존재하는 이메일이거나 회원가입에 실패했습니다. 다른 이메일을 사용해주세요.');
        }
        throw Exception('서버에서 회원가입을 처리할 수 없습니다. 잠시 후 다시 시도해주세요.');
      }
      throw Exception('네트워크 오류가 발생했습니다: ${e.toString()}');
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
      if (user == null) {
        print('인증되지 않은 사용자');
        return false;
      }

      await _apiService.from('profiles')
          .update({...profileData, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', user.id);

      print('프로필 업데이트 성공');
      return true;
    } catch (e) {
      print('Update user profile error: $e');
      // 404 에러(테이블 없음)도 false 반환하지만 예외는 발생시키지 않음
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
