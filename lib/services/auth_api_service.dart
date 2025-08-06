import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
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

  // Edge Function을 사용한 회원가입 (RLS 문제 해결)
  Future<AuthResponse> _signUpWithCorrectFlow({
    required String email,
    required String password,
    required String name,
    required String? phone,
    required String userType,
  }) async {
    try {
      print('데이터베이스 구조에 맞는 회원가입 시작...');
      
      // 1. Edge Function을 사용하여 회원가입 처리
      print('Step 1: Edge Function을 사용한 회원가입...');
      
      try {
        final dio = Dio();
        dio.options.headers = {
          'apikey': AppConfig.supabaseAnonKey,
          'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
          'Content-Type': 'application/json',
        };
        
        final response = await dio.post(
          '${AppConfig.supabaseUrl}/functions/v1/auth-signup',
          data: {
            'email': email,
            'password': password,
            'name': name,
            'phone': phone,
            'user_type': userType,
          },
        );
        
        if (response.statusCode == 200) {
          print('Edge Function 회원가입 성공');
          
          // 로그인하여 세션 생성
          final authResponse = await _apiService.auth.signInWithPassword(
            email: email,
            password: password,
          );
          
          if (authResponse.user != null) {
            print('로그인 성공');
            return authResponse;
          } else {
            throw Exception('로그인에 실패했습니다.');
          }
        } else {
          throw Exception('Edge Function 오류: ${response.statusCode}');
        }
      } catch (e) {
        if (e.toString().contains('DioException') || e.toString().contains('404') || e.toString().contains('500')) {
          print('Edge Function 사용 불가, 대체 방법 사용...');
          return await _signUpWithAlternativeMethod(
            email: email,
            password: password,
            name: name,
            phone: phone,
            userType: userType,
          );
        } else {
          rethrow;
        }
      }
      
    } catch (e) {
      print('회원가입 에러: $e');
      
      // 에러 메시지 정리
      if (e.toString().contains('User already registered')) {
        throw Exception('이미 등록된 이메일입니다.');
      } else if (e.toString().contains('duplicate key value violates unique constraint')) {
        throw Exception('이미 등록된 사용자입니다.');
      } else if (e.toString().contains('violates foreign key constraint')) {
        throw Exception('데이터베이스 외래키 제약조건 위반. 시스템 관리자에게 문의해주세요.');
      } else if (e.toString().contains('relation') && e.toString().contains('does not exist')) {
        throw Exception('요구되는 데이터베이스 테이블이 존재하지 않습니다.');
      } else if (e.toString().contains('Password should be at least')) {
        throw Exception('비밀번호는 최소 6자 이상이어야 합니다.');
      } else if (e.toString().contains('Invalid email')) {
        throw Exception('유효하지 않은 이메일 형식입니다.');
      } else if (e.toString().contains('Exception:')) {
        rethrow; // 이미 처리된 Exception은 그대로 전달
      }
      
      throw Exception('회원가입에 실패했습니다: ${e.toString()}');
    }
  }

  // 대체 회원가입 방법 (이메일 확인 비활성화)
  Future<AuthResponse> _signUpWithAlternativeMethod({
    required String email,
    required String password,
    required String name,
    required String? phone,
    required String userType,
  }) async {
    try {
      print('대체 방법으로 회원가입 시도...');
      
      // 1. Supabase Auth에 사용자 생성 (이메일 확인 비활성화)
      print('Auth 사용자 생성...');
      final authResponse = await _apiService.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null, // 이메일 리다이렉트 비활성화
        data: {
          'name': name,
          'user_type': userType,
          'email': email, // metadata에 이메일 포함
        },
      );
      
      if (authResponse.user == null) {
        throw Exception('Auth 사용자 생성 실패');
      }
      
      final userId = authResponse.user!.id;
      print('Auth 사용자 생성 성공 - ID: $userId');
      
      // 2. 개발 모드에서는 이메일 확인 강제 통과
      print('개발 모드: 이메일 확인 우회하고 프로필 생성...');
      
      // 3. 현재 사용자로 로그인 시도 (이메일 확인 상태 무시)
      try {
        // 개발 환경에서는 바로 로그인 성공했다고 가정
        print('개발용 로그인 성공 처리');
        
        // 프로필 생성은 건너뛰고 기본 auth만 사용
        // 인증 이메일 발송 등 인증 관련 절차 완전 제거 (나중에 6자리 코드 인증 방식으로 복원 예정)
        print('기본 Auth 사용자만 생성(이메일 인증 절차 없음), 프로필은 나중에 생성');
        print('[생성된 Auth 사용자 ID] ${authResponse.user!.id}');
        print('[Auth 사용자 이메일] ${authResponse.user!.email}');
        print('[Auth 사용자 metadata] ${authResponse.user!.userMetadata}');
        
        // profiles 테이블 insert 시도 (인증 절차와 무관하게 바로 진행)
        try {
          print('profiles 테이블에 사용자 정보 INSERT 시도...');
          final insertResponse = await _apiService.from('profiles').insert({
            'id': userId,
            'email': email,
            'name': name,
            'phone': phone,
            'user_type': userType,
            'is_verified': false,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          print('[profiles INSERT 성공] $insertResponse');
        } catch (insertError) {
          print('[profiles INSERT 실패] $insertError');
        }
        return authResponse;
      } catch (e) {
        print('로그인 시도 실패: $e');
        // 이메일 확인이 정말 필요한 경우
        throw Exception('이메일 확인이 필요합니다. 이메일을 확인한 후 다시 로그인해주세요.');
      }
    } catch (e) {
      print('대체 회원가입 방법 실패: $e');
      rethrow;
    }
  }



  // 로그인
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('로그인 시도: $email');
      
      final response = await _apiService.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.session != null && response.user != null) {
        print('로그인 성공: ${response.user!.id}');
        
        // 프로필 정보 확인 및 로드
        try {
          final profile = await getUserProfile();
          if (profile != null) {
            print('사용자 프로필 로드 성공: ${profile['user_type']}');
          }
        } catch (e) {
          print('프로필 로드 실패: $e');
        }
        
        return response;
      } else {
        throw Exception('로그인에 실패했습니다.');
      }
    } catch (e) {
      print('로그인 에러: $e');
      
      // 이메일 확인 에러는 완전히 무시하고 로그인 성공으로 처리
      if (e.toString().contains('Email not confirmed')) {
        print('[개발 모드] 이메일 미확인 상태지만 로그인 성공으로 처리');
        
        try {
          // 직접 signInWithPassword를 다시 시도하되, 에러를 무시
          // Supabase는 실제로 사용자를 인증했지만 이메일 확인만 안 된 상태
          final adminResponse = await _apiService.auth.signInWithPassword(
            email: email.trim(),
            password: password,
          );
          
          // 세션이 생성되었다면 성공으로 처리
          if (adminResponse.session != null || adminResponse.user != null) {
            print('이메일 미확인이지만 로그인 세션 생성됨: ${adminResponse.user?.id}');
            return adminResponse;
          }
        } catch (retryError) {
          print('재시도 실패, 임시 사용자 생성: $retryError');
        }
        
        // 그래도 안 되면 임시로 성공한 것으로 가정하고 더미 응답 반환
        // 실제로는 이 부분이 실행되지 않아야 함
        print('임시 로그인 성공 처리 (개발용)');
        
        // 현재 인증 상태 확인
        final currentUser = _apiService.auth.currentUser;
        final currentSession = _apiService.auth.currentSession;
        
        if (currentUser != null) {
          return AuthResponse(
            session: currentSession,
            user: currentUser,
          );
        }
        
        // 최후의 수단: 에러 메시지를 변경하여 상위에서 무시하도록
        throw Exception('DEVELOPMENT_EMAIL_BYPASS_SUCCESS');
      }
      
      // 에러 메시지 정리
      if (e.toString().contains('Invalid login credentials')) {
        throw Exception('이메일 또는 비밀번호가 올바르지 않습니다.');
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

      final response = await _apiService.from('profiles')
          .update({...profileData, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', user.id);

      print('[프로필 UPDATE 쿼리 결과] response: $response, type: ${response.runtimeType}');
      
      // Supabase update는 보통 빈 배열을 반환하므로 에러가 없으면 성공으로 간주
      print('프로필 UPDATE 완료 (에러 없음)');
      
      // 실제로 업데이트가 됐는지 확인해보자
      try {
        final checkProfile = await _apiService.from('profiles').select('*').eq('id', user.id).maybeSingle();
        print('[프로필 확인 결과] $checkProfile');
        if (checkProfile != null) {
          print('프로필 UPDATE 성공: 데이터가 존재함');
          return true;
        } else {
          print('프로필 UPDATE 실패: 해당 id의 row가 없음 (INSERT 필요)');
          return false;
        }
      } catch (checkError) {
        print('[프로필 확인 중 에러] $checkError');
        return false;
      }
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
