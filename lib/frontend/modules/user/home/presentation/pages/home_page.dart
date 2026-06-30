import 'dart:math' as math;
import 'package:fitness_webapp/backend/backend.dart';
import 'package:fitness_webapp/frontend/theme/app_theme.dart';
import 'package:fitness_webapp/frontend/widgets/app_widgets.dart';
import 'package:flutter/material.dart';

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

class FitnessHomePage extends StatefulWidget {
  const FitnessHomePage({super.key, this.onLogout});

  final VoidCallback? onLogout;

  @override
  State<FitnessHomePage> createState() => _FitnessHomePageState();
}

class _FitnessHomePageState extends State<FitnessHomePage> {
  int _pageIndex = 0;

  // Local state for interactive features
  int _caloriesBurned = 350;
  final int _calorieGoal = 600;

  // Weight progression state
  late List<double> _weightHistory;
  final _weightInputController = TextEditingController();

  // BMI State
  final _heightBmiController = TextEditingController(text: '175');
  final _weightBmiController = TextEditingController();
  double? _calculatedBmi;
  String _bmiCategory = '';
  Color _bmiColor = _muted;

  // Chat State
  final _chatController = TextEditingController();
  final List<Map<String, dynamic>> _chatMessages = [
    {
      'sender': 'Trainer',
      'text': 'Hey! Hope you are ready for a strong session today. Let me know if you have any questions about your deadlifts!',
      'time': '10:30 AM',
    }
  ];

  // Workout Checklist State
  final List<Map<String, dynamic>> _todayExercises = [
    {'name': 'Goblet squats', 'sets': '3 sets x 10 reps', 'weight': '16 kg', 'done': false, 'desc': 'Hold the kettlebell at chest height. Keep chest upright and track knees over toes.'},
    {'name': 'Tempo deadlifts', 'sets': '4 sets x 8 reps', 'weight': '40 kg', 'done': false, 'desc': 'Execute a 3-second descent. Keep the bar close to your shins.'},
    {'name': 'Half-kneeling press', 'sets': '3 sets x 12 reps', 'weight': '10 kg', 'done': false, 'desc': 'Squeeze glute of the down knee. Press directly overhead.'},
  ];
  bool _workoutCompletedToday = false;
  final List<String> _workoutHistory = ['Upper Body Focus (2 days ago)', 'Active Mobility reset (5 days ago)'];

  // Motivational quote state
  String _motivationQuote = 'The only bad workout is the one that didn\'t happen.';
  final List<String> _quotes = [
    'The only bad workout is the one that didn\'t happen.',
    'Clear your mind. Lift the weights. Master your movement.',
    'Consistency always beats intensity in the long run.',
    'Focus on progression, not perfection.',
    'Your body can stand almost anything. It\'s your mind that you have to convince.',
  ];

