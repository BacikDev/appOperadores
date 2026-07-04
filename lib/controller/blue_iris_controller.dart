import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../config/blue_iris_config.dart';
import '../models/blue_iris_camera_model.dart';

class BlueIrisController extends GetxController {
  final isLoading = false.obs;
  final searchText = ''.obs;
  final cameras = <BlueIrisCameraModel>[].obs;

  final selectedCamera = Rxn<BlueIrisCameraModel>();

  String? session;

  @override
  void onInit() {
    super.onInit();
    cargarCamaras();
  }

  List<BlueIrisCameraModel> get camerasFiltradas {
    final query = searchText.value.toLowerCase();

    if (query.isEmpty) return cameras;

    return cameras.where((camera) {
      return camera.nombre.toLowerCase().contains(query) ||
          camera.shortName.toLowerCase().contains(query);
    }).toList();
  }

  void buscar(String value) {
    searchText.value = value;
  }

  void seleccionarCamara(BlueIrisCameraModel camera) {
    selectedCamera.value = camera;
  }

  Future<void> login() async {
    final url = Uri.parse(BlueIrisConfig.jsonUrl());

    final firstResponse = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cmd': 'login'}),
    );

    final firstData = jsonDecode(firstResponse.body);
    final currentSession = firstData['session'].toString();

    final raw =
        '${BlueIrisConfig.user}:$currentSession:${BlueIrisConfig.password}';

    final responseHash = md5.convert(utf8.encode(raw)).toString();

    final secondResponse = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cmd': 'login',
        'session': currentSession,
        'response': responseHash,
      }),
    );

    final secondData = jsonDecode(secondResponse.body);

    if (secondData['result'] != 'success') {
      throw Exception('Login falló: ${secondResponse.body}');
    }

    session = currentSession;
  }

  Future<void> cargarCamaras() async {
    try {
      isLoading.value = true;

      await login();

      final response = await http.post(
        Uri.parse(BlueIrisConfig.jsonUrl()),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cmd': 'camlist',
          'session': session,
        }),
      );

      final data = jsonDecode(response.body);
      final List lista = data['data'] ?? data['cameras'] ?? [];

      final result = lista
          .map((item) => BlueIrisCameraModel.fromJson(item))
          .where((cam) {
            final short = cam.shortName.toLowerCase();
            final name = cam.nombre.toLowerCase();

            return cam.shortName.isNotEmpty &&
                !short.contains('+all') &&
                !name.contains('all cameras');
          })
          .toList();

      cameras.assignAll(result);

      if (result.isNotEmpty && selectedCamera.value == null) {
        selectedCamera.value = result.first;
      }
    } catch (e) {
      Get.snackbar(
        'Blue Iris',
        'No se pudieron cargar las cámaras: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> habilitarCamara(BlueIrisCameraModel camera) async {
    await _ejecutarComando(
      BlueIrisConfig.adminEnableUrl(camera.shortName),
      'Cámara habilitada',
    );
  }

  Future<void> deshabilitarCamara(BlueIrisCameraModel camera) async {
    await _ejecutarComando(
      BlueIrisConfig.adminDisableUrl(camera.shortName),
      'Cámara deshabilitada',
    );
  }

  Future<void> resetearCamara(BlueIrisCameraModel camera) async {
    await _ejecutarComando(
      BlueIrisConfig.adminResetUrl(camera.shortName),
      'Cámara reseteada',
    );
  }

  Future<void> _ejecutarComando(String url, String mensajeOk) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: BlueIrisConfig.authHeaders(),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Get.snackbar('Blue Iris', mensajeOk);
        await cargarCamaras();
      } else {
        Get.snackbar('Blue Iris', 'Error ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Blue Iris', 'No se pudo ejecutar el comando');
    }
  }
}