import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/chat.dart';
import 'api_service.dart';
import '../providers/auth_provider.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final ApiService _api = apiService;
  AuthProvider? _authProvider;
  
  // AuthProvider 설정
  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
  }
  
  // WebSocket connection for real-time messaging
  StreamController<ChatMessage>? _messageStreamController;
  StreamController<ChatRoom>? _chatRoomStreamController;

  // 채팅방 생성
  Future<Map<String, dynamic>> createChatRoom(ChatRoomCreateRequest request) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // TODO: 실제 API 호출
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/rooms'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': '채팅방이 생성되었습니다.',
          'chat_room': ChatRoom.fromJson(data),
        };
      } else {
        return {
          'success': false,
          'message': '채팅방 생성에 실패했습니다.',
        };
      }
      */
      
      // Mock 응답
      final now = DateTime.now();
      final mockChatRoom = ChatRoom(
        id: 'chatroom_${now.millisecondsSinceEpoch}',
        name: request.name,
        type: request.type,
        status: ChatRoomStatus.active,
        participantIds: request.participantIds,
        participants: request.participantIds.map((id) => ChatParticipant(
          userId: id,
          name: '사용자$id',
          role: id == 'current_user' ? 'customer' : 'freelancer',
          joinedAt: now,
          isOnline: true,
        )).toList(),
        requestId: request.requestId,
        contractId: request.contractId,
        matchingId: request.matchingId,
        unreadCount: 0,
        createdAt: now,
        updatedAt: now,
        lastActivityAt: now,
        metadata: request.metadata,
      );
      
      return {
        'success': true,
        'message': '채팅방이 생성되었습니다.',
        'chat_room': mockChatRoom,
      };
    } catch (e) {
      return {
        'success': false,
        'message': '채팅방 생성 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 내 채팅방 목록 조회
  Future<List<ChatRoom>> getChatRooms({
    ChatRoomType? type,
    int? limit,
    int? offset,
  }) async {
    try {
      // AuthProvider에서 현재 사용자 정보 가져오기
      String? currentUserId;
      if (_authProvider != null && _authProvider!.currentUser != null) {
        currentUserId = _authProvider!.currentUser!.id;
      } else {
        // Fallback: Supabase auth 사용
        currentUserId = _api.auth.currentUser?.id;
      }
      
      if (currentUserId == null) {
        throw Exception('로그인이 필요합니다');
      }
      
      final response = await _api.from('chat_rooms')
          .select('*')
          .contains('participants', [currentUserId])
          .order('updated_at', ascending: false)
          .limit(limit ?? 20);
      
      if ((response as List<dynamic>).isNotEmpty) {
        return (response as List<dynamic>)
            .map((item) => ChatRoom.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        // 비어있는 결과인 경우 빈 리스트 반환
        return <ChatRoom>[];
      }
    } catch (e) {
      print('채팅방 목록 조회 오류: $e');
      // 오류 시 목업 데이터 반환
      return _generateMockChatRooms(type: type);
    }
  }

  // 채팅방 상세 조회
  Future<ChatRoom> getChatRoom(String chatRoomId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // TODO: 실제 API 호출
    /*
    final response = await http.get(
      Uri.parse('$_baseUrl/chat/rooms/$chatRoomId'),
      headers: {
        'Authorization': 'Bearer ${await _getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ChatRoom.fromJson(data);
    } else {
      throw Exception('채팅방 조회에 실패했습니다.');
    }
    */
    
    // Mock 데이터
    final firstRoom = _generateMockChatRooms().first;
    return ChatRoom(
      id: chatRoomId,
      name: firstRoom.name,
      type: firstRoom.type,
      status: firstRoom.status,
      participantIds: firstRoom.participantIds,
      participants: firstRoom.participants,
      requestId: firstRoom.requestId,
      contractId: firstRoom.contractId,
      matchingId: firstRoom.matchingId,
      lastMessage: firstRoom.lastMessage,
      unreadCount: firstRoom.unreadCount,
      createdAt: firstRoom.createdAt,
      updatedAt: firstRoom.updatedAt,
      lastActivityAt: firstRoom.lastActivityAt,
      metadata: firstRoom.metadata,
    );
  }

  // 채팅 메시지 목록 조회
  Future<List<ChatMessage>> getMessages(
    String chatRoomId, {
    int? limit,
    String? beforeMessageId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    // TODO: 실제 API 호출
    /*
    final queryParams = <String, String>{
      if (limit != null) 'limit': limit.toString(),
      if (beforeMessageId != null) 'before': beforeMessageId,
    };
    
    final uri = Uri.parse('$_baseUrl/chat/rooms/$chatRoomId/messages')
        .replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${await _getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => ChatMessage.fromJson(item)).toList();
    } else {
      throw Exception('메시지 목록 조회에 실패했습니다.');
    }
    */
    
    // Mock 데이터
    return _generateMockMessages(chatRoomId, limit ?? 20);
  }

  // 메시지 전송
  Future<Map<String, dynamic>> sendMessage(ChatMessageSendRequest request) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // TODO: 실제 API 호출
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final message = ChatMessage.fromJson(data);
        
        // 실시간 스트림에 메시지 추가
        _messageStreamController?.add(message);
        
        return {
          'success': true,
          'message_id': message.id,
          'message': message,
        };
      } else {
        return {
          'success': false,
          'message': '메시지 전송에 실패했습니다.',
        };
      }
      */
      
      // Mock 응답
      final now = DateTime.now();
      final message = ChatMessage(
        id: 'msg_${now.millisecondsSinceEpoch}',
        chatRoomId: request.chatRoomId,
        senderId: 'current_user',
        senderName: '나',
        type: request.type,
        content: request.content,
        fileUrl: request.fileUrl,
        fileName: request.fileName,
        fileSize: request.fileSize,
        status: MessageStatus.sent,
        createdAt: now,
        replyToMessageId: request.replyToMessageId,
        metadata: request.metadata,
      );
      
      // 실시간 스트림에 메시지 추가
      _messageStreamController?.add(message);
      
      return {
        'success': true,
        'message_id': message.id,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': '메시지 전송 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 파일 업로드
  Future<Map<String, dynamic>> uploadFile(File file, String chatRoomId) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: 실제 파일 업로드 구현
      /*
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/chat/upload'),
      );
      
      request.headers['Authorization'] = 'Bearer ${await _getAccessToken()}';
      request.fields['chat_room_id'] = chatRoomId;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return {
          'success': true,
          'file_url': data['file_url'],
          'thumbnail_url': data['thumbnail_url'],
        };
      } else {
        return {
          'success': false,
          'message': '파일 업로드에 실패했습니다.',
        };
      }
      */
      
      // Mock 업로드
      final fileName = file.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      final isImage = ['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension);
      
      return {
        'success': true,
        'file_url': 'https://mock.caresurflink.com/files/${DateTime.now().millisecondsSinceEpoch}_$fileName',
        'thumbnail_url': isImage 
            ? 'https://mock.caresurflink.com/thumbnails/${DateTime.now().millisecondsSinceEpoch}_$fileName'
            : null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': '파일 업로드 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 메시지 읽음 처리
  Future<Map<String, dynamic>> markMessagesAsRead(
    String chatRoomId, {
    String? messageId,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      // TODO: 실제 API 호출
      /*
      final response = await http.put(
        Uri.parse('$_baseUrl/chat/rooms/$chatRoomId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
        body: json.encode({
          'message_id': messageId,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': '메시지를 읽음 처리했습니다.',
        };
      } else {
        return {
          'success': false,
          'message': '읽음 처리에 실패했습니다.',
        };
      }
      */
      
      return {
        'success': true,
        'message': '메시지를 읽음 처리했습니다.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '읽음 처리 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 채팅방 나가기
  Future<Map<String, dynamic>> leaveChatRoom(String chatRoomId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // TODO: 실제 API 호출
      /*
      final response = await http.delete(
        Uri.parse('$_baseUrl/chat/rooms/$chatRoomId/leave'),
        headers: {
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': '채팅방을 나갔습니다.',
        };
      } else {
        return {
          'success': false,
          'message': '채팅방 나가기에 실패했습니다.',
        };
      }
      */
      
      return {
        'success': true,
        'message': '채팅방을 나갔습니다.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '채팅방 나가기 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 사용자 신고
  Future<Map<String, dynamic>> reportUser(
    String chatRoomId,
    String userId,
    String reason,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      // TODO: 실제 API 호출
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/report'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
        body: json.encode({
          'chat_room_id': chatRoomId,
          'user_id': userId,
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': '신고가 접수되었습니다.',
        };
      } else {
        return {
          'success': false,
          'message': '신고 접수에 실패했습니다.',
        };
      }
      */
      
      return {
        'success': true,
        'message': '신고가 접수되었습니다. 검토 후 조치하겠습니다.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '신고 접수 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 실시간 메시지 스트림
  Stream<ChatMessage> getMessageStream(String chatRoomId) {
    _messageStreamController ??= StreamController<ChatMessage>.broadcast();
    
    // TODO: WebSocket 연결 구현
    /*
    // WebSocket 연결
    final websocket = WebSocket.connect('ws://api.caresurflink.com/chat/$chatRoomId');
    websocket.then((ws) {
      ws.listen((data) {
        final messageData = json.decode(data);
        final message = ChatMessage.fromJson(messageData);
        _messageStreamController?.add(message);
      });
    });
    */
    
    return _messageStreamController!.stream
        .where((message) => message.chatRoomId == chatRoomId);
  }

  // 실시간 채팅방 업데이트 스트림
  Stream<ChatRoom> getChatRoomStream() {
    _chatRoomStreamController ??= StreamController<ChatRoom>.broadcast();
    
    // TODO: WebSocket 연결 구현
    
    return _chatRoomStreamController!.stream;
  }

  // 연결 해제
  void dispose() {
    _messageStreamController?.close();
    _chatRoomStreamController?.close();
  }

  // Mock 데이터 생성 메서드들
  List<ChatRoom> _generateMockChatRooms({ChatRoomType? type}) {
    final rooms = <ChatRoom>[];
    final now = DateTime.now();
    final types = ChatRoomType.values;
    
    for (int i = 0; i < 10; i++) {
      final roomType = types[i % types.length];
      if (type != null && roomType != type) continue;
      
      final participants = [
        ChatParticipant(
          userId: 'current_user',
          name: '나',
          role: i % 2 == 0 ? 'customer' : 'freelancer',
          joinedAt: now.subtract(Duration(days: i)),
          isOnline: i < 5,
          lastSeenAt: i >= 5 ? now.subtract(Duration(minutes: i * 10)) : null,
        ),
        ChatParticipant(
          userId: 'user_$i',
          name: '${roomType == ChatRoomType.matching ? (i % 2 == 0 ? '박프리랜서' : '김고객') : '상담원'}$i',
          role: i % 2 == 0 ? 'freelancer' : 'customer',
          joinedAt: now.subtract(Duration(days: i)),
          isOnline: i < 3,
          lastSeenAt: i >= 3 ? now.subtract(Duration(hours: i)) : null,
        ),
      ];
      
      final lastMessage = ChatMessage(
        id: 'msg_last_$i',
        chatRoomId: 'room_$i',
        senderId: i % 2 == 0 ? 'current_user' : 'user_$i',
        senderName: i % 2 == 0 ? '나' : participants[1].name,
        type: i % 4 == 0 ? MessageType.image : MessageType.text,
        content: _getLastMessageContent(i),
        status: MessageStatus.read,
        createdAt: now.subtract(Duration(minutes: i * 15)),
      );
      
      rooms.add(ChatRoom(
        id: 'room_$i',
        name: _getChatRoomName(roomType, i),
        type: roomType,
        status: i == 7 ? ChatRoomStatus.completed : ChatRoomStatus.active,
        participantIds: participants.map((p) => p.userId).toList(),
        participants: participants,
        requestId: roomType == ChatRoomType.matching ? 'request_$i' : null,
        contractId: roomType == ChatRoomType.contract ? 'contract_$i' : null,
        matchingId: roomType == ChatRoomType.matching ? 'matching_$i' : null,
        lastMessage: lastMessage,
        unreadCount: i % 3,
        createdAt: now.subtract(Duration(days: i)),
        updatedAt: now.subtract(Duration(minutes: i * 15)),
        lastActivityAt: now.subtract(Duration(minutes: i * 15)),
      ));
    }
    
    return rooms;
  }

  List<ChatMessage> _generateMockMessages(String chatRoomId, int count) {
    final messages = <ChatMessage>[];
    final now = DateTime.now();
    
    for (int i = 0; i < count; i++) {
      final isMyMessage = i % 3 != 0;
      final messageType = _getMessageType(i);
      
      messages.add(ChatMessage(
        id: 'msg_${chatRoomId}_$i',
        chatRoomId: chatRoomId,
        senderId: isMyMessage ? 'current_user' : 'other_user',
        senderName: isMyMessage ? '나' : '상대방',
        type: messageType,
        content: _getMessageContent(messageType, i),
        fileUrl: messageType != MessageType.text 
            ? 'https://mock.caresurflink.com/files/file_$i.jpg'
            : null,
        fileName: messageType == MessageType.file ? 'document_$i.pdf' : null,
        fileSize: messageType == MessageType.file ? 1024 * (i + 1) : null,
        thumbnailUrl: messageType == MessageType.image
            ? 'https://mock.caresurflink.com/thumbnails/thumb_$i.jpg'
            : null,
        status: isMyMessage ? MessageStatus.read : MessageStatus.delivered,
        createdAt: now.subtract(Duration(minutes: i * 2)),
        readAt: MessageStatus.read == (isMyMessage ? MessageStatus.read : MessageStatus.delivered)
            ? now.subtract(Duration(minutes: i * 2 - 1))
            : null,
      ));
    }
    
    return messages.reversed.toList();
  }

  String _getChatRoomName(ChatRoomType type, int index) {
    switch (type) {
      case ChatRoomType.matching:
        return '${index % 2 == 0 ? '박프리랜서' : '김고객'}$index님과의 채팅';
      case ChatRoomType.contract:
        return '계약 관련 채팅 #$index';
      case ChatRoomType.support:
        return '고객 지원';
    }
  }

  String _getLastMessageContent(int index) {
    final contents = [
      '안녕하세요! 언제 시작할 수 있을까요?',
      '📷 이미지',
      '네, 내일부터 가능합니다.',
      '자세한 내용은 전화로 상담드릴게요.',
      '📁 계약서.pdf',
      '감사합니다. 잘 부탁드려요.',
      '궁금한 점이 있으면 언제든 연락주세요.',
      '오늘 서비스 어떠셨나요?',
      '다음에도 잘 부탁드립니다.',
      '리뷰 남겨주시면 감사하겠습니다.',
    ];
    return contents[index % contents.length];
  }

  MessageType _getMessageType(int index) {
    if (index % 10 == 0) return MessageType.image;
    if (index % 7 == 0) return MessageType.file;
    if (index % 15 == 0) return MessageType.system;
    return MessageType.text;
  }

  String _getMessageContent(MessageType type, int index) {
    switch (type) {
      case MessageType.text:
        final texts = [
          '안녕하세요!',
          '언제 시작하면 될까요?',
          '네, 알겠습니다.',
          '감사합니다.',
          '내일 오전 10시는 어떠세요?',
          '좋습니다. 확인해보겠습니다.',
          '질문이 있는데요...',
          '잘 부탁드려요.',
          '오늘 고생하셨습니다.',
          '다음에도 연락드릴게요.',
        ];
        return texts[index % texts.length];
      case MessageType.image:
        return '이미지를 보냈습니다.';
      case MessageType.file:
        return '파일을 보냈습니다.';
      case MessageType.system:
        return '채팅방에 입장하셨습니다.';
    }
  }

  // 채팅방 업데이트 스트림
  Stream<ChatRoom> getChatRoomUpdatesStream() {
    _chatRoomStreamController ??= StreamController<ChatRoom>.broadcast();
    
    // Mock 데이터로 시뮤레이션
    Timer.periodic(const Duration(seconds: 10), (timer) {
      // 실제로는 WebSocket이나 Server-Sent Events를 사용
      // 여기서는 mock 데이터를 전송
    });
    
    return _chatRoomStreamController!.stream;
  }
  
  Future<String?> _getAccessToken() async {
    // TODO: 실제 토큰 관리 로직
    return 'mock_access_token';
  }
}
