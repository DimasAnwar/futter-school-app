import 'package:flutter/material.dart';

class ObrolanPage extends StatefulWidget {
  const ObrolanPage({
    super.key,
    required this.currentUserRole,
    required this.currentUserName,
  });

  final String currentUserRole;
  final String currentUserName;

  @override
  State<ObrolanPage> createState() => _ObrolanPageState();
}

class _ObrolanPageState extends State<ObrolanPage> {
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  final List<Map<String, dynamic>> _chats = [
    {
      'id': 'c1',
      'name': 'Grup Dosen Pemrograman Mobile',
      'type': 'Grup Kelas',
      'lastMessage': 'Pak Budi: Jadwal asistensi praktikum disepakati hari Kamis ya.',
      'time': '10:45',
      'unreadCount': 2,
      'isOnline': true,
      'avatarColor': 0xFF2563EB,
      'messages': [
        {'sender': 'Pak Budi', 'text': 'Halo rekan-rekan dosen, bagaimana progres modul 4?', 'time': '10:30', 'isMe': false},
        {'sender': 'Saya', 'text': 'Modul 4 sudah selesai disusun pak.', 'time': '10:35', 'isMe': true},
        {'sender': 'Pak Budi', 'text': 'Jadwal asistensi praktikum disepakati hari Kamis ya.', 'time': '10:45', 'isMe': false},
      ],
    },
    {
      'id': 'c2',
      'name': 'Ahmad Rizky (Siswa)',
      'type': 'Mahasiswa',
      'lastMessage': 'Selamat siang Pak, izin bertanya mengenai tugas 2...',
      'time': '09:12',
      'unreadCount': 1,
      'isOnline': true,
      'avatarColor': 0xFF10B981,
      'messages': [
        {'sender': 'Ahmad Rizky', 'text': 'Selamat siang Pak, izin bertanya mengenai tugas 2...', 'time': '09:12', 'isMe': false},
      ],
    },
    {
      'id': 'c3',
      'name': 'Siti Rahma (Siswa)',
      'type': 'Mahasiswa',
      'lastMessage': 'Terima kasih atas penjelasan materi hari ini Pak!',
      'time': 'Kemarin',
      'unreadCount': 0,
      'isOnline': false,
      'avatarColor': 0xFF8B5CF6,
      'messages': [
        {'sender': 'Siti Rahma', 'text': 'Pak, apakah file slide pert 3 sudah diunggah?', 'time': 'Kemarin 14:00', 'isMe': false},
        {'sender': 'Saya', 'text': 'Sudah diunggah di tab Akademik ya Siti.', 'time': 'Kemarin 14:05', 'isMe': true},
        {'sender': 'Siti Rahma', 'text': 'Terima kasih atas penjelasan materi hari ini Pak!', 'time': 'Kemarin 14:10', 'isMe': false},
      ],
    },
    {
      'id': 'c4',
      'name': 'Dr. Hendra Wijaya (Kaprodi)',
      'type': 'Dosen',
      'lastMessage': 'Rapat koordinasi perkuliahan semester ganjil dimulai pukul 13:00.',
      'time': 'Kemarin',
      'unreadCount': 0,
      'isOnline': false,
      'avatarColor': 0xFFF59E0B,
      'messages': [
        {'sender': 'Dr. Hendra Wijaya', 'text': 'Rapat koordinasi perkuliahan semester ganjil dimulai pukul 13:00.', 'time': 'Kemarin 11:20', 'isMe': false},
      ],
    },
    {
      'id': 'c5',
      'name': 'Tim Layanan Akademik',
      'type': 'Dosen',
      'lastMessage': 'Batas penginputan nilai akhir mahasiswa sampai tanggal 20.',
      'time': '10 Agt',
      'unreadCount': 0,
      'isOnline': true,
      'avatarColor': 0xFFEC4899,
      'messages': [
        {'sender': 'Tim Layanan Akademik', 'text': 'Batas penginputan nilai akhir mahasiswa sampai tanggal 20.', 'time': '10 Agt 08:00', 'isMe': false},
      ],
    },
  ];

