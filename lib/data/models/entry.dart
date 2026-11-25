/// The kind of value stored in an entry field.
enum EntryFieldType { text, secret, url, numberPin, email, phone }

/// A labeled value that belongs to a vault entry.
class EntryField {
  const EntryField({
    required this.label,
    required this.value,
    required this.type,
    required this.isSecret,
  });

  final String label;
  final String value;
  final EntryFieldType type;
  final bool isSecret;

  EntryField copyWith({
    String? label,
    String? value,
    EntryFieldType? type,
    bool? isSecret,
  }) {
    return EntryField(
      label: label ?? this.label,
      value: value ?? this.value,
      type: type ?? this.type,
      isSecret: isSecret ?? this.isSecret,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'label': label,
    'value': value,
    'type': type.name,
    'isSecret': isSecret,
  };

  factory EntryField.fromJson(Object? json) {
    final map = _asJsonMap(json);
    final typeName = _requiredString(map, 'type');
    final EntryFieldType fieldType;
    try {
      fieldType = EntryFieldType.values.byName(typeName);
    } on ArgumentError {
      throw const FormatException('Invalid vault entry data.');
    }

    final isSecret = map['isSecret'];
    if (isSecret is! bool) {
      throw const FormatException('Invalid vault entry data.');
    }

    return EntryField(
      label: _requiredString(map, 'label'),
      value: _requiredString(map, 'value'),
      type: fieldType,
      isSecret: isSecret,
    );
  }
}

/// An immutable record stored in the encrypted vault.
class VaultEntry {
  VaultEntry({
    required this.id,
    required this.title,
    required this.category,
    this.person,
    required List<EntryField> fields,
    this.notes = '',
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  }) : fields = List<EntryField>.unmodifiable(fields);

  static const Object _notProvided = Object();

  final String id;
  final String title;
  final String category;
  final String? person;
  final List<EntryField> fields;
  final String notes;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  VaultEntry copyWith({
    String? id,
    String? title,
    String? category,
    Object? person = _notProvided,
    List<EntryField>? fields,
    String? notes,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _notProvided,
  }) {
    return VaultEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      person: identical(person, _notProvided) ? this.person : person as String?,
      fields: fields ?? this.fields,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, _notProvided)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'title': title,
    'category': category,
    'person': person,
    'fields': fields.map((field) => field.toJson()).toList(growable: false),
    'notes': notes,
    'isFavorite': isFavorite,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory VaultEntry.fromJson(Object? json) {
    final map = _asJsonMap(json);
    final rawFields = map['fields'];
    if (rawFields is! List<Object?>) {
      throw const FormatException('Invalid vault entry data.');
    }

    final person = map['person'];
    if (person != null && person is! String) {
      throw const FormatException('Invalid vault entry data.');
    }

    final notes = map['notes'];
    final isFavorite = map['isFavorite'];
    if (notes is! String || isFavorite is! bool) {
      throw const FormatException('Invalid vault entry data.');
    }

    return VaultEntry(
      id: _requiredString(map, 'id'),
      title: _requiredString(map, 'title'),
      category: _requiredString(map, 'category'),
      person: person as String?,
      fields: rawFields.map(EntryField.fromJson).toList(growable: false),
      notes: notes,
      isFavorite: isFavorite,
      createdAt: _requiredDateTime(map, 'createdAt'),
      updatedAt: _requiredDateTime(map, 'updatedAt'),
      deletedAt: _optionalDateTime(map, 'deletedAt'),
    );
  }
}

Map<String, Object?> _asJsonMap(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  throw const FormatException('Invalid vault entry data.');
}

String _requiredString(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is String) {
    return value;
  }
  throw const FormatException('Invalid vault entry data.');
}

DateTime _requiredDateTime(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is String) {
    final date = DateTime.tryParse(value);
    if (date != null) {
      return date;
    }
  }
  throw const FormatException('Invalid vault entry data.');
}

DateTime? _optionalDateTime(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value == null) {
    return null;
  }
  if (value is String) {
    final date = DateTime.tryParse(value);
    if (date != null) {
      return date;
    }
  }
  throw const FormatException('Invalid vault entry data.');
}
