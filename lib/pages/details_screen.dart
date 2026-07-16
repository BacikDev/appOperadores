import 'package:app_cabecera/pages/pantalla_fullscreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsScreen extends StatelessWidget {
  final Object heroTag;
  final String canalLogo;
  final String deco;
  final String serie;
  final String estante;
  final String proveedorNombre;
  final String numeroAnalogico;
  final String numeroDigital;
  final String fotoDeco;
  final String fotoInfo;
  final String proveedorNumero;

  const DetailsScreen({
    super.key,
    required this.heroTag,
    required this.canalLogo,
    required this.deco,
    required this.serie,
    required this.estante,
    required this.proveedorNombre,
    required this.numeroAnalogico,
    required this.numeroDigital,
    required this.fotoDeco,
    required this.fotoInfo,
    required this.proveedorNumero,
  });

  static const Color _background = Color(0xFF050B18);
  static const Color _card = Color(0xFF0D172A);
  static const Color _cardSecondary = Color(0xFF101A2E);
  static const Color _purple = Color(0xFF8A5CFF);
  static const Color _blue = Color(0xFF1296FF);
  static const Color _green = Color(0xFF20D489);
  static const Color _orange = Color(0xFFFFA726);
  static const Color _pink = Color(0xFFFF4F81);
  static const Color _textSecondary = Color(0xFF9BA6C7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: _background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Detalle del canal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildHeroCard(context),
                    const SizedBox(height: 16),
                    _buildInfoCard(),
                    const SizedBox(height: 16),
                    _buildImagesSection(context),
                    const SizedBox(height: 18),
                    _buildWhatsappButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: _purple.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChannelBadge(
                  label: 'Analógico',
                  value: _safe(numeroAnalogico),
                  color: _purple,
                  icon: Icons.settings_input_antenna_rounded,
                ),
                _ChannelBadge(
                  label: 'Digital',
                  value: _safe(numeroDigital),
                  color: _green,
                  icon: Icons.tv_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Hero(
            tag: heroTag,
            child: Container(
              width: double.infinity,
              height: 190,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _cardSecondary,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white10),
              ),
              child: CachedNetworkImage(
                imageUrl: canalLogo,
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(
                    color: _purple,
                    strokeWidth: 2.5,
                  ),
                ),
                errorWidget: (_, __, ___) => const _ImageError(
                  message: 'No se pudo cargar el logo',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.memory_rounded,
            title: 'INFORMACIÓN TÉCNICA',
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.router_rounded,
            label: 'Decodificador',
            value: _safe(deco),
            color: _blue,
          ),
          const _DividerLine(),
          _InfoRow(
            icon: Icons.numbers_rounded,
            label: 'Número de serie',
            value: _safe(serie),
            color: _purple,
          ),
          const _DividerLine(),
          _InfoRow(
            icon: Icons.shelves,
            label: 'Estante',
            value: _safe(estante),
            color: _orange,
          ),
          const _DividerLine(),
          _InfoRow(
            icon: Icons.business_rounded,
            label: 'Proveedor',
            value: _safe(proveedorNombre),
            color: _green,
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          icon: Icons.photo_library_rounded,
          title: 'IMÁGENES DE REFERENCIA',
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 10) / 2;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _ReferenceImageCard(
                    title: 'Deco y control',
                    imageUrl: fotoDeco,
                    accent: _blue,
                    onTap: () => _openFullscreen(context, fotoDeco),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: itemWidth,
                  child: _ReferenceImageCard(
                    title: 'Info. técnica',
                    imageUrl: fotoInfo,
                    accent: _purple,
                    onTap: () => _openFullscreen(context, fotoInfo),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildWhatsappButton(BuildContext context) {
    final numeroValido = proveedorNumero.trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: numeroValido
            ? () => _abrirWhatsapp(context)
            : null,
        style: FilledButton.styleFrom(
          backgroundColor: _green,
          disabledBackgroundColor: Colors.white10,
          foregroundColor: _background,
          disabledForegroundColor: _textSecondary,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: Icon(
          numeroValido
              ? Icons.chat_rounded
              : Icons.chat_bubble_outline_rounded,
        ),
        label: Text(
          numeroValido
              ? 'CONTACTAR PROVEEDOR POR WHATSAPP'
              : 'SIN NÚMERO DE CONTACTO',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  void _openFullscreen(
    BuildContext context,
    String imageUrl,
  ) {
    if (imageUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay una imagen disponible.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImage(
          imageUrl: imageUrl,
        ),
      ),
    );
  }

  Future<void> _abrirWhatsapp(BuildContext context) async {
    final numero = proveedorNumero
        .replaceAll(RegExp(r'[^0-9]'), '');

    if (numero.isEmpty) {
      _mostrarMensaje(
        context,
        'El proveedor no tiene un número configurado.',
      );
      return;
    }

    final mensaje = Uri.encodeComponent(
      'Hola, necesito información sobre el canal.',
    );

    final uri = Uri.parse(
      'https://wa.me/$numero?text=$mensaje',
    );

    final abierto = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!abierto && context.mounted) {
      _mostrarMensaje(
        context,
        'No se pudo abrir WhatsApp.',
      );
    }
  }

  void _mostrarMensaje(
    BuildContext context,
    String mensaje,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _cardSecondary,
      ),
    );
  }

  String _safe(String? value) {
    final texto = value?.trim() ?? '';
    return texto.isEmpty ? 'Sin información' : texto;
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 2),
        Icon(
          icon,
          color: const Color(0xFF8A5CFF),
          size: 21,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF8A5CFF),
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF9BA6C7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      color: Colors.white10,
    );
  }
}

class _ChannelBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _ChannelBadge({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 15,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReferenceImageCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final Color accent;
  final VoidCallback onTap;

  const _ReferenceImageCard({
    required this.title,
    required this.imageUrl,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D172A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.05,
                child: hasImage
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF8A5CFF),
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (_, __, ___) => const _ImageError(
                          message: 'Imagen no disponible',
                        ),
                      )
                    : const _ImageError(
                        message: 'Sin imagen',
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  11,
                  10,
                  11,
                  11,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.fullscreen_rounded,
                      color: accent,
                      size: 19,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageError extends StatelessWidget {
  final String message;

  const _ImageError({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF101A2E),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.broken_image_outlined,
            color: Color(0xFF9BA6C7),
            size: 34,
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9BA6C7),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
