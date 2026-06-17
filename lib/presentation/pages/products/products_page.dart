import 'dart:convert'; // Importación para soportar decodificación Base64 en imágenes
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import 'product_detail_page.dart'; // Importación de la pantalla de detalle

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductService _service = ProductService();
  final TextEditingController _searchController = TextEditingController();
  final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

  int _selectedTab = -1; // -1: Todos, 0: Bajo stock, 1: Más vendidos
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _filterProducts();
  }

  Future<void> _loadProducts() async {
    final products = await _service.getAllProducts();
    setState(() {
      _allProducts = products;
      _filteredProducts = products;
      _isLoading = false;
    });
  }

  void _filterProducts() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredProducts = _allProducts.where((product) {
        final matchesSearch = product.nombre.toLowerCase().contains(query) ||
            product.laboratorio.toLowerCase().contains(query) ||
            product.categoria.toLowerCase().contains(query);

        bool matchesTab = true;
        if (_selectedTab == 0) {
          matchesTab = product.stock < 10;
        } else if (_selectedTab == 1) {
          matchesTab = product.stock >= 10;
        }
        return matchesSearch && matchesTab;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // HEADER Y FILTROS
                  Container(
                    padding: EdgeInsets.all(20.w),
                    color: AppColors.background,
                    child: Column(
                      children: [
                        Text("Productos", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 20.h),
                        
                        // Buscador
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Buscar medicamento...",
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.w),
                          ),
                        ),
                        
                        SizedBox(height: 20.h),
                        
                        // Botones de Filtro
                        Row(
                          children: [
                            Expanded(child: _buildTabButton("Bajo stock", 0)),
                            SizedBox(width: 15.w),
                            Expanded(child: _buildTabButton("Más vendidos", 1)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // LISTA DE RESULTADOS
                  Expanded(
                    child: _filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 50.sp, color: Colors.grey[400]),
                              SizedBox(height: 10.h),
                              Text("No se encontraron productos", style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                          itemCount: _filteredProducts.length,
                          separatorBuilder: (c, i) => SizedBox(height: 15.h),
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return _buildProductItem(product);
                          },
                        ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final bool isSelected = _selectedTab == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          // Lógica de "Toggle":
          if (_selectedTab == index) {
            _selectedTab = -1; // Volver a ver todos
          } else {
            _selectedTab = index;
          }
          _filterProducts();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent, 
            width: 1.5
          ),
          boxShadow: isSelected 
            ? [] 
            : [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 5)],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }

  // Descodificador para imágenes Base64 / Network seguro para evitar fallos de renderizado
  Widget _buildProductItemImage(String? imageStr) {
    if (imageStr == null || imageStr.isEmpty || imageStr.toLowerCase() == 'null') {
      return Icon(Icons.medication, color: Colors.grey[700]);
    }

    if (imageStr.contains('base64,')) {
      try {
        final base64Str = imageStr.split('base64,').last;
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            base64Decode(base64Str),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(Icons.medication, color: Colors.grey[700]),
          ),
        );
      } catch (_) {}
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageStr,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(Icons.medication, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildProductItem(ProductModel product) {
    return InkWell(
      onTap: () {
        // Navegación con push para ver el detalle del producto seleccionado
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildProductItemImage(product.imagen),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nombre,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    product.laboratorio,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "Stock: ${product.stock}",
                    style: TextStyle(
                      color: product.stock < 10 ? Colors.red : Colors.grey[600],
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              currencyFormat.format(product.precio),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}