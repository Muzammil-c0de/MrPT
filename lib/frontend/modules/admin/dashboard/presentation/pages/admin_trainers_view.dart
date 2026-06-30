part of 'admin_dashboard_page.dart';

/// Trainers tab: directory + create, enable/disable, assign tasks, performance.
class _AdminTrainersView extends StatelessWidget {
  const _AdminTrainersView({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final trainers = state.trainers;

    return Column(
      children: [
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final tight = constraints.maxWidth < 460;
                  final header = AppPanelHeader(
                    title: 'All trainers',
                    action: tight
                        ? null
                        : AppSmallChip(
                            label: '${trainers.length} total',
                            color: AppColors.yellow,
                            textColor: AppColors.charcoal,
                          ),
                  );
                  final addButton = SizedBox(
                    width: tight ? double.infinity : null,
                    child: FilledButton.icon(
                      onPressed: () => _showAddTrainerDialog(context, state),
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Add trainer'),
                    ),
                  );
                  if (tight) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [header, const SizedBox(height: 14), addButton],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: header),
                      const SizedBox(width: 12),
                      addButton,
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              if (trainers.isEmpty)
                const AppEmptyState(
                  icon: Icons.group_add_outlined,
                  message:
                      'No trainers yet. Use "Add trainer" to create the first '
                      'account with a name and password.',
                )
              else
                for (var i = 0; i < trainers.length; i++) ...[
                  _TrainerCard(trainer: trainers[i], state: state),
                  if (i != trainers.length - 1) const SizedBox(height: 12),
                ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _TrainerPerformancePanel(state: state),
      ],
    );
  }
}

class _TrainerCard extends StatelessWidget {
  const _TrainerCard({required this.trainer, required this.state});

  final AppUser trainer;
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
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: AppColors.surfaceAlt,
                child: Text(
                  initialsFor(trainer.name),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.yellow,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trainer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${trainer.id}  ·  ${state.membersOfTrainer(trainer.id)} members',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AppSmallChip(
                label: trainer.active ? 'Active' : 'Disabled',
                color: (trainer.active ? AppColors.success : AppColors.muted)
                    .withValues(alpha: 0.15),
                textColor: trainer.active ? AppColors.success : AppColors.muted,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule, size: 15, color: AppColors.muted),
              const SizedBox(width: 6),
              Text(
                'Joined ${_formatDate(trainer.createdAt)}',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () =>
                    _showCreateTaskDialog(context, state, trainerId: trainer.id),
                icon: const Icon(Icons.add_task, size: 18),
                label: const Text('Assign task'),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    state.setTrainerActive(trainer.id, !trainer.active),
                icon: Icon(
                  trainer.active
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                  size: 18,
                ),
                label: Text(trainer.active ? 'Disable' : 'Enable'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrainerPerformancePanel extends StatelessWidget {
  const _TrainerPerformancePanel({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final trainers = state.trainers;

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPanelHeader(title: 'Trainer performance'),
          const SizedBox(height: 14),
          if (trainers.isEmpty)
            const AppEmptyState(
              icon: Icons.insights_outlined,
              message: 'Performance appears once trainers have assigned tasks.',
            )
          else
            for (final trainer in trainers)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            trainer.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Text(
                          '${(state.trainerPerformance(trainer.id) * 100).round()}%',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.yellow,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppLoadMeter(value: state.trainerPerformance(trainer.id)),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
