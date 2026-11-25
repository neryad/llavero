import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/entry.dart';
import '../security/reauthentication_dialog.dart';
import '../../l10n/generated/app_localizations.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  late AppControllers _controllers;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    _initialized = true;
    _controllers = AppScope.of(context);
    unawaited(_purgeExpiredEntries());
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.trashTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListenableBuilder(
              listenable: _controllers.entries,
              builder: (context, _) {
                final trashedEntries =
                    _controllers.entries.entries
                        .where((entry) => entry.deletedAt != null)
                        .toList()
                      ..sort(_sortNewestFirst);
                if (trashedEntries.isEmpty) {
                  return EmptyState(
                    icon: Icons.delete_outline_rounded,
                    title: strings.trashEmpty,
                    message: strings.trashRetentionMessage,
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    for (final entry in trashedEntries)
                      _TrashEntryCard(
                        entry: entry,
                        onRestore: () => _restore(entry),
                        onDeleteForever: () => _deleteForever(entry),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        strings.trashRetentionMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  int _sortNewestFirst(VaultEntry first, VaultEntry second) {
    return second.deletedAt!.compareTo(first.deletedAt!);
  }

  Future<void> _purgeExpiredEntries() async {
    try {
      await _controllers.entries.purgeExpiredTrash();
    } on Object {
      if (mounted) {
        _showMessage(AppLocalizations.of(context).saveFailed);
      }
    }
  }

  Future<void> _restore(VaultEntry entry) async {
    final strings = AppLocalizations.of(context);
    try {
      await _controllers.entries.restoreFromTrash(entry.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.entryRestored)));
      }
    } on Object {
      if (mounted) {
        _showMessage(strings.saveFailed);
      }
    }
  }

  Future<void> _deleteForever(VaultEntry entry) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.deleteForever),
        content: Text(strings.deleteForeverConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            key: const ValueKey('confirm-delete-forever'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(strings.deleteForever),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    final authenticated = await _reauthenticate();
    if (!authenticated || !mounted) {
      return;
    }
    try {
      await _controllers.entries.deleteForever(entry.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.entryDeletedForever)));
      }
    } on Object {
      if (mounted) {
        _showMessage(strings.saveFailed);
      }
    }
  }

  Future<bool> _reauthenticate() async {
    final strings = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (_) => ReauthenticationDialog(
            controllers: _controllers,
            prompt: strings.reauthenticateToDelete,
            reason: strings.reauthenticationReason,
          ),
        ) ??
        false;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TrashEntryCard extends StatelessWidget {
  const _TrashEntryCard({
    required this.entry,
    required this.onRestore,
    required this.onDeleteForever,
  });

  final VaultEntry entry;
  final VoidCallback onRestore;
  final VoidCallback onDeleteForever;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Card(
      key: ValueKey('trash-entry-${entry.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.title, style: Theme.of(context).textTheme.titleMedium),
            if (entry.person?.isNotEmpty ?? false) ...[
              const SizedBox(height: 4),
              Text(entry.person!),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  key: ValueKey('trash-restore-${entry.id}'),
                  onPressed: onRestore,
                  icon: const Icon(Icons.restore_rounded),
                  label: Text(strings.trashRestore),
                ),
                TextButton.icon(
                  key: ValueKey('trash-delete-${entry.id}'),
                  onPressed: onDeleteForever,
                  icon: const Icon(Icons.delete_forever_outlined),
                  label: Text(strings.deleteForever),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
