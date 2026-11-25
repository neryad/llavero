import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/data/entry_categories.dart';
import 'package:llavero/data/models/entry.dart';

void main() {
  test('provides stable category ids and templates for common entry types', () {
    expect(entryCategoryTemplates.map((template) => template.id), <String>[
      'wifi',
      'email',
      'streaming',
      'banking',
      'pin',
      'social',
      'devices',
      'documents',
      'other',
    ]);

    final wifi = entryCategoryTemplates.firstWhere(
      (template) => template.id == 'wifi',
    );
    expect(wifi.fields.map((field) => field.labelKey), [
      'fieldNetworkName',
      'fieldPassword',
      'fieldSecurityType',
    ]);
    expect(wifi.fields[1].type, EntryFieldType.secret);
    expect(wifi.fields[1].isSecret, isTrue);

    final streaming = entryCategoryTemplates.firstWhere(
      (template) => template.id == 'streaming',
    );
    expect(streaming.presets, containsAll(['Netflix', 'Disney+', 'Max']));
    expect(
      streaming.presets,
      containsAll(['Prime Video', 'Spotify', 'YouTube Premium']),
    );
  });
}
