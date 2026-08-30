import 'dart:convert';

class VolumePreset {
  final String id;
  final String name;
  final int mediaPercentage;
  final int ringPercentage;
  final int alarmPercentage;
  final int callPercentage;
  final bool isBuiltIn;

  const VolumePreset({
    required this.id,
    required this.name,
    required this.mediaPercentage,
    required this.ringPercentage,
    required this.alarmPercentage,
    required this.callPercentage,
    this.isBuiltIn = false,
  });

  static const List<VolumePreset> builtInPresets = [
    VolumePreset(
      id: 'builtin_25',
      name: '25%',
      mediaPercentage: 25,
      ringPercentage: 25,
      alarmPercentage: 25,
      callPercentage: 25,
      isBuiltIn: true,
    ),
    VolumePreset(
      id: 'builtin_50',
      name: '50%',
      mediaPercentage: 50,
      ringPercentage: 50,
      alarmPercentage: 50,
      callPercentage: 50,
      isBuiltIn: true,
    ),
    VolumePreset(
      id: 'builtin_75',
      name: '75%',
      mediaPercentage: 75,
      ringPercentage: 75,
      alarmPercentage: 75,
      callPercentage: 75,
      isBuiltIn: true,
    ),
    VolumePreset(
      id: 'builtin_100',
      name: '100%',
      mediaPercentage: 100,
      ringPercentage: 100,
      alarmPercentage: 100,
      callPercentage: 100,
      isBuiltIn: true,
    ),
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mediaPercentage': mediaPercentage,
      'ringPercentage': ringPercentage,
      'alarmPercentage': alarmPercentage,
      'callPercentage': callPercentage,
      'isBuiltIn': isBuiltIn,
    };
  }

  factory VolumePreset.fromMap(Map<String, dynamic> map) {
    return VolumePreset(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      mediaPercentage: (map['mediaPercentage'] as num?)?.toInt() ?? 50,
      ringPercentage: (map['ringPercentage'] as num?)?.toInt() ?? 50,
      alarmPercentage: (map['alarmPercentage'] as num?)?.toInt() ?? 50,
      callPercentage: (map['callPercentage'] as num?)?.toInt() ?? 50,
      isBuiltIn: map['isBuiltIn'] as bool? ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory VolumePreset.fromJson(String source) =>
      VolumePreset.fromMap(jsonDecode(source) as Map<String, dynamic>);

  VolumePreset copyWith({
    String? id,
    String? name,
    int? mediaPercentage,
    int? ringPercentage,
    int? alarmPercentage,
    int? callPercentage,
    bool? isBuiltIn,
  }) {
    return VolumePreset(
      id: id ?? this.id,
      name: name ?? this.name,
      mediaPercentage: mediaPercentage ?? this.mediaPercentage,
      ringPercentage: ringPercentage ?? this.ringPercentage,
      alarmPercentage: alarmPercentage ?? this.alarmPercentage,
      callPercentage: callPercentage ?? this.callPercentage,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VolumePreset &&
        other.id == id &&
        other.name == name &&
        other.mediaPercentage == mediaPercentage &&
        other.ringPercentage == ringPercentage &&
        other.alarmPercentage == alarmPercentage &&
        other.callPercentage == callPercentage &&
        other.isBuiltIn == isBuiltIn;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      mediaPercentage,
      ringPercentage,
      alarmPercentage,
      callPercentage,
      isBuiltIn,
    );
  }
}
