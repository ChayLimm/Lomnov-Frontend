import 'package:flutter/material.dart';

class SearchBarWithFilter extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final EdgeInsetsGeometry? padding;

  const SearchBarWithFilter({
    super.key,
    required this.controller,
    this.hintText = 'Search buildings',
    this.onFilterTap,
    this.onChanged,
    this.onSubmitted,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              tooltip: 'Filters',
              icon: const Icon(Icons.filter_list),
              onPressed: onFilterTap,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ),
    );
  }
}
