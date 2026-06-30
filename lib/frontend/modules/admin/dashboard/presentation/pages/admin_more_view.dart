part of 'admin_dashboard_page.dart';

/// More tab: account header + a menu routing to the secondary admin screens.
class _AdminMoreView extends StatelessWidget {
  const _AdminMoreView({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final admin = state.currentUser ?? state.admin;

    void open(Widget page) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    }

    return Column(
      children: [
        AppPanel(
          color: AppColors.charcoal,
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.yellow,
                child: Text(
                  initialsFor(admin.name),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.charcoal,
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
                      admin.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${admin.id} · ${admin.role.label}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppPanel(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              _MoreItem(
                icon: Icons.insights_outlined,
                label: 'Reports',
                onTap: () => open(_ReportsPage()),
              ),
              _MoreItem(
                icon: Icons.event_available_outlined,
                label: 'Attendance',
                onTap: () => open(_AttendancePage()),
              ),
              _MoreItem(
                icon: Icons.payments_outlined,
                label: 'Payments',
                onTap: () => open(_PaymentsPage()),
              ),
              _MoreItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () => open(_NotificationsPage()),
              ),
              _MoreItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () => open(_SettingsPage()),
              ),
              _MoreItem(
                icon: Icons.account_circle_outlined,
                label: 'Admin profile',
                onTap: () => open(_AdminProfilePage()),
              ),
              _MoreItem(
                icon: Icons.logout,
                label: 'Logout',
                danger: true,
                onTap: state.logout,
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MoreItem extends StatelessWidget {
  const _MoreItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.ink;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: danger ? AppColors.danger : AppColors.yellow, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (!danger)
                  const Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: AppColors.line, indent: 16, endIndent: 16),
      ],
    );
  }
}

/// Common scaffold for the pushed secondary screens.
class _SubPageScaffold extends StatelessWidget {
  const _SubPageScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        foregroundColor: AppColors.ink,
        elevation: 0,
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reports
// ---------------------------------------------------------------------------

class _ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final totalTasks = state.tasks.length;
    final completion = totalTasks == 0 ? 0.0 : state.completedTasks / totalTasks;

    return _SubPageScaffold(
      title: 'Reports',
      child: Column(
        children: [
          _AdminMetricGrid(
            tiles: [
              _AdminMetricTile(
                icon: Icons.payments_outlined,
                label: 'Total revenue',
                value: _money(state.totalRevenue),
                color: AppColors.yellow,
              ),
              _AdminMetricTile(
                icon: Icons.calendar_month_outlined,
                label: 'This month',
                value: _money(state.monthlyRevenue),
                color: AppColors.success,
              ),
              _AdminMetricTile(
                icon: Icons.people_alt_outlined,
                label: 'Members',
                value: '${state.totalMembers}',
                color: AppColors.amber,
              ),
              _AdminMetricTile(
                icon: Icons.task_alt,
                label: 'Task completion',
                value: '${(completion * 100).round()}%',
                color: AppColors.gold,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppPanelHeader(title: 'Task completion report'),
                const SizedBox(height: 16),
                _StatMeter(
                  label: 'Completed',
                  detail: '${state.completedTasks} of $totalTasks',
                  value: completion,
                ),
                const SizedBox(height: 14),
                _StatMeter(
                  label: 'In progress',
                  detail: '${state.inProgressTasks} of $totalTasks',
                  value: totalTasks == 0 ? 0 : state.inProgressTasks / totalTasks,
                ),
                const SizedBox(height: 14),
                _StatMeter(
                  label: 'Pending',
                  detail: '${state.pendingTasks} of $totalTasks',
                  value: totalTasks == 0 ? 0 : state.pendingTasks / totalTasks,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _TrainerPerformancePanel(state: state),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Attendance
// ---------------------------------------------------------------------------

class _AttendancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final records = state.attendance;

    return _SubPageScaffold(
      title: 'Attendance',
      child: AppPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppPanelHeader(
              title: "Today's check-ins",
              action: AppSmallChip(
                label: '${records.length} today',
                color: AppColors.yellow,
                textColor: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 12),
            if (records.isEmpty)
              const AppEmptyState(
                icon: Icons.event_busy_outlined,
                message: 'No check-ins recorded today.',
              )
            else
              for (var i = 0; i < records.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Row(
                    children: [
                      AppIconBadge(
                        icon: records[i].role == 'Trainer'
                            ? Icons.fitness_center
                            : Icons.person_outline,
                        size: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              records[i].name,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              records[i].role,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        records[i].time,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.yellow,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i != records.length - 1)
                  const Divider(height: 1, color: AppColors.line),
              ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Payments
// ---------------------------------------------------------------------------

class _PaymentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final payments = state.payments;

    return _SubPageScaffold(
      title: 'Payments',
      child: Column(
        children: [
          _AdminMetricGrid(
            tiles: [
              _AdminMetricTile(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Total revenue',
                value: _money(state.totalRevenue),
                color: AppColors.yellow,
              ),
              _AdminMetricTile(
                icon: Icons.calendar_month_outlined,
                label: 'This month',
                value: _money(state.monthlyRevenue),
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppPanelHeader(title: 'Payment history'),
                const SizedBox(height: 12),
                if (payments.isEmpty)
                  const AppEmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: 'No payments recorded yet.',
                  )
                else
                  for (var i = 0; i < payments.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      child: Row(
                        children: [
                          const AppIconBadge(
                            icon: Icons.receipt_long_outlined,
                            size: 40,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  payments[i].memberName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${payments[i].planName} · ${_formatDate(payments[i].date)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _money(payments[i].amount),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.yellow,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (i != payments.length - 1)
                      const Divider(height: 1, color: AppColors.line),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifications
// ---------------------------------------------------------------------------

class _NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final items = state.notifications;

    return _SubPageScaffold(
      title: 'Notifications',
      child: AppPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppPanelHeader(title: 'Recent notifications'),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const AppEmptyState(
                icon: Icons.notifications_off_outlined,
                message: 'You are all caught up.',
              )
            else
              for (final n in items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppIconBadge(icon: n.icon, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    n.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                ),
                                Text(
                                  n.time,
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(color: AppColors.muted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              n.detail,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings
// ---------------------------------------------------------------------------

class _SettingsPage extends StatefulWidget {
  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return _SubPageScaffold(
      title: 'Settings',
      child: AppPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppPanelHeader(title: 'Preferences'),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.charcoal,
              activeTrackColor: AppColors.yellow,
              title: Text(
                'Push notifications',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                'Alert admins about new tasks and approvals.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
              value: state.notificationsEnabled,
              onChanged: (value) =>
                  setState(() => state.notificationsEnabled = value),
            ),
            const Divider(color: AppColors.line),
            const AppDetailRow(
              icon: Icons.business_outlined,
              label: 'Gym',
              value: 'FitPilot Performance Studio',
            ),
            const AppDetailRow(
              icon: Icons.verified_outlined,
              label: 'Plan',
              value: 'Pro · Single branch',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Admin profile
// ---------------------------------------------------------------------------

class _AdminProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final admin = state.currentUser ?? state.admin;

    return _SubPageScaffold(
      title: 'Admin profile',
      child: Column(
        children: [
          AppPanel(
            color: AppColors.charcoal,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.yellow,
                  child: Text(
                    initialsFor(admin.name),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        admin.name,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        admin.role.label,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppPanelHeader(title: 'Account details'),
                AppDetailRow(
                  icon: Icons.badge_outlined,
                  label: 'Account ID',
                  value: admin.id,
                ),
                AppDetailRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: admin.email ?? 'Not set',
                ),
                AppDetailRow(
                  icon: Icons.shield_outlined,
                  label: 'Role',
                  value: admin.role.label,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                state.logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ),
        ],
      ),
    );
  }
}
