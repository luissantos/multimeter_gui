// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OWON B41T';

  @override
  String get scanScreenTitle => 'OWON B41T — Scan';

  @override
  String get buttonScan => 'Scan';

  @override
  String get buttonScanning => 'Scanning...';

  @override
  String get buttonConnect => 'Connect';

  @override
  String get buttonDisconnect => 'Disconnect';

  @override
  String get buttonRename => 'Rename';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonClear => 'Clear';

  @override
  String get buttonRetry => 'Retry';

  @override
  String get tooltipRenameDevice => 'Rename device';

  @override
  String get tooltipHideDecoration => 'Hide window decoration';

  @override
  String get tooltipShowDecoration => 'Show window decoration';

  @override
  String get tooltipHideSidebar => 'Hide sidebar';

  @override
  String get tooltipShowSidebar => 'Show sidebar';

  @override
  String get tooltipPause => 'Pause';

  @override
  String get tooltipResume => 'Resume';

  @override
  String get controlsPanelLabel => 'CONTROLS';

  @override
  String get tabHistory => 'HISTORY';

  @override
  String get tabConsole => 'CONSOLE';

  @override
  String get statMin => 'MIN';

  @override
  String get statAvg => 'AVG';

  @override
  String get statMax => 'MAX';

  @override
  String get compatibleOnly => 'Compatible only';

  @override
  String get badgeAc => 'AC';

  @override
  String get badgeDc => 'DC';

  @override
  String get waitingForData => 'Waiting for data...';

  @override
  String get noDataYet => 'No data yet...';

  @override
  String get renameDialogTitle => 'Rename Device';

  @override
  String get renameDialogHint => 'Up to 14 characters';

  @override
  String get renameDialogValidationNote => 'Cannot contain ?, *, @, or comma';

  @override
  String get deviceRenamedSuccess => 'Device renamed successfully';

  @override
  String get noCompatibleDevices => 'No compatible devices found';

  @override
  String get searchingForDevices => 'Searching for devices...';

  @override
  String get compatibleDeviceHint =>
      'Make sure your OWON B41T is powered on,\nor disable the filter to see all devices';

  @override
  String get devicePowerOnHint => 'Make sure your OWON B41T is powered on';
}
