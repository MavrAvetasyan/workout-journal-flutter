import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';

class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    required this.title,
    required this.kicker,
    this.action,
    required this.child,
  });

  final String title;
  final String kicker;
  final Widget? action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.shell,
            const Color(0xFFEAF1FF),
            const Color(0xFFF8FBFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -110,
            right: -60,
            child: _Orb(
              size: 240,
              colors: [
                palette.accent.withValues(alpha: 0.22),
                Colors.white.withValues(alpha: 0.04),
              ],
            ),
          ),
          Positioned(
            top: 120,
            left: -70,
            child: _Orb(
              size: 180,
              colors: [
                const Color(0xFFFFE8CD).withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.08),
              ],
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar.large(
                pinned: true,
                title: Text(title),
                actions: action == null
                    ? null
                    : [
                        Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: action!,
                        ),
                      ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 102, 18, 0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SectionKicker(kicker),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                sliver: SliverToBoxAdapter(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.56),
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(color: palette.line),
                      boxShadow: [
                        BoxShadow(
                          color: palette.accent.withValues(alpha: 0.06),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                      child: child,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({
    required this.size,
    required this.colors,
  });

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}

class SectionKicker extends StatelessWidget {
  const SectionKicker(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: context.palette.accent,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
    );
  }
}

class MetaLine extends StatelessWidget {
  const MetaLine(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.palette.muted,
            height: 1.45,
          ),
    );
  }
}

String formatDateTime(DateTime? value) {
  if (value == null) return 'Без даты';
  return DateFormat('dd.MM.yyyy, HH:mm', 'ru_RU').format(value);
}

String formatDateOnly(DateTime? value) {
  if (value == null) return 'Без даты';
  return DateFormat('dd.MM.yyyy', 'ru_RU').format(value);
}

String phaseSummary({
  int? sets,
  int? reps,
  double? weight,
  String note = '',
}) {
  final parts = <String>[];
  if (sets != null) parts.add('$sets подх');
  if (reps != null) parts.add('$reps повт');
  if (weight != null) {
    parts.add('${weight.toStringAsFixed(weight.truncateToDouble() == weight ? 0 : 1)} кг');
  }
  if (parts.isNotEmpty) return parts.join(' · ');
  if (note.trim().isNotEmpty) return note.trim();
  return 'Без данных';
}

extension BuildContextPalette on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
