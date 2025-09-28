class User {
  final String id;
  final String username;
  final String name;
  final String role;
  final List<String> permissions;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
    required this.permissions,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      permissions: List<String>.from(json['permissions'] ?? []),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'role': role,
      'permissions': permissions,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  bool canViewReports() {
    return hasPermission('view_reports') || role == 'admin' || role == 'manager';
  }
}
