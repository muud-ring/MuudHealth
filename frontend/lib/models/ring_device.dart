// MUUD Health — Ring Device Model (Smart Ring BLE)
// © Muud Health — Armin Hoes, MD

class RingDevice {
  final String id;
  final String ownerSub;
  final String macAddress;
  final String firmwareVersion;
  final String model;
  final int batteryLevel;
  final DateTime? lastSyncAt;
  final bool isConnected;

  const RingDevice({
    required this.id,
    required this.ownerSub,
    required this.macAddress,
    this.firmwareVersion = '',
    this.model = 'MUUD Ring V1',
    this.batteryLevel = 0,
    this.lastSyncAt,
    this.isConnected = false,
  });

  factory RingDevice.fromJson(Map<String, dynamic> json) {
    return RingDevice(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      ownerSub: json['ownerSub'] as String? ?? '',
      macAddress: json['macAddress'] as String? ?? '',
      firmwareVersion: json['firmwareVersion'] as String? ?? '',
      model: json['model'] as String? ?? 'MUUD Ring V1',
      batteryLevel: json['batteryLevel'] as int? ?? 0,
      lastSyncAt: json['lastSyncAt'] != null
          ? DateTime.tryParse(json['lastSyncAt'].toString())
          : null,
      isConnected: json['isConnected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerSub': ownerSub,
    'macAddress': macAddress,
    'firmwareVersion': firmwareVersion,
    'model': model,
    'batteryLevel': batteryLevel,
    if (lastSyncAt != null) 'lastSyncAt': lastSyncAt!.toIso8601String(),
    'isConnected': isConnected,
  };

  RingDevice copyWith({
    String? id, String? ownerSub, String? macAddress, String? firmwareVersion,
    String? model, int? batteryLevel, DateTime? lastSyncAt, bool? isConnected,
  }) {
    return RingDevice(
      id: id ?? this.id, ownerSub: ownerSub ?? this.ownerSub,
      macAddress: macAddress ?? this.macAddress,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      model: model ?? this.model, batteryLevel: batteryLevel ?? this.batteryLevel,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  bool get needsCharge => batteryLevel < 20;
  bool get hasSyncedToday {
    if (lastSyncAt == null) return false;
    final now = DateTime.now();
    return lastSyncAt!.year == now.year &&
        lastSyncAt!.month == now.month &&
        lastSyncAt!.day == now.day;
  }

  @override
  String toString() => 'RingDevice($model, battery: $batteryLevel%, connected: $isConnected)';
}
