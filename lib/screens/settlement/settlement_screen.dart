import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/settlement.dart';

class SettlementScreen extends StatefulWidget {
  const SettlementScreen({super.key});

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Settlement> _settlements = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSettlementData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSettlementData() {
    // TODO: 실제 API 호출로 대체
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _settlements = _getSampleSettlements();
        _stats = _getSampleStats();
        _isLoading = false;
      });
    });
  }

  List<Settlement> _getSampleSettlements() {
    return [
      Settlement(
        id: '1',
        amount: 150000,
        fee: 15000,
        netAmount: 135000,
        status: SettlementStatus.completed,
        requestDate: DateTime.now().subtract(const Duration(days: 2)),
        completedDate: DateTime.now().subtract(const Duration(days: 1)),
        serviceType: '아이 돌봄',
        clientName: '김고객',
      ),
      Settlement(
        id: '2',
        amount: 200000,
        fee: 20000,
        netAmount: 180000,
        status: SettlementStatus.pending,
        requestDate: DateTime.now().subtract(const Duration(days: 1)),
        serviceType: '영어 과외',
        clientName: '박학부모',
      ),
      Settlement(
        id: '3',
        amount: 100000,
        fee: 10000,
        netAmount: 90000,
        status: SettlementStatus.completed,
        requestDate: DateTime.now().subtract(const Duration(days: 5)),
        completedDate: DateTime.now().subtract(const Duration(days: 3)),
        serviceType: '심리 상담',
        clientName: '이내담자',
      ),
    ];
  }

  Map<String, dynamic> _getSampleStats() {
    return {
      'totalEarnings': 750000,
      'thisMonthEarnings': 350000,
      'pendingAmount': 200000,
      'totalFee': 75000,
      'completedServices': 15,
      'averageRating': 4.8,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('정산/수익 관리'),
        backgroundColor: Color(AppConfig.primaryColor),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '수익 현황'),
            Tab(text: '정산 내역'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStatsTab(),
                _buildSettlementsTab(),
              ],
            ),
    );
  }

  Widget _buildStatsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadSettlementData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCard(),
            const SizedBox(height: 24),
            _buildMonthlyChart(),
            const SizedBox(height: 24),
            _buildServiceBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '수익 요약',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '총 수익',
                    '${_stats['totalEarnings']?.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}원',
                    Colors.blue,
                    Icons.account_balance_wallet,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '이번 달',
                    '${_stats['thisMonthEarnings']?.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}원',
                    Colors.green,
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '대기 중',
                    '${_stats['pendingAmount']?.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}원',
                    Colors.orange,
                    Icons.hourglass_empty,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '평균 평점',
                    '${_stats['averageRating']} ⭐',
                    Colors.amber,
                    Icons.star,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '월별 수익 추이',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '차트는 실제 앱에서 구현됩니다',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceBreakdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '서비스별 수익',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildServiceItem('아이 돌봄', 250000, Colors.pink),
            _buildServiceItem('영어 과외', 300000, Colors.blue),
            _buildServiceItem('심리 상담', 150000, Colors.green),
            _buildServiceItem('간병 서비스', 50000, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(String service, int amount, Color color) {
    final total = _stats['totalEarnings'] ?? 1;
    final percentage = (amount / total * 100).round();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(service),
              Text(
                '${amount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}원 ($percentage%)',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadSettlementData();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        itemCount: _settlements.length,
        itemBuilder: (context, index) {
          final settlement = _settlements[index];
          return _buildSettlementCard(settlement);
        },
      ),
    );
  }

  Widget _buildSettlementCard(Settlement settlement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  settlement.serviceType,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _buildStatusChip(settlement.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '고객: ${settlement.clientName}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '서비스 금액',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${settlement.amount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}원',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '수수료',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '-${settlement.fee.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}원',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '실수령액',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${settlement.netAmount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}원',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '신청일: ${_formatDate(settlement.requestDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (settlement.completedDate != null)
                  Text(
                    '완료일: ${_formatDate(settlement.completedDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            if (settlement.status == SettlementStatus.pending) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showCancelDialog(settlement);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[700],
                  ),
                  child: const Text('정산 취소'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(SettlementStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case SettlementStatus.pending:
        color = Colors.orange;
        text = '대기중';
        break;
      case SettlementStatus.completed:
        color = Colors.green;
        text = '완료';
        break;
      case SettlementStatus.rejected:
        color = Colors.red;
        text = '반려';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  void _showCancelDialog(Settlement settlement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정산 취소'),
        content: const Text('정산 요청을 취소하시겠습니까?\n취소된 정산은 다시 요청할 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelSettlement(settlement);
            },
            child: const Text('취소하기'),
          ),
        ],
      ),
    );
  }

  void _cancelSettlement(Settlement settlement) {
    // TODO: 실제 API 호출로 대체
    setState(() {
      _settlements.removeWhere((s) => s.id == settlement.id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('정산 요청이 취소되었습니다.'),
      ),
    );
  }
}
