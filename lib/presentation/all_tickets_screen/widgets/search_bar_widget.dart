import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final String hintText;
  final Function(String) onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onSortTap;
  final String searchQuery;

  const SearchBarWidget({
    Key? key,
    required this.hintText,
    required this.onChanged,
    this.onFilterTap,
    this.onSortTap,
    this.searchQuery = '',
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
    _isSearchActive = widget.searchQuery.isNotEmpty;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged('');
    setState(() {
      _isSearchActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSearchActive
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline,
                  width: _isSearchActive ? 2 : 1,
                ),
              ),
              child: TextField(
                controller: _controller,
                onChanged: (value) {
                  widget.onChanged(value);
                  setState(() {
                    _isSearchActive = value.isNotEmpty;
                  });
                },
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.outline,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'search',
                      size: 5.w,
                      color: _isSearchActive
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline,
                    ),
                  ),
                  suffixIcon: _isSearchActive
                      ? IconButton(
                          onPressed: _clearSearch,
                          icon: CustomIconWidget(
                            iconName: 'close',
                            size: 5.w,
                            color: AppTheme.lightTheme.colorScheme.outline,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 3.h,
                  ),
                ),
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ),
          ),
          if (widget.onSortTap != null) ...[
            SizedBox(width: 2.w),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: widget.onSortTap,
                icon: CustomIconWidget(
                  iconName: 'sort',
                  size: 6.w,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
                tooltip: 'Sort tickets',
              ),
            ),
          ],
          if (widget.onFilterTap != null) ...[
            SizedBox(width: 2.w),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: widget.onFilterTap,
                icon: CustomIconWidget(
                  iconName: 'filter_list',
                  size: 6.w,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
                tooltip: 'Filter tickets',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
