import '../../l10n/generated/app_localizations.dart';
import 'title_tier.dart';

/// Localized display names and humorous descriptions for [TitleTier].
extension TitleTierL10n on TitleTier {
  String localizedName(AppLocalizations l10n) => switch (this) {
    TitleTier.dormantMind => l10n.rankDormantMindName,
    TitleTier.mindApprentice => l10n.rankMindApprenticeName,
    TitleTier.activeNeuron => l10n.rankActiveNeuronName,
    TitleTier.sharpIntellect => l10n.rankSharpIntellectName,
    TitleTier.analyticMind => l10n.rankAnalyticMindName,
    TitleTier.quantumBrain => l10n.rankQuantumBrainName,
    TitleTier.synapseLord => l10n.rankSynapseLordName,
    TitleTier.brainiac => l10n.rankBrainiacName,
  };

  String localizedDescription(AppLocalizations l10n) => switch (this) {
    TitleTier.dormantMind => l10n.rankDormantMindDescription,
    TitleTier.mindApprentice => l10n.rankMindApprenticeDescription,
    TitleTier.activeNeuron => l10n.rankActiveNeuronDescription,
    TitleTier.sharpIntellect => l10n.rankSharpIntellectDescription,
    TitleTier.analyticMind => l10n.rankAnalyticMindDescription,
    TitleTier.quantumBrain => l10n.rankQuantumBrainDescription,
    TitleTier.synapseLord => l10n.rankSynapseLordDescription,
    TitleTier.brainiac => l10n.rankBrainiacDescription,
  };
}
