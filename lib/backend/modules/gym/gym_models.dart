import 'package:flutter/material.dart';

/// Lifecycle state of a gym member.
enum MemberStatus { active, expired, frozen }

extension MemberStatusDetails on MemberStatus {
  String get label => switch (this) {
    MemberStatus.active => 'Active',
    MemberStatus.expired => 'Expired',
    MemberStatus.frozen => 'Frozen',
  };

  Color get color => switch (this) {
    MemberStatus.active => const Color(0xFF7BD88F),
    MemberStatus.expired => const Color(0xFFFF6B6B),
    MemberStatus.frozen => const Color(0xFFFFE58A),
  };
}

/// A purchasable membership plan.
class MembershipPlan {
  const MembershipPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMonths,
  });

  final String id;
  final String name;
  final double price;
  final int durationMonths;
}

/// A gym member.
class Member {
  Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.planId,
    required this.joinDate,
    required this.expiryDate,
    this.imageUrl,
    this.lastWorkout,
    this.oldWeight,
    this.currentWeight,
  });

  final String id;
  String name;
  String phone;
  String planId;
  DateTime joinDate;
  DateTime expiryDate;
  String? imageUrl;
  String? lastWorkout;
  double? oldWeight;
  double? currentWeight;

  MemberStatus get status =>
      expiryDate.isBefore(DateTime.now()) ? MemberStatus.expired : MemberStatus.active;
}

/// A task assigned to a gym member.
class GymTask {
  GymTask({
    required this.id,
    required this.title,
    required this.memberName,
    required this.priority,
    required this.dueDate,
    required this.instructions,
    this.photoSubmitted = false,
    this.photoApproved = false,
  });

  final String id;
  String title;
  String memberName;
  String priority; // High / Medium / Low
  String dueDate;
  String instructions;
  bool photoSubmitted;
  bool photoApproved;
}

/// A recorded payment (membership purchase or renewal).
class Payment {
  const Payment({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.planName,
    required this.date,
  });

  final String id;
  final String memberId;
  final String memberName;
  final double amount;
  final String planName;
  final DateTime date;
}

/// A daily attendance check-in record.
class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.name,
    required this.role,
    required this.time,
  });

  final String id;
  final String name;
  final String role; // Member / Trainer
  final String time;
}

/// An admin-facing notification.
class GymNotification {
  const GymNotification({
    required this.title,
    required this.detail,
    required this.time,
    required this.icon,
  });

  final String title;
  final String detail;
  final String time;
  final IconData icon;
}
