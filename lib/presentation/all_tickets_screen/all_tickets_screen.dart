import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/bulk_action_bar_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/sort_bottom_sheet_widget.dart';
import './widgets/ticket_card_widget.dart';

class AllTicketsScreen extends StatefulWidget {
  const AllTicketsScreen({Key? key}) : super(key: key);

  @override
  State<AllTicketsScreen> createState() => _AllTicketsScreenState();
}

class _AllTicketsScreenState extends State<AllTicketsScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // State variables
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};
  String _sortBy = 'lastUpdated';
  bool _isAscending = false;
  bool _isMultiSelectMode = false;
  Set<String> _selectedTickets = {};
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  final int _itemsPerPage = 20;

  // Mock data
  final List<Map<String, dynamic>> _allTickets = [
    {
      'id': 'TKT-001',
      'title': 'Unable to access company email on mobile device',
      'status': 'Open',
      'priority': 'High',
      'category': 'Account Access',
      'assignee': {
        'id': '1',
        'name': 'John Smith',
        'avatar':
            'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
      },
      'customer': 'Alice Johnson',
      'createdDate': DateTime.now().subtract(const Duration(hours: 2)),
      'lastUpdated': DateTime.now().subtract(const Duration(minutes: 30)),
      'description':
          'User reports being unable to access company email on their mobile device after recent password change.',
    },
    {
      'id': 'TKT-002',
      'title': 'Printer not responding in Marketing department',
      'status': 'In Progress',
      'priority': 'Medium',
      'category': 'Hardware',
      'assignee': {
        'id': '2',
        'name': 'Sarah Johnson',
        'avatar':
            'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
      },
      'customer': 'Bob Wilson',
      'createdDate': DateTime.now().subtract(const Duration(hours: 5)),
      'lastUpdated': DateTime.now().subtract(const Duration(hours: 1)),
      'description':
          'Marketing team printer is not responding to print jobs. Status light shows error.',
    },
    {
      'id': 'TKT-003',
      'title': 'Software installation request for Adobe Creative Suite',
      'status': 'Resolved',
      'priority': 'Low',
      'category': 'Software',
      'assignee': {
        'id': '3',
        'name': 'Mike Davis',
        'avatar':
            'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
      },
      'customer': 'Carol Brown',
      'createdDate': DateTime.now().subtract(const Duration(days: 1)),
      'lastUpdated': DateTime.now().subtract(const Duration(hours: 3)),
      'description':
          'Request for Adobe Creative Suite installation for new graphic designer.',
    },
    {
      'id': 'TKT-004',
      'title': 'Network connectivity issues in Conference Room B',
      'status': 'Open',
      'priority': 'Critical',
      'category': 'Network',
      'assignee': null,
      'customer': 'David Lee',
      'createdDate': DateTime.now().subtract(const Duration(hours: 8)),
      'lastUpdated': DateTime.now().subtract(const Duration(hours: 6)),
      'description':
          'Conference Room B has no network connectivity affecting important client meetings.',
    },
    {
      'id': 'TKT-005',
      'title': 'Password reset for multiple user accounts',
      'status': 'On Hold',
      'priority': 'Medium',
      'category': 'Security',
      'assignee': {
        'id': '4',
        'name': 'Emily Brown',
        'avatar':
            'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
      },
      'customer': 'Frank Miller',
      'createdDate': DateTime.now().subtract(const Duration(days: 2)),
      'lastUpdated': DateTime.now().subtract(const Duration(days: 1)),
      'description':
          'Multiple users need password resets due to security policy update.',
    },
    {
      'id': 'TKT-006',
      'title': 'VPN connection failing for remote workers',
      'status': 'In Progress',
      'priority': 'High',
      'category': 'Network',
      'assignee': {
        'id': '1',
        'name': 'John Smith',
        'avatar':
            'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
      },
      'customer': 'Grace Taylor',
      'createdDate': DateTime.now().subtract(const Duration(hours: 12)),
      'lastUpdated': DateTime.now().subtract(const Duration(hours: 2)),
      'description':
          'Remote workers unable to connect to VPN, affecting productivity.',
    },
    {
      'id': 'TKT-007',
      'title': 'Database backup verification needed',
      'status': 'Closed',
      'priority': 'Low',
      'category': 'Software',
      'assignee': {
        'id': '2',
        'name': 'Sarah Johnson',
        'avatar':
            'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
      },
      'customer': 'Henry Wilson',
      'createdDate': DateTime.now().subtract(const Duration(days: 3)),
      'lastUpdated': DateTime.now().subtract(const Duration(days: 2)),
      'description':
          'Monthly database backup verification and integrity check completed.',
    },
    {
      'id': 'TKT-008',
      'title': 'New employee laptop setup and configuration',
      'status': 'Open',
      'priority': 'Medium',
      'category': 'Hardware',
      'assignee': null,
      'customer': 'Ivy Chen',
      'createdDate': DateTime.now().subtract(const Duration(hours: 4)),
      'lastUpdated': DateTime.now().subtract(const Duration(hours: 4)),
      'description':
          'Setup laptop for new employee starting next week with standard software package.',
    },
  ];

  List<Map<String, dynamic>> _filteredTickets = [];

  @override
  void initState() {
    super.initState();
    _filteredTickets = List.from(_allTickets);
    _scrollController.addListener(_onScroll);
    _applyFiltersAndSort();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreTickets();
    }
  }

  void _loadMoreTickets() {
    if (!_isLoadingMore &&
        _filteredTickets.length >= _currentPage * _itemsPerPage) {
      setState(() {
        _isLoadingMore = true;
        _currentPage++;
      });

      // Simulate loading delay
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isLoadingMore = false;
        });
      });
    }
  }

  void _applyFiltersAndSort() {
    setState(() {
      _isLoading = true;
    });

    List<Map<String, dynamic>> filtered = List.from(_allTickets);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((ticket) {
        final title = (ticket['title'] as String? ?? '').toLowerCase();
        final id = (ticket['id'] as String? ?? '').toLowerCase();
        final description =
            (ticket['description'] as String? ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) ||
            id.contains(query) ||
            description.contains(query);
      }).toList();
    }

    // Apply status filter
    if (_activeFilters['status'] != null &&
        (_activeFilters['status'] as List).isNotEmpty) {
      filtered = filtered.where((ticket) {
        return (_activeFilters['status'] as List).contains(ticket['status']);
      }).toList();
    }

    // Apply priority filter
    if (_activeFilters['priority'] != null &&
        (_activeFilters['priority'] as List).isNotEmpty) {
      filtered = filtered.where((ticket) {
        return (_activeFilters['priority'] as List)
            .contains(ticket['priority']);
      }).toList();
    }

    // Apply category filter
    if (_activeFilters['category'] != null &&
        (_activeFilters['category'] as List).isNotEmpty) {
      filtered = filtered.where((ticket) {
        return (_activeFilters['category'] as List)
            .contains(ticket['category']);
      }).toList();
    }

    // Apply assignee filter
    if (_activeFilters['assignees'] != null &&
        (_activeFilters['assignees'] as List).isNotEmpty) {
      filtered = filtered.where((ticket) {
        final assigneeIds = _activeFilters['assignees'] as List<String>;
        if (assigneeIds.contains('unassigned')) {
          return ticket['assignee'] == null ||
              assigneeIds.contains(ticket['assignee']?['id']);
        }
        return ticket['assignee'] != null &&
            assigneeIds.contains(ticket['assignee']['id']);
      }).toList();
    }

    // Apply date range filter
    if (_activeFilters['dateRange'] != null) {
      final dateRange = _activeFilters['dateRange'] as DateTimeRange;
      filtered = filtered.where((ticket) {
        final createdDate = ticket['createdDate'] as DateTime;
        return createdDate
                .isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
            createdDate.isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      dynamic aValue, bValue;

      switch (_sortBy) {
        case 'createdDate':
          aValue = a['createdDate'] as DateTime;
          bValue = b['createdDate'] as DateTime;
          break;
        case 'lastUpdated':
          aValue = a['lastUpdated'] as DateTime;
          bValue = b['lastUpdated'] as DateTime;
          break;
        case 'priority':
          final priorityOrder = {
            'Low': 1,
            'Medium': 2,
            'High': 3,
            'Critical': 4
          };
          aValue = priorityOrder[a['priority']] ?? 0;
          bValue = priorityOrder[b['priority']] ?? 0;
          break;
        case 'status':
          aValue = a['status'] as String;
          bValue = b['status'] as String;
          break;
        case 'title':
          aValue = a['title'] as String;
          bValue = b['title'] as String;
          break;
        default:
          aValue = a['lastUpdated'] as DateTime;
          bValue = b['lastUpdated'] as DateTime;
      }

      int comparison;
      if (aValue is DateTime && bValue is DateTime) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is int && bValue is int) {
        comparison = aValue.compareTo(bValue);
      } else {
        comparison = aValue.toString().compareTo(bValue.toString());
      }

      return _isAscending ? comparison : -comparison;
    });

    setState(() {
      _filteredTickets = filtered;
      _isLoading = false;
      _currentPage = 1;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFiltersAndSort();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _activeFilters,
        onApplyFilters: (filters) {
          setState(() {
            _activeFilters = filters;
          });
          _applyFiltersAndSort();
        },
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SortBottomSheetWidget(
        currentSortBy: _sortBy,
        isAscending: _isAscending,
        onApplySort: (sortBy, isAscending) {
          setState(() {
            _sortBy = sortBy;
            _isAscending = isAscending;
          });
          _applyFiltersAndSort();
        },
      ),
    );
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedTickets.clear();
      }
    });
  }

  void _onTicketTap(Map<String, dynamic> ticket) {
    if (_isMultiSelectMode) {
      _toggleTicketSelection(ticket['id'] as String);
    } else {
      Navigator.pushNamed(
        context,
        '/ticket-details-screen',
        arguments: ticket,
      );
    }
  }

  void _onTicketLongPress(Map<String, dynamic> ticket) {
    if (!_isMultiSelectMode) {
      _toggleMultiSelectMode();
    }
    _toggleTicketSelection(ticket['id'] as String);
  }

  void _toggleTicketSelection(String ticketId) {
    setState(() {
      if (_selectedTickets.contains(ticketId)) {
        _selectedTickets.remove(ticketId);
      } else {
        _selectedTickets.add(ticketId);
      }

      if (_selectedTickets.isEmpty) {
        _isMultiSelectMode = false;
      }
    });
  }

  void _handleBulkAssign() {
    // Show assign dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Tickets'),
        content: Text(
            'Assign ${_selectedTickets.length} selected tickets to an agent?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${_selectedTickets.length} tickets assigned successfully'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                ),
              );
              _toggleMultiSelectMode();
            },
            child: Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _handleBulkStatusUpdate() {
    // Show status update dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Status'),
        content: Text(
            'Update status for ${_selectedTickets.length} selected tickets?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${_selectedTickets.length} tickets updated successfully'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                ),
              );
              _toggleMultiSelectMode();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _handleBulkExport() {
    // Handle export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting ${_selectedTickets.length} tickets...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
    _toggleMultiSelectMode();
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters.clear();
      _searchQuery = '';
      _searchController.clear();
    });
    _applyFiltersAndSort();
  }

  List<String> _getActiveFilterLabels() {
    List<String> labels = [];

    if (_activeFilters['status'] != null &&
        (_activeFilters['status'] as List).isNotEmpty) {
      labels.add('Status (${(_activeFilters['status'] as List).length})');
    }
    if (_activeFilters['priority'] != null &&
        (_activeFilters['priority'] as List).isNotEmpty) {
      labels.add('Priority (${(_activeFilters['priority'] as List).length})');
    }
    if (_activeFilters['category'] != null &&
        (_activeFilters['category'] as List).isNotEmpty) {
      labels.add('Category (${(_activeFilters['category'] as List).length})');
    }
    if (_activeFilters['assignees'] != null &&
        (_activeFilters['assignees'] as List).isNotEmpty) {
      labels.add('Assignee (${(_activeFilters['assignees'] as List).length})');
    }
    if (_activeFilters['dateRange'] != null) {
      labels.add('Date Range');
    }

    return labels;
  }

  Widget _buildTicketsList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    }

    if (_filteredTickets.isEmpty) {
      return EmptyStateWidget(
        title: _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
            ? 'No tickets found'
            : 'No tickets available',
        subtitle: _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
            ? 'Try adjusting your search or filters to find what you\'re looking for.'
            : 'There are no tickets in the system at the moment.',
        actionText: _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
            ? 'Clear Filters'
            : null,
        onActionPressed: _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
            ? _clearAllFilters
            : null,
        iconName: _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
            ? 'search_off'
            : 'inbox',
      );
    }

    final displayTickets =
        _filteredTickets.take(_currentPage * _itemsPerPage).toList();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        _applyFiltersAndSort();
      },
      color: AppTheme.lightTheme.colorScheme.primary,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: displayTickets.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= displayTickets.length) {
            return Container(
              padding: EdgeInsets.all(4.w),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            );
          }

          final ticket = displayTickets[index];
          final ticketId = ticket['id'] as String;
          final isSelected = _selectedTickets.contains(ticketId);

          return Slidable(
            key: ValueKey(ticketId),
            enabled: !_isMultiSelectMode,
            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Assigning ticket ${ticket['id']}...'),
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.primary,
                      ),
                    );
                  },
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
                  icon: Icons.person_add,
                  label: 'Assign',
                ),
              ],
            ),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Updating status for ticket ${ticket['id']}...'),
                        backgroundColor: const Color(0xFFF57C00),
                      ),
                    );
                  },
                  backgroundColor: const Color(0xFFF57C00),
                  foregroundColor: Colors.white,
                  icon: Icons.update,
                  label: 'Status',
                ),
              ],
            ),
            child: TicketCardWidget(
              ticket: ticket,
              isSelected: isSelected,
              isMultiSelectMode: _isMultiSelectMode,
              onTap: () => _onTicketTap(ticket),
              onLongPress: () => _onTicketLongPress(ticket),
              onSelectionChanged: (selected) {
                if (selected == true) {
                  _selectedTickets.add(ticketId);
                } else {
                  _selectedTickets.remove(ticketId);
                }
                setState(() {
                  if (_selectedTickets.isEmpty) {
                    _isMultiSelectMode = false;
                  }
                });
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeFilterLabels = _getActiveFilterLabels();

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'All Tickets',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        foregroundColor: AppTheme.lightTheme.appBarTheme.foregroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        actions: [
          if (_isMultiSelectMode)
            TextButton(
              onPressed: _toggleMultiSelectMode,
              child: Text(
                'Cancel',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.appBarTheme.foregroundColor,
                ),
              ),
            )
          else
            PopupMenuButton<String>(
              icon: CustomIconWidget(
                iconName: 'more_vert',
                size: 6.w,
                color: AppTheme.lightTheme.appBarTheme.foregroundColor,
              ),
              onSelected: (value) {
                switch (value) {
                  case 'multi_select':
                    _toggleMultiSelectMode();
                    break;
                  case 'refresh':
                    _applyFiltersAndSort();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'multi_select',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'checklist',
                        size: 5.w,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                      SizedBox(width: 3.w),
                      Text('Multi Select'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'refresh',
                        size: 5.w,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                      SizedBox(width: 3.w),
                      Text('Refresh'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          SearchBarWidget(
            hintText: 'Search tickets by ID, title, or description...',
            onChanged: _onSearchChanged,
            onFilterTap: _showFilterBottomSheet,
            onSortTap: _showSortBottomSheet,
            searchQuery: _searchQuery,
          ),

          // Active filter chips
          if (activeFilterLabels.isNotEmpty)
            Container(
              height: 6.h,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: activeFilterLabels.length + 1,
                itemBuilder: (context, index) {
                  if (index == activeFilterLabels.length) {
                    return FilterChipWidget(
                      label: 'Clear All',
                      isSelected: false,
                      onTap: _clearAllFilters,
                    );
                  }
                  return FilterChipWidget(
                    label: activeFilterLabels[index],
                    isSelected: true,
                    onTap: _showFilterBottomSheet,
                  );
                },
              ),
            ),

          // Tickets list
          Expanded(
            child: _buildTicketsList(),
          ),
        ],
      ),
      bottomNavigationBar: _isMultiSelectMode && _selectedTickets.isNotEmpty
          ? BulkActionBarWidget(
              selectedCount: _selectedTickets.length,
              onAssign: _handleBulkAssign,
              onUpdateStatus: _handleBulkStatusUpdate,
              onExport: _handleBulkExport,
              onCancel: _toggleMultiSelectMode,
            )
          : null,
      floatingActionButton: !_isMultiSelectMode
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create-ticket-screen');
              },
              child: CustomIconWidget(
                iconName: 'add',
                size: 7.w,
                color: AppTheme
                    .lightTheme.floatingActionButtonTheme.foregroundColor,
              ),
            )
          : null,
    );
  }
}
