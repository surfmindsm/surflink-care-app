import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';
import '../../widgets/profile_menu_item.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          // 계정 설정
          _buildSection(
            title: '계정 설정',
            children: [
              ProfileMenuItem(
                icon: Icons.person_outline,
                title: '프로필 수정',
                onTap: () => context.push('/profile/edit'),
              ),
              ProfileMenuItem(
                icon: Icons.security,
                title: '비밀번호 변경',
                onTap: () => _showPasswordChangeDialog(),
              ),
              ProfileMenuItem(
                icon: Icons.phone,
                title: '연락처 변경',
                onTap: () => _showContactChangeDialog(),
              ),
            ],
          ),

          // 알림 설정
          _buildSection(
            title: '알림 설정',
            children: [
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: '푸시 알림',
                subtitle: '새로운 의뢰, 채팅 메시지 등',
                value: _pushNotifications,
                onChanged: (value) => setState(() => _pushNotifications = value),
              ),
              _buildSwitchTile(
                icon: Icons.email_outlined,
                title: '이메일 알림',
                subtitle: '중요한 공지사항, 계약 관련',
                value: _emailNotifications,
                onChanged: (value) => setState(() => _emailNotifications = value),
              ),
            ],
          ),

          // 앱 설정
          _buildSection(
            title: '앱 설정',
            children: [
              _buildSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: '다크 모드',
                subtitle: '어두운 테마 사용',
                value: _darkMode,
                onChanged: (value) => setState(() => _darkMode = value),
              ),
              ProfileMenuItem(
                icon: Icons.language,
                title: '언어 설정',
                subtitle: '한국어',
                onTap: () => _showLanguageDialog(),
              ),
            ],
          ),

          // 이용 약관 및 정책
          _buildSection(
            title: '이용 약관 및 정책',
            children: [
              ProfileMenuItem(
                icon: Icons.description_outlined,
                title: '이용약관',
                onTap: () => _showTermsDialog(),
              ),
              ProfileMenuItem(
                icon: Icons.privacy_tip_outlined,
                title: '개인정보처리방침',
                onTap: () => _showPrivacyDialog(),
              ),
              ProfileMenuItem(
                icon: Icons.help_outline,
                title: '고객센터',
                onTap: () => _showSupportDialog(),
              ),
            ],
          ),

          // 기타
          _buildSection(
            title: '기타',
            children: [
              ProfileMenuItem(
                icon: Icons.info_outline,
                title: '앱 정보',
                subtitle: 'v${AppConfig.appVersion}',
                onTap: () => _showAppInfoDialog(),
              ),
              ProfileMenuItem(
                icon: Icons.rate_review_outlined,
                title: '앱 평가하기',
                onTap: () => _showRatingDialog(),
              ),
              if (user?.isFreelancer == true)
                ProfileMenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: '정산 관리',
                  onTap: () => _showPaymentDialog(),
                ),
            ],
          ),

          // 로그아웃
          _buildSection(
            title: '',
            children: [
              ProfileMenuItem(
                icon: Icons.logout,
                title: '로그아웃',
                titleColor: Colors.red,
                onTap: () => _showLogoutDialog(),
              ),
              ProfileMenuItem(
                icon: Icons.delete_outline,
                title: '회원탈퇴',
                titleColor: Colors.red,
                onTap: () => _showDeleteAccountDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConfig.defaultPadding,
              24,
              AppConfig.defaultPadding,
              8,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
        Card(
          margin: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Color(AppConfig.primaryColor),
      ),
    );
  }

  void _showPasswordChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('비밀번호 변경'),
        content: const Text('비밀번호 변경 기능은 준비 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showContactChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('연락처 변경'),
        content: const Text('연락처 변경 기능은 준비 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('언어 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('한국어'),
              value: 'ko',
              groupValue: 'ko',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: 'ko',
              onChanged: (value) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('언어 변경 기능은 준비 중입니다')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이용약관'),
        content: const Text('이용약관 내용을 여기에 표시합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개인정보처리방침'),
        content: const Text('개인정보처리방침 내용을 여기에 표시합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('고객센터'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('이메일: support@prifree.com'),
            SizedBox(height: 8),
            Text('전화: 1588-1234'),
            SizedBox(height: 8),
            Text('운영시간: 평일 09:00 - 18:00'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showAppInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${AppConfig.appName} v${AppConfig.appVersion}'),
            const SizedBox(height: 8),
            const Text('프리랜서 중개 플랫폼'),
            const SizedBox(height: 8),
            const Text('© 2024 PRIFREE'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 평가하기'),
        content: const Text('앱스토어로 이동하여 평가해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('앱스토어 연동 기능은 준비 중입니다')),
              );
            },
            child: const Text('평가하기'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정산 관리'),
        content: const Text('정산 관리 기능은 준비 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (mounted) {
                context.go('/login');
              }
            },
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원탈퇴'),
        content: const Text(
          '정말 회원탈퇴하시겠습니까?\n\n'
          '탈퇴 시 모든 데이터가 삭제되며 복구할 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('회원탈퇴 기능은 준비 중입니다')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );
  }
}
