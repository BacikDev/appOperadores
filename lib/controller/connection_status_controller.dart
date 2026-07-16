import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConnectionStatusController extends GetxController {
  static const MethodChannel _channel =
      MethodChannel('app_cabecera/system_status');

  // Reemplazá esta URL por una URL HTTP accesible únicamente desde ZeroTier
  // si querés verificar Blue Iris de forma real. Si queda vacía, el módulo
  // Cámaras se considera disponible cuando Android detecta una VPN activa.
  static const String blueIrisProbeUrl = '';

  // URL conocida de tu servidor MediaMTX.
  static const String mediaMtxProbeUrl =
      'http://192.168.0.244:8888/';

  final RxBool comprobando = true.obs;
  final RxBool internetDisponible = false.obs;
  final RxBool supabaseDisponible = false.obs;
  final RxBool vpnActiva = false.obs;
  final RxBool camarasDisponibles = false.obs;
  final RxBool transmisionesDisponibles = false.obs;

  final RxnString ultimaAdvertencia = RxnString();
  final Rxn<DateTime> ultimaComprobacion = Rxn<DateTime>();

  bool get serviciosBasicosDisponibles =>
      internetDisponible.value && supabaseDisponible.value;

  Future<void> comprobarTodo() async {
    comprobando.value = true;

    try {
      final resultados = await Future.wait<bool>([
        _consultarEstadoNativo('hasInternet'),
        _consultarEstadoNativo('isVpnActive'),
      ]);

      internetDisponible.value = resultados[0];
      vpnActiva.value = resultados[1];

      supabaseDisponible.value = internetDisponible.value
          ? await _comprobarSupabase()
          : false;

      if (vpnActiva.value) {
        camarasDisponibles.value = blueIrisProbeUrl.trim().isEmpty
            ? true
            : await _comprobarUrl(blueIrisProbeUrl);

        transmisionesDisponibles.value =
            await _comprobarUrl(mediaMtxProbeUrl);
      } else {
        camarasDisponibles.value = false;
        transmisionesDisponibles.value = false;
      }

      ultimaAdvertencia.value = vpnActiva.value
          ? null
          : 'Las cámaras y transmisiones no están habilitadas porque '
              'la VPN ZeroTier no está activa.';
    } catch (_) {
      internetDisponible.value = false;
      supabaseDisponible.value = false;
      vpnActiva.value = false;
      camarasDisponibles.value = false;
      transmisionesDisponibles.value = false;
      ultimaAdvertencia.value =
          'No se pudo comprobar el estado de las conexiones.';
    } finally {
      ultimaComprobacion.value = DateTime.now();
      comprobando.value = false;
    }
  }

  Future<bool> _consultarEstadoNativo(String metodo) async {
    try {
      return await _channel.invokeMethod<bool>(metodo) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> _comprobarSupabase() async {
    try {
      await Supabase.instance.client
          .from('operador_turno')
          .select('id')
          .limit(1)
          .timeout(const Duration(seconds: 4));

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _comprobarUrl(String url) async {
    if (url.trim().isEmpty) return false;

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 3)
      ..idleTimeout = const Duration(seconds: 3);

    try {
      final request = await client
          .getUrl(Uri.parse(url))
          .timeout(const Duration(seconds: 4));

      final response =
          await request.close().timeout(const Duration(seconds: 4));

      await response.drain<void>();

      return response.statusCode >= 200 &&
          response.statusCode < 500;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }
}
