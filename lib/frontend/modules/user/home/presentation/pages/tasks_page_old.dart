part of 'home_page.dart';

class _TasksView extends StatelessWidget {
  const _TasksView({
    required this.tasks,
    required this.selectedTask,
    required this.taskStatuses,
    required this.taskNotes,
    required this.uploads,
    required this.programs,
    required this.onSelectTask,
    required this.onStatusChanged,
    required this.onNoteChanged,
    required this.onUpload,
  });

  final List<TrainerTask> tasks;
  final int selectedTask;
  final List<TaskStatus> taskStatuses;
  final Map<int, String> taskNotes;
  final List<PhotoUpload> uploads;
  final List<WorkoutProgram> programs;
  final ValueChanged<int> onSelectTask;
  final void Function(int index, TaskStatus status) onStatusChanged;
  final void Function(int index, String note) onNoteChanged;
  final void Function(String category, String memberName, String description)
  onUpload;

  @override
  Widget build(BuildContext context) {
    final activeTask = tasks[selectedTask];
    final activeStatus = taskStatuses[selectedTask];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1020;

        final taskList = _TaskListPanel(
          tasks: tasks,
          taskStatuses: taskStatuses,
          selectedTask: selectedTask,
          onSelectTask: onSelectTask,
        );

        final detail = Column(
          children: [
            _TaskDetailPanel(task: activeTask, status: activeStatus),
            const SizedBox(height: 16),
            _TaskProgressPanel(
              taskIndex: selectedTask,
              task: activeTask,
              status: activeStatus,
              note: taskNotes[selectedTask] ?? '',
              onStatusChanged: onStatusChanged,
              onNoteChanged: onNoteChanged,
            ),
            const SizedBox(height: 16),
            _PhotoUploadPanel(task: activeTask, onUpload: onUpload),
          ],
        );

        final supporting = Column(
          children: [
            _WorkoutProgramsPanel(programs: programs),
            const SizedBox(height: 16),
            _UploadHistoryPanel(uploads: uploads),
          ],
        );

        if (!wide) {
          return Column(
            children: [
              taskList,
              const SizedBox(height: 16),
              detail,
              const SizedBox(height: 16),
              supporting,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: taskList),
            const SizedBox(width: 16),
            Expanded(flex: 5, child: detail),
            const SizedBox(width: 16),
            Expanded(flex: 4, child: supporting),
          ],
        );
      },
    );
  }
}

class _TaskListPanel extends StatelessWidget {
  const _TaskListPanel({
    required this.tasks,
    required this.taskStatuses,
    required this.selectedTask,
    required this.onSelectTask,
  });

