import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/add_comment_bottom_sheet.dart';
import './widgets/comments_thread_widget.dart';
import './widgets/description_card_widget.dart';
import './widgets/file_attachments_widget.dart';
import './widgets/status_update_widget.dart';
import './widgets/ticket_header_widget.dart';
import './widgets/ticket_hero_section_widget.dart';

class TicketDetailsScreen extends StatefulWidget {
  const TicketDetailsScreen({Key? key}) : super(key: key);

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  bool _isLoading = false;
  bool _isRefreshing = false;

  // Mock ticket data
  final Map<String, dynamic> _ticketData = {
    "id": "TKT-2024-001",
    "title": "Unable to access company email on mobile device",
    "description":
        """I'm experiencing issues accessing my company email account on my iPhone. The email app keeps showing an authentication error even though I'm using the correct credentials. I've tried restarting the app and my phone, but the problem persists. This is affecting my ability to respond to urgent emails while I'm away from my desk.

The error message says "Cannot verify server identity" and sometimes shows "The mail server is not responding". I need this resolved urgently as I have important client communications that require immediate attention.

I've also noticed that the calendar sync has stopped working, which is causing me to miss scheduled meetings. Please help resolve this issue as soon as possible.""",
    "status": "in_progress",
    "priority": "high",
    "category": "Email & Communication",
    "assignedAgent": {
      "id": "agent_001",
      "name": "Sarah Johnson",
      "avatar":
          "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face"
    },
    "createdAt": DateTime.now().subtract(const Duration(days: 2, hours: 3)),
    "updatedAt": DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
  };

  // Mock file attachments
  final List<Map<String, dynamic>> _attachments = [
    {
      "id": "att_001",
      "name": "error_screenshot.png",
      "type": "png",
      "size": "2.4 MB",
      "thumbnail":
          "https://images.unsplash.com/photo-1551650975-87deedd944c3?w=300&h=200&fit=crop"
    },
    {
      "id": "att_002",
      "name": "email_settings.pdf",
      "type": "pdf",
      "size": "1.2 MB",
      "thumbnail": null
    },
    {
      "id": "att_003",
      "name": "device_info.txt",
      "type": "txt",
      "size": "0.8 KB",
      "thumbnail": null
    },
  ];

  // Mock comments data
  List<Map<String, dynamic>> _comments = [
    {
      "id": "comment_001",
      "user": {
        "id": "user_001",
        "name": "Michael Chen",
        "avatar":
            "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face"
      },
      "message":
          "I'm experiencing the same issue. Started happening after the latest iOS update. Has anyone found a solution?",
      "timestamp": DateTime.now().subtract(const Duration(hours: 4)),
      "isOwn": false,
      "parentId": null,
      "parentMessage": null,
    },
    {
      "id": "comment_002",
      "user": {
        "id": "agent_001",
        "name": "Sarah Johnson",
        "avatar":
            "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face"
      },
      "message":
          "Thank you for reporting this issue. I've escalated this to our email server team. We're investigating the authentication problems that started after the recent server maintenance. I'll update you within 2 hours with our findings.",
      "timestamp":
          DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
      "isOwn": false,
      "parentId": null,
      "parentMessage": null,
    },
    {
      "id": "comment_003",
      "user": {
        "id": "current_user",
        "name": "You",
        "avatar":
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face"
      },
      "message":
          "Thanks for the quick response! I really appreciate the update. Looking forward to hearing back from you soon.",
      "timestamp":
          DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      "isOwn": true,
      "parentId": "comment_002",
      "parentMessage":
          "Thank you for reporting this issue. I've escalated this to our email server team...",
    },
  ];

