import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';
import '../../widgets/social_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      context.go('/home');
    } else if (mounted && authProvider.error != null) {
      _showErrorDialog(authProvider.error!);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그인 실패'),
        content: Text(message),
        actions: [
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
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: '이메일 또는 휴대폰번호',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이메일 또는 휴대폰번호를 입력해주세요';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // 비밀번호 입력
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: '비밀번호',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력해주세요';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // 로그인 유지
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),
              const Text('로그인 상태 유지'),
            ],
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
          height: 48,
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _login,
            child: authProvider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('로그인'),
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
