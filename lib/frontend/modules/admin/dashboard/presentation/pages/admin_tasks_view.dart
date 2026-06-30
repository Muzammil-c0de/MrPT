part of 'admin_dashboard_page.dart';

/// Tasks tab: create/assign tasks, filter by status, and approve photos.
class _AdminTasksView extends StatefulWidget {
  const _AdminTasksView({required this.state});

  final AppState state;

  @override
  State<_AdminTasksView> createState() => _AdminTasksViewState();
}

class _AdminTasksViewState extends State<_AdminTasksView> {
  GymTaskStatus? _filter; // null == all

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final tasks = _filter == null
        ? state.tasks
        : state.tasksByStatus(_filter!);

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
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    label: 'All (${state.tasks.length})',
                    selected: _filter == null,
                    onTap: () => setState(() => _filter = null),
                  ),
                  _FilterChip(
                    label: 'Pending (${state.pendingTasks})',
                    selected: _filter == GymTaskStatus.pending,
                    onTap: () => setState(() => _filter = GymTaskStatus.pending),
                  ),
                  _FilterChip(
                    label: 'In progress (${state.inProgressTasks})',
                    selected: _filter == GymTaskStatus.inProgress,
                    onTap: () =>
                        setState(() => _filter = GymTaskStatus.inProgress),
                  ),
                  _FilterChip(
                    label: 'Completed (${state.completedTasks})',
                    selected: _filter == GymTaskStatus.completed,
                    onTap: () =>
                        setState(() => _filter = GymTaskStatus.completed),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (tasks.isEmpty)
                const AppEmptyState(
                  icon: Icons.assignment_outlined,
                  message: 'No tasks in this view. Create one to get started.',
                )
              else
                for (var i = 0; i < tasks.length; i++) ...[
                  _TaskCard(task: tasks[i], state: state),
                  if (i != tasks.length - 1) const SizedBox(height: 12),
                ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PhotoApprovalsPanel(state: state),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.yellow : AppColors.charcoal,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? AppColors.yellow : AppColors.line),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? AppColors.charcoal : AppColors.muted,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.state});

  final GymTask task;
  final AppState state;

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
              AppIconBadge(icon: task.status.icon),
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
                      'Assigned to: ${state.trainerName(task.trainerId)}',
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
              const SizedBox(width: 10),
              AppSmallChip(
                label: task.status.label,
                color: AppColors.surfaceAlt,
                textColor: AppColors.yellow,
              ),
            ],
          ),
          if (task.videoUrl != null) ...[
            const SizedBox(height: 12),
            Container(
              height: 180,
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
          const SizedBox(height: 12),
          _StatusMenuButton(task: task, state: state),
        ],
      ),
    );
  }
}

class _StatusMenuButton extends StatelessWidget {
  const _StatusMenuButton({required this.task, required this.state});

  final GymTask task;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<GymTaskStatus>(
      tooltip: 'Change status',
      color: AppColors.surface,
      onSelected: (status) => state.setTaskStatus(task.id, status),
      itemBuilder: (context) => [
        for (final status in GymTaskStatus.values)
          PopupMenuItem(value: status, child: Text(status.label)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kAppRadius),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flag_outlined, size: 18, color: AppColors.ink),
            const SizedBox(width: 8),
            Text(
              'Set status',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.muted),
          ],
        ),
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
  String? trainerId,
}) async {
  if (state.trainers.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add a trainer before creating tasks.')),
    );
    return;
  }
  final task = await showDialog<GymTask>(
    context: context,
    builder: (_) => _CreateTaskDialog(state: state, initialTrainerId: trainerId),
  );
  if (task != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task ${task.id} assigned to ${state.trainerName(task.trainerId)}.')),
    );
  }
}

class _CreateTaskDialog extends StatefulWidget {
  const _CreateTaskDialog({required this.state, this.initialTrainerId});

  final AppState state;
  final String? initialTrainerId;

  @override
  State<_CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<_CreateTaskDialog> {

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  late String _trainerId =
      widget.initialTrainerId ?? widget.state.trainers.first.id;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _create() {
    if (!_formKey.currentState!.validate()) return;
    final task = widget.state.addTask(
      title: _titleController.text,
      trainerId: _trainerId,
      memberName: 'N/A',
      priority: 'Medium',
      dueDate: 'No due date',
      instructions: '',
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
                  initialValue: _trainerId,
                  decoration: const InputDecoration(
                    labelText: 'Assign to trainer',
                    prefixIcon: Icon(Icons.fitness_center_outlined),
                  ),
                  dropdownColor: AppColors.surface,
                  items: [
                    for (final trainer in widget.state.trainers)
                      DropdownMenuItem(
                        value: trainer.id,
                        child: Text(trainer.name),
                      ),
                  ],
                  onChanged: (value) => setState(() => _trainerId = value!),
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
