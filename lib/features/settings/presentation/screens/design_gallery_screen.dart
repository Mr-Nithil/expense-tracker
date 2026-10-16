import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/app_card.dart';
import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:expense_tracker/core/widgets/leaf_confetti.dart';
import 'package:expense_tracker/core/widgets/pip.dart';
import 'package:expense_tracker/core/widgets/pip_speech_bubble.dart';
import 'package:expense_tracker/core/widgets/progress_bar.dart';
import 'package:expense_tracker/core/widgets/progress_ring.dart';
import 'package:expense_tracker/core/widgets/section_header.dart';
import 'package:expense_tracker/core/widgets/sprout_loader.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_stage.dart';
import 'package:expense_tracker/features/goals/presentation/shared/goal_plant.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Debug builds only (Settings → Design gallery): previews the Sprout mascot, loaders, progress
/// and plants in the current theme, to check them on a device. Captions are enum names: this
/// screen is for developers and is never translated.
class DesignGalleryScreen extends StatefulWidget {
  const DesignGalleryScreen({super.key});

  @override
  State<DesignGalleryScreen> createState() => _DesignGalleryScreenState();
}

enum _Section { pip, speechBubble, sproutLoader, progress, progressBar, goalPlant, leafConfetti }

enum _PipVariant { coverEyes, wave, jump, still }

class _DesignGalleryScreenState extends State<DesignGalleryScreen> {
  var _shakes = 0;
  var _value = 0.45;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget captioned(String caption, Widget child) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const Gap(AppSpacing.xs),
        Text(caption, style: context.text.labelSmall),
      ],
    );
    Widget section(_Section section, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: section.name),
          child,
        ],
      ),
    );
    Widget wrap(List<Widget> children) => Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: children,
    );

    return AppScaffold(
      title: l10n.designGalleryTitle,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          section(
            _Section.pip,
            wrap([
              for (final mood in PipMood.values)
                captioned(
                  mood.name,
                  GestureDetector(
                    onTap: () => setState(() => _shakes++),
                    child: Pip(mood: mood, size: 88, shakeTrigger: _shakes),
                  ),
                ),
              for (final variant in _PipVariant.values)
                captioned(
                  variant.name,
                  Pip(
                    size: 88,
                    coverEyes: variant == _PipVariant.coverEyes,
                    wave: variant == _PipVariant.wave,
                    idle: switch (variant) {
                      _PipVariant.jump => PipIdle.jump,
                      _PipVariant.still => PipIdle.none,
                      _ => PipIdle.bob,
                    },
                  ),
                ),
            ]),
          ),
          section(
            _Section.speechBubble,
            Row(
              children: [
                const Pip(size: 64, mood: PipMood.happy, idle: PipIdle.none),
                const Gap(AppSpacing.sm),
                Flexible(child: PipSpeechBubble(text: l10n.designGalleryTitle)),
              ],
            ),
          ),
          section(
            _Section.sproutLoader,
            wrap([
              for (final size in [
                AppSizes.loaderPage,
                AppSizes.loaderSplash,
                AppSizes.loaderButton,
                AppSizes.loaderTyping,
              ])
                captioned(size.toStringAsFixed(0), SproutLoader(size: size)),
              AppButton.primary(label: l10n.commonSave, onPressed: () {}, isLoading: true),
              AppButton.secondary(label: l10n.commonSave, onPressed: () {}, isLoading: true),
            ]),
          ),
          section(
            _Section.progress,
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Slider(value: _value, onChanged: (v) => setState(() => _value = v)),
                  const Gap(AppSpacing.md),
                  ProgressBar(value: _value),
                  const Gap(AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ProgressRing(
                        value: _value,
                        size: 88,
                        child: Text(l10n.goalsPercent((_value * 100).round())),
                      ),
                      GoalPlant(stage: GoalStage.of((_value * 100).floor()), size: 120),
                    ],
                  ),
                ],
              ),
            ),
          ),
          section(
            _Section.progressBar,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (level, value) in [
                  (ProgressLevel.normal, 0.45),
                  (ProgressLevel.warning, 0.85),
                  (ProgressLevel.exceeded, 1.0),
                  (ProgressLevel.complete, 1.0),
                ]) ...[
                  Text(level.name, style: context.text.labelSmall),
                  const Gap(AppSpacing.md),
                  ProgressBar(value: value, level: level, height: 14),
                  const Gap(AppSpacing.md),
                ],
              ],
            ),
          ),
          section(
            _Section.goalPlant,
            wrap([
              for (final stage in GoalStage.values)
                captioned(stage.name, GoalPlant(stage: stage, size: 96)),
            ]),
          ),
          section(
            _Section.leafConfetti,
            const SizedBox(
              height: 240,
              child: AppCard(
                padding: EdgeInsets.zero,
                child: Stack(
                  children: [
                    Center(
                      child: Pip(idle: PipIdle.jump, mood: PipMood.happy),
                    ),
                    Positioned.fill(child: LeafConfetti()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
