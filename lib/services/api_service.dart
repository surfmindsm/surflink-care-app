import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  final SupabaseClient _supabase = supabase;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: SupabaseConfig.url,
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(milliseconds: 3000),
      headers: {
        'apikey': SupabaseConfig.anonKey,
        'Authorization': 'Bearer ${SupabaseConfig.anonKey}',
        'Content-Type': 'application/json',
      },
    ));

    // Request/Response 인터셉터 추가
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 인증 토큰이 있을 경우 자동으로 헤더에 추가
        final session = _supabase.auth.currentSession;
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        print('API Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  // GET 요청
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST 요청
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT 요청
  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE 요청
  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Supabase Edge Function 호출
  Future<Map<String, dynamic>> invokeFunction(String functionName, {Map<String, dynamic>? body}) async {
    try {
      final response = await _supabase.functions.invoke(
        functionName,
        body: body,
      );
      return response.data;
    } catch (e) {
      print('Supabase Function Error: $e');
      rethrow;
    }
  }

  // Supabase REST API 호출 (테이블 직접 접근)
  SupabaseQueryBuilder from(String table) {
    return _supabase.from(table);
  }

  // 인증 관련
  GoTrueClient get auth => _supabase.auth;

  // 스토리지 관련
  SupabaseStorageClient get storage => _supabase.storage;

  // 에러 핸들링
  Exception _handleError(DioException error) {
    String message;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = '네트워크 연결 시간이 초과되었습니다.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        message = '서버 오류: $statusCode - ${responseData?['message'] ?? '알 수 없는 오류가 발생했습니다.'}';
        break;
      case DioExceptionType.cancel:
        message = '요청이 취소되었습니다.';
        break;
      case DioExceptionType.connectionError:
        message = '네트워크 연결을 확인해주세요.';
        break;
      default:
        message = '알 수 없는 오류가 발생했습니다.';
    }
    return Exception(message);
  }
}

// 전역 API 서비스 인스턴스
final apiService = ApiService();
