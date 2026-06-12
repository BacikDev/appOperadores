import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {

  final String imageUrl;

  const FullScreenImage({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 255, 246),

      body: GestureDetector(

        onTap: () {
          Navigator.pop(context);
        },

        child: Center(

          child: InteractiveViewer(

            minScale: 1,
            maxScale: 5,

            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,

              placeholder: (context, url) =>
                  CircularProgressIndicator(),

              errorWidget: (_,__,___)=>
                  Icon(Icons.error,color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}