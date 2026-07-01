part of 'admin_dashboard_page.dart';

/// Members tab: search, directory, add/renew, and plans.
class _AdminMembersView extends StatefulWidget {
  const _AdminMembersView({required this.state});

  final AppState state;

  @override
  State<_AdminMembersView> createState() => _AdminMembersViewState();
}

class _AdminMembersViewState extends State<_AdminMembersView> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final query = _query.trim().toLowerCase();
    final members = state.members.where((m) {
      if (query.isEmpty) return true;
      return m.name.toLowerCase().contains(query) ||
          m.id.toLowerCase().contains(query) ||
          m.phone.toLowerCase().contains(query);
    }).toList();

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
                    title: 'All members',
                    action: tight
                        ? null
                        : AppSmallChip(
                            label: '${state.totalMembers} total',
                            color: AppColors.yellow,
                            textColor: AppColors.charcoal,
                          ),
                  );
                  final addButton = SizedBox(
                    width: tight ? double.infinity : null,
                    child: FilledButton.icon(
                      onPressed: () => _showAddMemberDialog(context, state),
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Add member'),
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
              const SizedBox(height: 14),
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search members by name, ID or phone',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
              const SizedBox(height: 16),
              if (members.isEmpty)
                AppEmptyState(
                  icon: Icons.person_search_outlined,
                  message: query.isEmpty
                      ? 'No members yet. Use "Add member" to register one.'
                      : 'No members match "$_query".',
                )
              else
                for (var i = 0; i < members.length; i++) ...[
                  _MemberCard(member: members[i], state: state),
                  if (i != members.length - 1) const SizedBox(height: 12),
                ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PlansPanel(state: state),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member, required this.state});

  final Member member;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final plan = state.planById(member.planId);

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
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 44,
                  height: 44,
                  color: AppColors.surfaceAlt,
                  child: member.imageUrl != null && member.imageUrl!.isNotEmpty
                      ? Image.network(
                          member.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              initialsFor(member.name),
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.yellow,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            initialsFor(member.name),
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.yellow,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${member.id}  ·  ${member.phone}',
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
                label: member.status.label,
                color: member.status.color.withValues(alpha: 0.15),
                textColor: member.status.color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppSmallChip(
                label: plan.name,
                color: AppColors.surfaceAlt,
                textColor: AppColors.yellow,
              ),
              AppSmallChip(
                label: 'Expires ${_formatDate(member.expiryDate)}',
                color: AppColors.surfaceAlt,
                textColor: AppColors.ink,
              ),
              AppSmallChip(
                label: 'Login: ${member.loginId}',
                color: AppColors.surfaceAlt,
                textColor: AppColors.yellow,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(kAppRadius - 2),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(
                  icon: Icons.fitness_center_outlined,
                  label: 'Last Workout',
                  value: member.lastWorkout ?? 'No workout logged yet',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Divider(color: AppColors.line, height: 1),
                ),
                _DetailRow(
                  icon: Icons.scale_outlined,
                  label: 'Weight progression',
                  value: member.oldWeight != null && member.currentWeight != null
                      ? '${member.oldWeight} kg → ${member.currentWeight} kg (${(member.currentWeight! - member.oldWeight!) > 0 ? "+" : ""}${(member.currentWeight! - member.oldWeight!).toStringAsFixed(1)} kg)'
                      : 'Not recorded',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    state.renewMember(member.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${member.name} membership renewed.')),
                    );
                  },
                  icon: const Icon(Icons.autorenew, size: 18),
                  label: const Text('Renew'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showEditLoginDialog(context, state, member),
                  icon: const Icon(Icons.key_outlined, size: 18),
                  label: const Text('Edit login'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.yellow),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlansPanel extends StatelessWidget {
  const _PlansPanel({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPanelHeader(title: 'Membership plans'),
          const SizedBox(height: 14),
          for (final plan in state.plans)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const AppIconBadge(icon: Icons.card_membership_outlined, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${plan.durationMonths} month(s)',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _money(plan.price),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.yellow,
                      fontWeight: FontWeight.w900,
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

// ---------------------------------------------------------------------------
// Add member dialog
// ---------------------------------------------------------------------------

Future<void> _showAddMemberDialog(BuildContext context, AppState state) async {
  final member = await showDialog<Member>(
    context: context,
    builder: (_) => _AddMemberDialog(state: state),
  );
  if (member != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${member.name} registered as ${member.id}.')),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit login credentials dialog
// ---------------------------------------------------------------------------

Future<void> _showEditLoginDialog(
  BuildContext context,
  AppState state,
  Member member,
) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => _EditLoginDialog(state: state, member: member),
  );
  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login updated for ${member.name}.')),
    );
  }
}

class _EditLoginDialog extends StatefulWidget {
  const _EditLoginDialog({required this.state, required this.member});

  final AppState state;
  final Member member;

  @override
  State<_EditLoginDialog> createState() => _EditLoginDialogState();
}

class _EditLoginDialogState extends State<_EditLoginDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _loginIdController =
      TextEditingController(text: widget.member.loginId);
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.state.updateMemberCredentials(
      widget.member.id,
      loginId: _loginIdController.text,
      password: _passwordController.text,
    );
    Navigator.of(context).pop(true);
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
          const AppIconBadge(icon: Icons.key_outlined, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Edit login',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set the ID and password ${widget.member.name} uses to sign in.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _loginIdController,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Login ID',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) {
                  final id = value?.trim() ?? '';
                  if (id.length < 3) return 'Enter a login ID (min 3 characters).';
                  if (widget.state
                      .isLoginIdTaken(id, ignoreMemberId: widget.member.id)) {
                    return 'That login ID is already in use.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New password',
                  helperText: 'Leave blank to keep the current password.',
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  return value.trim().length < 4
                      ? 'Password must be at least 4 characters.'
                      : null;
                },
              ),
            ],
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
          onPressed: _save,
          icon: const Icon(Icons.check),
          label: const Text('Save'),
        ),
      ],
    );
  }
}

