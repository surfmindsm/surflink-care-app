import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  bool _isLoading = false;
  String _searchQuery = '';
  
  List<dynamic> _searchResults = [];
  List<String> _recentSearches = [];
  List<String> _popularKeywords = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    setState(() {
      _recentSearches = [
        '아이 돌봄',
        '영어 과외',
        '심리 상담',
        '간병 서비스',
      ];
      _popularKeywords = [
        '아이 돌봄',
        '영어',
        '수학',
        '간병',
        '심리상담',
        '방문',
        '강남구',
        '주말',
      ];
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchQuery = query.trim();
    });

    // 최근 검색어에 추가
    if (!_recentSearches.contains(_searchQuery)) {
      _recentSearches.insert(0, _searchQuery);
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
    }

    // TODO: 실제 API 호출로 대체
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _searchResults = _getSampleSearchResults();
        _isLoading = false;
      });
    });
  }

  List<dynamic> _getSampleSearchResults() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    
    if (user?.isFreelancer == true) {
      // 프리랜서용 - 의뢰 검색 결과
      return [
        {
          'type': 'request',
          'id': '1',
          'title': '6세 아이 돌봄 서비스 요청',
          'description': '주중 오후 2시-6시, 강남구 역삼동',
          'price': 15000,
          'location': '강남구 역삼동',
          'postedDate': DateTime.now().subtract(const Duration(hours: 2)),
          'serviceType': '아이 돌봄',
          'urgent': true,
        },
        {
          'type': 'request',
          'id': '2',
          'title': '중학교 영어 과외 선생님 구합니다',
          'description': '주 2회, 화목 오후 7시-9시',
          'price': 25000,
          'location': '서초구 서초동',
          'postedDate': DateTime.now().subtract(const Duration(hours: 5)),
          'serviceType': '튜터링',
          'urgent': false,
        },
      ];
    } else {
      // 고객용 - 프리랜서 검색 결과
      return [
        {
          'type': 'freelancer',
          'id': '1',
          'name': '김선생님',
          'profileImage': null,
          'specialties': ['아이 돌봄', '영어'],
          'experience': 5,
          'rating': 4.9,
          'reviewCount': 127,
          'hourlyRate': 20000,
          'location': '강남구',
          'isVerified': true,
          'responseTime': '평균 2시간',
        },
        {
          'type': 'freelancer',
          'id': '2',
          'name': '박상담사',
          'profileImage': null,
          'specialties': ['심리상담', '아동상담'],
          'experience': 8,
          'rating': 4.8,
          'reviewCount': 89,
          'hourlyRate': 35000,
          'location': '서초구',
          'isVerified': true,
          'responseTime': '평균 1시간',
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text('검색'),
        backgroundColor: Color(AppConfig.primaryColor),
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(AppConfig.defaultPadding),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '서비스나 전문가를 검색하세요',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: _performSearch,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ),
      ),
      body: _searchQuery.isEmpty 
          ? _buildInitialContent()
          : _buildSearchResults(),
    );
  }

  Widget _buildInitialContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            _buildSectionHeader('최근 검색', onClear: () {
              setState(() {
                _recentSearches.clear();
              });
            }),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((search) => _buildChip(
                search,
                onTap: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
                onDelete: () {
                  setState(() {
                    _recentSearches.remove(search);
                  });
                },
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],
          
          _buildSectionHeader('인기 검색어'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularKeywords.map((keyword) => _buildChip(
              keyword,
              onTap: () {
                _searchController.text = keyword;
                _performSearch(keyword);
              },
            )).toList(),
          ),
          
          const SizedBox(height: 32),
          _buildQuickCategories(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onClear}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onClear != null)
          TextButton(
            onPressed: onClear,
            child: const Text('전체 삭제'),
          ),
      ],
    );
  }

  Widget _buildChip(String text, {VoidCallback? onTap, VoidCallback? onDelete}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '카테고리별 찾기',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3,
          children: [
            _buildCategoryCard('아이 돌봄', Icons.child_care, Colors.pink),
            _buildCategoryCard('간병 서비스', Icons.elderly, Colors.orange),
            _buildCategoryCard('튜터링', Icons.school, Colors.blue),
            _buildCategoryCard('심리 상담', Icons.psychology, Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        _searchController.text = title;
        _performSearch(title);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('검색 중...'),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '다른 키워드로 검색해보세요',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        
        if (result['type'] == 'freelancer') {
          return _buildFreelancerCard(result);
        } else {
          return _buildRequestCard(result);
        }
      },
    );
  }

  Widget _buildFreelancerCard(Map<String, dynamic> freelancer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.go('/freelancers/${freelancer['id']}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Color(AppConfig.primaryColor),
                child: freelancer['profileImage'] != null
                    ? ClipOval(
                        child: Image.network(
                          freelancer['profileImage'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        freelancer['name'][0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          freelancer['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (freelancer['isVerified']) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 16,
                            color: Colors.blue,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      freelancer['specialties'].join(', '),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              '${freelancer['rating']} (${freelancer['reviewCount']})',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${freelancer['experience']}년 경력',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${freelancer['location']} • ${freelancer['responseTime']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '시급 ${freelancer['hourlyRate'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}원',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.go('/requests/${request['id']}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          request['serviceType'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (request['urgent']) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '급구',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    _formatTimeAgo(request['postedDate']),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                request['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                request['description'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        request['location'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '시급 ${request['price'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}원',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }
}
