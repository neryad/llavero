import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../core/app_scope.dart';
import '../../core/utils/entry_search.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/entry_card.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/entry.dart';
import '../../data/models/vault_category.dart';
import '../../l10n/generated/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _selectedCategory;
  String? _selectedPerson;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controllers = AppScope.of(context);
    final strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        actions: [
          IconButton(
            key: const ValueKey('home-export-import'),
            tooltip: strings.backupCenterTitle,
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.exportImport),
            icon: const Icon(Icons.backup_outlined),
          ),
          IconButton(
            key: const ValueKey('home-settings'),
            tooltip: strings.settingsTitle,
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: strings.trash,
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.trash),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListenableBuilder(
              listenable: controllers.entries,
              builder: (context, _) {
                final activeEntries = controllers.entries.entries
                    .where((entry) => entry.deletedAt == null)
                    .toList(growable: false);
                final matchingEntries = searchEntries(
                  activeEntries,
                  _query,
                  category: _selectedCategory,
                  person: _selectedPerson,
                )..sort(_sortEntries);
                final favorites = matchingEntries
                    .where((entry) => entry.isFavorite)
                    .toList(growable: false);
                final categories = _categoriesFor(activeEntries);
                final people = _peopleFor(activeEntries);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                  children: [
                    if (controllers.settings.needsBackupReminder)
                      Card(
                        key: const ValueKey('backup-reminder-banner'),
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: ListTile(
                          leading: const Icon(Icons.backup_outlined),
                          title: Text(strings.backupReminderTitle),
                          subtitle: Text(strings.backupReminderDescription),
                          onTap: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.exportImport),
                        ),
                      ),
                    TextField(
                      key: const ValueKey('entry-search-field'),
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: strings.searchEntries,
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: strings.cancel,
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    if (activeEntries.isEmpty)
                      EmptyState(
                        key: const ValueKey('empty-vault-state'),
                        icon: Icons.key_rounded,
                        title: strings.emptyVaultTitle,
                        message: strings.emptyVaultMessage,
                        actionLabel: strings.addEntryButton,
                        onAction: _openNewEntry,
                      )
                    else ...[
                      _buildFilterSection(
                        strings: strings,
                        categories: categories,
                        people: people,
                      ),
                      if (matchingEntries.isEmpty)
                        EmptyState(
                          key: const ValueKey('empty-search-results'),
                          icon: Icons.search_off_rounded,
                          title: strings.noSearchResults,
                          message: '',
                        )
                      else ...[
                        if (favorites.isNotEmpty) ...[
                          SectionHeader(
                            title: strings.favoritesSection,
                            count: favorites.length,
                          ),
                          ...favorites.map(
                            (entry) => _buildEntryCard(entry, controllers),
                          ),
                        ],
                        SectionHeader(
                          title: strings.allEntriesSection,
                          count: matchingEntries.length,
                        ),
                        ...matchingEntries.map(
                          (entry) => _buildEntryCard(entry, controllers),
                        ),
                      ],
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('add-entry-button'),
        onPressed: _openNewEntry,
        icon: const Icon(Icons.add_rounded),
        label: Text(strings.addEntryButton),
      ),
    );
  }

  Widget _buildFilterSection({
    required AppLocalizations strings,
    required List<_CategoryOption> categories,
    required List<String> people,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: strings.filterCategories),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            CategoryChip(
              categoryId: 'other',
              label: strings.allFilter,
              selected: _selectedCategory == null,
              onSelected: (_) => setState(() => _selectedCategory = null),
            ),
            ...categories.map(
              (category) => CategoryChip(
                categoryId: category.id,
                label: category.name,
                selected: _selectedCategory == category.id,
                onSelected: (selected) => setState(
                  () => _selectedCategory = selected ? category.id : null,
                ),
              ),
            ),
          ],
        ),
        if (people.isNotEmpty) ...[
          SectionHeader(title: strings.filterPeople),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              FilterChip(
                label: Text(strings.allFilter),
                selected: _selectedPerson == null,
                onSelected: (_) => setState(() => _selectedPerson = null),
              ),
              ...people.map(
                (person) => FilterChip(
                  label: Text(person),
                  selected: _selectedPerson == person,
                  onSelected: (selected) => setState(
                    () => _selectedPerson = selected ? person : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildEntryCard(VaultEntry entry, AppControllers controllers) {
    final strings = AppLocalizations.of(context);
    return EntryCard(
      key: ValueKey('entry-${entry.id}'),
      title: entry.title,
      categoryId: entry.category,
      categoryLabel: _categoryName(
        strings,
        entry.category,
        controllers.entries.customCategories,
      ),
      person: entry.person,
      isFavorite: entry.isFavorite,
      favoriteTooltip: strings.favorite,
      removeFavoriteTooltip: strings.removeFavorite,
      onTap: () => Navigator.of(
        context,
      ).pushNamed(AppRoutes.entryDetail, arguments: entry.id),
      onFavoriteTap: () async {
        try {
          await controllers.entries.updateEntry(
            entry.copyWith(isFavorite: !entry.isFavorite),
          );
        } on Object {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(strings.saveFailed)));
          }
        }
      },
    );
  }

  List<_CategoryOption> _categoriesFor(List<VaultEntry> entries) {
    final ids = entries.map((entry) => entry.category).toSet();
    final strings = AppLocalizations.of(context);
    final controllers = AppScope.of(context);
    final custom = controllers.entries.customCategories;
    return ids.map((id) {
      final customCategory = _customCategory(custom, id);
      return _CategoryOption(
        id: id,
        name: customCategory?.name ?? _categoryName(strings, id, custom),
      );
    }).toList()..sort((first, second) => first.name.compareTo(second.name));
  }

  List<String> _peopleFor(List<VaultEntry> entries) {
    final people =
        entries
            .map((entry) => entry.person?.trim())
            .whereType<String>()
            .where((person) => person.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return people;
  }

  VaultCategory? _customCategory(List<VaultCategory> categories, String id) {
    for (final category in categories) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }

  String _categoryName(
    AppLocalizations strings,
    String id,
    List<VaultCategory> customCategories,
  ) {
    final custom = _customCategory(customCategories, id);
    if (custom != null) {
      return custom.name;
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

  int _sortEntries(VaultEntry first, VaultEntry second) {
    return second.updatedAt.compareTo(first.updatedAt);
  }

  void _openNewEntry() {
    Navigator.of(context).pushNamed(AppRoutes.entryForm);
  }
}

class _CategoryOption {
  const _CategoryOption({required this.id, required this.name});

  final String id;
  final String name;
}
