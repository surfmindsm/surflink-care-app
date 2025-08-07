import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/password_reset_screen.dart';
import '../screens/auth/email_confirm_screen.dart';
// import '../screens/auth/email_verification_screen.dart'; // 사용 안 함
import '../screens/auth/register_complete_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/request/request_list_screen.dart';
import '../screens/request/create_request_screen.dart';
import '../screens/request/request_detail_screen.dart';
import '../screens/freelancer/freelancer_list_screen.dart';
import '../screens/freelancer/freelancer_detail_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/api_test_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/payment/payment_screen.dart';
import '../screens/notification/notification_screen.dart';
import '../screens/report/report_screen.dart';
import '../screens/report/report_create_screen.dart';
import '../screens/settlement/settlement_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/activity/activity_screen.dart';
import '../screens/main_wrapper.dart';
import '../providers/auth_provider.dart';
import '../models/chat.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login' || 
                           state.matchedLocation == '/register' ||
                           state.matchedLocation == '/password-reset' ||
                           // state.matchedLocation == '/register/email-verification' ||
                           state.matchedLocation == '/register/complete' ||
                           state.matchedLocation.startsWith('/auth/');
        
        // 로그인되지 않은 경우
        if (!isLoggedIn) {
          // 스플래시 화면이나 로그인 관련 화면이 아니면 로그인으로 리다이렉트
          if (state.matchedLocation != '/splash' && !isLoggingIn) {
            return '/login';
          }
        }
        
        // 이미 로그인된 경우 로그인 화면들에서 홈으로 리다이렉트
        if (isLoggedIn && isLoggingIn) {
          return '/home';
        }
        
        return null;
      },
      routes: [
        // Splash
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        
        // Authentication Routes
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/password-reset',
          builder: (context, state) => const PasswordResetScreen(),
        ),
        
        // Email Confirmation Route
        GoRoute(
          path: '/auth/confirm',
          builder: (context, state) {
            final code = state.uri.queryParameters['code'];
            return EmailConfirmScreen(code: code);
          },
        ),
        
        // Email Verification Routes (사용 안 함 - 도메인 구매 필요)
        /*
        GoRoute(
          path: '/register/email-verification',
          builder: (context, state) {
            final email = state.extra as String? ?? '';
            return EmailVerificationScreen(email: email);
          },
        ),
        */
        GoRoute(
          path: '/register/complete',
          builder: (context, state) {
            final email = state.extra as String? ?? '';
            return RegisterCompleteScreen(email: email);
          },
        ),
        
        // Main App Routes with MainWrapper
        GoRoute(
          path: '/home',
          builder: (context, state) => MainWrapper(
            child: const HomeScreen(),
            location: state.matchedLocation,
          ),
        ),
        
        // Profile Routes  
        GoRoute(
          path: '/profile',
          builder: (context, state) => MainWrapper(
            child: const ProfileScreen(),
            location: state.matchedLocation,
          ),
        ),
        GoRoute(
          path: '/profile/edit',
          builder: (context, state) => const EditProfileScreen(),
        ),
        
        // Request Routes
        GoRoute(
          path: '/requests',
          builder: (context, state) => MainWrapper(
            child: const RequestListScreen(),
            location: state.matchedLocation,
          ),
        ),
        GoRoute(
          path: '/requests/create',
          builder: (context, state) => const CreateRequestScreen(),
        ),
        GoRoute(
          path: '/requests/:id',
          builder: (context, state) {
            final requestId = state.pathParameters['id']!;
            return RequestDetailScreen(requestId: requestId);
          },
        ),
        
        // Freelancer Routes
        GoRoute(
          path: '/freelancers',
          builder: (context, state) => MainWrapper(
            child: const FreelancerListScreen(),
            location: state.matchedLocation,
          ),
        ),
        GoRoute(
          path: '/freelancers/:id',
          builder: (context, state) {
            final freelancerId = state.pathParameters['id']!;
            return FreelancerDetailScreen(freelancerId: freelancerId);
          },
        ),
        
        // Chat Routes
        GoRoute(
          path: '/chats',
          builder: (context, state) => MainWrapper(
            child: const ChatListScreen(),
            location: state.matchedLocation,
          ),
        ),
        GoRoute(
          path: '/chat/:roomId',
          builder: (context, state) {
            final roomId = state.pathParameters['roomId']!;
            
            // extra가 Map<String, dynamic>인 경우 ChatRoom으로 변환
            ChatRoom? chatRoom;
            if (state.extra != null) {
              if (state.extra is ChatRoom) {
                chatRoom = state.extra as ChatRoom;
              } else if (state.extra is Map<String, dynamic>) {
                try {
                  chatRoom = ChatRoom.fromJson(state.extra as Map<String, dynamic>);
                } catch (e) {
                  print('ChatRoom 변환 실패: $e');
                  chatRoom = null;
                }
              }
            }
            
            if (chatRoom != null) {
              return ChatScreen(chatRoom: chatRoom);
            } else {
              // ChatRoom 정보가 없을 때의 처리
              return Scaffold(
                appBar: AppBar(
                  title: const Text('채팅'),
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
                body: const Center(
                  child: Text('채팅방 정보를 불러올 수 없습니다.'),
                ),
              );
            }
          },
        ),
        
        // Payment Routes
        GoRoute(
          path: '/payment',
          builder: (context, state) => const PaymentScreen(),
        ),
        
        // Notification Routes
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationScreen(),
        ),
        
        // Report Routes
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportScreen(),
        ),
        GoRoute(
          path: '/reports/create',
          builder: (context, state) => const ReportCreateScreen(),
        ),
        
        // Settlement Routes
        GoRoute(
          path: '/settlement',
          builder: (context, state) => MainWrapper(
            child: const SettlementScreen(),
            location: state.matchedLocation,
          ),
        ),
        
        // Search Routes
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        
        // Activity Routes
        GoRoute(
          path: '/activity',
          builder: (context, state) => const ActivityScreen(),
        ),
        
        // Settings
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/settings/api-test',
          builder: (context, state) => const ApiTestScreen(),
        ),
      ],
      
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                '페이지를 찾을 수 없습니다',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('홈으로 가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
