import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DetailsScreen extends StatefulWidget {
  final heroTag;
  final canalLogo;
  final deco;
  final serie;
  final estante;
  final proveedorNombre;
  const DetailsScreen({super.key,this.heroTag, this.canalLogo, this.deco, this.estante,this.serie,this.proveedorNombre});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.green[200],
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
          numeroAnalogico(),
          numeroDigital(),
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
                  ),)
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
      )            
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
          '24.2',
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
          '24',
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

}