import '../models/category_model.dart';
import './supabase_service.dart';

class CategoryService {
  static CategoryService? _instance;
  static CategoryService get instance => _instance ??= CategoryService._();
  CategoryService._();

  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final client = SupabaseService.instance.client;

      final response = await client.from('categories').select('''
            *,
            parent:categories!categories_parent_id_fkey(name)
          ''').order('name', ascending: true);

      return response.map((json) {
        final flatJson = Map<String, dynamic>.from(json);
        if (json['parent'] != null) {
          flatJson['parent_name'] = json['parent']['name'];
        }
        return CategoryModel.fromJson(flatJson);
      }).toList();
    } catch (error) {
      throw Exception('Failed to get categories: $error');
    }
  }

  Future<List<CategoryModel>> getParentCategories() async {
    try {
      final client = SupabaseService.instance.client;

      final response = await client
          .from('categories')
          .select()
          .isFilter('parent_id', null)
          .order('name', ascending: true);

      return response.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get parent categories: $error');
    }
  }

  Future<List<CategoryModel>> getSubcategories(int parentId) async {
    try {
      final client = SupabaseService.instance.client;

      final response = await client.from('categories').select('''
            *,
            parent:categories!categories_parent_id_fkey(name)
          ''').eq('parent_id', parentId).order('name', ascending: true);

      return response.map((json) {
        final flatJson = Map<String, dynamic>.from(json);
        if (json['parent'] != null) {
          flatJson['parent_name'] = json['parent']['name'];
        }
        return CategoryModel.fromJson(flatJson);
      }).toList();
    } catch (error) {
      throw Exception('Failed to get subcategories: $error');
    }
  }

  Future<List<CategoryModel>> getCategoriesWithSubcategories() async {
    try {
      final allCategories = await getAllCategories();
      final parentCategories =
          allCategories.where((c) => c.isParentCategory).toList();

      // Group subcategories under their parents
      for (var parent in parentCategories) {
        final subcategories =
            allCategories.where((c) => c.parentId == parent.id).toList();

        parent = parent.copyWith(subcategories: subcategories);
      }

      return parentCategories;
    } catch (error) {
      throw Exception('Failed to get categories with subcategories: $error');
    }
  }

  Future<CategoryModel?> getCategoryById(int categoryId) async {
    try {
      final client = SupabaseService.instance.client;

      final response = await client.from('categories').select('''
            *,
            parent:categories!categories_parent_id_fkey(name)
          ''').eq('id', categoryId).maybeSingle();

      if (response != null) {
        final flatJson = Map<String, dynamic>.from(response);
        if (response['parent'] != null) {
          flatJson['parent_name'] = response['parent']['name'];
        }
        return CategoryModel.fromJson(flatJson);
      }
      return null;
    } catch (error) {
      throw Exception('Failed to get category: $error');
    }
  }

  Future<CategoryModel> createCategory({
    required String name,
    int? parentId,
  }) async {
    try {
      final client = SupabaseService.instance.client;

      final response = await client.from('categories').insert({
        'name': name,
        'parent_id': parentId,
      }).select('''
            *,
            parent:categories!categories_parent_id_fkey(name)
          ''').single();

      final flatJson = Map<String, dynamic>.from(response);
      if (response['parent'] != null) {
        flatJson['parent_name'] = response['parent']['name'];
      }
      return CategoryModel.fromJson(flatJson);
    } catch (error) {
      throw Exception('Failed to create category: $error');
    }
  }

  Future<bool> updateCategory({
    required int categoryId,
    required String name,
    int? parentId,
  }) async {
    try {
      final client = SupabaseService.instance.client;

      await client.from('categories').update({
        'name': name,
        'parent_id': parentId,
      }).eq('id', categoryId);

      return true;
    } catch (error) {
      throw Exception('Failed to update category: $error');
    }
  }

  Future<bool> deleteCategory(int categoryId) async {
    try {
      final client = SupabaseService.instance.client;

      // Check if category has tickets
      final ticketCount = await client
          .from('tickets')
          .select('id')
          .or('category_id.eq.$categoryId,subcategory_id.eq.$categoryId')
          .count();

      if (ticketCount.count > 0) {
        throw Exception('Cannot delete category that has tickets');
      }

      // Check if category has subcategories
      final subcategoryCount = await client
          .from('categories')
          .select('id')
          .eq('parent_id', categoryId)
          .count();

      if (subcategoryCount.count > 0) {
        throw Exception('Cannot delete category that has subcategories');
      }

      await client.from('categories').delete().eq('id', categoryId);

      return true;
    } catch (error) {
      throw Exception('Failed to delete category: $error');
    }
  }

  // Utility methods for UI
  List<CategoryModel> filterCategoriesForSelection(
      List<CategoryModel> categories,
      {bool includeSubcategories = true}) {
    if (includeSubcategories) return categories;
    return categories.where((c) => c.isParentCategory).toList();
  }

  String getCategoryDisplayName(CategoryModel category) {
    if (category.parentName != null) {
      return '${category.parentName} > ${category.name}';
    }
    return category.name;
  }
}
