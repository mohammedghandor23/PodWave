// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PodWave';

  @override
  String get home => 'Home';

  @override
  String get library => 'Library';

  @override
  String get settings => 'Settings';

  @override
  String get yourMusicOffline => 'Your music, offline.';

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get queue => 'Queue';

  @override
  String get songs => 'Songs';

  @override
  String get albums => 'Albums';

  @override
  String get artists => 'Artists';

  @override
  String get playlists => 'Playlists';

  @override
  String get search => 'Search';

  @override
  String get searchInLibrary => 'Find in Library';

  @override
  String get recentlyPlayed => 'Recently Played';

  @override
  String get mostPlayed => 'Most Played';

  @override
  String get recentlyAdded => 'Recently Added';

  @override
  String get favorites => 'Favorites';

  @override
  String get folderNotFound => 'Folder not found';

  @override
  String get noSongsInFolder => 'No songs in this folder';

  @override
  String get noAlbumsFound => 'No albums found';

  @override
  String get noSongsFound => 'No songs found';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get error => 'Error';

  @override
  String get refresh => 'Refresh';

  @override
  String songCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'songs',
      one: 'song',
    );
    return '$count $_temp0';
  }

  @override
  String get customizeYourAuditoryExperience => 'Customize your auditory experience.';

  @override
  String get playback => 'Playback';

  @override
  String get resumePlayback => 'Resume Playback';

  @override
  String get autoPlayWhenAppOpens => 'Auto-play when app opens';

  @override
  String get resumeModePrompt => 'Ask to resume';

  @override
  String get resumeModePromptDesc => 'Show dialog when resuming songs';

  @override
  String get resumeModeAuto => 'Auto resume';

  @override
  String get resumeModeAutoDesc => 'Automatically resume from saved position';

  @override
  String get system => 'System';

  @override
  String get localStorage => 'Local Storage';

  @override
  String get appVersion => 'App Version';

  @override
  String get resumeDialogTitle => 'Resume Playback?';

  @override
  String resumeDialogMessage(Object position) {
    return 'You stopped at $position. Resume from there?';
  }

  @override
  String get resume => 'Resume';

  @override
  String get startOver => 'Start Over';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';
}
