class BlueIrisCameraModel {
  final String nombre;
  final String shortName;

  BlueIrisCameraModel({
    required this.nombre,
    required this.shortName,
  });

  factory BlueIrisCameraModel.fromJson(Map<String, dynamic> json) {
    return BlueIrisCameraModel(
      nombre: json['optionDisplay']?.toString() ??
          json['name']?.toString() ??
          json['camera']?.toString() ??
          'Cámara',
      shortName: json['optionValue']?.toString() ??
          json['shortName']?.toString() ??
          json['camera']?.toString() ??
          '',
    );
  }
}