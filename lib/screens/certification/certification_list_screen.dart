import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/certification.dart';
import '../../services/certification_service.dart';
import 'certification_upload_screen.dart';
import 'document_viewer_screen.dart';
import '../../widgets/custom_button.dart';

class CertificationListScreen extends StatefulWidget {
  final String? freelancerId;

  const CertificationListScreen({
    super.key,
    this.freelancerId,
  });

  @override
  State<CertificationListScreen> createState() => _CertificationListScreenState();
}

class _CertificationListScreenState extends State<CertificationListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CertificationService _certificationService = CertificationService();
  
  List<Certification> _certifications = [];
  Map<String, int> _stats = {};
  bool _isLoading = true;
  String? _error;

  final List<String> _statusTabs = [
    '전체',
    '승인됨',
    '검토중',
    '거부됨',
    '만료예정',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _loadData();
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
        title: const Text('인증서류 관리'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToUpload,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: _statusTabs.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final count = _getTabCount(index);
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(status),
                  if (count > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          onTap: (index) => _onTabChanged(index),
        ),
      ),
      body: Column(
        children: [
          _buildStatsCard(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToUpload,
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsCard() {
    if (_stats.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '인증서류 현황',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('전체', _stats['total'] ?? 0, Colors.blue),
                _buildStatItem('승인', _stats['approved'] ?? 0, Colors.green),
                _buildStatItem('검토중', _stats['pending'] ?? 0, Colors.orange),
                _buildStatItem('거부', _stats['rejected'] ?? 0, Colors.red),
              ],
            ),
            if ((_stats['expiring_soon'] ?? 0) > 0) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Text(
                      '${_stats['expiring_soon']}개의 인증서류가 곧 만료됩니다',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
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
              onPressed: _loadData,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    final filteredCertifications = _getFilteredCertifications();

    if (filteredCertifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '인증서류가 없습니다',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: '인증서류 등록',
              onPressed: _navigateToUpload,
              type: ButtonType.primary,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredCertifications.length,
        itemBuilder: (context, index) {
          final certification = filteredCertifications[index];
          return _buildCertificationCard(certification);
        },
      ),
    );
  }

  Widget _buildCertificationCard(Certification certification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showCertificationDetail(certification),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(certification.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getTypeColor(certification.type).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      certification.typeDisplayName,
                      style: TextStyle(
                        color: _getTypeColor(certification.type),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildStatusChip(certification.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                certification.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (certification.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  certification.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              if (certification.issuer != null) ...[
                Row(
                  children: [
                    Icon(Icons.business, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      certification.issuer!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    certification.issueDate != null
                        ? '발급일: ${DateFormat('yyyy.MM.dd').format(certification.issueDate!)}'
                        : '발급일: 미기재',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (certification.expiryDate != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      certification.isExpiring ? Icons.warning : Icons.event,
                      size: 14,
                      color: certification.isExpiring ? Colors.orange : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '만료: ${DateFormat('yyyy.MM.dd').format(certification.expiryDate!)}',
                      style: TextStyle(
                        color: certification.isExpiring ? Colors.orange : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: certification.isExpiring ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.attach_file, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${certification.fileUrls.length}개 파일',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (certification.status == CertificationStatus.rejected &&
                      certification.reviewNotes != null) ...[
                    IconButton(
                      icon: Icon(Icons.info_outline, color: Colors.red[300]),
                      onPressed: () => _showRejectReason(certification),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                  PopupMenuButton<String>(
                    onSelected: (action) => _handleAction(action, certification),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('상세보기'),
                          ],
                        ),
                      ),
                      if (certification.status != CertificationStatus.approved) ...[
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('수정'),
                            ],
                          ),
                        ),
                      ],
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('삭제', style: TextStyle(color: Colors.red)),
                          ],
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

  Widget _buildStatusChip(CertificationStatus status) {
    Color color;
    IconData? icon;

    switch (status) {
      case CertificationStatus.pending:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case CertificationStatus.approved:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case CertificationStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case CertificationStatus.expired:
        color = Colors.grey;
        icon = Icons.schedule;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
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

  Color _getTypeColor(CertificationType type) {
    switch (type) {
      case CertificationType.license:
        return Colors.blue;
      case CertificationType.certificate:
        return Colors.green;
      case CertificationType.education:
        return Colors.purple;
      case CertificationType.experience:
        return Colors.orange;
      case CertificationType.portfolio:
        return Colors.teal;
      case CertificationType.other:
        return Colors.grey;
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final certifications = await _certificationService.getCertifications(
        freelancerId: widget.freelancerId,
      );
      final stats = await _certificationService.getCertificationStats(
        freelancerId: widget.freelancerId,
      );
      
      setState(() {
        _certifications = certifications;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '데이터를 불러오는데 실패했습니다: $e';
        _isLoading = false;
      });
    }
  }

  List<Certification> _getFilteredCertifications() {
    final selectedIndex = _tabController.index;
    
    switch (selectedIndex) {
      case 0: // 전체
        return _certifications;
      case 1: // 승인됨
        return _certifications.where((c) => c.status == CertificationStatus.approved).toList();
      case 2: // 검토중
        return _certifications.where((c) => c.status == CertificationStatus.pending).toList();
      case 3: // 거부됨
        return _certifications.where((c) => c.status == CertificationStatus.rejected).toList();
      case 4: // 만료예정
        return _certifications.where((c) => c.isExpiring || c.hasExpired).toList();
      default:
        return _certifications;
    }
  }

  int _getTabCount(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _stats['total'] ?? 0;
      case 1:
        return _stats['approved'] ?? 0;
      case 2:
        return _stats['pending'] ?? 0;
      case 3:
        return _stats['rejected'] ?? 0;
      case 4:
        return _stats['expiring_soon'] ?? 0;
      default:
        return 0;
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      // 탭 변경 시 필터된 리스트 다시 빌드
    });
  }

  void _navigateToUpload([Certification? existingCertification]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CertificationUploadScreen(
          existingCertification: existingCertification,
        ),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _showCertificationDetail(Certification certification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) {
          return _buildDetailSheet(certification, scrollController);
        },
      ),
    );
  }

  Widget _buildDetailSheet(Certification certification, ScrollController scrollController) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  certification.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusChip(certification.status),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (certification.description.isNotEmpty) ...[
                    const Text(
                      '설명',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(certification.description),
                    const SizedBox(height: 16),
                  ],
                  if (certification.issuer != null) ...[
                    const Text(
                      '발급기관',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(certification.issuer!),
                    const SizedBox(height: 16),
                  ],
                  if (certification.licenseNumber != null) ...[
                    const Text(
                      '자격증 번호',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(certification.licenseNumber!),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    '첨부파일',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ...certification.fileUrls.map((url) => InkWell(
                    onTap: () => _viewDocument(url),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.insert_drive_file),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(url.split('/').last),
                          ),
                          const Icon(Icons.open_in_new),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(String action, Certification certification) {
    switch (action) {
      case 'view':
        _showCertificationDetail(certification);
        break;
      case 'edit':
        _navigateToUpload(certification);
        break;
      case 'delete':
        _confirmDelete(certification);
        break;
    }
  }

  void _confirmDelete(Certification certification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('인증서류 삭제'),
        content: Text('${certification.title}을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCertification(certification.id);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCertification(String certificationId) async {
    final result = await _certificationService.deleteCertification(certificationId);
    
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRejectReason(Certification certification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('거부 사유'),
        content: Text(certification.reviewNotes ?? '거부 사유가 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _viewDocument(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentViewerScreen(
          documentUrl: url,
          title: url.split('/').last,
        ),
      ),
    );
  }
}
