import 'package:flutter/foundation.dart';

final ValueNotifier<int> sessionExpiredVersion = ValueNotifier<int>(0);

void notifySessionExpired() {
  sessionExpiredVersion.value = sessionExpiredVersion.value + 1;
}
