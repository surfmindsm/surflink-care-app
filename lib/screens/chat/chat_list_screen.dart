import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/app_config.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> _chatRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  void _loadChatRooms() {
    // TODO: 실제 API 호출로 대체
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _chatRooms = _getSampleChatRooms();
        _isLoading = false;
      });
    });
  }

  List<Map<String, dynamic>> _getSampleChatRooms() {
    return [
      {
        'id': '1',
        'otherUserId': 'user1',
        'otherUserName': '김선생님',
        'otherUserImage': null,
        'lastMessage': '안녕하세요! 의뢰 건에 대해 문의드립니다.',
        'lastMessageTime': DateTime.now().subtract(const Duration(minutes: 5)),
        'unreadCount': 2,
        'isOnline': true,
        'requestId': 'request1',
        'requestTitle': '7세 아이 돌봄',
      },
      {
        'id': '2',
        'otherUserId': 'user2',
        'otherUserName': '박간병사',
        'otherUserImage': null,
        'lastMessage': '네, 언제든 연락주세요.',
        'lastMessageTime': DateTime.now().subtract(const Duration(hours: 2)),
        'unreadCount': 0,
        'isOnline': false,
        'requestId': 'request2',
        'requestTitle': '어르신 돌봄',
      },
      {
        'id': '3',
        'otherUserId': 'user3',
        'otherUserName': '이상담사',
        'otherUserImage': null,
        'lastMessage': '상담 시간 조정 가능할까요?',
        'lastMessageTime': DateTime.now().subtract(const Duration(days: 1)),
        'unreadCount': 1,
        'isOnline': true,
        'requestId': 'request3',
        'requestTitle': '심리 상담',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
        actions: [
          IconButton(
            onPressed: _showSearchDialog,
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildChatList(),
    );
  }

  Widget _buildChatList() {
    if (_chatRooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '채팅방이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '의뢰나 지원을 통해 채팅을 시작해보세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadChatRooms();
      },
      child: ListView.builder(
        itemCount: _chatRooms.length,
        itemBuilder: (context, index) {
          final chatRoom = _chatRooms[index];
          return _buildChatRoomTile(chatRoom);
        },
      ),
    );
  }

  Widget _buildChatRoomTile(Map<String, dynamic> chatRoom) {
    return InkWell(
      onTap: () => context.push('/chat/${chatRoom['id']}'),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConfig.defaultPadding,
          vertical: 12,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: chatRoom['otherUserImage'] != null
                      ? NetworkImage(chatRoom['otherUserImage']!)
                      : null,
                  child: chatRoom['otherUserImage'] == null
                      ? Text(
                          chatRoom['otherUserName'][0],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                if (chatRoom['isOnline'])
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chatRoom['otherUserName'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(chatRoom['lastMessageTime']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (chatRoom['requestTitle'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(AppConfig.primaryColor).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        chatRoom['requestTitle'],
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(AppConfig.primaryColor),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chatRoom['lastMessage'],
                          style: TextStyle(
                            fontSize: 14,
                            color: chatRoom['unreadCount'] > 0
                                ? Colors.black
                                : Colors.grey[600],
                            fontWeight: chatRoom['unreadCount'] > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chatRoom['unreadCount'] > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${chatRoom['unreadCount']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '방금';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일';
    } else {
      return DateFormat('MM/dd').format(time);
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사용자 검색'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: '이름을 입력하세요',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('검색 기능은 준비 중입니다')),
              );
            },
            child: const Text('검색'),
          ),
        ],
      ),
    );
  }
}
