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
      connectTimeout: const Duration(milliseconds: 10000), // 회원가입 시간 여유 추가
      receiveTimeout: const Duration(milliseconds: 10000),
      headers: {
        'apikey': SupabaseConfig.anonKey,
        'Authorization': 'Bearer ${SupabaseConfig.anonKey}',
        'Content-Type': 'application/json',
        'X-Client-Info': 'prifree-flutter/1.0.0', // API 문서의 헤더 요구사항
      },
    ));

    // Request/Response 인터셉터 추가
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print('[DIO] $obj'),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // API 문서에 따라 필요한 헤더 추가
        options.headers['apikey'] = SupabaseConfig.anonKey;
        
        // 인증 토큰이 있을 경우 자동으로 헤더에 추가
        final session = _supabase.auth.currentSession;
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        } else {
          // 세션이 없을 때는 anon key 사용
          options.headers['Authorization'] = 'Bearer ${SupabaseConfig.anonKey}';
        }
        
        print('[API Request] ${options.method} ${options.path}');
        print('[API Headers] ${options.headers}');
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('[API Response] ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('[API Error] ${error.requestOptions.method} ${error.requestOptions.path}');
        print('[API Error] ${error.response?.statusCode} - ${error.message}');
        if (error.response?.data != null) {
          print('[API Error Data] ${error.response!.data}');
        }
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
      print('Edge Function 호출: $functionName');
      print('요청 데이터: $body');
      
      // API 문서에 따른 Edge Function 엔드포인트: /functions/v1/$functionName
      final response = await _supabase.functions.invoke(
        functionName,
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${SupabaseConfig.anonKey}', // API 문서 명시
        },
      );
      
      print('Edge Function 응답 상태: ${response.status}');
      print('Edge Function 응답 데이터: ${response.data}');
      
      // 상태 코드에 따른 처리
      if (response.status == 200 || response.status == 201) {
        return response.data ?? {};
      } else if (response.status == 400) {
        // 클라이언트 에러 (Bad Request)
        final errorData = response.data;
        final errorMessage = errorData?['error'] ?? errorData?['message'] ?? '잘못된 요청입니다.';
        throw Exception('Edge Function 에러 (400): $errorMessage');
      } else if (response.status == 401) {
        // 인증 오류
        throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
      } else if (response.status == 500) {
        // 서버 내부 오류
        throw Exception('서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
      } else {
        // 기타 에러
        throw Exception('Edge Function 에러 (${response.status}): ${response.data}');
      }
    } catch (e) {
      print('Supabase Function Error: $e');
      print('Function name: $functionName');
      print('Request body: $body');
      
      // FunctionException의 세부 정보 추출 및 에러 메시지 정리
      if (e.toString().contains('FunctionException')) {
        print('상세 에러 정보: $e');
        
        // FunctionException에서 상태 코드와 메시지 추출 시도
        if (e.toString().contains('status: 400')) {
          if (e.toString().contains('Failed to create user account')) {
            throw Exception('Edge Function: 이미 존재하는 이메일이거나 사용자 생성에 실패했습니다.');
          } else if (e.toString().contains('Database error')) {
            throw Exception('Edge Function: 데이터베이스 오류가 발생했습니다.');
          }
        } else if (e.toString().contains('status: 500')) {
          throw Exception('Edge Function: 서버 내부 오류가 발생했습니다.');
        }
        
        // 일반적인 FunctionException 처리
        throw Exception('Edge Function 오류: ${e.toString()}');
      } else if (e.toString().contains('Network')) {
        throw Exception('네트워크 연결 오류: 인터넷 연결을 확인해주세요.');
      } else if (e.toString().contains('timeout')) {
        throw Exception('요청 시간이 초과되었습니다. 다시 시도해주세요.');
      }
      
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
