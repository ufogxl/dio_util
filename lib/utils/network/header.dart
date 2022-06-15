part of 'networking.dart';

class Header {
  static Map<String, dynamic> get unLoginHeader => {
        "Phone-Type": "android",
        "version": 1.0,
      };

  static Map<String, dynamic> get loginHeader => {
        "Phone-Type": "iOS",
        "version": 1.0,
        "Authorization": "jwt Token",
      };
}
