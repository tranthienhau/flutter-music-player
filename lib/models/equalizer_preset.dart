class EqualizerPreset {
  final String name;
  final List<double> bandValues;
  final bool isCustom;

  const EqualizerPreset({
    required this.name,
    required this.bandValues,
    this.isCustom = false,
  });

  EqualizerPreset copyWith({
    String? name,
    List<double>? bandValues,
    bool? isCustom,
  }) {
    return EqualizerPreset(
      name: name ?? this.name,
      bandValues: bandValues ?? List.from(this.bandValues),
      isCustom: isCustom ?? this.isCustom,
    );
  }

  static const List<String> bandLabels = [
    '60Hz',
    '230Hz',
    '910Hz',
    '3.6kHz',
    '14kHz',
  ];

  static const EqualizerPreset flat = EqualizerPreset(
    name: 'Flat',
    bandValues: [0, 0, 0, 0, 0],
  );

  static const EqualizerPreset pop = EqualizerPreset(
    name: 'Pop',
    bandValues: [-1, 2, 5, 2, -1],
  );

  static const EqualizerPreset rock = EqualizerPreset(
    name: 'Rock',
    bandValues: [4, 2, -1, 2, 4],
  );

  static const EqualizerPreset jazz = EqualizerPreset(
    name: 'Jazz',
    bandValues: [3, 1, -1, 1, 3],
  );

  static const EqualizerPreset classical = EqualizerPreset(
    name: 'Classical',
    bandValues: [4, 2, 0, 2, 4],
  );

  static const EqualizerPreset bassBoost = EqualizerPreset(
    name: 'Bass Boost',
    bandValues: [6, 4, 0, 0, 0],
  );

  static const EqualizerPreset trebleBoost = EqualizerPreset(
    name: 'Treble Boost',
    bandValues: [0, 0, 0, 4, 6],
  );

  static List<EqualizerPreset> get presets => [
    flat,
    pop,
    rock,
    jazz,
    classical,
    bassBoost,
    trebleBoost,
  ];

  Map<String, dynamic> toJson() {
    return {'name': name, 'bandValues': bandValues, 'isCustom': isCustom};
  }

  factory EqualizerPreset.fromJson(Map<String, dynamic> json) {
    return EqualizerPreset(
      name: json['name'] as String,
      bandValues: (json['bandValues'] as List)
          .map((v) => (v as num).toDouble())
          .toList(),
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }
}
