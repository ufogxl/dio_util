part of 'networking.dart';

String? accessToken = "validToken";
String? refreshToken = "refreshToken";

class Header {
  static Map<String, dynamic> get unLoginHeader => {
        "Phone-Type": "android",
        "version": 1.0,
      };

  static Map<String, dynamic> get loginHeader => {
        "Phone-Type": "iOS",
        "version": 1.0,
        "Authorization": accessToken,
      };
}
