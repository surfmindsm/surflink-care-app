import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DocumentViewerScreen extends StatefulWidget {
  final String documentUrl;
  final String title;

  const DocumentViewerScreen({
    super.key,
    required this.documentUrl,
    required this.title,
  });

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openInBrowser,
            tooltip: '브라우저에서 열기',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareDocument,
            tooltip: '공유',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('문서를 불러오는 중...'),
          ],
        ),
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadDocument,
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _openInBrowser,
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('브라우저에서 열기'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return _buildDocumentViewer();
  }

  Widget _buildDocumentViewer() {
    final fileExtension = widget.documentUrl.split('.').last.toLowerCase();
    
    if (_isImageFile(fileExtension)) {
      return _buildImageViewer();
    } else if (fileExtension == 'pdf') {
      return _buildPdfViewer();
    } else {
      return _buildUnsupportedViewer();
    }
  }

  Widget _buildImageViewer() {
    return InteractiveViewer(
      panEnabled: true,
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: widget.documentUrl,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '이미지를 불러올 수 없습니다',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildPdfViewer() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 24),
          Text(
            'PDF 문서',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[700],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'PDF 문서는 브라우저에서 확인하거나\n다운로드하여 확인할 수 있습니다.',
                  style: TextStyle(
                    color: Colors.blue[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _openInBrowser,
                icon: const Icon(Icons.open_in_browser),
                label: const Text('브라우저에서 열기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _downloadDocument,
                icon: const Icon(Icons.download),
                label: const Text('다운로드'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedViewer() {
    final fileExtension = widget.documentUrl.split('.').last.toLowerCase();
    IconData iconData;
    String fileType;

    switch (fileExtension) {
      case 'doc':
      case 'docx':
        iconData = Icons.description;
        fileType = 'Word 문서';
        break;
      case 'xls':
      case 'xlsx':
        iconData = Icons.table_chart;
        fileType = 'Excel 문서';
        break;
      case 'ppt':
      case 'pptx':
        iconData = Icons.slideshow;
        fileType = 'PowerPoint 문서';
        break;
      default:
        iconData = Icons.insert_drive_file;
        fileType = '문서';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            fileType,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.warning_outline,
                  color: Colors.orange[700],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  '이 파일 형식은 앱에서 직접 미리보기를 지원하지 않습니다.\n다운로드하여 확인해주세요.',
                  style: TextStyle(
                    color: Colors.orange[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _downloadDocument,
                icon: const Icon(Icons.download),
                label: const Text('다운로드'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _openInBrowser,
                icon: const Icon(Icons.open_in_browser),
                label: const Text('브라우저에서 열기'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isImageFile(String extension) {
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  void _loadDocument() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // 문서 로딩 시뮬레이션
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _openInBrowser() async {
    try {
      final uri = Uri.parse(widget.documentUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('브라우저를 열 수 없습니다.');
      }
    } catch (e) {
      _showErrorSnackBar('브라우저 열기에 실패했습니다: $e');
    }
  }

  Future<void> _downloadDocument() async {
    // TODO: 실제 다운로드 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('다운로드 기능은 준비 중입니다.'),
      ),
    );
  }

  Future<void> _shareDocument() async {
    // TODO: 실제 공유 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('공유 기능은 준비 중입니다.'),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
