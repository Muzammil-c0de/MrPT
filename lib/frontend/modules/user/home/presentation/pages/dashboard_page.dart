part of 'home_page.dart';

class _DashboardView extends StatelessWidget {
  const _DashboardView({
    required this.trainer,
    required this.members,
    required this.tasks,
    required this.taskStatuses,
    required this.completedTasks,
    required this.pendingTasks,
    required this.activities,
    required this.notifications,
    required this.uploads,
    required this.programs,
  });

  final TrainerProfile trainer;
  final List<TrainerMember> members;
  final List<TrainerTask> tasks;
  final List<TaskStatus> taskStatuses;
  final int completedTasks;
  final int pendingTasks;
  final List<ActivityItem> activities;
  final List<PortalNotification> notifications;
  final List<PhotoUpload> uploads;
  final List<WorkoutProgram> programs;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumn = constraints.maxWidth >= 1040;

        final primary = Column(
          children: [
            _WelcomeOverview(
              trainer: trainer,
              completedTasks: completedTasks,
              pendingTasks: pendingTasks,
            ),
            const SizedBox(height: 16),
            _PortalMetricGrid(
              assignedMembers: members.length,
              assignedTasks: tasks.length,
              completedTasks: completedTasks,
              pendingTasks: pendingTasks,
            ),
            const SizedBox(height: 16),
            _RecentActivitiesPanel(activities: activities),
          ],
        );

        final secondary = Column(
          children: [
            _NotificationsPanel(notifications: notifications),
            const SizedBox(height: 16),
            _UploadHistoryPanel(uploads: uploads.take(3).toList()),
            const SizedBox(height: 16),
            _ProgramsPreviewPanel(programs: programs),
          ],
        );

        if (!twoColumn) {
          return Column(
            children: [primary, const SizedBox(height: 16), secondary],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: primary),
            const SizedBox(width: 16),
            Expanded(flex: 4, child: secondary),
          ],
        );
      },
    );
  }
}

class _WelcomeOverview extends StatelessWidget {
  const _WelcomeOverview({
    required this.trainer,
    required this.completedTasks,
    required this.pendingTasks,
  });

  final TrainerProfile trainer;
  final int completedTasks;
  final int pendingTasks;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      color: _charcoal,
      borderColor: _line,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 680;

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _StatusPill(
                icon: Icons.workspace_premium_outlined,
                label: 'FitPilot',
                color: _yellow,
                dark: true,
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome, ${trainer.name}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                trainer.bio,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SmallChip(
                    label: '$completedTasks completed',
                    color: _yellow,
                    textColor: _charcoal,
                  ),
                  _SmallChip(
                    label: '$pendingTasks pending',
                    color: _surfaceAlt,
                    textColor: _yellow,
                  ),
                  for (final specialty in trainer.specialties.take(2))
                    _SmallChip(
                      label: specialty,
                      color: Colors.white.withValues(alpha: 0.1),
                      textColor: Colors.white,
                    ),
                ],
              ),
            ],
          );

          final visual = TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.82, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: SizedBox(
              height: compact ? 180 : 270,
              child: CustomPaint(
                painter: const _TrainingVisualPainter(accent: _yellow),
                child: const Center(
                  child: Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 74,
                  ),
                ),
              ),
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [visual, const SizedBox(height: 18), content],
            );
          }

          return Row(
            children: [
              Expanded(flex: 5, child: content),
              const SizedBox(width: 24),
              Expanded(flex: 4, child: visual),
            ],
          );
        },
      ),
    );
  }
}

class _PortalMetricGrid extends StatelessWidget {
  const _PortalMetricGrid({
    required this.assignedMembers,
    required this.assignedTasks,
    required this.completedTasks,
    required this.pendingTasks,
  });

