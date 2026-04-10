# OWON Multimeter — Development Guidelines

## Architecture

### Constructor Injection over Ambient DI
Services (`MultimeterProvider`, `WindowProvider`, `ZoomProvider`) are created once in `main()` and passed through constructors. There is no `provider` package. Do not add it back.

### Reactivity
- `ChangeNotifier` state: use `ListenableBuilder` (or `addListener`/`removeListener` in `StatefulWidget`) — not `Consumer`, `context.watch`, or `context.read`.
- Stream state: use `StreamBuilder` with `initialData` so `snapshot.requireData` never throws.

### Sealed State Models
Screen-level state is modelled as sealed classes with exhaustive `switch` expressions, not booleans/nullables scattered across the widget.
- See `lib/models/scanner_state.dart` for the pattern: `sealed class` → `final class` variants.
- Emit state from providers via `StreamController<T>.broadcast()`.

### Presenter Layer
All computation, formatting, and filtering logic lives in `lib/presenters/`, not in widgets.
- Presenters are plain Dart objects (no `ChangeNotifier`, no `StatefulWidget`).
- `StatelessWidget` holds a presenter as a `final` field, initialised in the constructor initializer list:
  ```dart
  class MyWidget extends StatelessWidget {
    final MyPresenter _presenter;
    MyWidget({required List<Foo> items}) : _presenter = MyPresenter(items);
  }
  ```
- Never instantiate a presenter inside `build()`.

### Single-Responsibility Presenters
- One presenter per domain concept, not one giant utility class.
- List-level operations (`ScannerPresenter`: sort, filter) are separate from per-item operations (`DevicePresenter`: `isOwon`).
- List presenters delegate to item presenters internally.

---

## Localisation
All user-visible strings use `context.l10n.*` (generated `AppLocalizations`). No hardcoded strings in widgets.

Capture l10n strings **before** any `await` to avoid `use_build_context_synchronously`:
```dart
final msg = context.l10n.someString; // before await
await doSomethingAsync();
showSnackBar(msg);                   // after await — safe
```

---

## Widgets

### Callbacks over Provider References
Widgets receive callbacks (`VoidCallback onRetry`, `Future<void> Function(ScanResult) onConnect`) rather than holding a reference to the provider. This keeps widgets testable and decoupled.

### Propagate Derived State Downward
Compute derived booleans (e.g. `isConnecting`) at the screen level and pass them down through `DeviceList` → `DeviceTile`. Widgets do not reach up to a provider to read state.

### `FloatingTitleBar` and `WindowDecorationToggle`
Both require an explicit `WindowProvider windowProvider` parameter. Always pass `widget.windowProvider` from the screen.

---

## BLE / Provider Notes
- `BleConnectionState` variants: `disconnected`, `scanning`, `connecting`, `connected`, `error`.
- Scan results are throttled (1 s timer) before being emitted to avoid excessive rebuilds.
- `_emitScannerState()` must be called after any state mutation that should update the scanner UI.
- `scannerStream` uses a broadcast controller — multiple listeners are safe.

---

## What Not to Do
- Do not use the `provider` package (`Consumer`, `context.watch`, `context.read`, `MultiProvider`).
- Do not put business logic or formatting in `build()` or widget methods.
- Do not make presenters static utility classes.
- Do not call `context.l10n` after an `await` without capturing the value first.
- Do not add `flutter_localizations` as a separate import in `main.dart` — `AppLocalizations.localizationsDelegates` already includes those delegates.
