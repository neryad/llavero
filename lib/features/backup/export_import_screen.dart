import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../data/backup/backup_file_gateway.dart';
import '../../data/backup/emergency_sheet_pdf.dart';
import '../../data/backup/plain_export_service.dart';
import '../../data/backup/vault_backup_service.dart';
import '../../data/models/entry.dart';
import '../../data/models/vault_category.dart';
import '../../data/vault_storage.dart';
import '../../l10n/generated/app_localizations.dart';
import '../security/reauthentication_dialog.dart';

class ExportImportScreen extends StatefulWidget {
  const ExportImportScreen({super.key, this.fileGateway, this.backupService});

  final BackupFileGateway? fileGateway;
  final VaultBackupService? backupService;

  @override
  State<ExportImportScreen> createState() => _ExportImportScreenState();
}

class _ExportImportScreenState extends State<ExportImportScreen> {
  final PlainExportService _plainExportService = const PlainExportService();
  final Set<String> _selectedPdfEntryIds = <String>{};
  late final BackupFileGateway _fileGateway;
  late final VaultBackupService _backupService;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _fileGateway = widget.fileGateway ?? PlatformBackupFileGateway();
    _backupService = widget.backupService ?? VaultBackupService();
  }

  @override
  Widget build(BuildContext context) {
    final controllers = AppScope.of(context);
    final strings = AppLocalizations.of(context);
    final entries = controllers.entries.entries
        .where((entry) => entry.deletedAt == null)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text(strings.backupCenterTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (controllers.settings.needsBackupReminder)
                  _BackupReminderCard(
                    title: strings.backupReminderTitle,
                    message: strings.backupReminderDescription,
                  ),
                _buildEncryptedBackupCard(strings),
                _buildPlainExportCard(strings),
                _buildEmergencySheetCard(strings, entries),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEncryptedBackupCard(AppLocalizations strings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.backupEncryptedTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(strings.backupEncryptedDescription),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  key: const ValueKey('backup-export-encrypted'),
                  onPressed: _isBusy ? null : _exportEncryptedBackup,
                  icon: const Icon(Icons.lock_outline_rounded),
                  label: Text(strings.backupCreateEncrypted),
                ),
                OutlinedButton.icon(
                  key: const ValueKey('backup-import-button'),
                  onPressed: _isBusy ? null : _importBackup,
                  icon: const Icon(Icons.file_open_outlined),
                  label: Text(strings.backupImportButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlainExportCard(AppLocalizations strings) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.backupPlainTextTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(strings.backupPlainTextDescription),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: colors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    strings.plainExportWarning,
                    style: TextStyle(color: colors.error),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  key: const ValueKey('backup-export-json'),
                  onPressed: _isBusy
                      ? null
                      : () => _exportPlainText(isJson: true),
                  icon: const Icon(Icons.data_object_rounded),
                  label: Text(strings.backupExportJson),
                ),
                OutlinedButton.icon(
                  key: const ValueKey('backup-export-csv'),
                  onPressed: _isBusy
                      ? null
                      : () => _exportPlainText(isJson: false),
                  icon: const Icon(Icons.table_chart_outlined),
                  label: Text(strings.backupExportCsv),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencySheetCard(
    AppLocalizations strings,
    List<VaultEntry> entries,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.backupEmergencySheetTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(strings.backupEmergencyDescription),
            const SizedBox(height: 12),
            Text(
              strings.backupSelectEntries,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(strings.backupNoEntries),
              )
            else
              for (final entry in entries)
                CheckboxListTile(
                  key: ValueKey('backup-pdf-entry-${entry.id}'),
                  contentPadding: EdgeInsets.zero,
                  value: _selectedPdfEntryIds.contains(entry.id),
                  title: Text(entry.title),
                  onChanged: _isBusy
                      ? null
                      : (selected) => setState(() {
                          if (selected ?? false) {
                            _selectedPdfEntryIds.add(entry.id);
                          } else {
                            _selectedPdfEntryIds.remove(entry.id);
                          }
                        }),
                ),
            const SizedBox(height: 8),
            FilledButton.icon(
              key: const ValueKey('backup-create-pdf'),
              onPressed: _isBusy || _selectedPdfEntryIds.isEmpty
                  ? null
                  : _createEmergencySheet,
              icon: const Icon(Icons.print_outlined),
              label: Text(strings.backupGeneratePdf),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportEncryptedBackup() async {
    final strings = AppLocalizations.of(context);
    final password = await _askBackupPassword(confirmPassword: true);
    if (password == null || !mounted) {
      return;
    }
    if (!await _reauthenticate(
          prompt: strings.reauthenticateToExport,
          reason: strings.reauthenticationExportReason,
        ) ||
        !mounted) {
      return;
    }

    await _runBusy(() async {
      final controllers = AppScope.of(context);
      final contents = VaultContents(
        entries: controllers.entries.entries,
        customCategories: controllers.entries.customCategories,
      );
      final bytes = await _backupService.createBackup(
        contents: contents,
        password: password,
      );
      final completed = await _chooseFileDestination(
        bytes: bytes,
        fileName: 'llavero-backup.llavero',
      );
      if (completed && mounted) {
        await controllers.settings.recordEncryptedBackup();
        if (mounted) {
          _showMessage(strings.backupExportCompleted);
        }
      }
    });
  }

  Future<void> _importBackup() async {
    await _runBusy(() async {
      final bytes = await _fileGateway.pickBackupFile();
      if (bytes == null || !mounted) {
        return;
      }
      final password = await _askBackupPassword(importing: true);
      if (password == null || !mounted) {
        return;
      }

      final imported = await _backupService.readBackup(
        bytes: bytes,
        password: password,
      );
      final choice = await _showImportPreview(imported);
      if (choice == null || !mounted) {
        return;
      }
      if (choice == _ImportChoice.replace) {
        if (!await _confirmVaultReplacement() || !mounted) {
          return;
        }
        final strings = AppLocalizations.of(context);
        if (!await _reauthenticate(
              prompt: strings.reauthenticateToReplace,
              reason: strings.reauthenticationReplaceReason,
            ) ||
            !mounted) {
          return;
        }
      }
      if (!mounted) {
        return;
      }

      final entries = AppScope.of(context).entries;
      if (choice == _ImportChoice.merge) {
        await entries.mergeContents(imported);
      } else {
        await entries.replaceContents(imported);
      }
      if (mounted) {
        _showMessage(
          choice == _ImportChoice.merge
              ? AppLocalizations.of(context).backupImportCompleted
              : AppLocalizations.of(context).backupReplaceCompleted,
        );
      }
    });
  }

  Future<void> _exportPlainText({required bool isJson}) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await _showSensitiveExportWarning(
      title: strings.plainExportWarningTitle,
      message: strings.plainExportWarning,
      details: strings.plainExportWarningDetails,
    );
    if (!confirmed ||
        !mounted ||
        !await _reauthenticate(
          prompt: strings.reauthenticateToExport,
          reason: strings.reauthenticationExportReason,
        )) {
      return;
    }

    await _runBusy(() async {
      final controllers = AppScope.of(context);
      final contents = VaultContents(
        entries: controllers.entries.entries,
        customCategories: controllers.entries.customCategories,
      );
      final text = isJson
          ? _plainExportService.encodeJson(contents)
          : _plainExportService.encodeCsv(contents);
      final completed = await _chooseFileDestination(
        bytes: Uint8List.fromList(utf8.encode(text)),
        fileName: isJson ? 'llavero-export.json' : 'llavero-export.csv',
      );
      if (completed && mounted) {
        _showMessage(strings.fileExportCompleted);
      }
    });
  }

  Future<void> _createEmergencySheet() async {
    final strings = AppLocalizations.of(context);
    final confirmed = await _showSensitiveExportWarning(
      title: strings.pdfExportWarningTitle,
      message: strings.pdfExportWarning,
    );
    if (!confirmed ||
        !mounted ||
        !await _reauthenticate(
          prompt: strings.reauthenticateToExport,
          reason: strings.reauthenticationExportReason,
        )) {
      return;
    }

    await _runBusy(() async {
      final controllers = AppScope.of(context);
      final entries = controllers.entries.entries
          .where(
            (entry) =>
                entry.deletedAt == null &&
                _selectedPdfEntryIds.contains(entry.id),
          )
          .toList(growable: false);
      if (entries.isEmpty) {
        return;
      }
      final bytes = await EmergencySheetPdf.create(
        entries: entries,
        labels: EmergencySheetLabels(
          title: strings.backupEmergencySheetTitle,
          category: strings.entryCategory,
          person: strings.entryPerson,
          notes: strings.entryNotes,
        ),
        categoryNamesById: _categoryNames(
          strings,
          controllers.entries.customCategories,
        ),
      );
      final completed = await _chooseFileDestination(
        bytes: bytes,
        fileName: 'llavero-emergency-sheet.pdf',
        isPdf: true,
      );
      if (completed && mounted) {
        _showMessage(strings.fileExportCompleted);
      }
    });
  }

  Future<String?> _askBackupPassword({
    bool importing = false,
    bool confirmPassword = false,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _BackupPasswordDialog(
        importing: importing,
        confirmPassword: confirmPassword,
      ),
    );
  }

  Future<bool> _reauthenticate({
    required String prompt,
    required String reason,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => ReauthenticationDialog(
            controllers: AppScope.of(context),
            prompt: prompt,
            reason: reason,
          ),
        ) ??
        false;
  }

  Future<bool> _showSensitiveExportWarning({
    required String title,
    required String message,
    String? details,
  }) async {
    final strings = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            icon: Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(title),
            content: Text(details == null ? message : '$message\n\n$details'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(strings.cancel),
              ),
              FilledButton(
                key: const ValueKey('confirm-plain-export-warning'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(strings.confirm),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _chooseFileDestination({
    required Uint8List bytes,
    required String fileName,
    bool isPdf = false,
  }) async {
    final destination = await showDialog<_ExportDestination>(
      context: context,
      builder: (dialogContext) {
        final strings = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: Text(strings.backupDestinationTitle),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.cancel),
            ),
            if (isPdf)
              TextButton(
                key: const ValueKey('backup-destination-print'),
                onPressed: () =>
                    Navigator.pop(dialogContext, _ExportDestination.print),
                child: Text(strings.backupPrint),
              ),
            TextButton(
              key: const ValueKey('backup-destination-share'),
              onPressed: () =>
                  Navigator.pop(dialogContext, _ExportDestination.share),
              child: Text(strings.backupShareFile),
            ),
            FilledButton(
              key: const ValueKey('backup-destination-save'),
              onPressed: () =>
                  Navigator.pop(dialogContext, _ExportDestination.save),
              child: Text(strings.backupSaveFile),
            ),
          ],
        );
      },
    );
    if (destination == null) {
      return false;
    }
    return switch (destination) {
      _ExportDestination.save => _fileGateway.saveFile(
        bytes: bytes,
        fileName: fileName,
      ),
      _ExportDestination.share => _fileGateway.shareFile(
        bytes: bytes,
        fileName: fileName,
      ),
      _ExportDestination.print => _fileGateway.printPdf(bytes: bytes),
    };
  }

  Future<_ImportChoice?> _showImportPreview(VaultContents contents) {
    return showDialog<_ImportChoice>(
      context: context,
      builder: (dialogContext) {
        final strings = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: Text(strings.backupImportPreviewTitle),
          content: Text(
            strings.backupImportPreview(
              contents.entries.length,
              contents.customCategories.length,
            ),
            key: const ValueKey('backup-import-preview'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.cancel),
            ),
            TextButton(
              key: const ValueKey('backup-import-merge'),
              onPressed: () =>
                  Navigator.pop(dialogContext, _ImportChoice.merge),
              child: Text(strings.backupMerge),
            ),
            FilledButton(
              key: const ValueKey('backup-import-replace'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () =>
                  Navigator.pop(dialogContext, _ImportChoice.replace),
              child: Text(strings.backupReplace),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmVaultReplacement() async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => _ReplaceVaultDialog(),
        ) ??
        false;
  }

  Future<void> _runBusy(Future<void> Function() action) async {
    if (_isBusy) {
      return;
    }
    setState(() => _isBusy = true);
    try {
      await action();
    } on BackupFileException {
      if (mounted) {
        _showMessage(AppLocalizations.of(context).backupImportInvalid);
      }
    } on Object {
      if (mounted) {
        _showMessage(AppLocalizations.of(context).backupExportFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Map<String, String> _categoryNames(
    AppLocalizations strings,
    List<VaultCategory> customCategories,
  ) {
    return <String, String>{
      'wifi': strings.categoryWifi,
      'email': strings.categoryEmail,
      'streaming': strings.categoryStreaming,
      'banking': strings.categoryBanking,
      'pin': strings.categoryPin,
      'social': strings.categorySocial,
      'devices': strings.categoryDevices,
      'documents': strings.categoryDocuments,
      'other': strings.categoryOther,
      for (final category in customCategories) category.id: category.name,
    };
  }
}

class _BackupReminderCard extends StatelessWidget {
  const _BackupReminderCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      key: const ValueKey('backup-reminder-banner'),
      color: colors.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.backup_outlined, color: colors.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(message),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackupPasswordDialog extends StatefulWidget {
  const _BackupPasswordDialog({
    required this.importing,
    required this.confirmPassword,
  });

  final bool importing;
  final bool confirmPassword;

  @override
  State<_BackupPasswordDialog> createState() => _BackupPasswordDialogState();
}

class _BackupPasswordDialogState extends State<_BackupPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(
        widget.importing
            ? strings.backupPasswordImportTitle
            : strings.backupPasswordTitle,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                widget.importing
                    ? strings.backupPasswordImportHint
                    : strings.backupPasswordHint,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('backup-password-field'),
              controller: _passwordController,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                labelText: strings.backupPasswordLabel,
                errorText: _errorMessage,
              ),
            ),
            if (widget.confirmPassword) ...[
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('backup-password-confirmation-field'),
                controller: _confirmationController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: strings.backupPasswordConfirmLabel,
                  errorText: _errorMessage,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.cancel),
        ),
        FilledButton(
          key: const ValueKey('backup-password-open'),
          onPressed: _submit,
          child: Text(
            widget.importing ? strings.backupOpenBackup : strings.confirm,
          ),
        ),
      ],
    );
  }

  void _submit() {
    final strings = AppLocalizations.of(context);
    final password = _passwordController.text;
    if (!widget.importing &&
        password.length < VaultBackupService.minimumPasswordLength) {
      setState(() => _errorMessage = strings.backupPasswordTooShort);
      return;
    }
    if (widget.confirmPassword && password != _confirmationController.text) {
      setState(() => _errorMessage = strings.backupPasswordMismatch);
      return;
    }
    Navigator.pop(context, password);
  }
}

class _ReplaceVaultDialog extends StatefulWidget {
  @override
  State<_ReplaceVaultDialog> createState() => _ReplaceVaultDialogState();
}

class _ReplaceVaultDialogState extends State<_ReplaceVaultDialog> {
  final TextEditingController _confirmationController = TextEditingController();

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final phrase = strings.backupReplacePhrase;
    final canReplace = _confirmationController.text.trim() == phrase;
    return AlertDialog(
      title: Text(strings.backupReplaceConfirmationTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(strings.backupReplaceConfirmationMessage),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('backup-replace-confirmation-field'),
            controller: _confirmationController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: strings.backupReplacePhraseLabel(phrase),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(strings.cancel),
        ),
        FilledButton(
          key: const ValueKey('backup-replace-confirm'),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: canReplace ? () => Navigator.pop(context, true) : null,
          child: Text(strings.backupReplace),
        ),
      ],
    );
  }
}

enum _ExportDestination { save, share, print }

enum _ImportChoice { merge, replace }
