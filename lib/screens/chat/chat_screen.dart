import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../models/chat.dart';
import '../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatScreen({
    super.key,
    required this.chatRoom,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isSending = false;
  bool _hasMoreMessages = true;
  
  ChatParticipant? _otherParticipant;

  @override
  void initState() {
    super.initState();
    _otherParticipant = widget.chatRoom.getOtherParticipant('current_user');
    _loadMessages();
    _listenToNewMessages();
    _markMessagesAsRead();
    
    // 스크롤 감지로 추가 메시지 로딩
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() async {
    if (_isLoadingMore) return;
    
    setState(() {
      if (_messages.isEmpty) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final messages = await _chatService.getMessages(
        widget.chatRoom.id,
        limit: 20,
        beforeMessageId: _messages.isNotEmpty ? _messages.first.id : null,
      );

      setState(() {
        if (_messages.isEmpty) {
          _messages = messages;
        } else {
          _messages = [...messages, ..._messages];
        }
        _hasMoreMessages = messages.length == 20;
        _isLoading = false;
        _isLoadingMore = false;
      });

      // 첫 로딩 시 맨 아래로 스크롤
      if (!_isLoadingMore && messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('메시지 로딩 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _listenToNewMessages() {
    _chatService.getMessageStream(widget.chatRoom.id).listen((message) {
      setState(() {
        _messages.add(message);
      });
      
      // 새 메시지가 오면 맨 아래로 스크롤
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
      
      // 상대방 메시지면 읽음 처리
      if (message.senderId != 'current_user') {
        _markMessagesAsRead();
      }
    });
  }

  void _markMessagesAsRead() async {
    try {
      await _chatService.markMessagesAsRead(widget.chatRoom.id);
    } catch (e) {
      // 조용히 실패 처리
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      if (_hasMoreMessages && !_isLoadingMore) {
        _loadMessages();
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: _otherParticipant?.profileImageUrl != null
                  ? NetworkImage(_otherParticipant!.profileImageUrl!)
                  : null,
              child: _otherParticipant?.profileImageUrl == null
                  ? Text(
                      _otherParticipant?.name.substring(0, 1) ?? '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _otherParticipant?.name ?? '채팅상대',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _getOnlineStatusText(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () => _showCallOptions(),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showChatOptions(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 채팅방 상태 표시
          if (widget.chatRoom.status != ChatRoomStatus.active)
            _buildStatusBar(),
          
          // 메시지 목록
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMessageList(),
          ),
          
          // 메시지 입력
          if (widget.chatRoom.isActive)
            _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    String statusText;
    Color statusColor;

    switch (widget.chatRoom.status) {
      case ChatRoomStatus.completed:
        statusText = '완료된 채팅방입니다';
        statusColor = Colors.blue;
        break;
      case ChatRoomStatus.reported:
        statusText = '신고된 채팅방입니다';
        statusColor = Colors.orange;
        break;
      case ChatRoomStatus.blocked:
        statusText = '차단된 채팅방입니다';
        statusColor = Colors.red;
        break;
      default:
        return Container();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: statusColor.withOpacity(0.1),
      child: Text(
        statusText,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_hasMoreMessages && _isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // 로딩 인디케이터
        if (index == _messages.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final message = _messages[_messages.length - 1 - index];
        final previousMessage = index < _messages.length - 1 
            ? _messages[_messages.length - 2 - index] 
            : null;
        
        // 날짜 구분선
        final showDateSeparator = previousMessage == null ||
            !_isSameDay(message.createdAt, previousMessage.createdAt);

        return Column(
          children: [
            if (showDateSeparator)
              _buildDateSeparator(message.createdAt),
            _MessageBubble(
              message: message,
              isMe: message.senderId == 'current_user',
              showAvatar: _shouldShowAvatar(message, index),
              showTime: _shouldShowTime(message, index),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    String dateText;
    if (difference == 0) {
      dateText = '오늘';
    } else if (difference == 1) {
      dateText = '어제';
    } else if (difference < 7) {
      dateText = DateFormat('E요일', 'ko_KR').format(date);
    } else {
      dateText = DateFormat('M월 d일', 'ko_KR').format(date);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              dateText,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _isSending ? null : _showAttachmentOptions,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: '메시지를 입력하세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: _isSending 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            onPressed: _isSending || _messageController.text.trim().isEmpty 
                ? null 
                : _sendMessage,
          ),
        ],
      ),
    );
  }

  bool _shouldShowAvatar(ChatMessage message, int index) {
    if (message.senderId == 'current_user') return false;
    
    // 다음 메시지가 다른 사람이거나 없으면 아바타 표시
    if (index == 0) return true;
    
    final nextMessage = _messages[_messages.length - index];
    return nextMessage.senderId != message.senderId;
  }

  bool _shouldShowTime(ChatMessage message, int index) {
    if (index == 0) return true;
    
    final nextMessage = _messages[_messages.length - index];
    
    // 다른 사람 메시지이거나 5분 이상 차이나면 시간 표시
    return nextMessage.senderId != message.senderId ||
        nextMessage.createdAt.difference(message.createdAt).inMinutes >= 5;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getOnlineStatusText() {
    if (_otherParticipant?.isOnline == true) {
      return '온라인';
    } else if (_otherParticipant?.lastSeenAt != null) {
      final lastSeen = _otherParticipant!.lastSeenAt!;
      final difference = DateTime.now().difference(lastSeen);
      
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
    return '';
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final request = ChatMessageSendRequest(
        chatRoomId: widget.chatRoom.id,
        type: MessageType.text,
        content: content,
      );

      final result = await _chatService.sendMessage(request);

      if (result['success']) {
        _messageController.clear();
        
        // 메시지 전송 성공 시 스크롤
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('메시지 전송 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('사진'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile(FileType.image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text('파일'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile(FileType.any);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickFile(FileType fileType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: fileType == FileType.custom 
            ? ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png']
            : null,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        await _uploadAndSendFile(file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('파일 선택 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadAndSendFile(File file) async {
    setState(() {
      _isSending = true;
    });

    try {
      // 파일 업로드
      final uploadResult = await _chatService.uploadFile(file, widget.chatRoom.id);
      
      if (!uploadResult['success']) {
        throw Exception(uploadResult['message']);
      }

      final fileName = file.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      final isImage = ['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension);

      // 메시지 전송
      final request = ChatMessageSendRequest(
        chatRoomId: widget.chatRoom.id,
        type: isImage ? MessageType.image : MessageType.file,
        content: isImage ? '이미지를 보냈습니다.' : '파일을 보냈습니다.',
        fileUrl: uploadResult['file_url'],
        fileName: fileName,
        fileSize: await file.length(),
      );

      final sendResult = await _chatService.sendMessage(request);

      if (!sendResult['success']) {
        throw Exception(sendResult['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('파일 전송 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _showCallOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.call),
                title: const Text('음성 통화'),
                onTap: () {
                  Navigator.pop(context);
                  _makeCall(false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('영상 통화'),
                onTap: () {
                  Navigator.pop(context);
                  _makeCall(true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _makeCall(bool isVideo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${isVideo ? '영상' : '음성'} 통화 기능은 준비 중입니다'),
      ),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('메시지 검색'),
                onTap: () {
                  Navigator.pop(context);
                  _showSearchMessages();
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_off),
                title: const Text('알림 끄기'),
                onTap: () {
                  Navigator.pop(context);
                  _toggleNotifications();
                },
              ),
              if (widget.chatRoom.type != ChatRoomType.support)
                ListTile(
                  leading: const Icon(Icons.report, color: Colors.red),
                  title: const Text('신고하기'),
                  onTap: () {
                    Navigator.pop(context);
                    _showReportDialog();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showSearchMessages() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('메시지 검색 기능은 준비 중입니다')),
    );
  }

  void _toggleNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.chatRoom.name} 알림이 꺼졌습니다'),
        action: SnackBarAction(
          label: '실행취소',
          onPressed: () {},
        ),
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('사용자 신고'),
          content: Text('${_otherParticipant?.name ?? '상대방'}님을 신고하시겠습니까?\n\n부적절한 행동이나 발언을 신고해주세요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _reportUser();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('신고'),
            ),
          ],
        );
      },
    );
  }

  void _reportUser() async {
    try {
      final result = await _chatService.reportUser(
        widget.chatRoom.id,
        _otherParticipant?.userId ?? '',
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
          content: Text('신고 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showAvatar;
  final bool showTime;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.showTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            // 상대방 아바타
            SizedBox(
              width: 32,
              child: showAvatar
                  ? CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        message.senderName?.substring(0, 1) ?? '?',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          
          // 메시지 콘텐츠
          Flexible(
            child: Column(
              crossAxisAlignment: isMe 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                if (!isMe && showAvatar)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.senderName ?? '알 수 없음',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue[600] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: _buildMessageContent(),
                ),
                
                if (showTime)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(message.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.status.icon,
                            size: 12,
                            color: message.status.color,
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          if (isMe) const SizedBox(width: 40), // 여백 for 균형
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        );
      
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                message.thumbnailUrl ?? message.fileUrl ?? '',
                width: 200,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 50),
                  );
                },
              ),
            ),
            if (message.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      
      case MessageType.file:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attach_file,
              color: isMe ? Colors.white : Colors.blue[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.fileName ?? '파일',
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (message.fileSize != null)
                    Text(
                      _formatFileSize(message.fileSize!),
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      
      case MessageType.system:
        return Text(
          message.content,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
}
