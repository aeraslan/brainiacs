import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_controller_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/session/game_session_notifier.dart';
import '../../../shared/widgets/candy_switch_row.dart';
import 'widgets/language_option_tile.dart';
import 'widgets/settings_section_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final language = ref.watch(languagePreferenceProvider);
    final audio = ref.watch(audioControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l10n.commonBack,
                    onPressed: () {
                      ref.read(gameSessionProvider.notifier).closeSettings();
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.textPrimary,
                  ),
                  Expanded(
                    child: Text(
                      l10n.settingsTitle,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                children: [
                  SettingsSectionCard(
                    title: l10n.settingsLanguage,
                    child: Column(
                      children: [
                        LanguageOptionTile(
                          preference: AppLanguage.system,
                          label: l10n.settingsSystemDefault,
                          selected: language == AppLanguage.system,
                          onTap: () {
                            ref
                                .read(languagePreferenceProvider.notifier)
                                .setPreference(AppLanguage.system);
                          },
                        ),
                        LanguageOptionTile(
                          preference: AppLanguage.en,
                          label: l10n.settingsEnglish,
                          selected: language == AppLanguage.en,
                          onTap: () {
                            ref
                                .read(languagePreferenceProvider.notifier)
                                .setPreference(AppLanguage.en);
                          },
                        ),
                        LanguageOptionTile(
                          preference: AppLanguage.tr,
                          label: l10n.settingsTurkish,
                          selected: language == AppLanguage.tr,
                          onTap: () {
                            ref
                                .read(languagePreferenceProvider.notifier)
                                .setPreference(AppLanguage.tr);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SettingsSectionCard(
                    title: l10n.settingsAudio,
                    child: Column(
                      children: [
                        CandySwitchRow(
                          icon: Icons.music_note_rounded,
                          label: l10n.settingsMusic,
                          description: l10n.settingsMusicDescription,
                          value: audio.bgmEnabled,
                          onChanged: (enabled) {
                            ref
                                .read(audioControllerProvider.notifier)
                                .setBgmEnabled(enabled);
                          },
                        ),
                        CandySwitchRow(
                          icon: Icons.volume_up_rounded,
                          label: l10n.settingsSoundEffects,
                          description: l10n.settingsSoundEffectsDescription,
                          value: audio.sfxEnabled,
                          onChanged: (enabled) {
                            ref
                                .read(audioControllerProvider.notifier)
                                .setSfxEnabled(enabled);
                          },
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
