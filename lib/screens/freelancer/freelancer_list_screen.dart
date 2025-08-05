import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/user.dart';
import '../../models/request.dart';
import '../../config/app_config.dart';
import '../../widgets/freelancer_card.dart';

class FreelancerListScreen extends StatefulWidget {
  const FreelancerListScreen({super.key});

  @override
  State<FreelancerListScreen> createState() => _FreelancerListScreenState();
}

class _FreelancerListScreenState extends State<FreelancerListScreen> {
  final _searchController = TextEditingController();
  List<User> _freelancers = [];
  List<User> _filteredFreelancers = [];
  bool _isLoading = true;
  ServiceType? _selectedServiceType;
  String? _selectedRegion;
  double? _minRating;

  final List<String> _regions = [
    '전체',
    '강남구',
    '서초구',
    '송파구',
    '강동구',
    '마포구',
    '영등포구',
    '관악구',
    '동작구',
  ];

  @override
  void initState() {
    super.initState();
    _loadFreelancers();
    _searchController.addListener(_filterFreelancers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadFreelancers() {
    // TODO: 실제 API 호출로 대체
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _freelancers = _getSampleFreelancers();
        _filteredFreelancers = _freelancers;
        _isLoading = false;
      });
    });
  }

  List<User> _getSampleFreelancers() {
    return [
      User(
        id: 'freelancer1',
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
        introduction: '아이들을 사랑하는 마음으로 정성껓 돌보겠습니다.',
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
        updatedAt: DateTime.now().subtract(const Duration(days: 100)),
      ),
      User(
        id: 'freelancer2',
        email: 'caregiver1@example.com',
        name: '박간병사',
        phone: '010-2222-2222',
        userType: UserType.freelancer,
        status: UserStatus.active,
        profileImageUrl: null,
        region: '서초구',
        rating: 4.9,
        reviewCount: 38,
        specialties: ['eldercare'],
        careerYears: 8,
        introduction: '어르신들을 가족처럼 생각하며 섬기겠습니다.',
        createdAt: DateTime.now().subtract(const Duration(days: 80)),
        updatedAt: DateTime.now().subtract(const Duration(days: 80)),
      ),
      User(
        id: 'freelancer3',
        email: 'counselor1@example.com',
        name: '이상담사',
        phone: '010-3333-3333',
        userType: UserType.freelancer,
        status: UserStatus.active,
        profileImageUrl: null,
        region: '강남구',
        rating: 4.7,
        reviewCount: 21,
        specialties: ['counseling'],
        careerYears: 3,
        introduction: '진심어린 마음으로 상담해드리겠습니다.',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];
  }

  void _filterFreelancers() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredFreelancers = _freelancers.where((freelancer) {
        final matchesSearch = query.isEmpty ||
            freelancer.name.toLowerCase().contains(query) ||
            freelancer.introduction?.toLowerCase().contains(query) == true;
        
        final matchesServiceType = _selectedServiceType == null ||
            freelancer.specialties?.contains(_selectedServiceType!.name) == true;
        
        final matchesRegion = _selectedRegion == null ||
            _selectedRegion == '전체' ||
            freelancer.region == _selectedRegion;
        
        final matchesRating = _minRating == null ||
            (freelancer.rating ?? 0) >= _minRating!;
        
        return matchesSearch && matchesServiceType && matchesRegion && matchesRating;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프리랜서 찾기'),
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildFreelancerList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: '이름, 소개 검색...',
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final hasFilters = _selectedServiceType != null ||
        (_selectedRegion != null && _selectedRegion != '전체') ||
        _minRating != null;

    if (!hasFilters) return const SizedBox.shrink();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (_selectedServiceType != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_selectedServiceType!.label),
                onSelected: (value) {},
                onDeleted: () {
                  setState(() {
                    _selectedServiceType = null;
                  });
                  _filterFreelancers();
                },
              ),
            ),
          if (_selectedRegion != null && _selectedRegion != '전체')
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_selectedRegion!),
                onSelected: (value) {},
                onDeleted: () {
                  setState(() {
                    _selectedRegion = null;
                  });
                  _filterFreelancers();
                },
              ),
            ),
          if (_minRating != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('★ $_minRating 이상'),
                onSelected: (value) {},
                onDeleted: () {
                  setState(() {
                    _minRating = null;
                  });
                  _filterFreelancers();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFreelancerList() {
    if (_filteredFreelancers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '조건에 맞는 프리랜서가 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadFreelancers();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        itemCount: _filteredFreelancers.length,
        itemBuilder: (context, index) {
          final freelancer = _filteredFreelancers[index];
          return FreelancerCard(
            freelancer: freelancer,
            onTap: () => context.push('/freelancers/${freelancer.id}'),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '필터',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // 서비스 유형
              const Text('서비스 유형'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('전체'),
                    selected: _selectedServiceType == null,
                    onSelected: (selected) {
                      if (selected) {
                        setModalState(() {
                          _selectedServiceType = null;
                        });
                      }
                    },
                  ),
                  ...ServiceType.values.map((type) {
                    return FilterChip(
                      label: Text(type.label),
                      selected: _selectedServiceType == type,
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedServiceType = selected ? type : null;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 지역
              const Text('지역'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _regions.map((region) {
                  return FilterChip(
                    label: Text(region),
                    selected: _selectedRegion == region ||
                        (region == '전체' && _selectedRegion == null),
                    onSelected: (selected) {
                      setModalState(() {
                        _selectedRegion = selected && region != '전체' ? region : null;
                      });
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // 평점
              const Text('최소 평점'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [4.0, 4.5, 4.8].map((rating) {
                  return FilterChip(
                    label: Text('★ $rating 이상'),
                    selected: _minRating == rating,
                    onSelected: (selected) {
                      setModalState(() {
                        _minRating = selected ? rating : null;
                      });
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedServiceType = null;
                          _selectedRegion = null;
                          _minRating = null;
                        });
                      },
                      child: const Text('초기화'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {});
                        _filterFreelancers();
                      },
                      child: const Text('적용'),
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
}
