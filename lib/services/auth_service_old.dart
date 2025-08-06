import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user.dart';
import '../config/app_config.dart';
import 'auth_api_service.dart';

class AuthService {
  final AuthApiService _authApiService = AuthApiService();
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final authResponse = await _authApiService.signIn(
        email: email,
        password: password,
      );
      
      if (authResponse.user != null) {
        // Supabase User를 앱 User 모델로 변환
        final userProfile = await _authApiService.getUserProfile();
        
        final user = User(
          id: authResponse.user!.id,
          email: authResponse.user!.email ?? email,
          name: userProfile?['name'] ?? '사용자',
          phone: userProfile?['phone'],
          userType: _parseUserType(userProfile?['user_type']),
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
          'message': '로그인에 실패했습니다.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '로그인 중 오류가 발생했습니다: ${e.toString()}',
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
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'user_type': userType.toString().split('.').last,
          if (phone != null) 'phone': phone,
          if (birth != null) 'birth': birth.toIso8601String(),
          if (gender != null) 'gender': gender,
        }),
      ).timeout(AppConfig.apiTimeout);
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'user': User.fromJson(data['user']),
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? '회원가입에 실패했습니다',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }
  
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/reset-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      ).timeout(AppConfig.apiTimeout);
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? '비밀번호 재설정 이메일을 발송했습니다',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? '비밀번호 재설정에 실패했습니다',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }
  
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConfig.authTokenKey);
      
      if (token == null) return null;
      
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
  
  Future<Map<String, dynamic>> updateProfile(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConfig.authTokenKey);
      
      final response = await http.put(
        Uri.parse('$_baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(user.toJson()),
      ).timeout(AppConfig.apiTimeout);
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': User.fromJson(data['user']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? '프로필 업데이트에 실패했습니다',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }
  
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConfig.authTokenKey);
      
      if (token != null) {
        await http.post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(AppConfig.apiTimeout);
      }
    } catch (e) {
      // 로그아웃 요청 실패해도 로컬 토큰은 삭제
    }
  }
  
  // 카카오 로그인
  Future<Map<String, dynamic>> loginWithKakao() async {
    try {
      // 카카오 로그인
      kakao.OAuthToken token;
      if (await kakao.isKakaoTalkInstalled()) {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }
      
      // 카카오 사용자 정보 가져오기
      final user = await kakao.UserApi.instance.me();
      
      // 서버에 카카오 로그인 정보 전송
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/kakao'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'access_token': token.accessToken,
          'kakao_id': user.id.toString(),
          'email': user.kakaoAccount?.email,
          'name': user.kakaoAccount?.profile?.nickname,
          'profile_image': user.kakaoAccount?.profile?.profileImageUrl,
        }),
      ).timeout(AppConfig.apiTimeout);
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': User.fromJson(data['user']),
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? '카카오 로그인에 실패했습니다',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '카카오 로그인 중 오류가 발생했습니다: $e',
      };
    }
  }
  
  // 구글 로그인
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return {
          'success': false,
          'message': '구글 로그인이 취소되었습니다',
        };
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // 서버에 구글 로그인 정보 전송
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/google'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'access_token': googleAuth.accessToken,
          'id_token': googleAuth.idToken,
          'google_id': googleUser.id,
          'email': googleUser.email,
          'name': googleUser.displayName,
          'profile_image': googleUser.photoUrl,
        }),
      ).timeout(AppConfig.apiTimeout);
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': User.fromJson(data['user']),
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? '구글 로그인에 실패했습니다',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '구글 로그인 중 오류가 발생했습니다: $e',
      };
    }
  }
}
