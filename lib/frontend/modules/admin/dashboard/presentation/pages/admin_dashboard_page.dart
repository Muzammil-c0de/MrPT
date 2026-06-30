import 'package:fitness_webapp/backend/backend.dart';
import 'package:fitness_webapp/frontend/theme/app_theme.dart';
import 'package:fitness_webapp/frontend/widgets/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:fitness_webapp/frontend/widgets/video_player_stub.dart'
    if (dart.library.html) 'package:fitness_webapp/frontend/widgets/video_player_web.dart' as video_player;

part 'admin_overview_view.dart';
part 'admin_members_view.dart';
part 'admin_trainers_view.dart';
part 'admin_tasks_view.dart';
part 'admin_more_view.dart';
part 'admin_add_trainer_dialog.dart';

/// The Super Admin console shell: a top bar, a five-section bottom navigation
/// rail (Dashboard · Members · Trainers · Tasks · More) and the active view.
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _pageIndex = 0;

  static const _sections = [
    (title: 'Dashboard', subtitle: 'Platform overview and today\'s activity.'),
    (title: 'Members', subtitle: 'Memberships, plans, renewals and search.'),
    (title: 'Trainers', subtitle: 'Create trainers, assign members and tasks.'),
    (title: 'Tasks', subtitle: 'Create, track and approve trainer tasks.'),
    (title: 'More', subtitle: 'Reports, payments, settings and account.'),
  ];

  void _goTo(int index) => setState(() => _pageIndex = index);

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final section = _sections[_pageIndex];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      wide ? 36 : 18,
                      wide ? 28 : 18,
                      wide ? 36 : 18,
                      wide ? 36 : 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AdminTopBar(
                          title: section.title,
                          subtitle: section.subtitle,
                          compact: !wide,
                          admin: state.currentUser ?? state.admin,
                        ),
                        const SizedBox(height: 22),
                        switch (_pageIndex) {
                          0 => _AdminOverviewView(state: state, onNavigate: _goTo),
                          1 => _AdminMembersView(state: state),
                          2 => _AdminTrainersView(state: state),
                          3 => _AdminTasksView(state: state),
                          _ => _AdminMoreView(state: state),
                        },
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: _AdminBottomNav(
            selectedIndex: _pageIndex,
            onSelect: _goTo,
            wide: wide,
          ),
        );
      },
    );
  }
}

class _AdminTopBar extends StatelessWidget {
  const _AdminTopBar({
    required this.title,
    required this.subtitle,
    required this.compact,
    required this.admin,
  });

  final String title;
  final String subtitle;
  final bool compact;
  final AppUser admin;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(
      context,
    ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900);

    Widget titleBlock() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: titleStyle),
          const SizedBox(height: 5),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        ],
      );
    }

    final profile = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppStatusPill(icon: Icons.shield_outlined, label: 'Admin console'),
        const SizedBox(width: 12),
        Tooltip(
          message: admin.name,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.yellow,
            child: Text(
              initialsFor(admin.name),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppBrandLockup(compact: true),
          const SizedBox(height: 14),
          titleBlock(),
          const SizedBox(height: 14),
          profile,
        ],
      );
    }

    return Row(
      children: [
        const AppBrandLockup(),
        const SizedBox(width: 24),
        Container(width: 1, height: 44, color: AppColors.line),
        const SizedBox(width: 24),
        Expanded(child: titleBlock()),
        const SizedBox(width: 18),
        profile,
      ],
    );
  }
}

class _AdminBottomNav extends StatelessWidget {
  const _AdminBottomNav({
    required this.selectedIndex,
    required this.onSelect,
    required this.wide,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool wide;

  static const _items = [
    (icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: 'Dashboard'),
    (icon: Icons.people_alt_outlined, selectedIcon: Icons.people_alt, label: 'Members'),
    (icon: Icons.fitness_center_outlined, selectedIcon: Icons.fitness_center, label: 'Trainers'),
    (icon: Icons.assignment_outlined, selectedIcon: Icons.assignment, label: 'Tasks'),
    (icon: Icons.menu, selectedIcon: Icons.menu_open, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        border: const Border(top: BorderSide(color: AppColors.line)),
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
          padding: EdgeInsets.fromLTRB(wide ? 24 : 6, 8, wide ? 24 : 6, 8),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: wide ? 760 : double.infinity),
              child: SizedBox(
                height: 62,
                child: Row(
                  children: [
                    for (var index = 0; index < _items.length; index++)
                      Expanded(
                        child: _AdminNavItem(
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

class _AdminNavItem extends StatelessWidget {
  const _AdminNavItem({
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
    final color = selected ? AppColors.charcoal : AppColors.muted;

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kAppRadius),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 54,
              height: 30,
              decoration: BoxDecoration(
                color: selected ? AppColors.yellow : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: selected ? null : Border.all(color: AppColors.line),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? AppColors.yellow : AppColors.muted,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small shared building blocks used across the admin views.
// ---------------------------------------------------------------------------

/// A square KPI tile (icon, label, value).
class _AdminMetricTile extends StatelessWidget {
  const _AdminMetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconBadge(icon: icon, color: color),
          const Spacer(),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

/// Lays out metric tiles in a responsive grid.
class _AdminMetricGrid extends StatelessWidget {
  const _AdminMetricGrid({required this.tiles});

  final List<_AdminMetricTile> tiles;

  @override
  Widget build(BuildContext context) {
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
          children: [
            for (final tile in tiles)
              SizedBox(width: itemWidth, height: 138, child: tile),
          ],
        );
      },
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String _money(double value) => '\$${value.toStringAsFixed(0)}';
