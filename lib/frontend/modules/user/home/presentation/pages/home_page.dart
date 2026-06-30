import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fitness_webapp/frontend/widgets/video_player_stub.dart'
    if (dart.library.html) 'package:fitness_webapp/frontend/widgets/video_player_web.dart' as video_player;

part 'dashboard_page.dart';
part '../widgets/navigation_widgets.dart';
part 'members_page.dart';
part 'profile_page.dart';
part '../widgets/shared_widgets.dart';
part 'tasks_page.dart';

const _background = Color(0xFF090907);
const _surface = Color(0xFF17150F);
const _surfaceAlt = Color(0xFF211E14);
const _ink = Color(0xFFFFF8DC);
const _muted = Color(0xFFC9B76D);
const _yellow = Color(0xFFFFD23F);
const _gold = Color(0xFFE4A900);
const _amber = Color(0xFFFFE58A);
const _charcoal = Color(0xFF0E0D0A);
const _line = Color(0xFF3C3314);
const _radius = 8.0;

class FitnessWebApp extends StatelessWidget {
  const FitnessWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _yellow,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'MrPT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme.copyWith(
          primary: _yellow,
          secondary: _gold,
          tertiary: _amber,
          surface: _surface,
          onPrimary: _charcoal,
          onSurface: _ink,
        ),
        scaffoldBackgroundColor: _background,
        cardTheme: const CardThemeData(
          color: _surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(_radius)),
            side: BorderSide(color: _line),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _yellow,
            foregroundColor: _charcoal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _ink,
            side: const BorderSide(color: _line),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: _yellow),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _charcoal,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radius),
            borderSide: const BorderSide(color: _line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radius),
            borderSide: const BorderSide(color: _line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radius),
            borderSide: const BorderSide(color: _yellow, width: 1.4),
          ),
          labelStyle: const TextStyle(color: _muted),
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: _ink,
          displayColor: _ink,
        ),
      ),
      home: const FitnessHomePage(),
    );
  }
}

class FitnessHomePage extends StatefulWidget {
  const FitnessHomePage({super.key, this.onLogout});

  /// When provided, a sign-out control is shown in the top bar.
  final VoidCallback? onLogout;

  @override
  State<FitnessHomePage> createState() => _FitnessHomePageState();
}

class _FitnessHomePageState extends State<FitnessHomePage> {
  int _pageIndex = 0;
  int _selectedMember = 0;
  int _selectedTask = 0;
  String _profilePhotoStatus = 'Profile photo verified';

  late final List<PhotoUpload> _uploads = List<PhotoUpload>.of(_seedUploads);

  final Map<int, TaskStatus> _taskStatuses = {
    0: TaskStatus.inProgress,
    1: TaskStatus.pending,
    2: TaskStatus.completed,
    3: TaskStatus.pending,
    4: TaskStatus.inProgress,
  };

  final Map<int, String> _taskNotes = {
    0: 'Keep knees tracking over toes. Add side-angle video after session.',
    2: 'Nutrition check-in completed. Client needs a lighter evening plan.',
  };

  static const _trainer = TrainerProfile(
    name: 'Maya Johnson',
    role: 'Senior Personal Trainer',
    initials: 'MJ',
    email: 'maya@mrpt.com',
    phone: '+1 (555) 014-7821',
    location: 'Downtown Performance Studio',
    experience: '8 years coaching strength, mobility, and body recomposition',
    bio:
        'Focused on clean movement patterns, measurable progress, and high-accountability coaching.',
    specialties: ['Strength', 'Mobility', 'Fat loss', 'Athletic prep'],
    certifications: [
      Certification('NASM-CPT', 'National Academy of Sports Medicine', '2017'),
      Certification('Corrective Exercise', 'NASM', '2019'),
      Certification('Nutrition Coach', 'Precision Nutrition', '2021'),
    ],
  );

