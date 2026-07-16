import 'package:app_cabecera/controller/get_data_controller.dart';
import 'package:app_cabecera/pages/details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CanalesScreen extends StatefulWidget {
  const CanalesScreen({super.key});

  @override
  State<CanalesScreen> createState() => _CanalesScreenState();
}

class _CanalesScreenState extends State<CanalesScreen> {
  static const Color _background = Color(0xFF050B18);
  static const Color _card = Color(0xFF0D172A);
  static const Color _cardSecondary = Color(0xFF101A2E);
  static const Color _purple = Color(0xFF8A5CFF);
  static const Color _blue = Color(0xFF1296FF);
  static const Color _green = Color(0xFF20D489);
  static const Color _textSecondary = Color(0xFF9BA6C7);
  static const Color _pink = Color(0xFFFF4F81);

  final GetDataController getDataController =
      Get.put(GetDataController());

  final TextEditingController searchController =
      TextEditingController();

  final RxString searchText = ''.obs;

  @override
  void initState() {
    super.initState();
    getDataController.getDataFromApi();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _abrirDetalle(BuildContext context, dynamic canal) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, animation, __) => DetailsScreen(
          heroTag: '${canal.nombre}_${canal.numeroDigital}',
          canalLogo: canal.logo?.toString() ?? '',
          deco: canal.marcaDeco?.toString() ?? '',
          serie: canal.serieDeco?.toString() ?? '',
          estante: canal.estante?.toString() ?? '',
          proveedorNumero:
              canal.proveedorNumero?.toString() ?? '',
          proveedorNombre:
              canal.proveedorNombre?.toString() ?? '',
          numeroAnalogico:
              canal.numeroAnalogico?.toString() ?? '',
          numeroDigital:
              canal.numeroDigital?.toString() ?? '',
          fotoDeco: canal.fotoDeco?.toString() ?? '',
          fotoInfo: canal.fotoInfo?.toString() ?? '',
        ),
        transitionsBuilder: (_, animation, __, child) {
          final slide = Tween<Offset>(
            begin: const Offset(0.06, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slide,
              child: child,
            ),
          );
        },
      ),
    );
  }

  Future<void> _actualizar() async {
    await getDataController.getDataFromApi();
  }

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
          'Grilla de canales',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _actualizar,
            icon: const Icon(
              Icons.refresh_rounded,
              color: _purple,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final query = searchText.value.trim().toLowerCase();

          final resultados =
              getDataController.getDataModel.value.results;

          final canales = resultados.where((canal) {
            if (query.isEmpty) return true;

            final nombre =
                canal.nombre?.toString().toLowerCase() ?? '';
            final digital =
                canal.numeroDigital?.toString().toLowerCase() ?? '';
            final analogico =
                canal.numeroAnalogico?.toString().toLowerCase() ?? '';
            final proveedor =
                canal.proveedorNombre?.toString().toLowerCase() ?? '';

            return nombre.contains(query) ||
                digital.contains(query) ||
                analogico.contains(query) ||
                proveedor.contains(query);
          }).toList();

          return RefreshIndicator(
            color: _purple,
            backgroundColor: _card,
            onRefresh: _actualizar,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                  sliver: SliverToBoxAdapter(
                    child: _SearchBox(
                      controller: searchController,
                      searchText: searchText,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                  sliver: SliverToBoxAdapter(
                    child: _ResultsHeader(
                      total: resultados.length,
                      visibles: canales.length,
                      buscando: query.isNotEmpty,
                    ),
                  ),
                ),
                if (getDataController.isLoading.value)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _LoadingState(),
                  )
                else if (canales.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      searching: query.isNotEmpty,
                      onClear: () {
                        searchController.clear();
                        searchText.value = '';
                      },
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      14,
                      0,
                      14,
                      28,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.88,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final canal = canales[index];

                          return _ChannelCard(
                            heroTag:
                                '${canal.nombre}_${canal.numeroDigital}',
                            logo: canal.logo?.toString() ?? '',
                            nombre:
                                canal.nombre?.toString() ?? 'Sin nombre',
                            digital:
                                canal.numeroDigital?.toString() ?? '',
                            analogico:
                                canal.numeroAnalogico?.toString() ?? '',
                            onTap: () =>
                                _abrirDetalle(context, canal),
                          );
                        },
                        childCount: canales.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final RxString searchText;

  const _SearchBox({
    required this.controller,
    required this.searchText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        onChanged: (value) {
          searchText.value = value;
        },
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        cursorColor: const Color(0xFF8A5CFF),
        decoration: InputDecoration(
          hintText: 'Buscar canal, número o proveedor...',
          hintStyle: const TextStyle(
            color: Color(0xFF6F7A94),
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF8A5CFF),
            size: 22,
          ),
          suffixIcon: Obx(
            () => searchText.value.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Limpiar búsqueda',
                    onPressed: () {
                      controller.clear();
                      searchText.value = '';
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF9BA6C7),
                      size: 20,
                    ),
                  ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  final int total;
  final int visibles;
  final bool buscando;

  const _ResultsHeader({
    required this.total,
    required this.visibles,
    required this.buscando,
  });

  @override
  Widget build(BuildContext context) {
    final texto = buscando
        ? '$visibles resultados de $total canales'
        : '$total canales disponibles';

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF1296FF).withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.live_tv_rounded,
            color: Color(0xFF1296FF),
            size: 19,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              color: Color(0xFF9BA6C7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Text(
          'TOCÁ PARA VER DETALLE',
          style: TextStyle(
            color: Color(0xFF8A5CFF),
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final Object heroTag;
  final String logo;
  final String nombre;
  final String digital;
  final String analogico;
  final VoidCallback onTap;

  const _ChannelCard({
    required this.heroTag,
    required this.logo,
    required this.nombre,
    required this.digital,
    required this.analogico,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const card = Color(0xFF0D172A);
    const cardSecondary = Color.fromARGB(255, 255, 255, 255);
    const purple = Color(0xFF8A5CFF);
    const green = Color(0xFF20D489);
    const textSecondary = Color(0xFF9BA6C7);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: cardSecondary,
                  padding: const EdgeInsets.all(10),
                  child: Hero(
                    tag: heroTag,
                    child: CachedNetworkImage(
                      imageUrl: logo,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(
                          color: purple,
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: textSecondary,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(9, 8, 9, 9),
                child: Column(
                  children: [
                    Text(
                      nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _MiniBadge(
                          label: digital.isEmpty ? '--' : digital,
                          color: green,
                          icon: Icons.tv_rounded,
                        ),
                        const SizedBox(width: 5),
                        _MiniBadge(
                          label: analogico.isEmpty ? '--' : analogico,
                          color: purple,
                          icon: Icons.settings_input_antenna_rounded,
                        ),
                      ],
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

class _MiniBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _MiniBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: 0.30),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 10,
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF8A5CFF),
            strokeWidth: 3,
          ),
          SizedBox(height: 14),
          Text(
            'Cargando canales...',
            style: TextStyle(
              color: Color(0xFF9BA6C7),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool searching;
  final VoidCallback onClear;

  const _EmptyState({
    required this.searching,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0D172A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: const Color(0xFF8A5CFF)
                    .withValues(alpha: 0.13),
                shape: BoxShape.circle,
              ),
              child: Icon(
                searching
                    ? Icons.search_off_rounded
                    : Icons.live_tv_rounded,
                color: const Color(0xFF8A5CFF),
                size: 34,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              searching
                  ? 'No encontramos coincidencias'
                  : 'No hay canales disponibles',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              searching
                  ? 'Probá buscando por otro nombre o número.'
                  : 'Actualizá la pantalla para volver a consultar.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF9BA6C7),
                fontSize: 12,
              ),
            ),
            if (searching) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onClear,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8A5CFF),
                  side: const BorderSide(
                    color: Color(0xFF8A5CFF),
                  ),
                ),
                icon: const Icon(Icons.close_rounded),
                label: const Text('Limpiar búsqueda'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
