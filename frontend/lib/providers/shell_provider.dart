import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the currently selected tab in the bottom navigation.
final selectedTabProvider = StateProvider<int>((ref) => 0);
