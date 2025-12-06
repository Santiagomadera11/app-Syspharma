import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Obtenemos el nombre del usuario logueado
        final userName = (state is Authenticated) ? state.user.name : "Usuario";
        
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saludo + Notificaciones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Hola ${userName.split(' ')[0]}",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Icon(Icons.notifications_none, size: 28.sp),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // -----------------------------
                  // TARJETA: VENTAS DEL DÍA
                  // -----------------------------
                  _buildSummaryCard(
                    title: "Ventas del día",
                    value: "\$12.345.678",
                    color: const Color(0xFFE0F7FA),
                    imagePath: 'assets/images/woman_pharmacist.png',
                  ),

                  SizedBox(height: 16.h),

                  // -----------------------------
                  // TARJETA: CITAS AGENDADAS
                  // -----------------------------
                  _buildSummaryCard(
                    title: "Citas Agendadas",
                    value: "5",
                    isAppointment: true,
                    color: const Color(0xFFE8F5E9),
                    imagePath: 'assets/images/man_pharmacist.png',
                  ),

                  SizedBox(height: 30.h),

                  // -----------------------------
                  // SECCIÓN GRÁFICO
                  // -----------------------------
                  Text("Citas por mes",
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  Text("578",
                      style: TextStyle(
                          fontSize: 32.sp, fontWeight: FontWeight.bold)),
                  const Text("Hoy +10%",
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.w600)),
                  
                  SizedBox(height: 20.h),

                  SizedBox(
                    height: 200.h,
                    child: SfCartesianChart(
                      primaryXAxis: const CategoryAxis(),
                      series: <CartesianSeries>[
                        SplineSeries<ChartData, String>(
                          dataSource: [
                            ChartData('ENE', 10),
                            ChartData('FEB', 28),
                            ChartData('MAR', 15),
                            ChartData('MAY', 32),
                            ChartData('JUN', 20),
                          ],
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          color: AppColors.primary,
                          width: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // NUEVA TARJETA COMPLETA (MODIFICADA COMO PEDISTE)
  // ============================================================
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color,
    required String imagePath,
    bool isAppointment = false,
  }) {
    return Container(
      height: 200.h,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // IMAGEN CENTRADA ARRIBA
          Expanded(
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                isAppointment ? Icons.calendar_month : Icons.point_of_sale,
                size: 80.sp,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // INFORMACIÓN INFERIOR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // IZQUIERDA
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              // BOTÓN
              SizedBox(
                height: 32.h,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                  ),
                  child: Text(
                    "Ver detalles",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Datos del gráfico
class ChartData {
  final String x;
  final double y;
  ChartData(this.x, this.y);
}
