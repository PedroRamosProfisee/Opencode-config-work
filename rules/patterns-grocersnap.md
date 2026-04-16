# GrocerSnap Learned Patterns

> Loaded only in GrocerSnap workspace sessions. Split from learned-patterns.md on 2026-04-10.

## Preferences

- No Mockito — manual fakes only; no GlobalScope; no `kotlinOptions`; no `kotlin-android` plugin; Room version stays at 1
- Do NOT use Accompanist for permissions — use native `ActivityResultContracts.RequestPermission` + `ContextCompat.checkSelfPermission`

## Codebase Patterns

- `AlarmScheduler.setAlarmSafely()` uses three-tier strategy: API 31+ `canScheduleExactAlarms()` → `setAlarmClock()`; API 34+ without permission → `setAndAllowWhileIdle()`; else → `setExactAndAllowWhileIdle()`
- `NotificationManager.notify()` must be called on the main thread — `Dispatchers.IO` silently fails on some Android versions; always `withContext(Dispatchers.Main)`
- AlarmManager fully replaces WorkManager for notifications

## Linting

### Android App (GrocerSnap)
- ktlint: add to `build.gradle.kts` — see GrocerSnap/.editorconfig for rule overrides
- detekt: config at `GrocerSnap/detekt.yml` — run `./gradlew detekt`
- Compose-aware: rules relaxed for long Compose functions and ViewModel constructors

### Kotlin API (GrocerSnap-API)
- Shares GrocerSnap's ktlint + detekt config
- Additional: no `GlobalScope`, prefer `CoroutineScope` with structured concurrency

## Common Errors

- `setExactAndAllowWhileIdle()` throws `SecurityException` on API 34+ without `SCHEDULE_EXACT_ALARM` — use `setAndAllowWhileIdle()` (inexact) instead
- Notification channel importance is cached from first install — changing in code has no effect; user must clear app data
