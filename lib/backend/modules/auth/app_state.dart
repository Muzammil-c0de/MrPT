import 'package:fitness_webapp/backend/modules/auth/app_user.dart';
import 'package:fitness_webapp/backend/modules/gym/gym_models.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Outcome of a sign-in attempt: `null` on success, otherwise an error message
/// suitable for display.
typedef LoginResult = String?;

/// In-memory application state: the authenticated session plus the full gym
/// directory (accounts, members, plans, tasks, payments, attendance and
/// notifications). The single source of truth every screen listens to.
///
/// Dependency-free (a plain [ChangeNotifier]) so it can be swapped for a
/// networked backend later without touching the UI.
class AppState extends ChangeNotifier {
  AppState() {
    _seed();
  }

  final List<AppUser> _users = <AppUser>[];
  final List<MembershipPlan> _plans = <MembershipPlan>[];
  final List<Member> _members = <Member>[];
  final List<GymTask> _tasks = <GymTask>[];
  final List<Payment> _payments = <Payment>[];
  final List<AttendanceRecord> _attendance = <AttendanceRecord>[];
  final List<GymNotification> _notifications = <GymNotification>[];

  AppUser? _currentUser;
  bool notificationsEnabled = true;

  static const _sessionKey = 'mrpt.session.userId';

  /// Whether the persisted session has been loaded yet. The gate shows a splash
  /// until this is true to avoid flashing the login screen on launch.
  bool _sessionRestored = false;
  bool get sessionRestored => _sessionRestored;

  final Map<UserRole, int> _idCounters = <UserRole, int>{};
  int _memberCounter = 0;
  int _taskCounter = 0;
  int _paymentCounter = 0;

  late final AppUser admin;

  // ---------------------------------------------------------------------------
  // Session
  // ---------------------------------------------------------------------------

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AppUser? _findUser(String id) {
    final query = id.trim().toLowerCase();
    for (final user in _users) {
      if (user.id.toLowerCase() == query) return user;
    }
    return null;
  }

  LoginResult login(String id, String password) {
    if (id.trim().isEmpty || password.isEmpty) {
      return 'Enter your ID and password.';
    }
    final user = _findUser(id);
    if (user == null) return 'No account found for that ID.';
    if (!user.active) {
      return 'This account is disabled. Contact your administrator.';
    }
    if (user.password != password) return 'Incorrect password. Please try again.';
    _currentUser = user;
    _persistSession();
    notifyListeners();
    return null;
  }

  void logout() {
    _currentUser = null;
    _persistSession();
    notifyListeners();
  }

