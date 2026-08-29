class NotificationSettings {
  final bool showMedia;
  final bool showRing;
  final bool showAlarm;
  final bool showNotification;
  final bool showCall;
  final bool showPercentage;
  final bool showMute;

  const NotificationSettings({
    this.showMedia = true,
    this.showRing = true,
    this.showAlarm = true,
    this.showNotification = true,
    this.showCall = false,
    this.showPercentage = true,
    this.showMute = true,
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      showMedia: map['showMedia'] ?? true,
      showRing: map['showRing'] ?? true,
      showAlarm: map['showAlarm'] ?? true,
      showNotification: map['showNotification'] ?? true,
      showCall: map['showCall'] ?? false,
      showPercentage: map['showPercentage'] ?? true,
      showMute: map['showMute'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'showMedia': showMedia,
      'showRing': showRing,
      'showAlarm': showAlarm,
      'showNotification': showNotification,
      'showCall': showCall,
      'showPercentage': showPercentage,
      'showMute': showMute,
    };
  }

  NotificationSettings copyWith({
    bool? showMedia,
    bool? showRing,
    bool? showAlarm,
    bool? showNotification,
    bool? showCall,
    bool? showPercentage,
    bool? showMute,
  }) {
    return NotificationSettings(
      showMedia: showMedia ?? this.showMedia,
      showRing: showRing ?? this.showRing,
      showAlarm: showAlarm ?? this.showAlarm,
      showNotification: showNotification ?? this.showNotification,
      showCall: showCall ?? this.showCall,
      showPercentage: showPercentage ?? this.showPercentage,
      showMute: showMute ?? this.showMute,
    );
  }
}
