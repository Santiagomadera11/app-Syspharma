class AppointmentModel {
  final int id;
  final String pacienteNombre;
  final String pacienteDocumento; // Nuevo
  final String pacienteEmail;     // Nuevo
  final String servicioNombre;
  final String hora;
  final String fecha;
  final String telefono;
  final double precio;            // Nuevo
  final String estado;
  final int estadoId;             // Nuevo
  final String notas;             // Nuevo
  final String fechaCreacion;     // Nuevo
  final int medicoId;             // Nuevo
  final int servicioId;           // Nuevo
  final int usuarioId;            // Nuevo

  AppointmentModel({
    required this.id,
    required this.pacienteNombre,
    required this.pacienteDocumento,
    required this.pacienteEmail,
    required this.servicioNombre,
    required this.hora,
    required this.fecha,
    required this.telefono,
    required this.precio,
    required this.estado,
    required this.estadoId,
    required this.notas,
    required this.fechaCreacion,
    required this.medicoId,
    required this.servicioId,
    required this.usuarioId,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final horaRaw = json['hora']?.toString() ?? '';
    final fechaRaw = json['fecha']?.toString() ?? '';

    String hora = '00:00';
    if (horaRaw.isNotEmpty) {
      hora = horaRaw.length >= 5 ? horaRaw.substring(0, 5) : horaRaw;
    }

    String fecha = '';
    if (fechaRaw.isNotEmpty) {
      fecha = fechaRaw.split('T').first;
    }

    final idValue = json['id'] ?? json['Id'] ?? 0;
    final telefonoValue = json['pacienteTelefono'] ?? json['telefono'] ?? json['Telefono'] ?? '';
    
    // Validaciones seguras para tipos numéricos nuevos
    final precioValue = json['precio'] ?? 0.0;
    final estadoIdValue = json['estadoId'] ?? 0;
    final medicoIdValue = json['medicoId'] ?? 0;
    final servicioIdValue = json['servicioId'] ?? 0;
    final usuarioIdValue = json['usuarioId'] ?? 0;

    return AppointmentModel(
      id: idValue is int ? idValue : int.tryParse(idValue?.toString() ?? '') ?? 0,
      pacienteNombre: json['pacienteNombre'] ?? json['paciente'] ?? 'Sin nombre',
      pacienteDocumento: json['pacienteDocumento']?.toString() ?? 'No registrado',
      pacienteEmail: json['pacienteEmail']?.toString() ?? 'Sin correo',
      servicioNombre: json['servicioNombre'] ?? json['servicio'] ?? 'Consulta General',
      hora: hora,
      fecha: fecha,
      telefono: telefonoValue.toString(),
      precio: precioValue is num ? precioValue.toDouble() : double.tryParse(precioValue.toString()) ?? 0.0,
      estado: json['estado'] ?? json['status'] ?? 'Confirmada',
      estadoId: estadoIdValue is int ? estadoIdValue : int.tryParse(estadoIdValue.toString()) ?? 0,
      notas: json['notas']?.toString() ?? '',
      fechaCreacion: json['fechaCreacion']?.toString() ?? '',
      medicoId: medicoIdValue is int ? medicoIdValue : int.tryParse(medicoIdValue.toString()) ?? 0,
      servicioId: servicioIdValue is int ? servicioIdValue : int.tryParse(servicioIdValue.toString()) ?? 0,
      usuarioId: usuarioIdValue is int ? usuarioIdValue : int.tryParse(usuarioIdValue.toString()) ?? 0,
    );
  }

  DateTime get fechaAsDate {
    try {
      return DateTime.parse(fecha);
    } catch (_) {
      return DateTime.now();
    }
  }

  String get periodo {
    final parts = hora.split(':');
    if (parts.isEmpty) return 'AM';
    final hour = int.tryParse(parts[0]) ?? 0;
    return hour >= 12 ? 'PM' : 'AM';
  }
}