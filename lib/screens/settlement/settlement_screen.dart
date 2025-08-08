import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../models/settlement.dart';
import '../../services/settlement_service.dart';
import '../../providers/auth_provider.dart';

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

  void _loadSettlementData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // AuthProvider를 사용하여 사용자 정보 가져오기
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      
      if (currentUser == null) {
        if (mounted) {
          context.go('/login');
        }
        return;
      }

      // 프리랜서 전용 화면이므로 사용자 타입 확인
      if (!currentUser.isFreelancer) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('프리랜서 회원만 이용할 수 있는 기능입니다.'),
            ),
          );
          context.go('/home');
        }
        return;
      }

      // 실제 API 호출
      final settlements = await settlementService.getSettlements(currentUser.id);
      final stats = await settlementService.getSettlementStats(currentUser.id);

      if (mounted) {
        setState(() {
          _settlements = settlements;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('정산 데이터 로드 에러: $e');
      if (mounted) {
        setState(() {
          _settlements = [];
          _stats = {};
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('데이터를 불러오는 중 오류가 발생했습니다.'),
          ),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
            Builder(builder: (_) {
              final Map<String, num> breakdown =
                  (_stats['serviceBreakdown'] as Map?)?.map((k, v) => MapEntry(k.toString(), (v as num? ?? 0)))
                      .cast<String, num>() ??
                  {};

              if (breakdown.isEmpty) {
                return Text(
                  '표시할 데이터가 없습니다',
                  style: TextStyle(color: Colors.grey[600]),
                );
              }

              final entries = breakdown.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              final colors = <Color>[
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.purple,
                Colors.pink,
                Colors.teal,
                Colors.indigo,
                Colors.redAccent,
              ];

              return Column(
                children: [
                  for (int i = 0; i < entries.length; i++)
                    (() {
                      final v = entries[i].value.toDouble();
                      final amt = (v.isFinite && !v.isNaN) ? v.round() : 0;
                      return _buildServiceItem(
                        entries[i].key,
                        amt,
                        colors[i % colors.length],
                      );
                    })(),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(String service, int amount, Color color) {
    final totalNum = (_stats['totalEarnings'] as num?)?.toDouble() ?? 0.0;
    final ratio = totalNum > 0 ? (amount / totalNum * 100.0) : 0.0;
    final percentage = (ratio.isFinite && !ratio.isNaN) ? ratio.round() : 0;
    
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

  void _cancelSettlement(Settlement settlement) async {
    try {
      final success = await settlementService.cancelSettlement(settlement.id);
      
      if (success && mounted) {
        setState(() {
          _settlements.removeWhere((s) => s.id == settlement.id);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('정산 요청이 취소되었습니다.'),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('정산 취소에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('정산 취소 에러: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('정산 취소 중 오류가 발생했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
