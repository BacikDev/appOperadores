class GetEventsModel {
  final List<Result> results;

  GetEventsModel({required this.results});

  factory GetEventsModel.fromJson(List<dynamic> json) {
    return GetEventsModel(
      results: json.map((e) => Result.fromJson(e)).toList(),
    );
  }
}

class Result {
  final int id;
  final String fecha;
  final String hora;
  final String deporteEvento;
  final String evento;
  final String senal;
  final int deporteId;
  final List<CanalEvento> canales;

  Result({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.deporteEvento,
    required this.evento,
    required this.senal,
    required this.deporteId,
    required this.canales,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    final canalesJson = json['evento_canal'] as List? ?? [];

    return Result(
      id: json['id'] ?? 0,
      fecha: json['fecha']?.toString() ?? '',
      hora: _formatearHora(json['hora']?.toString() ?? ''),
      deporteEvento: json['deporte_evento']?.toString() ?? '',
      evento: json['evento']?.toString() ?? '',
      senal: json['senal']?.toString() ?? '',
      deporteId: json['deporte_id'] ?? 0,
      canales: canalesJson
          .map((e) => CanalEvento.fromJson(e['canal'] ?? {}))
          .where((canal) => canal.logo.isNotEmpty)
          .toList(),
    );
  }

  static String _formatearHora(String hora) {
    if (hora.isEmpty) return '';
    return hora.length >= 5 ? hora.substring(0, 5) : hora;
  }
}

class CanalEvento {
  final int id;
  final String nombre;
  final String logo;

  CanalEvento({
    required this.id,
    required this.nombre,
    required this.logo,
  });

  factory CanalEvento.fromJson(Map<String, dynamic> json) {
    return CanalEvento(
      id: json['id'] ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      logo: json['logo']?.toString() ?? '',
    );
  }
}