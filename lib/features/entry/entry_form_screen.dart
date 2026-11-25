import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/password_generator.dart';
import '../../data/entry_categories.dart';
import '../../data/models/entry.dart';
import '../../l10n/generated/app_localizations.dart';

class EntryFormScreen extends StatefulWidget {
  const EntryFormScreen({super.key, this.entryId});

  final String? entryId;

  @override
  State<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _personController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _categoryNameController = TextEditingController();
  final List<_FieldDraft> _fields = <_FieldDraft>[];
  late final AppControllers _controllers;
  String _selectedCategory = 'other';
  VaultEntry? _originalEntry;
  bool _initialized = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    _initialized = true;
    _controllers = AppScope.of(context);
    final id = widget.entryId;
    if (id == null) {
      return;
    }
    for (final entry in _controllers.entries.entries) {
      if (entry.id == id) {
        _originalEntry = entry;
        _titleController.text = entry.title;
        _personController.text = entry.person ?? '';
        _notesController.text = entry.notes;
        _selectedCategory = entry.category;
        _fields.addAll(entry.fields.map(_FieldDraft.fromEntryField));
        return;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _personController.dispose();
    _notesController.dispose();
    _categoryNameController.dispose();
    for (final field in _fields) {
      field.dispose();
    }
    super.dispose();
  }

  bool get _hasUnsavedChanges {
    final original = _originalEntry;
    if (original == null) {
      return _titleController.text.isNotEmpty ||
          _personController.text.isNotEmpty ||
          _notesController.text.isNotEmpty ||
          _selectedCategory != 'other' ||
          _fields.isNotEmpty;
    }
    if (_titleController.text != original.title ||
        _personController.text != (original.person ?? '') ||
        _notesController.text != original.notes ||
        _selectedCategory != original.category ||
        _fields.length != original.fields.length) {
      return true;
    }
    for (var index = 0; index < _fields.length; index++) {
      if (!_fields[index].matches(original.fields[index])) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final existingEntryNotFound =
        widget.entryId != null && _originalEntry == null;

    return PopScope<Object?>(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _hasUnsavedChanges) {
          unawaited(_confirmDiscard());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: strings.back,
            onPressed: _requestClose,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(
            _originalEntry == null ? strings.newEntry : strings.editEntry,
          ),
        ),
        body: existingEntryNotFound
            ? Center(child: Text(strings.startupFailed))
            : Center(
                child: ConstrainedBox(
                  key: const ValueKey('entry-form-content'),
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              key: const ValueKey('entry-title-field'),
                              controller: _titleController,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                labelText: strings.entryTitle,
                                hintText: strings.entryTitleHint,
                              ),
                              validator: (value) =>
                                  value?.trim().isNotEmpty == true
                                  ? null
                                  : strings.entryTitleRequired,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              key: const ValueKey('entry-category-field'),
                              initialValue: _selectedCategory,
                              decoration: InputDecoration(
                                labelText: strings.entryCategory,
                              ),
                              items: _categoryOptions(strings)
                                  .map(
                                    (category) => DropdownMenuItem<String>(
                                      value: category.id,
                                      child: Text(category.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (category) {
                                if (category != null) {
                                  _changeCategory(category, strings);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildPersonField(strings),
                            const SizedBox(height: 16),
                            TextFormField(
                              key: const ValueKey('entry-notes-field'),
                              controller: _notesController,
                              minLines: 2,
                              maxLines: 4,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                labelText: strings.entryNotes,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    strings.entryFields,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                ),
                                TextButton.icon(
                                  key: const ValueKey('add-field-button'),
                                  onPressed: () => setState(
                                    () => _fields.add(_FieldDraft()),
                                  ),
                                  icon: const Icon(Icons.add_rounded),
                                  label: Text(strings.addField),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            for (var index = 0; index < _fields.length; index++)
                              _buildField(index, strings),
                            if (_selectedCategory == 'streaming')
                              _buildStreamingPreset(strings),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              key: const ValueKey('create-category-button'),
                              onPressed: _createCustomCategory,
                              icon: const Icon(
                                Icons.create_new_folder_outlined,
                              ),
                              label: Text(strings.addCustomCategory),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              key: const ValueKey('save-entry-button'),
                              onPressed: _saving ? null : _save,
                              icon: _saving
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.check_rounded),
                              label: Text(strings.saveEntry),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildPersonField(AppLocalizations strings) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: _personController.text),
      optionsBuilder: (value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) {
          return const Iterable<String>.empty();
        }
        final people = _controllers.entries.entries
            .where((entry) => entry.deletedAt == null)
            .map((entry) => entry.person?.trim())
            .whereType<String>()
            .where((person) => person.isNotEmpty)
            .toSet();
        return people.where((person) => person.toLowerCase().contains(query));
      },
      onSelected: (person) => _personController.text = person,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          key: const ValueKey('entry-person-field'),
          controller: controller,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: strings.entryPerson),
          onChanged: (value) => _personController.text = value,
        );
      },
    );
  }

  Widget _buildField(int index, AppLocalizations strings) {
    final field = _fields[index];
    final isFirst = index == 0;
    final isLast = index == _fields.length - 1;

    return Card(
      key: field.key,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('field-label-$index'),
                    controller: field.labelController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(labelText: strings.fieldLabel),
                    validator: (value) => value?.trim().isNotEmpty == true
                        ? null
                        : strings.fieldLabelRequired,
                  ),
                ),
                IconButton(
                  key: ValueKey('field-move-up-$index'),
                  tooltip: strings.moveFieldUp,
                  onPressed: isFirst ? null : () => _moveField(index, -1),
                  icon: const Icon(Icons.arrow_upward_rounded),
                ),
                IconButton(
                  key: ValueKey('field-move-down-$index'),
                  tooltip: strings.moveFieldDown,
                  onPressed: isLast ? null : () => _moveField(index, 1),
                  icon: const Icon(Icons.arrow_downward_rounded),
                ),
                IconButton(
                  key: ValueKey('field-remove-$index'),
                  tooltip: strings.removeField,
                  onPressed: () => _removeField(index),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            DropdownButtonFormField<EntryFieldType>(
              key: ValueKey('field-type-$index'),
              initialValue: field.type,
              decoration: InputDecoration(labelText: strings.fieldType),
              items: EntryFieldType.values
                  .map(
                    (type) => DropdownMenuItem<EntryFieldType>(
                      value: type,
                      child: Text(_fieldTypeName(strings, type)),
                    ),
                  )
                  .toList(),
              onChanged: (type) {
                if (type != null) {
                  setState(() {
                    field.type = type;
                    field.revealTimer?.cancel();
                    field.isRevealed = false;
                    if (type == EntryFieldType.secret ||
                        type == EntryFieldType.numberPin) {
                      field.isSecret = true;
                    } else {
                      field.isSecret = false;
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: ValueKey('field-value-$index'),
              controller: field.valueController,
              obscureText: field.isSecret && !field.isRevealed,
              keyboardType: _keyboardType(field.type),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: strings.fieldValue,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (field.isSecret)
                      IconButton(
                        tooltip: strings.fieldSecretToggle,
                        onPressed: () => _toggleSecretVisibility(field),
                        icon: Icon(
                          field.isRevealed
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    if (field.isSecret)
                      IconButton(
                        tooltip: strings.passwordGenerator,
                        key: ValueKey('field-generate-$index'),
                        onPressed: () => _openPasswordGenerator(field),
                        icon: const Icon(Icons.auto_awesome_outlined),
                      ),
                  ],
                ),
              ),
            ),
            if (field.isSecret && field.valueController.text.isNotEmpty)
              _buildStrengthMeter(field.valueController.text, strings),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamingPreset(AppLocalizations strings) {
    final serviceField = _fields.isEmpty ? null : _fields.first;
    return DropdownButtonFormField<String>(
      key: const ValueKey('streaming-preset-field'),
      initialValue:
          streamingServicePresets.contains(serviceField?.valueController.text)
          ? serviceField!.valueController.text
          : null,
      decoration: InputDecoration(labelText: strings.streamingPreset),
      hint: Text(strings.chooseService),
      items: streamingServicePresets
          .map(
            (service) =>
                DropdownMenuItem<String>(value: service, child: Text(service)),
          )
          .toList(),
      onChanged: serviceField == null
          ? null
          : (service) {
              if (service != null) {
                setState(() => serviceField.valueController.text = service);
              }
            },
    );
  }

  Widget _buildStrengthMeter(String value, AppLocalizations strings) {
    final score = PasswordGenerator.strengthScore(value);
    final label = switch (score) {
      1 => strings.passwordStrengthWeak,
      2 => strings.passwordStrengthFair,
      3 => strings.passwordStrengthGood,
      _ => strings.passwordStrengthStrong,
    };
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(child: LinearProgressIndicator(value: score / 4)),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }

  List<_CategoryOption> _categoryOptions(AppLocalizations strings) {
    final options = entryCategoryTemplates
        .map(
          (template) => _CategoryOption(
            id: template.id,
            name: _categoryName(strings, template.id),
          ),
        )
        .toList();
    options.addAll(
      _controllers.entries.customCategories.map(
        (category) => _CategoryOption(id: category.id, name: category.name),
      ),
    );
    if (!options.any((category) => category.id == _selectedCategory)) {
      options.add(
        _CategoryOption(id: _selectedCategory, name: _selectedCategory),
      );
    }
    return options;
  }

  String _categoryName(AppLocalizations strings, String id) {
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

  String _fieldTypeName(AppLocalizations strings, EntryFieldType type) {
    return switch (type) {
      EntryFieldType.text => strings.fieldTypeText,
      EntryFieldType.secret => strings.fieldTypeSecret,
      EntryFieldType.url => strings.fieldTypeUrl,
      EntryFieldType.numberPin => strings.fieldTypeNumberPin,
      EntryFieldType.email => strings.fieldTypeEmail,
      EntryFieldType.phone => strings.fieldTypePhone,
    };
  }

  TextInputType _keyboardType(EntryFieldType type) {
    return switch (type) {
      EntryFieldType.numberPin => TextInputType.number,
      EntryFieldType.email => TextInputType.emailAddress,
      EntryFieldType.phone => TextInputType.phone,
      EntryFieldType.url => TextInputType.url,
      EntryFieldType.secret || EntryFieldType.text => TextInputType.text,
    };
  }

  void _changeCategory(String category, AppLocalizations strings) {
    if (_selectedCategory == category) {
      return;
    }
    setState(() {
      _selectedCategory = category;
      if (_originalEntry == null) {
        _clearFields();
        final template = entryCategoryTemplates.where(
          (item) => item.id == category,
        );
        if (template.isNotEmpty) {
          _fields.addAll(
            template.first
                .createFields((key) => _fieldLabel(strings, key))
                .map(_FieldDraft.fromEntryField),
          );
        }
      }
    });
  }

  String _fieldLabel(AppLocalizations strings, String key) {
    return switch (key) {
      'fieldNetworkName' => strings.fieldNetworkName,
      'fieldPassword' => strings.fieldPassword,
      'fieldSecurityType' => strings.fieldSecurityType,
      'fieldEmailAddress' => strings.fieldEmailAddress,
      'fieldRecoveryEmail' => strings.fieldRecoveryEmail,
      'fieldRecoveryPhone' => strings.fieldRecoveryPhone,
      'fieldService' => strings.fieldService,
      'fieldEmailOrUsername' => strings.fieldEmailOrUsername,
      'fieldProfilePin' => strings.fieldProfilePin,
      'fieldBank' => strings.fieldBank,
      'fieldCardPin' => strings.fieldCardPin,
      'fieldCodeName' => strings.fieldCodeName,
      'fieldCode' => strings.fieldCode,
      'fieldDeviceName' => strings.fieldDeviceName,
      'fieldDocumentType' => strings.fieldDocumentType,
      'fieldDocumentNumber' => strings.fieldDocumentNumber,
      _ => key,
    };
  }

  void _clearFields() {
    for (final field in _fields) {
      field.dispose();
    }
    _fields.clear();
  }

  void _moveField(int index, int offset) {
    setState(() {
      final field = _fields.removeAt(index);
      _fields.insert(index + offset, field);
    });
  }

  void _removeField(int index) {
    setState(() => _fields.removeAt(index).dispose());
  }

  Future<void> _createCustomCategory() async {
    final strings = AppLocalizations.of(context);
    _categoryNameController.clear();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(strings.addCustomCategory),
          content: TextField(
            key: const ValueKey('custom-category-name-field'),
            controller: _categoryNameController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: strings.customCategoryName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.cancel),
            ),
            FilledButton(
              key: const ValueKey('confirm-category-button'),
              onPressed: () {
                FocusScope.of(dialogContext).unfocus();
                Navigator.pop(dialogContext, _categoryNameController.text);
              },
              child: Text(strings.confirm),
            ),
          ],
        );
      },
    );
    if (name == null || !mounted) {
      return;
    }
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      _showMessage(strings.categoryNameRequired);
      return;
    }
    final alreadyExists = _controllers.entries.customCategories.any(
      (category) => category.name.toLowerCase() == normalizedName.toLowerCase(),
    );
    if (alreadyExists) {
      _showMessage(strings.categoryAlreadyExists);
      return;
    }
    try {
      final category = await _controllers.entries.addCustomCategory(name);
      if (mounted) {
        setState(() => _selectedCategory = category.id);
      }
    } on Object {
      if (mounted) {
        _showMessage(strings.saveFailed);
      }
    }
  }

  Future<void> _openPasswordGenerator(_FieldDraft field) async {
    final generated = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _PasswordGeneratorSheet(),
    );
    if (generated != null && mounted) {
      setState(() {
        field.valueController.text = generated;
        field.isRevealed = false;
      });
    }
  }

  void _toggleSecretVisibility(_FieldDraft field) {
    setState(() {
      field.revealTimer?.cancel();
      field.isRevealed = !field.isRevealed;
      if (field.isRevealed) {
        field.revealTimer = Timer(const Duration(seconds: 10), () {
          if (mounted && _fields.contains(field)) {
            setState(() => field.isRevealed = false);
          }
        });
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final strings = AppLocalizations.of(context);
    final fields = _fields
        .map(
          (field) => EntryField(
            label: field.labelController.text.trim(),
            value: field.valueController.text,
            type: field.type,
            isSecret: field.isSecret,
          ),
        )
        .toList(growable: false);
    final person = _personController.text.trim();
    setState(() => _saving = true);
    try {
      final original = _originalEntry;
      if (original == null) {
        await _controllers.entries.addEntry(
          title: _titleController.text.trim(),
          category: _selectedCategory,
          person: person.isEmpty ? null : person,
          fields: fields,
          notes: _notesController.text,
        );
      } else {
        await _controllers.entries.updateEntry(
          original.copyWith(
            title: _titleController.text.trim(),
            category: _selectedCategory,
            person: person.isEmpty ? null : person,
            fields: fields,
            notes: _notesController.text,
          ),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.entrySaved)));
        Navigator.of(context).pop();
      }
    } on Object {
      if (mounted) {
        _showMessage(strings.saveFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _requestClose() async {
    if (!_hasUnsavedChanges) {
      Navigator.of(context).maybePop();
      return;
    }
    await _confirmDiscard();
  }

  Future<void> _confirmDiscard() async {
    final strings = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.discardDialogTitle),
        content: Text(strings.discardDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(strings.discardChanges),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PasswordGeneratorSheet extends StatefulWidget {
  const _PasswordGeneratorSheet();

  @override
  State<_PasswordGeneratorSheet> createState() =>
      _PasswordGeneratorSheetState();
}

class _PasswordGeneratorSheetState extends State<_PasswordGeneratorSheet> {
  int _length = 20;
  int _wordCount = 5;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  bool _usePassphrase = false;
  String _generated = '';

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final score = PasswordGenerator.strengthScore(_generated);
    final strengthLabel = switch (score) {
      0 || 1 => strings.passwordStrengthWeak,
      2 => strings.passwordStrengthFair,
      3 => strings.passwordStrengthGood,
      _ => strings.passwordStrengthStrong,
    };

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              strings.passwordGenerator,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(strings.generatorPassphrase),
              value: _usePassphrase,
              onChanged: (value) => setState(() => _usePassphrase = value),
            ),
            if (_usePassphrase)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.generatorWordCount),
                  Slider(
                    key: const ValueKey('generator-word-count'),
                    value: _wordCount.toDouble(),
                    min: 4,
                    max: 8,
                    divisions: 4,
                    label: '$_wordCount',
                    onChanged: (value) =>
                        setState(() => _wordCount = value.round()),
                  ),
                ],
              )
            else ...[
              Text(strings.generatorLength(_length)),
              Slider(
                key: const ValueKey('generator-length'),
                value: _length.toDouble(),
                min: 8,
                max: 64,
                divisions: 56,
                label: '$_length',
                onChanged: (value) => setState(() => _length = value.round()),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(strings.generatorNumbers),
                value: _includeNumbers,
                onChanged: (value) =>
                    setState(() => _includeNumbers = value ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(strings.generatorSymbols),
                value: _includeSymbols,
                onChanged: (value) =>
                    setState(() => _includeSymbols = value ?? false),
              ),
            ],
            if (_generated.isNotEmpty) ...[
              SelectableText(
                _generated,
                style: Theme.of(context).extension<AppTypography>()!.secret,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: score / 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(strengthLabel),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey('generate-password-button'),
              onPressed: _generate,
              child: Text(strings.generate),
            ),
            if (_generated.isNotEmpty)
              TextButton(
                key: const ValueKey('use-generated-password-button'),
                onPressed: () => Navigator.pop(context, _generated),
                child: Text(strings.useGenerated),
              ),
          ],
        ),
      ),
    );
  }

  void _generate() {
    setState(() {
      _generated = _usePassphrase
          ? PasswordGenerator.generatePassphrase(wordCount: _wordCount)
          : PasswordGenerator.generate(
              length: _length,
              includeNumbers: _includeNumbers,
              includeSymbols: _includeSymbols,
            );
    });
  }
}

class _FieldDraft {
  _FieldDraft({
    String label = '',
    String value = '',
    this.type = EntryFieldType.text,
    this.isSecret = false,
  }) : labelController = TextEditingController(text: label),
       valueController = TextEditingController(text: value);

  factory _FieldDraft.fromEntryField(EntryField field) {
    return _FieldDraft(
      label: field.label,
      value: field.value,
      type: field.type,
      isSecret: field.isSecret,
    );
  }

  final Key key = UniqueKey();
  final TextEditingController labelController;
  final TextEditingController valueController;
  EntryFieldType type;
  bool isSecret;
  bool isRevealed = false;
  Timer? revealTimer;

  bool matches(EntryField field) {
    return labelController.text == field.label &&
        valueController.text == field.value &&
        type == field.type &&
        isSecret == field.isSecret;
  }

  void dispose() {
    revealTimer?.cancel();
    labelController.dispose();
    valueController.dispose();
  }
}

class _CategoryOption {
  const _CategoryOption({required this.id, required this.name});

  final String id;
  final String name;
}
