import 'dart:async';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/models/entry.dart';
import '../data/models/vault_category.dart';
import '../data/vault_storage.dart';

/// Keeps decrypted entries in memory only while the vault is unlocked.
class EntriesController extends ChangeNotifier {
  EntriesController({
    VaultStorage? storage,
    DateTime Function()? clock,
    Uuid? uuid,
  }) : _storage = storage ?? VaultStorage(),
       _clock = clock ?? DateTime.now,
       _uuid = uuid ?? const Uuid();

  final VaultStorage _storage;
  final DateTime Function() _clock;
  final Uuid _uuid;
  final List<VaultEntry> _entries = <VaultEntry>[];
  final List<VaultCategory> _customCategories = <VaultCategory>[];
  Future<void> _operationQueue = Future<void>.value();
  SecretKey? _dataKey;
  int _sessionVersion = 0;

  bool get isUnlocked => _dataKey != null;

  List<VaultEntry> get entries => List<VaultEntry>.unmodifiable(_entries);

  List<VaultCategory> get customCategories =>
      List<VaultCategory>.unmodifiable(_customCategories);

  /// Loads and decrypts the vault for this unlocked session.
  Future<void> unlock({required SecretKey dataKey}) {
    final sessionVersion = _sessionVersion;
    return _serialize(() async {
      if (_dataKey != null) {
        return;
      }
      final loadedContents = await _storage.loadContents(dataKey: dataKey);
      if (sessionVersion != _sessionVersion) {
        return;
      }
      _entries
        ..clear()
        ..addAll(loadedContents.entries);
      _customCategories
        ..clear()
        ..addAll(loadedContents.customCategories);
      _dataKey = dataKey;
      notifyListeners();
    });
  }

  /// Removes the data key and all decrypted entry data from memory.
  void lock() {
    _sessionVersion++;
    if (_dataKey == null && _entries.isEmpty) {
      return;
    }
    _dataKey = null;
    _entries.clear();
    _customCategories.clear();
    notifyListeners();
  }

  /// Locks the vault and removes its encrypted file from private storage.
  Future<void> eraseVault() {
    lock();
    return _serialize(_storage.delete);
  }

  /// Creates a new entry and saves it before exposing it to listeners.
  Future<VaultEntry> addEntry({
    required String title,
    required String category,
    String? person,
    List<EntryField> fields = const <EntryField>[],
    String notes = '',
    bool isFavorite = false,
  }) {
    return _serialize(() async {
      _requireUnlocked();
      final now = _clock();
      final entry = VaultEntry(
        id: _uuid.v4(),
        title: title,
        category: category,
        person: person,
        fields: fields,
        notes: notes,
        isFavorite: isFavorite,
        createdAt: now,
        updatedAt: now,
      );
      await _saveChanges(<VaultEntry>[..._entries, entry]);
      return entry;
    });
  }

  /// Adds a custom category to the encrypted vault.
  Future<VaultCategory> addCustomCategory(String name) {
    return _serialize(() async {
      _requireUnlocked();
      final normalizedName = name.trim();
      if (normalizedName.isEmpty ||
          _customCategories.any(
            (category) =>
                category.name.toLowerCase() == normalizedName.toLowerCase(),
          )) {
        throw ArgumentError.value(name, 'name', 'Category name is invalid.');
      }
      final category = VaultCategory(id: _uuid.v4(), name: normalizedName);
      await _saveChanges(
        _entries,
        customCategories: <VaultCategory>[..._customCategories, category],
      );
      return category;
    });
  }

  /// Creates a new entry with the same data but a fresh identity and dates.
  Future<VaultEntry> duplicateEntry(String id) {
    return _serialize(() async {
      _requireUnlocked();
      final original = _entries[_entryIndex(id)];
      final now = _clock();
      final duplicate = original.copyWith(
        id: _uuid.v4(),
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
      );
      await _saveChanges(<VaultEntry>[..._entries, duplicate]);
      return duplicate;
    });
  }

