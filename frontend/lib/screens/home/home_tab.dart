import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../services/user_api.dart';
import '../../services/token_storage.dart';
import '../../services/feed_api.dart';
import '../../services/journal_api.dart';
import '../../services/vault_api.dart';

// ✅ ADD THIS IMPORT
import '../journal/pages/edit_journal_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);

  String _displayName = "there";
  String _location = "";
  String? _avatarUrl;

  bool _loading = true;
  bool _avatarLoading = true;
  String? _error;

  // ✅ Home feed
  bool _feedLoading = true;
  String? _feedError;
  List<_FeedPost> _posts = [];

  // ✅ to determine owner
  String _mySub = "";

  // audio player for voice notes
  final AudioPlayer _player = AudioPlayer();
  String? _playingId;
  bool _playing = false;

  static const List<Map<String, String>> _vaultCategories = [
    {"key": "family", "label": "Family"},
    {"key": "friends", "label": "Friends"},
    {"key": "events", "label": "Events"},
    {"key": "holidays", "label": "Holidays"},
    {"key": "work", "label": "Work"},
    {"key": "school", "label": "School"},
    {"key": "other", "label": "Other"},
  ];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  bool _looksLikeUuid(String v) {
    final s = v.trim();
    if (s.isEmpty) return false;
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(s);
  }

  String _pickDisplayNameFromClaims(Map<String, dynamic> c) {
    String s(dynamic v) => (v ?? '').toString().trim();

    final preferred = s(c['preferred_username']);
    final cognitoUsername = s(c['cognito:username']);
    final username = s(c['username']);
    final name = s(c['name']);
    final email = s(c['email']);
    final sub = s(c['sub']);

    final candidates = <String>[
      preferred,
      cognitoUsername,
      username,
      name,
      email,
    ];

    for (final v in candidates) {
      if (v.isNotEmpty && !_looksLikeUuid(v)) return v;
    }
    return sub.isNotEmpty ? sub : "there";
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // ✅ 1) name + mySub from token
      final idToken = await TokenStorage.getIdToken();
      if (idToken != null && idToken.isNotEmpty) {
        final claims = JwtDecoder.decode(idToken);
        final nameFromToken = _pickDisplayNameFromClaims(claims);
        final sub = (claims['sub'] ?? '').toString();

        if (mounted) {
          setState(() {
            _displayName = nameFromToken;
            _mySub = sub;
          });
        }
      }

      // ✅ 2) location from backend
      try {
        final me = await UserApi.getMe();
        final location = (me['location'] ?? '').toString().trim();
        if (mounted) setState(() => _location = location);
      } catch (_) {}

      // ✅ 3) avatar
      await _loadAvatar();

      // ✅ 4) feed
      await _loadFeed();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadAvatar() async {
    setState(() => _avatarLoading = true);
    try {
      final url = await UserApi.getAvatarUrl();
      if (!mounted) return;
      setState(() => _avatarUrl = url);
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _avatarLoading = false);
    }
  }

  Future<void> _loadFeed() async {
    setState(() {
      _feedLoading = true;
      _feedError = null;
    });

    try {
      final raw = await FeedApi.getHomeFeed();
      final mapped = raw.map((m) => _FeedPost.fromMap(m)).toList();
      if (!mounted) return;
      setState(() => _posts = mapped);
    } catch (e) {
      if (!mounted) return;
      setState(() => _feedError = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _feedLoading = false);
    }
  }

  Future<void> _toggleAudio(_FeedPost p) async {
    if (p.audioUrl == null || p.audioUrl!.isEmpty) return;

    if (_playingId == p.id && _playing) {
      await _player.stop();
      if (!mounted) return;
      setState(() {
        _playing = false;
        _playingId = null;
      });
      return;
    }

    await _player.stop();
    await _player.play(UrlSource(p.audioUrl!));

    if (!mounted) return;
    setState(() {
      _playing = true;
      _playingId = p.id;
    });

    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _playing = false;
        _playingId = null;
      });
    });
  }

  bool _isOwner(_FeedPost p) => _mySub.isNotEmpty && p.authorSub == _mySub;

  Future<void> _showOwnerMenu(_FeedPost p) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7E1EF),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: kPurple),
                title: const Text(
                  "Edit",
                  style: TextStyle(color: kPurple, fontWeight: FontWeight.w900),
                ),
                onTap: () => Navigator.pop(context, "edit"),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                onTap: () => Navigator.pop(context, "delete"),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    if (picked == "edit") {
      await _openEditScreen(p);
    } else if (picked == "delete") {
      await _confirmDelete(p);
    }
  }

  // ✅ NEW: edit on a full screen (no bottom sheet controller disposal issues)
  Future<void> _openEditScreen(_FeedPost p) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            EditJournalScreen(postId: p.id, initialCaption: p.caption),
      ),
    );

    if (!mounted) return;

    if (updated == true) {
      await _loadFeed();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Saved ✅")));
    }
  }

  Future<void> _confirmDelete(_FeedPost p) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete this journal?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (yes != true) return;

    try {
      await JournalApi.deletePost(postId: p.id);
      if (!mounted) return;
      await _loadFeed();
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Deleted ✅")));
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Delete failed"),
          content: Text(e.toString().replaceFirst("Exception: ", "")),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _openSaveToVaultSheet(_FeedPost p) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _VaultCategorySheet(
        categories: _vaultCategories,
        purple: kPurple,
        grey: kGreyText,
      ),
    );

    if (chosen == null || chosen.isEmpty) return;

    try {
      await VaultApi.savePostToVault(postId: p.id, category: chosen);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Saved to Vault")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarWidget = _buildAvatar();

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good Morning $_displayName!",
              style: const TextStyle(
                fontSize: 28,
                height: 1.1,
                fontWeight: FontWeight.w800,
                color: kPurple,
              ),
            ),
            const SizedBox(height: 18),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

            // Profile card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () async {
                        final updated = await Navigator.pushNamed(
                          context,
                          '/edit-profile',
                        );
                        if (updated == true) await _loadAll();
                      },
                      child: const Text(
                        "Edit",
                        style: TextStyle(
                          color: kPurple,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  avatarWidget,
                  const SizedBox(height: 12),
                  Text(
                    _displayName,
                    style: const TextStyle(
                      color: kPurple,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _location.isNotEmpty ? _location : " ",
                    style: const TextStyle(
                      color: kGreyText,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "Your Journals",
              style: TextStyle(
                color: kPurple,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),

            if (_feedLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_feedError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    Text(
                      _feedError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _loadFeed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPurple,
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Retry",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (_posts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 12),
                  child: Column(
                    children: const [
                      Icon(Icons.edit_note, size: 48, color: Color(0xFFD7CDE3)),
                      SizedBox(height: 10),
                      Text(
                        "No journals yet",
                        style: TextStyle(
                          color: kPurple,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Tap + to create your first post.",
                        style: TextStyle(
                          color: kGreyText,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: _posts.map((p) {
                  final isThisPlaying = _playing && _playingId == p.id;
                  final owner = _isOwner(p);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(18),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1.1,
                                  child:
                                      (p.imageUrl == null ||
                                          p.imageUrl!.isEmpty)
                                      ? Container(
                                          color: const Color(0xFFF2EEF6),
                                          child: const Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: kGreyText,
                                            ),
                                          ),
                                        )
                                      : Image.network(
                                          p.imageUrl!,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              if (owner)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => _showOwnerMenu(p),
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.35),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.more_horiz,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (p.caption.isNotEmpty)
                                  Text(
                                    p.caption,
                                    style: const TextStyle(
                                      color: kPurple,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                if (p.caption.isNotEmpty)
                                  const SizedBox(height: 10),
                                if (p.audioUrl != null &&
                                    p.audioUrl!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFFE7E1EF),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () => _toggleAudio(p),
                                          icon: Icon(
                                            isThisPlaying
                                                ? Icons.pause_circle
                                                : Icons.play_circle,
                                            color: kPurple,
                                            size: 34,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Expanded(
                                          child: Text(
                                            "Voice note",
                                            style: TextStyle(
                                              color: kPurple,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      _formatTime(p.createdAt),
                                      style: const TextStyle(
                                        color: kGreyText,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                    const Spacer(),

                                    // ✅ Save to Vault
                                    IconButton(
                                      onPressed: () => _openSaveToVaultSheet(p),
                                      icon: const Icon(
                                        Icons.bookmark_border,
                                        color: kPurple,
                                      ),
                                      tooltip: "Save to Vault",
                                    ),

                                    Text(
                                      p.visibilityLabel,
                                      style: const TextStyle(
                                        color: kGreyText,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.5,
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
                }).toList(),
              ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPurple,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Tap the + button to post")),
                  );
                },
                child: const Text(
                  "Start Journaling",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return "$y-$m-$d  $hh:$mm";
  }

  Widget _buildAvatar() {
    if (_avatarLoading) {
      return const SizedBox(
        width: 98,
        height: 98,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          _avatarUrl!,
          width: 98,
          height: 98,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderAvatar(),
        ),
      );
    }

    return _placeholderAvatar();
  }

  Widget _placeholderAvatar() {
    return Container(
      width: 98,
      height: 98,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFEFEFEF),
      ),
      child: const Icon(Icons.person, size: 48, color: Color(0xFFBDBDBD)),
    );
  }
}

class _FeedPost {
  final String id;
  final String authorSub;
  final String caption;
  final String? imageUrl;
  final String? audioUrl;
  final String visibility;
  final DateTime createdAt;

  _FeedPost({
    required this.id,
    required this.authorSub,
    required this.caption,
    required this.imageUrl,
    required this.audioUrl,
    required this.visibility,
    required this.createdAt,
  });

  String get visibilityLabel {
    if (visibility == "innerCircle") return "Inner Circle";
    if (visibility == "connections") return "Connections";
    return "Public";
  }

  factory _FeedPost.fromMap(Map<String, dynamic> m) {
    return _FeedPost(
      id: (m["id"] ?? "").toString(),
      authorSub: (m["authorSub"] ?? "").toString(),
      caption: (m["caption"] ?? "").toString(),
      imageUrl: m["imageUrl"]?.toString(),
      audioUrl: m["audioUrl"]?.toString(),
      visibility: (m["visibility"] ?? "public").toString(),
      createdAt:
          DateTime.tryParse((m["createdAt"] ?? "").toString()) ??
          DateTime.now(),
    );
  }
}

class _VaultCategorySheet extends StatefulWidget {
  final List<Map<String, String>> categories;
  final Color purple;
  final Color grey;

  const _VaultCategorySheet({
    required this.categories,
    required this.purple,
    required this.grey,
  });

  @override
  State<_VaultCategorySheet> createState() => _VaultCategorySheetState();
}

class _VaultCategorySheetState extends State<_VaultCategorySheet> {
  String selected = "other";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE7E1EF),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              "Save to Vault",
              style: TextStyle(
                color: widget.purple,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Choose a category for this memory.",
              style: TextStyle(color: widget.grey, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: widget.categories.map((c) {
                  final key = c["key"]!;
                  final label = c["label"]!;
                  final isSelected = selected == key;

                  return InkWell(
                    onTap: () => setState(() => selected = key),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? widget.purple : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: widget.purple),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : widget.purple,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      side: BorderSide(color: widget.purple),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: widget.purple,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, selected),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.purple,
                      shape: const StadiumBorder(),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
