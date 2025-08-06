class AppConfig {
  // App Information
  static const String appName = '프리프리';
  static const String appSubtitle = '돌봄·간병·튜터링·심리상담 프리랜서 매칭 플랫폼';
  static const String appVersion = '1.0.0';
  
  // API Configuration - API 문서에 명시된 공식 설정
  static const String supabaseUrl = 'https://eeprrrbqhufhduvbzftv.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVlcHJycmJxaHVmaGR1dmJ6ZnR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0NTUwNTQsImV4cCI6MjA3MDAzMTA1NH0.Bt5eTr4ZYT9jpYex_wFFqLr4rk9_yZBi5So-o9K0m9w';
  
  // Service Role Key (개발 용도만 - RLS 우회용)
  // 주의: 실제 프로덕션에서는 서버에서만 사용해야 함
  static const String supabaseServiceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVlcHJycmJxaHVmaGR1dmJ6ZnR2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDQ1NTA1NCwiZXhwIjoyMDcwMDMxMDU0fQ.zCJJ_bj4kdw6GgPEEt8Q0qD5eIYNjNlNEzwvYmGJhac';
  
  // API Endpoints - API 문서 기준
  static const String authSignupEndpoint = '/functions/v1/auth-signup';  // 회원가입 Edge Function
  static const String authTokenEndpoint = '/auth/v1/token';            // 로그인
  static const String sendEmailCodeEndpoint = '/send-email-code';      // 이메일 인증코드 발송
  static const String verifyEmailCodeEndpoint = '/verify-email-code';  // 이메일 인증코드 검증
  static const String createRequestEndpoint = '/functions/v1/create-request'; // 의뢰 생성
  static const String serviceRequestsEndpoint = '/rest/v1/service_requests';   // 의뢰 REST API
  static const String matchingsEndpoint = '/rest/v1/matchings';              // 매칭 REST API
  static const String paymentsEndpoint = '/rest/v1/payments';                // 결제 REST API
  
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration functionTimeout = Duration(seconds: 15); // Edge Function용
  
  // Authentication
  static const String authTokenKey = 'auth_token';
  static const String userTypeKey = 'user_type';
  static const String userIdKey = 'user_id';
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedDocTypes = ['pdf', 'doc', 'docx'];
  
  // Chat
  static const String socketUrl = 'ws://socket.prifree.com';
  
  // Social Login
  static const String kakaoAppKey = 'YOUR_KAKAO_APP_KEY';
  static const String googleClientId = 'YOUR_GOOGLE_CLIENT_ID';
  
  // Firebase
  static const String firebaseProjectId = 'prifree-app';
  
  // Feature Flags
  static const bool enableSocialLogin = true;
  static const bool enablePushNotifications = true;
  static const bool enableChat = true;
  static const bool enablePayment = true;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardRadius = 12.0;
  static const double buttonRadius = 8.0;
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxUsernameLength = 20;
  static const int maxReviewLength = 500;
  
  // Colors
  static const int primaryColor = 0xFF2196F3;
  static const int secondaryColor = 0xFF4CAF50;
  static const int errorColor = 0xFFFF5722;
  static const int warningColor = 0xFFFF9800;
}
