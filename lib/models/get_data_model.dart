import 'dart:convert';

GetDataModel getDataModelFromJson(String str) => GetDataModel.fromJson(json.decode(str));

String getDataModelToJson(GetDataModel data) => json.encode(data.toJson());

class GetDataModel {
    List<Result> results;

    GetDataModel({
        required this.results,
    });

    factory GetDataModel.fromJson(Map<String, dynamic> json) => GetDataModel(
        results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
    };
}

class Result {
    int id;
    String nombre;
    String numeroDigital;
    int numeroAnalogico;
    String logo;
    String? marcaDeco;
    String? serieDeco;
    String? proveedorNombre;
    String? proveedorNumero;
    String? estante;
    String? info;
    String? decoControl;

    Result({
        required this.id,
        required this.nombre,
        required this.numeroDigital,
        required this.numeroAnalogico,
        required this.logo,
        required this.marcaDeco,
        required this.serieDeco,
        required this.proveedorNombre,
        required this.proveedorNumero,
        required this.estante,
        required this.info,
        required this.decoControl,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        nombre: json["nombre"],
        numeroDigital: json["numeroDigital"],
        numeroAnalogico: json["numeroAnalogico"],
        logo: json["logo"],
        marcaDeco: json["marca_deco"],
        serieDeco: json["serie_deco"],
        proveedorNombre: json["proveedor_nombre"],
        proveedorNumero: json["proveedor_numero"],
        estante: json["estante"],
        info: json["info"],
        decoControl: json["deco_control"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "numeroDigital": numeroDigital,
        "numeroAnalogico": numeroAnalogico,
        "logo": logo,
        "marca_deco": marcaDeco,
        "serie_deco": serieDeco,
        "proveedor_nombre": proveedorNombre,
        "proveedor_numero": proveedorNumero,
        "estante": estante,
        "info": info,
        "deco_control": decoControl,
    };
}
