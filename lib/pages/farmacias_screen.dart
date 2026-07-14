import 'package:app_cabecera/controller/farmacias_controller.dart';
import 'package:app_cabecera/models/farmacia_turno_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class FarmaciasScreen extends StatelessWidget {
  FarmaciasScreen({super.key});

  final FarmaciasController controller = Get.put(FarmaciasController());

  static const Color backgroundColor = Color(0xFF020014);
  static const Color cardColor = Color(0xFF061B2E);
  static const Color cardBorderColor = Color(0xFF173B50);
  static const Color purpleColor = Color(0xFF9259FF);
  static const Color greenColor = Color(0xFF18D98B);
  static const Color textPrimaryColor = Color(0xFFF5F4FA);
  static const Color textSecondaryColor = Color(0xFFA7A4BE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimaryColor,
            size: 21,
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Farmacias',
              style: TextStyle(
                color: textPrimaryColor,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Farmacias de turno',
              style: TextStyle(
                color: textSecondaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Obx(
            () => IconButton(
              tooltip: 'Actualizar',
              onPressed: controller.isLoading.value
                  ? null
                  : controller.cargarFarmacias,
              icon: controller.isLoading.value
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: greenColor,
                      ),
                    )
                  : const Icon(
                      Icons.refresh_rounded,
                      color: greenColor,
                    ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.farmaciaActual.value == null) {
            return const _LoadingView();
          }

          final farmaciaActual = controller.farmaciaActual.value;

          if (farmaciaActual == null) {
            return _EmptyView(
              onRefresh: controller.cargarFarmacias,
            );
          }

          return RefreshIndicator(
            color: greenColor,
            backgroundColor: cardColor,
            onRefresh: controller.cargarFarmacias,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
              children: [
                _SectionTitle(
                  title: 'FARMACIA DE TURNO',
                  icon: Icons.local_pharmacy_rounded,
                  color: greenColor,
                ),
                const SizedBox(height: 12),
                _FarmaciaActualCard(
                  farmacia: farmaciaActual,
                ),
                const SizedBox(height: 24),
                const _SectionTitle(
                  title: 'PRÓXIMOS TURNOS',
                  icon: Icons.calendar_month_rounded,
                  color: purpleColor,
                ),
                const SizedBox(height: 12),
                _CalendarioCard(
                  farmacias: controller.turnos,
                ),
                const SizedBox(height: 24),
                const _SectionTitle(
                  title: 'UBICACIÓN',
                  icon: Icons.location_on_rounded,
                  color: Color(0xFFFFA52F),
                ),
                const SizedBox(height: 12),
                _MapaCard(
                  farmacia: farmaciaActual,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _FarmaciaActualCard extends StatelessWidget {
  final FarmaciaTurnoModel farmacia;

  const _FarmaciaActualCard({
    required this.farmacia,
  });

  static const Color greenColor = Color(0xFF18D98B);
  static const Color textPrimaryColor = Color(0xFFF5F4FA);
  static const Color textSecondaryColor = Color(0xFFA7A4BE);

  @override
  Widget build(BuildContext context) {
    final fechaTexto = _capitalizar(
      DateFormat(
        "EEEE d 'de' MMMM",
        'es_AR',
      ).format(farmacia.fecha),
    );

    return _DarkCard(
      borderColor: greenColor.withOpacity(0.30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _StatusChip(
                text: 'HOY',
                color: greenColor,
                icon: Icons.bolt_rounded,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  fechaTexto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textSecondaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: greenColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: greenColor.withOpacity(0.55),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: greenColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: greenColor.withOpacity(0.40),
                  ),
                ),
                child: const Icon(
                  Icons.local_pharmacy_rounded,
                  color: greenColor,
                  size: 39,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farmacia.nombre,
                      style: const TextStyle(
                        color: textPrimaryColor,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Farmacia de turno · Atención 24 hs',
                      style: TextStyle(
                        color: greenColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 21),
          _InformationContainer(
            children: [
              const _InfoLine(
                icon: Icons.schedule_rounded,
                label: 'Horario',
                text: 'Turno 24 horas',
              ),
              const SizedBox(height: 14),
              _InfoLine(
                icon: Icons.location_on_outlined,
                label: 'Dirección',
                text: farmacia.direccion,
              ),
              const SizedBox(height: 14),
              _InfoLine(
                icon: Icons.phone_outlined,
                label: 'Teléfono',
                text: farmacia.telefono,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _PrimaryButton(
                  icon: Icons.call_rounded,
                  label: 'Llamar',
                  color: greenColor,
                  onPressed: () => _llamar(
                    context,
                    farmacia.telefono,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: _SecondaryButton(
                  icon: Icons.near_me_rounded,
                  label: 'Cómo llegar',
                  color: const Color(0xFF9259FF),
                  onPressed: () => _abrirMaps(
                    context,
                    farmacia,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarioCard extends StatelessWidget {
  final List<FarmaciaTurnoModel> farmacias;

  const _CalendarioCard({
    required this.farmacias,
  });

  static const Color purpleColor = Color(0xFF9259FF);
  static const Color greenColor = Color(0xFF18D98B);
  static const Color textPrimaryColor = Color(0xFFF5F4FA);
  static const Color textSecondaryColor = Color(0xFFA7A4BE);

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final turnosOrdenados = [...farmacias]
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    if (turnosOrdenados.isEmpty) {
      return const _DarkCard(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'No hay próximos turnos cargados',
              style: TextStyle(
                color: textSecondaryColor,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    final mes = _capitalizar(
      DateFormat('MMMM yyyy', 'es_AR').format(
        turnosOrdenados.first.fecha,
      ),
    );

    return _DarkCard(
      borderColor: purpleColor.withOpacity(0.28),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(17, 17, 17, 13),
            child: Row(
              children: [
                Container(
                  width: 37,
                  height: 37,
                  decoration: BoxDecoration(
                    color: purpleColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.date_range_rounded,
                    color: purpleColor,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    mes,
                    style: const TextStyle(
                      color: textPrimaryColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${turnosOrdenados.length} turnos',
                  style: const TextStyle(
                    color: textSecondaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.06),
          ),
          ...turnosOrdenados.asMap().entries.map((entry) {
            final index = entry.key;
            final farmacia = entry.value;

            final esHoy = _mismaFecha(farmacia.fecha, hoy);
            final esManana = _mismaFecha(
              farmacia.fecha,
              hoy.add(const Duration(days: 1)),
            );

            final ultimo = index == turnosOrdenados.length - 1;

            return _TurnoItem(
              farmacia: farmacia,
              esHoy: esHoy,
              esManana: esManana,
              mostrarSeparador: !ultimo,
            );
          }),
        ],
      ),
    );
  }
}

class _TurnoItem extends StatelessWidget {
  final FarmaciaTurnoModel farmacia;
  final bool esHoy;
  final bool esManana;
  final bool mostrarSeparador;

  const _TurnoItem({
    required this.farmacia,
    required this.esHoy,
    required this.esManana,
    required this.mostrarSeparador,
  });

  static const Color purpleColor = Color(0xFF9259FF);
  static const Color greenColor = Color(0xFF18D98B);
  static const Color textPrimaryColor = Color(0xFFF5F4FA);
  static const Color textSecondaryColor = Color(0xFFA7A4BE);

  @override
  Widget build(BuildContext context) {
    final color = esHoy ? greenColor : purpleColor;

    String etiquetaFecha;

    if (esHoy) {
      etiquetaFecha = 'HOY';
    } else if (esManana) {
      etiquetaFecha = 'MAÑANA';
    } else {
      etiquetaFecha = DateFormat(
        'EEE',
        'es_AR',
      ).format(farmacia.fecha).toUpperCase();
    }

    return InkWell(
      onTap: () => _mostrarDetalleFarmacia(
        context,
        farmacia,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: esHoy
              ? greenColor.withOpacity(0.055)
              : Colors.transparent,
          border: mostrarSeparador
              ? Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.06),
                  ),
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 14,
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 59,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withOpacity(0.30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    etiquetaFecha,
                    style: TextStyle(
                      color: color,
                      fontSize: esManana ? 9 : 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    farmacia.fecha.day.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      color: textPrimaryColor,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farmacia.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textPrimaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: textSecondaryColor,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          farmacia.direccion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}

class _MapaCard extends StatelessWidget {
  final FarmaciaTurnoModel farmacia;

  const _MapaCard({
    required this.farmacia,
  });

  static const Color orangeColor = Color(0xFFFFA52F);
  static const Color textPrimaryColor = Color(0xFFF5F4FA);
  static const Color textSecondaryColor = Color(0xFFA7A4BE);

  @override
  Widget build(BuildContext context) {
    return _DarkCard(
      borderColor: orangeColor.withOpacity(0.28),
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: () => _abrirMaps(
          context,
          farmacia,
        ),
        child: Column(
          children: [
            Container(
              height: 175,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF071E31),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: orangeColor.withOpacity(0.20),
                  ),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MapBackgroundPainter(),
                    ),
                  ),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: orangeColor.withOpacity(0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: orangeColor.withOpacity(0.45),
                      ),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: orangeColor,
                      size: 42,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(17),
              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: orangeColor.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.near_me_rounded,
                      color: orangeColor,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Abrir ubicación',
                          style: TextStyle(
                            color: textPrimaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          farmacia.direccion,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textSecondaryColor,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.open_in_new_rounded,
                    color: orangeColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionTitle({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 19,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _DarkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;

  const _DarkCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF061B2E),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: borderColor ?? const Color(0xFF173B50),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InformationContainer extends StatelessWidget {
  final List<Widget> children;

  const _InformationContainer({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF031425),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.white.withOpacity(0.055),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: const Color(0xFF18D98B).withOpacity(0.11),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF18D98B),
            size: 19,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFA7A4BE),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text.isEmpty ? 'Sin información' : text,
                style: const TextStyle(
                  color: Color(0xFFF5F4FA),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const _StatusChip({
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(0.38),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 49,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 20,
        ),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: color,
          foregroundColor: const Color(0xFF001A13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 49,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 19,
        ),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(
            color: color.withOpacity(0.65),
          ),
          backgroundColor: color.withOpacity(0.07),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF18D98B),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Cargando farmacias...',
            style: TextStyle(
              color: Color(0xFFA7A4BE),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyView({
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: _DarkCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: const Color(0xFF9259FF).withOpacity(0.13),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_pharmacy_outlined,
                  color: Color(0xFF9259FF),
                  size: 43,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'No hay farmacias cargadas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF5F4FA),
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Actualizá la información para volver a consultar los turnos.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFA7A4BE),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Actualizar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9259FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final roadPaint = Paint()
      ..color = const Color(0xFF18D98B).withOpacity(0.07)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (double x = 15; x < size.width; x += 42) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + 45, size.height),
        linePaint,
      );
    }

    for (double y = 20; y < size.height; y += 38) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y - 18),
        linePaint,
      );
    }

    final path = Path()
      ..moveTo(-20, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.20,
        size.width * 0.62,
        size.height * 0.58,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.85,
        size.width + 20,
        size.height * 0.30,
      );

    canvas.drawPath(path, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Future<void> _llamar(
  BuildContext context,
  String telefono,
) async {
  final telefonoLimpio = telefono.replaceAll(
    RegExp(r'[^0-9+]'),
    '',
  );

  if (telefonoLimpio.isEmpty) {
    _mostrarMensaje(
      context,
      'La farmacia no tiene un teléfono registrado.',
    );
    return;
  }

  final uri = Uri(
    scheme: 'tel',
    path: telefonoLimpio,
  );

  final abierto = await launchUrl(uri);

  if (!abierto && context.mounted) {
    _mostrarMensaje(
      context,
      'No se pudo abrir la aplicación de llamadas.',
    );
  }
}

Future<void> _abrirMaps(
  BuildContext context,
  FarmaciaTurnoModel farmacia,
) async {
  if (farmacia.direccion.trim().isEmpty) {
    _mostrarMensaje(
      context,
      'La farmacia no tiene una dirección registrada.',
    );
    return;
  }

  final query = Uri.encodeComponent(farmacia.direccion.trim());

  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$query',
  );

  final abierto = await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );

  if (!abierto && context.mounted) {
    _mostrarMensaje(
      context,
      'No se pudo abrir Google Maps.',
    );
  }
}

void _mostrarDetalleFarmacia(
  BuildContext context,
  FarmaciaTurnoModel farmacia,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (bottomSheetContext) {
      final fecha = _capitalizar(
        DateFormat(
          "EEEE d 'de' MMMM",
          'es_AR',
        ).format(farmacia.fecha),
      );

      return SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: const Color(0xFF061B2E),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFF9259FF).withOpacity(0.38),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: const Color(0xFF18D98B).withOpacity(0.13),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.local_pharmacy_rounded,
                  color: Color(0xFF18D98B),
                  size: 37,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                farmacia.nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFF5F4FA),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                fecha,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF9259FF),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _InformationContainer(
                children: [
                  _InfoLine(
                    icon: Icons.location_on_outlined,
                    label: 'Dirección',
                    text: farmacia.direccion,
                  ),
                  const SizedBox(height: 14),
                  _InfoLine(
                    icon: Icons.phone_outlined,
                    label: 'Teléfono',
                    text: farmacia.telefono,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _PrimaryButton(
                      icon: Icons.call_rounded,
                      label: 'Llamar',
                      color: const Color(0xFF18D98B),
                      onPressed: () {
                        Navigator.pop(bottomSheetContext);
                        _llamar(context, farmacia.telefono);
                      },
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: _SecondaryButton(
                      icon: Icons.near_me_rounded,
                      label: 'Mapa',
                      color: const Color(0xFF9259FF),
                      onPressed: () {
                        Navigator.pop(bottomSheetContext);
                        _abrirMaps(context, farmacia);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _mostrarMensaje(
  BuildContext context,
  String mensaje,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensaje),
      backgroundColor: const Color(0xFF061B2E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );
}

bool _mismaFecha(
  DateTime primera,
  DateTime segunda,
) {
  return primera.year == segunda.year &&
      primera.month == segunda.month &&
      primera.day == segunda.day;
}

String _capitalizar(String texto) {
  if (texto.isEmpty) return texto;

  return '${texto[0].toUpperCase()}${texto.substring(1)}';
}