  /// Restores a previously persisted session on app launch. Safe to call once.
  Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_sessionKey);
      if (id != null) {
        final user = _findUser(id);
        if (user != null && user.active) _currentUser = user;
      }
    } catch (_) {
      // Storage unavailable (e.g. private mode); fall back to a fresh session.
    }
    _sessionRestored = true;
    notifyListeners();
  }

  Future<void> _persistSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = _currentUser;
      if (user == null) {
        await prefs.remove(_sessionKey);
      } else {
        await prefs.setString(_sessionKey, user.id);
      }
    } catch (_) {
      // Persistence is best-effort; ignore storage failures.
    }
  }

  // ---------------------------------------------------------------------------
  // Trainers
  // ---------------------------------------------------------------------------

  List<AppUser> get trainers {
    final list = _users
        .where((user) => user.role == UserRole.personalTrainer)
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(list);
  }

  int get totalTrainers => trainers.length;
  int get activeTrainers => trainers.where((t) => t.active).length;
  int get disabledTrainers => totalTrainers - activeTrainers;

  String trainerName(String? id) {
    if (id == null) return 'Unassigned';
    return _findUser(id)?.name ?? 'Unassigned';
  }

  String _nextId(UserRole role) {
    final next = (_idCounters[role] ?? 0) + 1;
    _idCounters[role] = next;
    return '${role.idPrefix}-${next.toString().padLeft(4, '0')}';
  }

  String get nextTrainerIdPreview {
    final next = (_idCounters[UserRole.personalTrainer] ?? 0) + 1;
    return '${UserRole.personalTrainer.idPrefix}-${next.toString().padLeft(4, '0')}';
  }

  AppUser addTrainer({
    required String name,
    required String password,
    String? email,
  }) {
    final trainer = AppUser(
      id: _nextId(UserRole.personalTrainer),
      name: name.trim(),
      role: UserRole.personalTrainer,
      email: email?.trim().isEmpty ?? true ? null : email!.trim(),
      password: password,
    );
    _users.add(trainer);
    notifyListeners();
    return trainer;
  }

  void setTrainerActive(String id, bool active) {
    final user = _findUser(id);
    if (user == null) return;
    user.active = active;
    notifyListeners();
  }

  /// Number of active members assigned to a trainer.
  int membersOfTrainer(String trainerId) =>
      _members.where((m) => m.assignedTrainerId == trainerId).length;

  /// Completed-task ratio for a trainer (0..1).
  double trainerPerformance(String trainerId) {
    final theirs = _tasks.where((t) => t.trainerId == trainerId).toList();
    if (theirs.isEmpty) return 0;
    final done = theirs.where((t) => t.status == GymTaskStatus.completed).length;
    return done / theirs.length;
  }

  // ---------------------------------------------------------------------------
  // Plans
  // ---------------------------------------------------------------------------

  List<MembershipPlan> get plans => List.unmodifiable(_plans);

  MembershipPlan planById(String id) =>
      _plans.firstWhere((p) => p.id == id, orElse: () => _plans.first);

  // ---------------------------------------------------------------------------
  // Members
  // ---------------------------------------------------------------------------

  List<Member> get members {
    final list = List<Member>.of(_members);
    list.sort((a, b) => b.joinDate.compareTo(a.joinDate));
    return List.unmodifiable(list);
  }

  int get totalMembers => _members.length;
  int get activeMembers =>
      _members.where((m) => m.status == MemberStatus.active).length;
  int get expiredMembers =>
      _members.where((m) => m.status == MemberStatus.expired).length;

  String get nextMemberIdPreview =>
      'MBR-${(_memberCounter + 1).toString().padLeft(4, '0')}';

  Member addMember({
    required String name,
    required String phone,
    required String planId,
    String? assignedTrainerId,
    String? imageUrl,
    String? lastWorkout,
    double? oldWeight,
    double? currentWeight,
  }) {
    final plan = planById(planId);
    final now = DateTime.now();
    _memberCounter++;
    final member = Member(
      id: 'MBR-${_memberCounter.toString().padLeft(4, '0')}',
      name: name.trim(),
      phone: phone.trim(),
      planId: planId,
      joinDate: now,
      expiryDate: DateTime(now.year, now.month + plan.durationMonths, now.day),
      assignedTrainerId: assignedTrainerId,
      imageUrl: imageUrl,
      lastWorkout: lastWorkout,
      oldWeight: oldWeight,
      currentWeight: currentWeight,
    );
    _members.add(member);
    _recordPayment(member, plan);
    notifyListeners();
    return member;
  }

  void renewMember(String memberId) {
    final member = _members.firstWhere((m) => m.id == memberId);
    final plan = planById(member.planId);
    final base = member.expiryDate.isAfter(DateTime.now())
        ? member.expiryDate
        : DateTime.now();
    member.expiryDate =
        DateTime(base.year, base.month + plan.durationMonths, base.day);
    _recordPayment(member, plan);
    notifyListeners();
  }

  void assignTrainerToMember(String memberId, String? trainerId) {
    final member = _members.firstWhere((m) => m.id == memberId);
    member.assignedTrainerId = trainerId;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Tasks
  // ---------------------------------------------------------------------------

  List<GymTask> get tasks => List.unmodifiable(_tasks);

  List<GymTask> tasksByStatus(GymTaskStatus status) =>
      _tasks.where((t) => t.status == status).toList();

  List<GymTask> get photoApprovals =>
      _tasks.where((t) => t.photoSubmitted && !t.photoApproved).toList();

  int get pendingTasks => tasksByStatus(GymTaskStatus.pending).length;
  int get inProgressTasks => tasksByStatus(GymTaskStatus.inProgress).length;
  int get completedTasks => tasksByStatus(GymTaskStatus.completed).length;

  String get nextTaskIdPreview =>
      'TSK-${(_taskCounter + 1).toString().padLeft(4, '0')}';

  GymTask addTask({
    required String title,
    required String trainerId,
    required String memberName,
    required String priority,
    required String dueDate,
    required String instructions,
  }) {
    _taskCounter++;
    final task = GymTask(
      id: 'TSK-${_taskCounter.toString().padLeft(4, '0')}',
      title: title.trim(),
      trainerId: trainerId,
      memberName: memberName.trim(),
      priority: priority,
      dueDate: dueDate.trim(),
      instructions: instructions.trim(),
    );
    _tasks.add(task);
    notifyListeners();
    return task;
  }

  void setTaskStatus(String taskId, GymTaskStatus status) {
    _tasks.firstWhere((t) => t.id == taskId).status = status;
    notifyListeners();
  }

  void approveTaskPhoto(String taskId, bool approved) {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    task.photoApproved = approved;
    if (!approved) task.photoSubmitted = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Payments / attendance / notifications
  // ---------------------------------------------------------------------------

  List<Payment> get payments {
    final list = List<Payment>.of(_payments);
    list.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(list);
  }

  double get totalRevenue =>
      _payments.fold(0, (sum, p) => sum + p.amount);

  double get monthlyRevenue {
    final now = DateTime.now();
    return _payments
        .where((p) => p.date.year == now.year && p.date.month == now.month)
        .fold(0, (sum, p) => sum + p.amount);
  }

  List<AttendanceRecord> get attendance => List.unmodifiable(_attendance);
  int get todayAttendance => _attendance.length;

  List<GymNotification> get notifications => List.unmodifiable(_notifications);

  void _recordPayment(Member member, MembershipPlan plan) {
    _paymentCounter++;
    _payments.add(
      Payment(
        id: 'PAY-${_paymentCounter.toString().padLeft(4, '0')}',
        memberId: member.id,
        memberName: member.name,
        amount: plan.price,
        planName: plan.name,
        date: DateTime.now(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Seed data
  // ---------------------------------------------------------------------------

  void _seed() {
    admin = AppUser(
      id: _nextId(UserRole.superAdmin),
      name: 'Gym Administrator',
      role: UserRole.superAdmin,
      email: 'admin@mrpt.com',
      password: 'Admin@123',
    );
    _users.add(admin);

    final now = DateTime.now();
    AppUser seedTrainer(String name) => AppUser(
      id: _nextId(UserRole.personalTrainer),
      name: name,
      role: UserRole.personalTrainer,
      email: '${name.split(' ').first.toLowerCase()}@mrpt.com',
      password: 'trainer123',
      createdAt: now.subtract(const Duration(days: 6)),
    );
    final maya = seedTrainer('Maya Johnson');
    final carlos = seedTrainer('Carlos Reyes');
    final nina = seedTrainer('Nina Park');
    _users.addAll([maya, carlos, nina]);

    _plans.addAll(const [
      MembershipPlan(id: 'PLN-1', name: 'Basic Monthly', price: 35, durationMonths: 1),
      MembershipPlan(id: 'PLN-2', name: 'Quarterly', price: 90, durationMonths: 3),
      MembershipPlan(id: 'PLN-3', name: 'Annual', price: 320, durationMonths: 12),
    ]);

    void seedMember({
      required String name,
      required String phone,
      required String planId,
      required int joinedDaysAgo,
      String? trainerId,
      String? imageUrl,
      String? lastWorkout,
      double? oldWeight,
      double? currentWeight,
    }) {
      final plan = planById(planId);
      final join = now.subtract(Duration(days: joinedDaysAgo));
      _memberCounter++;
      final member = Member(
        id: 'MBR-${_memberCounter.toString().padLeft(4, '0')}',
        name: name,
        phone: phone,
        planId: planId,
        joinDate: join,
        expiryDate: DateTime(join.year, join.month + plan.durationMonths, join.day),
        assignedTrainerId: trainerId,
        imageUrl: imageUrl,
        lastWorkout: lastWorkout,
        oldWeight: oldWeight,
        currentWeight: currentWeight,
      );
      _members.add(member);
      _paymentCounter++;
      _payments.add(
        Payment(
          id: 'PAY-${_paymentCounter.toString().padLeft(4, '0')}',
          memberId: member.id,
          memberName: member.name,
          amount: plan.price,
          planName: plan.name,
          date: join,
        ),
      );
    }

    seedMember(
      name: 'Ava Ramos',
      phone: '+1 555-0147',
      planId: 'PLN-3',
      joinedDaysAgo: 12,
      trainerId: maya.id,
      imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      lastWorkout: 'Squat Technique & Glute activation (Yesterday)',
      oldWeight: 68.5,
      currentWeight: 64.2,
    );
    seedMember(
      name: 'Darius King',
      phone: '+1 555-0192',
      planId: 'PLN-2',
      joinedDaysAgo: 8,
      trainerId: carlos.id,
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      lastWorkout: 'High-intensity interval conditioning (2 days ago)',
      oldWeight: 85.0,
      currentWeight: 82.3,
    );
    seedMember(
      name: 'Mina Patel',
      phone: '+1 555-0163',
      planId: 'PLN-1',
      joinedDaysAgo: 4,
      trainerId: maya.id,
      imageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
      lastWorkout: 'Active mobility & Hip mobility drill (Today)',
      oldWeight: 58.2,
      currentWeight: 57.9,
    );
    seedMember(
      name: 'Theo Brooks',
      phone: '+1 555-0118',
      planId: 'PLN-1',
      joinedDaysAgo: 70,
      trainerId: nina.id,
      imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      lastWorkout: 'Deadlift heavy sets & core accessory (3 days ago)',
      oldWeight: 92.4,
      currentWeight: 94.1,
    );
    seedMember(
      name: 'Lena Cole',
      phone: '+1 555-0175',
      planId: 'PLN-2',
      joinedDaysAgo: 2,
      imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      lastWorkout: 'None yet (Onboarding screen pending)',
      oldWeight: 71.0,
      currentWeight: 71.0,
    );

    _tasks.addAll([
      GymTask(
        id: 'TSK-0001',
        title: 'Review Barbell Bench Press form',
        trainerId: maya.id,
        memberName: 'Ava Ramos',
        priority: 'High',
        dueDate: 'Today, 6:00 PM',
        instructions: 'Check chest contact point, elbow tuck angle, and bar path. Add two corrective cues for shoulder stability.',
        status: GymTaskStatus.inProgress,
      ),
      GymTask(
        id: 'TSK-0002',
        title: 'Build Dumbbell Fly workout plan',
        trainerId: carlos.id,
        memberName: 'Darius King',
        priority: 'Medium',
        dueDate: 'Tomorrow, 9:00 AM',
        instructions: 'Create a 4-set chest hypertrophy sequence. Focus on deep stretch and controlled concentric phase.',
        status: GymTaskStatus.pending,
      ),
      GymTask(
        id: 'TSK-0003',
        title: 'Update Lever Seated Fly execution tips',
        trainerId: maya.id,
        memberName: 'Mina Patel',
        priority: 'High',
        dueDate: 'Thu, 8:00 PM',
        instructions: 'Review seat height and handle alignment. Add remarks on avoiding excessive shoulder external rotation.',
        status: GymTaskStatus.inProgress,
        photoSubmitted: true,
      ),
      GymTask(
        id: 'TSK-0004',
        title: 'Assess Lever Chest Press technique',
        trainerId: nina.id,
        memberName: 'Theo Brooks',
        priority: 'Low',
        dueDate: 'Completed today',
        instructions: 'Check push path and scapular retraction against pad. Provide feedback on power output.',
        status: GymTaskStatus.completed,
        photoSubmitted: true,
      ),
      GymTask(
        id: 'TSK-0005',
        title: 'Confirm Bench Press attendance variance',
        trainerId: carlos.id,
        memberName: 'Lena Cole',
        priority: 'Medium',
        dueDate: 'Fri, 12:00 PM',
        instructions: 'Follow up on the skipped heavy chest day. Reschedule the Bench Press progression session.',
        status: GymTaskStatus.pending,
      ),
    ]);
    _taskCounter = 5;

    _attendance.addAll(const [
      AttendanceRecord(id: 'A1', name: 'Ava Ramos', role: 'Member', time: '6:05 AM'),
      AttendanceRecord(id: 'A2', name: 'Maya Johnson', role: 'Trainer', time: '5:50 AM'),
      AttendanceRecord(id: 'A3', name: 'Darius King', role: 'Member', time: '7:20 AM'),
      AttendanceRecord(id: 'A4', name: 'Mina Patel', role: 'Member', time: '8:10 AM'),
      AttendanceRecord(id: 'A5', name: 'Carlos Reyes', role: 'Trainer', time: '8:00 AM'),
    ]);

    _notifications.addAll(const [
      GymNotification(
        title: 'New member joined',
        detail: 'Lena Cole purchased the Quarterly plan.',
        time: '2 hr',
        icon: Icons.person_add_alt_1,
      ),
      GymNotification(
        title: 'Photo approval pending',
        detail: 'Mina Patel progress photos await review.',
        time: '3 hr',
        icon: Icons.photo_library_outlined,
      ),
      GymNotification(
        title: 'Membership expired',
        detail: 'Theo Brooks membership needs renewal.',
        time: 'Today',
        icon: Icons.warning_amber_outlined,
      ),
      GymNotification(
        title: 'Task completed',
        detail: 'Nina Park completed nutrition remarks.',
        time: 'Today',
        icon: Icons.task_alt,
      ),
    ]);
  }
}
