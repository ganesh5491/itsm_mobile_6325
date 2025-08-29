import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StatusUpdateWidget extends StatelessWidget {
  final String currentStatus;
  final Function(String) onStatusUpdate;
  final bool hasPermission;

  const StatusUpdateWidget({
    Key? key,
    required this.currentStatus,
    required this.onStatusUpdate,
    required this.hasPermission,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!hasPermission) {
      return const SizedBox.shrink();
    }

    final List<Map<String, dynamic>> statusOptions = [
      {'value': 'open', 'label': 'Open', 'color': const Color(0xFF2196F3)},
      {
        'value': 'in_progress',
        'label': 'In Progress',
        'color': const Color(0xFFFF9800)
      },
      {
        'value': 'resolved',
        'label': 'Resolved',
        'color': const Color(0xFF4CAF50)
      },
      {'value': 'closed', 'label': 'Closed', 'color': const Color(0xFF757575)},
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'update',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Update Status',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: statusOptions.map((status) {
              final bool isSelected = status['value'] == currentStatus;
              final bool isCritical = status['value'] == 'closed';

              return GestureDetector(
                onTap: () {
                  if (!isSelected) {
                    if (isCritical) {
                      _showConfirmationDialog(context, status);
                    } else {
                      onStatusUpdate(status['value'] as String);
                    }
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (status['color'] as Color).withValues(alpha: 0.2)
                        : AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? (status['color'] as Color)
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 3.w,
                        height: 3.w,
                        decoration: BoxDecoration(
                          color: status['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        status['label'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? (status['color'] as Color)
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      if (isSelected) ...[
                        SizedBox(width: 2.w),
                        CustomIconWidget(
                          iconName: 'check_circle',
                          color: status['color'] as Color,
                          size: 4.w,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(
      BuildContext context, Map<String, dynamic> status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: const Color(0xFFFF9800),
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Confirm Action',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to ${status['label'].toString().toLowerCase()} this ticket? This action may not be reversible.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onStatusUpdate(status['value'] as String);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: status['color'] as Color,
              foregroundColor: Colors.white,
            ),
            child: Text(status['label'] as String),
          ),
        ],
      ),
    );
  }
}
