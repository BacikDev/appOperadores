import 'dart:convert';

class BlueIrisConfig {
  static const String baseUrl = 'http://192.168.194.175:81';

  static const String user = 'ElLider';
  static const String password = 'ElLider.198';

  static String authQuery() {
    return 'user=${Uri.encodeComponent(user)}&pw=${Uri.encodeComponent(password)}';
  }

  static Map<String, String> authHeaders() {
    final token = base64Encode(utf8.encode('$user:$password'));

    return {
      'Authorization': 'Basic $token',
    };
  }

  static String jsonUrl() {
    return '$baseUrl/json';
  }

  static String imageUrl(String shortName) {
    final t = DateTime.now().millisecondsSinceEpoch;
    return '$baseUrl/image/${Uri.encodeComponent(shortName)}?${authQuery()}&t=$t';
  }

  static String allCamerasImageUrl() {
    final t = DateTime.now().millisecondsSinceEpoch;
    return '$baseUrl/image/%2Ball%20cameras?${authQuery()}&t=$t';
  }

  static String adminEnableUrl(String shortName) {
    return '$baseUrl/admin?camera=${Uri.encodeComponent(shortName)}&enable=1&${authQuery()}';
  }

  static String adminDisableUrl(String shortName) {
    return '$baseUrl/admin?camera=${Uri.encodeComponent(shortName)}&enable=0&${authQuery()}';
  }

  static String adminResetUrl(String shortName) {
    return '$baseUrl/admin?camera=${Uri.encodeComponent(shortName)}&reset&${authQuery()}';
  }
}