  /// Updates an existing entry while preserving its original creation date.
  Future<void> updateEntry(VaultEntry entry) {
    return _serialize(() async {
      _requireUnlocked();
      final index = _entryIndex(entry.id);
      final original = _entries[index];
      final updated = entry.copyWith(
        createdAt: original.createdAt,
        updatedAt: _clock(),
        deletedAt: original.deletedAt,
      );
      final nextEntries = List<VaultEntry>.of(_entries)..[index] = updated;
      await _saveChanges(nextEntries);
    });
  }

  /// Marks an entry as deleted so it can later be restored from the trash.
  Future<void> moveToTrash(String id) {
    return _serialize(() async {
      _requireUnlocked();
      final index = _entryIndex(id);
      final now = _clock();
      final deleted = _entries[index].copyWith(deletedAt: now, updatedAt: now);
      final nextEntries = List<VaultEntry>.of(_entries)..[index] = deleted;
      await _saveChanges(nextEntries);
    });
  }

  /// Restores an entry from the trash.
  Future<void> restoreFromTrash(String id) {
    return _serialize(() async {
      _requireUnlocked();
      final index = _entryIndex(id);
      final restored = _entries[index].copyWith(
        deletedAt: null,
        updatedAt: _clock(),
      );
      final nextEntries = List<VaultEntry>.of(_entries)..[index] = restored;
      await _saveChanges(nextEntries);
    });
  }

  /// Permanently removes an entry, for example after the trash retention period.
  Future<void> deleteForever(String id) {
    return _serialize(() async {
      _requireUnlocked();
      final index = _entryIndex(id);
      final nextEntries = List<VaultEntry>.of(_entries)..removeAt(index);
      await _saveChanges(nextEntries);
    });
  }

  /// Permanently removes trash entries that have reached their 30-day limit.
  Future<int> purgeExpiredTrash({DateTime? now}) {
    return _serialize(() async {
      _requireUnlocked();
      final cutoff = (now ?? _clock()).subtract(const Duration(days: 30));
      final nextEntries = _entries
          .where(
            (entry) =>
                entry.deletedAt == null || entry.deletedAt!.isAfter(cutoff),
          )
          .toList(growable: false);
      final purgedCount = _entries.length - nextEntries.length;
      if (purgedCount > 0) {
        await _saveChanges(nextEntries);
      }
      return purgedCount;
    });
  }

  Future<void> _saveChanges(
    List<VaultEntry> nextEntries, {
    List<VaultCategory>? customCategories,
  }) async {
    final dataKey = _requireUnlocked();
    final sessionVersion = _sessionVersion;
    final nextEntrySnapshot = List<VaultEntry>.of(nextEntries);
    final nextCategorySnapshot = List<VaultCategory>.of(
      customCategories ?? _customCategories,
    );
    await _storage.save(
      entries: nextEntrySnapshot,
      customCategories: nextCategorySnapshot,
      dataKey: dataKey,
    );
    if (sessionVersion != _sessionVersion || !identical(_dataKey, dataKey)) {
      return;
    }
    _entries
      ..clear()
      ..addAll(nextEntrySnapshot);
    _customCategories
      ..clear()
      ..addAll(nextCategorySnapshot);
    notifyListeners();
  }

  SecretKey _requireUnlocked() {
    final dataKey = _dataKey;
    if (dataKey == null) {
      throw const VaultLockedException();
    }
    return dataKey;
  }

  int _entryIndex(String id) {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index == -1) {
      throw const EntryNotFoundException();
    }
    return index;
  }

  Future<T> _serialize<T>(Future<T> Function() operation) {
    final result = Completer<T>();
    _operationQueue = _operationQueue.then((_) async {
      try {
        result.complete(await operation());
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }
}

/// Indicates that an operation requires an unlocked vault.
class VaultLockedException implements Exception {
  const VaultLockedException();

  @override
  String toString() => 'The vault is locked.';
}

/// Indicates that an entry id is not present in the unlocked vault.
class EntryNotFoundException implements Exception {
  const EntryNotFoundException();

  @override
  String toString() => 'The requested entry was not found.';
}
