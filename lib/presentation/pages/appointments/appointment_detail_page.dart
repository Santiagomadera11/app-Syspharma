import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/appointment_model.dart';

class AppointmentDetailPage extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentDetailPage({super.key, required this.appointment});

  Color _getEstadoColor(String estado) {
    final status = estado.toLowerCase();
    if (status.contains('confirm') || status.contains('atendid')) {
      return Colors.green;
    } else if (status.contains('pendient')) {
      return Colors.orange;
    } else if (status.contains('cancel')) {
      return Colors.red;
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Detalle de la Cita",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
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
            // Cabecera principal (Estado e ID de la Cita)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      // REEMPLAZADO: de .withOpacity(0.1) a .withValues(alpha: 0.1)
                      color: _getEstadoColor(appointment.estado).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      appointment.estado,
                      style: TextStyle(
                        color: _getEstadoColor(appointment.estado),
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    appointment.servicioNombre,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "Cita #${appointment.id}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Sección 1: Información del Paciente
            _buildSection(
              title: "Información del Paciente",
              items: [
                _buildDetailTile(Icons.person_outline, "Nombre", appointment.pacienteNombre),
                _buildDetailTile(Icons.badge_outlined, "Documento", appointment.pacienteDocumento),
                _buildDetailTile(
                  Icons.phone_outlined, 
                  "Teléfono", 
                  appointment.telefono,
                  action: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone, color: Colors.green, size: 18),
                  ),
                ),
                _buildDetailTile(Icons.email_outlined, "Correo electrónico", appointment.pacienteEmail),
              ],
            ),
            SizedBox(height: 20.h),

            // Sección 2: Datos de Agenda
            _buildSection(
              title: "Datos del Agendamiento",
              items: [
                _buildDetailTile(Icons.calendar_today_outlined, "Fecha", appointment.fecha),
                _buildDetailTile(Icons.access_time_outlined, "Hora de atención", "${appointment.hora} ${appointment.periodo}"),
                _buildDetailTile(
                  Icons.attach_money_outlined, 
                  "Precio del servicio", 
                  "\$${appointment.precio.toStringAsFixed(0)}",
                  textStyle: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  )
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Sección 3: Notas / Observaciones
            if (appointment.notas.isNotEmpty)
              _buildSection(
                title: "Notas e Indicaciones",
                items: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.sticky_note_2_outlined, color: Colors.amber, size: 22),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            appointment.notas,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[800],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            SizedBox(height: 20.h),

            // Datos de auditoría técnica en la parte inferior
            Text(
              "Médico ID: ${appointment.medicoId}  •  Usuario Registro: ${appointment.usuarioId}",
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[400]),
            ),
            if (appointment.fechaCreacion.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                "Creado el: ${appointment.fechaCreacion}",
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[400]),
              ),
            ],
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
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
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

  // Fila de datos individuales con su etiqueta e icono correspondiente
  Widget _buildDetailTile(IconData icon, String label, String value, {Widget? action, TextStyle? textStyle}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[400], size: 22.sp),
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
                style: textStyle ?? TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        if (action != null) action,
      ],
    );
  }
}