import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/password_reset_screen.dart';
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
import '../screens/splash/splash_screen.dart';
import '../screens/payment/payment_screen.dart';
import '../screens/notification/notification_screen.dart';
import '../screens/report/report_screen.dart';
import '../screens/report/report_create_screen.dart';
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
                           state.matchedLocation == '/password-reset';
        
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
        
        // Main App Routes
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        
        // Profile Routes
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/profile/edit',
          builder: (context, state) => const EditProfileScreen(),
        ),
        
        // Request Routes
        GoRoute(
          path: '/requests',
          builder: (context, state) => const RequestListScreen(),
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
          builder: (context, state) => const FreelancerListScreen(),
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
          builder: (context, state) => const ChatListScreen(),
        ),
        GoRoute(
          path: '/chat/:roomId',
          builder: (context, state) {
            final roomId = state.pathParameters['roomId']!;
            final chatRoom = state.extra as ChatRoom?;
            
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
        
        // Settings
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
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
