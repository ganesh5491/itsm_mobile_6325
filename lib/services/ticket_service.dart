import '../models/ticket_model.dart';
import './auth_service.dart';
import './supabase_service.dart';

class TicketService {
  static TicketService? _instance;
  static TicketService get instance => _instance ??= TicketService._();
  TicketService._();

  Future<List<TicketModel>> getAllTickets({
    String? status,
    String? priority,
    int? assignedToId,
    String? searchQuery,
    int limit = 100,
  }) async {
    try {
      final client = SupabaseService.instance.client;

      var query = client.from('tickets').select('''
            *,
            categories!tickets_category_id_fkey(name),
            subcategories:categories!tickets_subcategory_id_fkey(name),
            created_by:users!tickets_created_by_id_fkey(name),
            assigned_to:users!tickets_assigned_to_id_fkey(name)
          ''');

      // Apply filters
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      if (priority != null && priority.isNotEmpty) {
        query = query.eq('priority', priority);
      }

      if (assignedToId != null) {
        query = query.eq('assigned_to_id', assignedToId);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query
            .or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      final response =
          await query.order('created_at', ascending: false).limit(limit);

      return response.map((json) {
        // Flatten the nested structure
        final flatJson = Map<String, dynamic>.from(json);
        if (json['categories'] != null) {
          flatJson['category_name'] = json['categories']['name'];
        }
        if (json['subcategories'] != null) {
          flatJson['subcategory_name'] = json['subcategories']['name'];
        }
        if (json['created_by'] != null) {
          flatJson['created_by_name'] = json['created_by']['name'];
        }
        if (json['assigned_to'] != null) {
          flatJson['assigned_to_name'] = json['assigned_to']['name'];
        }
        return TicketModel.fromJson(flatJson);
      }).toList();
    } catch (error) {
      throw Exception('Failed to get tickets: $error');
    }
  }

  Future<List<TicketModel>> getMyTickets({
    String? status,
    String? priority,
  }) async {
    final currentUser = AuthService.instance.currentUser;
    if (currentUser == null) return [];

    if (currentUser.isAgent) {
      // For agents, get assigned tickets
      return getAllTickets(
        assignedToId: currentUser.id,
        status: status,
        priority: priority,
      );
    } else {
      // For users, get created tickets
      try {
        final client = SupabaseService.instance.client;

        var query = client.from('tickets').select('''
              *,
              categories!tickets_category_id_fkey(name),
              subcategories:categories!tickets_subcategory_id_fkey(name),
              created_by:users!tickets_created_by_id_fkey(name),
              assigned_to:users!tickets_assigned_to_id_fkey(name)
            ''').eq('created_by_id', currentUser.id);

        if (status != null && status.isNotEmpty) {
          query = query.eq('status', status);
        }

        if (priority != null && priority.isNotEmpty) {
          query = query.eq('priority', priority);
        }

        final response = await query.order('created_at', ascending: false);

        return response.map((json) {
          final flatJson = Map<String, dynamic>.from(json);
          if (json['categories'] != null) {
            flatJson['category_name'] = json['categories']['name'];
          }
          if (json['subcategories'] != null) {
            flatJson['subcategory_name'] = json['subcategories']['name'];
          }
          if (json['created_by'] != null) {
            flatJson['created_by_name'] = json['created_by']['name'];
          }
          if (json['assigned_to'] != null) {
            flatJson['assigned_to_name'] = json['assigned_to']['name'];
          }
          return TicketModel.fromJson(flatJson);
        }).toList();
      } catch (error) {
        throw Exception('Failed to get my tickets: $error');
      }
    }
  }

  Future<TicketModel?> getTicketById(int ticketId) async {
    try {
      final client = SupabaseService.instance.client;

      final response = await client.from('tickets').select('''
            *,
            categories!tickets_category_id_fkey(name),
            subcategories:categories!tickets_subcategory_id_fkey(name),
            created_by:users!tickets_created_by_id_fkey(name),
            assigned_to:users!tickets_assigned_to_id_fkey(name)
          ''').eq('id', ticketId).maybeSingle();

      if (response != null) {
        final flatJson = Map<String, dynamic>.from(response);
        if (response['categories'] != null) {
          flatJson['category_name'] = response['categories']['name'];
        }
        if (response['subcategories'] != null) {
          flatJson['subcategory_name'] = response['subcategories']['name'];
        }
        if (response['created_by'] != null) {
          flatJson['created_by_name'] = response['created_by']['name'];
        }
        if (response['assigned_to'] != null) {
          flatJson['assigned_to_name'] = response['assigned_to']['name'];
        }
        return TicketModel.fromJson(flatJson);
      }
      return null;
    } catch (error) {
      throw Exception('Failed to get ticket: $error');
    }
  }

  Future<TicketModel> createTicket({
    required String title,
    required String description,
    required int categoryId,
    int? subcategoryId,
    String priority = 'medium',
    String supportType = 'remote',
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    String? contactDepartment,
    DateTime? dueDate,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final client = SupabaseService.instance.client;

      final response = await client.from('tickets').insert({
        'title': title,
        'description': description,
        'category_id': categoryId,
        'subcategory_id': subcategoryId,
        'priority': priority,
        'support_type': supportType,
        'contact_name': contactName,
        'contact_email': contactEmail,
        'contact_phone': contactPhone,
        'contact_department': contactDepartment,
        'due_date': dueDate?.toIso8601String(),
        'created_by_id': currentUser.id,
        'status': 'open',
      }).select('''
            *,
            categories!tickets_category_id_fkey(name),
            subcategories:categories!tickets_subcategory_id_fkey(name),
            created_by:users!tickets_created_by_id_fkey(name),
            assigned_to:users!tickets_assigned_to_id_fkey(name)
          ''').single();

      final flatJson = Map<String, dynamic>.from(response);
      if (response['categories'] != null) {
        flatJson['category_name'] = response['categories']['name'];
      }
      if (response['subcategories'] != null) {
        flatJson['subcategory_name'] = response['subcategories']['name'];
      }
      if (response['created_by'] != null) {
        flatJson['created_by_name'] = response['created_by']['name'];
      }
      if (response['assigned_to'] != null) {
        flatJson['assigned_to_name'] = response['assigned_to']['name'];
      }
      return TicketModel.fromJson(flatJson);
    } catch (error) {
      throw Exception('Failed to create ticket: $error');
    }
  }

  Future<bool> updateTicketStatus({
    required int ticketId,
    required String status,
  }) async {
    try {
      final client = SupabaseService.instance.client;

      await client.from('tickets').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', ticketId);

      return true;
    } catch (error) {
      throw Exception('Failed to update ticket status: $error');
    }
  }

  Future<bool> assignTicket({
    required int ticketId,
    required int assignedToId,
  }) async {
    try {
      final client = SupabaseService.instance.client;

      await client.from('tickets').update({
        'assigned_to_id': assignedToId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', ticketId);

      return true;
    } catch (error) {
      throw Exception('Failed to assign ticket: $error');
    }
  }

  Future<bool> updateTicketPriority({
    required int ticketId,
    required String priority,
  }) async {
    try {
      final client = SupabaseService.instance.client;

      await client.from('tickets').update({
        'priority': priority,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', ticketId);

      return true;
    } catch (error) {
      throw Exception('Failed to update ticket priority: $error');
    }
  }

  Future<List<TicketModel>> getRecentTickets({int limit = 10}) async {
    return getAllTickets(limit: limit);
  }

  Future<int> getTicketCount({String? status}) async {
    try {
      final client = SupabaseService.instance.client;

      var query = client.from('tickets').select('id');

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      final response = await query.count();
      return response.count ?? 0;
    } catch (error) {
      throw Exception('Failed to get ticket count: $error');
    }
  }
}
