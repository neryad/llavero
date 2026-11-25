import 'dart:math' as math;

abstract final class PasswordGenerator {
  static const String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _numbers = '0123456789';
  static const String _symbols = r'!@#$%^&*()-_=+[]{};:,.?';

  static const List<String> passphraseWords = <String>[
    'amber',
    'anchor',
    'apricot',
    'arch',
    'artist',
    'atlas',
    'bamboo',
    'beacon',
    'birch',
    'bloom',
    'breeze',
    'cactus',
    'candle',
    'canvas',
    'cedar',
    'cherry',
    'cinder',
    'citrus',
    'cloud',
    'cobalt',
    'comet',
    'coral',
    'cricket',
    'daisy',
    'delta',
    'dolphin',
    'drift',
    'eagle',
    'ember',
    'falcon',
    'fern',
    'field',
    'finch',
    'forest',
    'fossil',
    'frost',
    'garden',
    'glacier',
    'granite',
    'harbor',
    'hazel',
    'island',
    'jasmine',
    'juniper',
    'kettle',
    'lagoon',
    'lantern',
    'lemon',
    'lilac',
    'maple',
    'marble',
    'meadow',
    'meteor',
    'mint',
    'morning',
    'moss',
    'mountain',
    'nectar',
    'novel',
    'ocean',
    'olive',
    'orchid',
    'otter',
    'paddle',
    'pebble',
    'pepper',
    'petal',
    'piano',
    'planet',
    'plum',
    'pocket',
    'poppy',
    'prairie',
    'quartz',
    'rabbit',
    'raven',
    'ripple',
    'river',
    'saffron',
    'sailor',
    'sandal',
    'shadow',
    'silver',
    'sparrow',
    'spruce',
    'star',
    'sunrise',
    'thistle',
    'thunder',
    'timber',
    'tulip',
    'valley',
    'velvet',
    'violet',
    'walnut',
    'willow',
    'winter',
    'wonder',
    'yonder',
    'zephyr',
  ];

  static final math.Random _random = math.Random.secure();

  static String generate({
    required int length,
    required bool includeNumbers,
    required bool includeSymbols,
  }) {
    if (length < 8 || length > 64) {
      throw ArgumentError.value(length, 'length', 'Use between 8 and 64.');
    }

    final pools = <String>[
      _lowercase,
      _uppercase,
      if (includeNumbers) _numbers,
      if (includeSymbols) _symbols,
    ];
    if (length < pools.length) {
      throw ArgumentError.value(length, 'length', 'Length is too short.');
    }

    final allCharacters = pools.join();
    final characters = <String>[
      for (final pool in pools) pool[_random.nextInt(pool.length)],
    ];
    while (characters.length < length) {
      characters.add(allCharacters[_random.nextInt(allCharacters.length)]);
    }
    for (var index = characters.length - 1; index > 0; index--) {
      final swapIndex = _random.nextInt(index + 1);
      final current = characters[index];
      characters[index] = characters[swapIndex];
      characters[swapIndex] = current;
    }
    return characters.join();
  }

  static String generatePassphrase({required int wordCount}) {
    if (wordCount < 4 || wordCount > 8) {
      throw ArgumentError.value(wordCount, 'wordCount', 'Use 4 to 8 words.');
    }
    return List<String>.generate(
      wordCount,
      (_) => passphraseWords[_random.nextInt(passphraseWords.length)],
      growable: false,
    ).join('-');
  }

  static int strengthScore(String password) {
    if (password.isEmpty) {
      return 0;
    }
    var poolSize = 0;
    if (RegExp('[a-z]').hasMatch(password)) {
      poolSize += _lowercase.length;
    }
    if (RegExp('[A-Z]').hasMatch(password)) {
      poolSize += _uppercase.length;
    }
    if (RegExp('[0-9]').hasMatch(password)) {
      poolSize += _numbers.length;
    }
    if (RegExp('[^A-Za-z0-9]').hasMatch(password)) {
      poolSize += _symbols.length;
    }
    final entropy = password.length * (math.log(poolSize) / math.ln2);
    if (entropy < 28) {
      return 1;
    }
    if (entropy < 45) {
      return 2;
    }
    if (entropy < 65) {
      return 3;
    }
    return 4;
  }
}
