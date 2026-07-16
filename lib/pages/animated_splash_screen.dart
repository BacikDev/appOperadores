import 'dart:async';

import 'package:app_cabecera/controller/connection_status_controller.dart';
import 'package:app_cabecera/pages/bottom_navigattion_bar.dart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() =>
      _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  static const Color _background = Color(0xFF050B18);
  static const Color _card = Color(0xFF0D172A);
  static const Color _purple = Color(0xFF8A5CFF);
  static const Color _green = Color(0xFF20D489);
  static const Color _orange = Color(0xFFFFA726);
  static const Color _textSecondary = Color(0xFF9BA6C7);

  late final AnimationController _logoController;
  late final AnimationController _pulseController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _pulse;

  final ConnectionStatusController _status =
      Get.put(ConnectionStatusController(), permanent: true);

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );

    _pulse = Tween<double>(
      begin: 0.92,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _logoController.forward();
    _inicializar();
  }

  Future<void> _inicializar() async {
    final inicio = DateTime.now();

    await _status.comprobarTodo();

    final transcurrido = DateTime.now().difference(inicio);
    const minimo = Duration(milliseconds: 2600);

    if (transcurrido < minimo) {
      await Future<void>.delayed(minimo - transcurrido);
    }

    if (!mounted) return;

    Get.off(
      () => const MainNavigationScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );

    if (!_status.vpnActiva.value) {
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        if (Get.context == null) return;

        Get.snackbar(
          'VPN ZeroTier desactivada',
          'Las cámaras y transmisiones no están habilitadas. '
              'El resto de la aplicación continúa disponible.',
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 18,
          backgroundColor: _card,
          colorText: Colors.white,
          icon: const Icon(
            Icons.vpn_key_off_rounded,
            color: _orange,
          ),
          duration: const Duration(seconds: 6),
        );
      });
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
          child: Column(
            children: [
              const Spacer(),
              FadeTransition(
                opacity: _logoOpacity,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: _pulse,
                        child: Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            color: _purple.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _purple.withValues(alpha: 0.55),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _purple.withValues(alpha: 0.26),
                                blurRadius: 34,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.tv_outlined,
                            color: _purple,
                            size: 58,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'EL LÍDER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Junto a Vos',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Obx(
                () => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      _StatusRow(
                        label: 'Internet',
                        checking: _status.comprobando.value,
                        active: _status.internetDisponible.value,
                      ),
                      const SizedBox(height: 11),
                      _StatusRow(
                        label: 'Supabase',
                        checking: _status.comprobando.value,
                        active: _status.supabaseDisponible.value,
                      ),
                      const SizedBox(height: 11),
                      _StatusRow(
                        label: 'VPN ZeroTier',
                        checking: _status.comprobando.value,
                        active: _status.vpnActiva.value,
                        optional: true,
                      ),
                      const SizedBox(height: 11),
                      _StatusRow(
                        label: 'Cámaras',
                        checking: _status.comprobando.value,
                        active: _status.camarasDisponibles.value,
                        blocked: !_status.vpnActiva.value,
                      ),
                      const SizedBox(height: 11),
                      _StatusRow(
                        label: 'Transmisiones',
                        checking: _status.comprobando.value,
                        active:
                            _status.transmisionesDisponibles.value,
                        blocked: !_status.vpnActiva.value,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Inicializando panel operativo...',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              const LinearProgressIndicator(
                minHeight: 3,
                color: _purple,
                backgroundColor: Colors.white10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final bool checking;
  final bool active;
  final bool blocked;
  final bool optional;

  const _StatusRow({
    required this.label,
    required this.checking,
    required this.active,
    this.blocked = false,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF20D489);
    const orange = Color(0xFFFFA726);
    const textSecondary = Color(0xFF9BA6C7);

    late final Color color;
    late final IconData icon;
    late final String state;

    if (checking) {
      color = textSecondary;
      icon = Icons.sync_rounded;
      state = 'Comprobando';
    } else if (blocked) {
      color = orange;
      icon = Icons.lock_outline_rounded;
      state = 'VPN requerida';
    } else if (active) {
      color = green;
      icon = Icons.check_circle_rounded;
      state = 'Disponible';
    } else {
      color = optional ? orange : const Color(0xFFFF4F81);
      icon = optional
          ? Icons.info_outline_rounded
          : Icons.error_outline_rounded;
      state = optional ? 'Opcional' : 'No disponible';
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 19),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          state,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
