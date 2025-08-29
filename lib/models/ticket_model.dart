class TicketModel {
  final int id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final int categoryId;
  final int? subcategoryId;
  final int createdById;
  final int? assignedToId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? dueDate;
  final String? supportType;
  final String? contactName;
  final String? contactEmail;
  final String? contactPhone;
  final String? contactDepartment;
  final String? attachmentUrl;
  final String? attachmentName;

  // Related objects (populated via joins)
  final String? categoryName;
  final String? subcategoryName;
  final String? createdByName;
  final String? assignedToName;

  const TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.categoryId,
    required this.createdById,
    this.subcategoryId,
    this.assignedToId,
    this.createdAt,
    this.updatedAt,
    this.dueDate,
    this.supportType,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    this.contactDepartment,
    this.attachmentUrl,
    this.attachmentName,
    this.categoryName,
    this.subcategoryName,
    this.createdByName,
    this.assignedToName,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      categoryId: json['category_id'] as int,
      subcategoryId: json['subcategory_id'] as int?,
      createdById: json['created_by_id'] as int,
      assignedToId: json['assigned_to_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      supportType: json['support_type'] as String?,
      contactName: json['contact_name'] as String?,
      contactEmail: json['contact_email'] as String?,
      contactPhone: json['contact_phone'] as String?,
      contactDepartment: json['contact_department'] as String?,
      attachmentUrl: json['attachment_url'] as String?,
      attachmentName: json['attachment_name'] as String?,
      categoryName: json['category_name'] as String?,
      subcategoryName: json['subcategory_name'] as String?,
      createdByName: json['created_by_name'] as String?,
      assignedToName: json['assigned_to_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'created_by_id': createdById,
      'assigned_to_id': assignedToId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'support_type': supportType,
      'contact_name': contactName,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'contact_department': contactDepartment,
      'attachment_url': attachmentUrl,
      'attachment_name': attachmentName,
    };
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'in-progress':
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  String get priorityDisplay {
    switch (priority.toLowerCase()) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return priority;
    }
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) &&
        !['resolved', 'closed'].contains(status.toLowerCase());
  }

  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;

  TicketModel copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    int? categoryId,
    int? subcategoryId,
    int? createdById,
    int? assignedToId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    String? supportType,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    String? contactDepartment,
    String? attachmentUrl,
    String? attachmentName,
    String? categoryName,
    String? subcategoryName,
    String? createdByName,
    String? assignedToName,
  }) {
    return TicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      createdById: createdById ?? this.createdById,
      assignedToId: assignedToId ?? this.assignedToId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      supportType: supportType ?? this.supportType,
      contactName: contactName ?? this.contactName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      contactDepartment: contactDepartment ?? this.contactDepartment,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentName: attachmentName ?? this.attachmentName,
      categoryName: categoryName ?? this.categoryName,
      subcategoryName: subcategoryName ?? this.subcategoryName,
      createdByName: createdByName ?? this.createdByName,
      assignedToName: assignedToName ?? this.assignedToName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TicketModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TicketModel(id: $id, title: $title, status: $status, priority: $priority)';
  }
}
