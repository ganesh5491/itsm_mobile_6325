import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TicketCardWidget extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final bool isSelected;
  final bool isMultiSelectMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(bool?)? onSelectionChanged;

  const TicketCardWidget({
    Key? key,
    required this.ticket,
    this.isSelected = false,
    this.isMultiSelectMode = false,
    this.onTap,
    this.onLongPress,
    this.onSelectionChanged,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'new':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'in_progress':
      case 'assigned':
        return const Color(0xFFF57C00);
      case 'resolved':
      case 'closed':
        return const Color(0xFF2E7D32);
      case 'on_hold':
        return const Color(0xFF757575);
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return const Color(0xFF2E7D32);
      case 'medium':
      case 'normal':
        return const Color(0xFFF57C00);
      case 'high':
        return const Color(0xFFD32F2F);
      case 'critical':
        return const Color(0xFF8E24AA);
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ticket['status'] as String? ?? 'Open';
    final priority = ticket['priority'] as String? ?? 'Medium';
    final lastUpdated = ticket['lastUpdated'] as DateTime? ?? DateTime.now();
    final assignee = ticket['assignee'] as Map<String, dynamic>?;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: isSelected ? 4.0 : 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: AppTheme.lightTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with ID, checkbox, and priority
              Row(
                children: [
                  if (isMultiSelectMode)
                    Padding(
                      padding: EdgeInsets.only(right: 3.w),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: onSelectionChanged,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${ticket['id']}',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(priority).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      priority.toUpperCase(),
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: _getPriorityColor(priority),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),

              // Title
              Text(
                ticket['title'] as String? ?? 'No Title',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 1.h),

              // Assignee and status row
              Row(
                children: [
                  // Assignee avatar and name
                  if (assignee != null) ...[
                    CircleAvatar(
                      radius: 3.w,
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      child: assignee['avatar'] != null
                          ? CustomImageWidget(
                              imageUrl: assignee['avatar'] as String,
                              width: 6.w,
                              height: 6.w,
                              fit: BoxFit.cover,
                            )
                          : Text(
                              (assignee['name'] as String? ?? 'U')[0]
                                  .toUpperCase(),
                              style: AppTheme.lightTheme.textTheme.labelMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        assignee['name'] as String? ?? 'Unassigned',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else ...[
                    CircleAvatar(
                      radius: 3.w,
                      backgroundColor: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                      child: CustomIconWidget(
                        iconName: 'person_outline',
                        size: 4.w,
                        color: AppTheme.lightTheme.colorScheme.outline,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Unassigned',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.outline,
                        ),
                      ),
                    ),
                  ],

                  // Status badge
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status.replaceAll('_', ' ').toUpperCase(),
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),

              // Last updated timestamp
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'access_time',
                    size: 3.w,
                    color: AppTheme.lightTheme.colorScheme.outline,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Updated ${_formatDateTime(lastUpdated)}',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
