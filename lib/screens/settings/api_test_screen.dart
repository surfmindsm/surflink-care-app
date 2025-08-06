import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final _scrollController = ScrollController();
  final List<ApiTestLog> _logs = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addLog(String message, ApiLogType type) {
    setState(() {
      _logs.add(ApiTestLog(
        message: message,
        type: type,
        timestamp: DateTime.now(),
      ));
    });
    
    // 자동으로 맨 아래로 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 기본 연결 테스트
  Future<void> _testBasicConnection() async {
    _addLog('[기본 연결] 테스트 시작', ApiLogType.info);
    setState(() => _isLoading = true);
    
    try {
      final response = await apiService.get('/rest/v1/');
      _addLog('[기본 연결] 성공: ${response.statusCode}', ApiLogType.success);
    } catch (e) {
      _addLog('[기본 연결] 실패: $e', ApiLogType.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 회원가입 테스트 (Edge Function)
  Future<void> _testSignup() async {
    _addLog('[회원가입] 테스트 시작', ApiLogType.info);
    setState(() => _isLoading = true);
    
    try {
      final response = await apiService.invokeFunction('auth-signup', body: {
        'email': 'test-${DateTime.now().millisecondsSinceEpoch}@example.com',
        'password': 'test123456',
        'user_type': 'customer',
        'full_name': '테스트 사용자',
        'phone': '010-1234-5678',
      });
      
      _addLog('[회원가입] 성공', ApiLogType.success);
      _addLog('응답 데이터: $response', ApiLogType.info);
    } catch (e) {
      _addLog('[회원가입] 실패: $e', ApiLogType.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 로그인 테스트
  Future<void> _testLogin() async {
    _addLog('[로그인] 테스트 시작', ApiLogType.info);
    _addLog('Email: test@example.com', ApiLogType.info);
    _addLog('Password: test123456', ApiLogType.info);
    
    setState(() => _isLoading = true);
    
    try {
      final response = await apiService.post('/auth/v1/token', data: {
        'email': 'test@example.com',
        'password': 'test123456',
      });
      
      _addLog('[로그인] 성공: ${response.statusCode}', ApiLogType.success);
      _addLog('응답 데이터: ${response.data}', ApiLogType.info);
    } catch (e) {
      _addLog('[로그인] 실패: $e', ApiLogType.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 프로필 목록 테스트
  Future<void> _testProfileList() async {
    _addLog('[프로필 목록] 테스트 시작', ApiLogType.info);
    setState(() => _isLoading = true);
    
    try {
      final response = await apiService.get('/rest/v1/profiles');
      _addLog('[프로필 목록] 성공: ${response.statusCode}', ApiLogType.success);
      
      final data = response.data;
      if (data is List) {
        _addLog('프로필 수: ${data.length}개', ApiLogType.info);
        if (data.isNotEmpty) {
          _addLog('첫 번째 프로필: ${data.first}', ApiLogType.info);
        }
      } else {
        _addLog('응답 데이터: $data', ApiLogType.info);
      }
    } catch (e) {
      _addLog('[프로필 목록] 실패: $e', ApiLogType.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 서비스 의뢰 목록 테스트
  Future<void> _testServiceRequests() async {
    _addLog('[서비스 의뢰] 테스트 시작', ApiLogType.info);
    setState(() => _isLoading = true);
    
    try {
      final response = await apiService.get('/rest/v1/service_requests');
      _addLog('[서비스 의뢰] 성공: ${response.statusCode}', ApiLogType.success);
      
      final data = response.data;
      if (data is List) {
        _addLog('의뢰 수: ${data.length}개', ApiLogType.info);
        if (data.isNotEmpty) {
          _addLog('첫 번째 의뢰: ${data.first}', ApiLogType.info);
        }
      } else {
        _addLog('응답 데이터: $data', ApiLogType.info);
      }
    } catch (e) {
      _addLog('[서비스 의뢰] 실패: $e', ApiLogType.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 매칭 목록 테스트
  Future<void> _testMatchings() async {
    _addLog('[매칭 목록] 테스트 시작', ApiLogType.info);
    setState(() => _isLoading = true);
    
    try {
      final response = await apiService.get('/rest/v1/matchings');
      _addLog('[매칭 목록] 성공: ${response.statusCode}', ApiLogType.success);
      
      final data = response.data;
      if (data is List) {
        _addLog('매칭 수: ${data.length}개', ApiLogType.info);
        if (data.isNotEmpty) {
          _addLog('첫 번째 매칭: ${data.first}', ApiLogType.info);
        }
      } else {
        _addLog('응답 데이터: $data', ApiLogType.info);
      }
    } catch (e) {
      _addLog('[매칭 목록] 실패: $e', ApiLogType.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 결제 내역 테스트
  Future<void> _testPayments() async {
    _addLog('[결제 내역] 테스트 시작', ApiLogType.info);
    setState(() => _isLoading = true);
    
    try {
      final response = await apiService.get('/rest/v1/payments');
      _addLog('[결제 내역] 성공: ${response.statusCode}', ApiLogType.success);
      
      final data = response.data;
      if (data is List) {
        _addLog('결제 수: ${data.length}개', ApiLogType.info);
        if (data.isNotEmpty) {
          _addLog('첫 번째 결제: ${data.first}', ApiLogType.info);
        }
      } else {
        _addLog('응답 데이터: $data', ApiLogType.info);
      }
    } catch (e) {
      _addLog('[결제 내역] 실패: $e', ApiLogType.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 리뷰 목록 테스트
  Future<void> _testReviews() async {
    _addLog('[리뷰 목록] 테스트 시작', ApiLogType.info);
    setState(() => _isLoading = true);
    
    try {
      final response = await apiService.get('/rest/v1/reviews');
      _addLog('[리뷰 목록] 성공: ${response.statusCode}', ApiLogType.success);
      
      final data = response.data;
      if (data is List) {
        _addLog('리뷰 수: ${data.length}개', ApiLogType.info);
        if (data.isNotEmpty) {
          _addLog('첫 번째 리뷰: ${data.first}', ApiLogType.info);
        }
      } else {
        _addLog('응답 데이터: $data', ApiLogType.info);
      }
    } catch (e) {
      _addLog('[리뷰 목록] 실패: $e', ApiLogType.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 모든 테스트 실행
  Future<void> _runAllTests() async {
    setState(() {
      _logs.clear();
    });
    _addLog('=== 전체 테스트 시작 ===', ApiLogType.info);
    
    await _testBasicConnection();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await _testSignup();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await _testLogin();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await _testProfileList();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await _testServiceRequests();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await _testMatchings();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await _testPayments();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await _testReviews();
    
    _addLog('=== 전체 테스트 완료 ===', ApiLogType.info);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API 테스트'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          // 테스트 상태 표시
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_logs.where((log) => log.type == ApiLogType.success).length}/${_logs.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 로그인 필요 경고
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.orange[50],
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PRIFREE API 테스트',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '프리랜서 중개 플랫폼 API 연결 상태를 확인할 수 있습니다:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'API: 회원가입, 로그인, 프로필, 서비스의뢰, 매칭, 결제, 리뷰',
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 테스트 버튼들
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 인증 테스트
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testBasicConnection,
                        icon: const Icon(Icons.wifi_outlined),
                        label: const Text('기본 연결'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testSignup,
                        icon: const Icon(Icons.person_add),
                        label: const Text('회원가입'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testLogin,
                        icon: const Icon(Icons.login),
                        label: const Text('로그인'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testProfileList,
                        icon: const Icon(Icons.people_outline),
                        label: const Text('프로필 목록'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 서비스 관리
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testServiceRequests,
                        icon: const Icon(Icons.work_outline),
                        label: const Text('서비스 의뢰'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testMatchings,
                        icon: const Icon(Icons.handshake_outlined),
                        label: const Text('매칭'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 결제 및 리뷰
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testPayments,
                        icon: const Icon(Icons.payment),
                        label: const Text('결제 내역'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testReviews,
                        icon: const Icon(Icons.star_outline),
                        label: const Text('리뷰 목록'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 전체 테스트
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _runAllTests,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('모든 테스트 실행'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 진행 상태 표시
          if (_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('테스트 중...', style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
          
          // 상태 표시
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '전체 ${_logs.length}개 테스트 중 ${_logs.where((log) => log.type == ApiLogType.success).length}개 성공',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (_logs.isNotEmpty)
                  Text(
                    '최종: ${_logs.last.timestamp.toString().substring(11, 19)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),

          // 로그 표시
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '디버그 로그',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        // 로그 개수 표시
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_logs.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 로그 복사 버튼
                        IconButton(
                          onPressed: _logs.isEmpty ? null : () {
                            final logs = _logs.map((log) => 
                              '[${log.timestamp.toString().substring(11, 19)}] ${log.message}'
                            ).join('\n');
                            Clipboard.setData(ClipboardData(text: logs));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('로그가 클립보드에 복사되었습니다'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.copy,
                            color: _logs.isEmpty ? Colors.grey[400] : Colors.white,
                            size: 18,
                          ),
                          tooltip: '로그 복사',
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: const EdgeInsets.all(4),
                        ),
                        // 로그 삭제 버튼
                        IconButton(
                          onPressed: _logs.isEmpty ? null : () {
                            setState(() {
                              _logs.clear();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('로그가 삭제되었습니다'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.delete_sweep,
                            color: _logs.isEmpty ? Colors.grey[400] : Colors.red[300],
                            size: 18,
                          ),
                          tooltip: '로그 삭제',
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: const EdgeInsets.all(4),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _logs.isEmpty
                        ? const Center(
                            child: Text(
                              '테스트를 실행하면 로그가 표시됩니다.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(8),
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              final log = _logs[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 1),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '[${log.timestamp.toString().substring(11, 19)}] ',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                      TextSpan(
                                        text: log.message,
                                        style: TextStyle(color: log.color),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class ApiTestLog {
  final String message;
  final ApiLogType type;
  final DateTime timestamp;

  ApiTestLog({
    required this.message,
    required this.type,
    required this.timestamp,
  });

  Color get color {
    switch (type) {
      case ApiLogType.success:
        return Colors.green;
      case ApiLogType.error:
        return Colors.red;
      case ApiLogType.warning:
        return Colors.orange;
      case ApiLogType.info:
        return Colors.white;
    }
  }
}

enum ApiLogType {
  success,
  error,
  warning,
  info,
}
