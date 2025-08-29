import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterBottomSheetWidget({
    Key? key,
    required this.currentFilters,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;
  DateTimeRange? _selectedDateRange;

  final List<String> _statusOptions = [
    'Open',
    'In Progress',
    'Resolved',
    'Closed',
    'On Hold'
  ];
  final List<String> _priorityOptions = ['Low', 'Medium', 'High', 'Critical'];
  final List<String> _categoryOptions = [
    'Hardware',
    'Software',
    'Network',
    'Security',
    'Account Access'
  ];
  final List<Map<String, dynamic>> _assigneeOptions = [
    {
      'id': '1',
      'name': 'John Smith',
      'avatar':
          'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png'
    },
    {
      'id': '2',
      'name': 'Sarah Johnson',
      'avatar':
          'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png'
    },
    {
      'id': '3',
      'name': 'Mike Davis',
      'avatar':
          'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png'
    },
    {
      'id': '4',
      'name': 'Emily Brown',
      'avatar':
          'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png'
    },
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
    if (_filters['dateRange'] != null) {
      _selectedDateRange = _filters['dateRange'] as DateTimeRange;
    }
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
      _selectedDateRange = null;
    });
  }

  void _applyFilters() {
    if (_selectedDateRange != null) {
      _filters['dateRange'] = _selectedDateRange;
    }
    widget.onApplyFilters(_filters);
    Navigator.pop(context);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Text(
        title,
        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMultiSelectChips(String filterKey, List<String> options) {
    final selectedValues = (_filters[filterKey] as List<String>?) ?? [];

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: options.map((option) {
        final isSelected = selectedValues.contains(option);
        return FilterChip(
          label: Text(
            option,
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.onPrimary
                  : AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                if (_filters[filterKey] == null) {
                  _filters[filterKey] = <String>[];
                }
                (_filters[filterKey] as List<String>).add(option);
              } else {
                (_filters[filterKey] as List<String>?)?.remove(option);
                if ((_filters[filterKey] as List<String>?)?.isEmpty == true) {
                  _filters.remove(filterKey);
                }
              }
            });
          },
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          selectedColor: AppTheme.lightTheme.colorScheme.primary,
          checkmarkColor: AppTheme.lightTheme.colorScheme.onPrimary,
          side: BorderSide(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAssigneeSelection() {
    final selectedAssignees = (_filters['assignees'] as List<String>?) ?? [];

    return Column(
      children: [
        // Unassigned option
        CheckboxListTile(
          title: Row(
            children: [
              CircleAvatar(
                radius: 4.w,
                backgroundColor: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
                child: CustomIconWidget(
                  iconName: 'person_outline',
                  size: 5.w,
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Unassigned',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ],
          ),
          value: selectedAssignees.contains('unassigned'),
          onChanged: (selected) {
            setState(() {
              if (selected == true) {
                if (_filters['assignees'] == null) {
                  _filters['assignees'] = <String>[];
                }
                (_filters['assignees'] as List<String>).add('unassigned');
              } else {
                (_filters['assignees'] as List<String>?)?.remove('unassigned');
                if ((_filters['assignees'] as List<String>?)?.isEmpty == true) {
                  _filters.remove('assignees');
                }
              }
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        // Assignee options
        ..._assigneeOptions.map((assignee) {
          final isSelected = selectedAssignees.contains(assignee['id']);
          return CheckboxListTile(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 4.w,
                  backgroundImage: NetworkImage(assignee['avatar'] as String),
                ),
                SizedBox(width: 3.w),
                Text(
                  assignee['name'] as String,
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ],
            ),
            value: isSelected,
            onChanged: (selected) {
              setState(() {
                if (selected == true) {
                  if (_filters['assignees'] == null) {
                    _filters['assignees'] = <String>[];
                  }
                  (_filters['assignees'] as List<String>)
                      .add(assignee['id'] as String);
                } else {
                  (_filters['assignees'] as List<String>?)
                      ?.remove(assignee['id']);
                  if ((_filters['assignees'] as List<String>?)?.isEmpty ==
                      true) {
                    _filters.remove('assignees');
                  }
                }
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDateRangeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: () async {
            final DateTimeRange? picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              initialDateRange: _selectedDateRange,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: AppTheme.lightTheme.colorScheme,
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _selectedDateRange = picked;
              });
            }
          },
          icon: CustomIconWidget(
            iconName: 'date_range',
            size: 5.w,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          label: Text(
            _selectedDateRange != null
                ? '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}'
                : 'Select Date Range',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
        ),
        if (_selectedDateRange != null) ...[
          SizedBox(height: 1.h),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedDateRange = null;
                _filters.remove('dateRange');
              });
            },
            icon: CustomIconWidget(
              iconName: 'close',
              size: 4.w,
              color: AppTheme.lightTheme.colorScheme.error,
            ),
            label: Text(
              'Clear Date Range',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
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
                  'Filter Tickets',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Clear All',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(color: AppTheme.lightTheme.colorScheme.outline),

          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Status'),
                  _buildMultiSelectChips('status', _statusOptions),
                  _buildSectionTitle('Priority'),
                  _buildMultiSelectChips('priority', _priorityOptions),
                  _buildSectionTitle('Category'),
                  _buildMultiSelectChips('category', _categoryOptions),
                  _buildSectionTitle('Assignee'),
                  _buildAssigneeSelection(),
                  _buildSectionTitle('Date Range'),
                  _buildDateRangeSelection(),
                  SizedBox(height: 4.h),
                ],
              ),
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
                    onPressed: _applyFilters,
                    child: Text(
                      'Apply Filters',
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
