class Producto {
  final String serie;
  final String sku;
  final String descripcion;
  final String negocio;
  final String depto;
  final String linea;
  final String temporada;
  final double precioAnterior;
  final double precioActualizado;
  final String fuente;

  Producto({
    required this.serie,
    required this.sku,
    required this.descripcion,
    required this.negocio,
    required this.depto,
    required this.linea,
    required this.temporada,
    required this.precioAnterior,
    required this.precioActualizado,
    required this.fuente,
  });

  String get clave => sku.length >= 9 ? sku.substring(0, 9) : sku;

  // Método para crear copia (útil para fusionar)
  Producto copyWith({
    double? precioActualizado,
    String? fuente,
  }) {
    return Producto(
      serie: serie,
      sku: sku,
      descripcion: descripcion,
      negocio: negocio,
      depto: depto,
      linea: linea,
      temporada: temporada,
      precioAnterior: precioAnterior,
      precioActualizado: precioActualizado ?? this.precioActualizado,
      fuente: fuente ?? this.fuente,
    );
  }

  // Calcular diferencia de precio
  double get diferenciaPrecio => precioActualizado - precioAnterior;
  double get porcentajeCambio => precioAnterior > 0 
      ? ((precioActualizado - precioAnterior) / precioAnterior) * 100 
      : 0;
}