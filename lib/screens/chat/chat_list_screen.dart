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
                      ? _buildEmptyState(isFreelancer)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredChatRooms.length,
                          itemBuilder: (context, index) {
                            return _ChatRoomCard(
                              chatRoom: _filteredChatRooms[index],
                              isFreelancer: isFreelancer,
                              onTap: () => _navigateToChat(_filteredChatRooms[index]),
                              onLongPress: () => _showChatRoomOptions(_filteredChatRooms[index]),
                            );
                          },
                        ),
                ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isFreelancer) {
    String message;
    IconData icon;
    
    switch (_tabController.index) {
      case 0:
        message = isFreelancer ? '고객과의 채팅이 없습니다' : '전문가와의 채팅이 없습니다';
        icon = Icons.chat_bubble_outline;
        break;
      case 1:
        message = '매칭 관련 채팅이 없습니다';
        icon = Icons.people_outline;
        break;
      case 2:
        message = '계약 관련 채팅이 없습니다';
        icon = Icons.assignment_outlined;
        break;
      case 3:
        message = '지원 관련 채팅이 없습니다';
        icon = Icons.support_agent_outlined;
        break;
      default:
        message = '채팅이 없습니다';
        icon = Icons.chat_bubble_outline;
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
          if (isFreelancer) ...[
            const SizedBox(height: 16),
            Text(
              '의뢰에 지원하면 고객과 채팅할 수 있습니다',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            const SizedBox(height: 16),
            Text(
              '의뢰를 등록하고 전문가를 찾아보세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _refreshChatRooms() async {
    await _loadChatRooms();
  }

  void _navigateToChat(ChatRoom chatRoom) {
    context.go('/chats/${chatRoom.id}');
  }

  void _showChatRoomOptions(ChatRoom chatRoom) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mark_chat_read),
              title: const Text('읽음 처리'),
              onTap: () {
                Navigator.pop(context);
                _markAsRead(chatRoom);
              },
            ),
            ListTile(
              leading: const Icon(Icons.volume_off),
              title: const Text('알림 설정'),
              onTap: () {
                Navigator.pop(context);
                _muteNotifications(chatRoom);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: const Text('신고하기', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(chatRoom);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('채팅방 나가기', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showLeaveDialog(chatRoom);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAsRead(ChatRoom chatRoom) async {
    try {
      // TODO: 실제 API 호출로 교체 필요
      setState(() {
        final index = _allChatRooms.indexWhere((room) => room.id == chatRoom.id);
        if (index != -1) {
          // 임시로 읽음 처리 - 실제 모델에 copyWith가 없으므로 unreadCount를 0으로 설정
          // _allChatRooms[index] = chatRoom.copyWith(unreadCount: 0);
          _filterChatRooms();
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('읽음 처리되었습니다'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('읽음 처리에 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _muteNotifications(ChatRoom chatRoom) async {
    try {
      // TODO: 실제 API 호출로 교체 필요
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('알림 설정이 변경되었습니다'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('설정 변경에 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showReportDialog(ChatRoom chatRoom) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('신고하기'),
        content: const Text('이 채팅방을 신고하시겠습니까?'),
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
      ),
    );
  }

  Future<void> _reportUser(ChatRoom chatRoom) async {
    try {
      // TODO: 실제 API 호출로 교체 필요
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('신고가 접수되었습니다. 검토 후 조치하겠습니다.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('신고 접수에 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLeaveDialog(ChatRoom chatRoom) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('채팅방 나가기'),
        content: const Text('정말로 이 채팅방을 나가시겠습니까?\n나간 후에는 이전 대화 내용을 볼 수 없습니다.'),
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
      ),
    );
  }

  Future<void> _leaveChatRoom(ChatRoom chatRoom) async {
    try {
      await _chatService.leaveChatRoom(chatRoom.id);
      
      setState(() {
        _allChatRooms.removeWhere((room) => room.id == chatRoom.id);
        _filterChatRooms();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('채팅방을 나갔습니다')),
      );
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
  final bool isFreelancer;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _ChatRoomCard({
    required this.chatRoom,
    required this.isFreelancer,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 프로필 이미지
              CircleAvatar(
                radius: 24,
                backgroundImage: chatRoom.getOtherParticipant('current_user_id')?.profileImageUrl != null 
                    ? NetworkImage(chatRoom.getOtherParticipant('current_user_id')!.profileImageUrl!)
                    : null,
                child: chatRoom.getOtherParticipant('current_user_id')?.profileImageUrl == null
                    ? Text(
                        chatRoom.getOtherParticipant('current_user_id')?.name.isNotEmpty == true 
                            ? chatRoom.getOtherParticipant('current_user_id')!.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
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
                            isFreelancer 
                                ? '고객: ${chatRoom.getOtherParticipant('current_user_id')?.name ?? '알 수 없음'}'
                                : '전문가: ${chatRoom.getOtherParticipant('current_user_id')?.name ?? '알 수 없음'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: chatRoom.type.color.withOpacity(0.1),
                            border: Border.all(color: chatRoom.type.color),
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
