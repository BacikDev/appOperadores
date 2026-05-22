class GetEventsModel {
  final List<Result>results;

  GetEventsModel({
    required this.results,
  });

  factory GetEventsModel.fromJson(List<dynamic>json){

    return GetEventsModel(
      results: json.map((e)=> Result.fromJson(e)).toList(),
    );
  }
}

class Result{

  final String fecha;
  final String hora;
  final String deporte_evento;
  final String evento;
  final String senal;

  Result({
    required this.fecha,
    required this.hora,
    required this.deporte_evento,
    required this.evento,
    required this.senal,
  });

  factory Result.fromJson(Map<String,dynamic>json){

    return Result(
      fecha: json['fecha'] ?? '', 
      hora: json['hora'] ?? '', 
      deporte_evento: json['deporte_evento'] ?? '', 
      evento: json['evento'] ?? '', 
      senal: json['senal'] ?? '',);
  }
}