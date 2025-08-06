import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailConfirmScreen extends StatefulWidget {
  final String? code;
  
  const EmailConfirmScreen({super.key, this.code});

  @override
  State<EmailConfirmScreen> createState() => _EmailConfirmScreenState();
}

class _EmailConfirmScreenState extends State<EmailConfirmScreen> {
  bool _isLoading = true;
  bool _isSuccess = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _handleEmailConfirmation();
  }

  Future<void> _handleEmailConfirmation() async {
    if (widget.code == null || widget.code!.isEmpty) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _message = '잘못된 인증 링크입니다.';
      });
      return;
    }

    try {
      // Supabase 이메일 인증 처리
      final response = await Supabase.instance.client.auth.verifyOTP(
        token: widget.code!,
        type: OtpType.email,
      );

      if (response.user != null) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
          _message = '이메일 인증이 완료되었습니다!\n이제 로그인할 수 있습니다.';
        });

        // 3초 후 로그인 페이지로 이동
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            context.go('/login');
          }
        });
      } else {
        throw Exception('인증에 실패했습니다.');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _message = '이메일 인증에 실패했습니다.\n${error.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이메일 인증'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                const Text(
                  '이메일 인증을 처리하고 있습니다...',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Icon(
                  _isSuccess ? Icons.check_circle : Icons.error,
                  size: 80,
                  color: _isSuccess ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 24),
                Text(
                  _message,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (_isSuccess) ...[
                  const Text(
                    '잠시 후 로그인 페이지로 이동합니다...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('로그인 페이지로 이동'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
