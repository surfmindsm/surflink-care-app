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

      print('회원가입 시작: $email ($userType)');
      
      // 데이터베이스 구조에 맞는 직접 회원가입 처리
      return await _signUpWithCorrectFlow(
        email: email.trim(),
        password: password,
        name: name.trim(),
        phone: phone.trim().isEmpty ? null : phone.trim(),
        userType: userType,
      );
    } on Exception catch (e) {
      print('회원가입 에러 (Exception): $e');
      rethrow;
    } catch (e) {
      print('회원가입 에러 (기타): $e');
      throw Exception('회원가입 처리 중 예상치 못한 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // 데이터베이스 구조에 맞는 올바른 회원가입 Flow
  Future<AuthResponse> _signUpWithCorrectFlow({
    required String email,
    required String password,
    required String name,
    required String? phone,
    required String userType,
  }) async {
    try {
      print('데이터베이스 구조에 맞는 회원가입 시작...');
      
      // 1. 먼저 이메일 중복 확인
      try {
        final existingProfile = await _apiService.from('profiles')
            .select('email')
            .eq('email', email)
            .maybeSingle();
            
        if (existingProfile != null) {
          throw Exception('이미 등록된 이메일입니다.');
        }
      } catch (e) {
        if (e.toString().contains('이미 등록된')) rethrow;
        print('이메일 중복 확인 실패 (무시하고 진행): $e');
      }
      
      // 2. Supabase Auth에 사용자 생성
      print('Step 1: Supabase Auth 사용자 생성...');
      final authResponse = await _apiService.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'user_type': userType,
        },
      );
      
      if (authResponse.user == null) {
        throw Exception('Auth 사용자 생성 실패');
      }
      
      final userId = authResponse.user!.id;
      print('Auth 사용자 생성 성공 - ID: $userId');
      
      // 3. profiles 테이블에 사용자 정보 삽입
      print('Step 2: profiles 테이블에 사용자 정보 삽입...');
      
      final profileData = {
        'id': userId, // auth.users.id와 동일한 UUID 사용 (외래키)
        'email': email,
        'name': name,
        'phone': phone,
        'user_type': userType,
        'role': 'user',
        'is_verified': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      print('삽입할 프로필 데이터: $profileData');
      }
      
      // 6. 자동 로그인 처리
      if (authResponse.session != null) {
        print('회원가입 및 자동 로그인 성공');
        return authResponse;
      } else {
        // 세션이 없는 경우 수동 로그인 시도
        print('세션이 없어 수동 로그인 시도...');
        final loginResponse = await _apiService.auth.signInWithPassword(
          email: email,
          password: password,
        );
        return loginResponse;
      }
    } catch (directAuthError) {
      print('Direct Auth 에러: $directAuthError');
      
      // 실패 시 생성된 Auth 사용자 정리
      if (authResponse?.user != null) {
        try {
          await _apiService.auth.admin.deleteUser(authResponse!.user!.id);
          print('실패 시 Auth 사용자 정리 완료');
        } catch (cleanupError) {
          print('실패 시 Auth 사용자 정리 실패: $cleanupError');
        }
      }
      
      // 에러 메시지 정리
      if (directAuthError.toString().contains('User already registered') || 
          directAuthError.toString().contains('already registered')) {
        throw Exception('이미 가입된 이메일 주소입니다.');
      } else if (directAuthError.toString().contains('Invalid email')) {
        throw Exception('올바른 이메일 형식이 아닙니다.');
      } else if (directAuthError.toString().contains('Password should be at least')) {
        throw Exception('비밀번호는 최소 6자 이상이어야 합니다.');
      } else if (directAuthError.toString().contains('Database error saving new user') ||
                 directAuthError.toString().contains('Database error')) {
        throw Exception('데이터베이스 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
      } else if (directAuthError.toString().contains('Network') ||
                 directAuthError.toString().contains('network')) {
        throw Exception('네트워크 연결을 확인해주세요.');
      } else if (directAuthError.toString().contains('사용자 프로필 생성')) {
        // 이미 처리한 프로필 생성 에러는 그대로 전달
        rethrow;
      }
      
      throw Exception('회원가입에 실패했습니다: 서버와의 연결을 확인하고 다시 시도해주세요.');
    }
  }

  // 로그인
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // 입력값 검증
      if (email.trim().isEmpty || !email.contains('@')) {
        throw Exception('유효한 이메일 주소를 입력해주세요.');
      }
      if (password.isEmpty) {
        throw Exception('비밀번호를 입력해주세요.');
      }

      print('로그인 시도: ${email.trim()}');
      
      // Supabase Auth API를 사용한 로그인
      final response = await _apiService.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      
      if (response.user != null && response.session != null) {
        print('로그인 성공: ${response.user!.id}');
        
        // 사용자 프로필 정보 확인
        try {
          final profile = await getUserProfile();
          if (profile != null) {
            print('사용자 타입: ${profile['user_type']}');
          }
        } catch (profileError) {
          print('프로필 정보 확인 실패: $profileError');
          // 프로필 오류가 있어도 로그인은 계속 진행
        }
        
        return response;
      } else {
        throw Exception('로그인에 실패했습니다.');
      }
    } catch (e) {
      print('로그인 에러: $e');
      
      // 에러 메시지 정리
      if (e.toString().contains('Invalid login credentials')) {
        throw Exception('이메일 또는 비밀번호가 올바르지 않습니다.');
      } else if (e.toString().contains('Email not confirmed')) {
        throw Exception('이메일 인증이 필요합니다. 이메일을 확인해주세요.');
      } else if (e.toString().contains('Too many requests')) {
        throw Exception('너무 많은 로그인 시도가 있었습니다. 잠시 후 다시 시도해주세요.');
      } else if (e.toString().contains('Network')) {
        throw Exception('네트워크 연결을 확인해주세요.');
      } else if (e.toString().contains('Exception:')) {
        // 이미 우리가 처리한 Exception는 그대로 전달
        rethrow;
      }
      
      throw Exception('로그인에 실패했습니다: ${e.toString()}');
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
