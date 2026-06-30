part of 'home_page.dart';

class _MembersView extends StatelessWidget {
  const _MembersView({
    required this.members,
    required this.selectedMember,
    required this.onSelectMember,
  });

  final List<TrainerMember> members;
  final int selectedMember;
  final ValueChanged<int> onSelectMember;

  @override
  Widget build(BuildContext context) {
    final activeMember = members[selectedMember];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;

        final roster = _MemberRosterPanel(
          members: members,
          selectedMember: selectedMember,
          onSelectMember: onSelectMember,
        );

        final detail = _MemberDetailPanel(member: activeMember);

        if (!wide) {
          return Column(children: [roster, const SizedBox(height: 16), detail]);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: roster),
            const SizedBox(width: 16),
            Expanded(flex: 4, child: detail),
          ],
        );
      },
    );
  }
}

class _MemberRosterPanel extends StatelessWidget {
  const _MemberRosterPanel({
    required this.members,
    required this.selectedMember,
    required this.onSelectMember,
  });

  final List<TrainerMember> members;
  final int selectedMember;
  final ValueChanged<int> onSelectMember;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            title: 'Assigned members',
            action: _SmallChip(
              label: '${members.length} active',
              color: _yellow,
              textColor: _charcoal,
            ),
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < members.length; index++) ...[
            _MemberCard(
              member: members[index],
              selected: index == selectedMember,
              onTap: () => onSelectMember(index),
            ),
            if (index != members.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.member,
    required this.selected,
    required this.onTap,
  });

  final TrainerMember member;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: selected ? _yellow : _surface,
                    child: Text(
                      _initialsFor(member.name),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: selected ? _charcoal : _yellow,
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
                          member.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          member.goal,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: _muted),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    selected ? Icons.check_circle : Icons.chevron_right,
                    color: selected ? _yellow : _muted,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _MiniProgress(
                      label: 'Progress',
                      value: member.progress,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniProgress(
                      label: 'Attendance',
                      value: member.attendance,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Next: ${member.nextSession}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: _yellow,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberDetailPanel extends StatelessWidget {
  const _MemberDetailPanel({required this.member});

  final TrainerMember member;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Panel(
          color: _charcoal,
          borderColor: _line,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _yellow,
                    child: Text(
                      _initialsFor(member.name),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _charcoal,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          member.plan,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: _muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in member.tags)
                    _SmallChip(
                      label: tag,
                      color: _surfaceAlt,
                      textColor: _yellow,
                    ),
                ],
              ),
              const SizedBox(height: 18),
              _DetailRow(
                icon: Icons.track_changes,
                label: 'Goal',
                value: member.goal,
              ),
              _DetailRow(
                icon: Icons.calendar_month_outlined,
                label: 'Next session',
                value: member.nextSession,
              ),
              _DetailRow(
                icon: Icons.notes_outlined,
                label: 'Latest trainer note',
                value: member.lastCheckIn,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PanelHeader(title: 'Progress tracking'),
              const SizedBox(height: 18),
              _ProgressStat(
                label: 'Workout plan progress',
                value: member.progress,
                icon: Icons.fitness_center,
              ),
              const SizedBox(height: 16),
              _ProgressStat(
                label: 'Attendance consistency',
                value: member.attendance,
                icon: Icons.event_available_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PanelHeader(title: 'Attendance history'),
              const SizedBox(height: 8),
              for (final entry in member.attendanceHistory)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: _yellow,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniProgress extends StatelessWidget {
  const _MiniProgress({required this.label, required this.value});

  final String label;
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: _muted),
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: _yellow,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        _LoadMeter(value: value, color: _yellow),
      ],
    );
  }
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final double value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBadge(icon: icon, color: _yellow, size: 42),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${(value * 100).round()}%',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: _yellow,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              _LoadMeter(value: value, color: _yellow),
            ],
          ),
        ),
      ],
    );
  }
}

String _initialsFor(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return parts.first
        .substring(0, math.min(2, parts.first.length))
        .toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
