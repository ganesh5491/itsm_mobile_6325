class UserModel {
  final int id;
  final String name;
  final String email;
  final String username;
  final String role;
  final String? department;
  final String? designation;
  final String? companyName;
  final String? contactNumber;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.role,
    this.department,
    this.designation,
    this.companyName,
    this.contactNumber,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      department: json['department'] as String?,
      designation: json['designation'] as String?,
      companyName: json['company_name'] as String?,
      contactNumber: json['contact_number'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'role': role,
      'department': department,
      'designation': designation,
      'company_name': companyName,
      'contact_number': contactNumber,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  bool get isAgent => role == 'agent' || role == 'admin';
  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? username,
    String? role,
    String? department,
    String? designation,
    String? companyName,
    String? contactNumber,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      role: role ?? this.role,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      companyName: companyName ?? this.companyName,
      contactNumber: contactNumber ?? this.contactNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role)';
  }
}
