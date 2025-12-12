import 'package:flutter/material.dart';
import 'models/producto.dart';
import 'services/archivo_service.dart';
import 'services/escaneo_service.dart';
import 'widgets/mobile_scanner_screen.dart';
import 'screens/lista_productos_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, Producto> productos = {};
  final ArchivoService _archivoService = ArchivoService();
  String? archivoActual;
  int totalProductos = 0;
  
  bool _modoGestionActivo = false;

  void _actualizarProductos(Map<String, Producto> nuevosProductos) {
    setState(() {
      productos = nuevosProductos;
      totalProductos = productos.length;
      final estado = _archivoService.obtenerEstado();
      archivoActual = productos.isEmpty 
          ? null 
          : '${productos.length} productos (${estado['totalArchivosFusionados'] + (estado['tieneArchivoInicial'] ? 1 : 0)} archivos)';
    });
  }

  void _alternarModoGestion() {
    setState(() {
      _modoGestionActivo = !_modoGestionActivo;
    });
  }

  Future<void> _cargarArchivoInicial() async {
    final productosNuevos = await _archivoService.cargarArchivoIndividual();
    
    if (productosNuevos != null && productosNuevos.isNotEmpty) {
      try {
        final productosActualizados = _archivoService.cargarArchivoInicial(
          productosNuevos: productosNuevos,
        );
        
        _actualizarProductos(productosActualizados);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Archivo inicial cargado - ${productosNuevos.length} productos'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $e'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _fusionarArchivo() async {
    final productosNuevos = await _archivoService.cargarArchivoIndividual();
    
    if (productosNuevos != null && productosNuevos.isNotEmpty) {
      try {
        final productosFusionados = _archivoService.fusionarArchivo(
          productosActuales: productos,
          productosNuevos: productosNuevos,
        );
        
        _actualizarProductos(productosFusionados);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Archivo fusionado - ${productosNuevos.length} productos actualizados'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $e'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _verLista() {
    if (productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ No hay productos cargados'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListaProductosScreen(
          productos: productos.values.toList(),
        ),
      ),
    );
  }

  void _limpiarTodo() {
    _archivoService.limpiarTodo();
    _actualizarProductos({});
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🗑️ Todos los archivos fueron eliminados'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void escanearCodigo(BuildContext context) {
    if (productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Primero carga un archivo inicial'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MobileScannerScreen(
          onDetect: (codigo) {
            Navigator.pop(context);
            EscaneoService.mostrarResultado(context, codigo, productos);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = _archivoService.obtenerEstado();
    final tieneArchivoInicial = _archivoService.tieneArchivoInicial;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Lector de Precios',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header con información del archivo fusionado
            if (archivoActual != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade50, Colors.blue.shade50],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.merge, color: Colors.green.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tieneArchivoInicial ? 'Archivo Base + Fusionados' : 'Archivo Inicial',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            archivoActual!,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                          if (estado['totalArchivosFusionados'] > 0)
                            Text(
                              '${estado['totalArchivosFusionados']} archivos fusionados',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (totalProductos > 0)
                      Column(
                        children: [
                          Text(
                            '$totalProductos',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'productos',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            
            const SizedBox(height: 32),
            
            // Tarjetas de acciones - CAMBIO DINÁMICO
            Expanded(
              child: _modoGestionActivo 
                  ? _buildVistaGestion(tieneArchivoInicial) 
                  : _buildVistaPrincipal(tieneArchivoInicial),
            ),
            
            // Footer informativo
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _modoGestionActivo ? Icons.manage_accounts : Icons.qr_code,
                        color: Colors.blue.shade600, 
                        size: 16
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _modoGestionActivo 
                            ? 'Modo Gestión - $totalProductos productos'
                            : 'Modo Escaneo - $totalProductos productos',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _modoGestionActivo
                        ? 'Cargar: Archivo inicial • Fusionar: Archivos adicionales'
                        : 'Escanea o ingresa códigos de barras',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Vista principal (Escanear/Ingresar)
  Widget _buildVistaPrincipal(bool tieneArchivoInicial) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botón Gestionar Bajas
        _buildActionCard(
          icon: Icons.manage_search,
          title: 'Gestionar Bajas',
          subtitle: 'Cargar archivo inicial y fusionar',
          color: Colors.purple,
          onTap: _alternarModoGestion,
        ),
        
        const SizedBox(height: 20),
        
        // Tarjeta Escanear (solo si hay archivo cargado)
        if (tieneArchivoInicial)
          _buildActionCard(
            icon: Icons.qr_code_scanner,
            title: 'Escanear Código',
            subtitle: 'Usa la cámara',
            color: Colors.green,
            onTap: () => escanearCodigo(context),
          ),
        
        if (tieneArchivoInicial) const SizedBox(height: 20),
        
        // Tarjeta Ingresar Manual (solo si hay archivo cargado)
        if (tieneArchivoInicial)
          _buildActionCard(
            icon: Icons.keyboard,
            title: 'Ingreso Manual',
            subtitle: 'Escribe el código',
            color: Colors.orange,
            onTap: () => EscaneoService.ingresarCodigoManual(context, productos),
          ),

        // Mensaje si no hay archivo cargado
        if (!tieneArchivoInicial)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: const Column(
              children: [
                Icon(Icons.info, color: Colors.orange, size: 40),
                SizedBox(height: 12),
                Text(
                  'Primero carga un archivo inicial\nen "Gestionar Bajas"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Vista de Gestión (Cargar/Fusionar/Listar)
  Widget _buildVistaGestion(bool tieneArchivoInicial) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botón para volver al modo principal
        _buildActionCard(
          icon: Icons.arrow_back,
          title: 'Volver al Escaneo',
          subtitle: 'Regresar al modo principal',
          color: Colors.grey,
          onTap: _alternarModoGestion,
        ),
        
        const SizedBox(height: 20),
        
        // Cargar Archivo INICIAL (solo si no hay archivo inicial)
        if (!tieneArchivoInicial)
          _buildActionCard(
            icon: Icons.upload_file,
            title: 'Cargar Archivo Inicial',
            subtitle: 'Primer y único archivo base',
            color: Colors.blue,
            onTap: _cargarArchivoInicial,
          ),
        
        if (!tieneArchivoInicial) const SizedBox(height: 20),
        
        // Fusionar Archivo (solo si hay archivo inicial)
        if (tieneArchivoInicial)
          _buildActionCard(
            icon: Icons.merge,
            title: 'Fusionar Archivo',
            subtitle: 'Agregar archivos adicionales',
            color: Colors.purple,
            onTap: _fusionarArchivo,
          ),
        
        if (tieneArchivoInicial) const SizedBox(height: 20),
        
        // Ver Lista (solo si hay productos)
        if (productos.isNotEmpty)
          _buildActionCard(
            icon: Icons.list_alt,
            title: 'Ver Lista Completa',
            subtitle: 'Con filtros y ordenamiento',
            color: Colors.indigo,
            onTap: _verLista,
          ),
        
        if (productos.isNotEmpty) const SizedBox(height: 20),

        // Limpiar Todo (solo si hay productos)
        if (productos.isNotEmpty)
          _buildActionCard(
            icon: Icons.delete_sweep,
            title: 'Limpiar Todo',
            subtitle: 'Eliminar todos los archivos',
            color: Colors.red,
            onTap: _limpiarTodo,
          ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}