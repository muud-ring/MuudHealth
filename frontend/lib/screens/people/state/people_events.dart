import 'package:flutter/foundation.dart';

class PeopleEvents {
  static final ValueNotifier<int> reload = ValueNotifier<int>(0);

  static void notifyReload() {
    reload.value++;
  }
}
