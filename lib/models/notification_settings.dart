class NotificationSettings {
  final bool showMedia;
  final bool showRing;
  final bool showAlarm;
  final bool showCall;
  final bool showPercentage;
  final bool showMute;

  const NotificationSettings({
    this.showMedia = true,
    this.showRing = true,
    this.showAlarm = true,
    this.showCall = true,
    this.showPercentage = true,
    this.showMute = true,
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      showMedia: map['showMedia'] ?? true,
      showRing: map['showRing'] ?? true,
      showAlarm: map['showAlarm'] ?? true,
      showCall: map['showCall'] ?? true,
      showPercentage: map['showPercentage'] ?? true,
      showMute: map['showMute'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'showMedia': showMedia,
      'showRing': showRing,
      'showAlarm': showAlarm,
      'showCall': showCall,
      'showPercentage': showPercentage,
      'showMute': showMute,
    };
  }

  NotificationSettings copyWith({
    bool? showMedia,
    bool? showRing,
    bool? showAlarm,
    bool? showCall,
    bool? showPercentage,
    bool? showMute,
  }) {
    return NotificationSettings(
      showMedia: showMedia ?? this.showMedia,
      showRing: showRing ?? this.showRing,
      showAlarm: showAlarm ?? this.showAlarm,
      showCall: showCall ?? this.showCall,
      showPercentage: showPercentage ?? this.showPercentage,
      showMute: showMute ?? this.showMute,
    );
  }
}
