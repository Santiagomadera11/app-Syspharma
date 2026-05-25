class ProductModel {
  final int id;
  final String nombre;
  final String laboratorio;
  final String categoria;
  final double precio;
  final int stock;
  final String? imagen;
  
  // Campo para saber si es un producto general o de farmacia
  final bool esMedicamento;

  // Campos de especificación médica (provenientes de "medicamento")
  final String composicion;
  final String concentracion;
  final String presentacion;
  final String viaAdministracion;
  final String? registroSanitario;
  final bool requiereFormula;

  ProductModel({
    required this.id,
    required this.nombre,
    required this.laboratorio,
    required this.categoria,
    required this.precio,
    required this.stock,
    this.imagen,
    required this.esMedicamento,
    required this.composicion,
    required this.concentracion,
    required this.presentacion,
    required this.viaAdministracion,
    this.registroSanitario,
    required this.requiereFormula,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['Id'] ?? 0;
    final precioValue = json['precio'] ?? json['Precio'] ?? 0;
    final stockValue = json['stock'] ?? json['Stock'] ?? 0;
    
    final esMedicamentoValue = json['esMedicamento'] ?? json['es_medicamento'] ?? false;
    final esMedicamento = esMedicamentoValue == true || esMedicamentoValue == 1;

    // Extraemos el objeto anidado "medicamento" de forma segura
    final medicamentoJson = json['medicamento'] as Map<String, dynamic>?;

    // Mapeo seguro de requiereFormula dentro del objeto anidado
    final requiereFormulaValue = medicamentoJson?['requiereFormula'] ?? 0;
    final requiereFormula = requiereFormulaValue == 1 || 
                           requiereFormulaValue == true || 
                           requiereFormulaValue.toString() == "1";

    return ProductModel(
      id: idValue is int ? idValue : int.tryParse(idValue?.toString() ?? '') ?? 0,
      nombre: json['nombre'] ?? json['Nombre'] ?? 'Sin nombre',
      laboratorio: json['proveedorNombre'] ?? json['laboratorio'] ?? json['ProveedorNombre'] ?? 'Genérico',
      categoria: json['categoriaNombre'] ?? json['categoria'] ?? json['CategoriaNombre'] ?? 'General',
      precio: precioValue is String
          ? double.tryParse(precioValue) ?? 0.0
          : (precioValue is num ? precioValue.toDouble() : 0.0),
      stock: stockValue is int
          ? stockValue
          : int.tryParse(stockValue?.toString() ?? '') ?? 0,
      imagen: json['imagen'] ?? json['imagenUrl'] ?? json['image'] ?? json['Image'],
      esMedicamento: esMedicamento,
      
      // Mapeo seguro accediendo al objeto "medicamento" anidado [1]
      composicion: medicamentoJson?['composicion'] ?? 'No especificada',
      concentracion: medicamentoJson?['concentracion'] ?? 'No especificada',
      presentacion: medicamentoJson?['presentacion'] ?? 'No especificada',
      viaAdministracion: medicamentoJson?['viaAdministracion'] ?? 'No especificada',
      registroSanitario: medicamentoJson?['registroSanitario'] ?? medicamentoJson?['registro_sanitario'],
      requiereFormula: requiereFormula,
    );
  }
}