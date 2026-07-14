import 'package:app_cabecera/controller/pendientes_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PendientesScreen extends StatefulWidget {
  const PendientesScreen({super.key});

  @override
  State<PendientesScreen> createState() => _PendientesScreenState();
}

class _PendientesScreenState extends State<PendientesScreen> {
  final PendientesController controller = Get.put(PendientesController());

  static const Color backgroundColor = Color(0xFF020016);
  static const Color cardColor = Color(0xFF031A2D);
  static const Color cardSecondaryColor = Color(0xFF07162B);
  static const Color borderColor = Color(0xFF173B51);
  static const Color purpleColor = Color(0xFF925AFF);
  static const Color greenColor = Color(0xFF20E5A0);
  static const Color orangeColor = Color(0xFFFFA51F);
  static const Color redColor = Color(0xFFFF4778);
  static const Color textPrimaryColor = Color(0xFFF7F7FF);
  static const Color textSecondaryColor = Color(0xFFA8AEC8);

  final List<String> estados = const [
    'Pendiente',
    'En progreso',
    'Urgente',
    'Completada',
  ];

  Color colorEstado(String estado) {
    switch (estado) {
      case 'Urgente':
        return redColor;
      case 'En progreso':
        return orangeColor;
      case 'Completada':
        return greenColor;
      default:
        return purpleColor;
    }
  }

  IconData iconoEstado(String estado) {
    switch (estado) {
      case 'Urgente':
        return Icons.warning_amber_rounded;
      case 'En progreso':
        return Icons.timelapse_rounded;
      case 'Completada':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.pending_actions_rounded;
    }
  }

