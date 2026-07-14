import 'package:flutter/material.dart';

class PlacasEccScreen extends StatelessWidget {
  const PlacasEccScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D172A),
        foregroundColor: Colors.white,
        title: const Text('Placas ECC'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.25,
          children: const [
            _EccCard(
              title: 'Placa Principal',
              subtitle: 'Estado operativo',
              icon: Icons.tv_rounded,
              color: Color(0xFFFFC107),
            ),
            _EccCard(
              title: 'Publicidades',
              subtitle: 'Gestión de placas',
              icon: Icons.image_rounded,
              color: Color(0xFF00D1C1),
            ),
            _EccCard(
              title: 'Comunicados',
              subtitle: 'Textos en pantalla',
              icon: Icons.campaign_rounded,
              color: Color(0xFF8A5CFF),
            ),
            _EccCard(
              title: 'Emergencias',
              subtitle: 'Avisos importantes',
              icon: Icons.warning_amber_rounded,
              color: Color(0xFFFF4F81),
            ),
          ],
        ),
      ),
    );
  }
}

class _EccCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _EccCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 54),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9BA6C7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}