import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PendientesController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final RxList<Map<String, dynamic>> tareas = <Map<String, dynamic>>[].obs;
  final RxBool cargando = true.obs;
  final RxnString error = RxnString();

  RealtimeChannel? _canalRealtime;

  @override
  void onInit() {
    super.onInit();
    cargarTareas();
    _escucharCambios();
  }

  @override
  void onClose() {
    final canal = _canalRealtime;
    if (canal != null) {
      _supabase.removeChannel(canal);
    }
    super.onClose();
  }

  Future<void> cargarTareas() async {
    try {
      cargando.value = true;
      error.value = null;

      final respuesta = await _supabase
          .from('pendientes')
          .select('id, titulo, descripcion, estado, fecha, hora')
          .order('fecha', ascending: true)
          .order('hora', ascending: true);

      final lista = (respuesta as List<dynamic>)
          .map(
            (item) => _desdeSupabase(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();

      tareas.assignAll(lista);
    } catch (e, stackTrace) {
      error.value = 'No se pudieron cargar las tareas';
      debugPrint('Error cargando pendientes: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      cargando.value = false;
    }
  }

  Future<void> crearTarea({
    required String titulo,
    required String descripcion,
    required String estado,
    required DateTime fecha,
    required TimeOfDay hora,
  }) async {
    try {
      await _supabase.from('pendientes').insert({
        'titulo': titulo.trim(),
        'descripcion': descripcion.trim(),
        'estado': estado,
        'fecha': _fechaAString(fecha),
        'hora': _horaAString(hora),
      });
    } catch (e, stackTrace) {
      debugPrint('Error creando pendiente: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> actualizarTarea({
    required int id,
    required String titulo,
    required String descripcion,
    required String estado,
    required DateTime fecha,
    required TimeOfDay hora,
  }) async {
    try {
      await _supabase
          .from('pendientes')
          .update({
            'titulo': titulo.trim(),
            'descripcion': descripcion.trim(),
            'estado': estado,
            'fecha': _fechaAString(fecha),
            'hora': _horaAString(hora),
          })
          .eq('id', id);
    } catch (e, stackTrace) {
      debugPrint('Error actualizando pendiente: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> eliminarTarea(int id) async {
    try {
      await _supabase.from('pendientes').delete().eq('id', id);
      tareas.removeWhere((tarea) => tarea['id'] == id);
    } catch (e, stackTrace) {
      debugPrint('Error eliminando pendiente: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> cambiarEstado({
    required int id,
    required String nuevoEstado,
  }) async {
    try {
      await _supabase
          .from('pendientes')
          .update({'estado': nuevoEstado})
          .eq('id', id);

      final index = tareas.indexWhere((tarea) => tarea['id'] == id);
      if (index >= 0) {
        final actualizada = Map<String, dynamic>.from(tareas[index]);
        actualizada['estado'] = nuevoEstado;
        tareas[index] = actualizada;
      }
    } catch (e, stackTrace) {
      debugPrint('Error cambiando estado: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  void _escucharCambios() {
    _canalRealtime = _supabase
        .channel('pendientes-realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'pendientes',
          callback: (_) => cargarTareas(),
        )
        .subscribe();
  }

  Map<String, dynamic> _desdeSupabase(Map<String, dynamic> data) {
    return {
      'id': _entero(data['id']),
      'titulo': data['titulo']?.toString() ?? '',
      'descripcion': data['descripcion']?.toString() ?? '',
      'estado': data['estado']?.toString() ?? 'Pendiente',
      'fecha': _fechaDesdeSupabase(data['fecha']),
      'hora': _horaDesdeSupabase(data['hora']),
    };
  }

  int _entero(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  DateTime _fechaDesdeSupabase(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }

  TimeOfDay _horaDesdeSupabase(dynamic value) {
    final texto = value?.toString() ?? '00:00';
    final partes = texto.split(':');

    return TimeOfDay(
      hour: int.tryParse(partes.first) ?? 0,
      minute: partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0,
    );
  }

  String _fechaAString(DateTime fecha) {
    final year = fecha.year.toString().padLeft(4, '0');
    final month = fecha.month.toString().padLeft(2, '0');
    final day = fecha.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _horaAString(TimeOfDay hora) {
    final hour = hora.hour.toString().padLeft(2, '0');
    final minute = hora.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }
}
