import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Application and default device name.
  ///
  /// In en, this message translates to:
  /// **'OWON B41T'**
  String get appTitle;

  /// Title shown in the scanner screen app bar.
  ///
  /// In en, this message translates to:
  /// **'OWON B41T — Scan'**
  String get scanScreenTitle;

  /// Label on the scan action button when idle.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get buttonScan;

  /// Label on the scan action button while a scan is running.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get buttonScanning;

  /// Label on the connect button in the device list.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get buttonConnect;

  /// Label on the disconnect button in the multimeter screen.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get buttonDisconnect;

  /// Label on the confirm button inside the rename dialog.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get buttonRename;

  /// Label on dialog cancel buttons.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// Label on the clear-history button in the sidebar.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get buttonClear;

  /// Label on the retry button shown on BLE error screens.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get buttonRetry;

  /// Tooltip for the rename icon button in the app bar.
  ///
  /// In en, this message translates to:
  /// **'Rename device'**
  String get tooltipRenameDevice;

  /// Tooltip shown when the native title bar is visible.
  ///
  /// In en, this message translates to:
  /// **'Hide window decoration'**
  String get tooltipHideDecoration;

  /// Tooltip shown when the native title bar is hidden.
  ///
  /// In en, this message translates to:
  /// **'Show window decoration'**
  String get tooltipShowDecoration;

  /// Tooltip on the sidebar toggle strip when the sidebar is open.
  ///
  /// In en, this message translates to:
  /// **'Hide sidebar'**
  String get tooltipHideSidebar;

  /// Tooltip on the sidebar toggle strip when the sidebar is closed.
  ///
  /// In en, this message translates to:
  /// **'Show sidebar'**
  String get tooltipShowSidebar;

  /// Tooltip on the console pause button when the console is live.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get tooltipPause;

  /// Tooltip on the console pause button when the console is paused.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get tooltipResume;

  /// Section header above the hardware control buttons.
  ///
  /// In en, this message translates to:
  /// **'CONTROLS'**
  String get controlsPanelLabel;

  /// Label for the history chart tab in the sidebar.
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get tabHistory;

  /// Label for the console log tab in the sidebar.
  ///
  /// In en, this message translates to:
  /// **'CONSOLE'**
  String get tabConsole;

  /// Label for the minimum value statistic.
  ///
  /// In en, this message translates to:
  /// **'MIN'**
  String get statMin;

  /// Label for the average value statistic.
  ///
  /// In en, this message translates to:
  /// **'AVG'**
  String get statAvg;

  /// Label for the maximum value statistic.
  ///
  /// In en, this message translates to:
  /// **'MAX'**
  String get statMax;

  /// Label next to the compatible-devices filter switch.
  ///
  /// In en, this message translates to:
  /// **'Compatible only'**
  String get compatibleOnly;

  /// Badge label shown for AC measurement modes.
  ///
  /// In en, this message translates to:
  /// **'AC'**
  String get badgeAc;

  /// Badge label shown for DC measurement modes.
  ///
  /// In en, this message translates to:
  /// **'DC'**
  String get badgeDc;

  /// Placeholder shown in the history chart before data arrives.
  ///
  /// In en, this message translates to:
  /// **'Waiting for data...'**
  String get waitingForData;

  /// Placeholder shown in the console log before data arrives.
  ///
  /// In en, this message translates to:
  /// **'No data yet...'**
  String get noDataYet;

  /// Title of the rename-device dialog.
  ///
  /// In en, this message translates to:
  /// **'Rename Device'**
  String get renameDialogTitle;

  /// Hint text inside the rename text field.
  ///
  /// In en, this message translates to:
  /// **'Up to 14 characters'**
  String get renameDialogHint;

  /// Validation note shown below the rename text field.
  ///
  /// In en, this message translates to:
  /// **'Cannot contain ?, *, @, or comma'**
  String get renameDialogValidationNote;

  /// SnackBar message shown after a successful rename.
  ///
  /// In en, this message translates to:
  /// **'Device renamed successfully'**
  String get deviceRenamedSuccess;

  /// Primary message when the filter is on but no devices match.
  ///
  /// In en, this message translates to:
  /// **'No compatible devices found'**
  String get noCompatibleDevices;

  /// Primary message while scanning with no results yet.
  ///
  /// In en, this message translates to:
  /// **'Searching for devices...'**
  String get searchingForDevices;

  /// Secondary hint when no compatible devices are found.
  ///
  /// In en, this message translates to:
  /// **'Make sure your OWON B41T is powered on,\nor disable the filter to see all devices'**
  String get compatibleDeviceHint;

  /// Secondary hint while scanning with no results.
  ///
  /// In en, this message translates to:
  /// **'Make sure your OWON B41T is powered on'**
  String get devicePowerOnHint;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
