import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SharedPreferences _prefs;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  AuthProvider(this._prefs) {
    _initializeAuth();
  }
  
  Future<void> _initializeAuth() async {
    _setLoading(true);
    try {
      final token = _prefs.getString(AppConfig.authTokenKey);
      
      if (token != null) {
        // 저장된 토큰으로 사용자 정보 가져오기
        final user = await _authService.getCurrentUser();
        if (user != null) {
          _currentUser = user;
        } else {
          // 토큰이 만료되었거나 유효하지 않음
          await _clearAuth();
        }
      }
    } catch (e) {
      _setError('인증 초기화 중 오류가 발생했습니다: $e');
      await _clearAuth();
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.login(email, password);
      
      if (result['success'] == true) {
        _currentUser = result['user'];
        
        // 토큰과 사용자 정보 저장
        await _prefs.setString(AppConfig.authTokenKey, result['token']);
        await _prefs.setString(AppConfig.userIdKey, _currentUser!.id);
        await _prefs.setString(AppConfig.userTypeKey, _currentUser!.userType.toString().split('.').last);
        
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? '로그인에 실패했습니다');
        return false;
      }
    } catch (e) {
      _setError('로그인 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required UserType userType,
    String? phone,
    DateTime? birth,
    String? gender,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.register(
        email: email,
        password: password,
        name: name,
        userType: userType,
        phone: phone,
        birth: birth,
        gender: gender,
      );
      
      if (result['success'] == true) {
        _currentUser = result['user'];
        
        // 토큰과 사용자 정보 저장
        await _prefs.setString(AppConfig.authTokenKey, result['token']);
        await _prefs.setString(AppConfig.userIdKey, _currentUser!.id);
        await _prefs.setString(AppConfig.userTypeKey, _currentUser!.userType.toString().split('.').last);
        
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? '회원가입에 실패했습니다');
        return false;
      }
    } catch (e) {
      print('AuthProvider register error: $e');
      // 백엔드 개발자 API 기반 에러 처리
      if (e.toString().contains('Exception: ')) {
        final cleanError = e.toString().replaceFirst('Exception: ', '');
        // 백엔드에서 전달한 구체적인 에러 메시지 사용
        _setError(cleanError);
      } else if (e.toString().contains('FunctionException')) {
        if (e.toString().contains('status: 400')) {
          _setError('입력한 정보를 확인해주세요. 이미 사용 중인 이메일일 수 있습니다.');
        } else {
          _setError('서버에서 회원가입을 처리할 수 없습니다. 잠시 후 다시 시도해주세요.');
        }
      } else {
        _setError('네트워크 연결을 확인해주세요.');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _authService.resetPassword(email);
      
      if (success) {
        return true;
      } else {
        _setError('비밀번호 재설정에 실패했습니다');
        return false;
      }
    } catch (e) {
      _setError('비밀번호 재설정 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> updateProfile(User updatedUser) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.updateProfile(updatedUser);
      
      if (result['success'] == true) {
        _currentUser = result['user'];
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? '프로필 업데이트에 실패했습니다');
        return false;
      }
    } catch (e) {
      _setError('프로필 업데이트 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authService.logout();
      await _clearAuth();
    } catch (e) {
      _setError('로그아웃 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _clearAuth() async {
    _currentUser = null;
    
    await _prefs.remove(AppConfig.authTokenKey);
    await _prefs.remove(AppConfig.userIdKey);
    await _prefs.remove(AppConfig.userTypeKey);
    
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
  
  // 소셜 로그인 메서드들
  Future<bool> loginWithKakao() async {
    _setLoading(true);
    _clearError();
    
    try {
      // 카카오 로그인은 아직 미구현
      _setError('카카오 로그인은 아직 지원되지 않습니다.');
      return false;
    } catch (e) {
      _setError('카카오 로그인 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.signInWithGoogle();
      
      if (result['success'] == true) {
        _currentUser = result['user'];
        
        await _prefs.setString(AppConfig.authTokenKey, result['token']);
        await _prefs.setString(AppConfig.userIdKey, _currentUser!.id);
        await _prefs.setString(AppConfig.userTypeKey, _currentUser!.userType.toString().split('.').last);
        
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? '카카오 로그인에 실패했습니다');
        return false;
      }
    } catch (e) {
      _setError('카카오 로그인 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
