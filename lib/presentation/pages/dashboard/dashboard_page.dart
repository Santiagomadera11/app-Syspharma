import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/user.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../../data/services/dashboard_service.dart';
import '../../../data/models/dashboard_models.dart';
import '../../../data/services/product_service.dart';
import '../../../data/services/appointment_service.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/appointment_model.dart';

// Modelo simple para manejar la lista de notificaciones
class AppNotification {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  AppNotification({required this.title, required this.message, required this.icon, required this.color});
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardService _service = DashboardService();
  final ProductService _productService = ProductService();
  final AppointmentService _appointmentService = AppointmentService();
  
  bool _isLoading = true;
  String _activePeriod = 'Mes'; // 'Sem' | 'Mes' | 'Año'
  
  double _displayTotal = 0;
  int _displayCitas = 0;
  
  List<VentaModel> _allVentas = [];
  List<AppointmentModel> _allAppts = [];
  List<ChartData> _chartData = [];
  final List<AppNotification> _realNotifications = [];
  
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final ventas = await _service.getVentas();
      final productos = await _productService.getAllProducts();
      final appts = await _appointmentService.getAppointments();

      _allVentas = ventas;
      _allAppts = appts;
      
      _generateNotifications(productos, appts);
      _updateDashboardByPeriod(_activePeriod);

    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error cargando API: $e');
    }
  }

  // Lógica para filtrar datos según el botón presionado (Semana, Mes, Año)
  void _updateDashboardByPeriod(String period) {
    DateTime now = DateTime.now();
    List<VentaModel> filteredVentas = [];
    
    if (period == 'Sem') {
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      filteredVentas = _allVentas.where((v) => v.fecha.isAfter(startOfWeek)).toList();
    } else if (period == 'Mes') {
      filteredVentas = _allVentas.where((v) => v.fecha.month == now.month && v.fecha.year == now.year).toList();
    } else { // Año
      filteredVentas = _allVentas.where((v) => v.fecha.year == now.year).toList();
    }

    setState(() {
      _activePeriod = period;
      _displayTotal = filteredVentas.fold(0.0, (prev, v) => prev + v.total);
      _displayCitas = _allAppts.where((a) => _isWithinPeriod(a.fecha, period)).length;
      _chartData = _generateChartData(filteredVentas, period);
      _isLoading = false;
    });
  }

  bool _isWithinPeriod(String dateStr, String period) {
    try {
      DateTime d = DateTime.parse(dateStr);
      DateTime now = DateTime.now();
      if (period == 'Sem') return d.isAfter(now.subtract(const Duration(days: 7)));
      if (period == 'Mes') return d.month == now.month;
      return d.year == now.year;
    } catch (_) { return false; }
  }

  List<ChartData> _generateChartData(List<VentaModel> ventas, String period) {
    if (period == 'Año') {
      // Agrupar por meses
      return List.generate(6, (i) {
        DateTime monthDate = DateTime(DateTime.now().year, DateTime.now().month - 5 + i, 1);
        double sum = ventas.where((v) => v.fecha.month == monthDate.month).fold(0, (p, c) => p + c.total);
        return ChartData(_getMesNombre(monthDate.month), sum);
      });
    } else {
      // Agrupar por días (últimos 6 puntos)
      return List.generate(6, (i) {
        DateTime dayDate = DateTime.now().subtract(Duration(days: 5 - i));
        double sum = ventas.where((v) => v.fecha.day == dayDate.day).fold(0, (p, c) => p + c.total);
        return ChartData("${dayDate.day}", sum);
      });
    }
  }

  String _getMesNombre(int mes) {
    const nombres = ['', 'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
    return nombres[mes];
  }

  void _generateNotifications(List<ProductModel> products, List<AppointmentModel> appts) {
    _realNotifications.clear();
    // 1. Stock Crítico
    for (var p in products.where((p) => p.stock == 0).take(3)) {
      _realNotifications.add(AppNotification(
        title: 'Stock Crítico: ${p.nombre}',
        message: 'Quedan 0 unidades. Reponer urgente.',
        icon: Icons.inventory_2_outlined, color: Colors.red,
      ));
    }
    // 2. Stock Bajo
    for (var p in products.where((p) => p.stock > 0 && p.stock < 10).take(2)) {
      _realNotifications.add(AppNotification(
        title: 'Stock Bajo: ${p.nombre}',
        message: 'Quedan ${p.stock} unidades.',
        icon: Icons.warning_amber_rounded, color: Colors.orange,
      ));
    }
    // 3. Cita hoy
    if (appts.isNotEmpty) {
      _realNotifications.add(AppNotification(
        title: 'Próxima Cita',
        message: '${appts.first.pacienteNombre} - ${appts.first.hora}',
        icon: Icons.calendar_today, color: AppColors.primary,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userName = 'Usuario';
        UserRole role = UserRole.employee;
        if (state is Authenticated) {
          userName = state.user.name;
          role = state.user.role;
        }

        if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, userName, role == UserRole.admin ? "Panel Gerencial" : "Resumen de hoy"),
                  SizedBox(height: 25.h),
                  
                  // Selector de Periodo (Sem, Mes, Año)
                  _buildPeriodSelector(),
                  
                  SizedBox(height: 15.h),
                  Row(
                    children: [
                      Expanded(child: _buildSummaryCard(
                        title: "Ventas ($_activePeriod)",
                        value: _currencyFormat.format(_displayTotal),
                        color: const Color(0xFFE0F7FA),
                        customIcon: Icons.storefront_outlined,
                        onTap: () => context.go('/reports'),
                      )),
                      SizedBox(width: 16.w),
                      Expanded(child: _buildSummaryCard(
                        title: "Citas ($_activePeriod)",
                        value: _displayCitas.toString().padLeft(2, '0'),
                        color: const Color(0xFFE8F5E9),
                        customIcon: Icons.calendar_month_outlined,
                        onTap: () => context.go('/appointments'),
                      )),
                    ],
                  ),
                  SizedBox(height: 30.h),
                  Text("Rendimiento de Ventas", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15.h),
                  _buildChartSection(_chartData),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Sem', 'Mes', 'Año'].map((p) {
          bool active = _activePeriod == p;
          return GestureDetector(
            onTap: () => _updateDashboardByPeriod(p),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: active ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: active ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)] : null,
              ),
              child: Text(p, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: active ? Colors.black : Colors.grey)),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Centro de Notificaciones", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 20.h),
              if (_realNotifications.isEmpty)
                const Padding(padding: EdgeInsets.all(20), child: Text("No hay alertas pendientes"))
              else
                ..._realNotifications.map((n) => _buildNotificationItem(
                  title: n.title, message: n.message, icon: n.icon, color: n.color
                )),
              SizedBox(height: 20.h),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")))
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String name, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hola ${name.split(' ')[0]}", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
            Text(subtitle, style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
          ],
        ),
        GestureDetector(
          onTap: () => _showNotificationsSheet(context),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Badge(
              label: Text(_realNotifications.length.toString()),
              isLabelVisible: _realNotifications.isNotEmpty,
              child: Icon(Icons.notifications_outlined, size: 24.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection(List<ChartData> data) {
    return Container(
      height: 250.h,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: SfCartesianChart(
        primaryXAxis: const CategoryAxis(majorGridLines: MajorGridLines(width: 0)),
        primaryYAxis: const NumericAxis(isVisible: false),
        series: <CartesianSeries>[
          SplineSeries<ChartData, String>(
            dataSource: data,
            xValueMapper: (ChartData d, _) => d.x,
            yValueMapper: (ChartData d, _) => d.y,
            color: AppColors.primary, width: 4,
            markerSettings: const MarkerSettings(isVisible: true),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required String value, required Color color, required IconData customIcon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(customIcon, size: 30.sp, color: AppColors.primary),
            SizedBox(height: 20.h),
            Text(title, style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
            Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({required String title, required String message, required IconData icon, required Color color}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 15.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(message, style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
            ],
          ))
        ],
      ),
    );
  }
}

class ChartData {
  final String x;
  final double y;
  const ChartData(this.x, this.y);
}