  static const _members = <TrainerMember>[
    TrainerMember(
      name: 'Ava Ramos',
      goal: 'Lean strength',
      plan: 'Strength Foundation',
      progress: 0.78,
      attendance: 0.92,
      nextSession: 'Today, 5:30 PM',
      lastCheckIn: 'Hip hinge improved, increase tempo deadlifts.',
      tags: ['Priority form review', 'Photo due'],
      attendanceHistory: ['Mon attended', 'Wed attended', 'Fri scheduled'],
    ),
    TrainerMember(
      name: 'Darius King',
      goal: 'Conditioning',
      plan: 'Engine Builder',
      progress: 0.64,
      attendance: 0.84,
      nextSession: 'Tomorrow, 7:00 AM',
      lastCheckIn: 'Intervals trending up, keep recovery walks steady.',
      tags: ['New assignment', 'High effort'],
      attendanceHistory: ['Tue attended', 'Thu late', 'Sat scheduled'],
    ),
    TrainerMember(
      name: 'Mina Patel',
      goal: 'Mobility reset',
      plan: 'Move Better Daily',
      progress: 0.71,
      attendance: 0.88,
      nextSession: 'Thu, 6:15 PM',
      lastCheckIn: 'Shoulder flexion improved by 12 degrees.',
      tags: ['Progress photo', 'Mobility'],
      attendanceHistory: ['Mon attended', 'Tue upload', 'Thu scheduled'],
    ),
    TrainerMember(
      name: 'Theo Brooks',
      goal: 'Recomposition',
      plan: 'Hybrid Strength',
      progress: 0.56,
      attendance: 0.76,
      nextSession: 'Fri, 4:45 PM',
      lastCheckIn: 'Needs food log consistency and lower-body deload.',
      tags: ['Pending note', 'Admin message'],
      attendanceHistory: ['Wed missed', 'Thu check-in', 'Fri scheduled'],
    ),
  ];

  static const _tasks = <TrainerTask>[
    TrainerTask(
      title: 'Review Barbell Bench Press form',
      memberName: 'Ava Ramos',
      instructions:
          'Check chest contact point, elbow tuck angle, and bar path. Add two corrective cues for shoulder stability.',
      dueDate: 'Today, 6:00 PM',
      priority: 'High',
      category: 'Workout',
      program: 'Strength Foundation',
      icon: Icons.video_camera_front_outlined,
    ),
    TrainerTask(
      title: 'Build Dumbbell Fly workout plan',
      memberName: 'Darius King',
      instructions:
          'Create a 4-set chest hypertrophy sequence. Focus on deep stretch and controlled concentric phase.',
      dueDate: 'Tomorrow, 9:00 AM',
      priority: 'Medium',
      category: 'Program',
      program: 'Engine Builder',
      icon: Icons.timer_outlined,
    ),
    TrainerTask(
      title: 'Update Lever Seated Fly execution tips',
      memberName: 'Theo Brooks',
      instructions:
          'Review seat height and handle alignment. Add remarks on avoiding excessive shoulder external rotation.',
      dueDate: 'Completed today',
      priority: 'Low',
      category: 'Remarks',
      program: 'Hybrid Strength',
      icon: Icons.rate_review_outlined,
    ),
    TrainerTask(
      title: 'Assess Lever Chest Press technique',
      memberName: 'Mina Patel',
      instructions:
          'Check push path and scapular retraction against pad. Provide feedback on power output.',
      dueDate: 'Thu, 8:00 PM',
      priority: 'High',
      category: 'Photo',
      program: 'Move Better Daily',
      icon: Icons.photo_camera_outlined,
    ),
    TrainerTask(
      title: 'Confirm Bench Press attendance variance',
      memberName: 'Theo Brooks',
      instructions:
          'Follow up on the skipped heavy chest day. Reschedule the Bench Press progression session.',
      dueDate: 'Fri, 12:00 PM',
      priority: 'Medium',
      category: 'Attendance',
      program: 'Hybrid Strength',
      icon: Icons.event_available_outlined,
    ),
  ];

  static const _programs = <WorkoutProgram>[
    WorkoutProgram(
      title: 'Strength Foundation',
      memberName: 'Ava Ramos',
      schedule: 'Mon / Wed / Fri',
      progress: 0.78,
      exercises: ['Goblet squat', 'Tempo deadlift', 'Half-kneeling press'],
    ),
    WorkoutProgram(
      title: 'Engine Builder',
      memberName: 'Darius King',
      schedule: 'Tue / Thu / Sat',
      progress: 0.64,
      exercises: ['Bike intervals', 'Sled push', 'Core carry ladder'],
    ),
    WorkoutProgram(
      title: 'Move Better Daily',
      memberName: 'Mina Patel',
      schedule: 'Daily mobility',
      progress: 0.71,
      exercises: ['90/90 hip flow', 'Wall slides', 'Breathing reset'],
    ),
  ];

