import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TicketCardWidget extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onAddComment;
  final VoidCallback? onChangeStatus;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final VoidCallback? onSetReminder;
  final VoidCallback? onMarkImportant;

  const TicketCardWidget({
    Key? key,
    required this.ticket,
    this.onTap,
    this.onEdit,
    this.onAddComment,
    this.onChangeStatus,
    this.onDelete,
    this.onShare,
    this.onSetReminder,
    this.onMarkImportant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String status = ticket['status'] ?? 'open';
    final String priority = ticket['priority'] ?? 'medium';
    final bool isDraft = status.toLowerCase() == 'draft';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(ticket['id']),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            if (onEdit != null)
              SlidableAction(
                onPressed: (_) => onEdit?.call(),
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit',
                borderRadius: BorderRadius.circular(2.w),
              ),
            if (onAddComment != null)
              SlidableAction(
                onPressed: (_) => onAddComment?.call(),
                backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                foregroundColor: Colors.white,
                icon: Icons.comment,
                label: 'Comment',
                borderRadius: BorderRadius.circular(2.w),
              ),
            if (onChangeStatus != null)
              SlidableAction(
                onPressed: (_) => onChangeStatus?.call(),
                backgroundColor: _getStatusColor(status),
                foregroundColor: Colors.white,
                icon: Icons.update,
                label: 'Status',
                borderRadius: BorderRadius.circular(2.w),
              ),
          ],
        ),
        endActionPane: isDraft && onDelete != null
            ? ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => onDelete?.call(),
                    backgroundColor: AppTheme.lightTheme.colorScheme.error,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                ],
              )
            : null,
        child: GestureDetector(
          onTap: onTap,
          onLongPress: () => _showContextMenu(context),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(1.w),
                        ),
                        child: Text(
                          '#${ticket['id']}',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _buildStatusBadge(status),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    ticket['title'] ?? 'No Title',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      _buildPriorityIndicator(priority),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          _formatDate(ticket['createdAt']),
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      if (ticket['isImportant'] == true)
                        CustomIconWidget(
                          iconName: 'star',
                          color: Colors.amber,
                          size: 4.w,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor = _getStatusColor(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(String priority) {
    Color priorityColor = _getPriorityColor(priority);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 2.w,
          height: 2.w,
          decoration: BoxDecoration(
            color: priorityColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          priority.toUpperCase(),
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: priorityColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'new':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'in_progress':
      case 'assigned':
        return Colors.orange;
      case 'resolved':
      case 'closed':
      case 'completed':
        return Colors.green;
      case 'draft':
        return Colors.grey;
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
      case 'normal':
        return Colors.orange;
      case 'high':
      case 'urgent':
        return Colors.red;
      case 'critical':
        return const Color(0xFFD32F2F);
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'No Date';

    DateTime dateTime;
    if (date is String) {
      dateTime = DateTime.tryParse(date) ?? DateTime.now();
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return 'Invalid Date';
    }

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

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(1.w),
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Share Ticket'),
              onTap: () {
                Navigator.pop(context);
                onShare?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'alarm',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 6.w,
              ),
              title: Text('Set Reminder'),
              onTap: () {
                Navigator.pop(context);
                onSetReminder?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName:
                    ticket['isImportant'] == true ? 'star' : 'star_border',
                color: Colors.amber,
                size: 6.w,
              ),
              title: Text(ticket['isImportant'] == true
                  ? 'Remove Important'
                  : 'Mark Important'),
              onTap: () {
                Navigator.pop(context);
                onMarkImportant?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}
