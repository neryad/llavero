# Vault Export and Import Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add offline encrypted backup/restore, reauthenticated plaintext and emergency-sheet exports, and a 30-day backup reminder.

**Architecture:** Keep archive crypto and serialization in testable data services, use `EntriesController` for atomic merge/replace, and keep file-picker/share/print flows in a dedicated export/import screen. Persist only the successful encrypted-backup timestamp through the existing settings store.

**Tech Stack:** Flutter/Dart, existing `cryptography`, `flutter_secure_storage`, `file_picker`, `share_plus`, `pdf`, `printing`, Flutter `ChangeNotifier`/`AppScope`, `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-11-25-vault-export-import-design.md`

## Global Constraints

- The app remains fully offline; do not add network permissions or network/analytics packages.
- Use only the already approved dependencies; add only `file_picker`, `share_plus`, `pdf`, and `printing` for this phase.
- Use the existing native Flutter state pattern and named routes; do not add a state-management package or code generation.
- The `.llavero` backup uses AES-256-GCM and PBKDF2-HMAC-SHA256 with at least 600,000 iterations and an independent password.
- The current vault format remains readable; imported content is written through the existing atomic `VaultStorage` path.
- Require reauthentication before every export; a failed/cancelled reauthentication must not share or save anything.
- Treat replacement import as destructive: require PIN or enabled device biometrics after typed confirmation and before changing the vault.
- Never log PINs, backup passwords, DEKs, or decrypted values; errors shown to users must not include backup contents.
- Every new visible string is localized in `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`.
- Work only on the existing `phase-5-entries` branch and stop after this phase; do not commit, push, or open a PR unless asked.

## Review Focus

- Malformed backup headers or excessive PBKDF2 iterations must be rejected before expensive derivation; test an out-of-range iteration count.
- Wrong passwords, modified ciphertext, and unsupported versions must fail without exposing contents or mutating the vault; test each failure.
- An interrupted/failed vault save must not publish half-imported entries/categories; test both in-memory state and reopened storage.
- ID collisions during merge must preserve existing records while adding missing IDs; test colliding entry and category IDs.
- Cancelled/failed reauthentication or a dismissed save/share flow must not export data or reset the backup reminder; test both paths.
- A failed/cancelled reauthentication after typed replacement confirmation must leave the current entries/categories unchanged; test the replacement flow.

---

### Task 1: Encrypted Backup Format

**Files:**
- Create: `lib/data/backup/vault_backup_service.dart`
- Test: `test/data/backup/vault_backup_service_test.dart`

**Interfaces:**
- Consumes: `VaultContents` from `lib/data/vault_storage.dart` and `VaultCrypto` from `lib/core/security/vault_crypto.dart`.
- Produces: `VaultBackupService.createBackup({required VaultContents contents, required String password}) -> Future<Uint8List>` and `VaultBackupService.readBackup({required List<int> bytes, required String password}) -> Future<VaultContents>`; invalid or unauthentic data throws one generic `BackupFileException`.

- [ ] **Step 1: Write failing archive tests.** Cover round-tripping active and trashed entries plus custom categories; reject a password shorter than 12 characters; reject a wrong password and tampering with the same generic exception; reject unsupported format versions and KDF iteration counts outside 600,000–2,000,000 before deriving a key.
- [ ] **Step 2: Run the tests to verify RED.** Run `flutter test test/data/backup/vault_backup_service_test.dart`; expected: compilation/test failures because the service does not exist.
- [ ] **Step 3: Implement the version-1 JSON archive.** Include format/content versions, PBKDF2 algorithm/iteration count/salt, AES-256-GCM nonce/ciphertext/tag; authenticate canonical header metadata as associated data. Use a fresh 16-byte salt and 12-byte nonce; keep the password transient and require at least 12 characters.
- [ ] **Step 4: Run the service tests to verify GREEN.** Run `flutter test test/data/backup/vault_backup_service_test.dart`; expected: all archive round-trip and rejection cases pass.