  static const _notifications = <PortalNotification>[
    PortalNotification(
      title: 'New task assigned',
      detail: 'Admin added a form review for Ava Ramos.',
      time: '12 min',
      icon: Icons.assignment_add,
    ),
    PortalNotification(
      title: 'Workout update',
      detail: 'Darius completed interval block 3 with a new pace record.',
      time: '38 min',
      icon: Icons.trending_up,
    ),
    PortalNotification(
      title: 'Member assignment',
      detail: 'Theo Brooks was moved into your Hybrid Strength roster.',
      time: '2 hr',
      icon: Icons.group_add_outlined,
    ),
    PortalNotification(
      title: 'Admin message',
      detail: 'Submit Friday attendance remarks before noon.',
      time: 'Today',
      icon: Icons.campaign_outlined,
    ),
  ];

  static const _seedUploads = <PhotoUpload>[
    PhotoUpload(
      category: 'Workout',
      memberName: 'Ava Ramos',
      description: 'Squat set 3 side angle',
      submittedAt: 'Today, 4:18 PM',
    ),
    PhotoUpload(
      category: 'Progress',
      memberName: 'Mina Patel',
      description: 'Shoulder range comparison',
      submittedAt: 'Yesterday, 6:02 PM',
    ),
    PhotoUpload(
      category: 'Before/After',
      memberName: 'Theo Brooks',
      description: 'Week 1 to week 6 posture',
      submittedAt: 'Mon, 8:31 AM',
    ),
  ];

  static const _activities = <ActivityItem>[
    ActivityItem(
      title: 'Completed nutrition remarks',
      detail: 'Theo Brooks / Hybrid Strength',
      time: 'Today',
      icon: Icons.task_alt,
    ),
    ActivityItem(
      title: 'Uploaded workout photo',
      detail: 'Ava Ramos / Squat set 3',
      time: 'Today',
      icon: Icons.photo_library_outlined,
    ),
    ActivityItem(
      title: 'Attendance updated',
      detail: 'Darius King / Thursday conditioning',
      time: 'Yesterday',
      icon: Icons.event_available_outlined,
    ),
    ActivityItem(
      title: 'Pending before/after upload',
      detail: 'Mina Patel / Move Better Daily',
      time: 'Due Thu',
      icon: Icons.pending_actions_outlined,
    ),
  ];

  TaskStatus _statusFor(int index) {
    return _taskStatuses[index] ?? TaskStatus.pending;
  }

  List<TaskStatus> get _resolvedTaskStatuses {
    return [
      for (var index = 0; index < _tasks.length; index++) _statusFor(index),
    ];
  }

  int get _completedTasks {
    return _resolvedTaskStatuses
        .where((status) => status == TaskStatus.completed)
        .length;
  }

  int get _pendingTasks {
    return _resolvedTaskStatuses
        .where((status) => status != TaskStatus.completed)
        .length;
  }

  String get _pageTitle {
    return switch (_pageIndex) {
      0 => 'Dashboard',
      1 => 'My Members',
      2 => 'Workout Tasks',
      _ => 'My Profile',
    };
  }

  String get _pageSubtitle {
    return switch (_pageIndex) {
      0 => 'Welcome back, ${_trainer.name}.',
      1 => 'Assigned roster, progress, and attendance history.',
      2 => 'Task status, notes, uploads, and workout programs.',
      _ => 'Profile, contact info, experience, and certifications.',
    };
  }

  void _selectMember(int index) {
    setState(() => _selectedMember = index);
  }

  void _selectTask(int index) {
    setState(() => _selectedTask = index);
  }

  void _updateTaskStatus(int index, TaskStatus status) {
    setState(() => _taskStatuses[index] = status);
  }

  void _updateTaskNote(int index, String note) {
    setState(() => _taskNotes[index] = note);
  }

  void _addUpload(String category, String memberName, String description) {
    setState(() {
      _uploads.insert(
        0,
        PhotoUpload(
          category: category,
          memberName: memberName,
          description: description,
          submittedAt: 'Just now',
        ),
      );
    });
  }

