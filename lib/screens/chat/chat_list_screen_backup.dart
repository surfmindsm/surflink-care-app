import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/chat.dart';
import '../../services/chat_service.dart';
import '../../providers/auth_provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with TickerProviderStateMixin {
  final ChatService _chatService = ChatService();
  
  late TabController _tabController;
  List<ChatRoom> _allChatRooms = [];
  List<ChatRoom> _filteredChatRooms = [];
  bool _isLoading = true;
  
  final List<String> _tabLabels = [
    '전체',
    '매칭',
    '계약',
    '지원',
  ];
  
  final List<ChatRoomType?> _tabFilters = [
    null, // 전체
    ChatRoomType.matching,
    ChatRoomType.contract,
    ChatRoomType.support,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadChatRooms();
    _listenToChatUpdates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _filterChatRooms();
    }
  }

  void _filterChatRooms() {
    final selectedFilter = _tabFilters[_tabController.index];
    setState(() {
      if (selectedFilter == null) {
        _filteredChatRooms = List.from(_allChatRooms);
      } else {
        _filteredChatRooms = _allChatRooms
            .where((room) => room.type == selectedFilter)
            .toList();
      }
    });
  }

  Future<void> _loadChatRooms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final chatRooms = await _chatService.getChatRooms();
      setState(() {
        _allChatRooms = chatRooms;
        _filterChatRooms();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('채팅방 목록을 불러오는데 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _listenToChatUpdates() {
    _chatService.getChatRoomUpdatesStream().listen((updatedRoom) {
      setState(() {
        final index = _allChatRooms.indexWhere((room) => room.id == updatedRoom.id);
        if (index != -1) {
          _allChatRooms[index] = updatedRoom;
        } else {
          _allChatRooms.insert(0, updatedRoom);
        }
        _filterChatRooms();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final isFreelancer = user?.isFreelancer == true;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(isFreelancer ? '고객 채팅' : '전문가 채팅'),
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshChatRooms,
              child: _filteredChatRooms.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredChatRooms.length,
                      itemBuilder: (context, index) {
                        return _ChatRoomCard(
                          chatRoom: _filteredChatRooms[index],
                          onTap: () => _navigateToChat(_filteredChatRooms[index]),
                          onLongPress: () => _showChatRoomOptions(_filteredChatRooms[index]),
                        );
                      },
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
          final room = _allChatRooms[index];
          _allChatRooms[index] = ChatRoom(
            id: room.id,
            name: room.name,
            type: room.type,
            status: room.status,
            participantIds: room.participantIds,
            participants: room.participants,
            requestId: room.requestId,
            contractId: room.contractId,
            matchingId: room.matchingId,
            lastMessage: room.lastMessage,
            unreadCount: 0,
            createdAt: room.createdAt,
            updatedAt: room.updatedAt,
            lastActivityAt: room.lastActivityAt,
            metadata: room.metadata,
          );
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
}
