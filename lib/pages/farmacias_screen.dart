import 'package:app_cabecera/controller/farmacias_controller.dart';
import 'package:app_cabecera/models/farmacia_turno_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class FarmaciasScreen extends StatelessWidget {
  FarmaciasScreen({super.key});

  final FarmaciasController controller = Get.put(FarmaciasController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7F9),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.farmaciaActual.value == null) {
            return const Center(
              child: Text('No hay farmacias cargadas'),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.cargarFarmacias,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _FarmaciaActualCard(
                    farmacia: controller.farmaciaActual.value!,
                  ),
                  const SizedBox(height: 16),
                  _CalendarioCard(
                    farmacias: controller.turnos,
                  ),
                  const SizedBox(height: 16),
                  _MapaCard(
                    farmacia: controller.farmaciaActual.value!,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FarmaciaActualCard extends StatelessWidget {
  final FarmaciaTurnoModel farmacia;

  const _FarmaciaActualCard({required this.farmacia});

  @override
  Widget build(BuildContext context) {
    final fechaTexto = DateFormat("EEEE d 'de' MMMM", 'es_AR')
        .format(farmacia.fecha);

    return _CardBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Chip(text: 'HOY'),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fechaTexto.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xff009E52),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: Color(0xff009E52),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_pharmacy,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farmacia.nombre,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff07122F),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const _InfoLine(
                      icon: Icons.access_time,
                      text: 'Turno 24 hs',
                    ),
                    _InfoLine(
                      icon: Icons.location_on_outlined,
                      text: farmacia.direccion,
                    ),
                    _InfoLine(
                      icon: Icons.phone,
                      text: farmacia.telefono,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _llamar(farmacia.telefono),
                  icon: const Icon(Icons.call),
                  label: const Text('Llamar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff009E52),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _abrirMaps(farmacia),
                  icon: const Icon(Icons.map),
                  label: const Text('Cómo llegar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _llamar(String telefono) async {
    final uri = Uri.parse('tel:$telefono');
    await launchUrl(uri);
  }

  Future<void> _abrirMaps(FarmaciaTurnoModel farmacia) async {
    final query = Uri.encodeComponent(farmacia.direccion);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _CalendarioCard extends StatelessWidget {
  final List<FarmaciaTurnoModel> farmacias;

  const _CalendarioCard({required this.farmacias});

  @override
  Widget build(BuildContext context) {
    final mes = DateFormat('MMMM yyyy', 'es_AR').format(DateTime.now());

    return _CardBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Color(0xff009E52)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Próximos turnos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                mes.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xff009E52),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...farmacias.map((farmacia) {
            final esActual = farmacia.fecha.day == DateTime.now().day &&
                farmacia.fecha.month == DateTime.now().month &&
                farmacia.fecha.year == DateTime.now().year;

            return Container(
              decoration: BoxDecoration(
                color: esActual ? const Color(0xffEAF7F1) : Colors.white,
                border: const Border(
                  bottom: BorderSide(color: Color(0xffEEEEEE)),
                ),
              ),
              child: ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE', 'es_AR')
                          .format(farmacia.fecha)
                          .toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      farmacia.fecha.day.toString(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: esActual
                            ? const Color(0xff009E52)
                            : const Color(0xff07122F),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  farmacia.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(farmacia.direccion),
                trailing: esActual
                    ? const _Chip(text: 'HOY')
                    : const Icon(Icons.chevron_right),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MapaCard extends StatelessWidget {
  final FarmaciaTurnoModel farmacia;

  const _MapaCard({required this.farmacia});

  @override
  Widget build(BuildContext context) {
    return _CardBase(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Color(0xff009E52)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  farmacia.direccion,
                  style: const TextStyle(
                    color: Color(0xff009E52),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _abrirMaps(farmacia),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xffDDECEF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Icon(
                  Icons.map,
                  size: 110,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirMaps(FarmaciaTurnoModel farmacia) async {
    final query = Uri.encodeComponent(farmacia.direccion);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _CardBase extends StatelessWidget {
  final Widget child;

  const _CardBase({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;

  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xffBFF3D9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xff009E52),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Color(0xff47536D)),
          SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
