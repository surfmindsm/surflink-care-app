import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class RegionPickerResult {
  final List<String> selections; // e.g., ["서울 강남구 개포동", "인천 연수구"]
  RegionPickerResult(this.selections);
}

class RegionPickerDialog extends StatefulWidget {
  const RegionPickerDialog({super.key, this.initialSelections = const []});

  final List<String> initialSelections;

  static Future<List<String>?> show(BuildContext context, {List<String> initialSelections = const []}) async {
    final result = await showDialog<RegionPickerResult>(
      context: context,
      barrierDismissible: true,
      builder: (_) => RegionPickerDialog(initialSelections: initialSelections),
    );
    return result?.selections;
  }

  @override
  State<RegionPickerDialog> createState() => _RegionPickerDialogState();
}

class _RegionPickerDialogState extends State<RegionPickerDialog> {
  Map<String, dynamic> _data = {};
  String? _selectedSido;
  String? _selectedSigungu;
  String _query = '';
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _load();
    _selected.addAll(widget.initialSelections);
  }

  Future<void> _load() async {
    final jsonStr = await rootBundle.loadString('assets/data/regions_kr.json');
    setState(() {
      _data = json.decode(jsonStr) as Map<String, dynamic>;
      _selectedSido = _data.keys.firstOrNull;
    });
  }

  List<String> get _sidoList => _data.keys.toList();

  List<String> get _sigunguList {
    if (_selectedSido == null) return [];
    final node = _data[_selectedSido!];
    if (node is Map<String, dynamic>) {
      return node.keys.toList();
    }
    return [];
  }

  List<String> get _dongList {
    if (_selectedSido == null || _selectedSigungu == null) return [];
    final node = _data[_selectedSido!]?[_selectedSigungu!];
    if (node is List) {
      return node.cast<String>();
    }
    return [];
  }

  void _toggleSelect(String label) {
    if (_selected.contains(label)) {
      _selected.remove(label);
    } else {
      _selected.add(label);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredSido = _query.isEmpty
        ? _sidoList
        : _sidoList.where((e) => e.contains(_query)).toList();

    final filteredSigungu = _query.isEmpty
        ? _sigunguList
        : _sigunguList.where((e) => e.contains(_query)).toList();

    final filteredDong = _query.isEmpty
        ? _dongList
        : _dongList.where((e) => e.contains(_query)).toList();

    return Dialog.fullscreen(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '희망근무지역 선택',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Search & keep similar (simplified; we only provide search)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: '지역명을 검색하세요.',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
            ),

            // 3 columns
            Expanded(
              child: Row(
                children: [
                  // Sido
                  Expanded(
                    child: _buildList(
                      title: '시·도',
                      items: filteredSido,
                      selected: _selectedSido,
                      onTap: (s) {
                        setState(() {
                          _selectedSido = s;
                          _selectedSigungu = null;
                        });
                      },
                    ),
                  ),

                  // Sigungu
                  Expanded(
                    child: _buildList(
                      title: '시·군·구',
                      items: filteredSigungu,
                      selected: _selectedSigungu,
                      onTap: (s) => setState(() => _selectedSigungu = s),
                      trailingBuilder: (s) {
                        final label = '${_selectedSido ?? ''} $s';
                        final checked = _selected.contains(label);
                        return Checkbox(value: checked, onChanged: (_) => _toggleSelect(label));
                      },
                    ),
                  ),

                  // Dong/Eup/Myeon
                  Expanded(
                    child: _buildList(
                      title: '동·읍·면',
                      items: filteredDong,
                      selected: null,
                      onTap: (d) => _toggleSelect('${_selectedSido ?? ''} ${_selectedSigungu ?? ''} $d'),
                      trailingBuilder: (d) {
                        final label = '${_selectedSido ?? ''} ${_selectedSigungu ?? ''} $d';
                        final checked = _selected.contains(label);
                        return Checkbox(value: checked, onChanged: (_) => _toggleSelect(label));
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Footer buttons
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: const Border(top: BorderSide(color: Color(0xFFE5E5EA))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(RegionPickerResult(_selected.toList()..sort())),
                      child: const Text('확인'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList({
    required String title,
    required List<String> items,
    required void Function(String) onTap,
    String? selected,
    Widget Function(String)? trailingBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE5E5EA))),
          ),
          child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = selected == item;
              return Material(
                color: isSelected ? const Color(0xFFFFEDE5) : null,
                child: ListTile(
                  dense: true,
                  title: Text(item),
                  onTap: () => onTap(item),
                  trailing: trailingBuilder?.call(item),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
