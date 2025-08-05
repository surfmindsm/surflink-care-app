import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_config.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  Map<String, dynamic>? _otherUser;
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadChatData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadChatData() {
    // TODO: 실제 API 호출로 대체
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _otherUser = _getSampleOtherUser();
        _messages = _getSampleMessages();
        _isLoading = false;
      });
      _scrollToBottom();
    });
  }

  Map<String, dynamic> _getSampleOtherUser() {
    return {
      'id': 'user1',
      'name': '김선생님',
      'image': null,
      'isOnline': true,
      'lastSeen': DateTime.now().subtract(const Duration(minutes: 2)),
    };
  }

  List<Map<String, dynamic>> _getSampleMessages() {
    return [
      {
        'id': '1',
        'senderId': 'user1',
        'message': '안녕하세요! 의뢰 건에 대해 문의드립니다.',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'type': 'text',
        'isRead': true,
      },
      {
        'id': '2',
        'senderId': 'current_user',
        'message': '네, 안녕하세요! 어떤 것이 궁금하신가요?',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2, minutes: 58)),
        'type': 'text',
        'isRead': true,
      },
      {
        'id': '3',
        'senderId': 'user1',
        'message': '아이 돌봄 시간이 평일 오후 2시부터 6시까지인데, 혹시 가능하신가요?',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        'type': 'text',
        'isRead': true,
      },
      {
        'id': '4',
        'senderId': 'current_user',
        'message': '네, 그 시간대는 가능합니다. 아이 연령대와 특별히 주의할 점이 있을까요?',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
        'type': 'text',
        'isRead': true,
      },
      {
        'id': '5',
        'senderId': 'user1',
        'message': '7세 남자아이이고, 활발한 편이에요. 간단한 간식 준비와 숙제 도움 부탁드립니다.',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 10)),
        'type': 'text',
        'isRead': false,
      },
    ];
  }

  void _scrollToBottom() {
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

  @override
  Widget build(BuildContext context) {
    
    if (_isLoading || _otherUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: _otherUser!['image'] != null
                  ? NetworkImage(_otherUser!['image']!)
                  : null,
              child: _otherUser!['image'] == null
                  ? Text(
                      _otherUser!['name'][0],
                      style: const TextStyle(fontSize: 12),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _otherUser!['name'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    _otherUser!['isOnline'] ? '온라인' : '오프라인',
                    style: TextStyle(
                      fontSize: 12,
                      color: _otherUser!['isOnline'] ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showMenuDialog,
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppConfig.defaultPadding),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['senderId'] == 'current_user';
                final showTimestamp = index == 0 ||
                    _shouldShowTimestamp(
                      _messages[index - 1]['timestamp'],
                      message['timestamp'],
                    );

                return Column(
                  children: [
                    if (showTimestamp) _buildTimestamp(message['timestamp']),
                    _buildMessageBubble(message, isMe),
                  ],
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildTimestamp(DateTime timestamp) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        DateFormat('MM월 dd일 HH:mm').format(timestamp),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 12,
              backgroundImage: _otherUser!['image'] != null
                  ? NetworkImage(_otherUser!['image']!)
                  : null,
              child: _otherUser!['image'] == null
                  ? Text(
                      _otherUser!['name'][0],
                      style: const TextStyle(fontSize: 8),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMe
                    ? Color(AppConfig.primaryColor)
                    : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                ),
              ),
              child: Text(
                message['message'],
                style: TextStyle(
                  fontSize: 14,
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Column(
              children: [
                Text(
                  DateFormat('HH:mm').format(message['timestamp']),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                if (message['isRead'])
                  Icon(
                    Icons.check,
                    size: 12,
                    color: Color(AppConfig.primaryColor),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _showAttachmentOptions,
            icon: const Icon(Icons.add),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: '메시지를 입력하세요...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: null,
              textInputAction: TextInputAction.newline,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            onPressed: _isSending ? null : _sendMessage,
            icon: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    Icons.send,
                    color: Color(AppConfig.primaryColor),
                  ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowTimestamp(DateTime prev, DateTime current) {
    return current.difference(prev).inMinutes > 30;
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      // TODO: 실제 API 호출로 대체
      await Future.delayed(const Duration(seconds: 1));

      final newMessage = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'senderId': 'current_user',
        'message': text,
        'timestamp': DateTime.now(),
        'type': 'text',
        'isRead': false,
      };

      setState(() {
        _messages.add(newMessage);
        _messageController.clear();
      });

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('메시지 전송 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('사진'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('사진 전송 기능은 준비 중입니다')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.attachment),
              title: const Text('파일'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('파일 전송 기능은 준비 중입니다')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMenuDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('프로필 보기'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 프로필 화면으로 이동
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('프로필 보기 기능은 준비 중입니다')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('차단하기'),
              onTap: () {
                Navigator.pop(context);
                _showBlockDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('신고하기'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사용자 차단'),
        content: Text('${_otherUser!['name']}님을 차단하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('차단 기능은 준비 중입니다')),
              );
            },
            child: const Text('차단'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사용자 신고'),
        content: Text('${_otherUser!['name']}님을 신고하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('신고 기능은 준비 중입니다')),
              );
            },
            child: const Text('신고'),
          ),
        ],
      ),
    );
  }
}
