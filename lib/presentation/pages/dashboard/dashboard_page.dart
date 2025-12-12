import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/user.dart';
import '../../blocs/auth/auth_bloc.dart';
// ESTA ES LA LÍNEA QUE TE FALTA O ESTÁ FALLANDO:
import '../../blocs/auth/auth_state.dart';
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userName = "Usuario";
        UserRole role = UserRole.employee;

        if (state is Authenticated) {
          userName = state.user.name;
          role = state.user.role;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: role == UserRole.admin
                ? _buildAdminView(context, userName)
                : _buildEmployeeView(context, userName),
          ),
        );
      },
    );
  }


  Widget _buildEmployeeView(BuildContext context, String userName) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, userName, "Resumen de hoy", showBell: false),
          SizedBox(height: 25.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: "Ventas del día",
                  value: "\$12.3M",
                  color: const Color(0xFFE0F7FA),
                  imagePath: 'assets/images/woman_pharmacist.png',
                  customIcon: Icons.storefront_outlined,
                  onTap: () => context.go('/reports'),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildSummaryCard(
                  title: "Citas Agendadas",
                  value: "05",
                  isAppointment: true,
                  color: const Color(0xFFE8F5E9),
                  imagePath: 'assets/images/man_pharmacist.png',
                  customIcon: Icons.calendar_month_outlined,
                  onTap: () => context.go('/appointments'),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 30.h),
          
          Text("Ventas Mensuales",
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          SizedBox(height: 15.h),
          
          _buildChartSection(),
        ],
      ),
    );
  }


  Widget _buildAdminView(BuildContext context, String userName) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, userName, "Panel Gerencial", showBell: true),
          SizedBox(height: 25.h),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: "Ventas Totales",
                  value: "\$45.2M",
                  color: const Color(0xFFE0F7FA),
                  imagePath: 'assets/images/woman_pharmacist.png',
                  customIcon: Icons.storefront,
                  onTap: () => context.go('/reports'),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildSummaryCard(
                  title: "Citas",
                  value: "12",
                  isAppointment: true,
                  color: const Color(0xFFE8F5E9),
                  imagePath: 'assets/images/man_pharmacist.png',
                  customIcon: Icons.calendar_today,
                  onTap: () => context.go('/appointments'),
                ),
              ),
            ],
          ),

          SizedBox(height: 30.h),
          Text("Ventas Mensuales",
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          SizedBox(height: 15.h),
          _buildChartSection(),
        ],
      ),
    );
  }



  Widget _buildHeader(BuildContext context, String name, String subtitle, {required bool showBell}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hola ${name.split(' ')[0]}",
                style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            SizedBox(height: 4.h),
            Text(subtitle,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
          ],
        ),
        
        if (showBell)
          GestureDetector(
            onTap: () => _showNotificationsSheet(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10)
                  ]),
              child: Stack(
                children: [
                  Icon(Icons.notifications_outlined, size: 24.sp, color: Colors.black87),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5)
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
      ],
    );
  }

  // MODAL DE NOTIFICACIONES CORREGIDO (CON SCROLL)
  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Centro de Notificaciones", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text("3 Nuevas", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                    )
                  ],
                ),
                
                SizedBox(height: 15.h),
                
                _buildNotificationItem(
                  title: "Stock Crítico: Amoxicilina",
                  message: "Quedan 0 unidades. Reponer inmediatamente.",
                  icon: Icons.inventory_2_outlined,
                  color: Colors.red,
                ),
                
                _buildNotificationItem(
                  title: "Stock Bajo: Paracetamol",
                  message: "Quedan 5 unidades. Considerar reponer.",
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),
                
                _buildNotificationItem(
                  title: "Nueva Cita Agendada",
                  message: "Mateo Hernandez - Vacunación (11:30 AM)",
                  icon: Icons.calendar_today,
                  color: AppColors.primary,
                ),
                
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    child: const Text("Cerrar", style: TextStyle(color: Colors.black)),
                  ),
                ),
                
                // Espacio extra al final para seguridad
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem({
    required String title, 
    required String message, 
    required IconData icon, 
    required Color color
  }) {
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
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: Colors.black87)),
                SizedBox(height: 3.h),
                Text(message, style: TextStyle(color: Colors.grey[700], fontSize: 12.sp)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      height: 250.h,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ]),
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: const CategoryAxis(
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(width: 0)),
        primaryYAxis:
            const NumericAxis(isVisible: false),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries>[
          SplineSeries<ChartData, String>(
            dataSource: const [
              ChartData('ENE', 15500),
              ChartData('FEB', 28000),
              ChartData('MAR', 22400),
              ChartData('ABR', 32100),
              ChartData('MAY', 25000),
              ChartData('JUN', 45000),
            ],
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y,
            color: AppColors.primary,
            width: 4,
            markerSettings: const MarkerSettings(isVisible: true),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color,
    required String imagePath,
    bool isAppointment = false,
    double? height,
    IconData? customIcon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 210.h, 
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: _buildVerticalContent(title, value, imagePath, isAppointment, customIcon),
      ),
    );
  }

  Widget _buildVerticalContent(String title, String value, String imagePath,
      bool isAppointment, IconData? customIcon) {
    return Column(
      children: [
        Expanded(
          child: imagePath.isNotEmpty
              ? Image.asset(
                  imagePath, 
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      customIcon ?? (isAppointment ? Icons.calendar_month : Icons.storefront),
                      size: 60.sp,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    );
                  },
                )
              : Icon(customIcon ?? Icons.analytics,
                  size: 50.sp,
                  color: AppColors.primary.withValues(alpha: 0.5)),
        ),
        SizedBox(height: 12.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54)),
                  SizedBox(height: 4.h),
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(value,
                          style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87))),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            _buildArrowButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildArrowButton() {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2))
          ]),
      child: Icon(Icons.arrow_forward_rounded,
          size: 18.sp, color: AppColors.primary),
    );
  }
}

class ChartData {
  final String x;
  final double y;
  const ChartData(this.x, this.y);
}