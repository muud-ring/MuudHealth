// MUUD Health — Ring BLE Provider
// Manages Muud Smart Ring connection state, scanning, and data sync
// Signal layer: primary biometric input peripheral
// © Muud Health — Armin Hoes, MD

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ring_device.dart';
import '../services/ring_api.dart';

// ── Ring Connection State ────────────────────────────────────────────────

enum RingConnectionStatus {
  disconnected,
  scanning,
  connecting,
  connected,
  syncing,
  error,
}

class RingState {
  final RingConnectionStatus status;
  final RingDevice? device;
  final String? errorMessage;
  final double syncProgress; // 0.0 → 1.0
  final DateTime? lastScanAt;

  const RingState({
    this.status = RingConnectionStatus.disconnected,
    this.device,
    this.errorMessage,
    this.syncProgress = 0.0,
    this.lastScanAt,
  });

  bool get isConnected => status == RingConnectionStatus.connected;
  bool get isSyncing => status == RingConnectionStatus.syncing;
  bool get isScanning => status == RingConnectionStatus.scanning;

  RingState copyWith({
    RingConnectionStatus? status,
    RingDevice? device,
    String? errorMessage,
    double? syncProgress,
    DateTime? lastScanAt,
  }) {
    return RingState(
      status: status ?? this.status,
      device: device ?? this.device,
      errorMessage: errorMessage,
      syncProgress: syncProgress ?? this.syncProgress,
      lastScanAt: lastScanAt ?? this.lastScanAt,
    );
  }
}

// ── Ring Notifier ────────────────────────────────────────────────────────

class RingNotifier extends StateNotifier<RingState> {
  RingNotifier() : super(const RingState());

  /// Start BLE scan for nearby Muud rings.
  /// BLE integration is a Phase 2 feature — this is a stub.
  Future<void> startScan() async {
    state = state.copyWith(
      status: RingConnectionStatus.scanning,
      lastScanAt: DateTime.now(),
    );

    // TODO: Phase 2 — Integrate flutter_blue_plus or similar BLE package
    // 1. Request Bluetooth permissions
    // 2. Scan for devices advertising Muud Ring service UUID
    // 3. Filter by MUUD_RING_SERVICE_UUID
    // 4. Present discovered devices to user

    // Stub: simulate scan duration then return to disconnected
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    state = state.copyWith(status: RingConnectionStatus.disconnected);
  }

  /// Connect to a discovered ring by MAC address.
  Future<void> connectToRing(String macAddress) async {
    state = state.copyWith(status: RingConnectionStatus.connecting);

    // TODO: Phase 2 — BLE connection flow
    // 1. Connect to GATT server
    // 2. Discover services and characteristics
    // 3. Enable notifications for biometric data characteristic
    // 4. Read device info (firmware, battery, model)

    // Stub: simulate connection
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final device = RingDevice(
      id: 'stub-device-id',
      ownerSub: '', // Populated after backend registration
      macAddress: macAddress,
      firmwareVersion: '0.0.0',
      batteryLevel: 0,
      lastSyncAt: null,
      isConnected: true,
    );

    state = state.copyWith(
      status: RingConnectionStatus.connected,
      device: device,
    );
  }

  /// Register the connected ring with the backend.
  Future<void> registerRing() async {
    final device = state.device;
    if (device == null) return;

    try {
      await RingApi.register(
        macAddress: device.macAddress,
        firmwareVersion: device.firmwareVersion,
        model: device.model,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Registration failed: $e',
      );
    }
  }

  /// Sync biometric data from ring to backend.
  Future<void> syncData() async {
    if (!state.isConnected) return;

    state = state.copyWith(
      status: RingConnectionStatus.syncing,
      syncProgress: 0.0,
    );

    // TODO: Phase 2 — Read accumulated readings from ring flash storage
    // 1. Read data buffer characteristic
    // 2. Parse binary protocol into BiometricReading objects
    // 3. Batch upload via BiometricsApi.recordBatch()
    // 4. Clear ring buffer after successful upload

    // Stub: simulate sync progress
    for (int i = 1; i <= 5; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      state = state.copyWith(syncProgress: i / 5);
    }

    state = state.copyWith(
      status: RingConnectionStatus.connected,
      syncProgress: 1.0,
      device: state.device?.copyWith(lastSyncAt: DateTime.now()),
    );
  }

  /// Check for firmware updates.
  Future<bool> checkFirmwareUpdate() async {
    try {
      final result = await RingApi.checkFirmware(currentVersion: state.device?.firmwareVersion ?? '0.0.0');
      return result['updateAvailable'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Disconnect from the ring.
  void disconnect() {
    // TODO: Phase 2 — Disconnect BLE GATT connection
    state = const RingState(status: RingConnectionStatus.disconnected);
  }

  /// Clear error state.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// ── Provider ─────────────────────────────────────────────────────────────

final ringProvider = StateNotifierProvider<RingNotifier, RingState>((ref) {
  return RingNotifier();
});
