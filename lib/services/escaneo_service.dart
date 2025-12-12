import 'package:flutter/material.dart';
import '../models/producto.dart';

class EscaneoService {
  static String limpiarCodigo(String raw) {
    return raw.replaceFirst(RegExp(r'^\](C1|A0|B1)'), '');
  }

  static void mostrarResultado(
    BuildContext context, 
    String codigoIngresado, 
    Map<String, Producto> productos
  ) {
    final clave = codigoIngresado.length >= 9
        ? codigoIngresado.substring(0, 9)
        : codigoIngresado;

    final producto = productos[clave];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resultado'),
        content: Text(producto != null
            ? 'Código escaneado: $codigoIngresado\n'
              'Código del archivo: ${producto.sku}\n'
              'Producto: ${producto.descripcion}\n'
              'Nuevo precio: \$${producto.precioActualizado.toStringAsFixed(0)}'
            : 'Código escaneado: $codigoIngresado\n'
              'Este producto no ha bajado de precio'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void ingresarCodigoManual(
    BuildContext context, 
    Map<String, Producto> productos
  ) {
    String codigo = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ingrese el código'),
        content: TextField(
          autofocus: true,
          keyboardType: TextInputType.number,
          onChanged: (value) => codigo = value,
          decoration: const InputDecoration(hintText: 'Código del producto'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              mostrarResultado(context, codigo, productos);
            },
            child: const Text('Verificar'),
          ),
        ],
      ),
    );
  }
}