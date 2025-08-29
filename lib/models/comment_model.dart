class CommentModel {
  final int id;
  final String content;
  final int userId;
  final int ticketId;
  final bool isInternal;
  final DateTime? createdAt;

  // Related objects
  final String? userName;
  final String? userRole;

  const CommentModel({
    required this.id,
    required this.content,
    required this.userId,
    required this.ticketId,
    required this.isInternal,
    this.createdAt,
    this.userName,
    this.userRole,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as int,
      content: json['content'] as String,
      userId: json['user_id'] as int,
      ticketId: json['ticket_id'] as int,
      isInternal: json['is_internal'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      userName: json['user_name'] as String?,
      userRole: json['user_role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'user_id': userId,
      'ticket_id': ticketId,
      'is_internal': isInternal,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get timeAgo {
    if (createdAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  bool get isFromAgent => userRole == 'agent' || userRole == 'admin';

  CommentModel copyWith({
    int? id,
    String? content,
    int? userId,
    int? ticketId,
    bool? isInternal,
    DateTime? createdAt,
    String? userName,
    String? userRole,
  }) {
    return CommentModel(
      id: id ?? this.id,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      ticketId: ticketId ?? this.ticketId,
      isInternal: isInternal ?? this.isInternal,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CommentModel(id: $id, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content})';
  }
}
