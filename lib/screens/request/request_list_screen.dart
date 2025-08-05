import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/request.dart';
import '../../config/app_config.dart';
import '../../widgets/request_card.dart';

class RequestListScreen extends StatefulWidget {
  const RequestListScreen({super.key});

  @override
  State<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<ServiceRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadRequests() {
    // TODO: 실제 API 호출로 대체
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _requests = _getSampleRequests();
        _isLoading = false;
      });
    });
  }

  List<ServiceRequest> _getSampleRequests() {
    return [
      ServiceRequest(
        id: '1',
        customerId: 'customer1',
        serviceType: ServiceType.childcare,
        title: '7세 아이 돌봄 부탁드려요',
        description: '평일 오후 2시~6시까지 아이 돌봄을 부탁드립니다.',
        region: '강남구 역삼동',
        startDate: DateTime.now().add(const Duration(days: 1)),
        preferredTimes: ['14:00-18:00'],
        conditions: {'age': 7, 'gender': 'any'},
        attachments: [],
        status: RequestStatus.pending,
        budget: 15000,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ServiceRequest(
        id: '2',
        customerId: 'customer1',
        serviceType: ServiceType.tutoring,
        title: '중학생 수학 과외',
        description: '중2 수학 내신 대비 과외를 구합니다.',
        region: '서초구 서초동',
        startDate: DateTime.now().add(const Duration(days: 3)),
        preferredTimes: ['19:00-21:00'],
        conditions: {'subject': 'math', 'level': 'middle'},
        attachments: [],
        status: RequestStatus.matched,
        budget: 25000,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        matchedFreelancerId: 'freelancer1',
        matchedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }

  List<ServiceRequest> _getFilteredRequests(RequestStatus? status) {
    if (status == null) return _requests;
    return _requests.where((request) => request.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(user?.isFreelancer == true ? '의뢰 찾기' : '내 의뢰'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '전체'),
            Tab(text: '매칭대기'),
            Tab(text: '진행중'),
            Tab(text: '완료'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRequestList(_getFilteredRequests(null)),
                _buildRequestList(_getFilteredRequests(RequestStatus.pending)),
                _buildRequestList(_getFilteredRequests(RequestStatus.inProgress)),
                _buildRequestList(_getFilteredRequests(RequestStatus.completed)),
              ],
            ),
      floatingActionButton: user?.isCustomer == true
          ? FloatingActionButton(
              onPressed: () => context.push('/requests/create'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildRequestList(List<ServiceRequest> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '의뢰가 없습니다',
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
        _loadRequests();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return RequestCard(
            request: request,
            onTap: () => context.push('/requests/${request.id}'),
          );
        },
      ),
    );
  }
}
