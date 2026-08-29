class VolumeSnapshot {
  final Map<int, int> streamVolumes;
  final DateTime timestamp;

  const VolumeSnapshot({
    required this.streamVolumes,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'streamVolumes': streamVolumes.map((k, v) => MapEntry(k.toString(), v)),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory VolumeSnapshot.fromMap(Map<String, dynamic> map) {
    final rawMap = (map['streamVolumes'] as Map<String, dynamic>?) ?? {};
    final streamVolumes = <int, int>{};
    for (final entry in rawMap.entries) {
      final key = int.tryParse(entry.key);
      final value = (entry.value as num?)?.toInt();
      if (key != null && value != null) {
        streamVolumes[key] = value;
      }
    }
    return VolumeSnapshot(
      streamVolumes: streamVolumes,
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
