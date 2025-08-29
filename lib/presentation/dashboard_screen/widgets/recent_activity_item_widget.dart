import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentActivityItemWidget extends StatelessWidget {
  final Map<String, dynamic> activity;
  final VoidCallback? onViewDetails;
  final VoidCallback? onAddComment;
  final VoidCallback? onChangeStatus;

  const RecentActivityItemWidget({
    Key? key,
    required this.activity,
    this.onViewDetails,
    this.onAddComment,
    this.onChangeStatus,
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
      case 'high':
      case 'urgent':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String ticketId = (activity['ticketId'] as String?) ?? '';
    final String title = (activity['title'] as String?) ?? '';
    final String status = (activity['status'] as String?) ?? '';
    final String priority = (activity['priority'] as String?) ?? '';
    final String timeAgo = (activity['timeAgo'] as String?) ?? '';
    final String description = (activity['description'] as String?) ?? '';

    return Slidable(
      key: ValueKey(ticketId),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onViewDetails?.call(),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            foregroundColor: Colors.white,
            icon: Icons.visibility,
            label: 'View',
            borderRadius: BorderRadius.circular(8),
          ),
          SlidableAction(
            onPressed: (_) => onAddComment?.call(),
            backgroundColor: const Color(0xFF37474F),
            foregroundColor: Colors.white,
            icon: Icons.comment,
            label: 'Comment',
            borderRadius: BorderRadius.circular(8),
          ),
          SlidableAction(
            onPressed: (_) => onChangeStatus?.call(),
            backgroundColor: const Color(0xFFF57C00),
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Status',
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#$ticketId',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.w600,
                      fontSize: 9.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.5.h),
            Text(
              description,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontSize: 12.sp,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'flag',
                  color: _getStatusColor(priority),
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  priority,
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: _getStatusColor(priority),
                    fontWeight: FontWeight.w500,
                    fontSize: 11.sp,
                  ),
                ),
                const Spacer(),
                CustomIconWidget(
                  iconName: 'access_time',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 14,
                ),
                SizedBox(width: 1.w),
                Text(
                  timeAgo,
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
