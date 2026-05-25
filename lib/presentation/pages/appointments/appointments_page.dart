import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/services/appointment_service.dart';
import 'appointment_detail_page.dart'; // Importación de la vista de detalle

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final AppointmentService _service = AppointmentService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<AppointmentModel> _allAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    final appointments = await _service.getAppointments();
    setState(() {
      _allAppointments = appointments;
      _isLoading = false;
    });
  }

  List<AppointmentModel> _getEventsForDay(DateTime day) {
    return _allAppointments.where((appt) => isSameDay(appt.fechaAsDate, day)).toList();
  }

  List<AppointmentModel> get _selectedDayAppointments {
    return _getEventsForDay(_selectedDay!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Citas", 
          style: TextStyle(
            fontSize: 20.sp, 
            fontWeight: FontWeight.bold, 
            color: Colors.black
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.05), 
                          blurRadius: 20, 
                          offset: const Offset(0, 10)
                        )
                      ]
                    ),
                    padding: EdgeInsets.only(bottom: 20.h),
                    child: TableCalendar(
                      locale: 'es_ES', 
                      firstDay: DateTime.utc(2020, 10, 16),
                      lastDay: DateTime.utc(2030, 3, 14),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Mes',
                        CalendarFormat.twoWeeks: '2 Sem',
                        CalendarFormat.week: 'Semana',
                      },

                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },

                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      
                      eventLoader: _getEventsForDay,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      
                      headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: true,
                        formatButtonShowsNext: false,
                        formatButtonDecoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        formatButtonTextStyle: const TextStyle(
                          color: AppColors.primary, 
                          fontWeight: FontWeight.bold
                        ),
                        titleTextStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                        leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.primary),
                        rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.primary),
                      ),
                      
                      calendarStyle: CalendarStyle(
                        selectedDecoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 1.5),
                        ),
                        todayTextStyle: const TextStyle(
                          color: AppColors.primary, 
                          fontWeight: FontWeight.bold
                        ),
                        markerDecoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        markersMaxCount: 1,
                        markerSize: 6.0,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 25.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Agenda del día", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                              Text(
                                DateFormat('d MMMM, yyyy', 'es_ES').format(_selectedDay!), 
                                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])
                              ),
                            ],
                          ),
                          SizedBox(height: 15.h),

                          Expanded(
                            child: _selectedDayAppointments.isEmpty
                                ? _buildEmptyState()
                                : ListView.separated(
                                    itemCount: _selectedDayAppointments.length,
                                    separatorBuilder: (c, i) => SizedBox(height: 15.h),
                                    padding: EdgeInsets.only(bottom: 20.h),
                                    itemBuilder: (context, index) {
                                      return _buildAppointmentCard(_selectedDayAppointments[index]);
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

  Widget _buildAppointmentCard(AppointmentModel appt) {
    return InkWell(
      onTap: () {
        // Navegación a la vista de detalle enviando el objeto de la cita seleccionada
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentDetailPage(appointment: appt),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05), 
              blurRadius: 10, 
              offset: const Offset(0, 4)
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    appt.hora,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: const Color(0xFF00C4B4)),
                  ),
                  Text(
                    appt.periodo,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12.sp, color: const Color(0xFF00C4B4)),
                  ),
                ],
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appt.pacienteNombre, 
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    appt.servicioNombre, 
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    appt.estado,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: appt.estado.toLowerCase().contains('confirm') ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Botón de llamada rápida
            InkWell(
              onTap: () {
                // Aquí puedes implementar url_launcher si decides usarlo en el futuro
              },
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1), 
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone, color: Colors.green, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 40.sp, color: Colors.grey[400]),
          SizedBox(height: 10.h),
          Text("Sin citas programadas", style: TextStyle(color: Colors.grey[500], fontSize: 16.sp)),
        ],
      ),
    );
  }
}