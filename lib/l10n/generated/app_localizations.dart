import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Brainiacs'**
  String get appTitle;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get commonMenu;

  /// No description provided for @commonScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get commonScore;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'C'**
  String get commonClear;

  /// No description provided for @commonScrollForMore.
  ///
  /// In en, this message translates to:
  /// **'Scroll for more'**
  String get commonScrollForMore;

  /// No description provided for @commonDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get commonDismiss;

  /// No description provided for @menuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Train your brain. Beat the clock.'**
  String get menuSubtitle;

  /// No description provided for @menuNewGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get menuNewGame;

  /// No description provided for @menuPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get menuPractice;

  /// No description provided for @menuMyProgress.
  ///
  /// In en, this message translates to:
  /// **'My Progress'**
  String get menuMyProgress;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettingsTooltip;

  /// No description provided for @practiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceTitle;

  /// No description provided for @practiceQuickOps.
  ///
  /// In en, this message translates to:
  /// **'Quick Ops'**
  String get practiceQuickOps;

  /// No description provided for @practiceMissingOp.
  ///
  /// In en, this message translates to:
  /// **'Missing Op'**
  String get practiceMissingOp;

  /// No description provided for @practiceCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get practiceCards;

  /// No description provided for @practiceRecall.
  ///
  /// In en, this message translates to:
  /// **'Recall'**
  String get practiceRecall;

  /// No description provided for @practiceCubeCount.
  ///
  /// In en, this message translates to:
  /// **'Cube Count'**
  String get practiceCubeCount;

  /// No description provided for @practiceBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get practiceBalance;

  /// No description provided for @practiceAsteroids.
  ///
  /// In en, this message translates to:
  /// **'Visual Sort'**
  String get practiceAsteroids;

  /// No description provided for @practiceColorClash.
  ///
  /// In en, this message translates to:
  /// **'Color Clash'**
  String get practiceColorClash;

  /// No description provided for @rankDecayTitle.
  ///
  /// In en, this message translates to:
  /// **'Mind getting rusty!'**
  String get rankDecayTitle;

  /// No description provided for @rankDecayBody.
  ///
  /// In en, this message translates to:
  /// **'Your mind is getting rusty! You haven\'t trained in over a week, so your rank has dropped. Time to win it back!'**
  String get rankDecayBody;

  /// No description provided for @rankDecayCta.
  ///
  /// In en, this message translates to:
  /// **'Let\'s train!'**
  String get rankDecayCta;

  /// No description provided for @rankDecayDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss rank decay notice'**
  String get rankDecayDismiss;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsSystemDefault;

  /// No description provided for @settingsEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsEnglish;

  /// No description provided for @settingsTurkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get settingsTurkish;

  /// No description provided for @settingsAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get settingsAudio;

  /// No description provided for @settingsMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get settingsMusic;

  /// No description provided for @settingsMusicDescription.
  ///
  /// In en, this message translates to:
  /// **'Background music'**
  String get settingsMusicDescription;

  /// No description provided for @settingsSoundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get settingsSoundEffects;

  /// No description provided for @settingsSoundEffectsDescription.
  ///
  /// In en, this message translates to:
  /// **'Game sounds and feedback'**
  String get settingsSoundEffectsDescription;

  /// No description provided for @pauseTitle.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pauseTitle;

  /// No description provided for @pauseResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get pauseResume;

  /// No description provided for @pauseEndPractice.
  ///
  /// In en, this message translates to:
  /// **'End Practice'**
  String get pauseEndPractice;

  /// No description provided for @pauseQuitToMenu.
  ///
  /// In en, this message translates to:
  /// **'Quit to Menu'**
  String get pauseQuitToMenu;

  /// No description provided for @pauseMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get pauseMusic;

  /// No description provided for @pauseSoundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get pauseSoundEffects;

  /// No description provided for @pauseDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss pause menu'**
  String get pauseDismiss;

  /// No description provided for @tutorialHowToPlay.
  ///
  /// In en, this message translates to:
  /// **'HOW TO PLAY'**
  String get tutorialHowToPlay;

  /// No description provided for @tutorialWatchFirst.
  ///
  /// In en, this message translates to:
  /// **'WATCH FIRST'**
  String get tutorialWatchFirst;

  /// No description provided for @tutorialPlay.
  ///
  /// In en, this message translates to:
  /// **'PLAY!'**
  String get tutorialPlay;

  /// No description provided for @tutorialQuickMathTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Math'**
  String get tutorialQuickMathTitle;

  /// No description provided for @tutorialQuickMathSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Solve the equation as fast as you can.'**
  String get tutorialQuickMathSubtitle;

  /// No description provided for @tutorialQuickMathStep1.
  ///
  /// In en, this message translates to:
  /// **'Solve the equation.'**
  String get tutorialQuickMathStep1;

  /// No description provided for @tutorialQuickMathStep2.
  ///
  /// In en, this message translates to:
  /// **'Tap the digits of the answer.'**
  String get tutorialQuickMathStep2;

  /// No description provided for @tutorialQuickMathStep3.
  ///
  /// In en, this message translates to:
  /// **'Correct answers unlock harder sums.'**
  String get tutorialQuickMathStep3;

  /// No description provided for @tutorialMissingOperatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing Operator'**
  String get tutorialMissingOperatorTitle;

  /// No description provided for @tutorialMissingOperatorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete the equation with the right operator.'**
  String get tutorialMissingOperatorSubtitle;

  /// No description provided for @tutorialMissingOperatorStep1.
  ///
  /// In en, this message translates to:
  /// **'Find the missing operator to complete the equation.'**
  String get tutorialMissingOperatorStep1;

  /// No description provided for @tutorialMissingOperatorStep2.
  ///
  /// In en, this message translates to:
  /// **'Answer correctly to unlock harder equations.'**
  String get tutorialMissingOperatorStep2;

  /// No description provided for @tutorialMissingOperatorStep3.
  ///
  /// In en, this message translates to:
  /// **'Think fast, but stay accurate!'**
  String get tutorialMissingOperatorStep3;

  /// No description provided for @tutorialCardMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Card Match'**
  String get tutorialCardMatchTitle;

  /// No description provided for @tutorialCardMatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Memorize, then match the pairs.'**
  String get tutorialCardMatchSubtitle;

  /// No description provided for @tutorialCardMatchStep1.
  ///
  /// In en, this message translates to:
  /// **'Memorize the cards while they are face up.'**
  String get tutorialCardMatchStep1;

  /// No description provided for @tutorialCardMatchStep2.
  ///
  /// In en, this message translates to:
  /// **'Flip two cards to find a pair.'**
  String get tutorialCardMatchStep2;

  /// No description provided for @tutorialCardMatchStep3.
  ///
  /// In en, this message translates to:
  /// **'Clear the board to get more cards.'**
  String get tutorialCardMatchStep3;

  /// No description provided for @tutorialMatrixRecallTitle.
  ///
  /// In en, this message translates to:
  /// **'Matrix Recall'**
  String get tutorialMatrixRecallTitle;

  /// No description provided for @tutorialMatrixRecallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Watch the sequence, then tap it back.'**
  String get tutorialMatrixRecallSubtitle;

  /// No description provided for @tutorialMatrixRecallStep1.
  ///
  /// In en, this message translates to:
  /// **'Watch the tiles light up.'**
  String get tutorialMatrixRecallStep1;

  /// No description provided for @tutorialMatrixRecallStep2.
  ///
  /// In en, this message translates to:
  /// **'Tap them back in the same order.'**
  String get tutorialMatrixRecallStep2;

  /// No description provided for @tutorialMatrixRecallStep3.
  ///
  /// In en, this message translates to:
  /// **'Each round adds one more tile.'**
  String get tutorialMatrixRecallStep3;

  /// No description provided for @tutorialCubeCountTitle.
  ///
  /// In en, this message translates to:
  /// **'Cube Count'**
  String get tutorialCubeCountTitle;

  /// No description provided for @tutorialCubeCountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Count every cube in the stack.'**
  String get tutorialCubeCountSubtitle;

  /// No description provided for @tutorialCubeCountStep1.
  ///
  /// In en, this message translates to:
  /// **'Count every cube, including hidden ones.'**
  String get tutorialCubeCountStep1;

  /// No description provided for @tutorialCubeCountStep2.
  ///
  /// In en, this message translates to:
  /// **'Enter the total on the pad.'**
  String get tutorialCubeCountStep2;

  /// No description provided for @tutorialCubeCountStep3.
  ///
  /// In en, this message translates to:
  /// **'Correct counts unlock taller stacks.'**
  String get tutorialCubeCountStep3;

  /// No description provided for @tutorialBalanceLogicTitle.
  ///
  /// In en, this message translates to:
  /// **'Balance Logic'**
  String get tutorialBalanceLogicTitle;

  /// No description provided for @tutorialBalanceLogicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the scales to compare weights.'**
  String get tutorialBalanceLogicSubtitle;

  /// No description provided for @tutorialBalanceLogicStep1.
  ///
  /// In en, this message translates to:
  /// **'Read the scales.'**
  String get tutorialBalanceLogicStep1;

  /// No description provided for @tutorialBalanceLogicStep2.
  ///
  /// In en, this message translates to:
  /// **'Pick the heaviest object.'**
  String get tutorialBalanceLogicStep2;

  /// No description provided for @tutorialBalanceLogicStep3.
  ///
  /// In en, this message translates to:
  /// **'Correct picks unlock tougher puzzles.'**
  String get tutorialBalanceLogicStep3;

  /// No description provided for @tutorialAsteroidsTitle.
  ///
  /// In en, this message translates to:
  /// **'Visual Sort'**
  String get tutorialAsteroidsTitle;

  /// No description provided for @tutorialAsteroidsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the asteroids in ascending order.'**
  String get tutorialAsteroidsSubtitle;

  /// No description provided for @tutorialAsteroidsStep1.
  ///
  /// In en, this message translates to:
  /// **'Tap the asteroids from lowest to highest.'**
  String get tutorialAsteroidsStep1;

  /// No description provided for @tutorialAsteroidsStep2.
  ///
  /// In en, this message translates to:
  /// **'A wrong tap shakes the asteroid.'**
  String get tutorialAsteroidsStep2;

  /// No description provided for @tutorialAsteroidsStep3.
  ///
  /// In en, this message translates to:
  /// **'Clear the field to face more asteroids.'**
  String get tutorialAsteroidsStep3;

  /// No description provided for @tutorialColorClashTitle.
  ///
  /// In en, this message translates to:
  /// **'Color Clash'**
  String get tutorialColorClashTitle;

  /// No description provided for @tutorialColorClashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow the rule: match the ink or the word.'**
  String get tutorialColorClashSubtitle;

  /// No description provided for @tutorialColorClashStep1.
  ///
  /// In en, this message translates to:
  /// **'Check the rule: ink color or word.'**
  String get tutorialColorClashStep1;

  /// No description provided for @tutorialColorClashStep2.
  ///
  /// In en, this message translates to:
  /// **'Tap the matching color.'**
  String get tutorialColorClashStep2;

  /// No description provided for @tutorialColorClashStep3.
  ///
  /// In en, this message translates to:
  /// **'Correct answers unlock tougher clashes.'**
  String get tutorialColorClashStep3;

  /// No description provided for @countdownGo.
  ///
  /// In en, this message translates to:
  /// **'GO!'**
  String get countdownGo;

  /// No description provided for @countdownGetReady.
  ///
  /// In en, this message translates to:
  /// **'Get ready'**
  String get countdownGetReady;

  /// No description provided for @countdownLetsPlay.
  ///
  /// In en, this message translates to:
  /// **'Let’s play'**
  String get countdownLetsPlay;

  /// No description provided for @countdownStartingSoon.
  ///
  /// In en, this message translates to:
  /// **'Starting soon'**
  String get countdownStartingSoon;

  /// No description provided for @cardMatchWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong!'**
  String get cardMatchWrong;

  /// No description provided for @cardMatchMemorize.
  ///
  /// In en, this message translates to:
  /// **'Memorize the cards...'**
  String get cardMatchMemorize;

  /// No description provided for @matrixRecallWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch the sequence...'**
  String get matrixRecallWatch;

  /// No description provided for @matrixRecallYourTurn.
  ///
  /// In en, this message translates to:
  /// **'Your turn!'**
  String get matrixRecallYourTurn;

  /// No description provided for @colorClashMatchColor.
  ///
  /// In en, this message translates to:
  /// **'Match the COLOR!'**
  String get colorClashMatchColor;

  /// No description provided for @colorClashMatchText.
  ///
  /// In en, this message translates to:
  /// **'Read the TEXT!'**
  String get colorClashMatchText;

  /// No description provided for @colorClashRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorClashRed;

  /// No description provided for @colorClashBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorClashBlue;

  /// No description provided for @colorClashGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorClashGreen;

  /// No description provided for @colorClashYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get colorClashYellow;

  /// No description provided for @colorClashPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorClashPink;

  /// No description provided for @colorClashPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorClashPurple;

  /// No description provided for @asteroidOne.
  ///
  /// In en, this message translates to:
  /// **'ONE'**
  String get asteroidOne;

  /// No description provided for @asteroidTwo.
  ///
  /// In en, this message translates to:
  /// **'TWO'**
  String get asteroidTwo;

  /// No description provided for @asteroidThree.
  ///
  /// In en, this message translates to:
  /// **'THREE'**
  String get asteroidThree;

  /// No description provided for @asteroidFour.
  ///
  /// In en, this message translates to:
  /// **'FOUR'**
  String get asteroidFour;

  /// No description provided for @asteroidFive.
  ///
  /// In en, this message translates to:
  /// **'FIVE'**
  String get asteroidFive;

  /// No description provided for @asteroidSix.
  ///
  /// In en, this message translates to:
  /// **'SIX'**
  String get asteroidSix;

  /// No description provided for @asteroidSeven.
  ///
  /// In en, this message translates to:
  /// **'SEVEN'**
  String get asteroidSeven;

  /// No description provided for @asteroidEight.
  ///
  /// In en, this message translates to:
  /// **'EIGHT'**
  String get asteroidEight;

  /// No description provided for @asteroidNine.
  ///
  /// In en, this message translates to:
  /// **'NINE'**
  String get asteroidNine;

  /// No description provided for @asteroidTen.
  ///
  /// In en, this message translates to:
  /// **'TEN'**
  String get asteroidTen;

  /// No description provided for @asteroidEleven.
  ///
  /// In en, this message translates to:
  /// **'ELEVEN'**
  String get asteroidEleven;

  /// No description provided for @asteroidTwelve.
  ///
  /// In en, this message translates to:
  /// **'TWELVE'**
  String get asteroidTwelve;

  /// No description provided for @asteroidThirteen.
  ///
  /// In en, this message translates to:
  /// **'THIRTEEN'**
  String get asteroidThirteen;

  /// No description provided for @asteroidFourteen.
  ///
  /// In en, this message translates to:
  /// **'FOURTEEN'**
  String get asteroidFourteen;

  /// No description provided for @asteroidFifteen.
  ///
  /// In en, this message translates to:
  /// **'FIFTEEN'**
  String get asteroidFifteen;

  /// No description provided for @asteroidSixteen.
  ///
  /// In en, this message translates to:
  /// **'SIXTEEN'**
  String get asteroidSixteen;

  /// No description provided for @asteroidSeventeen.
  ///
  /// In en, this message translates to:
  /// **'SEVENTEEN'**
  String get asteroidSeventeen;

  /// No description provided for @asteroidEighteen.
  ///
  /// In en, this message translates to:
  /// **'EIGHTEEN'**
  String get asteroidEighteen;

  /// No description provided for @asteroidNineteen.
  ///
  /// In en, this message translates to:
  /// **'NINETEEN'**
  String get asteroidNineteen;

  /// No description provided for @asteroidTwenty.
  ///
  /// In en, this message translates to:
  /// **'TWENTY'**
  String get asteroidTwenty;

  /// No description provided for @hudPauseHome.
  ///
  /// In en, this message translates to:
  /// **'Pause menu'**
  String get hudPauseHome;

  /// No description provided for @hudTimePenalty.
  ///
  /// In en, this message translates to:
  /// **'-{seconds}s'**
  String hudTimePenalty(int seconds);

  /// No description provided for @categoryMath.
  ///
  /// In en, this message translates to:
  /// **'Math'**
  String get categoryMath;

  /// No description provided for @categoryMemory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get categoryMemory;

  /// No description provided for @categoryAnalytic.
  ///
  /// In en, this message translates to:
  /// **'Analytic'**
  String get categoryAnalytic;

  /// No description provided for @categoryVisual.
  ///
  /// In en, this message translates to:
  /// **'Visual'**
  String get categoryVisual;

  /// No description provided for @timesUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Time\'s Up!'**
  String get timesUpTitle;

  /// No description provided for @scoreGameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get scoreGameOver;

  /// No description provided for @scoreTimeUp.
  ///
  /// In en, this message translates to:
  /// **'Time\'s Up!'**
  String get scoreTimeUp;

  /// No description provided for @scoreFinalScore.
  ///
  /// In en, this message translates to:
  /// **'Final Score'**
  String get scoreFinalScore;

  /// No description provided for @scorePlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get scorePlayAgain;

  /// No description provided for @scoreThisRun.
  ///
  /// In en, this message translates to:
  /// **'This run'**
  String get scoreThisRun;

  /// No description provided for @scoreNewHighScore.
  ///
  /// In en, this message translates to:
  /// **'New high score'**
  String get scoreNewHighScore;

  /// No description provided for @scoreNewRankUnlocked.
  ///
  /// In en, this message translates to:
  /// **'New Rank Unlocked!'**
  String get scoreNewRankUnlocked;

  /// No description provided for @scoreYourRank.
  ///
  /// In en, this message translates to:
  /// **'Your Rank This Run'**
  String get scoreYourRank;

  /// No description provided for @scoreNice.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get scoreNice;

  /// No description provided for @scoreDismissRankReveal.
  ///
  /// In en, this message translates to:
  /// **'Dismiss rank reveal'**
  String get scoreDismissRankReveal;

  /// No description provided for @rankOf.
  ///
  /// In en, this message translates to:
  /// **'Rank {number} of {total}'**
  String rankOf(int number, int total);

  /// No description provided for @rankTopReached.
  ///
  /// In en, this message translates to:
  /// **'Top rank reached'**
  String get rankTopReached;

  /// No description provided for @rankNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {name}'**
  String rankNext(String name);

  /// No description provided for @rankScoreRequirement.
  ///
  /// In en, this message translates to:
  /// **'Score {score}+ in one game'**
  String rankScoreRequirement(int score);

  /// No description provided for @rankThisRunProgress.
  ///
  /// In en, this message translates to:
  /// **'This run: {runScore} / {nextScore}'**
  String rankThisRunProgress(String runScore, String nextScore);

  /// No description provided for @rankViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All Ranks'**
  String get rankViewAll;

  /// No description provided for @rankAllRanks.
  ///
  /// In en, this message translates to:
  /// **'All Ranks'**
  String get rankAllRanks;

  /// No description provided for @rankYou.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get rankYou;

  /// No description provided for @rankLadderEntry.
  ///
  /// In en, this message translates to:
  /// **'Rank {number} · {score}+ pts'**
  String rankLadderEntry(int number, int score);

  /// No description provided for @rankLadderExplainer.
  ///
  /// In en, this message translates to:
  /// **'Train at least once every {days} days to keep your rank. Practice games don\'t count.'**
  String rankLadderExplainer(int days);

  /// No description provided for @rankDefendToday.
  ///
  /// In en, this message translates to:
  /// **'defend today'**
  String get rankDefendToday;

  /// No description provided for @rankDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day left} other{{count} days left}}'**
  String rankDaysLeft(int count);

  /// No description provided for @rankDefendChipNew.
  ///
  /// In en, this message translates to:
  /// **'New held rank: {name} — defend today!'**
  String rankDefendChipNew(String name);

  /// No description provided for @rankDefendChipDefend.
  ///
  /// In en, this message translates to:
  /// **'{name} — {status}'**
  String rankDefendChipDefend(String name, String status);

  /// No description provided for @rankDefendChipDefended.
  ///
  /// In en, this message translates to:
  /// **'{name} defended — {status}'**
  String rankDefendChipDefended(String name, String status);

  /// No description provided for @rankDefendChipHeld.
  ///
  /// In en, this message translates to:
  /// **'Held: {name} — {status}'**
  String rankDefendChipHeld(String name, String status);

  /// No description provided for @rankRevealPromotionHeading.
  ///
  /// In en, this message translates to:
  /// **'NEW RANK UNLOCKED!'**
  String get rankRevealPromotionHeading;

  /// No description provided for @rankRevealDefendedHeading.
  ///
  /// In en, this message translates to:
  /// **'RANK DEFENDED!'**
  String get rankRevealDefendedHeading;

  /// No description provided for @rankRevealSessionHeading.
  ///
  /// In en, this message translates to:
  /// **'YOUR RANK THIS RUN'**
  String get rankRevealSessionHeading;

  /// No description provided for @rankDormantMindName.
  ///
  /// In en, this message translates to:
  /// **'Single Brain Cell'**
  String get rankDormantMindName;

  /// No description provided for @rankDormantMindDescription.
  ///
  /// In en, this message translates to:
  /// **'One brain cell. Zero backup plans.'**
  String get rankDormantMindDescription;

  /// No description provided for @rankMindApprenticeName.
  ///
  /// In en, this message translates to:
  /// **'Brain Not Found'**
  String get rankMindApprenticeName;

  /// No description provided for @rankMindApprenticeDescription.
  ///
  /// In en, this message translates to:
  /// **'Error 404: Intelligence not found.'**
  String get rankMindApprenticeDescription;

  /// No description provided for @rankActiveNeuronName.
  ///
  /// In en, this message translates to:
  /// **'Caveman Mode'**
  String get rankActiveNeuronName;

  /// No description provided for @rankActiveNeuronDescription.
  ///
  /// In en, this message translates to:
  /// **'Discovered fire. Still figuring out the calculator.'**
  String get rankActiveNeuronDescription;

  /// No description provided for @rankSharpIntellectName.
  ///
  /// In en, this message translates to:
  /// **'Gifted But Lazy'**
  String get rankSharpIntellectName;

  /// No description provided for @rankSharpIntellectDescription.
  ///
  /// In en, this message translates to:
  /// **'Your teachers saw potential. Your homework didn\'t.'**
  String get rankSharpIntellectDescription;

  /// No description provided for @rankAnalyticMindName.
  ///
  /// In en, this message translates to:
  /// **'Mom\'s Little Genius'**
  String get rankAnalyticMindName;

  /// No description provided for @rankAnalyticMindDescription.
  ///
  /// In en, this message translates to:
  /// **'Mom says you\'re a genius. She\'s totally unbiased.'**
  String get rankAnalyticMindDescription;

  /// No description provided for @rankQuantumBrainName.
  ///
  /// In en, this message translates to:
  /// **'Galaxy Brain'**
  String get rankQuantumBrainName;

  /// No description provided for @rankQuantumBrainDescription.
  ///
  /// In en, this message translates to:
  /// **'Your brain has officially expanded beyond reasonable limits.'**
  String get rankQuantumBrainDescription;

  /// No description provided for @rankSynapseLordName.
  ///
  /// In en, this message translates to:
  /// **'NASA Is Calling'**
  String get rankSynapseLordName;

  /// No description provided for @rankSynapseLordDescription.
  ///
  /// In en, this message translates to:
  /// **'They called three times. You were busy solving Sudoku.'**
  String get rankSynapseLordDescription;

  /// No description provided for @rankBrainiacName.
  ///
  /// In en, this message translates to:
  /// **'Certified Brainiac'**
  String get rankBrainiacName;

  /// No description provided for @rankBrainiacDescription.
  ///
  /// In en, this message translates to:
  /// **'AI asks YOU the questions now. We\'re slightly concerned.'**
  String get rankBrainiacDescription;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'My Progress'**
  String get progressTitle;

  /// No description provided for @progressGamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Games Played'**
  String get progressGamesPlayed;

  /// No description provided for @progressPersonalBest.
  ///
  /// In en, this message translates to:
  /// **'Personal Best'**
  String get progressPersonalBest;

  /// No description provided for @progressLatestScore.
  ///
  /// In en, this message translates to:
  /// **'Latest Score'**
  String get progressLatestScore;

  /// No description provided for @progressAverageScore.
  ///
  /// In en, this message translates to:
  /// **'Average Score'**
  String get progressAverageScore;

  /// No description provided for @progressLast10Runs.
  ///
  /// In en, this message translates to:
  /// **'Last 10 runs'**
  String get progressLast10Runs;

  /// No description provided for @progressCategoryRecords.
  ///
  /// In en, this message translates to:
  /// **'Category Records'**
  String get progressCategoryRecords;

  /// No description provided for @progressRecentPerformance.
  ///
  /// In en, this message translates to:
  /// **'Recent Performance'**
  String get progressRecentPerformance;

  /// No description provided for @progressEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your progress starts here!'**
  String get progressEmptyTitle;

  /// No description provided for @progressEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Complete your next New Game session to start building your performance history.'**
  String get progressEmptyBody;

  /// No description provided for @progressLegacyNote.
  ///
  /// In en, this message translates to:
  /// **'Detailed score tracking starts with your next completed game.'**
  String get progressLegacyNote;

  /// No description provided for @progressEmDash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get progressEmDash;

  /// No description provided for @progressRunLabel.
  ///
  /// In en, this message translates to:
  /// **'Run {number}'**
  String progressRunLabel(int number);

  /// No description provided for @progressDaysStreak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Day} other{{count} Days}}'**
  String progressDaysStreak(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
