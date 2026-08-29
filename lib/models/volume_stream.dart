class VolumeStream {
  final int streamType;
  final String name;
  final String description;
  final String icon;
  final int currentVolume;
  final int maxVolume;
  final int minVolume;
  final int percentage;
  final bool isMuted;
  final bool isSupported;
  final String primaryColor;
  final String secondaryColor;
  final bool isExternallyChanged;

  const VolumeStream({
    required this.streamType,
    required this.name,
    required this.description,
    required this.icon,
    required this.currentVolume,
    required this.maxVolume,
    required this.minVolume,
    required this.percentage,
    required this.isMuted,
    required this.isSupported,
    required this.primaryColor,
    required this.secondaryColor,
    this.isExternallyChanged = false,
  });

  factory VolumeStream.fromMap(Map<dynamic, dynamic> map, {bool isExternal = false}) {
    return VolumeStream(
      streamType: (map['streamType'] as num?)?.toInt() ?? 3,
      name: (map['name'] as String?) ?? 'Media',
      description: (map['description'] as String?) ?? '',
      icon: (map['icon'] as String?) ?? 'music_note',
      currentVolume: (map['currentVolume'] as num?)?.toInt() ?? 0,
      maxVolume: (map['maxVolume'] as num?)?.toInt() ?? 15,
      minVolume: (map['minVolume'] as num?)?.toInt() ?? 0,
      percentage: (map['percentage'] as num?)?.toInt() ?? 0,
      isMuted: (map['isMuted'] as bool?) ?? false,
      isSupported: (map['isSupported'] as bool?) ?? true,
      primaryColor: (map['primaryColor'] as String?) ?? '#00E5FF',
      secondaryColor: (map['secondaryColor'] as String?) ?? '#4A8EFF',
      isExternallyChanged: isExternal,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'streamType': streamType,
      'name': name,
      'description': description,
      'icon': icon,
      'currentVolume': currentVolume,
      'maxVolume': maxVolume,
      'minVolume': minVolume,
      'percentage': percentage,
      'isMuted': isMuted,
      'isSupported': isSupported,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'isExternallyChanged': isExternallyChanged,
    };
  }

  VolumeStream copyWith({
    int? streamType,
    String? name,
    String? description,
    String? icon,
    int? currentVolume,
    int? maxVolume,
    int? minVolume,
    int? percentage,
    bool? isMuted,
    bool? isSupported,
    String? primaryColor,
    String? secondaryColor,
    bool? isExternallyChanged,
  }) {
    return VolumeStream(
      streamType: streamType ?? this.streamType,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      currentVolume: currentVolume ?? this.currentVolume,
      maxVolume: maxVolume ?? this.maxVolume,
      minVolume: minVolume ?? this.minVolume,
      percentage: percentage ?? this.percentage,
      isMuted: isMuted ?? this.isMuted,
      isSupported: isSupported ?? this.isSupported,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      isExternallyChanged: isExternallyChanged ?? this.isExternallyChanged,
    );
  }
}
