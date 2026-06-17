import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';

class ProductDetailPage extends StatelessWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  Widget _buildProductImage(String? imageStr) {
    if (imageStr == null || imageStr.isEmpty || imageStr.toLowerCase() == 'null') {
      return Container(
        height: 180.h,
        color: Colors.grey[100],
        child: Icon(Icons.medication_outlined, size: 70.sp, color: Colors.grey[400]),
      );
    }

    if (imageStr.contains('base64,')) {
      try {
        final base64Str = imageStr.split('base64,').last;
        return Container(
          height: 180.h,
          padding: EdgeInsets.all(10.w),
          child: Image.memory(
            base64Decode(base64Str),
            fit: BoxFit.contain,
          ),
        );
      } catch (_) {}
    }

    if (imageStr.startsWith('http')) {
      return Container(
        height: 180.h,
        padding: EdgeInsets.all(10.w),
        child: Image.network(
          imageStr,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.medication_outlined, size: 70.sp, color: Colors.grey[400]);
          },
        ),
      );
    }

    return Container(
      height: 180.h,
      color: Colors.grey[100],
      child: Icon(Icons.medication_outlined, size: 70.sp, color: Colors.grey[400]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Detalle de Producto",
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          children: [
            // Cabecera con Imagen y Nombre
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildProductImage(product.imagen),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.h, left: 16.w, right: 16.w),
                    child: Column(
                      children: [
                        Text(
                          product.nombre.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          "Laboratorio: ${product.laboratorio}",
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey[500], fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Tarjeta de Control Sanitario y Fórmula (Se adapta si es medicamento)
            _buildSection(
              title: "Control de Distribución",
              items: [
                if (product.esMedicamento)
                  _buildControlTile(
                    product.requiereFormula ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                    product.requiereFormula ? "Requiere Fórmula Médica" : "Venta Libre",
                    product.requiereFormula ? "Medicamento bajo prescripción profesional obligatoria." : "Disponible para venta directa sin receta.",
                    product.requiereFormula ? Colors.red : Colors.green,
                  )
                else
                  _buildControlTile(
                    Icons.shopping_bag_outlined,
                    "Venta General",
                    "No requiere receta médica ni control especial.",
                    Colors.blue,
                  ),
                _buildControlTile(
                  Icons.inventory_2_outlined,
                  "Control de Inventario",
                  "${product.stock} unidades disponibles",
                  product.stock < 15 ? Colors.orange : Colors.indigo,
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Ficha Técnica de Composición (Solo visible si es medicamento)
            if (product.esMedicamento) ...[
              _buildSection(
                title: "Ficha Técnica y Composición",
                items: [
                  _buildDetailTile(Icons.biotech_outlined, "Composición (Principio Activo)", product.composicion),
                  _buildDetailTile(Icons.opacity_outlined, "Concentración", product.concentracion),
                  _buildDetailTile(Icons.layers_outlined, "Presentación", product.presentacion),
                  _buildDetailTile(Icons.input_outlined, "Vía de Administración", product.viaAdministracion),
                  _buildDetailTile(
                    Icons.gavel_outlined, 
                    "Registro Sanitario", 
                    product.registroSanitario != null && product.registroSanitario != 'NULL' 
                        ? product.registroSanitario! 
                        : 'No registrado'
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],

            // Tarjeta Comercial
            _buildSection(
              title: "Precios y Clasificación",
              items: [
                _buildDetailTile(
                  Icons.attach_money_outlined,
                  "Precio de Venta",
                  "\$${product.precio.toStringAsFixed(0)}",
                  textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
                _buildDetailTile(Icons.category_outlined, "Categoría de Producto", product.categoria),
              ],
            ),
            SizedBox(height: 20.h),

            // Datos de identificación al pie de página
            Text(
              "ID Producto: #${product.id}",
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  // Estructura contenedora para cada tarjeta de sección
  Widget _buildSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 5.w, bottom: 8.h),
          child: Text(
            title,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
        ),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              if (index == items.length - 1) return items[index];
              return Column(
                children: [
                  items[index],
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Divider(color: Colors.grey[100], height: 1),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  // Fila de datos estándar (Clave/Valor)
  Widget _buildDetailTile(IconData icon, String label, String value, {TextStyle? textStyle}) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo[300], size: 22.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: textStyle ?? TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Tarjeta de control (Para advertencias prioritarias como Stock y Receta)
  Widget _buildControlTile(IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}