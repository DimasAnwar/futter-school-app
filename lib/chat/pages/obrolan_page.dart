import 'package:bestpractice/common/widgets/skeleton_item.dart';
import 'package:bestpractice/services/chat_services.dart';
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
  final ChatServices _chatServices = ChatServices();
  String _searchQuery = '';
  String _selectedFilter = 'Semua';
  bool _isLoadingRooms = false;
  List<Map<String, dynamic>> _realChats = [];

  Widget _buildChatRoomsSkeleton(bool isDark) {
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => Divider(height: 1, color: dividerColor),
      itemBuilder: (_, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            children: [
              const SkeletonItem(width: 48, height: 48, borderRadius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        SkeletonItem(width: 130, height: 14, borderRadius: 4),
                        SkeletonItem(width: 36, height: 10, borderRadius: 4),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const SkeletonItem(width: 180, height: 12, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchSkeleton(bool isDark) {
    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
      itemBuilder: (_, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              const SkeletonItem(width: 40, height: 40, borderRadius: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonItem(width: 120, height: 13, borderRadius: 4),
                  SizedBox(height: 6),
                  SkeletonItem(width: 160, height: 10, borderRadius: 4),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadRealChats();
  }

  Future<void> _loadRealChats() async {
    if (!_chatServices.hasCachedRooms) {
      setState(() => _isLoadingRooms = true);
    }
    final rooms = await _chatServices.refreshRooms();
    if (mounted) {
      setState(() {
        _realChats = rooms;
        _isLoadingRooms = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredChats {
    return _realChats.where((chat) {
      final matchesSearch = (chat['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (chat['lastMessage'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      if (_selectedFilter == 'Semua') return matchesSearch;
      return matchesSearch && (chat['type'] == _selectedFilter);
    }).toList();
  }

  Future<void> _showNewChatOptions() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomContext) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Jenis Obrolan Baru',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_search_rounded, color: Color(0xFF2563EB)),
                ),
                title: Text('Obrolan 1-on-1 (Cari Kontak)', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                subtitle: const Text('Cari pengguna terdaftar melalui nama atau email', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                onTap: () {
                  Navigator.pop(bottomContext);
                  _showDirectChatModal();
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.group_add_rounded, color: Color(0xFF059669)),
                ),
                title: Text('Buat Grup Chat Baru', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                subtitle: const Text('Buat grup percakapan baru dengan memilih beberapa anggota', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                onTap: () {
                  Navigator.pop(bottomContext);
                  _showCreateGroupModal();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDirectChatModal() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final fieldFill = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);

    final TextEditingController searchCtrl = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];
    bool isSearching = false;
    bool hasSearched = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> doSearch(String q) async {
              if (q.trim().isEmpty) {
                setModalState(() {
                  searchResults = [];
                  hasSearched = false;
                  isSearching = false;
                });
                return;
              }
              setModalState(() => isSearching = true);
              final res = await _chatServices.searchContacts(q);
              setModalState(() {
                searchResults = res;
                isSearching = false;
                hasSearched = true;
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(bottomContext).viewInsets.bottom,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.65,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cari Pengguna',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: textColor),
                          onPressed: () => Navigator.pop(bottomContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: searchCtrl,
                      onChanged: doSearch,
                      autofocus: true,
                      style: TextStyle(color: textColor, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Ketik nama atau email pengguna...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2563EB)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        filled: true,
                        fillColor: fieldFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: isDark ? const BorderSide(color: Color(0xFF334155)) : BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: isSearching
                          ? _buildSearchSkeleton(isDark)
                          : (!hasSearched || searchCtrl.text.trim().isEmpty)
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.search, size: 48, color: Color(0xFF94A3B8)),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Ketik nama atau email untuk mulai mencari kontak.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                )
                              : searchResults.isEmpty
                                  ? Center(
                                      child: Text(
                                        'Pengguna "${searchCtrl.text}" tidak ditemukan.',
                                        style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)),
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: searchResults.length,
                                      separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                                      itemBuilder: (context, index) {
                                        final c = searchResults[index];
                                        final name = c['full_name'] as String? ?? 'Pengguna';
                                        final email = c['email'] as String? ?? '-';
                                        final role = c['role'] as String? ?? 'Mahasiswa';
                                        final targetId = c['id'] as String;

                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: const Color(0xFF2563EB),
                                            child: Text(
                                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                                          subtitle: Text('$email • Peran: $role', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B))),
                                          onTap: () async {
                                            Navigator.pop(bottomContext);
                                            final roomId = await _chatServices.getOrCreateDirectRoom(targetId, name);
                                            if (mounted) {
                                              _openChatRoom({
                                                'id': roomId ?? 'new_room',
                                                'name': name,
                                                'type': role,
                                                'lastMessage': '',
                                                'time': 'Baru',
                                                'unreadCount': 0,
                                                'isOnline': true,
                                                'avatarColor': 0xFF2563EB,
                                              });
                                              _loadRealChats();
                                            }
                                          },
                                        );
                                      },
                                    ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showCreateGroupModal() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final fieldFill = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);

    final TextEditingController groupNameCtrl = TextEditingController();
    final TextEditingController searchCtrl = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];
    final Set<String> selectedUserIds = {};
    bool isSearching = false;
    bool isCreating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> doSearch(String q) async {
              if (q.trim().isEmpty) {
                setModalState(() {
                  searchResults = [];
                  isSearching = false;
                });
                return;
              }
              setModalState(() => isSearching = true);
              final res = await _chatServices.searchContacts(q);
              setModalState(() {
                searchResults = res;
                isSearching = false;
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(bottomContext).viewInsets.bottom,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Buat Grup Chat Baru',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: textColor),
                          onPressed: () => Navigator.pop(bottomContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: groupNameCtrl,
                      style: TextStyle(color: textColor, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Nama Grup Chat',
                        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF2563EB)),
                        hintText: 'Contoh: Grup Diskusi Mobile App',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        filled: true,
                        fillColor: fieldFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: isDark ? const BorderSide(color: Color(0xFF334155)) : BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Cari & Tambah Anggota Grup:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: searchCtrl,
                      onChanged: doSearch,
                      style: TextStyle(color: textColor, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Cari anggota via nama atau email...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.person_search_rounded, color: Color(0xFF2563EB)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        filled: true,
                        fillColor: fieldFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: isDark ? const BorderSide(color: Color(0xFF334155)) : BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: isSearching
                          ? _buildSearchSkeleton(isDark)
                          : searchCtrl.text.trim().isEmpty
                              ? Center(
                                  child: Text(
                                    'Ketik nama atau email untuk mencari anggota grup.',
                                    style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: searchResults.length,
                                  separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                                  itemBuilder: (context, index) {
                                    final c = searchResults[index];
                                    final name = c['full_name'] as String? ?? 'Pengguna';
                                    final email = c['email'] as String? ?? '-';
                                    final targetId = c['id'] as String;
                                    final isSelected = selectedUserIds.contains(targetId);

                                    return CheckboxListTile(
                                      value: isSelected,
                                      activeColor: const Color(0xFF2563EB),
                                      title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14)),
                                      subtitle: Text(email, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B))),
                                      onChanged: (val) {
                                        setModalState(() {
                                          if (val == true) {
                                            selectedUserIds.add(targetId);
                                          } else {
                                            selectedUserIds.remove(targetId);
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isCreating
                            ? null
                            : () async {
                                final gName = groupNameCtrl.text.trim();
                                if (gName.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Nama grup tidak boleh kosong.')),
                                  );
                                  return;
                                }
                                setModalState(() => isCreating = true);
                                final roomId = await _chatServices.createGroupRoom(gName, selectedUserIds.toList());
                                if (mounted) {
                                  Navigator.pop(bottomContext);
                                  _openChatRoom({
                                    'id': roomId ?? 'new_group',
                                    'name': gName,
                                    'type': 'Grup Kelas',
                                    'lastMessage': '',
                                    'time': 'Baru',
                                    'unreadCount': 0,
                                    'isOnline': true,
                                    'avatarColor': 0xFF059669,
                                  });
                                  _loadRealChats();
                                }
                              },
                        child: isCreating
                            ? const SkeletonItem(width: 80, height: 16, borderRadius: 4)
                            : Text('Buat Grup Chat (${selectedUserIds.length} Anggota)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
            tooltip: 'Obrolan Baru',
            onPressed: _showNewChatOptions,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2563EB)),
            tooltip: 'Muat Ulang',
            onPressed: _loadRealChats,
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
                    children: ['Semua', 'Grup Kelas'].map((filter) {
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
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatServices.getRoomsStream(),
              builder: (context, snapshot) {
                final currentList = snapshot.data ?? _realChats;
                final isStillLoading = _isLoadingRooms && currentList.isEmpty;

                if (isStillLoading) {
                  return _buildChatRoomsSkeleton(isDark);
                }

                final filteredList = currentList.where((chat) {
                  final matchesSearch = (chat['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (chat['lastMessage'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
                  if (_selectedFilter == 'Semua') return matchesSearch;
                  return matchesSearch && (chat['type'] == _selectedFilter);
                }).toList();

                if (filteredList.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada obrolan ditemukan.',
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: dividerColor),
                  itemBuilder: (context, index) {
                    final chat = filteredList[index];
                    final name = chat['name'] as String;
                    final lastMessage = chat['lastMessage'] as String;
                    final time = chat['time'] as String;
                    final unreadCount = chat['unreadCount'] as int? ?? 0;
                    final isOnline = chat['isOnline'] as bool? ?? true;
                    final colorVal = chat['avatarColor'] as int? ?? 0xFF2563EB;
                    final isGroupItem = (chat['isGroup'] as bool? ?? false) || (chat['type'] == 'Grup Kelas');
                    final pCount = chat['participantCount'] as int? ?? 0;

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
                                    backgroundColor: isGroupItem ? const Color(0xFF059669) : Color(colorVal),
                                    child: isGroupItem
                                        ? const Icon(Icons.group_rounded, color: Colors.white, size: 24)
                                        : Text(
                                            name.isEmpty ? 'C' : name[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                  ),
                                  if (isOnline && !isGroupItem)
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
  final ChatServices _chatServices = ChatServices();
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, dynamic>> _localMessages;
  Map<String, String> _participantNames = {};

  @override
  void initState() {
    super.initState();
    _localMessages = List<Map<String, dynamic>>.from(widget.chat['messages'] ?? []);
    final roomId = widget.chat['id'] as String;
    if (roomId.length > 10) {
      _loadParticipantNames(roomId);
    }
  }

  Future<void> _loadParticipantNames(String roomId) async {
    final names = await _chatServices.getRoomParticipantNames(roomId);
    if (mounted) {
      setState(() {
        _participantNames = names;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final roomId = widget.chat['id'] as String;
    _msgController.clear();

    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // If it's a real Supabase room (UUID format or not starting with 'c')
    if (roomId.length > 10) {
      await _chatServices.sendMessage(roomId, text);
    } else {
      setState(() {
        _localMessages.add({
          'sender': 'Saya',
          'text': text,
          'time': timeStr,
          'isMe': true,
        });
        widget.chat['lastMessage'] = 'Saya: $text';
        widget.chat['time'] = timeStr;
      });
    }

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

  Widget _buildMessagesSkeleton(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        final isLeft = index % 2 == 0;
        return Align(
          alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                SkeletonItem(
                  width: isLeft ? 190 : 140,
                  height: 42,
                  borderRadius: 16,
                ),
                const SizedBox(height: 4),
                const SkeletonItem(width: 36, height: 8, borderRadius: 4),
              ],
            ),
          ),
        );
      },
    );
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
    final rawName = widget.chat['name'] as String? ?? 'Obrolan';
    final chatType = widget.chat['type'] as String? ?? '';
    final bool isGroup = (widget.chat['isGroup'] as bool? ?? false) || chatType == 'Grup Kelas' || chatType == 'group';
    final int partCount = (widget.chat['participantCount'] as int? ?? 0) > 0 
        ? (widget.chat['participantCount'] as int) 
        : _participantNames.length;

    final myId = _chatServices.currentUserId;
    final otherPartEntries = _participantNames.entries.where((e) => e.key != myId).toList();
    final headerName = isGroup 
        ? rawName 
        : (otherPartEntries.isNotEmpty ? otherPartEntries.first.value : rawName);

    final isOnline = widget.chat['isOnline'] as bool? ?? true;
    final subtitleText = isGroup 
        ? (partCount > 0 ? '$partCount Anggota' : 'Grup Obrolan') 
        : (isOnline ? 'Online' : 'Offline');

    final colorVal = isGroup ? 0xFF059669 : (widget.chat['avatarColor'] as int? ?? 0xFF2563EB);

    final roomId = widget.chat['id'] as String;
    final isRealRoom = roomId.length > 10;

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
              child: isGroup
                  ? const Icon(Icons.group_rounded, color: Colors.white, size: 20)
                  : Text(
                      headerName.isEmpty ? 'C' : headerName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headerName,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitleText,
                    style: TextStyle(
                      fontSize: 11,
                      color: isGroup ? const Color(0xFF059669) : (isOnline ? const Color(0xFF10B981) : const Color(0xFF94A3B8)),
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
            child: isRealRoom
                ? StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _chatServices.getMessagesStream(roomId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildMessagesSkeleton(isDark);
                      }

                      final messagesList = snapshot.data ?? [];
                      if (messagesList.isEmpty) {
                        return Center(
                          child: Text(
                            'Belum ada pesan. Mulai obrolan sekarang!',
                            style: TextStyle(color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8), fontSize: 13),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messagesList.length,
                        itemBuilder: (context, index) {
                          final msg = messagesList[index];
                          final isMe = msg['isMe'] as bool;
                          final text = msg['text'] as String;
                          final time = msg['time'] as String;
                          final senderId = msg['senderId'] as String? ?? '';
                          final realSender = isMe
                              ? 'Saya'
                              : (_participantNames[senderId] ?? headerName);

                          return _buildMessageBubble(isMe, text, time, realSender, incomingBubbleBg, incomingBubbleText);
                        },
                      );
                    },
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _localMessages.length,
                    itemBuilder: (context, index) {
                      final msg = _localMessages[index];
                      final isMe = msg['isMe'] as bool;
                      final text = msg['text'] as String;
                      final time = msg['time'] as String;
                      final sender = msg['sender'] as String;
                      return _buildMessageBubble(isMe, text, time, sender, incomingBubbleBg, incomingBubbleText);
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

  Widget _buildMessageBubble(
    bool isMe,
    String text,
    String time,
    String sender,
    Color incomingBubbleBg,
    Color incomingBubbleText,
  ) {
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
  }
}
