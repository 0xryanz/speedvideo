// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SPEEDVIDEO';

  @override
  String get appTagline => 'Unlimited movies, series and more.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get loginRequired => 'Sign in required';

  @override
  String get guestLibraryTitle => 'Sign in to sync your library';

  @override
  String get guestLibraryHint =>
      'Your list, watch progress and downloads need an account. Browsing and playback don\'t.';

  @override
  String get watchlistNeedsAccount => 'Sign in to save titles to your list.';

  @override
  String get downloadNeedsAccount => 'Sign in to download titles.';

  @override
  String get emptyWatchlistHint =>
      'Open a title and tap \"Add to My List\" to save it here.';

  @override
  String get signOut => 'Sign Out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get displayName => 'Display name';

  @override
  String get welcomeTitle => 'Watch anywhere. Cancel anytime.';

  @override
  String get welcomeSubtitle =>
      'Stories that move you, on every screen you own.';

  @override
  String get signInSubtitle => 'Sign in to continue watching.';

  @override
  String get signUpSubtitle => 'Create your account. No commitment.';

  @override
  String get noAccount => 'New to SpeedVideo?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get continueLabel => 'Continue';

  @override
  String get invalidEmail => 'Enter a valid email address.';

  @override
  String get passwordMin => 'Password must be at least 8 characters.';

  @override
  String get nameRequired => 'Please enter your name.';

  @override
  String get invalidCredentials => 'Incorrect email or password.';

  @override
  String get emailTaken => 'An account with this email already exists.';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get whoIsWatching => 'Who\'s watching?';

  @override
  String get manageProfiles => 'Manage Profiles';

  @override
  String get done => 'Done';

  @override
  String get addProfile => 'Add Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get profileName => 'Profile name';

  @override
  String get kidsProfile => 'Kids profile';

  @override
  String get kidsProfileHint => 'Only shows titles suitable for children.';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get deleteProfileTitle => 'Delete profile?';

  @override
  String deleteProfileMessage(Object name) {
    return '\"$name\" and its viewing history will be removed.';
  }

  @override
  String get profileLimitReached => 'You have reached the profile limit.';

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get newHot => 'New & Hot';

  @override
  String get myNetflix => 'My Space';

  @override
  String get play => 'Play';

  @override
  String get resume => 'Resume';

  @override
  String get moreInfo => 'More Info';

  @override
  String get myList => 'My List';

  @override
  String get addToMyList => 'Add to My List';

  @override
  String get removeFromMyList => 'Remove from My List';

  @override
  String get top10Today => 'Top 10 in Your Country Today';

  @override
  String get continueWatching => 'Continue Watching';

  @override
  String continueWatchingFor(String name) {
    return 'Continue Watching for $name';
  }

  @override
  String get newReleases => 'New Releases';

  @override
  String get myListTitle => 'My List';

  @override
  String get trendingNow => 'Trending Now';

  @override
  String get searchHint => 'Search shows, movies and more';

  @override
  String get searchEmpty => 'Find your next story';

  @override
  String get searchEmptyHint => 'Search by title or genre.';

  @override
  String noResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get genres => 'Genres';

  @override
  String get season => 'Season';

  @override
  String seasonNumber(int number) {
    return 'Season $number';
  }

  @override
  String get episodes => 'Episodes';

  @override
  String get moreLikeThis => 'More Like This';

  @override
  String get cast => 'Cast';

  @override
  String get director => 'Director';

  @override
  String matchLabel(int percent) {
    return '$percent% Match';
  }

  @override
  String get episode => 'Episode';

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String get settings => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get language => 'Language';

  @override
  String get playback => 'Playback';

  @override
  String get autoplayNext => 'Autoplay next episode';

  @override
  String get downloads => 'Downloads';

  @override
  String get downloadsEmpty => 'No downloads yet';

  @override
  String get downloadsEmptyHint =>
      'Downloaded titles will appear here and play offline.';

  @override
  String get help => 'Help';

  @override
  String get about => 'About';

  @override
  String get profile => 'Profile';

  @override
  String get signOutConfirm => 'Sign out of SpeedVideo?';

  @override
  String get offlineBanner => 'You are offline. Check your connection.';

  @override
  String get playerError => 'This title can\'t be played right now.';

  @override
  String get nextEpisode => 'Next Episode';

  @override
  String get tvRemoteHint => 'OK play/pause · ◀ ▶ seek 10s · Back exit';

  @override
  String get skipIntro => 'Skip Intro';

  @override
  String get loading => 'Loading';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get selectProfile => 'Select a profile to start watching.';

  @override
  String get manage => 'Manage';

  @override
  String get viewAll => 'View all';

  @override
  String get recentlyAdded => 'Recently Added';

  @override
  String get popular => 'Popular';

  @override
  String get accountEmail => 'Email';

  @override
  String get plan => 'Plan';

  @override
  String get memberSince => 'Member since';

  @override
  String get appearance => 'Appearance';

  @override
  String get system => 'System';

  @override
  String get english => 'English';

  @override
  String get chinese => '简体中文';

  @override
  String get aboutBody => 'A streaming experience built with Flutter and Go.';

  @override
  String get apiUnavailable => 'Can\'t reach SpeedVideo. Is the API running?';

  @override
  String get more => 'More';

  @override
  String get less => 'Less';

  @override
  String seasonsCount(int count) {
    return '$count Seasons';
  }

  @override
  String get aboutApp => 'About SpeedVideo';

  @override
  String get download => 'Download';

  @override
  String get downloading => 'Downloading';

  @override
  String get downloaded => 'Downloaded';

  @override
  String get downloadFailed => 'Download failed.';

  @override
  String get downloadUnavailable => 'This title is not available for download.';

  @override
  String get downloadRemoved => 'Download removed.';

  @override
  String downloadStarted(String name) {
    return 'Downloading $name';
  }

  @override
  String get storedOnDevice => 'Saved on this device.';

  @override
  String get notDownloaded => 'This title is not downloaded on this device.';

  @override
  String get deleteDownloadTitle => 'Delete download?';

  @override
  String deleteDownloadMessage(String name) {
    return '\"$name\" will be removed from this device.';
  }

  @override
  String downloadsSize(String size) {
    return '$size on this device';
  }

  @override
  String get noMatches => 'No titles match these filters.';

  @override
  String get movieLabel => 'Movie';

  @override
  String get cancelDownload => 'Cancel download';

  @override
  String get deleteDownload => 'Delete download';

  @override
  String get switchProfile => 'Switch Profile';

  @override
  String get emptyListTitle => 'Your list is empty';

  @override
  String get emptyListHint => 'Titles you add to My List appear here.';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get clear => 'Clear';

  @override
  String get emptyCatalogueTitle => 'Nothing to watch yet';

  @override
  String get emptyCatalogueHint =>
      'The catalogue is empty. The collector fills it from your licensed sources.';

  @override
  String get playbackSource => 'Playback source';

  @override
  String get playbackSourceHint =>
      'Choose which provider supplies this stream.';

  @override
  String get playbackSourceDefault => 'Default';

  @override
  String episodesCount(int count) {
    return '$count episodes';
  }
}
