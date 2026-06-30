/// Roles supported by the FitPilot platform.
///
/// [branchManager] is wired into the model now so the permission system is
/// future-ready, even though only [superAdmin] and [personalTrainer] are
/// provisioned today.
enum UserRole { superAdmin, branchManager, personalTrainer }

extension UserRoleDetails on UserRole {
  String get label {
    return switch (this) {
      UserRole.superAdmin => 'Super Admin',
      UserRole.branchManager => 'Branch Manager',
      UserRole.personalTrainer => 'Personal Trainer',
    };
  }

  /// Short prefix used when generating account IDs for a role.
  String get idPrefix {
    return switch (this) {
      UserRole.superAdmin => 'ADM',
      UserRole.branchManager => 'MGR',
      UserRole.personalTrainer => 'PT',
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
