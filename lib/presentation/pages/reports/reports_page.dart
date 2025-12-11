import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../core/constants/app_colors.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  // 0: Semanal, 1: Mensual, 2: Anual
  int _selectedTimeRange = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: _buildReportsContent(),
        ),
      ),
    );
  }


  Widget _buildReportsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Reportes Generales",
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 20.h),

        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),

            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- FILA 1: CABECERA (Título + Selector) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Estadística de Citas",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Selector (Sem / Mes / Año)
                  _buildTimeSelector(),
                ],
              ),

              SizedBox(height: 20.h),


              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _getCitasValue(),
                    style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getCitasGrowth(),
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),


              SizedBox(
                height: 180.h,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: const AxisLine(width: 0),
                    labelStyle: TextStyle(fontSize: 10.sp, color: Colors.grey),
                  ),
                  primaryYAxis: const NumericAxis(isVisible: false),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries>[
                    ColumnSeries<ChartData, String>(
                      dataSource: _getChartData(),
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                      color: AppColors.primary,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(6)),
                      width: 0.6,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 30.h),

        // 2. VENTAS DIARIAS (Gráfico de ondas)
        Text("Ventas Diarias",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 10.h),
        SizedBox(
          height: 150.h,
          child: SfCartesianChart(
            plotAreaBorderWidth: 0,
            primaryXAxis: const CategoryAxis(isVisible: false),
            primaryYAxis: const NumericAxis(isVisible: false),
            series: <CartesianSeries>[
              SplineAreaSeries<ChartData, String>(
                dataSource: const [
                  ChartData('Lun', 20),
                  ChartData('Mar', 40),
                  ChartData('Mie', 35),
                  ChartData('Jue', 55),
                  ChartData('Vie', 45),
                  ChartData('Sab', 70),
                  ChartData('Dom', 60),
                ],
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.5),
                    AppColors.primary.withValues(alpha: 0.0)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderColor: AppColors.primary,
                borderWidth: 3,
              )
            ],
          ),
        ),

        SizedBox(height: 30.h),

        // 3. TOP PRODUCTOS
        Text("Top 5 Productos",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 20.h),
        _buildProductBar("Paracetamol 500mg", 0.9),
        _buildProductBar("Ibuprofeno 200mg", 0.7),
        _buildProductBar("Dolex Forte", 0.5),
        _buildProductBar("Aspirina", 0.3),
        _buildProductBar("Vitamina C", 0.2),

        SizedBox(height: 40.h),
      ],
    );
  }



  Widget _buildTimeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildOptionBtn("Sem", 0),
          _buildOptionBtn("Mes", 1),
          _buildOptionBtn("Año", 2),
        ],
      ),
    );
  }

  Widget _buildOptionBtn(String text, int index) {
    bool isSelected = _selectedTimeRange == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTimeRange = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  String _getCitasValue() {
    switch (_selectedTimeRange) {
      case 0:
        return "42";
      case 1:
        return "185";
      case 2:
        return "2,450";
      default:
        return "0";
    }
  }

  String _getCitasGrowth() {
    switch (_selectedTimeRange) {
      case 0:
        return "+5% vs semana pas.";
      case 1:
        return "+12% vs mes pas.";
      case 2:
        return "+24% vs año pas.";
      default:
        return "";
    }
  }

  List<ChartData> _getChartData() {
    switch (_selectedTimeRange) {
      case 0: // Semanal
        return const [
          ChartData('Lun', 5),
          ChartData('Mar', 8),
          ChartData('Mie', 4),
          ChartData('Jue', 10),
          ChartData('Vie', 12),
          ChartData('Sab', 3),
        ];
      case 1: // Mensual
        return const [
          ChartData('Sem 1', 35),
          ChartData('Sem 2', 42),
          ChartData('Sem 3', 28),
          ChartData('Sem 4', 55),
        ];
      case 2: // Anual
        return const [
          ChartData('Ene', 150),
          ChartData('Feb', 180),
          ChartData('Mar', 120),
          ChartData('Abr', 210),
          ChartData('May', 190),
          ChartData('Jun', 240),
        ];
      default:
        return [];
    }
  }

  Widget _buildProductBar(String name, double percent) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Row(
        children: [
          SizedBox(
              width: 100.w,
              child: Text(name,
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600]))),
          Expanded(
            child: Container(
              height: 10.h,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(5)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percent,
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(5)),
                ),
              ),
            ),
          ),
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