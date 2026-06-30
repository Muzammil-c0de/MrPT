/// Roles supported by the FitPilot platform.
enum UserRole { superAdmin, branchManager }

extension UserRoleDetails on UserRole {
  String get label {
    return switch (this) {
      UserRole.superAdmin => 'Super Admin',
      UserRole.branchManager => 'Branch Manager',
    };
  }

  /// Short prefix used when generating account IDs for a role.
  String get idPrefix {
    return switch (this) {
      UserRole.superAdmin => 'ADM',
      UserRole.branchManager => 'MGR',
    };
  }
}

/// A single platform account (admin, manager, or personal trainer).
class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.password,
    this.email,
    this.active = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Generated login identifier, e.g. `ADM-0001` or `PT-0003`.
  final String id;

  String name;
  final UserRole role;
  String password;
  String? email;
  bool active;
  final DateTime createdAt;
}
