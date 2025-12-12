import 'package:flutter/material.dart';
import '../models/producto.dart';

class ListaProductosScreen extends StatefulWidget {
  final List<Producto> productos;

  const ListaProductosScreen({super.key, required this.productos});

  @override
  State<ListaProductosScreen> createState() => _ListaProductosScreenState();
}

class _ListaProductosScreenState extends State<ListaProductosScreen> {
  List<Producto> _productosFiltrados = [];
  String _filtroDepto = 'Todos';
  String _filtroLinea = 'Todos';
  String _filtroTemporada = 'Todos';
  String _ordenamiento = 'Precio Actualizado (Menor a Mayor)';

  final List<String> _opcionesOrdenamiento = [
    'Precio Actualizado (Menor a Mayor)',
    'Precio Actualizado (Mayor a Menor)',
    'Precio Anterior (Menor a Mayor)',
    'Precio Anterior (Mayor a Menor)',
    'SKU (A-Z)',
    'Descripción (A-Z)',
  ];

  @override
  void initState() {
    super.initState();
    _aplicarFiltrosYOrdenamiento();
  }

  void _aplicarFiltrosYOrdenamiento() {
    // Aplicar filtros
    List<Producto> productosFiltrados = widget.productos;

    if (_filtroDepto != 'Todos') {
      productosFiltrados = productosFiltrados
          .where((producto) => producto.depto == _filtroDepto)
          .toList();
    }

    if (_filtroLinea != 'Todos') {
      productosFiltrados = productosFiltrados
          .where((producto) => producto.linea == _filtroLinea)
          .toList();
    }

    if (_filtroTemporada != 'Todos') {
      productosFiltrados = productosFiltrados
          .where((producto) => producto.temporada == _filtroTemporada)
          .toList();
    }

    // Aplicar ordenamiento
    switch (_ordenamiento) {
      case 'Precio Actualizado (Menor a Mayor)':
        productosFiltrados
            .sort((a, b) => a.precioActualizado.compareTo(b.precioActualizado));
        break;
      case 'Precio Actualizado (Mayor a Menor)':
        productosFiltrados
            .sort((a, b) => b.precioActualizado.compareTo(a.precioActualizado));
        break;
      case 'Precio Anterior (Menor a Mayor)':
        productosFiltrados
            .sort((a, b) => a.precioAnterior.compareTo(b.precioAnterior));
        break;
      case 'Precio Anterior (Mayor a Menor)':
        productosFiltrados
            .sort((a, b) => b.precioAnterior.compareTo(a.precioAnterior));
        break;
      case 'SKU (A-Z)':
        productosFiltrados.sort((a, b) => a.sku.compareTo(b.sku));
        break;
      case 'Descripción (A-Z)':
        productosFiltrados.sort((a, b) => a.descripcion.compareTo(b.descripcion));
        break;
    }

    setState(() {
      _productosFiltrados = productosFiltrados;
    });
  }

  List<String> _obtenerOpcionesFiltro(List<Producto> productos, String tipo) {
    final valores = <String>['Todos'];
    final valoresUnicos = productos.map((p) {
      switch (tipo) {
        case 'depto':
          return p.depto;
        case 'linea':
          return p.linea;
        case 'temporada':
          return p.temporada;
        default:
          return '';
      }
    }).where((valor) => valor.isNotEmpty).toSet().toList()..sort();

    valores.addAll(valoresUnicos);
    return valores;
  }

  void _mostrarDialogoFiltros() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Filtrar y Ordenar'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Filtro Depto
                  _buildFiltroDropdown(
                    label: 'Departamento',
                    value: _filtroDepto,
                    opciones: _obtenerOpcionesFiltro(widget.productos, 'depto'),
                    onChanged: (value) {
                      setDialogState(() {
                        _filtroDepto = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Filtro Línea
                  _buildFiltroDropdown(
                    label: 'Línea',
                    value: _filtroLinea,
                    opciones: _obtenerOpcionesFiltro(widget.productos, 'linea'),
                    onChanged: (value) {
                      setDialogState(() {
                        _filtroLinea = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Filtro Temporada
                  _buildFiltroDropdown(
                    label: 'Temporada',
                    value: _filtroTemporada,
                    opciones: _obtenerOpcionesFiltro(widget.productos, 'temporada'),
                    onChanged: (value) {
                      setDialogState(() {
                        _filtroTemporada = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Ordenamiento
                  _buildFiltroDropdown(
                    label: 'Ordenar por',
                    value: _ordenamiento,
                    opciones: _opcionesOrdenamiento,
                    onChanged: (value) {
                      setDialogState(() {
                        _ordenamiento = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _aplicarFiltrosYOrdenamiento();
                },
                child: const Text('Aplicar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFiltroDropdown({
    required String label,
    required String value,
    required List<String> opciones,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: opciones.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Productos'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _mostrarDialogoFiltros,
            tooltip: 'Filtrar y Ordenar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Resumen de filtros
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                Icon(Icons.filter_list, color: Colors.blue.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_productosFiltrados.length} productos'
                    '${_filtroDepto != 'Todos' ? ' • Depto: $_filtroDepto' : ''}'
                    '${_filtroLinea != 'Todos' ? ' • Línea: $_filtroLinea' : ''}'
                    '${_filtroTemporada != 'Todos' ? ' • Temp: $_filtroTemporada' : ''}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de productos
          Expanded(
            child: _productosFiltrados.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No se encontraron productos',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _productosFiltrados.length,
                    itemBuilder: (context, index) {
                      final producto = _productosFiltrados[index];
                      return _buildItemProducto(producto);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemProducto(Producto producto) {
    final bool precioBajo = producto.precioActualizado < producto.precioAnterior;
    final bool precioSubio = producto.precioActualizado > producto.precioAnterior;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con SKU y Serie
            Row(
              children: [
                Expanded(
                  child: Text(
                    producto.sku,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    producto.serie,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Descripción
            Text(
              producto.descripcion,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 8),
            
            // Info Depto, Línea, Temporada
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (producto.depto.isNotEmpty)
                  _buildChipInfo('Depto: ${producto.depto}'),
                if (producto.linea.isNotEmpty)
                  _buildChipInfo('Línea: ${producto.linea}'),
                if (producto.temporada.isNotEmpty)
                  _buildChipInfo('Temp: ${producto.temporada}'),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Precios
            Row(
              children: [
                // Precio Anterior
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Precio Anterior',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '\$${producto.precioAnterior.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Icono de cambio
                Icon(
                  precioBajo
                      ? Icons.arrow_downward
                      : precioSubio
                          ? Icons.arrow_upward
                          : Icons.remove,
                  color: precioBajo
                      ? Colors.green
                      : precioSubio
                          ? Colors.red
                          : Colors.grey,
                  size: 20,
                ),
                
                // Precio Actualizado
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Precio Actual',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '\$${producto.precioActualizado.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: precioBajo
                              ? Colors.green
                              : precioSubio
                                  ? Colors.red
                                  : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            
            const SizedBox(height: 8),
            
            // Fuente
            Text(
              'Fuente: ${producto.fuente}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipInfo(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 10,
          color: Colors.blue.shade800,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}