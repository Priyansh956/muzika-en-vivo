// lib/widgets/search_bar_field.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated search field with a search / clear button.
class SearchBarField extends StatefulWidget {
  final TextEditingController controller;
  final bool isSearching;
  final VoidCallback onSubmit;

  const SearchBarField({
    super.key,
    required this.controller,
    required this.isSearching,
    required this.onSubmit,
  });

  @override
  State<SearchBarField> createState() => _SearchBarFieldState();
}

class _SearchBarFieldState extends State<SearchBarField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final has = widget.controller.text.isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => widget.onSubmit(),
            style: const TextStyle(color: AppTheme.textHi, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Search songs, artists, albums…',
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppTheme.textMid, size: 22),
              suffixIcon: _hasText
                  ? IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppTheme.textMid, size: 20),
                onPressed: () {
                  widget.controller.clear();
                  FocusScope.of(context).unfocus();
                },
              )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: widget.isSearching
              ? const SizedBox(
            key: ValueKey('loading'),
            width: 48,
            height: 48,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          )
              : ElevatedButton(
            key: const ValueKey('btn'),
            onPressed: widget.onSubmit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(48, 48),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Icon(Icons.arrow_forward_rounded, size: 20),
          ),
        ),
      ],
    );
  }
}