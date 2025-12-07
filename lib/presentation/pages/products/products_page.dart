import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  // CAMBIO IMPORTANTE: Inicia en -1 para mostrar TODOS al principio
  // -1: Todos, 0: Bajo Stock, 1: Más Vendidos
  int _selectedTab = -1; 
  
  final TextEditingController _searchController = TextEditingController();
  
  // DATOS MOCK
  final List<Map<String, dynamic>> _allProducts = [
    {'id': 1, 'name': 'Paracetamol 500mg', 'lab': 'Genéricos', 'price': 5.99, 'stock': 'low'},
    {'id': 2, 'name': 'Ibuprofeno 200mg', 'lab': 'Pfizer', 'price': 7.50, 'stock': 'high'},
    {'id': 3, 'name': 'Aspirina 100mg', 'lab': 'Bayer', 'price': 4.25, 'stock': 'low'},
    {'id': 4, 'name': 'Tylenol 500mg', 'lab': 'Johnson & Johnson', 'price': 6.75, 'stock': 'high'},
    {'id': 5, 'name': 'Amoxicilina 500mg', 'lab': 'Genéricos', 'price': 12.50, 'stock': 'low'},
    {'id': 6, 'name': 'Loratadina 10mg', 'lab': 'Mk', 'price': 3.99, 'stock': 'high'},
    {'id': 7, 'name': 'Omeprazol 20mg', 'lab': 'Genéricos', 'price': 8.50, 'stock': 'low'},
    {'id': 8, 'name': 'Vitamina C', 'lab': 'MK', 'price': 15.00, 'stock': 'high'},
  ];

  List<Map<String, dynamic>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filterProducts(); // Al iniciar, carga TODOS (-1)
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _filterProducts();
  }

  void _filterProducts() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      
      _filteredProducts = _allProducts.where((product) {
        // 1. Filtro de Texto (Buscador)
        final matchesSearch = product['name'].toLowerCase().contains(query) || 
                              product['lab'].toLowerCase().contains(query);
        
        // 2. Filtro de Tab
        bool matchesTab = true;
        
        if (_selectedTab == -1) {
          matchesTab = true; // Si es -1, mostramos TODO
        } else if (_selectedTab == 0) {
          matchesTab = product['stock'] == 'low';
        } else if (_selectedTab == 1) {
          matchesTab = product['stock'] == 'high';
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
      body: SafeArea(
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
          // Si toco el que ya está activo, lo desactivo (vuelvo a ver todos)
          // Si toco uno nuevo, lo activo.
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
          // Si está seleccionado: Fondo verde clarito. Si no: Blanco.
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            // Si está seleccionado: Borde verde. Si no: Transparente (o gris muy suave)
            color: isSelected ? AppColors.primary : Colors.transparent, 
            width: 1.5
          ),
          boxShadow: isSelected 
            ? [] 
            : [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5)],
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

  Widget _buildProductItem(Map<String, dynamic> product) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
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
            child: Icon(Icons.medication, color: Colors.grey[700]),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  product['lab'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "\$${product['price']}",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}