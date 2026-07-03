import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PendientesScreen extends StatefulWidget {
  const PendientesScreen({super.key});

  @override
  State<PendientesScreen> createState() => _PendientesScreenState();
}

class _PendientesScreenState extends State<PendientesScreen> {
  final searchController = TextEditingController();

  String filtroEstado = 'Todas';
  String filtroArea = 'Todas';

  final estados = ['Pendiente', 'En progreso', 'Urgente', 'Completada'];
  final prioridades = ['Baja', 'Media', 'Alta', 'Crítica'];

  final responsables = [
    'Operador 1',
    'Operador 2',
    'Técnico',
    'Producción',
    'Mantenimiento',
  ];

  final areas = [
    'Cabecera',
    'Subtitulado',
    'Streaming',
    'Reclamos',
    'Cámaras',
    'Mantenimiento',
    'Transmisión',
  ];

  final canales = [
    'Canal 2',
    'TV Pública',
    'América',
    'Telefe',
    'ESPN',
    'Fox Sports',
    'TyC Sports',
    'Disney+',
  ];

  final List<Map<String, dynamic>> tareas = [
    {
      'titulo': 'Revisar temperatura del cabezal',
      'descripcion': 'Controlar temperatura y prender extractor si supera el límite.',
      'estado': 'Urgente',
      'prioridad': 'Crítica',
      'responsable': 'Operador 1',
      'area': 'Cabecera',
      'canal': 'Canal 2',
      'fecha': DateTime.now(),
      'hora': const TimeOfDay(hour: 9, minute: 0),
      'creado': DateTime.now(),
      'modificado': DateTime.now(),
      'comentarios': ['Temperatura elevada detectada.'],
      'historial': ['Tarea creada', 'Estado cambiado a Urgente'],
      'adjunto': null,
    },
    {
      'titulo': 'Revisar señal de Canal 2',
      'descripcion': 'Verificar audio, video y estabilidad de la transmisión.',
      'estado': 'En progreso',
      'prioridad': 'Alta',
      'responsable': 'Operador 2',
      'area': 'Transmisión',
      'canal': 'Canal 2',
      'fecha': DateTime.now(),
      'hora': const TimeOfDay(hour: 12, minute: 0),
      'creado': DateTime.now(),
      'modificado': DateTime.now(),
      'comentarios': [],
      'historial': ['Tarea creada'],
      'adjunto': null,
    },
  ];

  List<Map<String, dynamic>> get tareasFiltradas {
    final texto = searchController.text.toLowerCase();

    return tareas.where((tarea) {
      final coincideTexto =
          tarea['titulo'].toString().toLowerCase().contains(texto) ||
          tarea['descripcion'].toString().toLowerCase().contains(texto) ||
          tarea['canal'].toString().toLowerCase().contains(texto);

      final coincideEstado =
          filtroEstado == 'Todas' || tarea['estado'] == filtroEstado;

      final coincideArea =
          filtroArea == 'Todas' || tarea['area'] == filtroArea;

      return coincideTexto && coincideEstado && coincideArea;
    }).toList()
      ..sort((a, b) {
        final prioridadOrden = {
          'Crítica': 0,
          'Alta': 1,
          'Media': 2,
          'Baja': 3,
        };

        return prioridadOrden[a['prioridad']]!
            .compareTo(prioridadOrden[b['prioridad']]!);
      });
  }

  Color colorEstado(String estado) {
    switch (estado) {
      case 'Urgente':
        return Colors.red;
      case 'En progreso':
        return Colors.orange;
      case 'Completada':
        return Colors.green;
      default:
        return Colors.deepPurple;
    }
  }

