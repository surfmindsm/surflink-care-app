import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  
  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isResending = false;
  String _errorMessage = '';
  int _remainingTime = 300; // 5분 = 300초
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _startTimer();
    // 화면 진입 시 자동으로 인증코드 발송
    _sendEmailCode();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }
  
  void _startTimer() {
    _timer?.cancel();
    _remainingTime = 300; // 5분 리셋
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
      }
    });
  }
  
  String get _formatTime {
    final minutes = _remainingTime ~/ 60;
    final seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  Future<void> _sendEmailCode() async {
    setState(() {
      _isResending = true;
      _errorMessage = '';
    });
    
    try {
      await _authService.sendEmailVerificationCode(widget.email);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.email}로 인증번호가 발송되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        _startTimer(); // 타이머 재시작
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '인증번호 발송에 실패했습니다. 잠시 후 다시 시도해 주세요.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }
  
  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    
    if (code.isEmpty) {
      setState(() {
        _errorMessage = '인증번호를 입력해주세요.';
      });
      return;
    }
    
    if (code.length != 6) {
      setState(() {
        _errorMessage = '인증번호는 6자리입니다.';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final isValid = await _authService.verifyEmailCode(widget.email, code);
      
      if (isValid && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이메일 인증이 완료되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 인증 완료 후 회원가입 완료 페이지로 이동
        context.go('/register/complete', extra: widget.email);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = '인증에 실패했습니다. 잠시 후 다시 시도해 주세요.';
        
        if (e.toString().contains('만료')) {
          errorMessage = '인증번호가 만료되었습니다. 재전송 해주세요.';
        } else if (e.toString().contains('올바르지 않습니다')) {
          errorMessage = '인증번호가 올바르지 않습니다.';
        }
        
        setState(() {
          _errorMessage = errorMessage;
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
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
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            
            // 아이콘
            Icon(
              Icons.email_outlined,
              size: 80,
              color: Colors.blue[700],
            ),
            
            const SizedBox(height: 32),
            
            // 제목
            const Text(
              '이메일 인증',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // 안내 메시지
            Text(
              '${widget.email}로\n인증번호가 발송되었습니다.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '6자리 인증번호를 입력해주세요.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // 인증번호 입력 필드
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                hintText: '000000',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  letterSpacing: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                counterText: '', // 글자수 카운터 숨김
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) {
                setState(() {
                  _errorMessage = '';
                });
                
                // 6자리 입력 시 자동 검증
                if (value.length == 6) {
                  _verifyCode();
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // 에러 메시지
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            const SizedBox(height: 32),
            
            // 인증 버튼
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '인증 완료',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            
            const SizedBox(height: 24),
            
            // 타이머 및 재전송 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_remainingTime > 0) ...[
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                
                TextButton(
                  onPressed: _isResending || (_remainingTime > 240) // 1분 후부터 재전송 가능
                      ? null
                      : _sendEmailCode,
                  child: _isResending
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _remainingTime <= 0 ? '인증번호 재전송' : '재전송',
                          style: TextStyle(
                            color: _remainingTime > 240
                                ? Colors.grey[400]
                                : Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // 도움말
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '도움말',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 인증번호가 오지 않으면 스팸메일함을 확인해주세요.\n'
                    '• 인증번호는 5분간 유효합니다.\n'
                    '• 1분 후부터 재전송이 가능합니다.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
