import 'package:flutter/material.dart';

enum PhotoSearchType { global, name, caption, category, time, comments }

extension PhotoSearchTypeInfo on PhotoSearchType {
  String get apiValue => name;

  String get label {
    switch (this) {
      case PhotoSearchType.global:
        return 'All fields';
      case PhotoSearchType.name:
        return 'Name';
      case PhotoSearchType.caption:
        return 'Caption';
      case PhotoSearchType.category:
        return 'Category';
      case PhotoSearchType.time:
        return 'Date (YYYY-MM-DD)';
      case PhotoSearchType.comments:
        return 'Comment';
    }
  }

  String get hintText => 'Search by ${label.toLowerCase()}...';
}

class PhotoSearchField extends StatelessWidget {
  final PhotoSearchType searchType;
  final ValueChanged<PhotoSearchType> onTypeChanged;
  final ValueChanged<String> onChanged;
  final EdgeInsetsGeometry padding;
  final Color? fillColor;
  final Key? fieldKey;

  const PhotoSearchField({
    super.key,
    required this.searchType,
    required this.onTypeChanged,
    required this.onChanged,
    required this.padding,
    this.fillColor,
    this.fieldKey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextField(
        key: fieldKey,
        decoration: InputDecoration(
          hintText: searchType.hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: PopupMenuButton<PhotoSearchType>(
            tooltip: 'Search by',
            icon: const Icon(Icons.tune),
            onSelected: onTypeChanged,
            itemBuilder: (_) => PhotoSearchType.values
                .map(
                  (type) => PopupMenuItem(
                    value: type,
                    child: Text(type.label),
                  ),
                )
                .toList(),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: fillColor,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
