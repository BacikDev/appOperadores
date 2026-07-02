import 'package:http/http.dart' as http;

class OsdService {
  OsdService({
    required this.ip,
    this.username = 'admin',
    this.password = 'admin',
  });

  final String ip;
  final String username;
  final String password;

  String get baseUrl => 'http://$ip/product/osd/php';

  Map<String, String> get headers => {
  'Accept': '*/*',
  'Authorization': 'Basic YWRtaW46YWRtaW4=',
  'X-Requested-With': 'XMLHttpRequest',
  'Origin': 'http://$ip',
  'Referer': 'http://$ip/product/osd/osd_setting.php',
  'Content-Type': 'application/x-www-form-urlencoded',
};

  Future<void> saveText(String text) async {
    final res = await http.post(
      Uri.parse('$baseUrl/save_caption_txt.php'),
      headers: headers,
      body: {
        'txt': text,
        'op': 'SAVE',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Error al guardar texto: ${res.statusCode}');
    }
  }

  Future<void> applyCaption({
  required String base64Png,
  required int line,
  required String fontFamily,
}) async {
  final res = await http.post(
    Uri.parse('$baseUrl/set_caption_png.php'),
    headers: {
      'Authorization': 'Basic YWRtaW46YWRtaW4=',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': '*/*',
      'X-Requested-With': 'XMLHttpRequest',
      'Referer': 'http://$ip/product/osd/osd_setting.php',
      'Origin': 'http://$ip',
    },
    body: {
      'caption_img': base64Png,
      'line': line.toString(),
      'font_family': fontFamily,
    },
  );

  print('STATUS: ${res.statusCode}');
  print('BODY: ${res.body}');

  if (res.statusCode != 200) {
    throw Exception('Error al aplicar subtítulo: ${res.statusCode}');
  }
}

  Future<void> deleteCaption() async {
  final res = await http.post(
    Uri.parse('http://$ip/product/osd/php/del.php'),
    headers: headers,
    body: {},
  );

  print('URL: http://$ip/product/osd/php/del.php');
  print('HEADERS: $headers');
  print('DELETE STATUS: ${res.statusCode}');
  print('DELETE BODY: ${res.body}');
}
}