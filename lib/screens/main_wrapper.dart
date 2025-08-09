import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../config/app_config.dart';

class MainWrapper extends StatefulWidget {
  final Widget child;
  final String? location;

  const MainWrapper({
    super.key,
    required this.child,
    this.location,
  });

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();



  @override
  void initState() {
    super.initState();
    _updateSelectedIndex();
  }

  @override
  void didUpdateWidget(MainWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _updateSelectedIndex();
    }
  }

  void _updateSelectedIndex() {
    if (widget.location != null) {
      setState(() {
        if (widget.location!.startsWith('/home') || widget.location == '/') {
          _selectedIndex = 0;
        } else if (widget.location!.startsWith('/requests')) {
          _selectedIndex = 1;
        } else if (widget.location!.startsWith('/freelancers')) {
          _selectedIndex = 2;
        } else if (widget.location!.startsWith('/chats')) {
          _selectedIndex = 3;
        } else if (widget.location!.startsWith('/profile')) {
          _selectedIndex = 4;
        } else if (widget.location!.startsWith('/settlement')) {
          _selectedIndex = 4; // 수익 화면도 4번 인덱스
        }
      });
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isFreelancer = authProvider.currentUser?.isFreelancer == true;

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        // 프리랜서: 일거리 (의뢰 목록), 고객: 내 의뢰
        context.go('/requests');
        break;
      case 2:
        // 프리랜서: 커뮤니티 (다른 프리랜서 목록), 고객: 전문가
        context.go('/freelancers');
        break;
      case 3:
        context.go('/chats');
        break;
      case 4:
        if (isFreelancer) {
          context.go('/settlement');
        } else {
          context.go('/profile');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _shouldShowBottomNav() ? _buildBottomNavigationBar() : null,
    );
  }

  bool _shouldShowBottomNav() {
    if (widget.location == null) return false;
    
    // 하단 네비게이션을 숨길 경로들
    final hideNavPaths = [
      '/login',
      '/register',
      '/password-reset',
      '/splash',
    ];

    return !hideNavPaths.any((path) => widget.location!.startsWith(path));
  }

  Widget _buildBottomNavigationBar() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final isFreelancer = user?.isFreelancer == true;
        
        return BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onBottomNavTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(AppConfig.primaryColor),
          unselectedItemColor: Colors.grey,
          // 라벨/아이콘 크기를 동일하게 고정해서 클릭 시 레이아웃 점프(흔들림) 방지
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedIconTheme: const IconThemeData(size: 24),
          unselectedIconTheme: const IconThemeData(size: 24),
          showUnselectedLabels: true,
          showSelectedLabels: true,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(isFreelancer ? Icons.work_outline : Icons.list_alt_outlined),
              activeIcon: Icon(isFreelancer ? Icons.work : Icons.list_alt),
              label: isFreelancer ? '일거리' : '내 의뢰',
            ),
            BottomNavigationBarItem(
              icon: Icon(isFreelancer ? Icons.group_outlined : Icons.people_outline),
              activeIcon: Icon(isFreelancer ? Icons.group : Icons.people),
              label: isFreelancer ? '커뮤니티' : '전문가',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: '채팅',
            ),
            BottomNavigationBarItem(
              icon: Icon(isFreelancer ? Icons.account_balance_wallet_outlined : Icons.person_outline),
              activeIcon: Icon(isFreelancer ? Icons.account_balance_wallet : Icons.person),
              label: isFreelancer ? '수익' : '마이',
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
