import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final foregroundColor = isDarkMode ? Colors.white : null;
    final searchBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide.none,
    );
    return Padding(
      padding: padding,
      child: TextField(
        key: fieldKey,
        style: TextStyle(color: foregroundColor),
        decoration: InputDecoration(
          hintText: searchType.hintText,
          hintStyle: TextStyle(color: isDarkMode ? Colors.white70 : null),
          prefixIcon: Icon(Icons.search, color: foregroundColor),
          suffixIcon: PopupMenuButton<PhotoSearchType>(
            tooltip: 'Search by',
            color: isDarkMode
                ? AppPalette.surface.withValues(alpha: .80)
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            icon: Icon(Icons.tune, color: foregroundColor),
            onSelected: onTypeChanged,
            itemBuilder: (_) => PhotoSearchType.values
                .map(
                  (type) => PopupMenuItem(
                    value: type,
                    child: Text(
                      type.label,
                      style: TextStyle(color: foregroundColor),
                    ),
                  ),
                )
                .toList(),
          ),
          border: searchBorder,
          enabledBorder: searchBorder,
          focusedBorder: searchBorder,
          filled: true,
          fillColor: isDarkMode
              ? AppPalette.surfaceHighlight
              : fillColor,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
