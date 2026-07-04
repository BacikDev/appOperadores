import 'dart:async';

import 'package:flutter/material.dart';

import '../config/blue_iris_config.dart';
import '../models/blue_iris_camera_model.dart';

class BlueIrisFullscreen extends StatefulWidget {
  final BlueIrisCameraModel camera;

  const BlueIrisFullscreen({
    super.key,
    required this.camera,
  });

  @override
  State<BlueIrisFullscreen> createState() => _BlueIrisFullscreenState();
}

class _BlueIrisFullscreenState extends State<BlueIrisFullscreen> {
  Timer? _timer;
  late String _url;

  @override
  void initState() {
    super.initState();

    _url = BlueIrisConfig.imageUrl(widget.camera.shortName);

    _timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) {
        if (!mounted) return;

        setState(() {
          _url = BlueIrisConfig.imageUrl(widget.camera.shortName);
        });
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _recargar() {
    setState(() {
      _url = BlueIrisConfig.imageUrl(widget.camera.shortName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.camera.nombre),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Image.network(
            _url,
            headers: BlueIrisConfig.authHeaders(),
            fit: BoxFit.contain,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.videocam_off,
                color: Colors.white,
                size: 80,
              );
            },
          ),
        ),
      ),
    );
  }
}