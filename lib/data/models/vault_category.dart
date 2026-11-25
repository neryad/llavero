/// A user-created category stored inside the encrypted vault.
class VaultCategory {
  const VaultCategory({required this.id, required this.name});

  final String id;
  final String name;

  VaultCategory copyWith({String? id, String? name}) {
    return VaultCategory(id: id ?? this.id, name: name ?? this.name);
  }

  Map<String, Object?> toJson() => <String, Object?>{'id': id, 'name': name};

  factory VaultCategory.fromJson(Object? json) {
    if (json is! Map<String, Object?> ||
        json['id'] is! String ||
        json['name'] is! String) {
      throw const FormatException('Invalid vault category data.');
    }
    return VaultCategory(
      id: json['id']! as String,
      name: json['name']! as String,
    );
  }
}
