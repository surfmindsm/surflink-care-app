import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../config/app_config.dart';
import '../../widgets/profile_info_card.dart';
import '../../widgets/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('프로필'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/profile/edit'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConfig.defaultPadding),
            child: Column(
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 24),
                
                if (user.isFreelancer) ...[
                  _buildFreelancerStats(user),
                  const SizedBox(height: 24),
                ],
                
                _buildProfileInfo(user),
                const SizedBox(height: 24),
                
                _buildMenuSection(context, user),
                const SizedBox(height: 24),
                
                _buildAccountSection(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(AppConfig.primaryColor),
            Color(AppConfig.primaryColor).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: user.profileImageUrl != null
                    ? NetworkImage(user.profileImageUrl!)
                    : null,
                child: user.profileImageUrl == null
                    ? Icon(
                        Icons.person,
                        size: 50,
                        color: Color(AppConfig.primaryColor),
                      )
                    : null,
              ),
              if (user.isVerified == true)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.isFreelancer ? '프리랜서' : '고객',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          if (user.isFreelancer && user.specialties != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: user.specialties!.take(3).map((specialty) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    specialty,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFreelancerStats(User user) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${user.rating?.toStringAsFixed(1) ?? "0.0"}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '평점',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Text(
                  '${user.reviewCount ?? 0}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '리뷰',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Text(
                  '${user.careerYears ?? 0}년',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '경력',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(User user) {
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
        const SizedBox(height: 12),
        ProfileInfoCard(
          items: [
            ProfileInfoItem(
              label: '이메일',
              value: user.email,
              icon: Icons.email_outlined,
            ),
            if (user.phone != null)
              ProfileInfoItem(
                label: '전화번호',
                value: user.phone!,
                icon: Icons.phone_outlined,
              ),
            if (user.region != null)
              ProfileInfoItem(
                label: '지역',
                value: user.region!,
                icon: Icons.location_on_outlined,
              ),
            if (user.birth != null)
              ProfileInfoItem(
                label: '생년월일',
                value: '${user.birth!.year}.${user.birth!.month.toString().padLeft(2, '0')}.${user.birth!.day.toString().padLeft(2, '0')}',
                icon: Icons.cake_outlined,
              ),
            if (user.isFreelancer && user.introduction != null)
              ProfileInfoItem(
                label: '자기소개',
                value: user.introduction!,
                icon: Icons.description_outlined,
                maxLines: 3,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context, User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '서비스',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              if (user.isFreelancer) ...[
                ProfileMenuItem(
                  icon: Icons.work_outline,
                  title: '내 서비스 관리',
                  subtitle: '제공하는 서비스를 관리하세요',
                  onTap: () {
                    // TODO: 서비스 관리 화면으로 이동
                  },
                ),
                const Divider(height: 1),
                ProfileMenuItem(
                  icon: Icons.analytics_outlined,
                  title: '수익 현황',
                  subtitle: '수익과 통계를 확인하세요',
                  onTap: () {
                    // TODO: 수익 현황 화면으로 이동
                  },
                ),
                const Divider(height: 1),
              ] else ...[
                ProfileMenuItem(
                  icon: Icons.list_alt_outlined,
                  title: '내 의뢰',
                  subtitle: '등록한 의뢰를 확인하세요',
                  onTap: () => context.go('/requests'),
                ),
                const Divider(height: 1),
              ],
              ProfileMenuItem(
                icon: Icons.star_outline,
                title: '리뷰 관리',
                subtitle: '받은 리뷰를 확인하세요',
                onTap: () {
                  // TODO: 리뷰 관리 화면으로 이동
                },
              ),
              const Divider(height: 1),
              ProfileMenuItem(
                icon: Icons.payment_outlined,
                title: '결제 내역',
                subtitle: '결제 및 정산 내역을 확인하세요',
                onTap: () {
                  // TODO: 결제 내역 화면으로 이동
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '계정',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              ProfileMenuItem(
                icon: Icons.settings_outlined,
                title: '설정',
                subtitle: '앱 설정을 변경하세요',
                onTap: () => context.go('/settings'),
              ),
              const Divider(height: 1),
              ProfileMenuItem(
                icon: Icons.help_outline,
                title: '고객센터',
                subtitle: '문의사항이 있으시면 연락하세요',
                onTap: () {
                  // TODO: 고객센터 화면으로 이동
                },
              ),
              const Divider(height: 1),
              ProfileMenuItem(
                icon: Icons.logout,
                title: '로그아웃',
                subtitle: '계정에서 로그아웃합니다',
                textColor: Colors.red,
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text(
              '로그아웃',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
