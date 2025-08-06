import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchListScreen extends StatefulWidget {
  const MatchListScreen({super.key});

  @override
  State<MatchListScreen> createState() => _MatchListScreenState();
}

class _MatchListScreenState extends State<MatchListScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = '전체';
  final List<String> _statuses = ['전체', '매칭대기', '진행중', '완료', '취소'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 목업 매칭 요청 데이터 (내가 요청한)
  List<Map<String, dynamic>> _getMyMatchRequests() {
    return [
      {
        'id': 'MATCH001',
        'service_type': '아이 돌봄',
        'freelancer': {
          'name': '김돌봄',
          'photo': 'https://example.com/photo1.jpg',
          'rating': 4.8,
          'career_years': 5,
        },
        'request_title': '7세 아이 돌봄 서비스',
        'status': '진행중',
        'date_requested': DateTime(2024, 7, 10, 14, 30),
        'date_started': DateTime(2024, 7, 12, 9, 0),
        'amount': 50000,
        'chat_room_id': 'CHAT001',
        'contract_id': 'CONT001',
      },
      {
        'id': 'MATCH002',
        'service_type': '심리상담',
        'freelancer': {
          'name': '박상담',
          'photo': 'https://example.com/photo2.jpg',
          'rating': 4.9,
          'career_years': 8,
        },
        'request_title': '청소년 상담 서비스',
        'status': '매칭대기',
        'date_requested': DateTime(2024, 7, 15, 10, 15),
        'amount': 80000,
        'chat_room_id': null,
        'contract_id': null,
      },
      {
        'id': 'MATCH003',
        'service_type': '튜터링',
        'freelancer': {
          'name': '이튜터',
          'photo': 'https://example.com/photo3.jpg',
          'rating': 4.7,
          'career_years': 3,
        },
        'request_title': '중학생 수학 과외',
        'status': '완료',
        'date_requested': DateTime(2024, 6, 20, 16, 45),
        'date_completed': DateTime(2024, 7, 5, 18, 0),
        'amount': 120000,
        'chat_room_id': 'CHAT003',
        'contract_id': 'CONT003',
        'review_written': true,
      },
      {
        'id': 'MATCH004',
        'service_type': '간병',
        'freelancer': {
          'name': '최간병',
          'photo': 'https://example.com/photo4.jpg',
          'rating': 4.6,
          'career_years': 10,
        },
        'request_title': '어르신 간병 서비스',
        'status': '취소',
        'date_requested': DateTime(2024, 6, 25, 11, 20),
        'date_cancelled': DateTime(2024, 6, 26, 14, 30),
        'amount': 200000,
        'cancel_reason': '일정 변경으로 인한 취소',
      },
    ];
  }

  // 목업 매칭 제안 데이터 (나에게 온)
  List<Map<String, dynamic>> _getMatchOffers() {
    return [
      {
        'id': 'OFFER001',
        'service_type': '아이 돌봄',
        'client': {
          'name': '김고객',
          'location': '서울 강남구',
          'rating': 4.5,
        },
        'request_title': '5세 아이 돌봄 (주말)',
        'status': '제안대기',
        'date_received': DateTime(2024, 7, 16, 9, 30),
        'amount': 60000,
        'message': '주말에 5세 아이를 돌봐주실 분을 찾습니다.',
        'deadline': DateTime(2024, 7, 18, 23, 59),
      },
      {
        'id': 'OFFER002',
        'service_type': '심리상담',
        'client': {
          'name': '박고객',
          'location': '서울 서초구',
          'rating': 4.8,
        },
        'request_title': '성인 심리상담',
        'status': '수락',
        'date_received': DateTime(2024, 7, 14, 15, 20),
        'date_accepted': DateTime(2024, 7, 14, 16, 30),
        'amount': 90000,
        'message': '불안장애 관련 상담을 받고 싶습니다.',
        'chat_room_id': 'CHAT005',
      },
      {
        'id': 'OFFER003',
        'service_type': '튜터링',
        'client': {
          'name': '이고객',
          'location': '서울 송파구',
          'rating': 4.3,
        },
        'request_title': '고등학생 영어 과외',
        'status': '거절',
        'date_received': DateTime(2024, 7, 12, 13, 45),
        'date_declined': DateTime(2024, 7, 12, 18, 20),
        'amount': 100000,
        'message': '고3 영어 과외를 부탁드립니다.',
        'decline_reason': '일정이 맞지 않음',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('매칭 관리'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // 상태 필터
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text('상태: ', style: TextStyle(fontWeight: FontWeight.w500)),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _statuses.map((status) {
                            final isSelected = _selectedStatus == status;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedStatus = status),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 탭바
              TabBar(
                controller: _tabController,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: const [
                  Tab(text: '내 매칭 요청'),
                  Tab(text: '받은 매칭 제안'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyMatchRequestsTab(),
          _buildMatchOffersTab(),
        ],
      ),
    );
  }

  Widget _buildMyMatchRequestsTab() {
    final matchRequests = _getMyMatchRequests()
        .where((match) => _selectedStatus == '전체' || match['status'] == _selectedStatus)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matchRequests.length,
      itemBuilder: (context, index) {
        final match = matchRequests[index];
        return _buildMatchRequestCard(match);
      },
    );
  }

  Widget _buildMatchOffersTab() {
    final matchOffers = _getMatchOffers()
        .where((offer) => _selectedStatus == '전체' || offer['status'] == _selectedStatus)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matchOffers.length,
      itemBuilder: (context, index) {
        final offer = matchOffers[index];
        return _buildMatchOfferCard(offer);
      },
    );
  }

  Widget _buildMatchRequestCard(Map<String, dynamic> match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[300],
                child: Text(
                  match['freelancer']['name'][0],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match['freelancer']['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 2),
                        Text('${match['freelancer']['rating']}'),
                        const SizedBox(width: 8),
                        Text('경력 ${match['freelancer']['career_years']}년'),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(match['status']),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        match['service_type'],
                        style: TextStyle(color: Colors.blue[700], fontSize: 12),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₩${NumberFormat('#,###').format(match['amount'])}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  match['request_title'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '요청일: ${DateFormat('yyyy.MM.dd HH:mm').format(match['date_requested'])}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                if (match['date_started'] != null)
                  Text(
                    '시작일: ${DateFormat('yyyy.MM.dd HH:mm').format(match['date_started'])}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                if (match['date_completed'] != null)
                  Text(
                    '완료일: ${DateFormat('yyyy.MM.dd HH:mm').format(match['date_completed'])}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                if (match['cancel_reason'] != null)
                  Text(
                    '취소사유: ${match['cancel_reason']}',
                    style: TextStyle(color: Colors.red[600], fontSize: 13),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (match['chat_room_id'] != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openChat(match['chat_room_id']),
                    icon: const Icon(Icons.chat, size: 16),
                    label: const Text('채팅'),
                  ),
                ),
              if (match['chat_room_id'] != null && match['contract_id'] != null)
                const SizedBox(width: 8),
              if (match['contract_id'] != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewContract(match['contract_id']),
                    icon: const Icon(Icons.description, size: 16),
                    label: const Text('계약서'),
                  ),
                ),
              if (match['status'] == '완료' && match['review_written'] != true)
                const SizedBox(width: 8),
              if (match['status'] == '완료' && match['review_written'] != true)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _writeReview(match['id']),
                    icon: const Icon(Icons.rate_review, size: 16),
                    label: const Text('후기작성'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              if (match['status'] == '매칭대기')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _cancelMatch(match['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('매칭취소'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchOfferCard(Map<String, dynamic> offer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, size: 40, color: Colors.grey[400]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer['client']['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey[500], size: 14),
                        const SizedBox(width: 2),
                        Text(offer['client']['location'], style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(width: 8),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 2),
                        Text('${offer['client']['rating']}'),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(offer['status']),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        offer['service_type'],
                        style: TextStyle(color: Colors.green[700], fontSize: 12),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₩${NumberFormat('#,###').format(offer['amount'])}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  offer['request_title'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  offer['message'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '받은일: ${DateFormat('yyyy.MM.dd HH:mm').format(offer['date_received'])}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                if (offer['deadline'] != null && offer['status'] == '제안대기')
                  Text(
                    '응답기한: ${DateFormat('yyyy.MM.dd HH:mm').format(offer['deadline'])}',
                    style: TextStyle(color: Colors.red[600], fontSize: 13),
                  ),
                if (offer['decline_reason'] != null)
                  Text(
                    '거절사유: ${offer['decline_reason']}',
                    style: TextStyle(color: Colors.red[600], fontSize: 13),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (offer['status'] == '제안대기')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _declineOffer(offer['id']),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('거절'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptOffer(offer['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('수락'),
                  ),
                ),
              ],
            ),
          if (offer['chat_room_id'] != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openChat(offer['chat_room_id']),
                icon: const Icon(Icons.chat, size: 16),
                label: const Text('채팅하기'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case '진행중':
      case '수락':
        color = Colors.blue;
        break;
      case '완료':
        color = Colors.green;
        break;
      case '취소':
      case '거절':
        color = Colors.red;
        break;
      case '매칭대기':
      case '제안대기':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _openChat(String chatRoomId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('채팅방 열기: $chatRoomId')),
    );
  }

  void _viewContract(String contractId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('계약서 보기: $contractId')),
    );
  }

  void _writeReview(String matchId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('후기 작성: $matchId')),
    );
  }

  void _cancelMatch(String matchId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('매칭 취소'),
        content: const Text('정말로 매칭을 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('매칭이 취소되었습니다: $matchId')),
              );
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _acceptOffer(String offerId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('매칭 제안 수락: $offerId')),
    );
  }

  void _declineOffer(String offerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('매칭 제안 거절'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('거절 사유를 선택해주세요:'),
            const SizedBox(height: 16),
            ...['일정이 맞지 않음', '조건이 맞지 않음', '다른 매칭 진행중', '기타'].map(
              (reason) => RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: null,
                onChanged: (value) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('매칭 제안 거절: $offerId ($value)')),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }
}
