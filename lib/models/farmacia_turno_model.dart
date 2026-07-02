class FarmaciaTurnoModel {
  final DateTime fecha;
  final String nombre;
  final String direccion;
  final String telefono;
  final double? latitud;
  final double? longitud;
  final String? observaciones;

  FarmaciaTurnoModel({
    required this.fecha,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    this.latitud,
    this.longitud,
    this.observaciones,
  });

  factory FarmaciaTurnoModel.fromMap(Map<String, dynamic> map) {
    final farmacia = map['farmacias'] as Map<String, dynamic>;

    return FarmaciaTurnoModel(
      fecha: DateTime.parse(map['fecha']),
      nombre: farmacia['nombre'] ?? '',
      direccion: farmacia['direccion'] ?? '',
      telefono: farmacia['telefono'] ?? '',
      latitud: farmacia['latitud']?.toDouble(),
      longitud: farmacia['longitud']?.toDouble(),
      observaciones: farmacia['observaciones'],
    );
  }
}