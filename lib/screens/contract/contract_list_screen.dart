import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/contract.dart';
import '../../services/contract_service.dart';
import 'contract_detail_screen.dart';

class ContractListScreen extends StatefulWidget {
  const ContractListScreen({super.key});

  @override
  State<ContractListScreen> createState() => _ContractListScreenState();
}

class _ContractListScreenState extends State<ContractListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ContractService _contractService = ContractService();
  
  List<Contract> _contracts = [];
  bool _isLoading = true;
  String? _error;

  final List<String> _statusTabs = [
    '전체',
    '진행중',
    '서명대기',
    '완료',
    '취소',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _loadContracts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('계약 관리'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: _statusTabs.map((status) => Tab(text: status)).toList(),
          onTap: (index) => _onTabChanged(index),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadContracts,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    final filteredContracts = _getFilteredContracts();

    if (filteredContracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '계약서가 없습니다',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadContracts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredContracts.length,
        itemBuilder: (context, index) {
          final contract = filteredContracts[index];
          return _buildContractCard(contract);
        },
      ),
    );
  }

  Widget _buildContractCard(Contract contract) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetail(contract),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      contract.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _buildStatusChip(contract.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                contract.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${DateFormat('MM/dd').format(contract.startDate)} - ${DateFormat('MM/dd').format(contract.endDate)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${NumberFormat('#,###').format(contract.totalAmount)}원',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildProgressIndicator(contract),
                  const SizedBox(width: 12),
                  _buildPaymentStatus(contract.paymentStatus),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ContractStatus status) {
    Color color;
    switch (status) {
      case ContractStatus.draft:
        color = Colors.grey;
        break;
      case ContractStatus.pending:
        color = Colors.orange;
        break;
      case ContractStatus.signed:
        color = Colors.blue;
        break;
      case ContractStatus.active:
        color = Colors.green;
        break;
      case ContractStatus.completed:
        color = Colors.purple;
        break;
      case ContractStatus.cancelled:
        color = Colors.red;
        break;
      case ContractStatus.disputed:
        color = Colors.red[800]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(Contract contract) {
    double progress;
    String text;

    switch (contract.status) {
      case ContractStatus.draft:
        progress = 0.2;
        text = '계약서 작성완료';
        break;
      case ContractStatus.pending:
        progress = 0.4;
        text = '서명 대기중';
        break;
      case ContractStatus.signed:
        progress = 0.6;
        text = '서명 완료';
        break;
      case ContractStatus.active:
        progress = 0.8;
        text = '서비스 진행중';
        break;
      case ContractStatus.completed:
        progress = 1.0;
        text = '완료';
        break;
      case ContractStatus.cancelled:
        progress = 0.0;
        text = '취소됨';
        break;
      case ContractStatus.disputed:
        progress = 0.0;
        text = '분쟁중';
        break;
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              contract.status == ContractStatus.cancelled ||
                      contract.status == ContractStatus.disputed
                  ? Colors.red
                  : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatus(PaymentStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case PaymentStatus.pending:
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        break;
      case PaymentStatus.escrow:
        icon = Icons.security;
        color = Colors.blue;
        break;
      case PaymentStatus.paid:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case PaymentStatus.refunded:
        icon = Icons.undo;
        color = Colors.purple;
        break;
      case PaymentStatus.disputed:
        icon = Icons.warning;
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadContracts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final contracts = await _contractService.getContracts();
      setState(() {
        _contracts = contracts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '계약서를 불러오는데 실패했습니다: $e';
        _isLoading = false;
      });
    }
  }

  List<Contract> _getFilteredContracts() {
    final selectedIndex = _tabController.index;
    
    if (selectedIndex == 0) {
      // 전체
      return _contracts;
    }

    ContractStatus? filterStatus;
    switch (selectedIndex) {
      case 1: // 진행중
        return _contracts.where((contract) => 
          contract.status == ContractStatus.active ||
          contract.status == ContractStatus.signed
        ).toList();
      case 2: // 서명대기
        filterStatus = ContractStatus.pending;
        break;
      case 3: // 완료
        filterStatus = ContractStatus.completed;
        break;
      case 4: // 취소
        return _contracts.where((contract) => 
          contract.status == ContractStatus.cancelled ||
          contract.status == ContractStatus.disputed
        ).toList();
    }

    if (filterStatus != null) {
      return _contracts.where((contract) => contract.status == filterStatus).toList();
    }

    return _contracts;
  }

  void _onTabChanged(int index) {
    setState(() {
      // 탭 변경 시 필터된 리스트 다시 빌드
    });
  }

  void _navigateToDetail(Contract contract) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContractDetailScreen(contract: contract),
      ),
    );
  }
}
