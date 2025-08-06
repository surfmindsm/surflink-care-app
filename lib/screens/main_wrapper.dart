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
        }
      });
    }
  }

  void _onBottomNavTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/home');
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