  InputDecoration inputDecoration({
    required String label,
    String? hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: purpleColor),
      labelStyle: const TextStyle(color: textSecondaryColor),
      hintStyle: TextStyle(
        color: textSecondaryColor.withValues(alpha: 0.65),
      ),
      filled: true,
      fillColor: cardSecondaryColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: purpleColor, width: 1.5),
      ),
    );
  }

  Future<void> abrirEditor({Map<String, dynamic>? tarea}) async {
    final editando = tarea != null;

    final tituloController = TextEditingController(
      text: editando ? tarea['titulo']?.toString() ?? '' : '',
    );
    final descripcionController = TextEditingController(
      text: editando ? tarea['descripcion']?.toString() ?? '' : '',
    );

    String estado =
        editando ? tarea['estado']?.toString() ?? 'Pendiente' : 'Pendiente';
    DateTime fecha =
        editando ? tarea['fecha'] as DateTime : DateTime.now();
    TimeOfDay hora =
        editando ? tarea['hora'] as TimeOfDay : TimeOfDay.now();
    bool guardando = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> guardar() async {
              final titulo = tituloController.text.trim();

              if (titulo.isEmpty) {
                _mostrarMensaje(
                  'Debes escribir un título',
                  color: redColor,
                  icono: Icons.warning_amber_rounded,
                );
                return;
              }

              setModalState(() => guardando = true);

              try {
                if (editando) {
                  await controller.actualizarTarea(
                    id: tarea['id'] as int,
                    titulo: titulo,
                    descripcion: descripcionController.text.trim(),
                    estado: estado,
                    fecha: fecha,
                    hora: hora,
                  );
                } else {
                  await controller.crearTarea(
                    titulo: titulo,
                    descripcion: descripcionController.text.trim(),
                    estado: estado,
                    fecha: fecha,
                    hora: hora,
                  );
                }

                if (sheetContext.mounted) {
                  Navigator.pop(sheetContext);
                }

                _mostrarMensaje(
                  editando
                      ? 'Cambios guardados correctamente'
                      : 'Tarea creada correctamente',
                  color: greenColor,
                  icono: Icons.check_circle_outline_rounded,
                );
              } catch (_) {
                if (sheetContext.mounted) {
                  setModalState(() => guardando = false);
                }
                _mostrarMensaje(
                  'No se pudo guardar la tarea',
                  color: redColor,
                  icono: Icons.error_outline_rounded,
                );
              }
            }

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.92,
              ),
              decoration: const BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                border: Border(
                  top: BorderSide(color: borderColor),
                  left: BorderSide(color: borderColor),
                  right: BorderSide(color: borderColor),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: textSecondaryColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: purpleColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            editando
                                ? Icons.edit_note_rounded
                                : Icons.add_task_rounded,
                            color: purpleColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            editando ? 'Editar tarea' : 'Nueva tarea',
                            style: const TextStyle(
                              color: textPrimaryColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: guardando
                              ? null
                              : () => Navigator.pop(sheetContext),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: borderColor, height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        20,
                        20,
                        20,
                        MediaQuery.of(context).viewInsets.bottom + 24,
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: tituloController,
                            enabled: !guardando,
                            style: const TextStyle(color: textPrimaryColor),
                            textCapitalization: TextCapitalization.sentences,
                            decoration: inputDecoration(
                              label: 'Título',
                              hint: 'Ejemplo: revisar señal de ESPN',
                              icon: Icons.task_alt_rounded,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: descripcionController,
                            enabled: !guardando,
                            maxLines: 4,
                            style: const TextStyle(color: textPrimaryColor),
                            textCapitalization: TextCapitalization.sentences,
                            decoration: inputDecoration(
                              label: 'Descripción',
                              hint: 'Detallá el trabajo que debe realizarse',
                              icon: Icons.notes_rounded,
                            ),
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            value: estado,
                            dropdownColor: cardColor,
                            iconEnabledColor: purpleColor,
                            style: const TextStyle(color: textPrimaryColor),
                            decoration: inputDecoration(
                              label: 'Estado',
                              icon: Icons.pending_actions_rounded,
                            ),
                            items: estados
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                            onChanged: guardando
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setModalState(() => estado = value);
                                    }
                                  },
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _dateTimeButton(
                                  icon: Icons.calendar_month_rounded,
                                  label: DateFormat('dd/MM/yyyy').format(fecha),
                                  onPressed: guardando
                                      ? null
                                      : () async {
                                          final nuevaFecha =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: fecha,
                                            firstDate: DateTime(2024),
                                            lastDate: DateTime(2035),
                                            builder: (context, child) {
                                              return Theme(
                                                data: Theme.of(context)
                                                    .copyWith(
                                                  colorScheme:
                                                      const ColorScheme.dark(
                                                    primary: purpleColor,
                                                    surface: cardColor,
                                                    onSurface:
                                                        textPrimaryColor,
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );

                                          if (nuevaFecha != null) {
                                            setModalState(
                                              () => fecha = nuevaFecha,
                                            );
                                          }
                                        },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _dateTimeButton(
                                  icon: Icons.access_time_rounded,
                                  label: hora.format(context),
                                  onPressed: guardando
                                      ? null
                                      : () async {
                                          final nuevaHora =
                                              await showTimePicker(
                                            context: context,
                                            initialTime: hora,
                                            builder: (context, child) {
                                              return Theme(
                                                data: Theme.of(context)
                                                    .copyWith(
                                                  colorScheme:
                                                      const ColorScheme.dark(
                                                    primary: purpleColor,
                                                    surface: cardColor,
                                                    onSurface:
                                                        textPrimaryColor,
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );

                                          if (nuevaHora != null) {
                                            setModalState(
                                              () => hora = nuevaHora,
                                            );
                                          }
                                        },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: guardando ? null : guardar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: purpleColor,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    purpleColor.withValues(alpha: 0.45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17),
                                ),
                              ),
                              icon: guardando
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      editando
                                          ? Icons.save_outlined
                                          : Icons.add_task_rounded,
                                    ),
                              label: Text(
                                guardando
                                    ? 'Guardando...'
                                    : editando
                                        ? 'Guardar cambios'
                                        : 'Crear tarea',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    tituloController.dispose();
    descripcionController.dispose();
  }

  Widget _dateTimeButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimaryColor,
          backgroundColor: cardSecondaryColor,
          side: const BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(icon, color: purpleColor, size: 20),
        label: Flexible(
          child: Text(label, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }

  Future<void> eliminarTarea(Map<String, dynamic> tarea) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cardColor,
        title: const Text(
          'Eliminar tarea',
          style: TextStyle(color: textPrimaryColor),
        ),
        content: Text(
          '¿Deseas eliminar "${tarea['titulo']}"?',
          style: const TextStyle(color: textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: redColor),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await controller.eliminarTarea(tarea['id'] as int);
      _mostrarMensaje(
        'La tarea fue eliminada',
        color: greenColor,
        icono: Icons.check_circle_outline_rounded,
      );
    } catch (_) {
      _mostrarMensaje(
        'No se pudo eliminar la tarea',
        color: redColor,
        icono: Icons.error_outline_rounded,
      );
    }
  }

  Future<void> cambiarEstado(Map<String, dynamic> tarea) async {
    final estadoActual = tarea['estado']?.toString() ?? 'Pendiente';
    final indexActual = estados.indexOf(estadoActual);
    final nuevoEstado =
        estados[indexActual < 0 ? 0 : (indexActual + 1) % estados.length];

    try {
      await controller.cambiarEstado(
        id: tarea['id'] as int,
        nuevoEstado: nuevoEstado,
      );
      _mostrarMensaje(
        'Estado cambiado a $nuevoEstado',
        color: colorEstado(nuevoEstado),
        icono: iconoEstado(nuevoEstado),
      );
    } catch (_) {
      _mostrarMensaje(
        'No se pudo cambiar el estado',
        color: redColor,
        icono: Icons.error_outline_rounded,
      );
    }
  }

  void _mostrarMensaje(
    String mensaje, {
    required Color color,
    required IconData icono,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: cardColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color),
        ),
        content: Row(
          children: [
            Icon(icono, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(color: textPrimaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int urgentes) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 18, 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: IconButton(
              onPressed: Get.back,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: textPrimaryColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PENDIENTES',
                  style: TextStyle(
                    color: purpleColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Gestión operativa del sector',
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: urgentes > 0
                  ? redColor.withValues(alpha: 0.15)
                  : greenColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  urgentes > 0
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline_rounded,
                  color: urgentes > 0 ? redColor : greenColor,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '$urgentes',
                  style: TextStyle(
                    color: urgentes > 0 ? redColor : greenColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid({
    required int total,
    required int progreso,
    required int urgentes,
    required int completadas,
  }) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            'Total',
            total,
            Icons.assignment_outlined,
            purpleColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _summaryCard(
            'En curso',
            progreso,
            Icons.timelapse_rounded,
            orangeColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _summaryCard(
            'Urgentes',
            urgentes,
            Icons.warning_amber_rounded,
            redColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _summaryCard(
            'Listas',
            completadas,
            Icons.check_circle_outline_rounded,
            greenColor,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(
    String title,
    int value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 13),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textSecondaryColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> tarea) {
    final estado = tarea['estado']?.toString() ?? 'Pendiente';
    final estadoColor = colorEstado(estado);
    final completada = estado == 'Completada';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: estado == 'Urgente'
              ? redColor.withValues(alpha: 0.65)
              : borderColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 15, 10, 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: estadoColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    iconoEstado(estado),
                    color: estadoColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tarea['titulo']?.toString() ?? '',
                        style: TextStyle(
                          color: completada
                              ? textSecondaryColor
                              : textPrimaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          decoration:
                              completada ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if ((tarea['descripcion']?.toString() ?? '')
                          .isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          tarea['descripcion'].toString(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textSecondaryColor,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  color: cardSecondaryColor,
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: textSecondaryColor,
                  ),
                  onSelected: (value) {
                    if (value == 'estado') cambiarEstado(tarea);
                    if (value == 'editar') abrirEditor(tarea: tarea);
                    if (value == 'eliminar') eliminarTarea(tarea);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'estado',
                      child: Text(
                        'Cambiar estado',
                        style: TextStyle(color: textPrimaryColor),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'editar',
                      child: Text(
                        'Editar',
                        style: TextStyle(color: textPrimaryColor),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'eliminar',
                      child: Text(
                        'Eliminar',
                        style: TextStyle(color: redColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cardSecondaryColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: textSecondaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd/MM/yyyy').format(tarea['fecha'] as DateTime),
                    style: const TextStyle(
                      color: textSecondaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.access_time_rounded,
                    color: textSecondaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    (tarea['hora'] as TimeOfDay).format(context),
                    style: const TextStyle(
                      color: textSecondaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: estadoColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      estado,
                      style: TextStyle(
                        color: estadoColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 38),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: const Column(
        children: [
          Icon(Icons.task_alt_rounded, color: purpleColor, size: 48),
          SizedBox(height: 16),
          Text(
            'No hay tareas pendientes',
            style: TextStyle(
              color: textPrimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Agregá una nueva tarea con el botón inferior.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textSecondaryColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tareas = controller.tareas;
      final total = tareas.length;
      final urgentes =
          tareas.where((tarea) => tarea['estado'] == 'Urgente').length;
      final progreso =
          tareas.where((tarea) => tarea['estado'] == 'En progreso').length;
      final completadas =
          tareas.where((tarea) => tarea['estado'] == 'Completada').length;

      if (controller.cargando.value && tareas.isEmpty) {
        return const Scaffold(
          backgroundColor: backgroundColor,
          body: Center(
            child: CircularProgressIndicator(color: purpleColor),
          ),
        );
      }

      if (controller.error.value != null && tareas.isEmpty) {
        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Center(
              child: ElevatedButton.icon(
                onPressed: controller.cargarTareas,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: backgroundColor,
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'pendientes_fab',
          onPressed: abrirEditor,
          backgroundColor: purpleColor,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_task_rounded),
          label: const Text(
            'Nueva tarea',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(urgentes),
              Expanded(
                child: RefreshIndicator(
                  color: purpleColor,
                  backgroundColor: cardColor,
                  onRefresh: controller.cargarTareas,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    children: [
                      _buildSummaryGrid(
                        total: total,
                        progreso: progreso,
                        urgentes: urgentes,
                        completadas: completadas,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'TAREAS',
                        style: TextStyle(
                          color: purpleColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (tareas.isEmpty)
                        _buildEmptyState()
                      else
                        ...tareas.map(_buildTaskCard),
                    ],
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
