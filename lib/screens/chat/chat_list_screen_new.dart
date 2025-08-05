import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/chat.dart';
import '../../services/chat_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ChatService _chatService = ChatService();

  List<ChatRoom> _chatRooms = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadChatRooms();
    _listenToChatRoomUpdates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadChatRooms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final chatRooms = await _chatService.getChatRooms();
      setState(() {
        _chatRooms = chatRooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('채팅방 목록 로딩 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _listenToChatRoomUpdates() {
    _chatService.getChatRoomStream().listen((updatedRoom) {
      setState(() {
        final index = _chatRooms.indexWhere((room) => room.id == updatedRoom.id);
        if (index != -1) {
          _chatRooms[index] = updatedRoom;
        } else {
          _chatRooms.insert(0, updatedRoom);
        }
        // 최신 활동 순으로 정렬
        _chatRooms.sort((a, b) => 
          (b.lastActivityAt ?? b.updatedAt).compareTo(a.lastActivityAt ?? a.updatedAt));
      });
    });
  }

  Future<void> _refreshChatRooms() async {
    setState(() {
      _isRefreshing = true;
    });
    
    await _loadChatRooms();
    
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: '전체 (${_chatRooms.length})'),
            Tab(text: '매칭 (${_getChatRoomsByType(ChatRoomType.matching).length})'),
            Tab(text: '계약 (${_getChatRoomsByType(ChatRoomType.contract).length})'),
            Tab(text: '지원 (${_getChatRoomsByType(ChatRoomType.support).length})'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshChatRooms,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshChatRooms,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildChatRoomList(null), // 전체
                  _buildChatRoomList(ChatRoomType.matching),
                  _buildChatRoomList(ChatRoomType.contract),
                  _buildChatRoomList(ChatRoomType.support),
                ],
              ),
            ),
    );
  }

  List<ChatRoom> _getChatRoomsByType(ChatRoomType? type) {
    if (type == null) return _chatRooms;
    return _chatRooms.where((room) => room.type == type).toList();
  }

  Widget _buildChatRoomList(ChatRoomType? type) {
    final filteredRooms = _getChatRoomsByType(type);

    if (filteredRooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '채팅방이 없습니다',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type == null
                  ? '매칭이 성사되면 채팅방이 생성됩니다'
                  : '${type.displayName} 채팅방이 없습니다',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredRooms.length,
      itemBuilder: (context, index) {
        final chatRoom = filteredRooms[index];
        return _ChatRoomCard(
          chatRoom: chatRoom,
          onTap: () => _openChatRoom(chatRoom),
          onLongPress: () => _showChatRoomOptions(chatRoom),
        );
      },
    );
  }

  void _openChatRoom(ChatRoom chatRoom) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatRoom: chatRoom),
      ),
    );

    if (result == true) {
      _loadChatRooms();
    }
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
                  leading: const Icon(Icons.report, color: Colors.red),
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
                  _showLeaveChatRoomDialog(chatRoom);
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
      _loadChatRooms();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('읽음 처리 중 오류가 발생했습니다: $e'),
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
    final otherParticipant = chatRoom.getOtherParticipant('current_user');
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('사용자 신고'),
          content: Text('${otherParticipant?.name ?? '상대방'}님을 신고하시겠습니까?\n\n부적절한 행동이나 발언을 신고해주세요. 신고 내용은 검토 후 적절한 조치가 취해집니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _reportUser(chatRoom, otherParticipant?.userId ?? '');
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('신고'),
            ),
          ],
        );
      },
    );
  }

  void _reportUser(ChatRoom chatRoom, String userId) async {
    try {
      final result = await _chatService.reportUser(
        chatRoom.id,
        userId,
        '부적절한 행동',
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('신고 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLeaveChatRoomDialog(ChatRoom chatRoom) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('채팅방 나가기'),
          content: const Text('정말로 채팅방을 나가시겠습니까?\n\n채팅방을 나가면 대화 내역을 다시 볼 수 없습니다.'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        _loadChatRooms();
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('채팅방 나가기 중 오류가 발생했습니다: $e'),
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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 프로필 이미지
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blue[100],
                    backgroundImage: otherParticipant?.profileImageUrl != null
                        ? NetworkImage(otherParticipant!.profileImageUrl!)
                        : null,
                    child: otherParticipant?.profileImageUrl == null
                        ? Text(
                            otherParticipant?.name.substring(0, 1) ?? '?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                  // 온라인 상태 표시
                  if (otherParticipant?.isOnline == true)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
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
              
              // 채팅 정보
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // 채팅방 타입 배지
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getChatRoomTypeColor(chatRoom.type).withOpacity(0.1),
                            border: Border.all(color: _getChatRoomTypeColor(chatRoom.type)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getChatRoomTypeText(chatRoom.type),
                            style: TextStyle(
                              color: _getChatRoomTypeColor(chatRoom.type),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // 마지막 메시지
                    Text(
                      chatRoom.lastMessage?.displayContent ?? '대화를 시작해보세요',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // 시간과 상태 정보
                    Row(
                      children: [
                        Text(
                          _formatLastMessageTime(chatRoom.lastMessage?.createdAt ?? chatRoom.updatedAt),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        if (otherParticipant?.isOnline == false && otherParticipant?.lastSeenAt != null) ...[
                          Text(
                            ' • ${_formatLastSeen(otherParticipant!.lastSeenAt!)}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const Spacer(),
                        
                        // 읽지 않은 메시지 수
                        if (chatRoom.hasUnreadMessages())
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              chatRoom.unreadCount > 99 ? '99+' : '${chatRoom.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Color _getChatRoomTypeColor(ChatRoomType type) {
    switch (type) {
      case ChatRoomType.matching:
        return Colors.blue;
      case ChatRoomType.contract:
        return Colors.green;
      case ChatRoomType.support:
        return Colors.orange;
    }
  }

  String _getChatRoomTypeText(ChatRoomType type) {
    switch (type) {
      case ChatRoomType.matching:
        return '매칭';
      case ChatRoomType.contract:
        return '계약';
      case ChatRoomType.support:
        return '지원';
    }
  }

  String _formatLastMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays < 7) {
      return DateFormat('E HH:mm', 'ko_KR').format(dateTime);
    } else {
      return DateFormat('MM/dd').format(dateTime);
    }
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return '방금 접속';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전 접속';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전 접속';
    } else {
      return '${difference.inDays}일 전 접속';
    }
  }
}
