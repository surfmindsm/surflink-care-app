import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/user.dart';
import '../../models/request.dart';
import '../../config/app_config.dart';
import '../../widgets/freelancer_card.dart';
import '../../services/freelancer_service.dart';
import '../../components/index.dart' as C;

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
  String _sortOption = '추천순'; // 추천순, 평점순, 리뷰많은순
  final List<String> _sortOptions = const ['추천순', '평점순', '리뷰많은순'];

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

  void _loadFreelancers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final freelancers = await freelancerService.getFreelancers(
        searchQuery: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        serviceType: _selectedServiceType,
        region: _selectedRegion,
        minRating: _minRating,
        limit: 50, // 충분한 개수로 설정
      );

      setState(() {
        _freelancers = freelancers;
        _filteredFreelancers = freelancers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('전문가 목록을 불러오는데 실패했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
        
        // API 실패 시 임시로 샘플 데이터 사용
        setState(() {
          _freelancers = _getSampleFreelancers();
          _filteredFreelancers = _freelancers;
        });
      }
    }
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
    // API에서 이미 필터링된 데이터를 가져오므로 로컬 필터링 대신 재검색
    _loadFreelancers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('커뮤니티'),
        actions: [
          IconButton(
            tooltip: '정렬',
            onPressed: _showSortSheet,
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            tooltip: '필터',
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
    return Padding(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: C.AppSearchInput(
        placeholder: '이름, 소개 검색...',
        controller: _searchController,
        onSubmitted: (_) => _filterFreelancers(),
        onClear: _filterFreelancers,
        size: C.InputSize.md,
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
      return Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding * 2),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              C.AppIcon.iconify(icon: 'mdi:account-search-outline', size: 64, semanticLabel: '검색 결과 없음'),
              const SizedBox(height: 16),
              Text(
                '조건에 맞는 프리랜서가 없습니다',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '필터를 조정하거나 검색어를 변경해 보세요.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              C.OutlineButton(
                text: '필터 초기화',
                icon: Icons.refresh,
                onPressed: () {
                  setState(() {
                    _selectedServiceType = null;
                    _selectedRegion = null;
                    _minRating = null;
                  });
                  _searchController.clear();
                  _filterFreelancers();
                },
              ),
            ],
          ),
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
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FreelancerCard(
              freelancer: freelancer,
              onTap: () => context.push('/freelancers/${freelancer.id}'),
            ),
          );
        },
      ),
    );
  }

  void _showSortSheet() {
    C.AppSheet.showMenu(
      context,
      title: '정렬',
      items: _sortOptions.map((o) {
        final selected = o == _sortOption;
        return C.AppSheetMenuItem(
          title: selected ? '$o (선택됨)' : o,
          icon: selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          onTap: () {
            setState(() {
              _sortOption = o;
              _filteredFreelancers = List<User>.from(_freelancers);
              if (o == '평점순') {
                _filteredFreelancers.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
              } else if (o == '리뷰많은순') {
                _filteredFreelancers.sort((a, b) => (b.reviewCount ?? 0).compareTo(a.reviewCount ?? 0));
              }
            });
          },
        );
      }).toList(),
    );
  }

  void _showFilterDialog() {
    C.AppSheet.showBottomSheet(
      context,
      title: '필터',
      child: StatefulBuilder(
        builder: (context, setModalState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('서비스 유형', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Column(
              children: [
                RadioListTile<ServiceType?>(
                  value: null,
                  groupValue: _selectedServiceType,
                  title: const Text('전체'),
                  onChanged: (v) => setModalState(() => _selectedServiceType = null),
                ),
                ...ServiceType.values.map((type) => RadioListTile<ServiceType?>(
                      value: type,
                      groupValue: _selectedServiceType,
                      title: Text(type.label),
                      onChanged: (v) => setModalState(() => _selectedServiceType = v),
                    )),
              ],
            ),

            const SizedBox(height: 16),
            const Text('지역', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _regions.map((region) {
                final selected = _selectedRegion == region || (region == '전체' && _selectedRegion == null);
                return ChoiceChip(
                  label: Text(region),
                  selected: selected,
                  onSelected: (val) => setModalState(() => _selectedRegion = (region == '전체') ? null : region),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            const Text('최소 평점', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [4.0, 4.5, 4.8].map((rating) {
                return ChoiceChip(
                  label: Text('★ $rating 이상'),
                  selected: _minRating == rating,
                  onSelected: (val) => setModalState(() => _minRating = val ? rating : null),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: C.OutlineButton(
                    text: '초기화',
                    onPressed: () {
                      setModalState(() {
                        _selectedServiceType = null;
                        _selectedRegion = null;
                        _minRating = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: C.PrimaryButton(
                    text: '적용',
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {});
                      _filterFreelancers();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
