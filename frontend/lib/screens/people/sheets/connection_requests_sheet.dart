import 'package:flutter/material.dart';
import '../../../services/people_api.dart';
import '../state/people_events.dart';

class ConnectionRequestsSheet {
  static Future<void> open(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => const _ConnectionRequestsBody(),
    );
  }
}

class _ConnectionRequestsBody extends StatefulWidget {
  const _ConnectionRequestsBody();

  @override
  State<_ConnectionRequestsBody> createState() =>
      _ConnectionRequestsBodyState();
}

class _ConnectionRequestsBodyState extends State<_ConnectionRequestsBody> {
  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);

  bool loading = true;
  String? error;

  List<Map<String, dynamic>> requests = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final list = await PeopleApi.fetchRequests();

      final mapped = <Map<String, dynamic>>[];
      for (final item in list) {
        if (item is Map<String, dynamic>) mapped.add(item);
        if (item is Map) mapped.add(item.cast<String, dynamic>());
      }

      setState(() {
        requests = mapped;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Map<String, dynamic>? _fromUser(Map<String, dynamic> req) {
    final u = req['fromUser'];
    if (u is Map<String, dynamic>) return u;
    if (u is Map) return u.cast<String, dynamic>();
    return null;
  }

  String _name(Map<String, dynamic> req) {
    final u = _fromUser(req);
    final name = (u?['name'] ?? '').toString();
    if (name.isNotEmpty) return name;

    final username = (u?['username'] ?? '').toString();
    if (username.isNotEmpty) return username;

    // fallback (short sub)
    final fromSub = (req['fromSub'] ?? '').toString();
    return fromSub.isEmpty ? 'Unknown' : '${fromSub.substring(0, 8)}…';
  }

  String _handle(Map<String, dynamic> req) {
    final u = _fromUser(req);
    final username = (u?['username'] ?? '').toString();
    if (username.isEmpty) return '';
    return username.startsWith('@') ? username : '@$username';
  }

  Future<void> _accept(String requestId) async {
    try {
      await PeopleApi.acceptRequest(requestId: requestId);
      if (!mounted) return;

      PeopleEvents.notifyReload(); // ✅ refresh People tab
      await _load(); // refresh sheet list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _decline(String requestId) async {
    try {
      await PeopleApi.declineRequest(requestId: requestId);
      if (!mounted) return;

      PeopleEvents.notifyReload(); // ✅ refresh People tab
      await _load(); // refresh sheet list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.55;

    return SafeArea(
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                "Connection Requests",
                style: TextStyle(
                  color: kPurple,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${requests.length} people want to connect.",
                style: const TextStyle(
                  color: kGreyText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 40,
                              color: kPurple,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: kGreyText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPurple,
                                elevation: 0,
                                shape: const StadiumBorder(),
                              ),
                              onPressed: _load,
                              child: const Text(
                                "Retry",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    : requests.isEmpty
                    ? const Center(
                        child: Text(
                          "No requests right now.",
                          style: TextStyle(
                            color: kGreyText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: requests.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final r = requests[i];
                          final requestId = (r['_id'] ?? '').toString();

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F2FA),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Color(0xFFE7E1F3),
                                  child: Icon(
                                    Icons.person,
                                    color: kPurple,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _name(r),
                                        style: const TextStyle(
                                          color: kPurple,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _handle(r),
                                        style: const TextStyle(
                                          color: kGreyText,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 10),

                                TextButton(
                                  onPressed: requestId.isEmpty
                                      ? null
                                      : () => _accept(requestId),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: kPurple,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    shape: const StadiumBorder(),
                                  ),
                                  child: const Text(
                                    "Accept",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: requestId.isEmpty
                                      ? null
                                      : () => _decline(requestId),
                                  style: TextButton.styleFrom(
                                    foregroundColor: kPurple,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    shape: const StadiumBorder(),
                                  ),
                                  child: const Text(
                                    "Decline",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
