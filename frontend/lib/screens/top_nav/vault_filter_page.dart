// MUUD Health — Vault Filter Page
// Filter options for vault content
// © Muud Health — Armin Hoes, MD

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class VaultFilterPage extends StatefulWidget {
  const VaultFilterPage({super.key});

  @override
  State<VaultFilterPage> createState() => _VaultFilterPageState();
}

class _VaultFilterPageState extends State<VaultFilterPage> {
  String tag = "All";
  String experience = "All";
  String contentType = "All";
  String sortBy = "All";
  DateTime? from;
  DateTime? to;

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial = (isFrom ? from : to) ?? now;
    final picked = await showDatePicker(context: context, firstDate: DateTime(2015), lastDate: DateTime(2100), initialDate: initial);
    if (picked == null) return;
    setState(() { if (isFrom) { from = picked; } else { to = picked; } });
  }

  void _reset() {
    setState(() { tag = "All"; experience = "All"; contentType = "All"; sortBy = "All"; from = null; to = null; });
  }

  String _fmt(DateTime? d) {
    if (d == null) return "";
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MuudColors.white,
      appBar: AppBar(
        backgroundColor: MuudColors.white,
        surfaceTintColor: MuudColors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Go back',
          icon: const Icon(Icons.arrow_back, color: MuudColors.purple),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text("Filter", style: MuudTypography.titleMedium.copyWith(color: MuudColors.purple)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(MuudSpacing.lg, MuudSpacing.sm, MuudSpacing.lg, MuudSpacing.xl),
        children: [
          _title("Tag"),
          const SizedBox(height: MuudSpacing.md),
          _chipRow(items: const ["All", "Theme", "Feeling", "Location", "Person"], selected: tag, onSelect: (v) => setState(() => tag = v)),
          const SizedBox(height: MuudSpacing.xl),
          _title("Type of experience"),
          const SizedBox(height: MuudSpacing.md),
          _chipRow(items: const ["All", "Group", "Solo", "Yoga", "Shopping"], selected: experience, onSelect: (v) => setState(() => experience = v)),
          const SizedBox(height: MuudSpacing.xl),
          _title("Content type"),
          const SizedBox(height: MuudSpacing.md),
          _chipRow(items: const ["All", "Journal", "Journey", "Photo"], selected: contentType, onSelect: (v) => setState(() => contentType = v)),
          const SizedBox(height: MuudSpacing.xl),
          _title("Sort by"),
          const SizedBox(height: MuudSpacing.md),
          _chipRow(items: const ["All", "Most Recent", "Popular", "By Relevance"], selected: sortBy, onSelect: (v) => setState(() => sortBy = v)),
          const SizedBox(height: MuudSpacing.xl),
          _title("Filter by date and time"),
          const SizedBox(height: MuudSpacing.md),
          Row(
            children: [
              Expanded(child: _dateBox(label: "From", value: _fmt(from), onTap: () => _pickDate(isFrom: true))),
              const SizedBox(width: MuudSpacing.md),
              Expanded(child: _dateBox(label: "To", value: _fmt(to), onTap: () => _pickDate(isFrom: false))),
            ],
          ),
          const SizedBox(height: MuudSpacing.xxl),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _reset,
                    style: OutlinedButton.styleFrom(side: BorderSide(color: MuudColors.divider), shape: const StadiumBorder()),
                    child: Text("Reset Filter", style: MuudTypography.label.copyWith(color: MuudColors.purple)),
                  ),
                ),
              ),
              const SizedBox(width: MuudSpacing.md),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        "tag": tag, "experience": experience, "contentType": contentType,
                        "sortBy": sortBy, "from": from?.toIso8601String(), "to": to?.toIso8601String(),
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: MuudColors.purple, shape: const StadiumBorder(), elevation: 0),
                    child: Text("Apply", style: MuudTypography.button.copyWith(color: MuudColors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _title(String t) => Text(t, style: MuudTypography.titleMedium.copyWith(color: MuudColors.purple));

  Widget _chipRow({required List<String> items, required String selected, required void Function(String) onSelect}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((t) {
          final isOn = selected == t;
          return Padding(
            padding: const EdgeInsets.only(right: MuudSpacing.sm),
            child: GestureDetector(
              onTap: () => onSelect(t),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: MuudSpacing.base, vertical: MuudSpacing.sm),
                decoration: BoxDecoration(
                  color: isOn ? MuudColors.purple : MuudColors.white,
                  borderRadius: MuudRadius.pillAll,
                  border: Border.all(color: MuudColors.purple, width: 2),
                ),
                child: Text(t, style: MuudTypography.caption.copyWith(color: isOn ? MuudColors.white : MuudColors.purple, fontWeight: FontWeight.w900)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _dateBox({required String label, required String value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 74,
        padding: const EdgeInsets.fromLTRB(MuudSpacing.md, MuudSpacing.sm, MuudSpacing.md, MuudSpacing.sm),
        decoration: BoxDecoration(
          color: MuudColors.white,
          borderRadius: MuudRadius.mdAll,
          border: Border.all(color: MuudColors.divider, width: 1.6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: MuudTypography.label.copyWith(color: MuudColors.purple)),
            const SizedBox(height: MuudSpacing.sm),
            Text(value.isEmpty ? " " : value, style: MuudTypography.caption.copyWith(color: MuudColors.greyText)),
          ],
        ),
      ),
    );
  }
}
