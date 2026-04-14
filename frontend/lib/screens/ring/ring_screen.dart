// MUUD Health — Ring Screen (Smart Ring Management)
// Signal layer: BLE connection, sync, firmware, battery
// Phase 2 feature — stub with connection UI flow
// © Muud Health — Armin Hoes, MD

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ring_provider.dart';
import '../../theme/app_theme.dart';

class RingScreen extends ConsumerWidget {
  const RingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ringState = ref.watch(ringProvider);

    return Scaffold(
      backgroundColor: MuudColors.white,
      appBar: AppBar(
        title: Text(
          'MUUD Ring',
          style: MuudTypography.titleMedium.copyWith(color: MuudColors.purple),
        ),
        backgroundColor: MuudColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: MuudColors.purple),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MuudSpacing.lg),
          child: ringState.isConnected
              ? _ConnectedView(ringState: ringState)
              : _DisconnectedView(ringState: ringState),
        ),
      ),
    );
  }
}

class _DisconnectedView extends ConsumerWidget {
  final RingState ringState;
  const _DisconnectedView({required this.ringState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ring illustration
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: MuudColors.purple.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.bluetooth_searching_rounded,
            size: 56,
            color: MuudColors.purple,
          ),
        ),
        const SizedBox(height: MuudSpacing.lg),

        Text(
          ringState.isScanning ? 'Scanning...' : 'Connect Your Ring',
          style: MuudTypography.heading.copyWith(color: MuudColors.purple),
        ),
        const SizedBox(height: MuudSpacing.md),
        Text(
          'Place your MUUD Ring near your phone and tap scan to pair.',
          textAlign: TextAlign.center,
          style: MuudTypography.bodyMedium.copyWith(
            color: MuudColors.bodyText,
            height: 1.6,
          ),
        ),
        const SizedBox(height: MuudSpacing.xl),

        if (ringState.isScanning)
          const CircularProgressIndicator(color: MuudColors.purple)
        else
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => ref.read(ringProvider.notifier).startScan(),
              style: ElevatedButton.styleFrom(
                backgroundColor: MuudColors.purple,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: Text(
                'Scan for Ring',
                style: MuudTypography.button.copyWith(color: MuudColors.white),
              ),
            ),
          ),

        if (ringState.errorMessage != null) ...[
          const SizedBox(height: MuudSpacing.md),
          Text(
            ringState.errorMessage!,
            style: MuudTypography.bodySmall.copyWith(color: MuudColors.error),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _ConnectedView extends ConsumerWidget {
  final RingState ringState;
  const _ConnectedView({required this.ringState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ringState.device!;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MuudSpacing.md,
              vertical: MuudSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: MuudColors.success.withValues(alpha: 0.1),
              borderRadius: MuudRadius.pillAll,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: MuudColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Connected',
                  style: MuudTypography.label.copyWith(
                    color: MuudColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: MuudSpacing.lg),

          // Device info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(MuudSpacing.lg),
            decoration: BoxDecoration(
              color: MuudColors.white,
              borderRadius: MuudRadius.lgAll,
              boxShadow: MuudShadows.card,
            ),
            child: Column(
              children: [
                _InfoRow(label: 'Model', value: device.model),
                _InfoRow(label: 'Firmware', value: device.firmwareVersion),
                _InfoRow(label: 'Battery', value: '${device.batteryLevel}%'),
                _InfoRow(
                  label: 'Last Sync',
                  value: device.hasSyncedToday ? 'Today' : 'Not yet',
                ),
              ],
            ),
          ),
          const SizedBox(height: MuudSpacing.lg),

          // Sync button
          if (ringState.isSyncing) ...[
            LinearProgressIndicator(
              value: ringState.syncProgress,
              color: MuudColors.purple,
              backgroundColor: MuudColors.divider,
            ),
            const SizedBox(height: MuudSpacing.sm),
            Text(
              'Syncing... ${(ringState.syncProgress * 100).round()}%',
              style: MuudTypography.caption,
            ),
          ] else
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => ref.read(ringProvider.notifier).syncData(),
                icon: const Icon(Icons.sync_rounded),
                label: Text(
                  'Sync Now',
                  style: MuudTypography.button.copyWith(color: MuudColors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MuudColors.purple,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
              ),
            ),

          const SizedBox(height: MuudSpacing.md),

          // Disconnect
          TextButton(
            onPressed: () => ref.read(ringProvider.notifier).disconnect(),
            child: Text(
              'Disconnect Ring',
              style: MuudTypography.label.copyWith(color: MuudColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MuudSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: MuudTypography.caption.copyWith(color: MuudColors.greyText)),
          Text(value, style: MuudTypography.label.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
