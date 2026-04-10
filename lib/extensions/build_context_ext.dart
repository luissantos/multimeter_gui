/// Convenience accessor for [AppLocalizations] on [BuildContext].
///
/// Instead of `AppLocalizations.of(context)!.someKey`, write
/// `context.l10n.someKey`.
library;

import 'package:flutter/material.dart';
import '../gen_l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
