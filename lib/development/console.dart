import 'dart:developer';

import 'package:flutter/foundation.dart';

console(var data) {
  if (kDebugMode) {
    return print(data);
  }
}

consolelog(var data) {
  if (kDebugMode) {
    return log(data.toString());
  }
}

consoleinspect(var data) {
  if (kDebugMode) {
    return inspect(data);
  }
}
