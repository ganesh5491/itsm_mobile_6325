class CategoryModel {
  final int id;
  final String name;
  final int? parentId;
  final String? parentName;
  final List<CategoryModel>? subcategories;

  const CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    this.parentName,
    this.subcategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      parentId: json['parent_id'] as int?,
      parentName: json['parent_name'] as String?,
      subcategories: json['subcategories'] != null
          ? (json['subcategories'] as List)
              .map((sub) => CategoryModel.fromJson(sub))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'parent_name': parentName,
      'subcategories': subcategories?.map((sub) => sub.toJson()).toList(),
    };
  }

  bool get isParentCategory => parentId == null;
  bool get isSubcategory => parentId != null;
  bool get hasSubcategories =>
      subcategories != null && subcategories!.isNotEmpty;

  CategoryModel copyWith({
    int? id,
    String? name,
    int? parentId,
    String? parentName,
    List<CategoryModel>? subcategories,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      subcategories: subcategories ?? this.subcategories,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, parentId: $parentId)';
  }
}
