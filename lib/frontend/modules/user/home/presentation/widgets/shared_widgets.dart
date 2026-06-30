part of '../pages/home_page.dart';

class _Panel extends StatelessWidget {
  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.color = _surface,
    this.borderColor = _line,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        ?action,
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
    this.dark = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withValues(alpha: 0.1)
            : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: dark ? _line : color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: dark ? color : color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: dark ? Colors.white : _ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: textColor.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color, this.size = 44});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final visibleColor = color == _charcoal ? _yellow : color;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: visibleColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: visibleColor.withValues(alpha: 0.24)),
      ),
      child: Icon(icon, color: visibleColor, size: size * 0.52),
    );
  }
}

class _LoadMeter extends StatelessWidget {
  const _LoadMeter({required this.value, this.color = _yellow});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1).toDouble(),
        minHeight: 9,
        backgroundColor: _line,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class _TrainingVisualPainter extends CustomPainter {
  const _TrainingVisualPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final big = Paint()
      ..shader =
          RadialGradient(
            colors: [
              accent.withValues(alpha: 0.88),
              accent.withValues(alpha: 0.16),
            ],
          ).createShader(
            Rect.fromCircle(center: center, radius: size.shortestSide * 0.55),
          );
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.18);
    final dot = Paint()..color = Colors.white.withValues(alpha: 0.24);

    canvas.drawCircle(center, size.shortestSide * 0.42, big);
    canvas.drawCircle(center, size.shortestSide * 0.33, stroke);
    canvas.drawCircle(center, size.shortestSide * 0.48, stroke);

    for (var i = 0; i < 14; i++) {
      final angle = i * math.pi * 2 / 14;
      final orbit = size.shortestSide * (0.22 + (i % 3) * 0.07);
      final point = Offset(
        center.dx + math.cos(angle) * orbit,
        center.dy + math.sin(angle) * orbit,
      );
      canvas.drawCircle(point, i.isEven ? 3.8 : 2.6, dot);
    }

    final path = Path()
      ..moveTo(size.width * 0.16, size.height * 0.74)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.52,
        size.width * 0.42,
        size.height * 0.88,
        size.width * 0.58,
        size.height * 0.62,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.38,
        size.width * 0.78,
        size.height * 0.52,
        size.width * 0.9,
        size.height * 0.28,
      );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.42),
    );
  }

  @override
  bool shouldRepaint(covariant _TrainingVisualPainter oldDelegate) {
    return oldDelegate.accent != accent;
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
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _yellow, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: _muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _charcoal,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          _IconBadge(icon: icon, color: _yellow, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
