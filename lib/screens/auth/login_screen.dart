import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';
import '../../widgets/social_login_button.dart';
import '../../components/index.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _rememberMe = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    print('[로그] 로그인 시도: 이메일=${_emailController.text.trim()}');
    // AppInput/AppPasswordInput은 validator를 제공하지 않으므로 수동 검증
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    String? emailErr;
    String? passwordErr;
    if (email.isEmpty) {
      emailErr = '이메일 또는 휴대폰번호를 입력해주세요';
    }
    if (password.isEmpty) {
      passwordErr = '비밀번호를 입력해주세요';
    }
    if (emailErr != null || passwordErr != null) {
      setState(() {
        _emailError = emailErr;
        _passwordError = passwordErr;
      });
      print('[로그] 폼 검증 실패');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    print('[로그] 로그인 결과: $success, 에러: [31m${authProvider.error}[0m');

    if (success && mounted) {
      print('[로그] 로그인 성공, 홈으로 이동');
      context.go('/home');
    } else if (mounted && authProvider.error != null) {
      print('[로그] 로그인 실패, 에러 다이얼로그 표시');
      _showErrorDialog(authProvider.error!);
    }
  }

  Widget _buildErrorContent(String message) {
    final bool showSignupHint = message.contains('이메일 또는 비밀번호가 올바르지 않습니다') ||
        message.contains('등록되지 않은 이메일');
    
    List<Widget> children = [Text(message)];
    
    if (showSignupHint) {
      children.addAll([
        const SizedBox(height: 16),
        const Text(
          '혹시 아직 회원가입을 하지 않으셨나요?',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.orange,
          ),
        ),
      ]);
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그인 실패'),
        content: _buildErrorContent(message),
        actions: [
          if (message.contains('이메일 또는 비밀번호가 올바르지 않습니다') ||
              message.contains('등록되지 않은 이메일'))
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/register');
              },
              child: const Text('회원가입'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // 로고 및 헤더
              _buildHeader(),
              
              const SizedBox(height: 48),
              
              // 로그인 폼
              _buildLoginForm(),
              
              const SizedBox(height: 24),
              
              // 로그인 버튼
              _buildLoginButton(),
              
              const SizedBox(height: 16),
              
              // 비밀번호 찾기
              _buildForgotPassword(),
              
              const SizedBox(height: 32),
              
              // 구분선
              _buildDivider(),
              
              const SizedBox(height: 24),
              
              // 소셜 로그인
              _buildSocialLogin(),
              
              const SizedBox(height: 32),
              
              // 회원가입 링크
              _buildSignupLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Color(AppConfig.primaryColor),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.favorite_border,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppConfig.appName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(AppConfig.primaryColor),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '안전하고 신뢰할 수 있는\n돌봄 서비스를 만나보세요',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 이메일 입력
          AppInput(
            label: '이메일 또는 휴대폰번호',
            placeholder: '이메일 또는 휴대폰번호',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            errorText: _emailError,
            onChanged: (v) {
              if (_emailError != null) {
                setState(() => _emailError = null);
              }
            },
          ),
          
          const SizedBox(height: 16),
          
          // 비밀번호 입력
          AppPasswordInput(
            label: '비밀번호',
            controller: _passwordController,
            errorText: _passwordError,
            onChanged: (v) {
              if (_passwordError != null) {
                setState(() => _passwordError = null);
              }
            },
            size: InputSize.md,
          ),
          
          const SizedBox(height: 16),
          
          // 로그인 유지
          AppCheckbox.simple(
            value: _rememberMe,
            onChanged: (value) {
              setState(() {
                _rememberMe = value ?? false;
              });
            },
            label: '로그인 상태 유지',
            size: CheckboxSize.md,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            text: '로그인',
            onPressed: authProvider.isLoading ? null : _login,
            isLoading: authProvider.isLoading,
            size: ButtonSize.lg,
          ),
        );
      },
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: () => context.push('/password-reset'),
      child: const Text('비밀번호를 잊으셨나요?'),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '또는',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          children: [
            // 카카오 로그인
            SocialLoginButton(
              text: '카카오로 시작하기',
              backgroundColor: const Color(0xFFFEE500),
              textColor: Colors.black87,
              icon: Icons.chat_bubble,
              onPressed: authProvider.isLoading ? null : () async {
                final success = await authProvider.loginWithKakao();
                if (success && mounted) {
                  context.go('/home');
                } else if (mounted && authProvider.error != null) {
                  _showErrorDialog(authProvider.error!);
                }
              },
            ),
            
            const SizedBox(height: 12),
            
            // 구글 로그인
            SocialLoginButton(
              text: '구글로 시작하기',
              backgroundColor: Colors.white,
              textColor: Colors.black87,
              icon: Icons.g_mobiledata,
              borderColor: Colors.grey[300],
              onPressed: authProvider.isLoading ? null : () async {
                final success = await authProvider.loginWithGoogle();
                if (success && mounted) {
                  context.go('/home');
                } else if (mounted && authProvider.error != null) {
                  _showErrorDialog(authProvider.error!);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSignupLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('계정이 없으신가요? '),
        TextButton(
          onPressed: () => context.push('/register'),
          child: const Text(
            '회원가입',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
