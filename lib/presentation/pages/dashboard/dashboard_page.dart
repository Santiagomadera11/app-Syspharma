import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Obtenemos el nombre del usuario logueado o un default
        final userName = (state is Authenticated) ? state.user.name : "Usuario";
        
        return Scaffold(
          backgroundColor: AppColors.background, // Fondo suave
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HEADER (Saludo y Notificación)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hola ${userName.split(' ')[0]}", 
                            style: TextStyle(
                              fontSize: 24.sp, 
                              fontWeight: FontWeight.bold,
                              color: Colors.black87
                            )
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Resumen de hoy", 
                            style: TextStyle(
                              fontSize: 14.sp, 
                              color: Colors.grey[600]
                            )
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                          ]
                        ),
                        child: Icon(Icons.notifications_outlined, size: 24.sp, color: Colors.black87),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 25.h),
                  
                  // 2. FILA DE TARJETAS (Una al lado de la otra)
                  Row(
                    children: [
                      // TARJETA 1: VENTAS
                      Expanded(
                        child: _buildSummaryCard(
                          title: "Ventas del día",
                          value: "\$12.3M",
                          color: const Color(0xFFE0F7FA), // Cyan Pastel
                          imagePath: 'assets/images/woman_pharmacist.png',
                        ),
                      ),
                      
                      // Espacio separador
                      SizedBox(width: 16.w), 

                      // TARJETA 2: CITAS
                      Expanded(
                        child: _buildSummaryCard(
                          title: "Citas Agendadas",
                          value: "05",
                          isAppointment: true,
                          color: const Color(0xFFE8F5E9), // Verde Pastel
                          imagePath: 'assets/images/man_pharmacist.png',
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 30.h),
                  
                  // 3. SECCIÓN DE ESTADÍSTICAS (Texto + Gráfico)
                  Text(
                    "Citas por mes", 
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Text(
                        "578", 
                        style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.black)
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Text(
                          "+10% vs mes anterior", 
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 12.sp)
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // 4. GRÁFICO SYNCFUSION
                  Container(
                    height: 250.h,
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                      ]
                    ),
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      primaryXAxis: const CategoryAxis(
                        majorGridLines: MajorGridLines(width: 0),
                        axisLine: AxisLine(width: 0),
                      ),
                      primaryYAxis: const NumericAxis(
                        isVisible: false,
                        minimum: 0, 
                        maximum: 40,
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries>[
                        SplineSeries<ChartData, String>(
                          dataSource: const [
                            ChartData('ENE', 10),
                            ChartData('FEB', 28),
                            ChartData('MAR', 15),
                            ChartData('ABR', 32),
                            ChartData('MAY', 20),
                            ChartData('JUN', 35),
                          ],
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          color: AppColors.primary,
                          width: 4,
                          markerSettings: const MarkerSettings(isVisible: true),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // WIDGET DE TARJETA (CON FIX DE OVERFLOW)
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color,
    required String imagePath,
    bool isAppointment = false,
  }) {
    return Container(
      height: 180.h, // Altura fija
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // IMAGEN (Arriba y centrada)
          Expanded(
            flex: 3,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                isAppointment ? Icons.calendar_month : Icons.storefront,
                size: 50.sp,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
          ),
          
          SizedBox(height: 10.h),

          // INFO Y BOTÓN (Abajo)
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 1. Textos a la izquierda (CORREGIDO: Usamos Expanded aquí)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1, // Evita saltos de línea feos
                        overflow: TextOverflow.ellipsis, // Pone "..." si no cabe
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      // FittedBox reduce el tamaño de la letra si el número es muy grande
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Espacio seguro entre texto y botón
                SizedBox(width: 8.w),

                // 2. Botón circular a la derecha
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2)
                      )
                    ]
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Modelo de datos para el gráfico
class ChartData {
  final String x;
  final double y;
  const ChartData(this.x, this.y);
}