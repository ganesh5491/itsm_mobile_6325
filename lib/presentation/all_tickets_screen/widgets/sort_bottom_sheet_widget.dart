import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SortBottomSheetWidget extends StatefulWidget {
  final String currentSortBy;
  final bool isAscending;
  final Function(String sortBy, bool isAscending) onApplySort;

  const SortBottomSheetWidget({
    Key? key,
    required this.currentSortBy,
    required this.isAscending,
    required this.onApplySort,
  }) : super(key: key);

  @override
  State<SortBottomSheetWidget> createState() => _SortBottomSheetWidgetState();
}

class _SortBottomSheetWidgetState extends State<SortBottomSheetWidget> {
  late String _selectedSortBy;
  late bool _isAscending;

  final List<Map<String, dynamic>> _sortOptions = [
    {
      'key': 'createdDate',
      'title': 'Creation Date',
      'subtitle': 'Sort by when ticket was created',
      'icon': 'schedule',
    },
    {
      'key': 'priority',
      'title': 'Priority',
      'subtitle': 'Sort by ticket priority level',
      'icon': 'priority_high',
    },
    {
      'key': 'status',
      'title': 'Status',
      'subtitle': 'Sort by current ticket status',
      'icon': 'flag',
    },
    {
      'key': 'lastUpdated',
      'title': 'Last Updated',
      'subtitle': 'Sort by most recent activity',
      'icon': 'update',
    },
    {
      'key': 'title',
      'title': 'Title',
      'subtitle': 'Sort alphabetically by title',
      'icon': 'sort_by_alpha',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedSortBy = widget.currentSortBy;
    _isAscending = widget.isAscending;
  }

  void _applySort() {
    widget.onApplySort(_selectedSortBy, _isAscending);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Text(
                  'Sort Tickets',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    size: 6.w,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          Divider(color: AppTheme.lightTheme.colorScheme.outline),

          // Sort options
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: _sortOptions.length,
              itemBuilder: (context, index) {
                final option = _sortOptions[index];
                final isSelected = _selectedSortBy == option['key'];

                return Card(
                  margin: EdgeInsets.only(bottom: 2.h),
                  elevation: isSelected ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.1)
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: option['icon'] as String,
                        size: 6.w,
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    title: Text(
                      option['title'] as String,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      option['subtitle'] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: isSelected
                        ? CustomIconWidget(
                            iconName: 'check_circle',
                            size: 6.w,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedSortBy = option['key'] as String;
                      });
                    },
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                  ),
                );
              },
            ),
          ),

          // Sort direction toggle
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: _isAscending ? 'arrow_upward' : 'arrow_downward',
                  size: 6.w,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sort Order',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _isAscending
                            ? 'Ascending (A-Z, 1-9)'
                            : 'Descending (Z-A, 9-1)',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: !_isAscending,
                  onChanged: (value) {
                    setState(() {
                      _isAscending = !value;
                    });
                  },
                ),
              ],
            ),
          ),

          // Action buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: AppTheme.lightTheme.textTheme.labelLarge,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applySort,
                    child: Text(
                      'Apply Sort',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
