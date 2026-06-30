part of 'admin_dashboard_page.dart';

/// Dashboard tab: headline KPIs, today's summary, and quick statistics.
class _AdminOverviewView extends StatelessWidget {
  const _AdminOverviewView({required this.state, required this.onNavigate});

  final AppState state;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AdminMetricGrid(
          tiles: [
            _AdminMetricTile(
              icon: Icons.people_alt_outlined,
              label: 'Active members',
              value: '${state.activeMembers}',
              color: AppColors.success,
            ),
            _AdminMetricTile(
              icon: Icons.fitness_center_outlined,
              label: 'Active trainers',
              value: '${state.activeTrainers}',
              color: AppColors.amber,
            ),
            _AdminMetricTile(
              icon: Icons.pending_actions_outlined,
              label: 'Pending tasks',
              value: '${state.pendingTasks}',
              color: AppColors.gold,
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumn = constraints.maxWidth >= 880;
            final summary = _TodaySummaryPanel(state: state, onNavigate: onNavigate);
            final stats = _QuickStatsPanel(state: state);
            if (!twoColumn) {
              return Column(
                children: [summary, const SizedBox(height: 16), stats],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: summary),
                const SizedBox(width: 16),
                Expanded(child: stats),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TodaySummaryPanel extends StatelessWidget {
  const _TodaySummaryPanel({required this.state, required this.onNavigate});

  final AppState state;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      color: AppColors.charcoal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPanelHeader(title: "Today's summary"),
          const SizedBox(height: 14),
          AppDetailRow(
            icon: Icons.event_available_outlined,
            label: 'Check-ins today',
            value: '${state.todayAttendance}',
          ),
          AppDetailRow(
            icon: Icons.photo_library_outlined,
            label: 'Photo approvals pending',
            value: '${state.photoApprovals.length}',
          ),
          AppDetailRow(
            icon: Icons.warning_amber_outlined,
            label: 'Expired memberships',
            value: '${state.expiredMembers}',
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () => onNavigate(1),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Members'),
              ),
              OutlinedButton.icon(
                onPressed: () => onNavigate(2),
                icon: const Icon(Icons.fitness_center),
                label: const Text('Trainers'),
              ),
              OutlinedButton.icon(
                onPressed: () => onNavigate(3),
                icon: const Icon(Icons.add_task),
                label: const Text('Tasks'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickStatsPanel extends StatelessWidget {
  const _QuickStatsPanel({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final totalMembers = state.totalMembers;
    final totalTasks = state.tasks.length;

    double ratio(int part, int whole) => whole == 0 ? 0 : part / whole;

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPanelHeader(title: 'Quick statistics'),
          const SizedBox(height: 16),
          _StatMeter(
            label: 'Active members',
            detail: '${state.activeMembers} of $totalMembers',
            value: ratio(state.activeMembers, totalMembers),
          ),
          const SizedBox(height: 14),
          _StatMeter(
            label: 'Tasks completed',
            detail: '${state.completedTasks} of $totalTasks',
            value: ratio(state.completedTasks, totalTasks),
          ),
          const SizedBox(height: 14),
          _StatMeter(
            label: 'Tasks in progress',
            detail: '${state.inProgressTasks} of $totalTasks',
            value: ratio(state.inProgressTasks, totalTasks),
          ),
        ],
      ),
    );
  }
}

class _StatMeter extends StatelessWidget {
  const _StatMeter({
    required this.label,
    required this.detail,
    required this.value,
  });

  final String label;
  final String detail;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              detail,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppLoadMeter(value: value),
      ],
    );
  }
}
