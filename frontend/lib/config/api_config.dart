import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:3000/api";
    } else {
      return "http://10.0.2.2:3000/api";
    }
  }

  static String get imageUrl {
    if (kIsWeb) {
      return "http://localhost:3000/uploads/";
    } else {
      return "http://10.0.2.2:3000/uploads/";
    }
  }
}