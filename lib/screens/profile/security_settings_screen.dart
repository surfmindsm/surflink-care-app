import 'package:flutter/material.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _twoFactorEnabled = false;
  bool _biometricEnabled = true;
  bool _deviceNotifications = true;
  bool _securityAlerts = true;

  // 목업 로그인 기록
  List<Map<String, dynamic>> _getLoginHistory() {
    return [
      {
        'device': 'iPhone 14 Pro',
        'location': '서울, 대한민국',
        'time': DateTime(2024, 7, 16, 14, 30),
        'ip': '192.168.1.100',
        'status': 'success',
        'current': true,
      },
      {
        'device': 'Chrome (macOS)',
        'location': '서울, 대한민국',
        'time': DateTime(2024, 7, 15, 9, 15),
        'ip': '192.168.1.101',
        'status': 'success',
        'current': false,
      },
      {
        'device': 'Samsung Galaxy S24',
        'location': '부산, 대한민국',
        'time': DateTime(2024, 7, 10, 18, 45),
        'ip': '211.234.123.45',
        'status': 'failed',
        'current': false,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('보안 설정'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPasswordSection(),
            const SizedBox(height: 16),
            _buildTwoFactorSection(),
            const SizedBox(height: 16),
            _buildBiometricSection(),
            const SizedBox(height: 16),
            _buildNotificationSection(),
            const SizedBox(height: 16),
            _buildLoginHistorySection(),
            const SizedBox(height: 16),
            _buildDataSection(),
            const SizedBox(height: 16),
            _buildAccountSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordSection() {
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
          const Text(
            '비밀번호 관리',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('비밀번호 변경'),
            subtitle: const Text('마지막 변경: 3개월 전'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changePassword,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('비밀번호 변경 이력'),
            subtitle: const Text('최근 비밀번호 변경 기록 확인'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _viewPasswordHistory,
          ),
        ],
      ),
    );
  }

  Widget _buildTwoFactorSection() {
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
          const Text(
            '2차 인증',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '계정 보안을 강화하기 위해 2차 인증을 활성화하세요.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            secondary: const Icon(Icons.security),
            title: const Text('2차 인증 활성화'),
            subtitle: Text(_twoFactorEnabled ? 'SMS 인증으로 보호 중' : '비활성화됨'),
            value: _twoFactorEnabled,
            onChanged: (value) {
              setState(() => _twoFactorEnabled = value);
              if (value) {
                _setupTwoFactor();
              } else {
                _disableTwoFactor();
              }
            },
          ),
          if (_twoFactorEnabled) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.smartphone),
              title: const Text('인증 방법 변경'),
              subtitle: const Text('SMS → 앱 인증으로 변경'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _changeTwoFactorMethod,
            ),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('백업 코드'),
              subtitle: const Text('비상시 사용할 백업 코드 생성'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _generateBackupCodes,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBiometricSection() {
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
          const Text(
            '생체 인증',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '지문 또는 얼굴 인식으로 빠르고 안전하게 로그인하세요.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('생체 인증 사용'),
            subtitle: Text(_biometricEnabled ? 'Face ID 활성화됨' : '비활성화됨'),
            value: _biometricEnabled,
            onChanged: (value) {
              setState(() => _biometricEnabled = value);
              if (value) {
                _enableBiometric();
              } else {
                _disableBiometric();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection() {
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
          const Text(
            '보안 알림',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '의심스러운 활동이 감지되면 알림을 받습니다.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            secondary: const Icon(Icons.devices),
            title: const Text('새 기기 로그인 알림'),
            subtitle: const Text('새로운 기기에서 로그인 시 알림'),
            value: _deviceNotifications,
            onChanged: (value) => setState(() => _deviceNotifications = value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.warning_amber),
            title: const Text('보안 경고 알림'),
            subtitle: const Text('의심스러운 활동 감지 시 알림'),
            value: _securityAlerts,
            onChanged: (value) => setState(() => _securityAlerts = value),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginHistorySection() {
    final loginHistory = _getLoginHistory();
    
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
              const Text(
                '로그인 기록',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: _viewFullLoginHistory,
                child: const Text('전체 보기'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '최근 로그인 활동을 확인하세요.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ...loginHistory.take(3).map((login) => _buildLoginHistoryItem(login)).toList(),
        ],
      ),
    );
  }

  Widget _buildLoginHistoryItem(Map<String, dynamic> login) {
    IconData deviceIcon;
    if (login['device'].contains('iPhone') || login['device'].contains('Samsung')) {
      deviceIcon = Icons.smartphone;
    } else {
      deviceIcon = Icons.computer;
    }

    Color statusColor = login['status'] == 'success' ? Colors.green : Colors.red;
    String statusText = login['status'] == 'success' ? '성공' : '실패';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: login['current'] ? Border.all(color: Colors.blue, width: 2) : null,
      ),
      child: Row(
        children: [
          Icon(deviceIcon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      login['device'],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (login['current']) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '현재',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  login['location'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                Text(
                  '${_formatDateTime(login['time'])} • ${login['ip']}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
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
          const Text(
            '데이터 관리',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('내 데이터 다운로드'),
            subtitle: const Text('개인정보 및 활동 데이터 내려받기'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _downloadMyData,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('개인정보 처리방침'),
            subtitle: const Text('개인정보 처리 및 보호 정책 확인'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _viewPrivacyPolicy,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('보안 감사 로그'),
            subtitle: const Text('계정 보안 관련 활동 기록'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _viewSecurityAuditLog,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
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
          const Text(
            '계정 관리',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.block, color: Colors.orange),
            title: const Text('계정 일시 정지'),
            subtitle: const Text('일정 기간 계정 사용을 중단합니다'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _suspendAccount,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('계정 삭제', style: TextStyle(color: Colors.red)),
            subtitle: const Text('계정과 모든 데이터를 영구 삭제합니다'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _deleteAccount,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('비밀번호 변경'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '현재 비밀번호',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '새 비밀번호',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '새 비밀번호 확인',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('비밀번호가 변경되었습니다')),
              );
            },
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }

  void _viewPasswordHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('비밀번호 변경 이력을 확인합니다')),
    );
  }

  void _setupTwoFactor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('2차 인증 설정'),
        content: const Text('휴대폰 번호로 인증 코드를 받으시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _twoFactorEnabled = false);
            },
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('2차 인증이 활성화되었습니다')),
              );
            },
            child: const Text('설정'),
          ),
        ],
      ),
    );
  }

  void _disableTwoFactor() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('2차 인증이 비활성화되었습니다')),
    );
  }

  void _changeTwoFactorMethod() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('인증 방법 변경 화면으로 이동합니다')),
    );
  }

  void _generateBackupCodes() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('백업 코드를 생성합니다')),
    );
  }

  void _enableBiometric() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('생체 인증이 활성화되었습니다')),
    );
  }

  void _disableBiometric() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('생체 인증이 비활성화되었습니다')),
    );
  }

  void _viewFullLoginHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('전체 로그인 기록을 확인합니다')),
    );
  }

  void _downloadMyData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('데이터 다운로드를 시작합니다')),
    );
  }

  void _viewPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('개인정보 처리방침을 확인합니다')),
    );
  }

  void _viewSecurityAuditLog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('보안 감사 로그를 확인합니다')),
    );
  }

  void _suspendAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 일시 정지'),
        content: const Text('정말로 계정을 일시 정지하시겠습니까?\n정지 기간 동안 서비스를 이용할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('계정이 일시 정지되었습니다')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('정지'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 삭제'),
        content: const Text('정말로 계정을 삭제하시겠습니까?\n\n이 작업은 되돌릴 수 없으며, 모든 데이터가 영구적으로 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('최종 확인'),
                  content: const Text('계정 삭제를 위해 비밀번호를 입력해주세요.'),
                  actions: [
                    TextField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: '비밀번호',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('취소'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('계정이 삭제되었습니다')),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('삭제'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
