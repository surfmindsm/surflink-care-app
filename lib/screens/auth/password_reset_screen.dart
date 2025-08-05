import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(_emailController.text.trim());

    if (success) {
      setState(() {
        _isEmailSent = true;
      });
    } else if (mounted && authProvider.error != null) {
      _showErrorDialog(authProvider.error!);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
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
      appBar: AppBar(
        title: const Text('비밀번호 재설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: _isEmailSent ? _buildSuccessContent() : _buildResetForm(),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        
        // 헤더
        const Text(
          '비밀번호를 재설정하세요',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        const Text(
          '가입 시 사용한 이메일 주소를 입력해주세요.\n비밀번호 재설정 링크를 보내드립니다.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 48),
        
        // 이메일 입력 폼
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: '이메일 주소',
              prefixIcon: Icon(Icons.email_outlined),
              hintText: 'example@email.com',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이메일 주소를 입력해주세요';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return '올바른 이메일 형식을 입력해주세요';
              }
              return null;
            },
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 재설정 버튼
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: authProvider.isLoading ? null : _resetPassword,
                child: authProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('재설정 링크 보내기'),
              ),
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // 로그인 돌아가기
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('로그인 화면으로 돌아가기'),
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 64),
        
        // 성공 아이콘
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Color(AppConfig.secondaryColor),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 성공 메시지
        const Text(
          '이메일을 보냈습니다!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        Text(
          '${_emailController.text}으로\n비밀번호 재설정 링크를 보냈습니다.\n\n이메일을 확인하고 링크를 클릭하여\n새로운 비밀번호를 설정해주세요.',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 48),
        
        // 이메일 다시 보내기
        OutlinedButton(
          onPressed: () {
            setState(() {
              _isEmailSent = false;
            });
          },
          child: const Text('다른 이메일로 재설정'),
        ),
        
        const SizedBox(height: 16),
        
        // 로그인으로 돌아가기
        ElevatedButton(
          onPressed: () => context.go('/login'),
          child: const Text('로그인 화면으로 가기'),
        ),
        
        const SizedBox(height: 32),
        
        // 도움말
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '이메일이 오지 않나요?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• 스팸/정크 메일함을 확인해보세요\n• 이메일 주소가 정확한지 확인해보세요\n• 몇 분 후에 다시 시도해보세요',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
