import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/user.dart';
import '../../models/request.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';


class FreelancerDetailScreen extends StatefulWidget {
  final String freelancerId;

  const FreelancerDetailScreen({
    super.key,
    required this.freelancerId,
  });

  @override
  State<FreelancerDetailScreen> createState() => _FreelancerDetailScreenState();
}

class _FreelancerDetailScreenState extends State<FreelancerDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  User? _freelancer;
  List<Map<String, dynamic>> _reviews = [];
  List<String> _portfolios = [];
  bool _isLoading = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFreelancerDetail();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadFreelancerDetail() {
    // TODO: 실제 API 호출로 대체
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _freelancer = _getSampleFreelancer();
        _reviews = _getSampleReviews();
        _portfolios = _getSamplePortfolios();
        _isLoading = false;
      });
    });
  }

  User _getSampleFreelancer() {
    return User(
      id: widget.freelancerId,
      email: 'teacher1@example.com',
      name: '김선생님',
      phone: '010-1111-1111',
      userType: UserType.freelancer,
      status: UserStatus.active,
      profileImageUrl: null,
      region: '강남구',
      rating: 4.8,
      reviewCount: 42,
      specialties: ['childcare', 'tutoring'],
      careerYears: 5,
      introduction: '안녕하세요! 아이들을 정말 사랑하고, 교육에 대한 열정이 가득한 김선생님입니다.\n\n5년간의 교육 경험을 바탕으로 각 아이의 개성과 특성을 파악하여 맞춤형 돌봄과 교육을 제공하고 있습니다. 특히 초등학생 돌봄과 학습지도에 특화되어 있으며, 아이들이 안전하고 즐겁게 시간을 보낼 수 있도록 최선을 다하고 있습니다.',
      birth: DateTime(1990, 5, 15),
      gender: '여성',
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
      updatedAt: DateTime.now().subtract(const Duration(days: 100)),
    );
  }

  List<Map<String, dynamic>> _getSampleReviews() {
    return [
      {
        'id': '1',
        'customerName': '박엄마',
        'rating': 5.0,
        'content': '정말 친절하시고 아이를 잘 돌봐주세요. 숙제도 꼼꼼히 봐주시고 아이가 너무 좋아해요!',
        'createdAt': DateTime.now().subtract(const Duration(days: 5)),
        'serviceType': ServiceType.childcare,
      },
      {
        'id': '2',
        'customerName': '이고객',
        'rating': 4.5,
        'content': '시간 약속을 잘 지키시고 아이 돌봄에 경험이 많으신 것 같아요. 추천합니다.',
        'createdAt': DateTime.now().subtract(const Duration(days: 12)),
        'serviceType': ServiceType.tutoring,
      },
    ];
  }

  List<String> _getSamplePortfolios() {
    return [
      '유아교육과 졸업',
      '보육교사 2급 자격증',
      '초등학교 방과후 교사 3년',
      '개인 과외 2년',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_freelancer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('프리랜서 상세')),
        body: const Center(
          child: Text('프리랜서를 찾을 수 없습니다'),
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              expandedHeight: 300,
              floating: false,
              pinned: true,
              actions: [
                IconButton(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : null,
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _buildProfileHeader(),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '프로필'),
                    Tab(text: '리뷰'),
                    Tab(text: '포트폴리오'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProfileTab(),
            _buildReviewTab(),
            _buildPortfolioTab(),
          ],
        ),
      ),
      bottomNavigationBar: currentUser?.isCustomer == true
          ? Container(
              padding: const EdgeInsets.all(AppConfig.defaultPadding),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _startChat,
                      child: const Text('채팅하기'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _requestService,
                      child: const Text('의뢰하기'),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(AppConfig.primaryColor),
            Color(AppConfig.primaryColor).withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _freelancer!.profileImage != null
                  ? NetworkImage(_freelancer!.profileImage!)
                  : null,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: _freelancer!.profileImage == null
                  ? Text(
                      _freelancer!.name[0],
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              _freelancer!.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  size: 20,
                  color: Colors.yellow[300],
                ),
                const SizedBox(width: 4),
                Text(
                  '${_freelancer!.rating} (${_freelancer!.reviewCount})',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  _freelancer!.region ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_freelancer!.specialties?.isNotEmpty == true)
              Wrap(
                spacing: 8,
                children: _freelancer!.specialties!.map((specialty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getSpecialtyLabel(specialty),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfo(),
          const SizedBox(height: 16),
          _buildIntroduction(),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
            _buildInfoRow('경력', '${_freelancer!.careerYears ?? 0}년'),
            _buildInfoRow('성별', _freelancer!.gender ?? '정보 없음'),
            _buildInfoRow('활동 지역', _freelancer!.region ?? '정보 없음'),
            _buildInfoRow('가입일', '${DateTime.now().difference(_freelancer!.createdAt).inDays}일 전'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroduction() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '자기소개',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _freelancer!.introduction ?? '소개글이 없습니다.',
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      review['customerName'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          Icons.star,
                          size: 16,
                          color: i < review['rating']
                              ? Colors.amber[600]
                              : Colors.grey[300],
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  review['content'],
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (review['serviceType'] as ServiceType).label,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${DateTime.now().difference(review['createdAt']).inDays}일 전',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPortfolioTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      itemCount: _portfolios.length,
      itemBuilder: (context, index) {
        final portfolio = _portfolios[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: Text(portfolio),
          ),
        );
      },
    );
  }

  String _getSpecialtyLabel(String specialty) {
    switch (specialty) {
      case 'childcare':
        return '아이 돌봄';
      case 'eldercare':
        return '어르신 돌봄';
      case 'tutoring':
        return '과외/교육';
      case 'counseling':
        return '상담';
      default:
        return specialty;
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? '찜 목록에 추가했습니다' : '찜 목록에서 제거했습니다'),
      ),
    );
  }

  void _startChat() {
    // TODO: 채팅 화면으로 이동
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('채팅 기능은 준비 중입니다')),
    );
  }

  void _requestService() {
    context.push('/requests/create');
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
