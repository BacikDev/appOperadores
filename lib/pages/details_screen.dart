import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsScreen extends StatefulWidget {
  final heroTag;
  final canalLogo;
  final deco;
  final serie;
  final estante;
  final proveedorNombre;
  final numeroAnalogico;
  final numeroDigital;
  final fotoDeco;
  final fotoInfo;
  const DetailsScreen({super.key,this.heroTag, this.canalLogo, this.deco, this.estante,this.serie,this.proveedorNombre, this.numeroAnalogico,this.numeroDigital, this.fotoDeco, this.fotoInfo});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Stack(
        alignment: Alignment.center,
        children: [
        Positioned(
          top: 30,
          child: Hero(tag: widget.heroTag,
          child: CachedNetworkImage(imageUrl: widget.canalLogo,
          height: 260,
          fit: BoxFit.cover,
          placeholder: (context, url)=> Center(
          child: CircularProgressIndicator(),)))
          ),
          flechaAtras(),
          numeroDigital(),
          numeroAnalogico(),
          Positioned(
            bottom: 0,
            child: Container(
              width: width,
              height: height * 0.6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))
              ),
              child: Padding(padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  //DECODIFICADOR
                  Padding(padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        width: width * 0.4,
                        child: Text('Decodificador:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),),
                      ),
                      Container(
                        child: Text(widget.deco,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),),
                      )
                    ],
                  ),),
                  //NUMERO DE SERIE
                  Padding(padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        width: width * 0.4,
                        child: Text('Serie: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),),
                      ),
                      Container(
                        child: Text(widget.serie,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),),
                      )
                    ],
                  ),),
                  //NUMERO DE ESTANTE
                  Padding(padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        width: width * 0.4,
                        child: Text('Estante:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),),
                      ),
                      Container(
                        child: Text(widget.estante,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),),
                      )
                    ],
                  ),),
                  //PROVEEDOR
                  Padding(padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        width: width * 0.4,
                        child: Text('Proveedor:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),),
                      ),
                      Container(
                        child: Text(widget.proveedorNombre,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),),
                      )
                    ],
                  ),),
                  Padding(padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        width: width * 0.5,
                        child: Text('Deco y Control:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),),
                      ),
                      Container(
                        child: Text('Inf. Técnica',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),),
                      )
                    ],
                  ),),
                  //IMAGEN DECO CONTROL
                  Padding(padding: const EdgeInsets.all(1),
                  child: Row(
                    children: [
                      SizedBox(
                        width: width * 0.45,
                        child: CachedNetworkImage(imageUrl: widget.fotoDeco,
                        fit: BoxFit.cover,
                        placeholder: (context, url)=> Center(
                        child: CircularProgressIndicator(),)))
                        ,
                        //IMAGEN INFO TECNICA
                      SizedBox(
                        width: width * 0.45,
                        child: CachedNetworkImage(imageUrl: widget.fotoInfo,  
                        fit: BoxFit.cover,
                        placeholder: (context, url)=> Center(
                        child: CircularProgressIndicator(),)))
                        ,
                    ],
                    //BOTON WHATSAPP
                  ),),ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),  
                        onPressed: abrirWhatsapp, 
                        icon: Icon(Icons.message, color: Colors.white,),
                        label: Text('Whatsapp', style: TextStyle(color: Colors.white),
                    )
                  )
                ],
                
              ),),
            ))
        ],
      ),
    );
  }

  Widget flechaAtras(){
    return Positioned(
      top: 40,
      left: 5,
      child: IconButton(
        icon: Icon(Icons.arrow_back), 
        color: Colors.green[700],
        iconSize: 35,
        onPressed: (){
          Navigator.pop(context);
        },
      ),
                  
    );
  }

    Widget numeroDigital(){
    return Positioned(
      top: 50, 
      right: 30,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.green
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5, top: 1, bottom: 1),
          child: Text(
          widget.numeroDigital,
          style: TextStyle(
            color: Colors.white,
            shadows: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10,
                offset: Offset(2.0,2.0),
              ),
            ],
            fontWeight: FontWeight.bold,
            fontSize: 18,
        
      ),))));
  }

  Widget numeroAnalogico(){
    return Positioned(
      top: 50, 
      right: 80,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.purple
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5, top: 1, bottom: 1),
          child: Text(
          widget.numeroAnalogico,
          style: TextStyle(
            color: Colors.white,
            shadows: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10,
                offset: Offset(2.0,2.0),
              ),
            ],
            fontWeight: FontWeight.bold,
            fontSize: 18,   
          ),)
        )
      )
    );
  }

Future<void> abrirWhatsapp() async{
  final numero = '5493705406848';
  final mensaje = 'Hola, necesito información';

  final uri = Uri.parse(
    'whatsapp://send?phone=$numero&text=$mensaje'
  );

  try{
    await launchUrl(uri,
    mode: LaunchMode.externalApplication);
  }catch(e){
    print('ERROR WHATSAPP: $e');
  }
} 
}
