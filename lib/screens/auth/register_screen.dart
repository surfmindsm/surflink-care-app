import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../config/app_config.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  
  // Step 1: 회원 유형 선택
  UserType? _selectedUserType;
  
  // Step 2: 기본 정보
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Step 3: 추가 정보
  DateTime? _selectedBirth;
  String? _selectedGender;
  
  // Step 4: 약관 동의
  bool _agreeTerms = false;
  bool _agreePrivacy = false;
  bool _agreeMarketing = false;
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _register();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _selectedUserType != null;
      case 1:
        // 기본 정보 단계: 필수 필드가 모두 입력되었는지 확인
        return _emailController.text.isNotEmpty &&
               _passwordController.text.isNotEmpty &&
               _confirmPasswordController.text.isNotEmpty &&
               _nameController.text.isNotEmpty &&
               _emailController.text.contains('@') &&
               _passwordController.text.length >= 6 &&
               _passwordController.text == _confirmPasswordController.text;
      case 2:
        return true; // 추가 정보는 선택사항
      case 3:
        return _agreeTerms && _agreePrivacy;
      default:
        return false;
    }
  }

  Future<void> _register() async {
    if (!_validateCurrentStep()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      userType: _selectedUserType!,
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      birth: _selectedBirth,
      gender: _selectedGender,
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
        title: const Text('회원가입 실패'),
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
        title: const Text('회원가입'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
      ),
      body: Column(
        children: [
          // 진행 표시기
          _buildProgressIndicator(),
          
          // 페이지 내용
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildUserTypeStep(),
                _buildBasicInfoStep(),
                _buildAdditionalInfoStep(),
                _buildTermsStep(),
              ],
            ),
          ),
          
          // 하단 버튼
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? Color(AppConfig.primaryColor)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUserTypeStep() {
    return Padding(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '어떤 서비스를 이용하시나요?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '가입 후에도 언제든지 변경할 수 있습니다',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          // 프리랜서 선택
          _UserTypeCard(
            title: '프리랜서로 가입',
            subtitle: '돌봄·간병·튜터링·상담 서비스를 제공합니다',
            icon: Icons.work_outline,
            isSelected: _selectedUserType == UserType.freelancer,
            onTap: () {
              setState(() {
                _selectedUserType = UserType.freelancer;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // 고객 선택
          _UserTypeCard(
            title: '고객으로 가입',
            subtitle: '돌봄·간병·튜터링·상담 서비스를 이용합니다',
            icon: Icons.person_outline,
            isSelected: _selectedUserType == UserType.customer,
            onTap: () {
              setState(() {
                _selectedUserType = UserType.customer;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '기본 정보를 입력해주세요',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              
              // 이메일
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: '이메일',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                onChanged: (value) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해주세요';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return '올바른 이메일 형식을 입력해주세요';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 비밀번호
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
                onChanged: (value) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요';
                  }
                  if (value.length < AppConfig.minPasswordLength) {
                    return '비밀번호는 ${AppConfig.minPasswordLength}자 이상이어야 합니다';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 비밀번호 확인
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                onChanged: (value) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호 확인을 입력해주세요';
                  }
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 이름
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '이름',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
                onChanged: (value) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 휴대폰번호
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: '휴대폰번호 (선택)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '추가 정보 (선택)',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '더 나은 서비스 제공을 위해 입력해주세요',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          // 생년월일
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
                firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _selectedBirth = date;
                });
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: '생년월일',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                _selectedBirth != null
                    ? '${_selectedBirth!.year}.${_selectedBirth!.month.toString().padLeft(2, '0')}.${_selectedBirth!.day.toString().padLeft(2, '0')}'
                    : '생년월일을 선택해주세요',
                style: TextStyle(
                  color: _selectedBirth != null ? null : Colors.grey,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 성별
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(
              labelText: '성별',
              prefixIcon: Icon(Icons.person_outline),
            ),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('남성')),
              DropdownMenuItem(value: 'female', child: Text('여성')),
              DropdownMenuItem(value: 'other', child: Text('기타')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTermsStep() {
    return Padding(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '약관에 동의해주세요',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          
          // 이용약관 동의
          CheckboxListTile(
            title: const Text('이용약관 동의 (필수)'),
            subtitle: const Text('서비스 이용을 위해 필요합니다'),
            value: _agreeTerms,
            onChanged: (value) {
              setState(() {
                _agreeTerms = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          
          // 개인정보처리방침 동의
          CheckboxListTile(
            title: const Text('개인정보처리방침 동의 (필수)'),
            subtitle: const Text('개인정보 보호를 위해 필요합니다'),
            value: _agreePrivacy,
            onChanged: (value) {
              setState(() {
                _agreePrivacy = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          
          // 마케팅 정보 수신 동의
          CheckboxListTile(
            title: const Text('마케팅 정보 수신 동의 (선택)'),
            subtitle: const Text('새로운 서비스 소식을 받아보세요'),
            value: _agreeMarketing,
            onChanged: (value) {
              setState(() {
                _agreeMarketing = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: authProvider.isLoading || !_validateCurrentStep()
                  ? null
                  : _nextStep,
              child: authProvider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(_currentStep < 3 ? '다음' : '회원가입 완료'),
            ),
          );
        },
      ),
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Color(AppConfig.primaryColor) : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Color(AppConfig.primaryColor).withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? Color(AppConfig.primaryColor) : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Color(AppConfig.primaryColor) : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Color(AppConfig.primaryColor),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
