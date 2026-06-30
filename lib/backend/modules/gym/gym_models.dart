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

/// Workflow state of a trainer task.
enum GymTaskStatus { pending, inProgress, completed }

extension GymTaskStatusDetails on GymTaskStatus {
  String get label => switch (this) {
    GymTaskStatus.pending => 'Pending',
    GymTaskStatus.inProgress => 'In progress',
    GymTaskStatus.completed => 'Completed',
  };

  IconData get icon => switch (this) {
    GymTaskStatus.pending => Icons.pending_actions_outlined,
    GymTaskStatus.inProgress => Icons.sync,
    GymTaskStatus.completed => Icons.task_alt,
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
    this.assignedTrainerId,
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
  String? assignedTrainerId;
  String? imageUrl;
  String? lastWorkout;
  double? oldWeight;
  double? currentWeight;

  MemberStatus get status =>
      expiryDate.isBefore(DateTime.now()) ? MemberStatus.expired : MemberStatus.active;
}

/// A task assigned to a personal trainer.
class GymTask {
  GymTask({
    required this.id,
    required this.title,
    required this.trainerId,
    required this.memberName,
    required this.priority,
    required this.dueDate,
    required this.instructions,
    this.status = GymTaskStatus.pending,
    this.photoSubmitted = false,
    this.photoApproved = false,
  });

  final String id;
  String title;
  String trainerId;
  String memberName;
  String priority; // High / Medium / Low
  String dueDate;
  String instructions;
  GymTaskStatus status;
  bool photoSubmitted;
  bool photoApproved;

  String? get videoUrl {
    final lowercase = title.toLowerCase();
    if (lowercase.contains('bench press')) {
      return 'videos/00251201-Barbell-Bench-Press-Chest.mp4';
    } else if (lowercase.contains('dumbbell fly')) {
      return 'videos/03081201-Dumbbell-Fly-Chest.mp4';
    } else if (lowercase.contains('seated fly')) {
      return 'videos/05961201-Lever-Seated-Fly-Chest.mp4';
    } else if (lowercase.contains('chest press')) {
      return 'videos/21951201-Lever-Chest-Press-VERSION-3-Chest+.mp4';
    }
    return null;
  }
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
