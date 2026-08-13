import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatServices {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get currentUserId => _supabase.auth.currentUser?.id;

  List<Map<String, dynamic>>? _cachedRooms;
  final Map<String, Map<String, String>> _participantNamesCache = {};
  final StreamController<List<Map<String, dynamic>>> _roomsStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  RealtimeChannel? _messagesSubscription;

  bool get hasCachedRooms => _cachedRooms != null;

  /// Returns a stream of chat rooms backed by in-memory cache and realtime Postgres changes.
  Stream<List<Map<String, dynamic>>> getRoomsStream() {
    if (_cachedRooms != null) {
      Timer.run(() {
        if (!_roomsStreamController.isClosed && _cachedRooms != null) {
          _roomsStreamController.add(_cachedRooms!);
        }
      });
    } else {
      refreshRooms();
    }

    _subscribeToRealtimeMessages();
    return _roomsStreamController.stream;
  }

  /// Forces a fresh fetch of chat rooms from Supabase and updates cache & stream.
  Future<List<Map<String, dynamic>>> refreshRooms() async {
    final rooms = await getMyChatRooms();
    _cachedRooms = rooms;
    if (!_roomsStreamController.isClosed) {
      _roomsStreamController.add(rooms);
    }
    return rooms;
  }

  void _subscribeToRealtimeMessages() {
    if (_messagesSubscription != null) return;
    try {
      _messagesSubscription = _supabase.channel('public:chat_messages_realtime');
      _messagesSubscription!.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_messages',
        callback: (payload) {
          final record = payload.newRecord;
          if (record.isEmpty) return;
          final roomId = record['room_id'] as String?;
          final msgText = record['message_text'] as String? ?? '';
          final senderId = record['sender_id'] as String?;
          final createdAt = record['created_at']?.toString();

          if (roomId != null && _cachedRooms != null) {
            final myId = currentUserId;
            final prefix = senderId == myId ? 'Saya: ' : '';
            String timeStr = '';
            if (createdAt != null) {
              final dt = DateTime.parse(createdAt).toLocal();
              timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
            }

            final index = _cachedRooms!.indexWhere((r) => r['id'] == roomId);
            if (index != -1) {
              final room = _cachedRooms![index];
              room['lastMessage'] = '$prefix$msgText';
              room['time'] = timeStr;
              _cachedRooms!.removeAt(index);
              _cachedRooms!.insert(0, room);

              if (!_roomsStreamController.isClosed) {
                _roomsStreamController.add(List.from(_cachedRooms!));
              }
            } else {
              refreshRooms();
            }
          }
        },
      ).subscribe();
    } catch (e) {
      debugPrint('ChatServices realtime subscription error: $e');
    }
  }

  /// Fetches all registered profiles from Supabase to start new chats.
  Future<List<Map<String, dynamic>>> getContacts() async {
    try {
      final myId = currentUserId;
      final response = await _supabase
          .from('profiles')
          .select('id, full_name, email, role, nim')
          .order('full_name', ascending: true);

      final List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(response);
      if (myId != null) {
        return list.where((p) => p['id']?.toString() != myId).toList();
      }
      return list;
    } catch (e) {
      debugPrint('ChatServices.getContacts error: $e');
      return [];
    }
  }

  /// Searches registered profiles matching query.
  Future<List<Map<String, dynamic>>> searchContacts(String query) async {
    try {
      final q = query.trim();
      if (q.isEmpty) return [];
      final myId = currentUserId;
      final response = await _supabase
          .from('profiles')
          .select('id, full_name, email, role, nim')
          .or('full_name.ilike.%$q%,email.ilike.%$q%')
          .order('full_name', ascending: true);

      final List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(response);
      if (myId != null) {
        return list.where((p) => p['id']?.toString() != myId).toList();
      }
      return list;
    } catch (e) {
      debugPrint('ChatServices.searchContacts error: $e');
      return [];
    }
  }

  /// Creates a new group chat room with a name and a list of participant user IDs.
  Future<String?> createGroupRoom(String groupName, List<String> participantUserIds) async {
    try {
      final myId = currentUserId;
      if (myId == null) return null;

      final allUserIds = {myId, ...participantUserIds}.toList();

      final newRoomRes = await _supabase
          .from('chat_rooms')
          .insert({
            'type': 'group',
            'name': groupName.trim(),
          })
          .select('id')
          .single();

      final newRoomId = newRoomRes['id'] as String;

      final participantRows = allUserIds.map((userId) => {
        'room_id': newRoomId,
        'user_id': userId,
      }).toList();

      await _supabase.from('chat_participants').insert(participantRows);

      return newRoomId;
    } catch (e) {
      debugPrint('ChatServices.createGroupRoom error: $e');
      return null;
    }
  }

  /// Gets existing direct chat room ID or creates a new one between two users.
  Future<String?> getOrCreateDirectRoom(String targetUserId, String targetName) async {
    try {
      final myId = currentUserId;
      if (myId == null) return null;

      // 1. Find rooms where current user is participant
      final myParticipants = await _supabase
          .from('chat_participants')
          .select('room_id')
          .eq('user_id', myId);

      final myRoomIds = (myParticipants as List).map((p) => p['room_id'] as String).toList();

      if (myRoomIds.isNotEmpty) {
        // 2. Check if target user is also in any of those rooms for 'direct' type
        final sharedParticipants = await _supabase
            .from('chat_participants')
            .select('room_id, chat_rooms(id, type)')
            .eq('user_id', targetUserId)
            .filter('room_id', 'in', myRoomIds);

        for (final item in sharedParticipants) {
          final room = item['chat_rooms'] as Map<String, dynamic>?;
          if (room != null && (room['type'] == 'direct' || room['type'] == null)) {
            final roomId = room['id'] as String;
            // Clean up old hardcoded room name in DB
            _supabase.from('chat_rooms').update({'name': null}).eq('id', roomId);
            return roomId;
          }
        }
      }

      // 3. Room does not exist -> Create new direct room
      final newRoomRes = await _supabase
          .from('chat_rooms')
          .insert({'type': 'direct'})
          .select('id')
          .single();

      final newRoomId = newRoomRes['id'] as String;

      // 4. Add both participants
      await _supabase.from('chat_participants').insert([
        {'room_id': newRoomId, 'user_id': myId},
        {'room_id': newRoomId, 'user_id': targetUserId},
      ]);

      return newRoomId;
    } catch (e) {
      debugPrint('ChatServices.getOrCreateDirectRoom error: $e');
      return null;
    }
  }

  /// Fetches all active chat rooms for the current logged-in user.
  Future<List<Map<String, dynamic>>> getMyChatRooms() async {
    try {
      final myId = currentUserId;
      if (myId == null) return [];

      final participants = await _supabase
          .from('chat_participants')
          .select('room_id, chat_rooms(id, name, type, updated_at)')
          .eq('user_id', myId);

      final List<Map<String, dynamic>> roomsList = [];

      for (final p in participants) {
        final room = p['chat_rooms'] as Map<String, dynamic>?;
        if (room == null) continue;

        final roomId = room['id'] as String;
        final roomType = room['type'] as String? ?? 'direct';

        // Fetch all participants for this room to find the other user
        final allParts = await _supabase
            .from('chat_participants')
            .select('user_id')
            .eq('room_id', roomId);

        String roomDisplayName = room['name'] ?? 'Obrolan';
        String userRoleStr = roomType == 'group' ? 'Grup Kelas' : 'Mahasiswa';
        String targetUserId = '';

        if (roomType == 'direct') {
          roomDisplayName = 'Obrolan';
          final otherPartList = (allParts as List).where((part) => part['user_id']?.toString() != myId).toList();

          if (otherPartList.isNotEmpty) {
            final otherUserId = otherPartList.first['user_id'] as String;
            targetUserId = otherUserId;

            // Fetch profile directly for the other participant
            final profRes = await _supabase
                .from('profiles')
                .select('id, full_name, email, role')
                .eq('id', otherUserId)
                .maybeSingle();

            if (profRes != null) {
              final fullName = profRes['full_name'] as String?;
              if (fullName != null && fullName.trim().isNotEmpty) {
                roomDisplayName = fullName.trim();
              }
              final role = profRes['role'] as String?;
              userRoleStr = role == 'teacher'
                  ? 'Dosen'
                  : (role == 'admin' ? 'Admin' : 'Mahasiswa');
            }
          }
        } else {
          // For group chats, keep room['name']
          roomDisplayName = room['name'] ?? 'Grup Kelas';
          userRoleStr = 'Grup Kelas';
        }

        // Fetch last message
        final lastMsgRes = await _supabase
            .from('chat_messages')
            .select('message_text, created_at, sender_id')
            .eq('room_id', roomId)
            .order('created_at', ascending: false)
            .limit(1);

        String lastMsgText = 'Belum ada pesan';
        String timeStr = '';
        if ((lastMsgRes as List).isNotEmpty) {
          final msgData = lastMsgRes.first;
          final senderId = msgData['sender_id'] as String?;
          final prefix = senderId == myId ? 'Saya: ' : '';
          lastMsgText = '$prefix${msgData['message_text'] ?? ''}';

          if (msgData['created_at'] != null) {
            final dt = DateTime.parse(msgData['created_at'].toString()).toLocal();
            timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
          }
        }

        roomsList.add({
          'id': roomId,
          'targetUserId': targetUserId,
          'name': roomDisplayName,
          'type': userRoleStr,
          'isGroup': roomType == 'group' || userRoleStr == 'Grup Kelas',
          'participantCount': (allParts as List).length,
          'lastMessage': lastMsgText,
          'time': timeStr,
          'unreadCount': 0,
          'isOnline': true,
          'avatarColor': roomType == 'group' ? 0xFF059669 : 0xFF2563EB,
        });
      }

      return roomsList;
    } catch (e) {
      debugPrint('ChatServices.getMyChatRooms error: $e');
      return [];
    }
  }

  /// Fetches participant user names for a room with in-memory caching.
  Future<Map<String, String>> getRoomParticipantNames(String roomId) async {
    if (_participantNamesCache.containsKey(roomId)) {
      return _participantNamesCache[roomId]!;
    }
    try {
      final response = await _supabase
          .from('chat_participants')
          .select('user_id, profiles(id, full_name)')
          .eq('room_id', roomId);

      final Map<String, String> namesMap = {};
      for (final p in (response as List)) {
        final profile = p['profiles'] as Map<String, dynamic>?;
        if (profile != null) {
          final userId = profile['id'] as String? ?? p['user_id'] as String;
          final fullName = profile['full_name'] as String? ?? 'Pengguna';
          namesMap[userId] = fullName;
        }
      }
      _participantNamesCache[roomId] = namesMap;
      return namesMap;
    } catch (e) {
      debugPrint('ChatServices.getRoomParticipantNames error: $e');
      return {};
    }
  }

  /// Stream of real-time messages for a room.
  Stream<List<Map<String, dynamic>>> getMessagesStream(String roomId) {
    try {
      return _supabase
          .from('chat_messages')
          .stream(primaryKey: ['id'])
          .eq('room_id', roomId)
          .order('created_at', ascending: true)
          .map((list) {
            final myId = currentUserId;
            return list.map((msg) {
              final senderId = msg['sender_id'] as String? ?? '';
              final isMe = senderId == myId;
              final dt = msg['created_at'] != null
                  ? DateTime.parse(msg['created_at'].toString()).toLocal()
                  : DateTime.now();
              final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

              return {
                'id': msg['id'],
                'senderId': senderId,
                'sender': isMe ? 'Saya' : 'Lawan Bicara',
                'text': msg['message_text'] ?? '',
                'time': timeStr,
                'isMe': isMe,
              };
            }).toList();
          });
    } catch (e) {
      debugPrint('ChatServices.getMessagesStream error: $e');
      return const Stream.empty();
    }
  }

  /// Sends a new message to Supabase.
  Future<bool> sendMessage(String roomId, String text, {String? attachmentUrl}) async {
    try {
      final myId = currentUserId;
      if (myId == null) return false;

      await _supabase.from('chat_messages').insert({
        'room_id': roomId,
        'sender_id': myId,
        'message_text': text,
        if (attachmentUrl != null) 'attachment_url': attachmentUrl,
      });

      await _supabase.from('chat_rooms').update({
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', roomId);

      return true;
    } catch (e) {
      debugPrint('ChatServices.sendMessage error: $e');
      return false;
    }
  }
}
