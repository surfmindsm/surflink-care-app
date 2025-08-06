import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileViewScreen extends StatefulWidget {
  final String userId;
  final String userType; // 'freelancer' or 'client'
  
  const ProfileViewScreen({
    super.key,
    required this.userId,
    required this.userType,
  });

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late Map<String, dynamic> _userData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.userType == 'freelancer' ? 4 : 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    if (widget.userType == 'freelancer') {
      _userData = _getFreelancerData();
    } else {
      _userData = _getClientData();
    }
  }

  Map<String, dynamic> _getFreelancerData() {
    return {
      'id': widget.userId,
      'name': '김돌봄',
      'age': 32,
      'gender': '여성',
      'location': '서울 강남구',
      'rating': 4.8,
      'review_count': 45,
      'career_years': 5,
      'service_types': ['아이 돌봄', '특수아동 돌봄'],
      'specialties': ['유아돌봄', '초등돌봄', '특수아동', '영어놀이'],
      'available_times': ['평일 오전', '평일 오후', '주말 오전'],
      'hourly_rate': {'min': 15000, 'max': 25000},
      'introduction': '안녕하세요! 5년간 아이들과 함께해온 김돌봄입니다. 아이들의 안전과 건강한 성장을 최우선으로 생각합니다.',
      'certifications': [
        {'name': '보육교사 2급', 'issuer': '한국보육진흥원', 'date': '2019.03.15', 'verified': true},
        {'name': '아동심리상담사', 'issuer': '한국아동심리학회', 'date': '2020.08.22', 'verified': true},
      ],
      'work_experience': [
        {'title': '개인 베이비시터', 'period': '2019.04 ~ 현재', 'description': '0세~10세 아이들의 개인 돌봄 서비스 제공'},
        {'title': '어린이집 보육교사', 'period': '2018.03 ~ 2019.03', 'description': '만 3세 반 담임교사로 근무'},
      ],
      'reviews': [
        {'client_name': '박**', 'rating': 5.0, 'content': '아이가 너무 좋아했어요. 정말 세심하고 친절하십니다.', 'service_type': '아이 돌봄', 'date': DateTime(2024, 7, 1)},
        {'client_name': '김**', 'rating': 4.8, 'content': '쌍둥이 돌봄이 쉽지 않은데 정말 잘 돌봐주셨어요.', 'service_type': '아이 돌봄', 'date': DateTime(2024, 6, 15)},
      ],
      'badges': [
        {'name': '신원인증', 'verified': true},
        {'name': '자격증인증', 'verified': true},
        {'name': '우수평점', 'verified': true},
      ],
      'stats': {'total_services': 45, 'repeat_clients': 12, 'response_rate': 98, 'on_time_rate': 99},
    };
  }

  Map<String, dynamic> _getClientData() {
    return {
      'id': widget.userId,
      'name': '박고객',
      'location': '서울 강남구',
      'rating': 4.5,
      'review_count': 12,
      'member_since': DateTime(2023, 3, 15),
      'service_usage': [
        {'service_type': '아이 돌봄', 'count': 8, 'last_used': DateTime(2024, 6, 30)},
        {'service_type': '튜터링', 'count': 3, 'last_used': DateTime(2024, 5, 15)},
      ],
      'reviews_given': [
        {'freelancer_name': '김**', 'rating': 5.0, 'content': '정말 만족스러운 서비스였습니다.', 'service_type': '아이 돌봄', 'date': DateTime(2024, 6, 30)},
      ],
      'badges': [
        {'name': '신원인증', 'verified': true},
        {'name': '정성리뷰', 'verified': true},
      ],
      'stats': {'total_bookings': 12, 'completed_services': 11, 'average_rating_given': 4.6, 'response_rate': 95},
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 16),
                _buildBadges(),
                const SizedBox(height: 16),
                if (widget.userType == 'freelancer') _buildStats() else _buildClientStats(),
                const SizedBox(height: 16),
              ],
            ),
          ),
          SliverFillRemaining(child: _buildTabContent()),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Colors.blue,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue, Colors.blueAccent],
            ),
          ),
          child: const Center(
            child: Icon(Icons.person, size: 80, color: Colors.white),
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'report', child: Text('신고하기')),
            const PopupMenuItem(value: 'block', child: Text('차단하기')),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[300],
            child: Text(_userData['name'][0], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text(_userData['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          if (widget.userType == 'freelancer') ...[
            Text('${_userData['age']}세 ${_userData['gender']} · ${_userData['location']}', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text('${_userData['rating']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text('(${_userData['review_count']}개 리뷰)'),
                const SizedBox(width: 16),
                Icon(Icons.work, color: Colors.grey[600], size: 16),
                const SizedBox(width: 4),
                Text('경력 ${_userData['career_years']}년'),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _userData['service_types'].map<Widget>((type) => 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(20)),
                  child: Text(type, style: TextStyle(color: Colors.blue[700], fontSize: 12)),
                ),
              ).toList(),
            ),
          ] else ...[
            Text(_userData['location'], style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text('${_userData['rating']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text('(${_userData['review_count']}개 평가)'),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, color: Colors.grey[600], size: 16),
                const SizedBox(width: 4),
                Text('가입 ${DateFormat('yyyy.MM').format(_userData['member_since'])}'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadges() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('인증 배지', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _userData['badges'].map<Widget>((badge) => 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: badge['verified'] ? Colors.green[50] : Colors.grey[50],
                  border: Border.all(color: badge['verified'] ? Colors.green : Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badge['verified'] ? Icons.verified : Icons.pending, size: 16, color: badge['verified'] ? Colors.green : Colors.grey),
                    const SizedBox(width: 4),
                    Text(badge['name'], style: TextStyle(color: badge['verified'] ? Colors.green[700] : Colors.grey[700], fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final stats = _userData['stats'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('활동 통계', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatItem('총 서비스', '${stats['total_services']}건')),
              Expanded(child: _buildStatItem('재이용 고객', '${stats['repeat_clients']}명')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatItem('응답률', '${stats['response_rate']}%')),
              Expanded(child: _buildStatItem('시간준수율', '${stats['on_time_rate']}%')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClientStats() {
    final stats = _userData['stats'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('이용 통계', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatItem('총 예약', '${stats['total_bookings']}건')),
              Expanded(child: _buildStatItem('완료 서비스', '${stats['completed_services']}건')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatItem('평균 평점', '${stats['average_rating_given']}점')),
              Expanded(child: _buildStatItem('응답률', '${stats['response_rate']}%')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildTabContent() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: widget.userType == 'freelancer' 
              ? const [Tab(text: '소개'), Tab(text: '자격증'), Tab(text: '경력'), Tab(text: '리뷰')]
              : const [Tab(text: '서비스 이용'), Tab(text: '작성 리뷰')],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.userType == 'freelancer'
              ? [_buildIntroductionTab(), _buildCertificationsTab(), _buildExperienceTab(), _buildReviewsTab()]
              : [_buildServiceUsageTab(), _buildGivenReviewsTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildIntroductionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('자기소개', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(_userData['introduction']),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('서비스 정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildInfoRow('전문분야', _userData['specialties'].join(', ')),
                _buildInfoRow('가능시간', _userData['available_times'].join(', ')),
                _buildInfoRow('시간당 요금', '₩${NumberFormat('#,###').format(_userData['hourly_rate']['min'])} ~ ₩${NumberFormat('#,###').format(_userData['hourly_rate']['max'])}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userData['certifications'].length,
      itemBuilder: (context, index) {
        final cert = _userData['certifications'][index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Icon(cert['verified'] ? Icons.verified : Icons.pending, color: cert['verified'] ? Colors.green : Colors.orange, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cert['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(cert['issuer'], style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    Text('취득일: ${cert['date']}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              OutlinedButton(onPressed: () => _viewCertificate(cert['name']), child: const Text('보기')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExperienceTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userData['work_experience'].length,
      itemBuilder: (context, index) {
        final exp = _userData['work_experience'][index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(exp['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(exp['period'], style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text(exp['description']),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userData['reviews'].length,
      itemBuilder: (context, index) {
        final review = _userData['reviews'][index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(review['client_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Row(children: List.generate(5, (i) => Icon(Icons.star, size: 16, color: i < review['rating'] ? Colors.amber : Colors.grey[300]))),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(4)),
                    child: Text(review['service_type'], style: TextStyle(color: Colors.blue[700], fontSize: 11)),
                  ),
                  const SizedBox(width: 8),
                  Text(DateFormat('yyyy.MM.dd').format(review['date']), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Text(review['content']),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceUsageTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userData['service_usage'].length,
      itemBuilder: (context, index) {
        final usage = _userData['service_usage'][index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.work, color: Colors.blue[700]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(usage['service_type'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${usage['count']}번 이용', style: TextStyle(color: Colors.grey[600])),
                    Text('최근: ${DateFormat('yyyy.MM.dd').format(usage['last_used'])}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGivenReviewsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userData['reviews_given'].length,
      itemBuilder: (context, index) {
        final review = _userData['reviews_given'][index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('${review['freelancer_name']}에게', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Row(children: List.generate(5, (i) => Icon(Icons.star, size: 16, color: i < review['rating'] ? Colors.amber : Colors.grey[300]))),
                ],
              ),
              const SizedBox(height: 4),
              Text(DateFormat('yyyy.MM.dd').format(review['date']), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              const SizedBox(height: 8),
              Text(review['content']),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _sendMessage,
              icon: const Icon(Icons.chat),
              label: const Text('메시지'),
            ),
          ),
          const SizedBox(width: 12),
          if (widget.userType == 'freelancer')
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _requestMatch,
                icon: const Icon(Icons.handshake),
                label: const Text('매칭 요청'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$action 실행')));
  }

  void _viewCertificate(String certName) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$certName 자격증 보기')));
  }

  void _sendMessage() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('메시지 보내기')));
  }

  void _requestMatch() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('매칭 요청')));
  }
}