### Task 2: Atomic Merge and Replace

**Files:**
- Modify: `lib/controllers/entries_controller.dart`
- Test: `test/controllers/entries_controller_test.dart`

**Interfaces:**
- Consumes: `VaultContents` returned by `VaultBackupService.readBackup`.
- Produces: `Future<void> mergeContents(VaultContents imported)` and `Future<void> replaceContents(VaultContents imported)` on `EntriesController`.

- [ ] **Step 1: Write failing import tests.** Verify merge adds absent IDs, preserves current entries/categories on ID collisions, replace removes old entries/categories, and a failed storage save leaves both memory and persisted contents unchanged.
- [ ] **Step 2: Run the tests to verify RED.** Run `flutter test test/controllers/entries_controller_test.dart`; expected: the new APIs are missing.
- [ ] **Step 3: Implement serialized bulk import.** Combine or replace entries and categories, persist the complete candidate content once, and publish it to listeners only after the atomic save succeeds.
- [ ] **Step 4: Run the controller tests to verify GREEN.** Run `flutter test test/controllers/entries_controller_test.dart`; expected: import tests and existing controller tests pass.

### Task 3: Plain-Text Export and Emergency PDF

**Files:**
- Create: `lib/data/backup/plain_export_service.dart`
- Create: `lib/data/backup/emergency_sheet_pdf.dart`
- Modify: `pubspec.yaml` (add only `pdf`; refresh `pubspec.lock` via Pub)
- Create: `test/data/backup/plain_export_service_test.dart`
- Create: `test/data/backup/emergency_sheet_pdf_test.dart`

**Interfaces:**
- Consumes: `VaultContents`, `VaultEntry`, and caller-supplied localized labels.
- Produces: `PlainExportService.encodeJson(VaultContents) -> String`, `PlainExportService.encodeCsv(VaultContents) -> String`, and `EmergencySheetPdf.create({required List<VaultEntry> entries, required EmergencySheetLabels labels}) -> Future<Uint8List>`.

- [ ] **Step 1: Write failing serialization/PDF tests.** Verify JSON preserves entries/categories, CSV correctly quotes commas/quotes/newlines, contains field values, and neutralizes spreadsheet formula prefixes; verify PDF output starts with the valid `%PDF-` signature. The PDF screen test verifies only checked entries are passed to the generator.
- [ ] **Step 2: Run the tests to verify RED.** Run `flutter test test/data/backup/plain_export_service_test.dart test/data/backup/emergency_sheet_pdf_test.dart`; expected: service classes are missing.
- [ ] **Step 3: Implement deterministic exports.** Emit a versioned JSON object and RFC-4180-style CSV with one row per field (and one row for entries with no fields); prefix spreadsheet-formula-leading CSV values with an apostrophe; build the emergency sheet only from the selected entries and localized labels.
- [ ] **Step 4: Add `pdf` and generate a valid PDF.** Add only the allowed package, run `flutter pub get`, and render the selected entry details using the package's PDF document API.
- [ ] **Step 5: Run export tests to verify GREEN.** Run both test files above; expected: serialized data and PDF signature/selection assertions pass.

### Task 4: Backup-Date Preference and Reminder State

**Files:**
- Modify: `lib/controllers/settings_controller.dart`
- Test: `test/controllers/settings_controller_test.dart`

**Interfaces:**
- Produces: `DateTime? get lastEncryptedBackupAt`, `bool get needsBackupReminder`, and `Future<void> recordEncryptedBackup({DateTime? completedAt})` on `SettingsController`; constructor accepts an optional clock for deterministic tests.

- [ ] **Step 1: Write failing date tests.** Verify no timestamp triggers the reminder, exactly 30 days does not, more than 30 days does, a saved completion timestamp persists/restores, and malformed timestamp data does not crash initialization.
- [ ] **Step 2: Run the tests to verify RED.** Run `flutter test test/controllers/settings_controller_test.dart`; expected: backup-date APIs are missing.
- [ ] **Step 3: Implement private timestamp persistence.** Store only an ISO-8601 completion timestamp in `SecureValueStore`; count only completed encrypted file saves or successful shares.
- [ ] **Step 4: Run settings tests to verify GREEN.** Run `flutter test test/controllers/settings_controller_test.dart`; expected: date boundary and persistence cases pass alongside language tests.

