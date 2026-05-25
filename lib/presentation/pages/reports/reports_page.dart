import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../data/services/dashboard_service.dart';
import '../../../data/models/dashboard_models.dart';
import '../../../data/models/report_models.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final DashboardService _service = DashboardService();
  bool _isLoading = true;
  String _selectedPeriod = 'Mes';

  List<VentaModel> _ventas = [];
  List<CitaModel> _citas = [];
  List<ChartData> _apptData = [];
  List<ChartData> _salesData = [];
  List<TopProductModel> _topProducts = [];

  @override
  void initState() {
    super.initState();
    _loadAllReports();
  }

  Future<void> _loadAllReports() async {
    try {
      final ventas = await _service.getVentas();
      final citas = await _service.getCitas();

      setState(() {
        _ventas = ventas;
        _citas = citas;
        _processData();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error cargando reportes: $e');
    }
  }

  void _processData() {
    final ahora = DateTime.now();
    List<VentaModel> ventasFiltradas = [];

    if (_selectedPeriod == 'Sem') {
      final haceUnaSemana = ahora.subtract(const Duration(days: 7));
      ventasFiltradas = _ventas.where((v) => v.fecha.isAfter(haceUnaSemana)).toList();
      _apptData = const [
        ChartData('Lun', 5),
        ChartData('Mar', 8),
        ChartData('Mie', 12),
        ChartData('Jue', 7),
        ChartData('Vie', 15),
        ChartData('Sab', 2),
      ];
    } else if (_selectedPeriod == 'Mes') {
      ventasFiltradas = _ventas.where((v) => v.fecha.month == ahora.month && v.fecha.year == ahora.year).toList();
      _apptData = const [
        ChartData('Sem 1', 20),
        ChartData('Sem 2', 35),
        ChartData('Sem 3', 15),
        ChartData('Sem 4', 40),
      ];
    } else {
      ventasFiltradas = _ventas.where((v) => v.fecha.year == ahora.year).toList();
      _apptData = const [
        ChartData('Trim 1', 120),
        ChartData('Trim 2', 150),
        ChartData('Trim 3', 90),
        ChartData('Trim 4', 200),
      ];
    }

    _salesData = ventasFiltradas
        .map((v) => ChartData('${v.fecha.day}/${v.fecha.month}', v.total))
        .toList();

    final Map<String, int> conteo = {};
    for (var venta in ventasFiltradas) {
      for (var detalle in venta.detalles) {
        conteo[detalle.nombre] = (conteo[detalle.nombre] ?? 0) + detalle.cantidad;
      }
    }

    final sorted = conteo.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();

    if (top5.isNotEmpty) {
      final max = top5.first.value;
      _topProducts = top5
          .map((e) => TopProductModel(
                nombre: e.key,
                cantidad: e.value,
                porcentaje: max > 0 ? e.value / max : 0.0,
              ))
          .toList();
    } else {
      _topProducts = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Reportes Generales',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppointmentStatsCard(),
            SizedBox(height: 25.h),
            Text('Ventas Diarias', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 15.h),
            _buildDailySalesChart(),
            SizedBox(height: 25.h),
            Text('Top 5 Productos', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 15.h),
            _buildTopProductsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentStatsCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estadística de Citas', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildPeriodSelector(),
            ],
          ),
          SizedBox(height: 15.h),
          Text(_citas.length.toString(), style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold)),
          Text(
            '+12% vs mes pas.',
            style: TextStyle(color: Colors.green, fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 200.h,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: const CategoryAxis(majorGridLines: MajorGridLines(width: 0)),
              primaryYAxis: const NumericAxis(isVisible: false),
              series: <CartesianSeries>[
                ColumnSeries<ChartData, String>(
                  dataSource: _apptData,
                  xValueMapper: (data, _) => data.x,
                  yValueMapper: (data, _) => data.y,
                  color: const Color(0xFF00C4B4),
                  borderRadius: BorderRadius.circular(8),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDailySalesChart() {
    return Container(
      height: 180.h,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: const CategoryAxis(isVisible: false),
        primaryYAxis: const NumericAxis(isVisible: false),
        series: <CartesianSeries>[
          SplineAreaSeries<ChartData, String>(
            dataSource: _salesData,
            xValueMapper: (data, _) => data.x,
            yValueMapper: (data, _) => data.y,
            gradient: LinearGradient(
              colors: [const Color(0xFF00C4B4).withValues(alpha: 0.3), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderColor: const Color(0xFF00C4B4),
            borderWidth: 2,
          )
        ],
      ),
    );
  }

  Widget _buildTopProductsList() {
    if (_topProducts.isEmpty) {
      return const Center(child: Text('Aún no hay ventas registradas'));
    }

    return Column(
      children: _topProducts.map((p) => Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.nombre, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
            SizedBox(height: 8.h),
            Stack(
              children: [
                Container(
                  height: 10.h,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                ),
                FractionallySizedBox(
                  widthFactor: p.porcentaje,
                  child: Container(
                    height: 10.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF00C4B4), Color(0xFF00E5D5)]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: ['Sem', 'Mes', 'Año'].map((p) => GestureDetector(
          onTap: () {
            setState(() {
              _selectedPeriod = p;
              _processData();
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _selectedPeriod == p ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: _selectedPeriod == p ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)] : null,
            ),
            child: Text(
              p,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: _selectedPeriod == p ? Colors.black : Colors.grey,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }
}

class ChartData {
  final String x;
  final double y;
  const ChartData(this.x, this.y);
}
