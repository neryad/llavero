import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/app_routes.dart';
import '../../core/app_scope.dart';
import '../../core/utils/wifi_qr.dart';
import '../../data/models/entry.dart';
import '../../data/models/vault_category.dart';
import '../../l10n/generated/app_localizations.dart';
import 'secret_value.dart';

class EntryDetailScreen extends StatelessWidget {
  const EntryDetailScreen({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context) {
    final controllers = AppScope.of(context);
    final strings = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: controllers.entries,
      builder: (context, _) {
        final entry = _findEntry(controllers.entries.entries, entryId);
        if (entry == null) {
          return Scaffold(
            appBar: AppBar(title: Text(strings.details)),
            body: Center(child: Text(strings.startupFailed)),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              entry.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                key: const ValueKey('toggle-favorite-button'),
                tooltip: entry.isFavorite
                    ? strings.removeFavorite
                    : strings.favorite,
                onPressed: () => _toggleFavorite(context, controllers, entry),
                icon: Icon(
                  entry.isFavorite
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _MetadataCard(
                      entry: entry,
                      customCategories: controllers.entries.customCategories,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          key: const ValueKey('edit-entry-button'),
                          onPressed: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.entryForm, arguments: entry.id),
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(strings.edit),
                        ),
                        OutlinedButton.icon(
                          key: const ValueKey('duplicate-entry-button'),
                          onPressed: () =>
                              _duplicate(context, controllers, entry),
                          icon: const Icon(Icons.content_copy_rounded),
                          label: Text(strings.duplicate),
                        ),
                        OutlinedButton.icon(
                          key: const ValueKey('move-to-trash-button'),
                          onPressed: () =>
                              _moveToTrash(context, controllers, entry),
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: Text(strings.moveToTrash),
                        ),
                      ],
                    ),
                    if (entry.notes.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(entry.notes),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    for (var index = 0; index < entry.fields.length; index++)
                      _buildField(context, entry.fields[index], index),
                    if (entry.category == 'wifi') ...[
                      const SizedBox(height: 16),
                      _buildWifiQr(context, entry),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(BuildContext context, EntryField field, int index) {
    final strings = AppLocalizations.of(context);
    return Card(
      key: ValueKey('entry-field-$index'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SecretValue(
                    value: field.value,
                    isSecret: field.isSecret,
                    index: index,
                  ),
                ],
              ),
            ),
            IconButton(
              key: ValueKey('copy-field-$index'),
              tooltip: strings.copy,
              onPressed: () => _copyField(context, field.value),
              icon: const Icon(Icons.copy_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWifiQr(BuildContext context, VaultEntry entry) {
    final strings = AppLocalizations.of(context);
    final networkName = _wifiField(
      entry.fields,
      expectedLabels: <String>{
        strings.fieldNetworkName.toLowerCase(),
        'network name',
      },
      fallback: (field) => !field.isSecret && field.type == EntryFieldType.text,
    );
    if (networkName == null || networkName.value.trim().isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(strings.qrMissingNetwork),
        ),
      );
    }
    final password = _wifiField(
      entry.fields,
      expectedLabels: <String>{strings.fieldPassword.toLowerCase(), 'password'},
      fallback: (field) => field.isSecret,
    );
    final securityType = _wifiField(
      entry.fields,
      expectedLabels: <String>{
        strings.fieldSecurityType.toLowerCase(),
        'security type',
      },
      fallback: (field) =>
          !field.isSecret &&
          field.type == EntryFieldType.text &&
          field != networkName,
    );
    final payload = buildWifiQrPayload(
      networkName: networkName.value,
      password: password?.value,
      securityType: securityType?.value,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(strings.wifiQr, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(strings.wifiQrHint, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            QrImageView(
              key: const ValueKey('wifi-qr-code'),
              data: payload,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          ],
        ),
      ),
    );
  }

  EntryField? _wifiField(
    List<EntryField> fields, {
    required Set<String> expectedLabels,
    required bool Function(EntryField field) fallback,
  }) {
    for (final field in fields) {
      if (expectedLabels.contains(field.label.trim().toLowerCase())) {
        return field;
      }
    }
    for (final field in fields) {
      if (fallback(field)) {
        return field;
      }
    }
    return null;
  }

  void _toggleFavorite(
    BuildContext context,
    AppControllers controllers,
    VaultEntry entry,
  ) {
    _runAction(context, () {
      return controllers.entries.updateEntry(
        entry.copyWith(isFavorite: !entry.isFavorite),
      );
    });
  }

  Future<void> _duplicate(
    BuildContext context,
    AppControllers controllers,
    VaultEntry entry,
  ) async {
    final strings = AppLocalizations.of(context);
    try {
      final duplicate = await controllers.entries.duplicateEntry(entry.id);
      await controllers.entries.updateEntry(
        duplicate.copyWith(
          title: '${entry.title} (${strings.duplicateSuffix})',
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.entrySaved)));
      }
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.saveFailed)));
      }
    }
  }

  Future<void> _moveToTrash(
    BuildContext context,
    AppControllers controllers,
    VaultEntry entry,
  ) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.moveToTrash),
        content: Text(strings.deleteEntryDialog),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            key: const ValueKey('confirm-delete-entry-button'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(strings.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    try {
      await controllers.entries.moveToTrash(entry.id);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.saveFailed)));
      }
    }
  }

  Future<void> _copyField(BuildContext context, String value) async {
    final strings = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: value));
    await HapticFeedback.selectionClick();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.copied)));
    }
  }

  void _runAction(BuildContext context, Future<void> Function() action) {
    final strings = AppLocalizations.of(context);
    action().catchError((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.saveFailed)));
      }
    });
  }

  VaultEntry? _findEntry(List<VaultEntry> entries, String id) {
    for (final entry in entries) {
      if (entry.id == id) {
        return entry;
      }
    }
    return null;
  }
}

class _MetadataCard extends StatelessWidget {
  const _MetadataCard({required this.entry, required this.customCategories});

  final VaultEntry entry;
  final List<VaultCategory> customCategories;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _categoryName(strings, entry.category),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            if (entry.person?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Text(entry.person!),
            ],
          ],
        ),
      ),
    );
  }

  String _categoryName(AppLocalizations strings, String id) {
    for (final category in customCategories) {
      if (category.id == id) {
        return category.name;
      }
    }
    return switch (id) {
      'wifi' => strings.categoryWifi,
      'email' => strings.categoryEmail,
      'streaming' => strings.categoryStreaming,
      'banking' => strings.categoryBanking,
      'pin' => strings.categoryPin,
      'social' => strings.categorySocial,
      'devices' => strings.categoryDevices,
      'documents' => strings.categoryDocuments,
      _ => strings.categoryOther,
    };
  }
}
