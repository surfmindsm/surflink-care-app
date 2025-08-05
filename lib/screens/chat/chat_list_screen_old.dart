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
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;
    
    final currentFilter = _tabFilters[_tabController.index];
    switch (currentFilter) {
      case ChatRoomType.matching:
        message = '매칭 채팅이 없습니다';
        icon = Icons.people;
        break;
      case ChatRoomType.contract:
        message = '계약 채팅이 없습니다';
        icon = Icons.description;
        break;
      case ChatRoomType.support:
        message = '지원 채팅이 없습니다';
        icon = Icons.support_agent;
        break;
      default:
        message = '채팅방이 없습니다';
        icon = Icons.chat;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshChatRooms() async {
    await _loadChatRooms();
  }

  void _navigateToChat(ChatRoom chatRoom) {
    context.push('/chat/${chatRoom.id}', extra: chatRoom);
  }

  void _showChatRoomOptions(ChatRoom chatRoom) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.mark_chat_read),
                title: const Text('읽음으로 표시'),
                onTap: () {
                  Navigator.pop(context);
                  _markAsRead(chatRoom);
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_off),
                title: const Text('알림 끄기'),
                onTap: () {
                  Navigator.pop(context);
                  _muteNotifications(chatRoom);
                },
              ),
              if (chatRoom.type != ChatRoomType.support)
                ListTile(
                  leading: const Icon(Icons.report, color: Colors.orange),
                  title: const Text('신고하기'),
                  onTap: () {
                    Navigator.pop(context);
                    _showReportDialog(chatRoom);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text('채팅방 나가기'),
                onTap: () {
                  Navigator.pop(context);
                  _showLeaveDialog(chatRoom);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _markAsRead(ChatRoom chatRoom) async {
    try {
      await _chatService.markMessagesAsRead(chatRoom.id);
      
      setState(() {
        final index = _allChatRooms.indexWhere((room) => room.id == chatRoom.id);
        if (index != -1) {
          _allChatRooms[index] = _allChatRooms[index].copyWith(unreadCount: 0);
          _filterChatRooms();
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('읽음으로 표시했습니다'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('읽음 표시에 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _muteNotifications(ChatRoom chatRoom) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${chatRoom.name} 알림이 꺼졌습니다'),
        action: SnackBarAction(
          label: '실행취소',
          onPressed: () {},
        ),
      ),
    );
  }

  void _showReportDialog(ChatRoom chatRoom) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('사용자 신고'),
          content: Text('${chatRoom.getOtherParticipant('current_user')?.name ?? '상대방'}님을 신고하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _reportUser(chatRoom);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('신고'),
            ),
          ],
        );
      },
    );
  }

  void _reportUser(ChatRoom chatRoom) async {
    try {
      final otherParticipant = chatRoom.getOtherParticipant('current_user');
      if (otherParticipant == null) return;

      final result = await _chatService.reportUser(
        chatRoom.id,
        otherParticipant.userId,
        '부적절한 행동',
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('신고에 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLeaveDialog(ChatRoom chatRoom) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('채팅방 나가기'),
          content: const Text('채팅방을 나가시겠습니까?\n\n채팅 기록이 삭제되며 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _leaveChatRoom(chatRoom);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('나가기'),
            ),
          ],
        );
      },
    );
  }

  void _leaveChatRoom(ChatRoom chatRoom) async {
    try {
      final result = await _chatService.leaveChatRoom(chatRoom.id);

      if (result['success']) {
        setState(() {
          _allChatRooms.removeWhere((room) => room.id == chatRoom.id);
          _filterChatRooms();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('채팅방 나가기에 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _ChatRoomCard extends StatelessWidget {
  final ChatRoom chatRoom;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ChatRoomCard({
    required this.chatRoom,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final otherParticipant = chatRoom.getOtherParticipant('current_user');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 프로필 이미지 및 온라인 상태
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: otherParticipant?.profileImageUrl != null
                        ? NetworkImage(otherParticipant!.profileImageUrl!)
                        : null,
                    child: otherParticipant?.profileImageUrl == null
                        ? Text(
                            otherParticipant?.name.substring(0, 1) ?? '?',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  if (otherParticipant?.isOnline == true)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              
              // 채팅방 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chatRoom.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // 채팅방 타입 뱃지
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: chatRoom.type.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            chatRoom.type.displayName,
                            style: TextStyle(
                              color: chatRoom.type.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    Row(
                      children: [
                        // 메시지 타입 아이콘
                        if (chatRoom.lastMessage != null)
                          Icon(
                            chatRoom.lastMessage!.type.icon,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                        if (chatRoom.lastMessage != null)
                          const SizedBox(width: 4),
                        
                        // 마지막 메시지
                        Expanded(
                          child: Text(
                            chatRoom.lastMessage?.content ?? '메시지가 없습니다',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              // 시간 및 읽지 않은 메시지 수
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(chatRoom.updatedAt),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (chatRoom.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: const BoxConstraints(minWidth: 20),
                      child: Text(
                        chatRoom.unreadCount > 99
                            ? '99+'
                            : chatRoom.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays < 7) {
      return DateFormat('E요일', 'ko_KR').format(dateTime);
    } else {
      return DateFormat('M/d').format(dateTime);
    }
  }
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
