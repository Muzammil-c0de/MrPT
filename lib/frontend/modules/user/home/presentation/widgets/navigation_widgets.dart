part of '../pages/home_page.dart';

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.compact,
    required this.trainer,
    this.onLogout,
  });

  final String title;
  final String subtitle;
  final bool compact;
  final TrainerProfile trainer;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: 0,
    );

    Widget titleBlock() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: titleStyle,
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: _muted),
          ),
        ],
      );
    }

    final profile = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _StatusPill(
          icon: Icons.verified_outlined,
          label: 'Trainer portal',
          color: _yellow,
        ),
        const SizedBox(width: 12),
        Tooltip(
          message: trainer.name,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: _yellow,
            child: Text(
              trainer.initials,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: _charcoal,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        if (onLogout != null) ...[
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Sign out',
            onPressed: onLogout,
            icon: const Icon(Icons.logout, color: _muted),
          ),
        ],
      ],
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandLockup(compact: true),
          const SizedBox(height: 14),
          titleBlock(),
          const SizedBox(height: 14),
          profile,
        ],
      );
    }

    return Row(
      children: [
        const _BrandLockup(),
        const SizedBox(width: 24),
        Container(width: 1, height: 44, color: _line),
        const SizedBox(width: 24),
        Expanded(child: titleBlock()),
        const SizedBox(width: 18),
        profile,
      ],
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final markSize = compact ? 40.0 : 44.0;
    final iconSize = compact ? 22.0 : 24.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: markSize,
          height: markSize,
          decoration: BoxDecoration(
            color: _yellow,
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Icon(Icons.fitness_center, color: _charcoal, size: iconSize),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MrPT',
              style:
                  (compact
                          ? Theme.of(context).textTheme.titleMedium
                          : Theme.of(context).textTheme.titleLarge)
                      ?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(
              'Fitness',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: _yellow,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AppBottomNav extends StatelessWidget {
  const _AppBottomNav({
    required this.selectedIndex,
    required this.onSelect,
    required this.wide,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool wide;

  static const _items = [
    (
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    (icon: Icons.groups_outlined, selectedIcon: Icons.groups, label: 'Members'),
    (
      icon: Icons.assignment_outlined,
      selectedIcon: Icons.assignment,
      label: 'Tasks',
    ),
    (icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _charcoal,
        border: const Border(top: BorderSide(color: _line)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(wide ? 24 : 10, 8, wide ? 24 : 10, 8),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: wide ? 720 : double.infinity,
              ),
              child: SizedBox(
                height: 62,
                child: Row(
                  children: [
                    for (var index = 0; index < _items.length; index++)
                      Expanded(
                        child: _BottomNavItem(
                          icon: selectedIndex == index
                              ? _items[index].selectedIcon
                              : _items[index].icon,
                          label: _items[index].label,
                          selected: selectedIndex == index,
                          onTap: () => onSelect(index),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _charcoal : _muted;

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 58,
              height: 32,
              decoration: BoxDecoration(
                color: selected ? _yellow : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: selected ? null : Border.all(color: _line),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? _yellow : _muted,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
