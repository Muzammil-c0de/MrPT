part of 'admin_dashboard_page.dart';

/// Tasks tab: create tasks, assign them to members, and approve photos.
class _AdminTasksView extends StatelessWidget {
  const _AdminTasksView({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final tasks = state.tasks;

    return Column(
      children: [
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final tight = constraints.maxWidth < 460;
                  final header = const AppPanelHeader(title: 'Tasks');
                  final createButton = SizedBox(
                    width: tight ? double.infinity : null,
                    child: FilledButton.icon(
                      onPressed: () => _showCreateTaskDialog(context, state),
                      icon: const Icon(Icons.add_task),
                      label: const Text('Create task'),
                    ),
                  );
                  if (tight) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [header, const SizedBox(height: 14), createButton],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: header),
                      const SizedBox(width: 12),
                      createButton,
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              if (tasks.isEmpty)
                const AppEmptyState(
                  icon: Icons.assignment_outlined,
                  message: 'No tasks yet. Create one to get started.',
                )
              else
                for (var i = 0; i < tasks.length; i++) ...[
                  _TaskCard(task: tasks[i]),
                  if (i != tasks.length - 1) const SizedBox(height: 12),
                ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PhotoApprovalsPanel(state: state),
        const SizedBox(height: 16),
        _VideoExerciseLibrary(state: state),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final GymTask task;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(kAppRadius),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AppIconBadge(icon: Icons.assignment_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Assigned to: ${task.memberName}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (task.videoUrl != null) ...[
            const SizedBox(height: 12),
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kAppRadius),
                border: Border.all(color: AppColors.line),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kAppRadius - 1),
                child: video_player.createVideoPlayer(task.videoUrl!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VideoExerciseLibrary extends StatelessWidget {
  const _VideoExerciseLibrary({required this.state});

  final AppState state;

  static const _templates = [
    (
      name: 'Barbell Bench Press Technique',
      videoUrl: 'videos/Bench-Press-Chest.mp4',
    ),
    (
      name: 'Chest Press Machine Form',
      videoUrl: 'videos/Chest-Press3.mp4',
    ),
    (
      name: 'Dumbbell Fly Execution',
      videoUrl: 'videos/Dumbbell-Fly-Chest.mp4',
    ),
    (
      name: 'Lever Seated Fly Technique',
      videoUrl: 'videos/Lever-Seated-Fly-Chest.mp4',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPanelHeader(title: 'Exercise Video Library'),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 600;
              final cardWidth = wide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;

              final children = _templates.map((template) {
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
                        template.name,
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
                          child: video_player.createVideoPlayer(template.videoUrl),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _showCreateTaskDialog(
                            context,
                            state,
                            initialTitle: template.name,
                            initialVideoUrl: template.videoUrl,
                          ),
                          icon: const Icon(Icons.send_rounded, size: 16),
                          label: const Text('Assign to Member'),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();

              if (wide) {
                return Wrap(
                  spacing: 16,
                  children: children,
                );
              }
              return Column(children: children);
            },
          ),
        ],
      ),
    );
  }
}

class _PhotoApprovalsPanel extends StatelessWidget {
  const _PhotoApprovalsPanel({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final approvals = state.photoApprovals;

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPanelHeader(
            title: 'Photo approvals',
            action: AppSmallChip(
              label: '${approvals.length} pending',
              color: AppColors.amber.withValues(alpha: 0.15),
              textColor: AppColors.amber,
            ),
          ),
          const SizedBox(height: 14),
          if (approvals.isEmpty)
            const AppEmptyState(
              icon: Icons.photo_library_outlined,
              message: 'No photo submissions are awaiting approval.',
            )
          else
            for (var i = 0; i < approvals.length; i++) ...[
              _ApprovalRow(task: approvals[i], state: state),
              if (i != approvals.length - 1)
                const Divider(height: 18, color: AppColors.line),
            ],
        ],
      ),
    );
  }
}

class _ApprovalRow extends StatelessWidget {
  const _ApprovalRow({required this.task, required this.state});

  final GymTask task;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppIconBadge(icon: Icons.image_outlined, size: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.memberName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 3),
              Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Reject',
          onPressed: () => state.approveTaskPhoto(task.id, false),
          icon: const Icon(Icons.close, color: AppColors.danger),
        ),
        IconButton(
          tooltip: 'Approve',
          onPressed: () => state.approveTaskPhoto(task.id, true),
          icon: const Icon(Icons.check_circle, color: AppColors.success),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Create task dialog
// ---------------------------------------------------------------------------

Future<void> _showCreateTaskDialog(
  BuildContext context,
  AppState state, {
  String? initialTitle,
  String? initialVideoUrl,
}) async {
  final task = await showDialog<GymTask>(
    context: context,
    builder: (_) => _CreateTaskDialog(
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

class _CreateTaskDialog extends StatefulWidget {
  const _CreateTaskDialog({
    required this.state,
    this.initialTitle,
    this.initialVideoUrl,
  });

  final AppState state;
  final String? initialTitle;
  final String? initialVideoUrl;

  @override
  State<_CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<_CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _memberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialTitle != null) {
      _titleController.text = widget.initialTitle!;
    }
    if (widget.state.members.isNotEmpty) {
      _memberController.text = widget.state.members.first.name;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memberController.dispose();
    super.dispose();
  }

  void _create() {
    if (!_formKey.currentState!.validate()) return;
    final task = widget.state.addTask(
      title: _titleController.text,
      memberName: _memberController.text,
      priority: 'Medium',
      dueDate: 'No due date',
      instructions: widget.initialVideoUrl != null
          ? 'Watch the exercise demonstration video and maintain correct posture.'
          : 'Complete the assigned training program.',
      videoUrl: widget.initialVideoUrl,
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
          const AppIconBadge(icon: Icons.add_task, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Create task',
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
                DropdownButtonFormField<String>(
                  value: _memberController.text.isEmpty ? null : _memberController.text,
                  decoration: const InputDecoration(
                    labelText: 'Assign to member',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: widget.state.members.map((m) {
                    return DropdownMenuItem<String>(
                      value: m.name,
                      child: Text(m.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _memberController.text = value ?? '';
                    });
                  },
                  validator: (value) =>
                      (value == null || value.isEmpty)
                      ? 'Select a member.'
                      : null,
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
          onPressed: _create,
          icon: const Icon(Icons.check),
          label: const Text('Create task'),
        ),
      ],
    );
  }
}
