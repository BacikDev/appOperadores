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
  final getDataController = Get.put(GetDataController());

  final TextEditingController searchController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canales = getDataController.getDataModel.value.results.where((canal) {
        final query = searchText.value.toLowerCase();

        final nombre = canal.nombre.toString().toLowerCase();
        final digital = canal.numeroDigital.toString().toLowerCase();
        final analogico = canal.numeroAnalogico.toString().toLowerCase();

        return nombre.contains(query) ||
            digital.contains(query) ||
            analogico.contains(query);
      }).toList();

      return Scaffold(
        backgroundColor: Colors.green[50],
        appBar: AppBar(
          backgroundColor: Colors.green[50],
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'El Líder Junto a vos',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: getDataController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                        left: 16,
                        right: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.live_tv,
                            color: Colors.deepPurple,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Grilla de Canales',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 38,
                              child: TextField(
                                controller: searchController,
                                onChanged: (value) {
                                  searchText.value = value;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Buscar...',
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    size: 18,
                                  ),
                                  suffixIcon: searchText.value.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            searchController.clear();
                                            searchText.value = '';
                                          },
                                        )
                                      : null,
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 0,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: canales.isEmpty
                          ? const Center(
                              child: Text(
                                'No se encontraron canales',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: canales.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1.5,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemBuilder: (context, index) {
                                  final canal = canales[index];

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(25),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DetailsScreen(
                                            heroTag:
                                                '${canal.nombre}_${canal.numeroDigital}',
                                            canalLogo: canal.logo,
                                            deco: canal.marcaDeco,
                                            serie: canal.serieDeco,
                                            estante: canal.estante,
                                            proveedorNumero:
                                                canal.proveedorNumero,
                                            proveedorNombre:
                                                canal.proveedorNombre,
                                            numeroAnalogico:
                                                canal.numeroAnalogico,
                                            numeroDigital: canal.numeroDigital,
                                            fotoDeco: canal.fotoDeco,
                                            fotoInfo: canal.fotoInfo,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: Colors.green,
                                      ),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            child: Hero(
                                              tag:
                                                  '${canal.nombre}_${canal.numeroDigital}',
                                              child: CachedNetworkImage(
                                                imageUrl: canal.logo ?? '',
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          Positioned(
                                            bottom: 5,
                                            left: 10,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 7,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.green,
                                              ),
                                              child: Text(
                                                canal.numeroDigital.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  shadows: [
                                                    BoxShadow(
                                                      color: Colors.black,
                                                      blurRadius: 10,
                                                      offset: Offset(2, 2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),

                                          Positioned(
                                            bottom: 5,
                                            left: 55,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 7,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.purple,
                                              ),
                                              child: Text(
                                                canal.numeroAnalogico
                                                    .toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  shadows: [
                                                    BoxShadow(
                                                      color: Colors.black,
                                                      blurRadius: 10,
                                                      offset: Offset(2, 2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}