  final List<TrainerTask> tasks;
  final List<TaskStatus> taskStatuses;
  final int selectedTask;
  final ValueChanged<int> onSelectTask;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            title: 'Assigned tasks',
            action: _SmallChip(
              label: '${tasks.length} total',
              color: _yellow,
              textColor: _charcoal,
            ),
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < tasks.length; index++) ...[
            _TaskListTile(
              task: tasks[index],
              status: taskStatuses[index],
              selected: index == selectedTask,
              onTap: () => onSelectTask(index),
            ),
            if (index != tasks.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _TaskListTile extends StatelessWidget {
  const _TaskListTile({
    required this.task,
    required this.status,
    required this.selected,
    required this.onTap,
  });

  final TrainerTask task;
  final TaskStatus status;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? _surfaceAlt : _charcoal,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: selected ? _yellow : _line),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _IconBadge(icon: task.icon, color: selected ? _yellow : _amber),
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
                    const SizedBox(height: 8),
                    _SmallChip(
                      label: status.label,
                      color: status.color.withValues(alpha: 0.15),
                      textColor: status.color,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskDetailPanel extends StatelessWidget {
  const _TaskDetailPanel({required this.task, required this.status});

  final TrainerTask task;
  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      color: _charcoal,
      borderColor: _line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _IconBadge(icon: task.icon, color: _yellow, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (task.videoUrl != null) ...[
            const SizedBox(height: 18),
            const Divider(color: _line, height: 1),
            const SizedBox(height: 14),
            Text(
              'Workout procedure:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: _yellow,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_radius),
                border: Border.all(color: _line),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_radius - 1),
                child: video_player.createVideoPlayer(task.videoUrl!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TaskProgressPanel extends StatelessWidget {
  const _TaskProgressPanel({
    required this.taskIndex,
    required this.task,
    required this.status,
    required this.note,
    required this.onStatusChanged,
    required this.onNoteChanged,
  });

  final int taskIndex;
  final TrainerTask task;
  final TaskStatus status;
  final String note;
  final void Function(int index, TaskStatus status) onStatusChanged;
  final void Function(int index, String note) onNoteChanged;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(title: 'Task progress'),
          const SizedBox(height: 16),
          SegmentedButton<TaskStatus>(
            selected: {status},
            showSelectedIcon: false,
            onSelectionChanged: (selected) {
              onStatusChanged(taskIndex, selected.first);
            },
            segments: const [
              ButtonSegment(
                value: TaskStatus.pending,
                icon: Icon(Icons.pending_actions_outlined),
                label: Text('Pending'),
              ),
              ButtonSegment(
                value: TaskStatus.inProgress,
                icon: Icon(Icons.sync),
                label: Text('In progress'),
              ),
              ButtonSegment(
                value: TaskStatus.completed,
                icon: Icon(Icons.task_alt),
                label: Text('Completed'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () =>
                      onStatusChanged(taskIndex, TaskStatus.inProgress),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Mark in progress'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      onStatusChanged(taskIndex, TaskStatus.completed),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark completed'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: ValueKey('task-note-$taskIndex'),
            initialValue: note,
            maxLines: 4,
            onChanged: (value) => onNoteChanged(taskIndex, value),
            decoration: InputDecoration(
              labelText: 'Notes and remarks for ${task.memberName}',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoUploadPanel extends StatelessWidget {
  const _PhotoUploadPanel({required this.task, required this.onUpload});

  final TrainerTask task;
  final void Function(String category, String memberName, String description)
  onUpload;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        label: 'Workout photo',
        icon: Icons.fitness_center,
        description: 'Workout set photo for ${task.title}',
      ),
      (
        label: 'Progress photo',
        icon: Icons.timeline_outlined,
        description: 'Progress checkpoint for ${task.memberName}',
      ),
      (
        label: 'Before/After',
        icon: Icons.compare_outlined,
        description: 'Before/after comparison for ${task.program}',
      ),
    ];

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(title: 'Photo upload system'),
          const SizedBox(height: 14),
          for (final action in actions)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton.icon(
                onPressed: () =>
                    onUpload(action.label, task.memberName, action.description),
                icon: Icon(action.icon),
                label: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(action.label),
                ),
              ),
            ),
          TextFormField(
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Photo description',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutProgramsPanel extends StatelessWidget {
  const _WorkoutProgramsPanel({required this.programs});

  final List<WorkoutProgram> programs;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(title: 'Assigned workout plans'),
          const SizedBox(height: 14),
          for (final program in programs)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _charcoal,
                  borderRadius: BorderRadius.circular(_radius),
                  border: Border.all(color: _line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _IconBadge(
                          icon: Icons.calendar_view_week_outlined,
                          color: _yellow,
                          size: 40,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                program.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${program.memberName} / ${program.schedule}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(color: _muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _LoadMeter(value: program.progress, color: _yellow),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final exercise in program.exercises)
                          _SmallChip(
                            label: exercise,
                            color: _surfaceAlt,
                            textColor: _ink,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      'High' => _yellow,
      'Medium' => _amber,
      _ => _muted,
    };

    return _SmallChip(
      label: '$priority priority',
      color: color.withValues(alpha: 0.15),
      textColor: color,
    );
  }
}