  // User role for permission checking
  final String _userRole = "user"; // Can be "admin", "agent", or "user"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          TicketHeaderWidget(
            ticket: _ticketData,
            onBackPressed: _handleBackPressed,
            onMenuPressed: _showOptionsMenu,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshTicketDetails,
              color: AppTheme.lightTheme.colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TicketHeroSectionWidget(ticket: _ticketData),
                    SizedBox(height: 3.h),
                    DescriptionCardWidget(
                      description: _ticketData["description"] as String,
                    ),
                    SizedBox(height: 3.h),
                    FileAttachmentsWidget(
                      attachments: _attachments,
                      onDownload: _downloadFile,
                      onShare: _shareFile,
                    ),
                    SizedBox(height: 3.h),
                    StatusUpdateWidget(
                      currentStatus: _ticketData["status"] as String,
                      onStatusUpdate: _updateTicketStatus,
                      hasPermission:
                          _userRole == "admin" || _userRole == "agent",
                    ),
                    SizedBox(height: 3.h),
                    CommentsThreadWidget(
                      comments: _comments,
                      onReply: _replyToComment,
                      onEdit: _editComment,
                      onDelete: _deleteComment,
                      onReport: _reportComment,
                    ),
                    SizedBox(height: 10.h), // Extra space for FAB
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCommentBottomSheet,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: CustomIconWidget(
          iconName: 'add_comment',
          color: Colors.white,
          size: 5.w,
        ),
        label: Text(
          'Add Comment',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _handleBackPressed() {
    Navigator.pop(context);
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            _buildMenuOption(
              icon: 'edit',
              title: 'Edit Ticket',
              onTap: () {
                Navigator.pop(context);
                _editTicket();
              },
            ),
            _buildMenuOption(
              icon: 'share',
              title: 'Share Ticket',
              onTap: () {
                Navigator.pop(context);
                _shareTicket();
              },
            ),
            if (_userRole == "admin" || _userRole == "agent")
              _buildMenuOption(
                icon: 'delete',
                title: 'Delete Ticket',
                onTap: () {
                  Navigator.pop(context);
                  _deleteTicket();
                },
                isDestructive: true,
              ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: isDestructive
            ? const Color(0xFFF44336)
            : AppTheme.lightTheme.colorScheme.onSurface,
        size: 5.w,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: isDestructive
              ? const Color(0xFFF44336)
              : AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Future<void> _refreshTicketDetails() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
      _ticketData["updatedAt"] = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ticket details refreshed'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _downloadFile(Map<String, dynamic> attachment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${attachment["name"]}...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareFile(Map<String, dynamic> attachment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${attachment["name"]}...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateTicketStatus(String newStatus) {
    setState(() {
      _ticketData["status"] = newStatus;
      _ticketData["updatedAt"] = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Ticket status updated to ${newStatus.replaceAll('_', ' ').toUpperCase()}'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _replyToComment(Map<String, dynamic> comment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCommentBottomSheet(
        replyToComment: comment,
        onSubmit: (message, files) {
          _addComment(message, files, parentId: comment["id"] as String);
        },
      ),
    );
  }

  void _editComment(Map<String, dynamic> comment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            const Text('Edit comment functionality would be implemented here'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteComment(Map<String, dynamic> comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Delete Comment',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
            'Are you sure you want to delete this comment? This action cannot be undone.'),
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
              setState(() {
                _comments.removeWhere((c) => c["id"] == comment["id"]);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Comment deleted'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _reportComment(Map<String, dynamic> comment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Comment reported. Thank you for your feedback.'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddCommentBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCommentBottomSheet(
        onSubmit: (message, files) {
          _addComment(message, files);
        },
      ),
    );
  }

  void _addComment(String message, List<PlatformFile>? files,
      {String? parentId}) {
    final newComment = {
      "id": "comment_${DateTime.now().millisecondsSinceEpoch}",
      "user": {
        "id": "current_user",
        "name": "You",
        "avatar":
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face"
      },
      "message": message,
      "timestamp": DateTime.now(),
      "isOwn": true,
      "parentId": parentId,
      "parentMessage": parentId != null
          ? (_comments.firstWhere((c) => c["id"] == parentId)["message"]
              as String)
          : null,
    };

    setState(() {
      _comments.add(newComment);
      _comments.sort((a, b) =>
          (a["timestamp"] as DateTime).compareTo(b["timestamp"] as DateTime));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(parentId != null ? 'Reply posted' : 'Comment added'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _editTicket() {
    Navigator.pushNamed(context, '/create-ticket-screen');
  }

  void _shareTicket() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ticket shared successfully'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteTicket() {
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
              'Delete Ticket',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this ticket? This action cannot be undone and all associated data will be permanently removed.',
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
              Navigator.pop(context); // Go back to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Ticket deleted successfully'),
                  backgroundColor: const Color(0xFFF44336),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
