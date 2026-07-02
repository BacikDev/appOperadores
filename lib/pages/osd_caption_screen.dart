import 'dart:convert';
import 'dart:ui' as ui;

import 'package:app_cabecera/controller/osd_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


class OsdCaptionScreen extends StatefulWidget {
  const OsdCaptionScreen({super.key});

  @override
  State<OsdCaptionScreen> createState() => _OsdCaptionScreenState();
}

class _OsdCaptionScreenState extends State<OsdCaptionScreen> {
  final _previewKey = GlobalKey();
  final _textController = TextEditingController();

  late final OsdService _service;

  bool _loading = false;

  String _ip = '192.168.0.133';
  int _channel = 4;
  int _line = 4;
  int _x = 20;
  int _y = 1032;

  double _fontSize = 30;
  String _fontFamily = 'Courier,monospace';

  Color _textColor = Colors.greenAccent;
  Color _backgroundColor = Colors.black;

  final List<String> _templates = [
    'Sorteo Mensual... Abonando hasta el 1er. Vto. puede ganar \$120.000 de Premio... El Líder Junto a Vos',
    'Canal momentáneamente fuera de servicio. Estamos trabajando para solucionarlo.',
    'Farmacia de turno disponible. Consulte nuestra grilla informativa.',
    'Por mantenimiento técnico, algunos servicios pueden verse afectados.',
  ];

  @override
  void initState() {
    super.initState();
    _service = OsdService(ip: _ip);
  }

  Future<String> _capturePreviewAsBase64() async {
    final boundary =
        _previewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);

    if (data == null) {
      throw Exception('No se pudo generar la imagen PNG');
    }

