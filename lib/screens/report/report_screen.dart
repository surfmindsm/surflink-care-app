import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/report.dart';
import '../../services/report_service.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';
import 'report_create_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReportService _reportService = ReportService();
  
  List<Report> _myReports = [];
  List<FAQ> _faqs = [];
  List<String> _faqCategories = [];
  String _selectedCategory = '전체';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id ?? 'user_002'; // Mock user

      final reports = await _reportService.getUserReports(userId);
      final faqs = await _reportService.getFAQs();
      final categories = await _reportService.getFAQCategories();

      if (mounted) {
        setState(() {
          _myReports = reports;
          _faqs = faqs;
          _faqCategories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터를 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('고객센터'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'FAQ'),
            Tab(text: '신고하기'),
            Tab(text: '내 신고'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFAQTab(),
                _buildReportFormTab(),
                _buildMyReportsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReportDialog(),
        icon: const Icon(Icons.report_problem),
        label: const Text('신고하기'),
        heroTag: "report_fab",
      ),
    );
  }

  Widget _buildFAQTab() {
    return Column(
      children: [
        // 카테고리 필터
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _faqCategories.length,
            itemBuilder: (context, index) {
              final category = _faqCategories[index];
              final isSelected = category == _selectedCategory;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                    _filterFAQs();
                  },
                ),
              );
            },
          ),
        ),
        
        // FAQ 목록
        Expanded(
          child: _buildFAQList(),
        ),
      ],
    );
  }

  Widget _buildFAQList() {
    final filteredFAQs = _selectedCategory == '전체' 
        ? _faqs
        : _faqs.where((faq) => faq.category == _selectedCategory).toList();

    if (filteredFAQs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('FAQ가 없습니다.'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        itemCount: filteredFAQs.length,
        itemBuilder: (context, index) {
          final faq = filteredFAQs[index];
          return _buildFAQCard(faq);
        },
      ),
    );
  }

  Widget _buildFAQCard(FAQ faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Row(
          children: [
            if (faq.isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '인기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (faq.isPopular) const SizedBox(width: 8),
            Expanded(
              child: Text(
                faq.question,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Text(
              faq.category,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '조회 ${faq.viewCount}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faq.answer,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '도움이 되셨나요?',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => _handleFAQFeedback(faq.id, true),
                          icon: const Icon(Icons.thumb_up, size: 16),
                          label: const Text('도움됨'),
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _handleFAQFeedback(faq.id, false),
                          icon: const Icon(Icons.thumb_down, size: 16),
                          label: const Text('아님'),
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        onExpansionChanged: (expanded) {
          if (expanded) {
            _reportService.incrementFAQViewCount(faq.id);
          }
        },
      ),
    );
  }

  Widget _buildReportFormTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '무엇을 도와드릴까요?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '문제를 빠르게 해결할 수 있도록 도와드리겠습니다.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 신고 유형 버튼들
          const Text(
            '신고/문의 유형',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: ReportType.values.map((type) {
              return _buildReportTypeCard(type);
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // 빠른 도움말
          const Text(
            '빠른 도움말',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildQuickHelpCard(
            '긴급상황',
            '즉시 도움이 필요한 경우',
            Icons.emergency,
            Colors.red,
            () => _showEmergencyDialog(),
          ),
          
          _buildQuickHelpCard(
            '채팅 상담',
            '실시간으로 상담받기',
            Icons.chat,
            Colors.blue,
            () => _startChatSupport(),
          ),
          
          _buildQuickHelpCard(
            '전화 상담',
            '1588-1234 (평일 9-18시)',
            Icons.phone,
            Colors.green,
            () => _makePhoneCall(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeCard(ReportType type) {
    return Card(
      child: InkWell(
        onTap: () => _showReportDialog(preSelectedType: type),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                type.icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                type.displayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickHelpCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyReportsTab() {
    if (_myReports.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.report_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('신고 내역이 없습니다.'),
            SizedBox(height: 8),
            Text(
              '문제가 있으시면 언제든지 신고해주세요.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        itemCount: _myReports.length,
        itemBuilder: (context, index) {
          final report = _myReports[index];
          return _buildReportCard(report);
        },
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    final dateFormatter = DateFormat('yyyy.MM.dd HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showReportDetail(report),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        report.type.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        report.type.displayName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: report.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: report.status.color.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      report.status.displayName,
                      style: TextStyle(
                        color: report.status.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Text(
                report.subject,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                report.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormatter.format(report.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  if (report.hasResponse)
                    Row(
                      children: [
                        Icon(
                          Icons.reply,
                          size: 16,
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '답변 완료',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _filterFAQs() async {
    setState(() => _isLoading = true);
    
    try {
      final faqs = await _reportService.getFAQs(category: _selectedCategory);
      if (mounted) {
        setState(() {
          _faqs = faqs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleFAQFeedback(String faqId, bool isHelpful) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isHelpful ? '피드백 감사합니다!' : '더 나은 답변을 준비하겠습니다.'),
      ),
    );
  }

  void _showReportDialog({ReportType? preSelectedType}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportCreateScreen(
          preSelectedType: preSelectedType,
          onReportCreated: () {
            _loadData(); // 신고 목록 새로고침
          },
        ),
      ),
    );
  }

  void _showReportDetail(Report report) {
    final dateFormatter = DateFormat('yyyy년 MM월 dd일 HH:mm');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '신고 상세',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            Text('신고 유형: ${report.type.displayName}'),
            const SizedBox(height: 8),
            Text('상태: ${report.status.displayName}'),
            const SizedBox(height: 8),
            Text('제목: ${report.subject}'),
            const SizedBox(height: 8),
            Text('내용: ${report.description}'),
            const SizedBox(height: 8),
            Text('접수일: ${dateFormatter.format(report.createdAt)}'),
            
            if (report.adminResponse != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                '관리자 답변',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(report.adminResponse!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('긴급상황'),
          ],
        ),
        content: const Text(
          '긴급상황인 경우 즉시 전화로 연락해주세요.\n\n'
          '고객센터: 1588-1234\n'
          '운영시간: 24시간',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _makePhoneCall();
            },
            child: const Text('전화걸기'),
          ),
        ],
      ),
    );
  }

  void _startChatSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('채팅 상담 기능을 준비 중입니다.')),
    );
  }

  void _makePhoneCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('전화 연결 기능을 준비 중입니다.')),
    );
  }
}
