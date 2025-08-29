import '../models/comment_model.dart';
import './auth_service.dart';
import './supabase_service.dart';

class CommentService {
  static CommentService? _instance;
  static CommentService get instance => _instance ??= CommentService._();
  CommentService._();

  Future<List<CommentModel>> getTicketComments(int ticketId) async {
    try {
      final client = SupabaseService.instance.client;

      final response = await client.from('comments').select('''
            *,
            users!comments_user_id_fkey(name, role)
          ''').eq('ticket_id', ticketId).order('created_at', ascending: true);

      return response.map((json) {
        final flatJson = Map<String, dynamic>.from(json);
        if (json['users'] != null) {
          flatJson['user_name'] = json['users']['name'];
          flatJson['user_role'] = json['users']['role'];
        }
        return CommentModel.fromJson(flatJson);
      }).toList();
    } catch (error) {
      throw Exception('Failed to get comments: $error');
    }
  }

  Future<List<CommentModel>> getPublicTicketComments(int ticketId) async {
    try {
      final client = SupabaseService.instance.client;

      final response = await client
          .from('comments')
          .select('''
            *,
            users!comments_user_id_fkey(name, role)
          ''')
          .eq('ticket_id', ticketId)
          .eq('is_internal', false)
          .order('created_at', ascending: true);

      return response.map((json) {
        final flatJson = Map<String, dynamic>.from(json);
        if (json['users'] != null) {
          flatJson['user_name'] = json['users']['name'];
          flatJson['user_role'] = json['users']['role'];
        }
        return CommentModel.fromJson(flatJson);
      }).toList();
    } catch (error) {
      throw Exception('Failed to get public comments: $error');
    }
  }

  Future<CommentModel> addComment({
    required int ticketId,
    required String content,
    bool isInternal = false,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final client = SupabaseService.instance.client;

      final response = await client.from('comments').insert({
        'ticket_id': ticketId,
        'user_id': currentUser.id,
        'content': content,
        'is_internal': isInternal,
      }).select('''
            *,
            users!comments_user_id_fkey(name, role)
          ''').single();

      final flatJson = Map<String, dynamic>.from(response);
      if (response['users'] != null) {
        flatJson['user_name'] = response['users']['name'];
        flatJson['user_role'] = response['users']['role'];
      }
      return CommentModel.fromJson(flatJson);
    } catch (error) {
      throw Exception('Failed to add comment: $error');
    }
  }

  Future<bool> updateComment({
    required int commentId,
    required String content,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) return false;

      final client = SupabaseService.instance.client;

      // Only allow users to edit their own comments
      await client
          .from('comments')
          .update({'content': content})
          .eq('id', commentId)
          .eq('user_id', currentUser.id);

      return true;
    } catch (error) {
      throw Exception('Failed to update comment: $error');
    }
  }

  Future<bool> deleteComment(int commentId) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) return false;

      final client = SupabaseService.instance.client;

      // Only allow users to delete their own comments or admin/agents to delete any
      if (currentUser.isAgent) {
        await client.from('comments').delete().eq('id', commentId);
      } else {
        await client
            .from('comments')
            .delete()
            .eq('id', commentId)
            .eq('user_id', currentUser.id);
      }

      return true;
    } catch (error) {
      throw Exception('Failed to delete comment: $error');
    }
  }

  Future<int> getCommentCount(int ticketId) async {
    try {
      final client = SupabaseService.instance.client;

      final response = await client
          .from('comments')
          .select('id')
          .eq('ticket_id', ticketId)
          .count();

      return response.count ?? 0;
    } catch (error) {
      throw Exception('Failed to get comment count: $error');
    }
  }

  Future<int> getPublicCommentCount(int ticketId) async {
    try {
      final client = SupabaseService.instance.client;

      final response = await client
          .from('comments')
          .select('id')
          .eq('ticket_id', ticketId)
          .eq('is_internal', false)
          .count();

      return response.count ?? 0;
    } catch (error) {
      throw Exception('Failed to get public comment count: $error');
    }
  }

  Future<CommentModel?> getLatestComment(int ticketId) async {
    try {
      final client = SupabaseService.instance.client;

      final response = await client
          .from('comments')
          .select('''
            *,
            users!comments_user_id_fkey(name, role)
          ''')
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        final flatJson = Map<String, dynamic>.from(response);
        if (response['users'] != null) {
          flatJson['user_name'] = response['users']['name'];
          flatJson['user_role'] = response['users']['role'];
        }
        return CommentModel.fromJson(flatJson);
      }
      return null;
    } catch (error) {
      throw Exception('Failed to get latest comment: $error');
    }
  }

  // Utility method to check if user can add internal comments
  bool canAddInternalComment() {
    final currentUser = AuthService.instance.currentUser;
    return currentUser?.isAgent ?? false;
  }

  // Utility method to check if user can see internal comments
  bool canViewInternalComments() {
    final currentUser = AuthService.instance.currentUser;
    return currentUser?.isAgent ?? false;
  }
}