    return base64Encode(data.buffer.asUint8List());
  }

  Future<void> _applyCaption() async {
    final text = _textController.text.trim();

    if (text.isEmpty) {
      _showMessage('Escribí un texto primero');
      return;
    }

    setState(() => _loading = true);

    try {
      await _service.saveText(text);

      final imageBase64 = await _capturePreviewAsBase64();

      await _service.applyCaption(
  base64Png: imageBase64,
  line: _line,
  fontFamily: _fontFamily,
);

      _showMessage('Subtítulo aplicado correctamente');
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteCaption() async {
    setState(() => _loading = true);

    try {
      await _service.deleteCaption();
      _showMessage('Subtítulo eliminado');
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _clearText() {
    setState(() {
      _textController.clear();
    });
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  String _hex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Widget _colorButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 8, backgroundColor: color),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  void _selectTextColor() {
    final colors = [
      Colors.greenAccent,
      Colors.white,
      Colors.yellow,
      Colors.redAccent,
      Colors.blueAccent,
    ];

    _showColorDialog(
      title: 'Color del texto',
      colors: colors,
      onSelected: (color) {
        setState(() => _textColor = color);
      },
    );
  }

  void _selectBackgroundColor() {
    final colors = [
      Colors.black,
      Colors.transparent,
      Colors.white,
      Colors.blueGrey,
      Colors.red,
    ];

    _showColorDialog(
      title: 'Color de fondo',
      colors: colors,
      onSelected: (color) {
        setState(() => _backgroundColor = color);
      },
    );
  }

  void _showColorDialog({
    required String title,
    required List<Color> colors,
    required void Function(Color) onSelected,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: colors.map((color) {
              return InkWell(
                onTap: () {
                  Navigator.pop(context);
                  onSelected(color);
                },
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: color,
                  child: color == Colors.transparent
                      ? const Icon(Icons.block, color: Colors.black)
                      : null,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f1720),
      appBar: AppBar(
        title: const Text('Panel OSD / Subtítulos'),
        backgroundColor: const Color(0xff0f1720),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPreview(),
                const SizedBox(height: 16),
                _buildTextBox(),
                const SizedBox(height: 16),
                _buildTemplateBox(),
                const SizedBox(height: 16),
                _buildMainControls(),
                const SizedBox(height: 16),
                _buildPositionControls(),
                const SizedBox(height: 16),
                _buildColorControls(),
                const SizedBox(height: 24),
                _buildActions(),
              ],
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return _card(
      title: 'Vista previa',
      child: AspectRatio(
        aspectRatio: 16 / 4,
        child: Container(
          color: Colors.black,
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(12),
          child: RepaintBoundary(
            key: _previewKey,
            child: Container(
              color: _backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                _textController.text.isEmpty
                    ? 'Texto de prueba...'
                    : _textController.text,
                maxLines: _line,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _textColor,
                  fontSize: _fontSize,
                  fontFamily: 'Courier',
                  height: 1.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextBox() {
    return _card(
      title: 'Mensaje',
      child: TextField(
        controller: _textController,
        maxLines: 4,
        style: const TextStyle(color: Colors.white),
        onChanged: (_) => setState(() {}),
        decoration: _inputDecoration('Texto del subtítulo'),
      ),
    );
  }

  Widget _buildTemplateBox() {
    return _card(
      title: 'Plantillas rápidas',
      child: Column(
        children: _templates.map((template) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _textController.text = template;
                });
              },
              child: Text(
                template,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainControls() {
    return _card(
      title: 'Configuración principal',
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            value: _channel,
            dropdownColor: const Color(0xff1b2633),
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Canal'),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Enc CH 1')),
              DropdownMenuItem(value: 2, child: Text('Enc CH 2')),
              DropdownMenuItem(value: 3, child: Text('Enc CH 3')),
              DropdownMenuItem(value: 4, child: Text('Enc CH 4')),
              DropdownMenuItem(value: 5, child: Text('Enc CH 5')),
              DropdownMenuItem(value: 6, child: Text('Enc CH 6')),
              DropdownMenuItem(value: 7, child: Text('Enc CH 7')),
              DropdownMenuItem(value: 8, child: Text('Enc CH 8')),
              DropdownMenuItem(value: 99, child: Text('ALL')),
            ],
            onChanged: (value) {
              setState(() => _channel = value ?? 8);
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            value: _line,
            dropdownColor: const Color(0xff1b2633),
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Cantidad de líneas'),
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 línea')),
              DropdownMenuItem(value: 2, child: Text('2 líneas')),
              DropdownMenuItem(value: 3, child: Text('3 líneas')),
              DropdownMenuItem(value: 4, child: Text('4 líneas')),
            ],
            onChanged: (value) {
              setState(() => _line = value ?? 4);
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _fontFamily,
            dropdownColor: const Color(0xff1b2633),
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Fuente'),
            items: const [
              DropdownMenuItem(
                value: 'Courier,monospace',
                child: Text('Courier monospace'),
              ),
              DropdownMenuItem(
                value: 'Arial',
                child: Text('Arial'),
              ),
            ],
            onChanged: (value) {
              setState(() => _fontFamily = value ?? 'Courier,monospace');
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tamaño: ${_fontSize.toInt()} px',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Expanded(
                flex: 2,
                child: Slider(
                  value: _fontSize,
                  min: 20,
                  max: 100,
                  divisions: 16,
                  onChanged: (value) {
                    setState(() => _fontSize = value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPositionControls() {
    return _card(
      title: 'Posición en pantalla',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _numberField('X', _x, (v) => _x = v)),
              const SizedBox(width: 12),
              Expanded(child: _numberField('Y', _y, (v) => _y = v)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Valores sugeridos para abajo a la izquierda: X=20, Y=1032',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildColorControls() {
    return _card(
      title: 'Colores',
      child: Column(
        children: [
          Row(
            children: [
              _colorButton(
                label: 'Texto ${_hex(_textColor)}',
                color: _textColor,
                onTap: _selectTextColor,
              ),
              const SizedBox(width: 12),
              _colorButton(
                label: 'Fondo',
                color: _backgroundColor,
                onTap: _selectBackgroundColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _applyCaption,
            icon: const Icon(Icons.send),
            label: const Text('Guardar y aplicar subtítulo'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _deleteCaption,
            icon: const Icon(Icons.delete),
            label: const Text('Borrar subtítulo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton.icon(
            onPressed: _clearText,
            icon: const Icon(Icons.cleaning_services),
            label: const Text('Limpiar texto'),
          ),
        ),
      ],
    );
  }

  Widget _numberField(
    String label,
    int value,
    void Function(int) onChanged,
  ) {
    return TextFormField(
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label),
      onChanged: (value) {
        final parsed = int.tryParse(value);
        if (parsed != null) {
          setState(() => onChanged(parsed));
        }
      },
    );
  }

  Widget _card({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff15202b),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xff1b2633),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}