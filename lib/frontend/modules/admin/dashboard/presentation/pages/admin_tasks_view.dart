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
  AppState state,
) async {
  final task = await showDialog<GymTask>(
    context: context,
    builder: (_) => _CreateTaskDialog(state: state),
  );
  if (task != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task ${task.id} assigned to ${task.memberName}.')),
    );
  }
}

class _CreateTaskDialog extends StatefulWidget {
  const _CreateTaskDialog({required this.state});

  final AppState state;

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
                TextFormField(
                  controller: _memberController,
                  decoration: const InputDecoration(
                    labelText: 'Assign to member',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                      ? 'Enter a member name.'
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
