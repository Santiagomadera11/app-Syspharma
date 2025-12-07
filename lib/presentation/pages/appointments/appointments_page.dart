import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../core/constants/app_colors.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  DateTime _selectedDate = DateTime.now();

  // DATOS MOCK: Simulamos citas para hoy y mañana
  late List<AppointmentModel> _allAppointments;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    // Creamos citas de ejemplo
    _allAppointments = [
      AppointmentModel(
        date: today,
        time: "10:00 AM",
        patientName: "Isabella Rodriguez",
        type: "Consulta General",
        status: "Confirmada",
      ),
      AppointmentModel(
        date: today,
        time: "11:30 AM",
        patientName: "Mateo Hernandez",
        type: "Vacunación",
        status: "Pendiente",
      ),
      AppointmentModel(
        date: today,
        time: "02:00 PM",
        patientName: "Camila Torres",
        timeEnd: "02:30 PM",
        type: "Revisión de Medicamentos",
        status: "Confirmada",
      ),
      AppointmentModel(
        date: today,
        time: "03:30 PM",
        patientName: "Diego Lopez",
        type: "Consulta de Seguimiento",
        status: "Cancelada",
      ),
      // Cita para mañana
      AppointmentModel(
        date: today.add(const Duration(days: 1)),
        time: "09:00 AM",
        patientName: "Valentina Gomez",
        type: "Consulta General",
        status: "Confirmada",
      ),
    ];
  }

  // Filtramos la lista según el día seleccionado en el calendario
  List<AppointmentModel> get _filteredAppointments {
    return _allAppointments.where((appt) {
      return appt.date.year == _selectedDate.year &&
             appt.date.month == _selectedDate.month &&
             appt.date.day == _selectedDate.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. CALENDARIO SUPERIOR
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                ]
              ),
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Calendario de Citas", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15.h),
                  
                  // WIDGET DE SYNCFUSION
                  SizedBox(
                    height: 280.h, // Altura fija para el calendario
                    child: SfCalendar(
                      view: CalendarView.month,
                      todayHighlightColor: AppColors.primary,
                      selectionDecoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: AppColors.primary, width: 2),
                        shape: BoxShape.circle,
                      ),
                      headerStyle: CalendarHeaderStyle(
                        textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      viewHeaderStyle: ViewHeaderStyle(
                        dayTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
                      ),
                      monthViewSettings: const MonthViewSettings(
                        appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                        showAgenda: false,
                      ),
                      // EVENTO: Cuando tocas un día
                      onSelectionChanged: (CalendarSelectionDetails details) {
                        if (details.date != null) {
                          setState(() {
                            _selectedDate = details.date!;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 2. LISTA DE CITAS DEL DÍA
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Citas del ${_selectedDate.day}/${_selectedDate.month}", 
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${_filteredAppointments.length} Citas",
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12.sp),
                          ),
                        )
                      ],
                    ),
                    
                    SizedBox(height: 15.h),

                    // LISTVIEW
                    Expanded(
                      child: _filteredAppointments.isEmpty 
                        ? _buildEmptyState()
                        : ListView.separated(
                            itemCount: _filteredAppointments.length,
                            separatorBuilder: (c, i) => SizedBox(height: 15.h),
                            padding: EdgeInsets.only(bottom: 20.h),
                            itemBuilder: (context, index) {
                              return _buildAppointmentCard(_filteredAppointments[index]);
                            },
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET: Tarjeta de Cita Individual
  Widget _buildAppointmentCard(AppointmentModel appt) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: AppColors.primary, width: 4.w), // Línea verde a la izquierda
        ),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ]
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HORA
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appt.time, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black)),
                  Text("AM", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                ],
              ),
              SizedBox(width: 15.w),
              
              // SEPARADOR VERTICAL
              Container(height: 40.h, width: 1, color: Colors.grey[200]),
              SizedBox(width: 15.w),

              // INFO PACIENTE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appt.type, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    SizedBox(height: 4.h),
                    Text("Paciente: ${appt.patientName}", style: TextStyle(fontSize: 14.sp, color: Colors.black87)),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 15.h),
          Divider(color: Colors.grey[100]),
          SizedBox(height: 5.h),

          // BOTONES DE ACCIÓN (Llamar / WhatsApp)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text("Llamar"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.message, size: 18, color: Colors.white),
                  label: const Text("WhatsApp", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366), // Color oficial WhatsApp
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // WIDGET: Estado Vacío (Sin citas)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available_outlined, size: 60.sp, color: Colors.grey[300]),
          SizedBox(height: 10.h),
          Text(
            "No hay citas para este día",
            style: TextStyle(color: Colors.grey[500], fontSize: 16.sp),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("Agendar Nueva Cita", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}

// Modelo local para esta pantalla
class AppointmentModel {
  final DateTime date;
  final String time;
  final String? timeEnd;
  final String patientName;
  final String type;
  final String status;

  AppointmentModel({
    required this.date,
    required this.time,
    this.timeEnd,
    required this.patientName,
    required this.type,
    required this.status,
  });
}