  final int assignedMembers;
  final int assignedTasks;
  final int completedTasks;
  final int pendingTasks;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _PortalMetric(
        icon: Icons.groups_outlined,
        label: 'Assigned members',
        value: '$assignedMembers',
        detail: 'Trainer roster',
        progress: 1,
        color: _yellow,
      ),
      _PortalMetric(
        icon: Icons.assignment_outlined,
        label: 'Assigned tasks',
        value: '$assignedTasks',
        detail: 'Open workflow',
        progress: assignedTasks == 0 ? 0.0 : pendingTasks / assignedTasks,
        color: _amber,
      ),
      _PortalMetric(
        icon: Icons.task_alt,
        label: 'Completed tasks',
        value: '$completedTasks',
        detail: 'Updated by trainer',
        progress: assignedTasks == 0 ? 0.0 : completedTasks / assignedTasks,
        color: _gold,
      ),
      _PortalMetric(
        icon: Icons.pending_actions_outlined,
        label: 'Pending tasks',
        value: '$pendingTasks',
        detail: 'Needs attention',
        progress: assignedTasks == 0 ? 0.0 : pendingTasks / assignedTasks,
        color: _yellow,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 920
            ? 4
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        final spacing = (columns - 1) * 14;
        final itemWidth = (constraints.maxWidth - spacing) / columns;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: itemWidth,
                  height: 160,
                  child: _PortalMetricTile(metric: metric),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _PortalMetric {
  const _PortalMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    required this.progress,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final double progress;
  final Color color;
}

class _PortalMetricTile extends StatelessWidget {
  const _PortalMetricTile({required this.metric});

  final _PortalMetric metric;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBadge(icon: metric.icon, color: metric.color),
              const Spacer(),
              Text(
                '${(metric.progress.clamp(0, 1) * 100).round()}%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: metric.color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            metric.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: _muted),
          ),
          const SizedBox(height: 4),
          Text(
            metric.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _LoadMeter(value: metric.progress, color: metric.color),
        ],
      ),
    );
  }
}

class _RecentActivitiesPanel extends StatelessWidget {
  const _RecentActivitiesPanel({required this.activities});

  final List<ActivityItem> activities;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(title: 'Recent activities'),
          const SizedBox(height: 8),
          for (var index = 0; index < activities.length; index++) ...[
            _ActivityRow(activity: activities[index]),
            if (index != activities.length - 1)
              const Divider(height: 1, color: _line),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final ActivityItem activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          _IconBadge(icon: activity.icon, color: _yellow, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            activity.time,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: _yellow,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsPanel extends StatelessWidget {
  const _NotificationsPanel({required this.notifications});

  final List<PortalNotification> notifications;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(title: 'Notifications'),
          const SizedBox(height: 8),
          for (final notification in notifications)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IconBadge(icon: notification.icon, color: _amber, size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                            Text(
                              notification.time,
                              style: Theme.of(
                                context,
                              ).textTheme.labelMedium?.copyWith(color: _muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.detail,
                          maxLines: 2,
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
            ),
        ],
      ),
    );
  }
}

class _UploadHistoryPanel extends StatelessWidget {
  const _UploadHistoryPanel({required this.uploads});

  final List<PhotoUpload> uploads;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(title: 'Upload history'),
          const SizedBox(height: 12),
          if (uploads.isEmpty)
            const _EmptyState(
              icon: Icons.photo_library_outlined,
              message: 'No trainer uploads yet.',
            )
          else
            for (final upload in uploads)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _UploadTile(upload: upload),
              ),
        ],
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({required this.upload});

  final PhotoUpload upload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _charcoal,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          _IconBadge(icon: Icons.image_outlined, color: _yellow, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${upload.category} / ${upload.memberName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  upload.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            upload.submittedAt,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: _muted),
          ),
        ],
      ),
    );
  }
}

class _ProgramsPreviewPanel extends StatelessWidget {
  const _ProgramsPreviewPanel({required this.programs});

  final List<WorkoutProgram> programs;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(title: 'Workout programs'),
          const SizedBox(height: 14),
          for (final program in programs)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          program.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Text(
                        '${(program.progress * 100).round()}%',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: _yellow,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${program.memberName} / ${program.schedule}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: _muted),
                  ),
                  const SizedBox(height: 8),
                  _LoadMeter(value: program.progress, color: _yellow),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
