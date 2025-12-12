import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../models/producto.dart';

class ArchivoService {
  String? _archivoInicial;
  final Set<String> _archivosFusionados = {};

  // Carga un archivo individual sin fusionar
  Future<Map<String, Producto>?> cargarArchivoIndividual() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final nombreArchivo = result.files.single.name;
      final productosNuevos = <String, Producto>{};
      final ext = path.split('.').last.toLowerCase();

      if (ext == 'csv') {
        await _procesarCSV(path, productosNuevos, nombreArchivo);
      } else if (ext == 'xlsx') {
        await _procesarExcel(path, productosNuevos, nombreArchivo);
      }

      return productosNuevos;
    }
    
    return null;
  }

  // Carga el archivo INICIAL (solo uno)
  Map<String, Producto> cargarArchivoInicial({
    required Map<String, Producto> productosNuevos,
  }) {
    final nombreArchivo = _obtenerNombreArchivo(productosNuevos);
    
    if (_archivoInicial != null) {
      throw Exception('Ya hay un archivo inicial cargado. Usa "Fusionar Archivo" para agregar más.');
    }

    _archivoInicial = nombreArchivo;
    return productosNuevos;
  }

  // Fusiona un archivo adicional
  Map<String, Producto> fusionarArchivo({
    required Map<String, Producto> productosActuales,
    required Map<String, Producto> productosNuevos,
  }) {
    final nombreArchivo = _obtenerNombreArchivo(productosNuevos);
    
    if (_archivosFusionados.contains(nombreArchivo)) {
      throw Exception('El archivo "$nombreArchivo" ya fue fusionado anteriormente');
    }

    // Verificar que no sea el archivo inicial
    if (nombreArchivo == _archivoInicial) {
      throw Exception('El archivo inicial no se puede fusionar consigo mismo');
    }

    // Fusionar: los nuevos productos sobreescriben los existentes
    final productosFusionados = {...productosActuales, ...productosNuevos};
    _archivosFusionados.add(nombreArchivo);

    return productosFusionados;
  }

  // Obtener nombre del archivo desde los productos
  String _obtenerNombreArchivo(Map<String, Producto> productos) {
    if (productos.isEmpty) return 'archivo_desconocido';
    return productos.values.first.fuente;
  }

  // Información del estado actual
  Map<String, dynamic> obtenerEstado() {
    return {
      'archivoInicial': _archivoInicial,
      'totalArchivosFusionados': _archivosFusionados.length,
      'archivosFusionados': _archivosFusionados.toList(),
      'tieneArchivoInicial': _archivoInicial != null,
    };
  }

  // Verificar si ya hay archivo inicial cargado
  bool get tieneArchivoInicial => _archivoInicial != null;

  // Verificar si se puede fusionar un archivo
  bool puedeFusionarArchivo(Map<String, Producto> productosNuevos) {
    final nombreArchivo = _obtenerNombreArchivo(productosNuevos);
    return !_archivosFusionados.contains(nombreArchivo) && 
           nombreArchivo != _archivoInicial;
  }

  // Limpiar todo
  void limpiarTodo() {
    _archivoInicial = null;
    _archivosFusionados.clear();
  }

  // Métodos de procesamiento (mantenidos igual)
  Future<void> _procesarCSV(
    String path, 
    Map<String, Producto> productos, 
    String nombreArchivo
  ) async {
    final file = File(path);
    final csvContent = await file.readAsString();
    final rows = const LineSplitter().convert(csvContent);

    for (var i = 1; i < rows.length; i++) {
      final columns = rows[i].split(',');

      if (columns.length >= 9) {
        final serie = columns[0].trim();
        final sku = columns[1].trim();
        final descripcion = columns[2].trim();
        final negocio = columns[3].trim();
        final depto = columns[4].trim();
        final linea = columns[5].trim();
        final temporada = columns[6].trim();
        final precioAnterior = double.tryParse(columns[7].trim()) ?? 0;
        final precioActualizado = double.tryParse(columns[8].trim()) ?? 0;

        if (sku.isNotEmpty) {
          final producto = Producto(
            serie: serie,
            sku: sku,
            descripcion: descripcion,
            negocio: negocio,
            depto: depto,
            linea: linea,
            temporada: temporada,
            precioAnterior: precioAnterior,
            precioActualizado: precioActualizado,
            fuente: nombreArchivo,
          );
          productos[producto.clave] = producto;
        }
      }
    }
  }

  Future<void> _procesarExcel(
    String path, 
    Map<String, Producto> productos, 
    String nombreArchivo
  ) async {
    final file = File(path);
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables[excel.tables.keys.first];

    if (sheet != null) {
      for (var row in sheet.rows.skip(1)) {
        final serie = row[0]?.value.toString().trim();
        final sku = row[1]?.value.toString().trim();
        final descripcion = row[2]?.value.toString().trim();
        final negocio = row[3]?.value.toString().trim();
        final depto = row[4]?.value.toString().trim();
        final linea = row[5]?.value.toString().trim();
        final temporada = row[6]?.value.toString().trim();
        final precioAnterior = double.tryParse(row[7]?.value.toString() ?? '') ?? 0;
        final precioActualizado = double.tryParse(row[8]?.value.toString() ?? '') ?? 0;

        if (sku != null && sku.isNotEmpty) {
          final producto = Producto(
            serie: serie ?? '',
            sku: sku,
            descripcion: descripcion ?? '',
            negocio: negocio ?? '',
            depto: depto ?? '',
            linea: linea ?? '',
            temporada: temporada ?? '',
            precioAnterior: precioAnterior,
            precioActualizado: precioActualizado,
            fuente: nombreArchivo,
          );
          productos[producto.clave] = producto;
        }
      }
    }
  }
}