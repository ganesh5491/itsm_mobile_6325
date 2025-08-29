import '../models/user_model.dart';
import './supabase_service.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;
  bool get isAgent => _currentUser?.isAgent ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      final client = SupabaseService.instance.client;

      // Query the users table with username and password
      final response = await client
          .from('users')
          .select()
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();

      if (response != null) {
        _currentUser = UserModel.fromJson(response);
        return true;
      } else {
        return false;
      }
    } catch (error) {
      throw Exception('Login failed: $error');
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String username,
    required String password,
    String? department,
    String? designation,
    String? companyName,
    String? contactNumber,
  }) async {
    try {
      final client = SupabaseService.instance.client;

      // Check if username already exists
      final existingUser = await client
          .from('users')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      if (existingUser != null) {
        throw Exception('Username already exists');
      }

      // Create new user
      final response = await client
          .from('users')
          .insert({
            'name': name,
            'email': email,
            'username': username,
            'password': password, // Note: In production, hash this password
            'role': 'user',
            'department': department,
            'designation': designation,
            'company_name': companyName,
            'contact_number': contactNumber,
          })
          .select()
          .single();

      _currentUser = UserModel.fromJson(response);
      return true;
    } catch (error) {
      throw Exception('Registration failed: $error');
    }
  }

  Future<UserModel?> getUserById(int userId) async {
    try {
      final client = SupabaseService.instance.client;

      final response =
          await client.from('users').select().eq('id', userId).maybeSingle();

      if (response != null) {
        return UserModel.fromJson(response);
      }
      return null;
    } catch (error) {
      throw Exception('Failed to get user: $error');
    }
  }

  Future<List<UserModel>> getAgents() async {
    try {
      final client = SupabaseService.instance.client;

      final response = await client
          .from('users')
          .select()
          .inFilter('role', ['agent', 'admin']).order('name', ascending: true);

      return response.map((json) => UserModel.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get agents: $error');
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    String? department,
    String? designation,
    String? companyName,
    String? contactNumber,
  }) async {
    try {
      if (_currentUser == null) return false;

      final client = SupabaseService.instance.client;

      final response = await client
          .from('users')
          .update({
            'name': name,
            'email': email,
            'department': department,
            'designation': designation,
            'company_name': companyName,
            'contact_number': contactNumber,
          })
          .eq('id', _currentUser!.id)
          .select()
          .single();

      _currentUser = UserModel.fromJson(response);
      return true;
    } catch (error) {
      throw Exception('Profile update failed: $error');
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (_currentUser == null) return false;

      final client = SupabaseService.instance.client;

      // Verify current password
      final user = await client
          .from('users')
          .select('password')
          .eq('id', _currentUser!.id)
          .eq('password', currentPassword)
          .maybeSingle();

      if (user == null) {
        throw Exception('Current password is incorrect');
      }

      // Update password
      await client
          .from('users')
          .update({'password': newPassword}).eq('id', _currentUser!.id);

      return true;
    } catch (error) {
      throw Exception('Password change failed: $error');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  // Auto-login for demo purposes (remove in production)
  Future<bool> autoLogin() async {
    try {
      final client = SupabaseService.instance.client;

      final response = await client.from('users').select().limit(1).single();

      _currentUser = UserModel.fromJson(response);
      return true;
          return false;
    } catch (error) {
      return false;
    }
  }
}
