import 'package:flutter/material.dart';
import 'package:muud_health_app/theme/app_theme.dart';

class VaultFilterPage extends StatefulWidget {
  const VaultFilterPage({super.key});

  @override
  State<VaultFilterPage> createState() => _VaultFilterPageState();
}

class _VaultFilterPageState extends State<VaultFilterPage> {
  static const Color kBorder = Color(0xFFE7E1EF);
  // selections (MVP UI only)
  String tag = "All"; // All / Theme / Feeling / Location / Person
  String experience = "All"; // All / Group / Solo / Yoga / Shopping
  String contentType = "All"; // All / Journal / Journey / Photo
  String sortBy = "All"; // All / Most Recent / Popular / By Relevance

  DateTime? from;
  DateTime? to;

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial = (isFrom ? from : to) ?? now;

    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
      initialDate: initial,
    );

    if (picked == null) return;

    setState(() {
      if (isFrom) {
        from = picked;
      } else {
        to = picked;
      }
    });
  }

  void _reset() {
    setState(() {
      tag = "All";
      experience = "All";
      contentType = "All";
      sortBy = "All";
      from = null;
      to = null;
    });
  }

  String _fmt(DateTime? d) {
    if (d == null) return "";
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    final dd = d.day.toString().padLeft(2, '0');
    return "$dd ${months[d.month - 1]} ${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.purple),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Filter",
          style: TextStyle(
            color: AppTheme.purple,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
        children: [
          _title("Tag"),
          const SizedBox(height: 12),
          _chipRow(
            items: const ["All", "Theme", "Feeling", "Location", "Person"],
            selected: tag,
            onSelect: (v) => setState(() => tag = v),
          ),

          const SizedBox(height: 22),
          _title("Type of experience"),
          const SizedBox(height: 12),
          _chipRow(
            items: const ["All", "Group", "Solo", "Yoga", "Shopping"],
            selected: experience,
            onSelect: (v) => setState(() => experience = v),
          ),

          const SizedBox(height: 22),
          _title("Content type"),
          const SizedBox(height: 12),
          _chipRow(
            items: const ["All", "Journal", "Journey", "Photo"],
            selected: contentType,
            onSelect: (v) => setState(() => contentType = v),
          ),

          const SizedBox(height: 22),
          _title("Sort by"),
          const SizedBox(height: 12),
          _chipRow(
            items: const ["All", "Most Recent", "Popular", "By Relevance"],
            selected: sortBy,
            onSelect: (v) => setState(() => sortBy = v),
          ),

          const SizedBox(height: 22),
          _title("Filter by date and time"),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _dateBox(
                  label: "From",
                  value: _fmt(from),
                  onTap: () => _pickDate(isFrom: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dateBox(
                  label: "To",
                  value: _fmt(to),
                  onTap: () => _pickDate(isFrom: false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _reset,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kBorder),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      "Reset Filter",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        "tag": tag,
                        "experience": experience,
                        "contentType": contentType,
                        "sortBy": sortBy,
                        "from": from?.toIso8601String(),
                        "to": to?.toIso8601String(),
                      });
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.purple,
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Apply",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _title(String t) {
    return Text(
      t,
      style: const TextStyle(
        color: AppTheme.purple,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _chipRow({
    required List<String> items,
    required String selected,
    required void Function(String) onSelect,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((t) {
          final isOn = selected == t;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onSelect(t),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isOn ? AppTheme.purple : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppTheme.purple, width: 2),
                ),
                child: Text(
                  t,
                  style: TextStyle(
                    color: isOn ? Colors.white : AppTheme.purple,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _dateBox({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 74,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder, width: 1.6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value.isEmpty ? " " : value,
              style: const TextStyle(
                color: AppTheme.greyText,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
