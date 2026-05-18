class GetDataModel {

  final List<Result> results;

  GetDataModel({
    required this.results,
  });

  factory GetDataModel.fromJson(List<dynamic> json) {

    return GetDataModel(
      results: json.map((e) => Result.fromJson(e)).toList(),
    );
  }
}

class Result {

  final String nombre;
  final String logo;
  final String numeroDigital;
  final String numeroAnalogico;
  final String marcaDeco;
  final String serieDeco;
  final String estante;
  final String proveedorNombre;
  final String proveedorNumero;
  final String fotoInfo;
  final String fotoDeco;


  Result({
    required this.nombre,
    required this.logo,
    required this.numeroDigital,
    required this.numeroAnalogico,
    required this.marcaDeco,
    required this.serieDeco,
    required this.estante,
    required this.proveedorNombre,
    required this.proveedorNumero,
    required this.fotoInfo,
    required this.fotoDeco,
  });

  factory Result.fromJson(Map<String, dynamic> json) {

    return Result(

      nombre: json['nombre'] ?? '',

      logo: json['logo'] ?? '',

      numeroDigital:
          json['numeroDigital']?.toString() ?? '',

      fotoInfo:
          json['fotoInfo']?.toString() ?? '',

      proveedorNumero:
          json['proveedorNumero']?.toString() ?? '',

      fotoDeco:
          json['fotoDeco']?.toString() ?? '',

      proveedorNombre:
          json['proveedorNombre']?.toString() ?? '',

      estante:
          json['estante']?.toString() ?? '',

      serieDeco:
          json['serieDeco']?.toString() ?? '',

      numeroAnalogico:
          json['numeroAnalogico']?.toString() ?? '',

      marcaDeco:
          json['marcaDeco']?.toString() ?? '',
    );
  }
}