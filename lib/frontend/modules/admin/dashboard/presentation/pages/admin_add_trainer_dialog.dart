part of 'admin_dashboard_page.dart';

/// Opens the "Add trainer" form. On success, shows the generated credentials
/// so the admin can hand them to the new personal trainer.
Future<void> _showAddTrainerDialog(BuildContext context, AppState state) async {
  final created = await showDialog<AppUser>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (_) => _AddTrainerDialog(state: state),
  );

  if (created != null && context.mounted) {
    await _showCredentialsDialog(context, created);
  }
}

class _AddTrainerDialog extends StatefulWidget {
  const _AddTrainerDialog({required this.state});

  final AppState state;

  @override
  State<_AddTrainerDialog> createState() => _AddTrainerDialogState();
}

class _AddTrainerDialogState extends State<_AddTrainerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final String _generatedId = widget.state.nextTrainerIdPreview;
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _create() {
    if (!_formKey.currentState!.validate()) return;
    final trainer = widget.state.addTrainer(
      name: _nameController.text,
      password: _passwordController.text,
      email: _emailController.text,
    );
    Navigator.of(context).pop(trainer);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kAppRadius),
        side: const BorderSide(color: AppColors.line),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      title: Row(
        children: [
          const AppIconBadge(icon: Icons.person_add_alt_1, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Add personal trainer',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _GeneratedIdPreview(id: _generatedId),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter the trainer name.';
                    }
                    if (value.trim().length < 2) {
                      return 'Name is too short.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email (optional)',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final ok = RegExp(
                      r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
                    ).hasMatch(value.trim());
                    return ok ? null : 'Enter a valid email address.';
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _create(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.key_outlined),
                    suffixIcon: IconButton(
                      tooltip: _obscure ? 'Show' : 'Hide',
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Set a password.';
                    }
                    if (value.length < 6) {
                      return 'Use at least 6 characters.';
                    }
                    return null;
                  },
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
          label: const Text('Create trainer'),
        ),
      ],
    );
  }
}

class _GeneratedIdPreview extends StatelessWidget {
  const _GeneratedIdPreview({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(kAppRadius),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.badge_outlined, color: AppColors.yellow, size: 20),
          const SizedBox(width: 10),
          Text(
            'Generated ID',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Text(
            id,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Confirmation dialog presenting the new trainer's login credentials.
Future<void> _showCredentialsDialog(
  BuildContext context,
  AppUser trainer,
) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kAppRadius),
        side: const BorderSide(color: AppColors.line),
      ),
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Trainer created',
              style: Theme.of(
                dialogContext,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share these login credentials with ${trainer.name}.',
              style: Theme.of(dialogContext).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            _CredentialLine(label: 'ID', value: trainer.id),
            const SizedBox(height: 10),
            _CredentialLine(label: 'Password', value: trainer.password),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}

class _CredentialLine extends StatelessWidget {
  const _CredentialLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(kAppRadius),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Text(
            '$label:',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              value,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
