import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late List<AppointmentModel> _allAppointments;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAppointments();
  }

  void _loadAppointments() {
    final today = DateTime.now();
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
        type: "Revisión",
        status: "Confirmada",
      ),
      AppointmentModel(
        date: today.add(const Duration(days: 1)),
        time: "09:00 AM",
        patientName: "Valentina Gomez",
        type: "Consulta General",
        status: "Confirmada",
      ),
    ];
  }

  List<AppointmentModel> _getEventsForDay(DateTime day) {
    return _allAppointments.where((appt) => isSameDay(appt.date, day)).toList();
  }

  List<AppointmentModel> get _selectedDayAppointments {
    return _getEventsForDay(_selectedDay!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // APP BAR AGREGADO
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
      body: SafeArea(
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
    return Container(
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
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  appt.time.split(' ')[0], 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppColors.primary)
                ),
                Text(
                  appt.time.split(' ')[1], 
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12.sp, color: AppColors.primary)
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
                  appt.patientName, 
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87)
                ),
                SizedBox(height: 4.h),
                Text(
                  appt.type, 
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1), 
                shape: BoxShape.circle
              ),
              child: const Icon(Icons.phone, color: Colors.green, size: 20),
            ),
          ),
        ],
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

class AppointmentModel {
  final DateTime date;
  final String time;
  final String patientName;
  final String type;
  final String status;

  AppointmentModel({required this.date, required this.time, required this.patientName, required this.type, required this.status});
}