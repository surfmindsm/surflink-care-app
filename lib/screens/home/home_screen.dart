import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../models/request.dart';
import '../../config/app_config.dart';
import '../../widgets/service_type_card.dart';
import '../../widgets/recent_activity_card.dart';
import '../../widgets/quick_action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        // 홈 - 이미 홈 화면
        break;
      case 1:
        context.go('/requests');
        break;
      case 2:
        context.go('/freelancers');
        break;
      case 3:
        context.go('/chats');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildServiceTypes(),
              const SizedBox(height: 32),
              _buildQuickActions(),
              const SizedBox(height: 32),
              _buildRecentActivity(),
              const SizedBox(height: 32),
              _buildRecommendations(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        return Container(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(AppConfig.primaryColor),
                Color(AppConfig.primaryColor).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.isFreelancer == true ? '안녕하세요, ${user?.name}님!' : '필요한 서비스를 찾아보세요',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.isFreelancer == true 
                            ? '새로운 의뢰를 확인해보세요'
                            : '신뢰할 수 있는 전문가들이 기다리고 있어요',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                        onPressed: () {
                          // TODO: 알림 화면으로 이동
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.white),
                        onPressed: () => context.go('/settings'),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 검색바
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: user?.isFreelancer == true ? '원하는 의뢰를 검색하세요' : '필요한 서비스를 검색하세요',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onTap: () {
                    // TODO: 검색 화면으로 이동
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceTypes() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
              child: Text(
                user?.isFreelancer == true ? '서비스 분야' : '어떤 서비스가 필요하신가요?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
                children: [
                  ServiceTypeCard(
                    title: '돌봄',
                    subtitle: '아이 돌봄 서비스',
                    icon: Icons.child_care,
                    color: Colors.pink,
                    onTap: () {
                      if (user?.isFreelancer == true) {
                        context.go('/freelancers?type=childcare');
                      } else {
                        context.go('/requests/create?type=childcare');
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  ServiceTypeCard(
                    title: '간병',
                    subtitle: '어르신 간병 서비스',
                    icon: Icons.elderly,
                    color: Colors.orange,
                    onTap: () {
                      if (user?.isFreelancer == true) {
                        context.go('/freelancers?type=eldercare');
                      } else {
                        context.go('/requests/create?type=eldercare');
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  ServiceTypeCard(
                    title: '튜터링',
                    subtitle: '학습 지도 서비스',
                    icon: Icons.school,
                    color: Colors.blue,
                    onTap: () {
                      if (user?.isFreelancer == true) {
                        context.go('/freelancers?type=tutoring');
                      } else {
                        context.go('/requests/create?type=tutoring');
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  ServiceTypeCard(
                    title: '심리상담',
                    subtitle: '전문 심리 상담',
                    icon: Icons.psychology,
                    color: Colors.green,
                    onTap: () {
                      if (user?.isFreelancer == true) {
                        context.go('/freelancers?type=counseling');
                      } else {
                        context.go('/requests/create?type=counseling');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
              child: Text(
                '빠른 메뉴',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
              child: Row(
                children: user?.isFreelancer == true ? [
                  Expanded(
                    child: QuickActionButton(
                      title: '새 의뢰 찾기',
                      icon: Icons.search,
                      color: Colors.blue,
                      onTap: () => context.go('/requests'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickActionButton(
                      title: '내 프로필',
                      icon: Icons.person,
                      color: Colors.green,
                      onTap: () => context.go('/profile'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickActionButton(
                      title: '수익 현황',
                      icon: Icons.analytics,
                      color: Colors.orange,
                      onTap: () {
                        // TODO: 수익 현황 화면으로 이동
                      },
                    ),
                  ),
                ] : [
                  Expanded(
                    child: QuickActionButton(
                      title: '의뢰 등록',
                      icon: Icons.add,
                      color: Colors.blue,
                      onTap: () => context.go('/requests/create'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickActionButton(
                      title: '전문가 찾기',
                      icon: Icons.people,
                      color: Colors.green,
                      onTap: () => context.go('/freelancers'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickActionButton(
                      title: '내 의뢰',
                      icon: Icons.list,
                      color: Colors.orange,
                      onTap: () => context.go('/requests'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '최근 활동',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 전체 활동 내역 화면으로 이동
                },
                child: const Text('전체 보기'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // 최근 활동 목록 (임시 데이터)
        const RecentActivityCard(
          title: '아이 돌봄 의뢰가 매칭되었습니다',
          subtitle: '김민정 프리랜서와 연결되었습니다',
          time: '2시간 전',
          icon: Icons.child_care,
          color: Colors.pink,
        ),
        const RecentActivityCard(
          title: '새로운 메시지가 도착했습니다',
          subtitle: '박선생님이 메시지를 보냈습니다',
          time: '1일 전',
          icon: Icons.message,
          color: Colors.blue,
        ),
        const RecentActivityCard(
          title: '서비스 완료 후기를 작성해주세요',
          subtitle: '영어 과외 서비스가 완료되었습니다',
          time: '3일 전',
          icon: Icons.star,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildRecommendations() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
              child: Text(
                user?.isFreelancer == true ? '추천 의뢰' : '추천 전문가',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(AppConfig.primaryColor),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              user?.isFreelancer == true 
                                  ? '아이 돌봄 의뢰'
                                  : '김민정 선생님',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.isFreelancer == true 
                                  ? '강남구 • 월~금 오후'
                                  : '영어, 수학 전문',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 12, color: Colors.orange),
                                const SizedBox(width: 2),
                                Text(
                                  '4.${8 + index}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const Spacer(),
                                Text(
                                  user?.isFreelancer == true 
                                      ? '시급 15,000원'
                                      : '시급 20,000원',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        return BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onBottomNavTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(AppConfig.primaryColor),
          unselectedItemColor: Colors.grey,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.list_alt_outlined),
              activeIcon: const Icon(Icons.list_alt),
              label: user?.isFreelancer == true ? '의뢰' : '내 의뢰',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people_outline),
              activeIcon: const Icon(Icons.people),
              label: user?.isFreelancer == true ? '경쟁자' : '전문가',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: '채팅',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: '프로필',
            ),
          ],
        );
      },
    );
  }
}
