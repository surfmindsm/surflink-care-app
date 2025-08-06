import '../models/user.dart';
import 'auth_api_service.dart';

class AuthService {
  final AuthApiService _authApiService = AuthApiService();
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('[로그] 로그인 시도: 이메일=$email');
      
      // 개발/테스트용 목업 로그인
      if (email.startsWith('test@') || email.contains('demo')) {
        print('[로그] 목업 로그인 모드 활성화');
        return _createMockLoginResponse(email);
      }
      
      final authResponse = await _authApiService.signIn(
        email: email,
        password: password,
      );
      
      print('[로그] 인증 응답: 사용자=${authResponse.user?.id}, 세션=${authResponse.session?.accessToken != null}');
      
      if (authResponse.user != null) {
        // 이메일 확인 상태 체크
        if (authResponse.user!.emailConfirmedAt == null) {
          print('[로그] 이메일 미확인 사용자: ${authResponse.user!.email}');
          // 이메일 미확인이어도 로그인 허용 (개발 환경)
          // return {
          //   'success': false,
          //   'message': '이메일 확인이 필요합니다. 이메일을 확인해주세요.',
          // };
        }
        
        // Supabase User를 앱 User 모델로 변환
        Map<String, dynamic>? userProfile;
        try {
          userProfile = await _authApiService.getUserProfile();
          print('[로그] 프로필 조회 성공: $userProfile');
        } catch (profileError) {
          print('[로그] 프로필 조회 실패 (기본값 사용): $profileError');
          userProfile = null;
        }
        
        final user = User(
          id: authResponse.user!.id,
          email: authResponse.user!.email ?? email,
          name: userProfile?['name'] ?? authResponse.user!.userMetadata?['name'] ?? '사용자',
          phone: userProfile?['phone'] ?? authResponse.user!.userMetadata?['phone'],
          userType: _parseUserType(userProfile?['user_type']),
          status: UserStatus.active,
          createdAt: DateTime.parse(authResponse.user!.createdAt),
          updatedAt: DateTime.now(),
        );
        
        print('[로그] 로그인 성공: ${user.name} (${user.userType})');
        
        return {
          'success': true,
          'user': user,
          'token': authResponse.session?.accessToken ?? '',
        };
      } else {
        print('[로그] 인증 실패: 사용자 정보 없음');
        return {
          'success': false,
          'message': '로그인에 실패했습니다.',
        };
      }
    } catch (e) {
      print('Login error: $e');
      
      // 개발 모드 이메일 우회 로직 처리
      if (e.toString().contains('DEVELOPMENT_EMAIL_BYPASS_SUCCESS')) {
        print('[개발 모드] 이메일 미확인 사용자 로그인 성공 처리');
        
        // 더미 사용자 생성 (개발용)
        final user = User(
          id: 'dev-user-${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          name: '개발용 사용자',
          phone: null,
          userType: UserType.customer,
          status: UserStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        print('[로그] 개발 모드 로그인 성공: ${user.name}');
        
        return {
          'success': true,
          'user': user,
          'token': 'dev-token-${DateTime.now().millisecondsSinceEpoch}',
        };
      }
      
      // 구체적인 에러 메시지 처리
      String errorMessage;
      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = '이메일 또는 비밀번호가 올바르지 않습니다.';
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage = '이메일 확인이 필요합니다. 이메일을 확인해주세요.';
      } else if (e.toString().contains('User not found')) {
        errorMessage = '등록되지 않은 이메일입니다. 회원가입을 해주세요.';
      } else if (e.toString().contains('Too many requests')) {
        errorMessage = '너무 많은 시도입니다. 잠시 후 다시 시도해주세요.';
      } else {
        errorMessage = '로그인 중 오류가 발생했습니다. 다시 시도해주세요.';
      }
      
      print('[로그] 로그인 결과: false, 에러: $errorMessage');
      
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }
  
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required UserType userType,
    String? phone,
    DateTime? birth,
    String? gender,
  }) async {
    try {
      final authResponse = await _authApiService.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone ?? '',
        userType: userType.toString().split('.').last,
      );
      
      if (authResponse.user != null) {
        // 사용자 프로필 업데이트 시도 (실패해도 무시)
        try {
          await _authApiService.updateUserProfile({
            'name': name,
            'phone': phone,
            'birth': birth?.toIso8601String(),
            'gender': gender,
            'user_type': userType.toString().split('.').last,
          });
          print('사용자 프로필 업데이트 성공');
        } catch (profileError) {
          print('사용자 프로필 업데이트 실패 (무시): $profileError');
        }
        
        final user = User(
          id: authResponse.user!.id,
          email: authResponse.user!.email ?? email,
          name: name,
          phone: phone,
          userType: userType,
          status: UserStatus.active,
          createdAt: DateTime.parse(authResponse.user!.createdAt),
          updatedAt: DateTime.now(),
        );
        
        return {
          'success': true,
          'user': user,
          'token': authResponse.session?.accessToken ?? '',
        };
      } else {
        return {
          'success': false,
          'message': '회원가입에 실패했습니다.',
        };
      }
    } on Exception catch (e) {
      print('Register error (Exception): $e');
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      print('Register error (기타): $e');
      // FunctionException 처리
      if (e.toString().contains('FunctionException')) {
        if (e.toString().contains('status: 400')) {
          return {
            'success': false,
            'message': '입력한 정보를 확인해주세요. 이미 사용 중인 이메일일 수 있습니다.',
          };
        }
        return {
          'success': false,
          'message': '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
        };
      }
      return {
        'success': false,
        'message': '네트워크 연결을 확인해주세요.',
      };
    }
  }

  // 소셜 로그인 (Google)
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final authResponse = await _authApiService.signInWithGoogle();
      
      if (authResponse.user != null) {
        // 기본 프로필 생성 또는 업데이트
        final userProfile = await _authApiService.getUserProfile();
        
        // 프로필이 없으면 기본 프로필 생성
        if (userProfile == null) {
          await _authApiService.updateUserProfile({
            'name': authResponse.user!.userMetadata?['full_name'] ?? 'Google 사용자',
            'user_type': 'customer', // 기본값
          });
        }
        
        final profile = await _authApiService.getUserProfile();
        
        final user = User(
          id: authResponse.user!.id,
          email: authResponse.user!.email ?? '',
          name: profile?['name'] ?? 'Google 사용자',
          phone: profile?['phone'],
          userType: _parseUserType(profile?['user_type']),
          status: UserStatus.active,
          createdAt: DateTime.parse(authResponse.user!.createdAt),
          updatedAt: DateTime.now(),
        );
        
        return {
          'success': true,
          'user': user,
          'token': authResponse.session?.accessToken ?? '',
        };
      } else {
        return {
          'success': false,
          'message': 'Google 로그인에 실패했습니다.',
        };
      }
    } catch (e) {
      print('Google sign in error: $e');
      return {
        'success': false,
        'message': 'Google 로그인 중 오류가 발생했습니다.',
      };
    }
  }

  // 로그아웃
  Future<bool> logout() async {
    try {
      await _authApiService.signOut();
      return true;
    } catch (e) {
      print('Logout error: $e');
      return false;
    }
  }

  // 현재 사용자 정보 가져오기
  Future<User?> getCurrentUser() async {
    try {
      final currentUser = _authApiService.currentUser;
      if (currentUser == null) return null;

      // 프로필 정보 가져오기 시도
      Map<String, dynamic>? userProfile;
      try {
        userProfile = await _authApiService.getUserProfile();
        print('사용자 프로필 및기 성공: $userProfile');
      } catch (profileError) {
        print('사용자 프로필 및기 실패 (기본값 사용): $profileError');
        userProfile = null;
      }

      return User(
        id: currentUser.id,
        email: currentUser.email ?? '',
        name: userProfile?['name'] ?? currentUser.userMetadata?['name'] ?? '사용자',
        phone: userProfile?['phone'] ?? currentUser.userMetadata?['phone'],
        userType: _parseUserType(userProfile?['user_type']),
        status: UserStatus.active,
        createdAt: DateTime.parse(currentUser.createdAt),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  // 비밀번호 재설정
  Future<bool> resetPassword(String email) async {
    try {
      await _authApiService.resetPassword(email: email);
      return true;
    } catch (e) {
      print('Reset password error: $e');
      return false;
    }
  }

  // 프로필 업데이트
  Future<Map<String, dynamic>> updateProfile(User updatedUser) async {
    try {
      final profileData = {
        'name': updatedUser.name,
        'phone': updatedUser.phone,
        'user_type': updatedUser.userType.toString().split('.').last,
      };

      final success = await _authApiService.updateUserProfile(profileData);
      
      if (success) {
        return {
          'success': true,
          'user': updatedUser,
        };
      } else {
        return {
          'success': false,
          'message': '프로필 업데이트에 실패했습니다.',
        };
      }
    } catch (e) {
      print('Update profile error: $e');
      return {
        'success': false,
        'message': '프로필 업데이트 중 오류가 발생했습니다: ${e.toString()}',
      };
    }
  }

  // 사용자 타입 파싱 헬퍼
  UserType _parseUserType(String? userType) {
    switch (userType?.toLowerCase()) {
      case 'freelancer':
        return UserType.freelancer;
      case 'customer':
      default:
        return UserType.customer;
    }
  }
  
  // 이메일 인증코드 발송 (사용 안 함 - 도메인 구매 필요)
  /*
  Future<bool> sendEmailVerificationCode(String email) async {
    try {
      // 개발/테스트 모드: 항상 성공으로 처리
      if (email.contains('test@') || email.contains('demo') || email.endsWith('@example.com')) {
        print('[로그] 개발용 이메일 인증코드 발송 (목업): $email');
        await Future.delayed(const Duration(milliseconds: 500)); // 네트워크 지연 시뮬레이션
        return true;
      }
      
      final response = await http.post(
        Uri.parse('${AppConfig.supabaseUrl}${AppConfig.sendEmailCodeEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
        },
        body: jsonEncode({'email': email}),
      );
      
      print('[로그] 인증코드 발송 요청: 이메일=$email, 상태=${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('[로그] 인증코드 발송 성공');
        return true;
      } else {
        print('[로그] 인증코드 발송 실패: ${response.body}');
        
        // API 문제 시 개발용 목업으로 fallback
        final errorData = jsonDecode(response.body);
        if (errorData['error']?.contains('sendRawEmail') == true || 
            errorData['error']?.contains('이미 가입된 이메일') == true) {
          print('[로그] API 문제로 인한 개발용 목업 모드 활성화');
          await Future.delayed(const Duration(milliseconds: 500));
          return true;
        }
        
        throw Exception('인증코드 발송에 실패했습니다.');
      }
    } catch (e) {
      print('[로그] 인증코드 발송 에러: $e');
      
      // 네트워크 오류 등의 경우 개발용 목업으로 처리
      if (e.toString().contains('Failed to load resource') || 
          e.toString().contains('Connection') ||
          e.toString().contains('SocketException')) {
        print('[로그] 네트워크 오류로 인한 개발용 목업 모드 활성화');
        await Future.delayed(const Duration(milliseconds: 500));
        return true;
      }
      
      rethrow;
    }
  }
  */
  
  // 이메일 인증코드 검증 (사용 안 함 - 도메인 구매 필요)
  /*
  Future<bool> verifyEmailCode(String email, String code) async {
    try {
      // 개발/테스트 모드: 항상 성공으로 처리 (코드가 6자리 숫자이면)
      if (email.contains('test@') || email.contains('demo') || email.endsWith('@example.com')) {
        print('[로그] 개발용 이메일 인증코드 검증 (목업): $email, 코드: $code');
        await Future.delayed(const Duration(milliseconds: 300));
        
        // 6자리 숫자 코드인지 확인
        if (code.length == 6 && RegExp(r'^[0-9]+$').hasMatch(code)) {
          return true;
        } else {
          throw Exception('인증코드는 6자리 숫자여야 합니다.');
        }
      }
      
      final response = await http.post(
        Uri.parse('${AppConfig.supabaseUrl}${AppConfig.verifyEmailCodeEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
        },
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );
      
      print('[로그] 인증코드 검증 요청: 이메일=$email, 코드=$code, 상태=${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('[로그] 인증코드 검증 성공');
        return true;
      } else {
        print('[로그] 인증코드 검증 실패: ${response.body}');
        
        // API 문제 시 개발용 목업으로 fallback
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error']?.toString().contains('sendRawEmail') == true) {
            print('[로그] API 문제로 인한 개발용 목업 모드 활성화');
            await Future.delayed(const Duration(milliseconds: 300));
            if (code.length == 6 && RegExp(r'^[0-9]+$').hasMatch(code)) {
              return true;
            }
          }
          throw Exception(errorData['message'] ?? '인증코드가 올바르지 않습니다.');
        } catch (_) {
          throw Exception('인증코드 검증에 실패했습니다.');
        }
      }
    } catch (e) {
      print('[로그] 인증코드 검증 에러: $e');
      
      // 네트워크 오류 등의 경우 개발용 목업으로 처리
      if (e.toString().contains('Failed to load resource') || 
          e.toString().contains('Connection') ||
          e.toString().contains('SocketException')) {
        print('[로그] 네트워크 오류로 인한 개발용 목업 모드 활성화');
        await Future.delayed(const Duration(milliseconds: 300));
        if (code.length == 6 && RegExp(r'^[0-9]+$').hasMatch(code)) {
          return true;
        }
      }
      
      rethrow;
    }
  }
  */

  // 목업 로그인 응답 생성
  Map<String, dynamic> _createMockLoginResponse(String email) {
    // 이메일에 따라 사용자 타입 결정
    final isFreelancer = email.contains('freelancer') || email.contains('provider');
    final userName = email.contains('freelancer') ? '김프리' : 
                    email.contains('provider') ? '이전문' : '홍고객';
    
    final user = User(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: userName,
      phone: '010-1234-5678',
      userType: isFreelancer ? UserType.freelancer : UserType.customer,
      status: UserStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    print('[로그] 목업 로그인 성공: ${user.name} (${user.userType})');
    
    return {
      'success': true,
      'user': user,
      'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    };
  }
}
