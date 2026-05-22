class GetCarruselModel {
  final List<Result>results;

  GetCarruselModel({
    required this.results,
  });

  factory GetCarruselModel.fromJson(List<dynamic> json){

    return GetCarruselModel(
      results: json.map((e)=> Result.fromJson(e)).toList(),
    );
  }
}

class Result{

  final String fondo;
  final String name;
  final int id;


  Result({
    required this.fondo,
    required this.name,
    required this.id,
  });

  factory Result.fromJson(Map<String,dynamic>json){

    return Result(
      fondo: json['fondo'] ?? '', 
      name: json['name'] ?? '', 
      id: json['id'] ?? '', 
    );
  }
}