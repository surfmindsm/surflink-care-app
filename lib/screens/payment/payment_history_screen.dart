import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '전체';
  final List<String> _periods = ['전체', '1개월', '3개월', '6개월', '1년'];

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

  // 목업 결제 데이터
  List<Map<String, dynamic>> _getPaymentHistory() {
    return [
      {
        'id': 'PAY001',
        'type': '서비스 결제',
        'service': '아이 돌봄 서비스',
        'freelancer': '김돌봄',
        'amount': 50000,
        'method': '신용카드',
        'status': '완료',
        'date': DateTime(2024, 7, 15, 14, 30),
        'receipt_available': true,
      },
      {
        'id': 'PAY002', 
        'type': '서비스 결제',
        'service': '심리상담 서비스',
        'freelancer': '박상담',
        'amount': 80000,
        'method': '계좌이체',
        'status': '완료',
        'date': DateTime(2024, 7, 10, 10, 15),
        'receipt_available': true,
      },
      {
        'id': 'PAY003',
        'type': '서비스 결제', 
        'service': '튜터링 서비스',
        'freelancer': '이튜터',
        'amount': 120000,
        'method': '카카오페이',
        'status': '완료',
        'date': DateTime(2024, 6, 28, 16, 45),
        'receipt_available': true,
      },
      {
        'id': 'PAY004',
        'type': '서비스 결제',
        'service': '간병 서비스',
        'freelancer': '최간병',
        'amount': 200000,
        'method': '신용카드',
        'status': '취소',
        'date': DateTime(2024, 6, 20, 9, 20),
        'receipt_available': false,
      },
    ];
  }

  // 목업 정산 데이터  
  List<Map<String, dynamic>> _getSettlementHistory() {
    return [
      {
        'id': 'SET001',
        'type': '서비스 정산',
        'service': '아이 돌봄 서비스',
        'client': '김고객',
        'amount': 45000,
        'fee': 5000,
        'net_amount': 40000,
        'status': '지급완료',
        'date': DateTime(2024, 7, 16, 14, 30),
        'tax_invoice_available': true,
      },
      {
        'id': 'SET002',
        'type': '서비스 정산',
        'service': '심리상담 서비스', 
        'client': '박고객',
        'amount': 72000,
        'fee': 8000,
        'net_amount': 64000,
        'status': '지급완료',
        'date': DateTime(2024, 7, 11, 10, 15),
        'tax_invoice_available': true,
      },
      {
        'id': 'SET003',
        'type': '서비스 정산',
        'service': '튜터링 서비스',
        'client': '이고객',
        'amount': 108000,
        'fee': 12000,
        'net_amount': 96000,
        'status': '정산요청',
        'date': DateTime(2024, 6, 29, 16, 45),
        'tax_invoice_available': false,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('결제/정산 내역'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // 기간 필터
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text('기간: ', style: TextStyle(fontWeight: FontWeight.w500)),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _periods.map((period) {
                            final isSelected = _selectedPeriod == period;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedPeriod = period),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  period,
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
                  Tab(text: '결제 내역'),
                  Tab(text: '정산 내역'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPaymentHistoryTab(),
          _buildSettlementHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryTab() {
    final paymentHistory = _getPaymentHistory();
    
    return Column(
      children: [
        // 통계 요약
        Container(
          margin: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('총 결제금액', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text('₩450,000', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('결제 건수', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text('4건', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 결제 내역 리스트
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: paymentHistory.length,
            itemBuilder: (context, index) {
              final payment = paymentHistory[index];
              return _buildPaymentCard(payment);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettlementHistoryTab() {
    final settlementHistory = _getSettlementHistory();
    
    return Column(
      children: [
        // 통계 요약
        Container(
          margin: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('총 정산금액', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text('₩200,000', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('정산 건수', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text('3건', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 정산 내역 리스트
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: settlementHistory.length,
            itemBuilder: (context, index) {
              final settlement = settlementHistory[index];
              return _buildSettlementCard(settlement);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                payment['service'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: payment['status'] == '완료' ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  payment['status'],
                  style: TextStyle(
                    color: payment['status'] == '완료' ? Colors.green[700] : Colors.red[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '프리랜서: ${payment['freelancer']}',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '결제수단: ${payment['method']}',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('yyyy.MM.dd HH:mm').format(payment['date']),
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              Text(
                '₩${NumberFormat('#,###').format(payment['amount'])}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (payment['receipt_available'])
            const SizedBox(height: 12),
          if (payment['receipt_available'])
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadReceipt(payment['id']),
                    icon: const Icon(Icons.receipt, size: 16),
                    label: const Text('영수증'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadTaxInvoice(payment['id']),
                    icon: const Icon(Icons.description, size: 16),
                    label: const Text('세금계산서'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSettlementCard(Map<String, dynamic> settlement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                settlement['service'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: settlement['status'] == '지급완료' ? Colors.green[100] : Colors.orange[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  settlement['status'],
                  style: TextStyle(
                    color: settlement['status'] == '지급완료' ? Colors.green[700] : Colors.orange[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '고객: ${settlement['client']}',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('서비스 금액', style: TextStyle(color: Colors.grey[600])),
                    Text('₩${NumberFormat('#,###').format(settlement['amount'])}'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('수수료', style: TextStyle(color: Colors.grey[600])),
                    Text('-₩${NumberFormat('#,###').format(settlement['fee'])}'),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('정산 금액', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '₩${NumberFormat('#,###').format(settlement['net_amount'])}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('yyyy.MM.dd HH:mm').format(settlement['date']),
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          if (settlement['tax_invoice_available'])
            const SizedBox(height: 12),
          if (settlement['tax_invoice_available'])
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _downloadTaxInvoice(settlement['id']),
                icon: const Icon(Icons.description, size: 16),
                label: const Text('세금계산서 다운로드'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _downloadReceipt(String paymentId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('영수증 다운로드: $paymentId')),
    );
  }

  void _downloadTaxInvoice(String id) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('세금계산서 다운로드: $id')),
    );
  }
}