class _AddMemberDialog extends StatefulWidget {
  const _AddMemberDialog({required this.state});

  final AppState state;

  @override
  State<_AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<_AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _loginIdController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _lastWorkoutController = TextEditingController();
  final _oldWeightController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _passwordController = TextEditingController();

  late String _planId = widget.state.plans.first.id;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _loginIdController.dispose();
    _imageUrlController.dispose();
    _lastWorkoutController.dispose();
    _oldWeightController.dispose();
    _currentWeightController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _create() {
    if (!_formKey.currentState!.validate()) return;
    final oldWeight = double.tryParse(_oldWeightController.text);
    final currentWeight = double.tryParse(_currentWeightController.text);

    final member = widget.state.addMember(
      name: _nameController.text,
      phone: _phoneController.text,
      planId: _planId,
      password: _passwordController.text,
      loginId: _loginIdController.text,
      imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
      lastWorkout: _lastWorkoutController.text.trim().isEmpty ? null : _lastWorkoutController.text.trim(),
      oldWeight: oldWeight,
      currentWeight: currentWeight,
    );
    Navigator.of(context).pop(member);
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
          const AppIconBadge(icon: Icons.person_add_alt_1, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Add member',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        height: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().length < 2)
                      ? 'Enter the member name.'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().length < 5)
                      ? 'Enter a contact number.'
                      : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _planId,
                  decoration: const InputDecoration(
                    labelText: 'Membership plan',
                    prefixIcon: Icon(Icons.card_membership_outlined),
                  ),
                  dropdownColor: AppColors.surface,
                  items: [
                    for (final plan in widget.state.plans)
                      DropdownMenuItem(
                        value: plan.id,
                        child: Text('${plan.name} · ${_money(plan.price)}'),
                      ),
                  ],
                  onChanged: (value) => setState(() => _planId = value!),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _loginIdController,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Login ID',
                    helperText: 'The member types this to sign in.',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) {
                    final id = value?.trim() ?? '';
                    if (id.length < 3) return 'Enter a login ID (min 3 characters).';
                    if (widget.state.isLoginIdTaken(id)) {
                      return 'That login ID is already in use.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Login Password',
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().length < 4)
                      ? 'Enter a password (min 4 characters).'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _imageUrlController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Image URL (optional)',
                    prefixIcon: Icon(Icons.image_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _lastWorkoutController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Last Workout (optional)',
                    prefixIcon: Icon(Icons.fitness_center_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _oldWeightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Old Weight (kg)',
                          prefixIcon: Icon(Icons.scale_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _currentWeightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Current Weight (kg)',
                          prefixIcon: Icon(Icons.scale_outlined),
                        ),
                      ),
                    ),
                  ],
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
          label: const Text('Add member'),
        ),
      ],
    );
  }
}
