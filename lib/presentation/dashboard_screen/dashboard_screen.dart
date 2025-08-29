import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/dashboard_stats_model.dart';
import '../../models/ticket_model.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import './widgets/analytics_chart_widget.dart';
import './widgets/bottom_sheet_details_widget.dart';
import './widgets/metrics_card_widget.dart';
import './widgets/recent_activity_item_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isLoading = true;

  DashboardStatsModel? _dashboardStats;
  List<TicketModel> _recentActivities = [];
  List<Map<String, dynamic>> _chartData = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load dashboard statistics
      _dashboardStats = await DashboardService.instance.getDashboardStats();

      // Load recent activities
      _recentActivities =
          await DashboardService.instance.getRecentActivity(limit: 5);

      // Load weekly trend data
      _chartData = await DashboardService.instance.getWeeklyTicketTrend();

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dashboard data: $error'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.instance.currentUser;
    final userName = currentUser?.name ?? 'User';
    final userRole = currentUser?.role.toUpperCase() ?? 'USER';

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshDashboard,
          color: AppTheme.lightTheme.colorScheme.primary,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(userName, userRole),
              SliverToBoxAdapter(
                child: _isLoading
                    ? _buildLoadingState()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMetricsSection(),
                          SizedBox(height: 2.h),
                          _buildRecentActivitySection(),
                          SizedBox(height: 2.h),
                          AnalyticsChartWidget(chartData: _chartData),
                          SizedBox(height: 10.h), // Space for FAB
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAppBar(String userName, String userRole) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      elevation: 0,
      toolbarHeight: 8.h,
      flexibleSpace: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Good morning,',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          userName,
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          userRole,
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                IconButton(
                  onPressed: _showNotifications,
                  icon: CustomIconWidget(
                    iconName: 'notifications',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Loading dashboard data...',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection() {
    if (_dashboardStats == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Overview',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          alignment: WrapAlignment.spaceEvenly,
          children: _dashboardStats!.metricsForChart.map((metric) {
            return MetricsCardWidget(
              title: metric['title'] as String,
              count: metric['count'] as String,
              trend: metric['trend'] as String,
              backgroundColor: metric['backgroundColor'] as Color,
              textColor: metric['textColor'] as Color,
              onTap: () => _navigateToDetails(metric['title'] as String),
              onLongPress: () => _showMetricDetails(metric),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              Text(
                'Recent Activity',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/my-tickets-screen'),
                child: Text(
                  'View All',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        _recentActivities.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Text(
                    'No recent activities',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentActivities.length,
                itemBuilder: (context, index) {
                  final ticket = _recentActivities[index];
                  return RecentActivityItemWidget(
                    activity: {
                      'ticketId': ticket.id.toString(),
                      'title': ticket.title,
                      'description': ticket.description,
                      'status': ticket.statusDisplay,
                      'priority': ticket.priorityDisplay,
                      'timeAgo': _formatTimeAgo(ticket.createdAt),
                    },
                    onViewDetails: () =>
                        _viewTicketDetails(ticket.id.toString()),
                    onAddComment: () => _addComment(ticket.id.toString()),
                    onChangeStatus: () => _changeStatus(ticket.id.toString()),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onBottomNavTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      selectedItemColor: AppTheme.lightTheme.colorScheme.primary,
      unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
      selectedLabelStyle: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 11.sp,
      ),
      unselectedLabelStyle: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
        fontSize: 11.sp,
      ),
      items: [
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'dashboard',
            color: _selectedIndex == 0
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'assignment',
            color: _selectedIndex == 1
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'My Tickets',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'list_alt',
            color: _selectedIndex == 2
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'All Tickets',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'person',
            color: _selectedIndex == 3
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.pushNamed(context, '/create-ticket-screen'),
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 3.0,
      icon: CustomIconWidget(
        iconName: 'add',
        color: Colors.white,
        size: 24,
      ),
      label: Text(
        'Create Ticket',
        style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Future<void> _refreshDashboard() async {
    await _loadDashboardData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dashboard updated successfully',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _onBottomNavTap(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        Navigator.pushNamed(context, '/my-tickets-screen');
        break;
      case 2:
        Navigator.pushNamed(context, '/all-tickets-screen');
        break;
      case 3:
        // Navigate to profile screen when available
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile screen coming soon',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
          ),
        );
        break;
    }
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'You have notifications',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to notifications screen
          },
        ),
      ),
    );
  }

  void _navigateToDetails(String metricType) {
    String route = '/my-tickets-screen';

    switch (metricType) {
      case 'Open Tickets':
      case 'In Progress':
        route = '/my-tickets-screen';
        break;
      case 'Resolved':
      case 'Closed':
        route = '/all-tickets-screen';
        break;
    }

    Navigator.pushNamed(context, route);
  }

  void _showMetricDetails(Map<String, dynamic> metric) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BottomSheetDetailsWidget(
        title: '${metric['title']} Details',
        details: [], // Can be expanded to show more details
      ),
    );
  }

  void _viewTicketDetails(String ticketId) {
    Navigator.pushNamed(
      context,
      '/ticket-details-screen',
      arguments: {'ticketId': ticketId},
    );
  }

  void _addComment(String ticketId) {
    Navigator.pushNamed(
      context,
      '/ticket-details-screen',
      arguments: {'ticketId': ticketId},
    );
  }

  void _changeStatus(String ticketId) {
    Navigator.pushNamed(
      context,
      '/ticket-details-screen',
      arguments: {'ticketId': ticketId},
    );
  }

  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
