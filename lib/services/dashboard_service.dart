import '../models/dashboard_stats_model.dart';
import '../models/ticket_model.dart';
import './supabase_service.dart';
import './ticket_service.dart';

class DashboardService {
  static DashboardService? _instance;
  static DashboardService get instance => _instance ??= DashboardService._();
  DashboardService._();

  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final client = SupabaseService.instance.client;

      final response =
          await client.from('dashboard_stats').select().limit(1).maybeSingle();

      if (response != null) {
        return DashboardStatsModel.fromJson(response);
      } else {
        // If dashboard_stats is empty, calculate stats from tickets table
        return await _calculateStatsFromTickets();
      }
    } catch (error) {
      throw Exception('Failed to get dashboard stats: $error');
    }
  }

  Future<DashboardStatsModel> _calculateStatsFromTickets() async {
    try {
      final client = SupabaseService.instance.client;

      // Get count for each status
      final openCount = await client
          .from('tickets')
          .select('id')
          .eq('status', 'open')
          .count();

      final inProgressCount = await client
          .from('tickets')
          .select('id')
          .eq('status', 'in-progress')
          .count();

      final resolvedCount = await client
          .from('tickets')
          .select('id')
          .eq('status', 'resolved')
          .count();

      final closedCount = await client
          .from('tickets')
          .select('id')
          .eq('status', 'closed')
          .count();

      return DashboardStatsModel(
        openTickets: openCount.count ?? 0,
        inProgressTickets: inProgressCount.count ?? 0,
        resolvedTickets: resolvedCount.count ?? 0,
        closedTickets: closedCount.count ?? 0,
        avgResolutionHours:
            null, // Complex calculation, can be implemented later
      );
    } catch (error) {
      throw Exception('Failed to calculate stats from tickets: $error');
    }
  }

  Future<List<TicketModel>> getRecentActivity({int limit = 10}) async {
    return TicketService.instance.getRecentTickets(limit: limit);
  }

  Future<List<Map<String, dynamic>>> getTicketsByPriority() async {
    try {
      final client = SupabaseService.instance.client;

      final priorities = ['low', 'medium', 'high', 'urgent'];
      final results = <Map<String, dynamic>>[];

      for (String priority in priorities) {
        final response = await client
            .from('tickets')
            .select('id')
            .eq('priority', priority)
            .count();

        results.add({
          'priority': priority,
          'count': response.count ?? 0,
        });
      }

      return results;
    } catch (error) {
      throw Exception('Failed to get tickets by priority: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getTicketsByCategory() async {
    try {
      final client = SupabaseService.instance.client;

      final response = await client.from('tickets').select('''
            category_id,
            categories!tickets_category_id_fkey(name)
          ''');

      // Group tickets by category
      final categoryMap = <int, Map<String, dynamic>>{};

      for (var ticket in response) {
        final categoryId = ticket['category_id'] as int;
        final categoryName = ticket['categories']?['name'] ?? 'Unknown';

        if (categoryMap.containsKey(categoryId)) {
          categoryMap[categoryId]!['count'] =
              categoryMap[categoryId]!['count'] + 1;
        } else {
          categoryMap[categoryId] = {
            'category_id': categoryId,
            'category_name': categoryName,
            'count': 1,
          };
        }
      }

      return categoryMap.values.toList()
        ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    } catch (error) {
      throw Exception('Failed to get tickets by category: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getWeeklyTicketTrend() async {
    try {
      final client = SupabaseService.instance.client;
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      final response = await client
          .from('tickets')
          .select('created_at')
          .gte('created_at', weekAgo.toIso8601String())
          .order('created_at', ascending: true);

      // Group tickets by day
      final dayMap = <String, int>{};

      // Initialize all days of the week with 0
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dayKey = _getDayKey(date);
        dayMap[dayKey] = 0;
      }

      // Count tickets for each day
      for (var ticket in response) {
        final createdAt = DateTime.parse(ticket['created_at']);
        final dayKey = _getDayKey(createdAt);
        dayMap[dayKey] = (dayMap[dayKey] ?? 0) + 1;
      }

      return dayMap.entries
          .map((entry) => {
                'day': entry.key,
                'value': entry.value,
              })
          .toList();
    } catch (error) {
      throw Exception('Failed to get weekly ticket trend: $error');
    }
  }

  String _getDayKey(DateTime date) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  Future<Map<String, dynamic>> getAgentPerformance() async {
    try {
      final client = SupabaseService.instance.client;

      final response = await client.from('tickets').select('''
            assigned_to_id,
            status,
            users!tickets_assigned_to_id_fkey(name, role)
          ''').not('assigned_to_id', 'is', null);

      // Group tickets by agent
      final agentMap = <int, Map<String, dynamic>>{};

      for (var ticket in response) {
        final agentId = ticket['assigned_to_id'] as int;
        final agentName = ticket['users']?['name'] ?? 'Unknown';
        final status = ticket['status'] as String;

        if (!agentMap.containsKey(agentId)) {
          agentMap[agentId] = {
            'agent_id': agentId,
            'agent_name': agentName,
            'total_tickets': 0,
            'resolved_tickets': 0,
            'open_tickets': 0,
          };
        }

        agentMap[agentId]!['total_tickets'] =
            agentMap[agentId]!['total_tickets'] + 1;

        if (status == 'resolved' || status == 'closed') {
          agentMap[agentId]!['resolved_tickets'] =
              agentMap[agentId]!['resolved_tickets'] + 1;
        } else if (status == 'open' || status == 'in-progress') {
          agentMap[agentId]!['open_tickets'] =
              agentMap[agentId]!['open_tickets'] + 1;
        }
      }

      // Calculate resolution rate for each agent
      for (var agent in agentMap.values) {
        final totalTickets = agent['total_tickets'] as int;
        final resolvedTickets = agent['resolved_tickets'] as int;
        agent['resolution_rate'] = totalTickets > 0
            ? (resolvedTickets / totalTickets * 100).toStringAsFixed(1)
            : '0.0';
      }

      final agents = agentMap.values.toList()
        ..sort((a, b) =>
            (b['total_tickets'] as int).compareTo(a['total_tickets'] as int));

      return {
        'agents': agents,
        'total_agents': agents.length,
      };
    } catch (error) {
      throw Exception('Failed to get agent performance: $error');
    }
  }

  Future<void> refreshDashboardStats() async {
    // This could be used to manually refresh the dashboard_stats view/table
    // For now, we'll just recalculate from the tickets table
    try {
      final stats = await _calculateStatsFromTickets();
      // In a real implementation, you might want to store this in the dashboard_stats table
    } catch (error) {
      throw Exception('Failed to refresh dashboard stats: $error');
    }
  }
}
