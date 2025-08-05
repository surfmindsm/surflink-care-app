import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../config/app_config.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _regionController = TextEditingController();
  final _introductionController = TextEditingController();
  
  DateTime? _selectedBirth;
  String? _selectedGender;
  List<String> _selectedSpecialties = [];
  int? _careerYears;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _regionController.text = user.region ?? '';
      _introductionController.text = user.introduction ?? '';
      _selectedBirth = user.birth;
      _selectedGender = user.gender;
      _selectedSpecialties = user.specialties ?? [];
      _careerYears = user.careerYears;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _regionController.dispose();
    _introductionController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser!;
    
    final updatedUser = user.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      region: _regionController.text.trim().isEmpty ? null : _regionController.text.trim(),
      birth: _selectedBirth,
      gender: _selectedGender,
      introduction: _introductionController.text.trim().isEmpty ? null : _introductionController.text.trim(),
      specialties: _selectedSpecialties.isEmpty ? null : _selectedSpecialties,
      careerYears: _careerYears,
    );

    final success = await authProvider.updateProfile(updatedUser);

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필이 업데이트되었습니다')),
      );
      context.pop();
    } else if (mounted && authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('저장'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 이미지
              _buildProfileImage(),
              const SizedBox(height: 32),
              
              // 기본 정보
              _buildBasicInfo(),
              const SizedBox(height: 24),
              
              // 프리랜서 추가 정보
              if (user?.isFreelancer == true) ...[
                _buildFreelancerInfo(),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.grey[400],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // TODO: 이미지 선택 기능
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Color(AppConfig.primaryColor),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '기본 정보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // 이름
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '이름',
            prefixIcon: Icon(Icons.person_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '이름을 입력해주세요';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // 전화번호
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: '전화번호',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 지역
        TextFormField(
          controller: _regionController,
          decoration: const InputDecoration(
            labelText: '지역',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 생년월일
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedBirth ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
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
    );
  }

  Widget _buildFreelancerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '프리랜서 정보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // 전문 분야
        const Text(
          '전문 분야',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['돌봄', '간병', '튜터링', '심리상담'].map((specialty) {
            return FilterChip(
              label: Text(specialty),
              selected: _selectedSpecialties.contains(specialty),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSpecialties.add(specialty);
                  } else {
                    _selectedSpecialties.remove(specialty);
                  }
                });
              },
            );
          }).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // 경력 기간
        DropdownButtonFormField<int>(
          value: _careerYears,
          decoration: const InputDecoration(
            labelText: '경력 기간',
            prefixIcon: Icon(Icons.work_outline),
          ),
          items: List.generate(21, (index) {
            return DropdownMenuItem(
              value: index,
              child: Text(index == 0 ? '신입' : '${index}년'),
            );
          }),
          onChanged: (value) {
            setState(() {
              _careerYears = value;
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        // 자기소개
        TextFormField(
          controller: _introductionController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: '자기소개',
            prefixIcon: Icon(Icons.description_outlined),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}
