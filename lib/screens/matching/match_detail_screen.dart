import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchDetailScreen extends StatefulWidget {
  final String matchId;
  
  const MatchDetailScreen({
    super.key,
    required this.matchId,
  });

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  late Map<String, dynamic> _matchData;

  @override
  void initState() {
    super.initState();
    _loadMatchData();
  }

  void _loadMatchData() {
    // 목업 매칭 상세 데이터
    _matchData = {
      'id': widget.matchId,
      'service_type': '아이 돌봄',
      'status': '진행중',
      'request': {
        'title': '7세 아이 돌봄 서비스',
        'description': '평일 오후 3시~7시까지 초등학교 1학년 아이를 돌봐주실 분을 찾습니다. 숙제 도움과 간단한 놀이 활동을 해주시면 됩니다.',
        'location': '서울 강남구 대치동',
        'schedule': '평일 15:00~19:00',
        'duration': '2주 (2024.07.15 ~ 2024.07.26)',
        'requirements': ['아이 돌봄 경험 필수', '관련 자격증 보유', '비흡연자'],
        'amount': 50000,
        'created_date': DateTime(2024, 7, 10, 14, 30),
      },
      'freelancer': {
        'id': 'FL001',
        'name': '김돌봄',
        'photo': 'https://example.com/photo1.jpg',
        'age': 32,
        'gender': '여성',
        'location': '서울 강남구',
        'rating': 4.8,
        'review_count': 45,
        'career_years': 5,
        'specialties': ['유아돌봄', '초등돌봄', '특수아동'],
        'certifications': [
          {'name': '보육교사 2급', 'date': '2019.03'},
          {'name': '아동심리상담사', 'date': '2020.08'},
        ],
        'introduction': '안녕하세요! 5년간 아이들과 함께해온 김돌봄입니다. 아이들의 안전과 건강한 성장을 최우선으로 생각합니다.',
      },
      'client': {
        'id': 'CL001',
        'name': '박고객',
        'location': '서울 강남구',
        'rating': 4.5,
        'review_count': 12,
      },
      'timeline': [
        {
          'date': DateTime(2024, 7, 10, 14, 30),
          'title': '매칭 요청',
          'description': '고객이 서비스를 요청했습니다.',
          'type': 'request',
        },
        {
          'date': DateTime(2024, 7, 11, 9, 15),
          'title': '프리랜서 지원',
          'description': '김돌봄님이 매칭을 신청했습니다.',
          'type': 'apply',
        },
        {
          'date': DateTime(2024, 7, 11, 16, 45),
          'title': '매칭 성사',
          'description': '고객이 매칭을 승인했습니다.',
          'type': 'match',
        },
        {
          'date': DateTime(2024, 7, 12, 8, 30),
          'title': '계약 체결',
          'description': '전자서명으로 계약이 완료되었습니다.',
          'type': 'contract',
        },
        {
          'date': DateTime(2024, 7, 12, 9, 0),
          'title': '서비스 시작',
          'description': '서비스가 시작되었습니다.',
          'type': 'start',
        },
      ],
      'contract': {
        'id': 'CONT001',
        'signed_date': DateTime(2024, 7, 12, 8, 30),
        'start_date': DateTime(2024, 7, 15, 15, 0),
        'end_date': DateTime(2024, 7, 26, 19, 0),
        'amount': 50000,
        'terms': [
          '서비스 시간: 평일 오후 3시~7시 (4시간)',
          '서비스 기간: 2주 (총 10일)',
          '주요 업무: 아이 돌봄, 숙제 지도, 놀이 활동',
          '결제 방식: 서비스 완료 후 일괄 결제',
        ],
      },
      'payment': {
        'status': '결제대기',
        'amount': 50000,
        'method': null,
        'due_date': DateTime(2024, 7, 27, 23, 59),
      },
      'chat_room_id': 'CHAT001',
      'reports': [],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('매칭 상세 - ${_matchData['id']}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'report', child: Text('신고하기')),
              const PopupMenuItem(value: 'cancel', child: Text('매칭 취소')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildRequestInfoCard(),
            const SizedBox(height: 16),
            _buildParticipantsCard(),
            const SizedBox(height: 16),
            _buildTimelineCard(),
            if (_matchData['contract'] != null) ...[
              const SizedBox(height: 16),
              _buildContractCard(),
            ],
            if (_matchData['payment'] != null) ...[
              const SizedBox(height: 16),
              _buildPaymentCard(),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildStatusCard() {
    return Container(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _matchData['service_type'],
                  style: TextStyle(color: Colors.blue[700], fontSize: 12),
                ),
              ),
              const Spacer(),
              _buildStatusBadge(_matchData['status']),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _matchData['request']['title'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '매칭 ID: ${_matchData['id']}',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '요청일: ${DateFormat('yyyy.MM.dd HH:mm').format(_matchData['request']['created_date'])}',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestInfoCard() {
    final request = _matchData['request'];
    
    return Container(
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
          const Text('서비스 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildInfoRow('서비스 내용', request['description']),
          _buildInfoRow('위치', request['location']),
          _buildInfoRow('일정', request['schedule']),
          _buildInfoRow('기간', request['duration']),
          _buildInfoRow('금액', '₩${NumberFormat('#,###').format(request['amount'])}'),
          const SizedBox(height: 12),
          const Text('요구사항', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          ...request['requirements'].map<Widget>((req) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text(req, style: const TextStyle(fontSize: 14))),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildParticipantsCard() {
    final freelancer = _matchData['freelancer'];
    final client = _matchData['client'];
    
    return Container(
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
          const Text('참여자 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // 프리랜서 정보
          const Text('프리랜서', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blue)),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[300],
                child: Text(freelancer['name'][0], style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(freelancer['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${freelancer['age']}세 ${freelancer['gender']} · ${freelancer['location']}'),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(' ${freelancer['rating']} (${freelancer['review_count']}개)'),
                        const SizedBox(width: 8),
                        Text('경력 ${freelancer['career_years']}년'),
                      ],
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => _viewProfile(freelancer['id']),
                child: const Text('프로필'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 고객 정보
          const Text('고객', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.green)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person, size: 50, color: Colors.grey[400]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(client['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(client['location']),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(' ${client['rating']} (${client['review_count']}개)'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    final timeline = _matchData['timeline'] as List;
    
    return Container(
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
          const Text('진행 상황', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...timeline.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == timeline.length - 1;
            
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _getTimelineColor(item['type']),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getTimelineIcon(item['type']),
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['description'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('yyyy.MM.dd HH:mm').format(item['date']),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      if (!isLast) const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildContractCard() {
    final contract = _matchData['contract'];
    
    return Container(
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
              const Text('계약 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _viewContract(contract['id']),
                icon: const Icon(Icons.description, size: 16),
                label: const Text('계약서 보기'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('계약 ID', contract['id']),
          _buildInfoRow('서명일', DateFormat('yyyy.MM.dd HH:mm').format(contract['signed_date'])),
          _buildInfoRow('서비스 시작', DateFormat('yyyy.MM.dd HH:mm').format(contract['start_date'])),
          _buildInfoRow('서비스 종료', DateFormat('yyyy.MM.dd HH:mm').format(contract['end_date'])),
          _buildInfoRow('계약 금액', '₩${NumberFormat('#,###').format(contract['amount'])}'),
          const SizedBox(height: 12),
          const Text('계약 조건', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          ...contract['terms'].map<Widget>((term) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(term, style: const TextStyle(fontSize: 14))),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    final payment = _matchData['payment'];
    
    return Container(
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
          const Text('결제 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildInfoRow('결제 상태', payment['status']),
          _buildInfoRow('결제 금액', '₩${NumberFormat('#,###').format(payment['amount'])}'),
          if (payment['method'] != null)
            _buildInfoRow('결제 수단', payment['method']),
          if (payment['due_date'] != null)
            _buildInfoRow('결제 기한', DateFormat('yyyy.MM.dd HH:mm').format(payment['due_date'])),
          
          if (payment['status'] == '결제대기') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('결제하기'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _openChat(_matchData['chat_room_id']),
              icon: const Icon(Icons.chat),
              label: const Text('채팅'),
            ),
          ),
          const SizedBox(width: 12),
          if (_matchData['status'] == '완료')
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _writeReview,
                icon: const Icon(Icons.rate_review),
                label: const Text('후기 작성'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          if (_matchData['status'] != '완료' && _matchData['status'] != '취소')
            Expanded(
              child: ElevatedButton(
                onPressed: _showCancelDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('매칭 취소'),
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
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
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

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case '진행중':
        color = Colors.blue;
        break;
      case '완료':
        color = Colors.green;
        break;
      case '취소':
        color = Colors.red;
        break;
      case '매칭대기':
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

  Color _getTimelineColor(String type) {
    switch (type) {
      case 'request':
        return Colors.grey;
      case 'apply':
        return Colors.blue;
      case 'match':
        return Colors.green;
      case 'contract':
        return Colors.purple;
      case 'start':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTimelineIcon(String type) {
    switch (type) {
      case 'request':
        return Icons.assignment;
      case 'apply':
        return Icons.person_add;
      case 'match':
        return Icons.handshake;
      case 'contract':
        return Icons.description;
      case 'start':
        return Icons.play_arrow;
      default:
        return Icons.circle;
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'report':
        _showReportDialog();
        break;
      case 'cancel':
        _showCancelDialog();
        break;
    }
  }

  void _viewProfile(String profileId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('프로필 보기: $profileId')),
    );
  }

  void _viewContract(String contractId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('계약서 보기: $contractId')),
    );
  }

  void _openChat(String chatRoomId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('채팅방 열기: $chatRoomId')),
    );
  }

  void _processPayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('결제 화면으로 이동합니다')),
    );
  }

  void _writeReview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('후기 작성 화면으로 이동합니다')),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('매칭 취소'),
        content: const Text('정말로 매칭을 취소하시겠습니까?\n취소 시 패널티가 발생할 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('돌아가기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('매칭이 취소되었습니다')),
              );
            },
            child: const Text('취소하기'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('신고하기'),
        content: const Text('이 매칭에 문제가 있나요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('돌아가기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('신고가 접수되었습니다')),
              );
            },
            child: const Text('신고하기'),
          ),
        ],
      ),
    );
  }
}
