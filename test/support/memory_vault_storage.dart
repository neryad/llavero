import 'package:cryptography/cryptography.dart';
import 'package:llavero/data/models/entry.dart';
import 'package:llavero/data/models/vault_category.dart';
import 'package:llavero/data/vault_storage.dart';

class MemoryVaultStorage extends VaultStorage {
  List<VaultEntry> entries = <VaultEntry>[];
  List<VaultCategory> customCategories = <VaultCategory>[];

  @override
  Future<VaultContents> loadContents({required SecretKey dataKey}) async {
    return VaultContents(entries: entries, customCategories: customCategories);
  }

  @override
  Future<void> save({
    required List<VaultEntry> entries,
    List<VaultCategory> customCategories = const <VaultCategory>[],
    required SecretKey dataKey,
  }) async {
    this.entries = List<VaultEntry>.of(entries);
    this.customCategories = List<VaultCategory>.of(customCategories);
  }

  @override
  Future<void> delete() async {
    entries.clear();
    customCategories.clear();
  }
}
