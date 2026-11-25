import 'models/entry.dart';

class EntryFieldTemplate {
  const EntryFieldTemplate({
    required this.labelKey,
    required this.type,
    this.isSecret = false,
  });

  final String labelKey;
  final EntryFieldType type;
  final bool isSecret;

  EntryField createField(String Function(String key) localize) {
    return EntryField(
      label: localize(labelKey),
      value: '',
      type: type,
      isSecret: isSecret,
    );
  }
}

class EntryCategoryTemplate {
  const EntryCategoryTemplate({
    required this.id,
    required this.labelKey,
    this.fields = const <EntryFieldTemplate>[],
    this.presets = const <String>[],
  });

  final String id;
  final String labelKey;
  final List<EntryFieldTemplate> fields;
  final List<String> presets;

  List<EntryField> createFields(String Function(String key) localize) {
    return fields.map((field) => field.createField(localize)).toList();
  }
}

const List<String> streamingServicePresets = <String>[
  'Netflix',
  'Disney+',
  'Max',
  'Prime Video',
  'Spotify',
  'YouTube Premium',
];

const List<EntryCategoryTemplate>
entryCategoryTemplates = <EntryCategoryTemplate>[
  EntryCategoryTemplate(
    id: 'wifi',
    labelKey: 'categoryWifi',
    fields: <EntryFieldTemplate>[
      EntryFieldTemplate(
        labelKey: 'fieldNetworkName',
        type: EntryFieldType.text,
      ),
      EntryFieldTemplate(
        labelKey: 'fieldPassword',
        type: EntryFieldType.secret,
        isSecret: true,
      ),
      EntryFieldTemplate(
        labelKey: 'fieldSecurityType',
        type: EntryFieldType.text,
      ),
    ],
  ),
  EntryCategoryTemplate(
    id: 'email',
    labelKey: 'categoryEmail',
    fields: <EntryFieldTemplate>[
      EntryFieldTemplate(
        labelKey: 'fieldEmailAddress',
        type: EntryFieldType.email,
      ),
      EntryFieldTemplate(
        labelKey: 'fieldPassword',
        type: EntryFieldType.secret,
        isSecret: true,
      ),
      EntryFieldTemplate(
        labelKey: 'fieldRecoveryEmail',
        type: EntryFieldType.email,
      ),
      EntryFieldTemplate(
        labelKey: 'fieldRecoveryPhone',
        type: EntryFieldType.phone,
      ),
    ],
  ),
  EntryCategoryTemplate(
    id: 'streaming',
    labelKey: 'categoryStreaming',
    fields: <EntryFieldTemplate>[
      EntryFieldTemplate(labelKey: 'fieldService', type: EntryFieldType.text),
      EntryFieldTemplate(
        labelKey: 'fieldEmailOrUsername',
        type: EntryFieldType.text,
      ),
      EntryFieldTemplate(
        labelKey: 'fieldPassword',
        type: EntryFieldType.secret,
        isSecret: true,
      ),
      EntryFieldTemplate(
        labelKey: 'fieldProfilePin',
        type: EntryFieldType.numberPin,
        isSecret: true,
      ),
    ],
    presets: streamingServicePresets,
  ),
  EntryCategoryTemplate(
    id: 'banking',
    labelKey: 'categoryBanking',
    fields: <EntryFieldTemplate>[
      EntryFieldTemplate(labelKey: 'fieldBank', type: EntryFieldType.text),
      EntryFieldTemplate(
        labelKey: 'fieldEmailOrUsername',
        type: EntryFieldType.text,
      ),
      EntryFieldTemplate(
        labelKey: 'fieldPassword',
        type: EntryFieldType.secret,
        isSecret: true,
      ),
      EntryFieldTemplate(
        labelKey: 'fieldCardPin',
        type: EntryFieldType.numberPin,
        isSecret: true,
      ),
    ],
  ),
  EntryCategoryTemplate(
    id: 'pin',
    labelKey: 'categoryPin',
    fields: <EntryFieldTemplate>[
      EntryFieldTemplate(labelKey: 'fieldCodeName', type: EntryFieldType.text),
      EntryFieldTemplate(
        labelKey: 'fieldCode',
        type: EntryFieldType.numberPin,
        isSecret: true,
      ),
    ],
  ),
  EntryCategoryTemplate(
    id: 'social',
    labelKey: 'categorySocial',
    fields: <EntryFieldTemplate>[
      EntryFieldTemplate(labelKey: 'fieldService', type: EntryFieldType.text),
      EntryFieldTemplate(
        labelKey: 'fieldEmailOrUsername',
        type: EntryFieldType.text,
      ),
      EntryFieldTemplate(
        labelKey: 'fieldPassword',
        type: EntryFieldType.secret,
        isSecret: true,
      ),
    ],
  ),
  EntryCategoryTemplate(
    id: 'devices',
    labelKey: 'categoryDevices',
    fields: <EntryFieldTemplate>[
      EntryFieldTemplate(
        labelKey: 'fieldDeviceName',
        type: EntryFieldType.text,
      ),
      EntryFieldTemplate(
        labelKey: 'fieldEmailOrUsername',
        type: EntryFieldType.text,
      ),
      EntryFieldTemplate(
        labelKey: 'fieldPassword',
        type: EntryFieldType.secret,
        isSecret: true,
      ),
    ],
  ),
  EntryCategoryTemplate(
    id: 'documents',
    labelKey: 'categoryDocuments',
    fields: <EntryFieldTemplate>[
      EntryFieldTemplate(
        labelKey: 'fieldDocumentType',
        type: EntryFieldType.text,
      ),
      EntryFieldTemplate(
        labelKey: 'fieldDocumentNumber',
        type: EntryFieldType.secret,
        isSecret: true,
      ),
    ],
  ),
  EntryCategoryTemplate(id: 'other', labelKey: 'categoryOther'),
];
