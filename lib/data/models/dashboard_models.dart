class VentaModel {
  final double total;
  final DateTime fecha;
  final List<VentaDetalleModel> detalles;

  VentaModel({required this.total, required this.fecha, required this.detalles});

  factory VentaModel.fromJson(Map<String, dynamic> json) {
    final dynamic totalValue = json['total'] ?? json['Total'] ?? 0;
    final total = (totalValue is String)
        ? double.tryParse(totalValue) ?? 0
        : (totalValue is num ? totalValue.toDouble() : 0.0);

    final fechaString = json['fechaVenta'] ?? json['fechaCreacion'] ?? json['Fecha'] ?? json['fecha'] ?? '';
    DateTime fecha;
    if (fechaString is String && fechaString.isNotEmpty) {
      fecha = DateTime.tryParse(fechaString) ?? DateTime.now();
    } else if (fechaString is DateTime) {
      fecha = fechaString;
    } else {
      fecha = DateTime.now();
    }

    final list = json['detalles'] as List? ?? [];
    final detallesList = list
        .map((item) => VentaDetalleModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return VentaModel(total: total, fecha: fecha, detalles: detallesList);
  }
}

class VentaDetalleModel {
  final String nombre;
  final int cantidad;

  VentaDetalleModel({required this.nombre, required this.cantidad});

  factory VentaDetalleModel.fromJson(Map<String, dynamic> json) {
    final cantidadValue = json['cantidad'] ?? json['Cantidad'] ?? 0;
    return VentaDetalleModel(
      nombre: json['productoNombre'] ?? json['producto'] ?? json['producto_nombre'] ?? 'Producto',
      cantidad: cantidadValue is int
          ? cantidadValue
          : int.tryParse(cantidadValue?.toString() ?? '') ?? 0,
    );
  }
}

class CitaModel {
  final int id;

  CitaModel({required this.id});

  factory CitaModel.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['Id'] ?? 0;
    final id = (idValue is int)
        ? idValue
        : int.tryParse(idValue?.toString() ?? '') ?? 0;
    return CitaModel(id: id);
  }
}
