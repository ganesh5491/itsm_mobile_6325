import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/skeleton_card_widget.dart';
import './widgets/ticket_card_widget.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({Key? key}) : super(key: key);

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  bool _isRefreshing = false;
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};
  List<Map<String, dynamic>> _allTickets = [];
  List<Map<String, dynamic>> _filteredTickets = [];

  // Mock data for tickets
  final List<Map<String, dynamic>> _mockTickets = [
    {
      "id": "TKT-001",
      "title": "Unable to access company email on mobile device",
      "description":
          "I'm having trouble setting up my work email on my iPhone. The authentication keeps failing.",
      "status": "Open",
      "priority": "High",
      "category": "Software",
      "subcategory": "Email",
      "assignedAgent": "Sarah Johnson",
      "createdAt": "2025-08-28T10:30:00Z",
      "updatedAt": "2025-08-28T14:15:00Z",
      "dueDate": "2025-08-30T17:00:00Z",
      "isImportant": true,
      "comments": 3,
      "attachments": 1,
    },
    {
      "id": "TKT-002",
      "title": "Laptop running very slow after recent Windows update",
      "description":
          "My laptop has become extremely slow since the last Windows update. Applications take forever to load.",
      "status": "In Progress",
      "priority": "Medium",
      "category": "Hardware",
      "subcategory": "Performance",
      "assignedAgent": "Mike Chen",
      "createdAt": "2025-08-27T09:15:00Z",
      "updatedAt": "2025-08-28T11:30:00Z",
      "dueDate": "2025-08-29T17:00:00Z",
      "isImportant": false,
      "comments": 5,
      "attachments": 0,
    },
    {
      "id": "TKT-003",
      "title": "Request for additional software license",
      "description":
          "Need Adobe Creative Suite license for new team member joining next week.",
      "status": "Resolved",
      "priority": "Low",
      "category": "Software",
      "subcategory": "Licensing",
      "assignedAgent": "Lisa Wang",
      "createdAt": "2025-08-26T14:20:00Z",
      "updatedAt": "2025-08-28T16:45:00Z",
      "dueDate": "2025-08-31T17:00:00Z",
      "isImportant": false,
      "comments": 2,
      "attachments": 2,
    },
    {
      "id": "TKT-004",
      "title": "VPN connection keeps dropping during video calls",
      "description":
          "The VPN connection becomes unstable during Teams meetings, causing frequent disconnections.",
      "status": "Open",
      "priority": "High",
      "category": "Network",
      "subcategory": "VPN",
      "assignedAgent": null,
      "createdAt": "2025-08-28T08:45:00Z",
      "updatedAt": "2025-08-28T08:45:00Z",
      "dueDate": "2025-08-29T12:00:00Z",
      "isImportant": true,
      "comments": 0,
      "attachments": 1,
    },
    {
      "id": "TKT-005",
      "title": "Password reset for shared drive access",
      "description":
          "Need to reset password for the marketing shared drive. Lost access after security update.",
      "status": "Draft",
      "priority": "Medium",
      "category": "Security",
      "subcategory": "Access Control",
      "assignedAgent": null,
      "createdAt": "2025-08-28T16:20:00Z",
      "updatedAt": "2025-08-28T16:20:00Z",
      "dueDate": null,
      "isImportant": false,
      "comments": 0,
      "attachments": 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeData() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _allTickets = List.from(_mockTickets);
          _filteredTickets = List.from(_allTickets);
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _refreshTickets() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate refresh delay
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() {
        _allTickets = List.from(_mockTickets);
        _applyFilters();
        _isRefreshing = false;
      });

      // Show refresh completion feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tickets refreshed successfully'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
    _applyFilters();
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allTickets);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((ticket) {
        final title = (ticket['title'] as String? ?? '').toLowerCase();
        final id = (ticket['id'] as String? ?? '').toLowerCase();
        final description =
            (ticket['description'] as String? ?? '').toLowerCase();

        return title.contains(_searchQuery) ||
            id.contains(_searchQuery) ||
            description.contains(_searchQuery);
      }).toList();
    }

    // Apply status filter
    if (_activeFilters['status'] != null) {
      filtered = filtered
          .where((ticket) =>
              (ticket['status'] as String? ?? '').toLowerCase() ==
              (_activeFilters['status'] as String).toLowerCase())
          .toList();
    }

    // Apply priority filter
    if (_activeFilters['priority'] != null) {
      filtered = filtered
          .where((ticket) =>
              (ticket['priority'] as String? ?? '').toLowerCase() ==
              (_activeFilters['priority'] as String).toLowerCase())
          .toList();
    }

    // Apply category filter
    if (_activeFilters['category'] != null) {
      filtered = filtered
          .where((ticket) =>
              (ticket['category'] as String? ?? '').toLowerCase() ==
              (_activeFilters['category'] as String).toLowerCase())
          .toList();
    }

    setState(() {
      _filteredTickets = filtered;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 80.h,
        child: FilterBottomSheetWidget(
          currentFilters: _activeFilters,
          onApplyFilters: (filters) {
            setState(() {
              _activeFilters = Map.from(filters);
            });
            _applyFilters();
          },
        ),
      ),
    );
  }

  void _removeFilter(String filterKey) {
    setState(() {
      _activeFilters.remove(filterKey);
    });
    _applyFilters();
  }

  int get _activeFilterCount {
    return _activeFilters.values.where((value) => value != null).length;
  }

  List<String> get _activeFilterLabels {
    List<String> labels = [];
    _activeFilters.forEach((key, value) {
      if (value != null) {
        labels.add(value.toString());
      }
    });
    return labels;
  }

  void _navigateToTicketDetails(Map<String, dynamic> ticket) {
    Navigator.pushNamed(
      context,
      '/ticket-details-screen',
      arguments: ticket,
    );
  }

  void _navigateToCreateTicket() {
    Navigator.pushNamed(context, '/create-ticket-screen');
  }

  void _editTicket(Map<String, dynamic> ticket) {
    Navigator.pushNamed(
      context,
      '/create-ticket-screen',
      arguments: {'ticket': ticket, 'isEdit': true},
    );
  }

  void _addComment(Map<String, dynamic> ticket) {
    Navigator.pushNamed(
      context,
      '/ticket-details-screen',
      arguments: {'ticket': ticket, 'openComments': true},
    );
  }

  void _changeStatus(Map<String, dynamic> ticket) {
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
            Text(
              'Change Status',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ...['Open', 'In Progress', 'Resolved', 'Closed']
                .map(
                  (status) => ListTile(
                    title: Text(status),
                    leading: Radio<String>(
                      value: status,
                      groupValue: ticket['status'],
                      onChanged: (value) {
                        Navigator.pop(context);
                        setState(() {
                          ticket['status'] = value;
                        });
                        _applyFilters();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Status updated to $value')),
                        );
                      },
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  void _deleteTicket(Map<String, dynamic> ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Ticket'),
        content: Text(
            'Are you sure you want to delete this draft ticket? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _allTickets.removeWhere((t) => t['id'] == ticket['id']);
              });
              _applyFilters();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ticket deleted successfully')),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _shareTicket(Map<String, dynamic> ticket) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ticket ${ticket['id']}')),
    );
  }

  void _setReminder(Map<String, dynamic> ticket) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder set for ticket ${ticket['id']}')),
    );
  }

  void _toggleImportant(Map<String, dynamic> ticket) {
    setState(() {
      ticket['isImportant'] = !(ticket['isImportant'] ?? false);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ticket['isImportant']
            ? 'Ticket marked as important'
            : 'Ticket removed from important'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            SearchBarWidget(
              hintText: 'Search tickets...',
              onChanged: _onSearchChanged,
              onFilterTap: _showFilterBottomSheet,
              filterCount: _activeFilterCount,
            ),

            // Filter chips
            if (_activeFilterLabels.isNotEmpty)
              Container(
                height: 6.h,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _activeFilterLabels.length,
                  itemBuilder: (context, index) {
                    final label = _activeFilterLabels[index];
                    final filterKey = _activeFilters.keys.firstWhere(
                      (key) => _activeFilters[key].toString() == label,
                    );

                    return FilterChipWidget(
                      label: label,
                      isSelected: true,
                      onTap: () {},
                      onRemove: () => _removeFilter(filterKey),
                    );
                  },
                ),
              ),

            // Tickets list
            Expanded(
              child: _isLoading
                  ? ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) =>
                          const SkeletonCardWidget(),
                    )
                  : _filteredTickets.isEmpty
                      ? EmptyStateWidget(
                          title:
                              _searchQuery.isNotEmpty || _activeFilterCount > 0
                                  ? 'No Tickets Found'
                                  : 'No Tickets Yet',
                          subtitle: _searchQuery.isNotEmpty ||
                                  _activeFilterCount > 0
                              ? 'Try adjusting your search or filters to find what you\'re looking for.'
                              : 'Create your first support ticket to get started with our IT helpdesk system.',
                          buttonText: 'Create Your First Ticket',
                          onButtonPressed: _navigateToCreateTicket,
                          illustrationUrl:
                              'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&h=300&fit=crop',
                        )
                      : RefreshIndicator(
                          onRefresh: _refreshTickets,
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _filteredTickets.length,
                            itemBuilder: (context, index) {
                              final ticket = _filteredTickets[index];

                              return TicketCardWidget(
                                ticket: ticket,
                                onTap: () => _navigateToTicketDetails(ticket),
                                onEdit: () => _editTicket(ticket),
                                onAddComment: () => _addComment(ticket),
                                onChangeStatus: () => _changeStatus(ticket),
                                onDelete:
                                    ticket['status']?.toLowerCase() == 'draft'
                                        ? () => _deleteTicket(ticket)
                                        : null,
                                onShare: () => _shareTicket(ticket),
                                onSetReminder: () => _setReminder(ticket),
                                onMarkImportant: () => _toggleImportant(ticket),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTicket,
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 7.w,
        ),
      ),
    );
  }
}
