part of 'admin_dashboard_page.dart';

/// Tasks tab: exercise videos, each of which can be assigned as a task.
class _AdminTasksView extends StatelessWidget {
  const _AdminTasksView({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return _ExerciseVideosPanel(state: state);
  }
}

/// Exercise demonstration videos, each with an "Assign as task" button that
/// opens the assign dialog pre-filled with that video.
class _ExerciseVideosPanel extends StatelessWidget {
  const _ExerciseVideosPanel({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPanelHeader(title: 'Exercise videos'),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 600;
              final cardWidth =
                  wide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;

              final children = _exerciseVideos.map((video) {
                return Container(
                  width: cardWidth,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.charcoal,
                    borderRadius: BorderRadius.circular(kAppRadius),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(kAppRadius),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(kAppRadius - 1),
                          child: video_player.createVideoPlayer(video.videoUrl),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _showAssignTaskDialog(
                            context,
                            state,
                            initialTitle: video.name,
                            initialVideoUrl: video.videoUrl,
                          ),
                          icon: const Icon(Icons.assignment_ind_outlined, size: 16),
                          label: const Text('Assign as task'),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();

              if (wide) {
                return Wrap(spacing: 16, children: children);
              }
              return Column(children: children);
            },
          ),
        ],
      ),
    );
  }
}

/// Exercise demonstration videos an admin can attach when assigning a task.
const _exerciseVideos = [
  (name: 'Barbell Bench Press Technique', videoUrl: 'videos/Bench-Press-Chest.mp4'),
  (name: 'Chest Press Machine Form', videoUrl: 'videos/Chest-Press3.mp4'),
  (name: 'Dumbbell Fly Execution', videoUrl: 'videos/Dumbbell-Fly-Chest.mp4'),
  (name: 'Lever Seated Fly Technique', videoUrl: 'videos/Lever-Seated-Fly-Chest.mp4'),
];

// ---------------------------------------------------------------------------
// Assign task dialog
// ---------------------------------------------------------------------------

Future<void> _showAssignTaskDialog(
  BuildContext context,
  AppState state, {
  String? initialTitle,
  String? initialVideoUrl,
}) async {
  final task = await showDialog<GymTask>(
    context: context,
    builder: (_) => _AssignTaskDialog(
      state: state,
      initialTitle: initialTitle,
      initialVideoUrl: initialVideoUrl,
    ),
  );
  if (task != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task ${task.id} assigned to ${task.memberName}.')),
    );
  }
}

class _AssignTaskDialog extends StatefulWidget {
  const _AssignTaskDialog({
    required this.state,
    this.initialTitle,
    this.initialVideoUrl,
  });

  final AppState state;
  final String? initialTitle;
  final String? initialVideoUrl;

  @override
  State<_AssignTaskDialog> createState() => _AssignTaskDialogState();
}

class _AssignTaskDialogState extends State<_AssignTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  // Members available to assign. Restricted to Ava for now.
  late final List<Member> _assignableMembers = widget.state.members
      .where((m) => m.name.toLowerCase().contains('ava'))
      .toList();

  String? _memberName;
  String? _videoUrl; // null = no video attached

  @override
  void initState() {
    super.initState();
    if (_assignableMembers.isNotEmpty) {
      _memberName = _assignableMembers.first.name;
    }
    _videoUrl = widget.initialVideoUrl;
    if (widget.initialTitle != null) {
      _titleController.text = widget.initialTitle!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _assign() {
    if (!_formKey.currentState!.validate()) return;
    final task = widget.state.addTask(
      title: _titleController.text,
      memberName: _memberName!,
      priority: 'Medium',
      dueDate: 'No due date',
      instructions: _videoUrl != null
          ? 'Watch the exercise demonstration video and maintain correct posture.'
          : 'Complete the assigned training program.',
      videoUrl: _videoUrl,
    );
    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kAppRadius),
        side: const BorderSide(color: AppColors.line),
      ),
      title: Row(
        children: [
          const AppIconBadge(icon: Icons.assignment_ind_outlined, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Assign task',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_assignableMembers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: Text(
                      'No assignable members available.',
                      style: TextStyle(color: AppColors.danger),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: _memberName,
                    decoration: const InputDecoration(
                      labelText: 'Assign to member',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    dropdownColor: AppColors.surface,
                    items: _assignableMembers.map((m) {
                      return DropdownMenuItem<String>(
                        value: m.name,
                        child: Text(m.name),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _memberName = value),
                    validator: (value) =>
                        (value == null || value.isEmpty)
                        ? 'Select a member.'
                        : null,
                  ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Workout name',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                      ? 'Enter a workout name.'
                      : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String?>(
                  initialValue: _videoUrl,
                  decoration: const InputDecoration(
                    labelText: 'Exercise video (optional)',
                    prefixIcon: Icon(Icons.ondemand_video_outlined),
                  ),
                  dropdownColor: AppColors.surface,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('No video'),
                    ),
                    for (final v in _exerciseVideos)
                      DropdownMenuItem<String?>(
                        value: v.videoUrl,
                        child: Text(v.name),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _videoUrl = value;
                      // Prefill the workout name from the chosen video.
                      if (value != null && _titleController.text.trim().isEmpty) {
                        _titleController.text = _exerciseVideos
                            .firstWhere((v) => v.videoUrl == value)
                            .name;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _assign,
          icon: const Icon(Icons.check),
          label: const Text('Assign task'),
        ),
      ],
    );
  }
}
