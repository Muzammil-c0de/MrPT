part of 'home_page.dart';

class _ProfileView extends StatelessWidget {
  const _ProfileView({
    required this.trainer,
    required this.uploads,
    required this.activities,
    required this.profilePhotoStatus,
    required this.onUploadPhoto,
  });

  final TrainerProfile trainer;
  final List<PhotoUpload> uploads;
  final List<ActivityItem> activities;
  final String profilePhotoStatus;
  final VoidCallback onUploadPhoto;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;

        final primary = Column(
          children: [
            _ProfileHeaderPanel(
              trainer: trainer,
              profilePhotoStatus: profilePhotoStatus,
              onUploadPhoto: onUploadPhoto,
            ),
            const SizedBox(height: 16),
            _UpdateProfilePanel(trainer: trainer),
            const SizedBox(height: 16),
            _ExperiencePanel(trainer: trainer),
          ],
        );

        final secondary = Column(
          children: [
            _ContactPanel(trainer: trainer),
            const SizedBox(height: 16),
            _CertificationsPanel(certifications: trainer.certifications),
            const SizedBox(height: 16),
            _ScopedAccessPanel(),
            const SizedBox(height: 16),
            _ProfileHistoryPanel(activities: activities, uploads: uploads),
          ],
        );

        if (!wide) {
          return Column(
            children: [primary, const SizedBox(height: 16), secondary],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: primary),
            const SizedBox(width: 16),
            Expanded(flex: 5, child: secondary),
          ],
        );
      },
    );
  }
}

class _ProfileHeaderPanel extends StatelessWidget {
  const _ProfileHeaderPanel({
    required this.trainer,
    required this.profilePhotoStatus,
    required this.onUploadPhoto,
  });

  final TrainerProfile trainer;
  final String profilePhotoStatus;
  final VoidCallback onUploadPhoto;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      color: _charcoal,
      borderColor: _line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: _yellow,
                  borderRadius: BorderRadius.circular(_radius),
                ),
                child: Center(
                  child: Text(
                    trainer.initials,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: _charcoal,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trainer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trainer.role,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: _muted),
                    ),
                    const SizedBox(height: 10),
                    _SmallChip(
                      label: profilePhotoStatus,
                      color: _surfaceAlt,
                      textColor: _yellow,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onUploadPhoto,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Upload profile photo'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('View profile'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpdateProfilePanel extends StatelessWidget {
  const _UpdateProfilePanel({required this.trainer});

  final TrainerProfile trainer;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(title: 'Update profile'),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: trainer.name,
            decoration: const InputDecoration(labelText: 'Display name'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: trainer.role,
            decoration: const InputDecoration(labelText: 'Role'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: trainer.bio,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Trainer bio',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save profile'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactPanel extends StatelessWidget {
  const _ContactPanel({required this.trainer});

  final TrainerProfile trainer;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(title: 'Contact information'),
          _DetailRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: trainer.email,
          ),
          _DetailRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: trainer.phone,
          ),
          _DetailRow(
            icon: Icons.location_on_outlined,
            label: 'Studio',
            value: trainer.location,
          ),
        ],
      ),
    );
  }
}

class _ExperiencePanel extends StatelessWidget {
  const _ExperiencePanel({required this.trainer});

  final TrainerProfile trainer;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(title: 'Experience details'),
          const SizedBox(height: 14),
          Text(
            trainer.experience,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final specialty in trainer.specialties)
                _SmallChip(
                  label: specialty,
                  color: _surfaceAlt,
                  textColor: _yellow,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CertificationsPanel extends StatelessWidget {
  const _CertificationsPanel({required this.certifications});

  final List<Certification> certifications;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(title: 'Certifications'),
          const SizedBox(height: 10),
          for (final certification in certifications)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  _IconBadge(
                    icon: Icons.workspace_premium_outlined,
                    color: _yellow,
                    size: 42,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          certification.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${certification.issuer} / ${certification.year}',
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
            ),
        ],
      ),
    );
  }
}

class _ScopedAccessPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Panel(
      color: _charcoal,
      borderColor: _line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(title: 'Trainer workspace'),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.lock_outline,
            label: 'Profile scope',
            value: 'Maya Johnson',
          ),
          _DetailRow(
            icon: Icons.groups_outlined,
            label: 'Roster scope',
            value: 'Assigned members only',
          ),
          _DetailRow(
            icon: Icons.assignment_ind_outlined,
            label: 'Task scope',
            value: 'Assigned tasks, uploads, and activities only',
          ),
        ],
      ),
    );
  }
}

class _ProfileHistoryPanel extends StatelessWidget {
  const _ProfileHistoryPanel({required this.activities, required this.uploads});

  final List<ActivityItem> activities;
  final List<PhotoUpload> uploads;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(title: 'Activity history'),
          const SizedBox(height: 10),
          for (final activity in activities.take(3))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                children: [
                  _IconBadge(icon: activity.icon, color: _yellow, size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${activity.detail} / ${activity.time}',
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
            ),
          const Divider(color: _line),
          const SizedBox(height: 8),
          const _PanelHeader(title: 'Upload history'),
          const SizedBox(height: 10),
          for (final upload in uploads.take(3)) _UploadTile(upload: upload),
        ],
      ),
    );
  }
}