  // Body Measurements State
  double _chestMeasurement = 96.5;
  double _waistMeasurement = 82.0;
  double _hipsMeasurement = 98.4;
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chestController.text = _chestMeasurement.toString();
    _waistController.text = _waistMeasurement.toString();
    _hipsController.text = _hipsMeasurement.toString();
  }

  @override
  void dispose() {
    _weightInputController.dispose();
    _heightBmiController.dispose();
    _weightBmiController.dispose();
    _chatController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    super.dispose();
  }

  void _refreshQuote() {
    final rand = math.Random();
    setState(() {
      _motivationQuote = _quotes[rand.nextInt(_quotes.length)];
    });
  }

  void _calculateBmi() {
    final height = double.tryParse(_heightBmiController.text);
    final weight = double.tryParse(_weightBmiController.text);
    if (height != null && weight != null && height > 0) {
      final heightM = height / 100.0;
      final bmi = weight / (heightM * heightM);
      setState(() {
        _calculatedBmi = bmi;
        if (bmi < 18.5) {
          _bmiCategory = 'Underweight';
          _bmiColor = _amber;
        } else if (bmi < 25.0) {
          _bmiCategory = 'Normal Weight';
          _bmiColor = Colors.green;
        } else if (bmi < 30.0) {
          _bmiCategory = 'Overweight';
          _bmiColor = _yellow;
        } else {
          _bmiCategory = 'Obese';
          _bmiColor = Colors.redAccent;
        }
      });
    }
  }

  void _sendChatMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatMessages.add({
        'sender': 'Member',
        'text': text,
        'time': 'Just now',
      });
      _chatController.clear();
    });

    // Mock response from coach
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      final autoReplies = [
        'Awesome work! Make sure to stay hydrated and hit your daily protein goal.',
        'Good form is key. Take your time between sets, around 90 seconds.',
        'For nutrition, try prioritizing lean meats and complex carbs before training.',
        'Keep up the momentum. Consistency is what yields the final results!',
      ];
      final rand = math.Random();
      setState(() {
        _chatMessages.add({
          'sender': 'Trainer',
          'text': autoReplies[rand.nextInt(autoReplies.length)],
          'time': 'Just now',
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final user = state.currentUser;
    final member = state.members.firstWhere(
      (m) => m.id == user?.id,
      orElse: () => Member(
        id: user?.id ?? 'MBR-0001',
        name: user?.name ?? 'Member',
        phone: '',
        planId: 'PLN-1',
        joinDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        password: 'password123',
        oldWeight: 75.0,
        currentWeight: 73.5,
      ),
    );

    // Initial weight progression graph setup
    _weightHistory = [
      member.oldWeight ?? 75.0,
      ((member.oldWeight ?? 75.0) + (member.currentWeight ?? 73.5)) / 2,
      member.currentWeight ?? 73.5,
    ];

    if (_weightBmiController.text.isEmpty) {
      _weightBmiController.text = (member.currentWeight ?? 73.5).toString();
    }

    final String planName = state.planById(member.planId).name;

    Widget currentTab() {
      switch (_pageIndex) {
        case 0:
          return _buildHomeTab(member, planName);
        case 1:
          return _buildWorkoutTab(member);
        case 2:
          return _buildProgressTab(member);
        case 3:
          return _buildChatTab(member);
        default:
          return _buildProfileTab(member, planName, state);
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: _charcoal,
            title: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _yellow,
                    borderRadius: BorderRadius.circular(_radius),
                  ),
                  child: const Icon(Icons.fitness_center, color: _charcoal, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  'FitPilot Member',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: _ink,
                      ),
                ),
              ],
            ),
            actions: [
              if (widget.onLogout != null)
                IconButton(
                  tooltip: 'Logout',
                  onPressed: widget.onLogout,
                  icon: const Icon(Icons.logout, color: _muted),
                ),
            ],
            elevation: 0,
          ),
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? 36 : 16,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: currentTab(),
                ),
              ),
            ),
          ),
          bottomNavigationBar: wide
              ? null
              : _buildBottomNav(),
        );
      },
    );
  }

  // --- Home Tab ---
  Widget _buildHomeTab(Member member, String planName) {
    final progress = member.expiryDate.difference(DateTime.now()).inDays;
    final int totalDays = member.expiryDate.difference(member.joinDate).inDays;
    final double expirationProgress = totalDays == 0 ? 0.0 : (progress / totalDays).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting & Motivational Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${member.name}! 👋',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote, color: _yellow, size: 28),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _motivationQuote,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: _amber,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _refreshQuote,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh Motivation'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Grid of status info
        LayoutBuilder(
          builder: (context, constraints) {
            final double gridWidth = constraints.maxWidth >= 600 ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;
            final items = [
              // Today's workout
              Container(
                width: gridWidth,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _charcoal,
                  borderRadius: BorderRadius.circular(_radius),
                  border: Border.all(color: _line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.fitness_center_outlined, color: _yellow),
                        SizedBox(width: 8),
                        Text('Today\'s Workout', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _workoutCompletedToday ? 'Workout Completed! 🎉' : 'Strength Foundation Plan',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _workoutCompletedToday ? 'Check history under Workout tab.' : 'Squats, deadlifts, & presses.',
                      style: const TextStyle(color: _muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Upcoming PT Session
              Container(
                width: gridWidth,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _charcoal,
                  borderRadius: BorderRadius.circular(_radius),
                  border: Border.all(color: _line),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_month_outlined, color: _yellow),
                        SizedBox(width: 8),
                        Text('Upcoming Session', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Personal Training Session',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tomorrow, 5:30 PM with Lead Coach',
                      style: TextStyle(color: _muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ];

            if (constraints.maxWidth >= 600) {
              return Row(
                children: [
                  items[0],
                  const SizedBox(width: 16),
                  items[1],
                ],
              );
            }
            return Column(
              children: [
                items[0],
                const SizedBox(height: 16),
                items[1],
              ],
            );
          },
        ),
        const SizedBox(height: 16),

        // Calories Burned (Interactive)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: _line),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Calories Burned Today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 6),
                    Text(
                      '$_caloriesBurned / $_calorieGoal kcal',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: _yellow),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: (_caloriesBurned / _calorieGoal).clamp(0.0, 1.0),
                      backgroundColor: _surfaceAlt,
                      color: _yellow,
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _caloriesBurned = math.min(_caloriesBurned + 50, 1000);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _yellow,
                            foregroundColor: _charcoal,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: const Text('+50 kcal'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _caloriesBurned = math.min(_caloriesBurned + 100, 1000);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _yellow,
                            foregroundColor: _charcoal,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: const Text('+100 kcal'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Membership Status
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _charcoal,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  const Text('Membership Status', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'Active',
                    style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Plan: $planName',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Expires in $progress days (${member.expiryDate.day}/${member.expiryDate.month}/${member.expiryDate.year})',
                style: const TextStyle(color: _muted, fontSize: 13),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: expirationProgress,
                backgroundColor: _surfaceAlt,
                color: Colors.greenAccent,
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Workout Tab ---
  Widget _buildWorkoutTab(Member member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'Workout Workspace',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 16),

        // Today's plan check-list
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Today\'s Exercises', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 12),
              for (int i = 0; i < _todayExercises.length; i++)
                CheckboxListTile(
                  title: Text(_todayExercises[i]['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${_todayExercises[i]['sets']} · ${_todayExercises[i]['weight']}'),
                  value: _todayExercises[i]['done'],
                  activeColor: _yellow,
                  checkColor: _charcoal,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  secondary: IconButton(
                    icon: const Icon(Icons.info_outline, color: _yellow),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: _surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_radius),
                            side: const BorderSide(color: _line),
                          ),
                          title: Text(_todayExercises[i]['name']),
                          content: Text(_todayExercises[i]['desc']),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  onChanged: (val) {
                    setState(() {
                      _todayExercises[i]['done'] = val!;
                    });
                  },
                ),
              const SizedBox(height: 16),
              if (!_workoutCompletedToday)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _workoutCompletedToday = true;
                        _caloriesBurned = math.min(_caloriesBurned + 250, _calorieGoal);
                        _workoutHistory.insert(0, 'Strength Foundation (Today)');
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Great job! Workout marked completed!')),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Mark Workout Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _yellow,
                      foregroundColor: _charcoal,
                    ),
                  ),
                )
              else
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.greenAccent, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Workout Completed Today!',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.greenAccent),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Video Demonstration
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _charcoal,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Workout Video Walkthroughs', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(_radius),
                  border: Border.all(color: _line),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_outline, color: _yellow, size: 48),
                      SizedBox(height: 8),
                      Text('Squat & Hinge Technique Cues', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // History list
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _charcoal,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Workout History Log', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              for (final hist in _workoutHistory)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: _muted, size: 18),
                      const SizedBox(width: 10),
                      Text(hist, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Progress Tab ---
  Widget _buildProgressTab(Member member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Progression',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 16),

        // Custom weight line chart
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Weight Progression Chart', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                'Starting: ${member.oldWeight ?? 75.0} kg  →  Current: ${member.currentWeight ?? 73.5} kg',
                style: const TextStyle(color: _muted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 150,
                width: double.infinity,
                child: CustomPaint(
                  painter: _WeightChartPainter(
                    oldWeight: member.oldWeight ?? 75.0,
                    currentWeight: member.currentWeight ?? 73.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // BMI Calculator
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _charcoal,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dynamic BMI Calculator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightBmiController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Height (cm)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _weightBmiController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Weight (kg)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _calculateBmi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _yellow,
                    foregroundColor: _charcoal,
                  ),
                  child: const Text('Calculate BMI'),
                ),
              ),
              if (_calculatedBmi != null) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'BMI Score: ${_calculatedBmi!.toStringAsFixed(1)}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    Text(
                      _bmiCategory,
                      style: TextStyle(color: _bmiColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Body Measurements
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Body Measurements (cm)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _chestController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Chest'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _waistController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Waist'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _hipsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Hips'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _chestMeasurement = double.tryParse(_chestController.text) ?? _chestMeasurement;
                    _waistMeasurement = double.tryParse(_waistController.text) ?? _waistMeasurement;
                    _hipsMeasurement = double.tryParse(_hipsController.text) ?? _hipsMeasurement;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Body measurements saved successfully.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _yellow,
                  foregroundColor: _charcoal,
                ),
                child: const Text('Save Measurements'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Chat Tab ---
  Widget _buildChatTab(Member member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trainer Chat & Help',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 16),

        // Chat Box View
        Container(
          height: 300,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: _line),
          ),
          child: ListView.builder(
            itemCount: _chatMessages.length,
            itemBuilder: (context, index) {
              final msg = _chatMessages[index];
              final isTrainer = msg['sender'] == 'Trainer';
              return Align(
                alignment: isTrainer ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isTrainer ? _surfaceAlt : _yellow,
                    borderRadius: BorderRadius.circular(_radius),
                    border: isTrainer ? Border.all(color: _line) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg['text'],
                        style: TextStyle(color: isTrainer ? Colors.white : _charcoal),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg['time'],
                        style: TextStyle(
                          fontSize: 10,
                          color: isTrainer ? Colors.white38 : _charcoal.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Message input row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _chatController,
                decoration: const InputDecoration(
                  hintText: 'Type your message to coach...',
                  fillColor: _charcoal,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: _yellow),
              onPressed: _sendChatMessage,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Diet Suggestions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _charcoal,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: _line),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Weekly Diet Tip', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Focus on 1.6g to 2.2g of protein per kg of bodyweight. Incorporate healthy fats like avocado and olive oil for hormonal health.',
                style: TextStyle(color: _muted, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Profile Tab ---
  Widget _buildProfileTab(Member member, String planName, AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: _line),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: _yellow,
                child: Text(
                  member.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: _charcoal, fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('ID: ${member.id} · Member Portal', style: const TextStyle(color: _muted, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Personal / Membership Info
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _charcoal,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Membership Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.card_membership_outlined, 'Plan Name', planName),
              _buildDetailRow(Icons.phone_outlined, 'Phone', member.phone),
              _buildDetailRow(Icons.calendar_today_outlined, 'Join Date', '${member.joinDate.day}/${member.joinDate.month}/${member.joinDate.year}'),
              _buildDetailRow(Icons.event_busy_outlined, 'Renewal Date', '${member.expiryDate.day}/${member.expiryDate.month}/${member.expiryDate.year}'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Change Password Form
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Change Account Password', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
                onChanged: (val) {
                  member.password = val.trim();
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password updated successfully.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _yellow,
                  foregroundColor: _charcoal,
                ),
                child: const Text('Update Password'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _yellow),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(color: _muted)),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _pageIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: _charcoal,
      selectedItemColor: _yellow,
      unselectedItemColor: _muted,
      onTap: (index) {
        setState(() {
          _pageIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.fitness_center_outlined), label: 'Workout'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Progress'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  _WeightChartPainter({required this.oldWeight, required this.currentWeight});

  final double oldWeight;
  final double currentWeight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _yellow
      ..strokeWidth = 3
      ..style = PaintStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_yellow.withOpacity(0.24), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * (oldWeight > currentWeight ? 0.4 : 0.8),
      size.width,
      size.height * 0.3,
    );

    canvas.drawPath(path, paint);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);

    final dotPaint = Paint()
      ..color = _yellow
      ..style = PaintStyle.fill;
    final dotBorderPaint = Paint()
      ..color = _charcoal
      ..strokeWidth = 2
      ..style = PaintStyle.stroke;

    canvas.drawCircle(Offset(0, size.height * 0.7), 6, dotPaint);
    canvas.drawCircle(Offset(0, size.height * 0.7), 6, dotBorderPaint);

    canvas.drawCircle(Offset(size.width, size.height * 0.3), 6, dotPaint);
    canvas.drawCircle(Offset(size.width, size.height * 0.3), 6, dotBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
