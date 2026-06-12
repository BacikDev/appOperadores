class SensorModel {
  final int id;
  final double temperatura;
  final double humedad;
  final DateTime createdAt;
  
  

  SensorModel({
    required this.id,
    required this.temperatura,
    required this.humedad,
    required this.createdAt,
  });

  factory SensorModel.fromJson(Map<String, dynamic> json) {
  return SensorModel(
    id: json['id'],
    temperatura: double.parse(json['temperatura'].toString()),
    humedad: double.parse(json['humedad'].toString()),
    createdAt: DateTime.parse(json['created_at'])
    .toUtc()
    .subtract(const Duration(hours: 3)),
  );

}
}