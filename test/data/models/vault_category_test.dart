import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/data/models/vault_category.dart';

void main() {
  test('copies a custom category without changing its id', () {
    const category = VaultCategory(id: 'category-1', name: 'Familia');

    final renamed = category.copyWith(name: 'Casa');

    expect(renamed.id, category.id);
    expect(renamed.name, 'Casa');
    expect(VaultCategory.fromJson(renamed.toJson()).name, 'Casa');
  });
}