  List<Map<String, dynamic>> get _filteredChats {
    return _chats.where((chat) {
      final matchesSearch = (chat['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (chat['lastMessage'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      if (_selectedFilter == 'Semua') return matchesSearch;
      return matchesSearch && (chat['type'] == _selectedFilter);
    }).toList();
  }

  void _openChatRoom(Map<String, dynamic> chat) {
    setState(() {
      chat['unreadCount'] = 0;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ChatRoomPage(
          chat: chat,
          currentUserName: widget.currentUserName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final searchFill = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Icon(Icons.chat_bubble_rounded, color: Color(0xFF2563EB), size: 24),
            const SizedBox(width: 10),
            Text(
              'Obrolan & Diskusi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_rounded, color: Color(0xFF2563EB)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Pesan Baru telah aktif.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Box
          Container(
            color: cardBg,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(color: textColor, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Cari percakapan atau kontak...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    filled: true,
                    fillColor: searchFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: isDark ? const BorderSide(color: Color(0xFF334155)) : BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Semua', 'Grup Kelas', 'Mahasiswa', 'Dosen'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF2563EB),
                          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          onSelected: (_) => setState(() => _selectedFilter = filter),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Chat List
          Expanded(
            child: _filteredChats.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada obrolan ditemukan.',
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredChats.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: dividerColor),
                    itemBuilder: (context, index) {
                      final chat = _filteredChats[index];
                      final name = chat['name'] as String;
                      final lastMessage = chat['lastMessage'] as String;
                      final time = chat['time'] as String;
                      final unreadCount = chat['unreadCount'] as int;
                      final isOnline = chat['isOnline'] as bool;
                      final colorVal = chat['avatarColor'] as int;

                      return InkWell(
                        onTap: () => _openChatRoom(chat),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Color(colorVal),
                                    child: Text(
                                      name.isEmpty ? 'C' : name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (isOnline)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.white, width: 2),
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
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          time,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: unreadCount > 0
                                                ? const Color(0xFF3B82F6)
                                                : const Color(0xFF94A3B8),
                                            fontWeight: unreadCount > 0
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            lastMessage,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: unreadCount > 0
                                                  ? textColor
                                                  : subTextColor,
                                              fontWeight: unreadCount > 0
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (unreadCount > 0)
                                          Container(
                                            margin: const EdgeInsets.only(left: 6),
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF2563EB),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '$unreadCount',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChatRoomPage extends StatefulWidget {
  const _ChatRoomPage({
    required this.chat,
    required this.currentUserName,
  });

  final Map<String, dynamic> chat;
  final String currentUserName;

  @override
  State<_ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<_ChatRoomPage> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List<Map<String, dynamic>>.from(widget.chat['messages'] as List);
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add({
        'sender': 'Saya',
        'text': text,
        'time': timeStr,
        'isMe': true,
      });
      widget.chat['lastMessage'] = 'Saya: $text';
      widget.chat['time'] = timeStr;
    });

    _msgController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final appBarBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final incomingBubbleBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final incomingBubbleText = isDark ? Colors.white : const Color(0xFF0F172A);
    final inputBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final fieldFill = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    final name = widget.chat['name'] as String;
    final isOnline = widget.chat['isOnline'] as bool;
    final colorVal = widget.chat['avatarColor'] as int;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Color(colorVal),
              child: Text(
                name.isEmpty ? 'C' : name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 11,
                      color: isOnline ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] as bool;
                final text = msg['text'] as String;
                final time = msg['time'] as String;
                final sender = msg['sender'] as String;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF2563EB) : incomingBubbleBg,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(2),
                        bottomRight: isMe ? const Radius.circular(2) : const Radius.circular(16),
                      ),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Text(
                            sender,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        if (!isMe) const SizedBox(height: 2),
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: 13,
                            color: isMe ? Colors.white : incomingBubbleText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe ? Colors.white70 : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Input Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: inputBg,
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file_rounded, color: Color(0xFF94A3B8)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur kirim lampiran dokumen siap digunakan.')),
                      );
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      onSubmitted: (_) => _sendMessage(),
                      style: TextStyle(color: textColor, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        filled: true,
                        fillColor: fieldFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: isDark ? const BorderSide(color: Color(0xFF334155)) : BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _sendMessage,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