  Color colorPrioridad(String prioridad) {
    switch (prioridad) {
      case 'Crítica':
        return Colors.red;
      case 'Alta':
        return Colors.deepOrange;
      case 'Media':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  IconData iconoArea(String area) {
    switch (area) {
      case 'Cabecera':
        return Icons.settings_input_antenna;
      case 'Subtitulado':
        return Icons.closed_caption;
      case 'Streaming':
        return Icons.wifi_tethering;
      case 'Reclamos':
        return Icons.report_problem;
      case 'Cámaras':
        return Icons.videocam;
      case 'Mantenimiento':
        return Icons.build;
      default:
        return Icons.live_tv;
    }
  }

  void eliminarTarea(Map<String, dynamic> tarea) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Deseas eliminar "${tarea['titulo']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() {
        tareas.remove(tarea);
      });
    }
  }

  void abrirEditor({Map<String, dynamic>? tarea}) {
    final editando = tarea != null;

    final tituloController =
        TextEditingController(text: editando ? tarea['titulo'] : '');
    final descripcionController =
        TextEditingController(text: editando ? tarea['descripcion'] : '');
    final comentarioController = TextEditingController();

    String estado = editando ? tarea['estado'] : 'Pendiente';
    String prioridad = editando ? tarea['prioridad'] : 'Media';
    String responsable = editando ? tarea['responsable'] : responsables.first;
    String area = editando ? tarea['area'] : areas.first;
    String canal = editando ? tarea['canal'] : canales.first;
    DateTime fecha = editando ? tarea['fecha'] : DateTime.now();
    TimeOfDay hora = editando ? tarea['hora'] : TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      editando ? 'Editar tarea' : 'Nueva tarea',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: tituloController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: descripcionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    dropdown('Estado', estado, estados, (v) {
                      setModalState(() => estado = v);
                    }),

                    const SizedBox(height: 12),

                    dropdown('Prioridad', prioridad, prioridades, (v) {
                      setModalState(() => prioridad = v);
                    }),

                    const SizedBox(height: 12),

                    dropdown('Responsable', responsable, responsables, (v) {
                      setModalState(() => responsable = v);
                    }),

                    const SizedBox(height: 12),

                    dropdown('Área', area, areas, (v) {
                      setModalState(() => area = v);
                    }),

                    const SizedBox(height: 12),

                    dropdown('Canal afectado', canal, canales, (v) {
                      setModalState(() => canal = v);
                    }),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_month),
                            label: Text(DateFormat('dd/MM/yyyy').format(fecha)),
                            onPressed: () async {
                              final nuevaFecha = await showDatePicker(
                                context: context,
                                initialDate: fecha,
                                firstDate: DateTime(2024),
                                lastDate: DateTime(2035),
                              );

                              if (nuevaFecha != null) {
                                setModalState(() => fecha = nuevaFecha);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.access_time),
                            label: Text(hora.format(context)),
                            onPressed: () async {
                              final nuevaHora = await showTimePicker(
                                context: context,
                                initialTime: hora,
                              );

                              if (nuevaHora != null) {
                                setModalState(() => hora = nuevaHora);
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: comentarioController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Agregar comentario',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Adjuntos pendiente de conectar con imagen/archivo',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Adjuntar foto o captura'),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (tituloController.text.trim().isEmpty) return;

                          setState(() {
                            if (editando) {
                              tarea['titulo'] = tituloController.text.trim();
                              tarea['descripcion'] =
                                  descripcionController.text.trim();
                              tarea['estado'] = estado;
                              tarea['prioridad'] = prioridad;
                              tarea['responsable'] = responsable;
                              tarea['area'] = area;
                              tarea['canal'] = canal;
                              tarea['fecha'] = fecha;
                              tarea['hora'] = hora;
                              tarea['modificado'] = DateTime.now();

                              if (comentarioController.text.trim().isNotEmpty) {
                                tarea['comentarios']
                                    .add(comentarioController.text.trim());
                              }

                              tarea['historial'].add(
                                'Modificada el ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                              );
                            } else {
                              tareas.add({
                                'titulo': tituloController.text.trim(),
                                'descripcion':
                                    descripcionController.text.trim(),
                                'estado': estado,
                                'prioridad': prioridad,
                                'responsable': responsable,
                                'area': area,
                                'canal': canal,
                                'fecha': fecha,
                                'hora': hora,
                                'creado': DateTime.now(),
                                'modificado': DateTime.now(),
                                'comentarios':
                                    comentarioController.text.trim().isEmpty
                                        ? []
                                        : [comentarioController.text.trim()],
                                'historial': ['Tarea creada'],
                                'adjunto': null,
                              });
                            }
                          });

                          Navigator.pop(context);
                        },
                        child: Text(editando ? 'Guardar cambios' : 'Crear tarea'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget dropdown(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e),
            ),
          )
          .toList(),
      onChanged: (v) => onChanged(v!),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget chipFiltro(String texto, String seleccionado, Function(String) onTap) {
    final activo = texto == seleccionado;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(texto),
        selected: activo,
        selectedColor: Colors.deepPurple.withOpacity(0.15),
        labelStyle: TextStyle(
          color: activo ? Colors.deepPurple : Colors.black54,
          fontWeight: FontWeight.bold,
        ),
        onSelected: (_) => onTap(texto),
      ),
    );
  }

  Widget resumen(String titulo, int cantidad, IconData icono, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icono, color: color),
            const SizedBox(height: 6),
            Text(
              '$cantidad',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(titulo, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget tareaCard(Map<String, dynamic> tarea) {
    final estadoColor = colorEstado(tarea['estado']);
    final prioridadColor = colorPrioridad(tarea['prioridad']);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(iconoArea(tarea['area']), color: estadoColor),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tarea['titulo'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: tarea['estado'] == 'Completada'
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  tarea['descripcion'],
                  style: const TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    infoChip(Icons.person, tarea['responsable']),
                    infoChip(Icons.live_tv, tarea['canal']),
                    infoChip(Icons.business_center, tarea['area']),
                    infoChip(
                      Icons.calendar_month,
                      DateFormat('dd/MM/yyyy').format(tarea['fecha']),
                    ),
                    infoChip(Icons.access_time, tarea['hora'].format(context)),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    etiqueta(tarea['estado'], estadoColor),
                    const SizedBox(width: 8),
                    etiqueta(tarea['prioridad'], prioridadColor),
                  ],
                ),

                if (tarea['comentarios'].isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Último comentario: ${tarea['comentarios'].last}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Column(
            children: [
              IconButton(
                tooltip: 'Cambiar estado',
                icon: const Icon(Icons.swap_horiz),
                onPressed: () {
                  final index = estados.indexOf(tarea['estado']);
                  final nuevoEstado = estados[(index + 1) % estados.length];

                  setState(() {
                    tarea['estado'] = nuevoEstado;
                    tarea['modificado'] = DateTime.now();
                    tarea['historial'].add('Estado cambiado a $nuevoEstado');
                  });
                },
              ),
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(Icons.edit, color: Colors.deepPurple),
                onPressed: () => abrirEditor(tarea: tarea),
              ),
              IconButton(
                tooltip: 'Eliminar',
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => eliminarTarea(tarea),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget infoChip(IconData icon, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Colors.blueGrey),
        const SizedBox(width: 4),
        Text(
          texto,
          style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
        ),
      ],
    );
  }

  Widget etiqueta(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = tareas.length;
    final urgentes = tareas.where((t) => t['estado'] == 'Urgente').length;
    final progreso = tareas.where((t) => t['estado'] == 'En progreso').length;
    final completadas = tareas.where((t) => t['estado'] == 'Completada').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
        onPressed: () => abrirEditor(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 26,
                      color: Color(0xFF111447),
                    ),
                    splashRadius: 24,
                    tooltip: 'Volver',
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pendientes',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111447),
                          ),
                        ),
                        Text(
                          'Gestión operativa del sector',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Text(
                      '$urgentes',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      resumen('Total', total, Icons.assignment, Colors.deepPurple),
                      const SizedBox(width: 8),
                      resumen('Curso', progreso, Icons.access_time, Colors.orange),
                      const SizedBox(width: 8),
                      resumen('Urgentes', urgentes, Icons.warning, Colors.red),
                      const SizedBox(width: 8),
                      resumen('Listas', completadas, Icons.check_circle, Colors.green),
                    ],
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Buscar tarea, canal o descripción...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Todas', ...estados]
                          .map(
                            (e) => chipFiltro(
                              e,
                              filtroEstado,
                              (v) => setState(() => filtroEstado = v),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Todas', ...areas]
                          .map(
                            (e) => chipFiltro(
                              e,
                              filtroArea,
                              (v) => setState(() => filtroArea = v),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (tareasFiltradas.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text('No hay tareas para mostrar'),
                      ),
                    )
                  else
                    ...tareasFiltradas.map(tareaCard),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}