### Task 5: Export/Import Screen and Application Integration

**Files:**
- Create: `lib/features/backup/export_import_screen.dart`
- Create: `lib/data/backup/backup_file_gateway.dart`
- Create: `lib/features/security/reauthentication_dialog.dart`
- Modify: `lib/features/trash/trash_screen.dart` (use shared reauthentication dialog)
- Modify: `lib/core/app_routes.dart`
- Modify: `lib/app.dart`
- Modify: `lib/features/home/home_screen.dart`
- Modify: `lib/l10n/app_es.arb`
- Modify: `lib/l10n/app_en.arb`
- Modify: `pubspec.yaml` (add only `file_picker`, `share_plus`, and `printing`; refresh lockfile via Pub)
- Create: `test/features/export_import_test.dart`
- Modify: `test/features/trash_test.dart`
- Modify: `PROGRESS.md`

**Interfaces:**
- Consumes: `VaultBackupService`, `PlainExportService`, `EmergencySheetPdf`, `EntriesController` import methods, `SettingsController` reminder state, and `LockController.reauthenticateWithPin`/`reauthenticateWithBiometrics`.
- Produces: `AppRoutes.exportImport`, an export/import screen reachable from Home, and a shared `ReauthenticationDialog` used by both the new screen and Trash.
- The screen consumes an injectable `BackupFileGateway` for native pick/save/share/print operations so cancellations can be tested without invoking platform UI.

- [ ] **Step 1: Write failing widget tests.** Verify Home navigates to export/import; import displays validated counts and requires an explicit merge/replace choice; replacement also requires reauthentication after typed confirmation and leaves the vault unchanged on failure; plaintext/PDF warnings precede export; failed export reauthentication performs no export; dismissing save/share does not clear the reminder.
- [ ] **Step 2: Run the tests to verify RED.** Run `flutter test test/features/export_import_test.dart`; expected: route/screen and required controls are missing.
- [ ] **Step 3: Add localized flow and shared reauthentication.** Add matching English/Spanish strings, extract the existing Trash reauthentication prompt to `ReauthenticationDialog`, and preserve its current behavior.
- [ ] **Step 4: Implement file and share flows.** Add only the allowed plugins; import `.llavero` with `file_picker`, validate before showing counts, and call the controller only after the user chooses merge or confirms replace and successfully reauthenticates for replacement. Require reauthentication before every export; show red plaintext/printing warnings before producing readable content.
- [ ] **Step 5: Add save/share/print actions and reminder UI.** Support saving or sharing encrypted/CSV/JSON files, printing/sharing selected-entry PDF, update the reminder only after a completed encrypted export, and show its localized 30-day banner on Home.
- [ ] **Step 6: Generate localizations and run feature tests.** Run `flutter gen-l10n` and `flutter test test/features/export_import_test.dart test/features/trash_test.dart`; expected: new flows pass and Trash reauthentication remains unchanged.
- [ ] **Step 7: Update `PROGRESS.md`.** Record phase 6, verification, limitations, and Spanish manual testing instructions for encrypted backup, restore, plaintext warning, PDF, and reminder.
- [ ] **Step 8: Run final phase verification.** Run `flutter analyze && flutter test`; expected: no analyzer issues and the full test suite passes. Also run `git diff --check`.

## Execution Review Focus

- Confirm the backup header is authenticated and bounds-checked before PBKDF2 work.
- Confirm import writes once and does not notify listeners before persistence succeeds.
- Confirm no cancellation, failed authentication, or failed share updates the last-backup timestamp.
- Confirm all UI errors and logs are generic and do not contain decrypted values or passwords.
- Confirm only the four permitted dependencies are added and the app remains offline.