  void _uploadProfilePhoto() {
    setState(() {
      _profilePhotoStatus = 'Updated just now';
      _uploads.insert(
        0,
        const PhotoUpload(
          category: 'Profile',
          memberName: 'Maya Johnson',
          description: 'Trainer profile photo',
          submittedAt: 'Just now',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      wide ? 36 : 18,
                      wide ? 28 : 18,
                      wide ? 36 : 18,
                      wide ? 36 : 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBar(
                          title: _pageTitle,
                          subtitle: _pageSubtitle,
                          compact: !wide,
                          trainer: _trainer,
                          onLogout: widget.onLogout,
                        ),
                        const SizedBox(height: 22),
                        _buildCurrentPage(wide: wide),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: _AppBottomNav(
            selectedIndex: _pageIndex,
            onSelect: (index) => setState(() => _pageIndex = index),
            wide: wide,
          ),
        );
      },
    );
  }

  Widget _buildCurrentPage({required bool wide}) {
    return switch (_pageIndex) {
      0 => _DashboardView(
        trainer: _trainer,
        members: _members,
        tasks: _tasks,
        taskStatuses: _resolvedTaskStatuses,
        completedTasks: _completedTasks,
        pendingTasks: _pendingTasks,
        activities: _activities,
        notifications: _notifications,
        uploads: _uploads,
        programs: _programs,
      ),
      1 => _MembersView(
        members: _members,
        selectedMember: _selectedMember,
        onSelectMember: _selectMember,
      ),
      2 => _TasksView(
        tasks: _tasks,
        selectedTask: _selectedTask,
        taskStatuses: _resolvedTaskStatuses,
        taskNotes: _taskNotes,
        uploads: _uploads,
        programs: _programs,
        onSelectTask: _selectTask,
        onStatusChanged: _updateTaskStatus,
        onNoteChanged: _updateTaskNote,
        onUpload: _addUpload,
      ),
      _ => _ProfileView(
        trainer: _trainer,
        uploads: _uploads,
        activities: _activities,
        profilePhotoStatus: _profilePhotoStatus,
        onUploadPhoto: _uploadProfilePhoto,
      ),
    };
  }
}

enum TaskStatus { pending, inProgress, completed }

extension TaskStatusDetails on TaskStatus {
  String get label {
    return switch (this) {
      TaskStatus.pending => 'Pending',
      TaskStatus.inProgress => 'In progress',
      TaskStatus.completed => 'Completed',
    };
  }

  IconData get icon {
    return switch (this) {
      TaskStatus.pending => Icons.pending_actions_outlined,
      TaskStatus.inProgress => Icons.sync,
      TaskStatus.completed => Icons.task_alt,
    };
  }

  Color get color {
    return switch (this) {
      TaskStatus.pending => _amber,
      TaskStatus.inProgress => _yellow,
      TaskStatus.completed => _gold,
    };
  }
}

class TrainerProfile {
  const TrainerProfile({
    required this.name,
    required this.role,
    required this.initials,
    required this.email,
    required this.phone,
    required this.location,
    required this.experience,
    required this.bio,
    required this.specialties,
    required this.certifications,
  });

  final String name;
  final String role;
  final String initials;
  final String email;
  final String phone;
  final String location;
  final String experience;
  final String bio;
  final List<String> specialties;
  final List<Certification> certifications;
}

class Certification {
  const Certification(this.name, this.issuer, this.year);

  final String name;
  final String issuer;
  final String year;
}

class TrainerMember {
  const TrainerMember({
    required this.name,
    required this.goal,
    required this.plan,
    required this.progress,
    required this.attendance,
    required this.nextSession,
    required this.lastCheckIn,
    required this.tags,
    required this.attendanceHistory,
  });

  final String name;
  final String goal;
  final String plan;
  final double progress;
  final double attendance;
  final String nextSession;
  final String lastCheckIn;
  final List<String> tags;
  final List<String> attendanceHistory;
}

class TrainerTask {
  const TrainerTask({
    required this.title,
    required this.memberName,
    required this.instructions,
    required this.dueDate,
    required this.priority,
    required this.category,
    required this.program,
    required this.icon,
  });

  final String title;
  final String memberName;
  final String instructions;
  final String dueDate;
  final String priority;
  final String category;
  final String program;
  final IconData icon;

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

class PhotoUpload {
  const PhotoUpload({
    required this.category,
    required this.memberName,
    required this.description,
    required this.submittedAt,
  });

  final String category;
  final String memberName;
  final String description;
  final String submittedAt;
}

class WorkoutProgram {
  const WorkoutProgram({
    required this.title,
    required this.memberName,
    required this.schedule,
    required this.progress,
    required this.exercises,
  });

  final String title;
  final String memberName;
  final String schedule;
  final double progress;
  final List<String> exercises;
}

class PortalNotification {
  const PortalNotification({
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

class ActivityItem {
  const ActivityItem({
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
