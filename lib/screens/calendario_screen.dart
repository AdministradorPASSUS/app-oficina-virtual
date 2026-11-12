import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:oficina_virtual_movil/screens/inicio_screen.dart';
import '../../services/auth_service.dart';

class SeleccionarCitasScreen extends StatefulWidget {
  final String tipoServicio;
  final String especialidad;
  final String oficina;
  final String profesor;
  final Map<String, dynamic> respuestaApi;
  final List<Map<String, dynamic>> citas;
  final Map<String, dynamic> datosAgendamiento;
  final int cantidadMaxima;
  final String direccionsede;
  final String sedeSeleccionada;
  final DateTime? fechaMinima;

  const SeleccionarCitasScreen({
    super.key,
    required this.tipoServicio,
    required this.especialidad,
    required this.oficina,
    required this.profesor,
    required this.respuestaApi,
    required this.citas,
    required this.cantidadMaxima,
    required this.datosAgendamiento,
    required this.direccionsede,
    required this.sedeSeleccionada,
    required this.fechaMinima,
  });

  @override
  State<SeleccionarCitasScreen> createState() =>
      _SeleccionarCitasScreenState();
}

class _GrupoHorario {
  final String clave;
  final String claveCaracteristicas;
  final DateTime inicio;
  final List<Map<String, dynamic>> cupos;

  _GrupoHorario({
    required this.clave,
    required this.claveCaracteristicas,
    required this.inicio,
    required this.cupos,
  });

  int get cantidadCupos => cupos.length;

  Map<String, dynamic> get registro => cupos.first;
}

class _SesionDoble {
  final _GrupoHorario primero;
  final _GrupoHorario segundo;

  _SesionDoble({
    required this.primero,
    required this.segundo,
  });

  String get clave => '${primero.clave}||${segundo.clave}';

  DateTime get inicio => primero.inicio;

  int get cuposDisponibles {
    final a = primero.cantidadCupos;
    final b = segundo.cantidadCupos;
    return a < b ? a : b;
  }
}

// Representa una opción de agendamiento.
// Puede contener una cita individual o dos citas consecutivas.
class _OpcionAgendamiento {
  final String clave;
  final DateTime inicio;
  final List<Map<String, dynamic>> citas;

  _OpcionAgendamiento({
    required this.clave,
    required this.inicio,
    required this.citas,
  });

  int get cantidadCitas => citas.length;
}

class _SeleccionarCitasScreenState
    extends State<SeleccionarCitasScreen> {
  static const Color azul = Color(0xFF0D6EFD);
  static const Color verde = Color(0xFF00A54F);

  late DateTime _focusedDay;
  DateTime? _selectedDay;

  final List<_OpcionAgendamiento> _opcionesSeleccionadas = [];

  final AuthService _authService = AuthService();

  bool _enviandoCitas = false;

  String _texto(dynamic valor) => valor?.toString().trim() ?? '';

  bool get _esDivertido { return widget.tipoServicio.trim().toLowerCase() == 'divertido';}

  // Especialidades que requieren sesiones dobles.
  // Las demás se agendan mediante citas individuales.
  bool get _requiereSesionDoble {

    if (_esDivertido) return false;
    final id = widget.especialidad.trim();

    const especialidadesDobles = {
      '11','14','35','62',
    };

    return especialidadesDobles.contains(id);
  }

  // Normaliza los nombres posibles de los identificadores.
  String _obtenerIdCita(Map<String, dynamic> cita) {
    return _texto(
      cita['id_slot'] ??
          cita['idSlot'] ??
          cita['cita'] ??
          cita['id'],
    );
  }

// LIMITA EL SIGUIENTE CALENDARIO
  DateTime get _fechaInicioCalendario {
    final hoy = DateTime.now();

    final fechaHoy = DateTime(
      hoy.year,
      hoy.month,
      hoy.day,
    );

    final minima = widget.fechaMinima;

    if (minima == null) return fechaHoy;

    final fechaMinima = DateTime(
      minima.year,
      minima.month,
      minima.day,
    );

    return fechaMinima.isAfter(fechaHoy)
        ? fechaMinima
        : fechaHoy;
  }

  dynamic _obtenerIdExamen(Map<String, dynamic> cita) {
    return cita['id_examen'] ??
        cita['idExam'] ??
        cita['id_exam'] ??
        cita['idExamen'] ??
        cita['exam'];
  }

  dynamic _obtenerIdOficina(Map<String, dynamic> cita) {
    return cita['idof'] ??
        cita['id_oficina'] ??
        cita['idOffice'] ??
        cita['id_sede'] ??
        cita['oficina'];
  }

  // Nombre general del servicio.
  String get _nombreServicio {
    final dynamic agenda = widget.respuestaApi['agenda'];

    final List<Map<String, dynamic>> origen =
        agenda is List && agenda.isNotEmpty
            ? agenda
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
            : widget.citas;

    if (origen.isNotEmpty) {
      final cita = origen.first;

      final nombre = _texto(
        cita['examen'] ?? cita['servicio'],
      );

      if (nombre.isNotEmpty) return nombre;
    }

    if (widget.especialidad.trim().isNotEmpty) {
      return widget.especialidad.trim();
    }

    return widget.tipoServicio;
  }

  DateTime? _fechaHora(Map<String, dynamic> cita) {
    final fechaHora = _texto(cita['fecha_hora']);

    if (fechaHora.isNotEmpty) {
      final fecha = DateTime.tryParse(fechaHora);
      if (fecha != null) return fecha;
    }

    final fecha = _texto(cita['fecha']);
    final hora = _texto(cita['hora']);

    if (fecha.isEmpty || hora.isEmpty) return null;

    return DateTime.tryParse('${fecha}T$hora');
  }

  int _duracionMinutos(Map<String, dynamic> cita) {
    final valor = cita['duracion'] ?? cita['durationSlot'];

    if (valor is num && valor > 0) {
      return valor.toInt();
    }

    final texto = _texto(valor);

    if (texto.contains(':')) {
      final partes = texto.split(':');

      if (partes.length >= 2) {
        final horas = int.tryParse(partes[0]);
        final minutos = int.tryParse(partes[1]);

        if (horas != null && minutos != null) {
          return horas * 60 + minutos;
        }
      }
    }

    final duracion = int.tryParse(texto);

    if (duracion != null && duracion > 0) {
      return duracion.clamp(1, 1440).toInt();
    }

    return 30;
  }

  String _hora(DateTime fecha) =>
      '${fecha.hour.toString().padLeft(2, '0')}:'
      '${fecha.minute.toString().padLeft(2, '0')}';

  String _intervalo(DateTime inicio, int minutos) {
    final fin = inicio.add(Duration(minutes: minutos));
    return '${_hora(inicio)} - ${_hora(fin)}';
  }

  String _fechaHoraInicial(DateTime inicio) {
    final fecha =
        '${inicio.day.toString().padLeft(2, '0')}/'
        '${inicio.month.toString().padLeft(2, '0')}/'
        '${inicio.year}';

    return '$fecha - ${_hora(inicio)}';
  }

  String _fechaTexto(DateTime fecha) =>
      '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/'
      '${fecha.year}';

  bool _mismaFecha(DateTime a, DateTime b) =>
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;

  DateTime _inicioSemana(DateTime fecha) {
    final dia = DateTime(fecha.year, fecha.month, fecha.day);

    return dia.subtract(
      Duration(days: dia.weekday - DateTime.monday),
    );
  }

  bool _mismaSemana(DateTime a, DateTime b) =>
      _inicioSemana(a) == _inicioSemana(b);

  String _claveCaracteristicas(Map<String, dynamic> cita) {
    return [
      _texto(
        cita['id_examen'] ??
            cita['idExam'] ??
            cita['id_exam'] ??
            cita['exam'] ??
            cita['examen'],
      ),
      _texto(cita['profesional'] ?? cita['nameProfessional']),
      _texto(
        cita['idof'] ??
            cita['id_oficina'] ??
            cita['idOffice'] ??
            cita['id_sede'] ??
            cita['oficina'],
      ),
      _texto(cita['sala'] ?? cita['nameRoom']),
      _duracionMinutos(cita).toString(),
    ].join('|');
  }

  String _claveHorario(
    DateTime fecha,
    String caracteristicas,
  ) {
    return '${fecha.year}-'
        '${fecha.month.toString().padLeft(2, '0')}-'
        '${fecha.day.toString().padLeft(2, '0')} '
        '${_hora(fecha)}|$caracteristicas';
  }

  // Utiliza primero la agenda de la respuesta y después widget.citas.
  List<Map<String, dynamic>> get _citasDisponibles {
    final dynamic agenda = widget.respuestaApi['agenda'];

    final List<Map<String, dynamic>> origen =
        agenda is List && agenda.isNotEmpty
            ? agenda
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
            : widget.citas;

    final resultado = <Map<String, dynamic>>[];
    final idsVistos = <String>{};

    for (final cita in origen) {
      if (_fechaHora(cita) == null) continue;

      final id = _obtenerIdCita(cita);

      if (id.isNotEmpty && !idsVistos.add(id)) {
        continue;
      }

      resultado.add(cita);
    }

    resultado.sort(
      (a, b) => _fechaHora(a)!.compareTo(_fechaHora(b)!),
    );

    return resultado;
  }

  List<_GrupoHorario> get _horarios {
    final Map<String, List<Map<String, dynamic>>> agrupados = {};
    final Map<String, DateTime> fechas = {};
    final Map<String, String> caracteristicas = {};

    for (final cita in _citasDisponibles) {
      final fecha = _fechaHora(cita);
      if (fecha == null) continue;

      final caracteristica = _claveCaracteristicas(cita);
      final clave = _claveHorario(fecha, caracteristica);

      agrupados.putIfAbsent(clave, () => []).add(cita);
      fechas[clave] = fecha;
      caracteristicas[clave] = caracteristica;
    }

    final resultado = agrupados.entries.map((entrada) {
      return _GrupoHorario(
        clave: entrada.key,
        claveCaracteristicas: caracteristicas[entrada.key]!,
        inicio: fechas[entrada.key]!,
        cupos: entrada.value,
      );
    }).toList();

    resultado.sort((a, b) => a.inicio.compareTo(b.inicio));

    return resultado;
  }

  // Busca sesiones dobles que comiencen en el minuto 15
  // y tengan su segundo horario 30 minutos después.
  List<_SesionDoble> get _sesionesDisponibles {
    final horarios = _horarios;

    final Map<String, _GrupoHorario> porClave = {
      for (final horario in horarios) horario.clave: horario,
    };

    final resultado = <_SesionDoble>[];

    for (final primero in horarios) {
      if (primero.inicio.minute != 15) continue;

      final segundoInicio =
          primero.inicio.add(const Duration(minutes: 30));

      if (segundoInicio.minute != 45) continue;

      final claveSegundo = _claveHorario(
        segundoInicio,
        primero.claveCaracteristicas,
      );

      final segundo = porClave[claveSegundo];

      if (segundo == null ||
          primero.cantidadCupos == 0 ||
          segundo.cantidadCupos == 0) {
        continue;
      }

      resultado.add(
        _SesionDoble(
          primero: primero,
          segundo: segundo,
        ),
      );
    }

    return resultado;
  }

  List<_OpcionAgendamiento> get _opcionesDisponibles {
  final fechaInicio = _fechaInicioCalendario;

  if (_requiereSesionDoble) {
    return _sesionesDisponibles
        .where((sesion) {
          final fecha = DateTime(
            sesion.inicio.year,
            sesion.inicio.month,
            sesion.inicio.day,
          );

          return !fecha.isBefore(fechaInicio);
        })
        .map((sesion) {
          return _OpcionAgendamiento(
            clave: sesion.clave,
            inicio: sesion.inicio,
            citas: [
              sesion.primero.registro,
              sesion.segundo.registro,
            ],
          );
        })
        .toList();
  }

  return _citasDisponibles
      .where((cita) {
        final fecha = _fechaHora(cita)!;

        final fechaDia = DateTime(
          fecha.year,
          fecha.month,
          fecha.day,
        );

        return !fechaDia.isBefore(fechaInicio);
      })
      .map((cita) {
        final fecha = _fechaHora(cita)!;
        final id = _obtenerIdCita(cita);

        final clave = id.isNotEmpty
            ? 'individual|$id'
            : 'individual|${_claveHorario(fecha, _claveCaracteristicas(cita))}';

        return _OpcionAgendamiento(
          clave: clave,
          inicio: fecha,
          citas: [cita],
        );
      })
      .toList();
}
/*
  List<_OpcionAgendamiento> get _opcionesDisponibles {
    if (_requiereSesionDoble) {
      return _sesionesDisponibles.map((sesion) {
        return _OpcionAgendamiento(
          clave: sesion.clave,
          inicio: sesion.inicio,
          citas: [
            sesion.primero.registro,
            sesion.segundo.registro,
          ],
        );
      }).toList();
    }

    return _citasDisponibles.map((cita) {
      final fecha = _fechaHora(cita)!;
      final id = _obtenerIdCita(cita);

      final clave = id.isNotEmpty
          ? 'individual|$id'
          : 'individual|${_claveHorario(fecha, _claveCaracteristicas(cita))}';

      return _OpcionAgendamiento(
        clave: clave,
        inicio: fecha,
        citas: [cita],
      );
    }).toList();
  }
*/
  List<_OpcionAgendamiento> _opcionesDelDia(DateTime dia) {
    return _opcionesDisponibles.where((opcion) {
      return _mismaFecha(opcion.inicio, dia);
    }).toList();
  }

  bool _opcionSeleccionada(_OpcionAgendamiento opcion) {
    return _opcionesSeleccionadas.any(
      (item) => item.clave == opcion.clave,
    );
  }

  int get _citasSeleccionadasCount {
    return _opcionesSeleccionadas.fold(
      0,
      (total, opcion) => total + opcion.cantidadCitas,
    );
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
  }

  // Selecciona o deselecciona una opción.
  // Una opción puede representar una o dos citas.
  void _seleccionarSesion(_OpcionAgendamiento opcion) {
    final existente = _opcionesSeleccionadas.indexWhere(
      (item) => item.clave == opcion.clave,
    );

    if (existente != -1) {
      setState(() {
        _opcionesSeleccionadas.removeAt(existente);
      });
      return;
    }

    if (widget.cantidadMaxima <= 0) {
      _mostrarMensaje(
        'No hay cantidad de sesiones autorizada.',
      );
      return;
    }

    if (_citasSeleccionadasCount + opcion.cantidadCitas >
        widget.cantidadMaxima) {
      _mostrarMensaje(
        'Solo puedes seleccionar hasta '
        '${widget.cantidadMaxima} citas individuales.',
      );
      return;
    }

    // Conserva la regla original: una opción por día.
    final yaTieneOpcionEseDia = _opcionesSeleccionadas.any(
      (item) => _mismaFecha(item.inicio, opcion.inicio),
    );

    if (yaTieneOpcionEseDia) {
      _mostrarMensaje(
        _requiereSesionDoble
            ? 'Solo puedes seleccionar una sesión doble por día.'
            : 'Solo puedes seleccionar una cita por día.',
      );
      return;
    }

    // Máximo tres días por semana solo para servicios diferentes a divertido
    if (!_esDivertido) {
      final diasSeleccionadosSemana = _opcionesSeleccionadas
          .where(
            (item) => _mismaSemana(item.inicio, opcion.inicio),
          )
          .map(
            (item) => DateTime(
              item.inicio.year,
              item.inicio.month,
              item.inicio.day,
            ),
          )
          .toSet();

      final nuevoDia = DateTime(
        opcion.inicio.year,
        opcion.inicio.month,
        opcion.inicio.day,
      );

      if (!diasSeleccionadosSemana.contains(nuevoDia) &&
          diasSeleccionadosSemana.length >= 3) {
        _mostrarMensaje(
          'Solo puedes agendar citas en tres días por semana.',
        );
        return;
      }
    }

/*
    final diasSeleccionadosSemana = _opcionesSeleccionadas
      .where(
        (item) => _mismaSemana(item.inicio, opcion.inicio),
      )
      .map(
        (item) => DateTime(
          item.inicio.year,
          item.inicio.month,
          item.inicio.day,
        ),
      )
      .toSet();

    final nuevoDia = DateTime(
      opcion.inicio.year,
      opcion.inicio.month,
      opcion.inicio.day,
    );

    if (!diasSeleccionadosSemana.contains(nuevoDia) &&
        diasSeleccionadosSemana.length >= 3) {
      _mostrarMensaje(
        'Solo puedes agendar citas en tres días por semana.',
      );
      return;
    }
*/
    setState(() {
      _opcionesSeleccionadas.add(opcion);

      _opcionesSeleccionadas.sort(
        (a, b) => a.inicio.compareTo(b.inicio),
      );
    });

    debugPrint('========== OPCIÓN SELECCIONADA ==========');
    debugPrint('ESPECIALIDAD: ${widget.especialidad}');
    debugPrint('MODALIDAD DOBLE: $_requiereSesionDoble');

    for (final cita in opcion.citas) {
      debugPrint('REGISTRO ORIGINAL: $cita');
      debugPrint('ID CITA: ${_obtenerIdCita(cita)}');
      debugPrint('ID EXAMEN: ${_obtenerIdExamen(cita)}');
      debugPrint('ID OFICINA: ${_obtenerIdOficina(cita)}');
    }

    debugPrint('==========================================');
  }

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _focusedDay = _fechaInicioCalendario;
    /*DateTime(hoy.year, hoy.month, hoy.day);*/
    _selectedDay = _focusedDay;

    final opciones = _opcionesDisponibles;

    if (opciones.isNotEmpty) {
      final primera = opciones.first.inicio;

      _focusedDay = DateTime(
        primera.year,
        primera.month,
        primera.day,
      );

      _selectedDay = _focusedDay;
    }
  }

  Future<void> _confirmarSeleccion() async {
    if (_enviandoCitas) return;

    debugPrint('========== INICIO AGENDAMIENTO ==========');

    if (_opcionesSeleccionadas.isEmpty) {
      _mostrarMensaje('Selecciona al menos un horario.');
      return;
    }

    if (_esDivertido) {
      if (_citasSeleccionadasCount < 1 ||
          _citasSeleccionadasCount > widget.cantidadMaxima) {
        _mostrarMensaje(
          'Selecciona mínimo una cita'
          '${widget.cantidadMaxima}.',
        );
        return;
      }
    } else {
      if (_citasSeleccionadasCount != widget.cantidadMaxima) {
        _mostrarMensaje(
          'Debes seleccionar ${widget.cantidadMaxima} citas.',
        );
        return;
      }
    }

    /*
    if (_citasSeleccionadasCount != widget.cantidadMaxima) {
      _mostrarMensaje(
        'Debes seleccionar ${widget.cantidadMaxima} citas.',
      );
      return;
    }
    */

    try {
      final List<Map<String, dynamic>> selecciones = [];

      // Recorre cada opción y cada cita que contiene.
      // En modalidad individual será una cita por opción.
      // En modalidad doble serán dos citas por opción.
      for (final opcion in _opcionesSeleccionadas) {
        for (final cita in opcion.citas) {
          final fechaHora = _fechaHora(cita);

          if (fechaHora == null) {
            throw Exception(
              'Una cita no tiene fecha u hora válida: $cita',
            );
          }

          final idCita = _obtenerIdCita(cita);
          final examen = _obtenerIdExamen(cita);
          final oficina = _obtenerIdOficina(cita);

          if (idCita.isEmpty ||
              examen == null ||
              examen.toString().trim().isEmpty ||
              oficina == null ||
              oficina.toString().trim().isEmpty) {
            debugPrint('IDENTIFICADORES INCOMPLETOS');
            debugPrint('REGISTRO: $cita');
            debugPrint('ID CITA: $idCita');
            debugPrint('ID EXAMEN: $examen');
            debugPrint('ID OFICINA: $oficina');

            throw Exception(
              'Faltan identificadores en una cita. '
              'Consulta el registro original en la consola.',
            );
          }

          final seleccion = <String, dynamic>{
            'cita': idCita,
            'exam': examen,
            'idof': oficina,
            'fecha':
                '${fechaHora.year}-'
                '${fechaHora.month.toString().padLeft(2, '0')}-'
                '${fechaHora.day.toString().padLeft(2, '0')}',
            'hora':
                '${fechaHora.hour.toString().padLeft(2, '0')}:'
                '${fechaHora.minute.toString().padLeft(2, '0')}',
            'profesional':
                cita['profesional'] ??
                cita['nameProfessional'] ??
                '',
            'examen':
                cita['examen'] ??
                cita['nameExam'] ??
                '',
            'sede':
                cita['sala'] ??
                cita['nameOffice'] ??
                '',
            'direccion': widget.direccionsede,
            'nombre_sede': widget.sedeSeleccionada,
          };

          selecciones.add(seleccion);

          debugPrint(
            'CITA ${selecciones.length}: $seleccion',
          );
        }
      }

      if(_esDivertido){
        if (selecciones.length < 1 || selecciones.length > widget.cantidadMaxima) {
          throw Exception(
            'Se prepararon ${selecciones.length} citas, '
            'pero se requieren ${widget.cantidadMaxima}.',
          );
        }
      }else{
        if (selecciones.length != widget.cantidadMaxima) {
          throw Exception(
            'Se prepararon ${selecciones.length} citas, '
            'pero se requieren ${widget.cantidadMaxima}.',
          );
        }
      }
      
      // Conserva los datos generales recibidos de la pantalla anterior.
      final datos = Map<String, dynamic>.from(
        widget.datosAgendamiento,
      );

      final informacion = <String, dynamic>{
        ...datos,
        'tipo_servicio': widget.tipoServicio,
        'selecciones': selecciones,
      };

      const camposObligatorios = [
        'usuario_id',
        'autorizacion_id',
        'numero_autorizacion',
        'documentPatient',
        'documentType',
        'email',
        'cellPhone',
        'codeContract',
        'codePlan',
        'codeRegime',
        'codeTypeAffiliate',
        'codeLevelAffiliate',
      ];

      final camposFaltantes = camposObligatorios.where((campo) {
        final valor = informacion[campo];

        return valor == null ||
            valor.toString().trim().isEmpty;
      }).toList();

      if (camposFaltantes.isNotEmpty) {
        debugPrint('CAMPOS FALTANTES: $camposFaltantes');

        _mostrarMensaje(
          'Faltan datos para agendar. Consulta la consola.',
        );
        return;
      }

      debugPrint('TOTAL DE CITAS: ${selecciones.length}');
      debugPrint('TIPO SERVICIO: ${widget.tipoServicio}');
      debugPrint('ESPECIALIDAD: ${widget.especialidad}');
      debugPrint(
        'CLAVES DATOS GENERALES: ${datos.keys.toList()}',
      );
      debugPrint('DATOS DE LAS SELECCIONES:');

      for (var i = 0; i < selecciones.length; i++) {
        debugPrint('CITA ${i + 1}: ${selecciones[i]}');
      }

      if (!mounted) return;

      setState(() {
        _enviandoCitas = true;
      });

      debugPrint('ENVIANDO SOLICITUD A CONFIRMAR CITAS...');

      final respuesta = await _authService.confirmarCitas(
        informacion: informacion,
      );

      debugPrint('RESPUESTA RECIBIDA DE LA API: $respuesta');

      if (!mounted) return;

      final dynamic fallidas = respuesta['citas_fallidas'];

      final bool hayFallidas = fallidas is List
          ? fallidas.isNotEmpty
          : fallidas is num
              ? fallidas > 0
              : false;

      final bool success =
          respuesta['success'] == true && !hayFallidas;

      debugPrint('SUCCESS: $success');
      debugPrint('HTTP STATUS: ${respuesta['http_status']}');
      debugPrint('CITAS AGENDADAS: ${respuesta['citas_agendadas']}');
      debugPrint('CITAS FALLIDAS: $fallidas');

      if (success) {
        debugPrint('AGENDAMIENTO CORRECTO');
        debugPrint('RESPUESTA COMPLETA: $respuesta');

        Navigator.pop(
          context,
          {
            'success': true,
            'respuesta': respuesta,
            'citasAgendadas': selecciones,
          },
        );
      } else {
        _mostrarMensaje(
          respuesta['message']?.toString() ??
              'No fue posible confirmar las citas.',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('========== ERROR AL AGENDAR ==========');
      debugPrint('TIPO: ${e.runtimeType}');
      debugPrint('ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        _mostrarMensaje(
          'Error al agendar. Revisa la consola.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _enviandoCitas = false;
        });
      }

      debugPrint('=========== FIN AGENDAMIENTO ==========');
    }
  }

  @override
  Widget build(BuildContext context) {
    final opciones = _selectedDay == null
        ? <_OpcionAgendamiento>[]
        : _opcionesDelDia(_selectedDay!);

    final fechasConAgenda = _opcionesDisponibles
        .map((opcion) => opcion.inicio)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar citas'),
        backgroundColor: azul,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nombreServicio,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _requiereSesionDoble
                                ? 'Selecciona sesiones dobles.'
                                : 'Selecciona los horarios individuales disponibles.',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: TableCalendar<DateTime>(
                        locale: 'es_CO',
                        firstDay: _fechaInicioCalendario,
                        /*firstDay: DateTime.now().subtract(
                          const Duration(days: 1),
                        ),*/
                        lastDay: DateTime.now().add(
                          const Duration(days: 365),
                        ),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            _selectedDay != null &&
                            _mismaFecha(day, _selectedDay!),
                        eventLoader: (day) {
                          return fechasConAgenda.where(
                            (fecha) => _mismaFecha(fecha, day),
                          ).toList();
                        },
                        calendarFormat: CalendarFormat.month,
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Mes',
                        },
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        calendarStyle: const CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Color(0x553693EB),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: azul,
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: verde,
                            shape: BoxShape.circle,
                          ),
                          markersMaxCount: 3,
                          outsideDaysVisible: false,
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        onDaySelected: (selected, focused) {
                          setState(() {
                            _selectedDay = selected;
                            _focusedDay = focused;
                          });
                        },
                        onPageChanged: (focused) {
                          _focusedDay = focused;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    _selectedDay == null
                        ? 'Horarios disponibles'
                        : 'Horarios del ${_fechaTexto(_selectedDay!)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (opciones.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'No hay horarios disponibles para este día.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  else
                    ...opciones.map(_construirOpcion),

                  const SizedBox(height: 16),

                  if (_opcionesSeleccionadas.isNotEmpty) ...[
                    const Text(
                      'Tu selección',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ..._opcionesSeleccionadas.map((opcion) {
                      return Column(
                        children: opcion.citas.map((cita) {
                          final fecha = _fechaHora(cita)!;

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.check_circle,
                              color: verde,
                            ),
                            title: Text(
                              '${_fechaTexto(fecha)} - ${_hora(fecha)}',
                            ),
                            //subtitle: Text(
                              //'ID: ${_obtenerIdCita(cita)}',
                            //),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _enviandoCitas
                                  ? null
                                  : () {
                                      setState(() {
                                        _opcionesSeleccionadas
                                            .removeWhere(
                                          (item) =>
                                              item.clave == opcion.clave,
                                        );
                                      });
                                    },
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 6,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Citas seleccionadas: '
                    '$_citasSeleccionadasCount / ${widget.cantidadMaxima}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          widget.cantidadMaxima > 0 &&
                            (_esDivertido
                                ? _citasSeleccionadasCount >= 1 &&
                                    _citasSeleccionadasCount <=
                                        widget.cantidadMaxima
                                : _citasSeleccionadasCount ==
                                    widget.cantidadMaxima) &&
                            !_enviandoCitas
                        ? _confirmarSeleccion
                        : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: azul,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                      child: Text(
                        _enviandoCitas
                            ? 'Agendando citas...'
                            : 'Confirmar selección',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dibuja una opción individual o una sesión doble.
  Widget _construirOpcion(_OpcionAgendamiento opcion) {
    final seleccionada = _opcionSeleccionada(opcion);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _enviandoCitas
            ? null
            : () => _seleccionarSesion(opcion),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: seleccionada
                ? azul.withValues(alpha: 0.08)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: seleccionada ? azul : verde,
                width: 4,
              ),
            ),
          ),
          child: Column(
            children: [
              if (seleccionada)
                const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.check_circle,
                    color: azul,
                  ),
                ),

              ...opcion.citas.map((cita) {
                final fecha = _fechaHora(cita)!;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _construirCitaIndividual(cita, fecha),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirCitaIndividual(
    Map<String, dynamic> cita,
    DateTime fecha,
  ) {
    // Para sesiones dobles se conserva el intervalo de 30 minutos.
    // Para citas individuales se utiliza la duración que entrega la API.
    final duracion = _requiereSesionDoble
        ? 30
        : _duracionMinutos(cita);

    final profesional = _texto(
      cita['profesional'] ?? cita['nameProfessional'],
    );

    final examen = _texto(
      cita['examen'] ?? cita['nameExam'] ?? cita['servicio'],
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.schedule,
            color: azul,
            size: 22,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _hora(fecha),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),

                //Text(
                  //_intervalo(fecha, duracion),
                  //style: TextStyle(
                    //color: Colors.grey.shade700,
                    //fontSize: 12,
                  //),
                //),

                if (profesional.isNotEmpty)
                  Text(
                    'Profesional: $profesional',
                    style: const TextStyle(fontSize: 12),
                  ),

                if (examen.isNotEmpty)
                  Text(
                    examen,
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ),

          const Icon(
            Icons.event_available,
            color: verde,
          ),
        ],
      ),
    );
  }
}

// AGENDAMIENTO CORRECTO ////////////////////////////////////////

class AgendamientoExitosoScreen extends StatelessWidget {
  final Map<String, dynamic> respuesta;
  final List<Map<String, dynamic>> citasAgendadas;

  const AgendamientoExitosoScreen({
    super.key,
    required this.respuesta,
    required this.citasAgendadas,
  });

  String texto(dynamic valor) {
    return valor?.toString().trim() ?? '';
  }

  String fechaBonita(dynamic valor) {
    final fecha = texto(valor);
    final partes = fecha.split('-');

    if (partes.length == 3 && partes[0].length == 4) {
      return '${partes[2]}/${partes[1]}/${partes[0]}';
    }

    return fecha;
  }

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF0D6EFD);
    const verde = Color(0xFF00A54F);

    // Si la API devuelve una lista de citas confirmadas,
    // utiliza esa lista; de lo contrario, muestra las
    // selecciones enviadas que fueron confirmadas exitosamente.
    final dynamic citasRespuesta = respuesta['citas_agendadas'];

    final List<Map<String, dynamic>> citas =
        citasRespuesta is List &&
                citasRespuesta.isNotEmpty &&
                citasRespuesta.every((item) => item is Map)
            ? citasRespuesta
                .map((item) => Map<String, dynamic>.from(item as Map))
                .toList()
            : citasAgendadas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamiento confirmado'),
        backgroundColor: azul,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 20),

                  const Icon(
                    Icons.check_circle,
                    size: 90,
                    color: verde,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    '¡Agendamiento exitoso!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Tus citas fueron agendadas correctamente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 24),

                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.event_available,
                        color: verde,
                        size: 35,
                      ),
                      title: const Text('Citas agendadas'),
                      subtitle: Text(
                        'Total: ${citas.length}',
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Detalle de tus citas',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...citas.asMap().entries.map((entrada) {
                    final indice = entrada.key;
                    final cita = entrada.value;

                    final fecha = cita['fecha'] ??
                        cita['fecha_cita'] ??
                        cita['date'];

                    final hora = cita['hora'] ??
                        cita['hora_cita'] ??
                        cita['time'];

                    final examen = cita['examen'] ??
                        cita['nameExam'] ??
                        cita['servicio'] ??
                        cita['exam'] ??
                        'Cita ${indice + 1}';

                    final profesional = cita['profesional'] ??
                        cita['nameProfessional'] ??
                        cita['profesional_nombre'];

                    final direccion =
                        cita['direccion']?.toString() ?? '';

                    final sede =
                        cita['nombre_sede']?.toString() ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: verde,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Cita ${indice + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Divider(),

                            Text('Servicio: ${texto(examen)}'),

                            const SizedBox(height: 8),

                            if (texto(fecha).isNotEmpty)
                              Text(
                                'Fecha: ${fechaBonita(fecha)}',
                              ),

                            if (texto(hora).isNotEmpty)
                              Text('Hora: ${texto(hora)}'),

                            if (texto(profesional).isNotEmpty)
                              Text(
                                'Profesional: ${texto(profesional)}',
                              ),

                            if (texto(sede).isNotEmpty)
                              Text(
                                'Sede: ${texto(sede)}',
                              ),

                            if (direccion.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: azul,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Dirección: $direccion',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const InicioScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Volver al inicio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: azul,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:oficina_virtual_movil/screens/inicio_screen.dart';
import '../../services/auth_service.dart';

class SeleccionarCitasScreen extends StatefulWidget {
  final String tipoServicio;
  final String especialidad;
  final String oficina;
  final String profesor;
  final Map<String, dynamic> respuestaApi;
  final List<Map<String, dynamic>> citas;
  final Map<String, dynamic> datosAgendamiento;
  final int cantidadMaxima;
  final String direccionsede;
  final String sedeSeleccionada;

  const SeleccionarCitasScreen({
    super.key,
    required this.tipoServicio,
    required this.especialidad,
    required this.oficina,
    required this.profesor,
    required this.respuestaApi,
    required this.citas,
    required this.cantidadMaxima,
    required this.datosAgendamiento,
    required this.direccionsede,
    required this.sedeSeleccionada,
  });

  @override
  State<SeleccionarCitasScreen> createState() =>
      _SeleccionarCitasScreenState();
}

class _GrupoHorario {
  final String clave;
  final String claveCaracteristicas;
  final DateTime inicio;
  final List<Map<String, dynamic>> cupos;

  _GrupoHorario({
    required this.clave,
    required this.claveCaracteristicas,
    required this.inicio,
    required this.cupos,
  });

  int get cantidadCupos => cupos.length;

  Map<String, dynamic> get registro => cupos.first;
}

class _SesionDoble {
  final _GrupoHorario primero;
  final _GrupoHorario segundo;

  _SesionDoble({
    required this.primero,
    required this.segundo,
  });

  String get clave => '${primero.clave}||${segundo.clave}';

  DateTime get inicio => primero.inicio;

  int get cuposDisponibles {
    final a = primero.cantidadCupos;
    final b = segundo.cantidadCupos;
    return a < b ? a : b;
  }
}

class _SeleccionarCitasScreenState
    extends State<SeleccionarCitasScreen> {
  static const Color azul = Color(0xFF0D6EFD);
  static const Color verde = Color(0xFF00A54F);

  late DateTime _focusedDay;
  DateTime? _selectedDay;

  final List<_SesionDoble> _sesionesSeleccionadas = [];

  final AuthService _authService = AuthService();

  bool _enviandoCitas = false;

  String _texto(dynamic valor) =>
      valor?.toString().trim() ?? '';

  // Normaliza los nombres posibles de los identificadores.
  String _obtenerIdCita(Map<String, dynamic> cita) {
    return _texto(
      cita['id_slot'] ??
          cita['idSlot'] ??
          cita['cita'] ??
          cita['id'],
    );
  }

  dynamic _obtenerIdExamen(Map<String, dynamic> cita) {
    return cita['id_examen'] ??
        cita['idExam'] ??
        cita['id_exam'] ??
        cita['idExamen'] ??
        cita['exam'];
  }

  dynamic _obtenerIdOficina(Map<String, dynamic> cita) {
    return cita['idof'] ??
        cita['id_oficina'] ??
        cita['idOffice'] ??
        cita['id_sede'] ??
        cita['oficina'];
  }

  // Nombre general del servicio.
  String get _nombreServicio {
    final dynamic agenda = widget.respuestaApi['agenda'];

    final List<Map<String, dynamic>> origen =
        agenda is List && agenda.isNotEmpty
            ? agenda
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
            : widget.citas;

    if (origen.isNotEmpty) {
      final cita = origen.first;

      final nombre = _texto(
        cita['examen'] ?? cita['servicio'],
      );

      if (nombre.isNotEmpty) return nombre;
    }

    if (widget.especialidad.trim().isNotEmpty) {
      return widget.especialidad.trim();
    }

    return widget.tipoServicio;
  }

  DateTime? _fechaHora(Map<String, dynamic> cita) {
    final fechaHora = _texto(cita['fecha_hora']);

    if (fechaHora.isNotEmpty) {
      final fecha = DateTime.tryParse(fechaHora);
      if (fecha != null) return fecha;
    }

    final fecha = _texto(cita['fecha']);
    final hora = _texto(cita['hora']);

    if (fecha.isEmpty || hora.isEmpty) return null;

    return DateTime.tryParse('${fecha}T$hora');
  }

  int _duracionMinutos(Map<String, dynamic> cita) {
    final valor = cita['duracion'] ?? cita['durationSlot'];

    if (valor is num && valor > 0) {
      return valor.toInt();
    }

    final texto = _texto(valor);

    if (texto.contains(':')) {
      final partes = texto.split(':');

      if (partes.length >= 2) {
        final horas = int.tryParse(partes[0]);
        final minutos = int.tryParse(partes[1]);

        if (horas != null && minutos != null) {
          return horas * 60 + minutos;
        }
      }
    }

    final duracion = int.tryParse(texto);

    if (duracion != null && duracion > 0) {
      return duracion.clamp(1, 1440).toInt();
    }

    return 30;
  }

  String _hora(DateTime fecha) =>
      '${fecha.hour.toString().padLeft(2, '0')}:'
      '${fecha.minute.toString().padLeft(2, '0')}';

  String _intervalo(DateTime inicio, int minutos) {
    final fin = inicio.add(Duration(minutes: minutos));
    return '${_hora(inicio)} - ${_hora(fin)}';
  }

  String _fechaHoraInicial(DateTime inicio) {
    final fecha =
        '${inicio.day.toString().padLeft(2, '0')}/'
        '${inicio.month.toString().padLeft(2, '0')}/'
        '${inicio.year}';

    return '$fecha - ${_hora(inicio)}';
  }

  String _fechaTexto(DateTime fecha) =>
      '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/'
      '${fecha.year}';

  bool _mismaFecha(DateTime a, DateTime b) =>
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;

  DateTime _inicioSemana(DateTime fecha) {
    final dia = DateTime(fecha.year, fecha.month, fecha.day);

    return dia.subtract(
      Duration(days: dia.weekday - DateTime.monday),
    );
  }

  bool _mismaSemana(DateTime a, DateTime b) =>
      _inicioSemana(a) == _inicioSemana(b);

  String _claveCaracteristicas(Map<String, dynamic> cita) {
    return [
      _texto(
        cita['id_examen'] ??
            cita['idExam'] ??
            cita['id_exam'] ??
            cita['exam'] ??
            cita['examen'],
      ),
      _texto(cita['profesional'] ?? cita['nameProfessional']),
      _texto(
        cita['idof'] ??
            cita['id_oficina'] ??
            cita['idOffice'] ??
            cita['id_sede'] ??
            cita['oficina'],
      ),
      _texto(cita['sala'] ?? cita['nameRoom']),
      _duracionMinutos(cita).toString(),
    ].join('|');
  }

  String _claveHorario(
    DateTime fecha,
    String caracteristicas,
  ) {
    return '${fecha.year}-'
        '${fecha.month.toString().padLeft(2, '0')}-'
        '${fecha.day.toString().padLeft(2, '0')} '
        '${_hora(fecha)}|$caracteristicas';
  }

  // Utiliza primero la agenda de la respuesta y después widget.citas.
  List<Map<String, dynamic>> get _citasDisponibles {
    final dynamic agenda = widget.respuestaApi['agenda'];

    final List<Map<String, dynamic>> origen =
        agenda is List && agenda.isNotEmpty
            ? agenda
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
            : widget.citas;

    final resultado = <Map<String, dynamic>>[];
    final idsVistos = <String>{};

    for (final cita in origen) {
      if (_fechaHora(cita) == null) continue;

      final id = _obtenerIdCita(cita);

      if (id.isNotEmpty && !idsVistos.add(id)) {
        continue;
      }

      resultado.add(cita);
    }

    resultado.sort(
      (a, b) => _fechaHora(a)!.compareTo(_fechaHora(b)!),
    );

    return resultado;
  }

  List<_GrupoHorario> get _horarios {
    final Map<String, List<Map<String, dynamic>>> agrupados = {};
    final Map<String, DateTime> fechas = {};
    final Map<String, String> caracteristicas = {};

    for (final cita in _citasDisponibles) {
      final fecha = _fechaHora(cita);
      if (fecha == null) continue;

      final caracteristica = _claveCaracteristicas(cita);
      final clave = _claveHorario(fecha, caracteristica);

      agrupados.putIfAbsent(clave, () => []).add(cita);
      fechas[clave] = fecha;
      caracteristicas[clave] = caracteristica;
    }

    final resultado = agrupados.entries.map((entrada) {
      return _GrupoHorario(
        clave: entrada.key,
        claveCaracteristicas: caracteristicas[entrada.key]!,
        inicio: fechas[entrada.key]!,
        cupos: entrada.value,
      );
    }).toList();

    resultado.sort((a, b) => a.inicio.compareTo(b.inicio));

    return resultado;
  }

  // Busca sesiones dobles que comiencen en el minuto 15
  // y tengan su segundo horario 30 minutos después.
  List<_SesionDoble> get _sesionesDisponibles {
    final horarios = _horarios;

    final Map<String, _GrupoHorario> porClave = {
      for (final horario in horarios) horario.clave: horario,
    };

    final resultado = <_SesionDoble>[];

    for (final primero in horarios) {
      if (primero.inicio.minute != 15) continue;

      final segundoInicio =
          primero.inicio.add(const Duration(minutes: 30));

      if (segundoInicio.minute != 45) continue;

      final claveSegundo = _claveHorario(
        segundoInicio,
        primero.claveCaracteristicas,
      );

      final segundo = porClave[claveSegundo];

      if (segundo == null ||
          primero.cantidadCupos == 0 ||
          segundo.cantidadCupos == 0) {
        continue;
      }

      resultado.add(
        _SesionDoble(
          primero: primero,
          segundo: segundo,
        ),
      );
    }

    return resultado;
  }

  List<_SesionDoble> _sesionesDelDia(DateTime dia) {
    return _sesionesDisponibles.where((sesion) {
      return _mismaFecha(sesion.inicio, dia);
    }).toList();
  }

  bool _sesionSeleccionada(_SesionDoble sesion) {
    return _sesionesSeleccionadas.any(
      (item) => item.clave == sesion.clave,
    );
  }

  int get _citasSeleccionadasCount =>
      _sesionesSeleccionadas.length * 2;

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
  }

  void _seleccionarSesion(_SesionDoble sesion) {
    final existente = _sesionesSeleccionadas.indexWhere(
      (item) => item.clave == sesion.clave,
    );

    if (existente != -1) {
      setState(() {
        _sesionesSeleccionadas.removeAt(existente);
      });
      return;
    }

    if (widget.cantidadMaxima <= 0) {
      _mostrarMensaje(
        'No hay cantidad de sesiones autorizada.',
      );
      return;
    }

    if (_citasSeleccionadasCount + 2 > widget.cantidadMaxima) {
      _mostrarMensaje(
        'Solo puedes seleccionar hasta '
        '${widget.cantidadMaxima} citas individuales.',
      );
      return;
    }

    if (sesion.cuposDisponibles <= 0) {
      _mostrarMensaje(
        'No hay cupos disponibles para este horario.',
      );
      return;
    }

    // Una sesión doble por día.
    final yaTieneSesionEseDia = _sesionesSeleccionadas.any(
      (item) => _mismaFecha(item.inicio, sesion.inicio),
    );

    if (yaTieneSesionEseDia) {
      _mostrarMensaje(
        'Solo puedes seleccionar una sesión doble por día.',
      );
      return;
    }

    // Máximo tres días por semana.
    final diasSeleccionadosSemana = _sesionesSeleccionadas
        .where(
          (item) => _mismaSemana(item.inicio, sesion.inicio),
        )
        .map(
          (item) => DateTime(
            item.inicio.year,
            item.inicio.month,
            item.inicio.day,
          ),
        )
        .toSet();

    final nuevoDia = DateTime(
      sesion.inicio.year,
      sesion.inicio.month,
      sesion.inicio.day,
    );

    if (!diasSeleccionadosSemana.contains(nuevoDia) &&
        diasSeleccionadosSemana.length >= 3) {
      _mostrarMensaje(
        'Solo puedes agendar sesiones en tres días por semana.',
      );
      return;
    }

    setState(() {
      _sesionesSeleccionadas.add(sesion);

      _sesionesSeleccionadas.sort(
        (a, b) => a.inicio.compareTo(b.inicio),
      );
    });

    debugPrint('========== SESIÓN DOBLE SELECCIONADA ==========');

    for (final cita in [
      sesion.primero.registro,
      sesion.segundo.registro,
    ]) {
      debugPrint('REGISTRO ORIGINAL: $cita');
      debugPrint('ID CITA: ${_obtenerIdCita(cita)}');
      debugPrint('ID EXAMEN: ${_obtenerIdExamen(cita)}');
      debugPrint('ID OFICINA: ${_obtenerIdOficina(cita)}');
    }

    debugPrint('==============================================');
  }

  @override
  void initState() {
    super.initState();

    final hoy = DateTime.now();

    _focusedDay = DateTime(hoy.year, hoy.month, hoy.day);
    _selectedDay = _focusedDay;

    final sesiones = _sesionesDisponibles;

    if (sesiones.isNotEmpty) {
      final primera = sesiones.first.inicio;

      _focusedDay = DateTime(
        primera.year,
        primera.month,
        primera.day,
      );

      _selectedDay = _focusedDay;
    }
  }

  Future<void> _confirmarSeleccion() async {
    if (_enviandoCitas) return;

    debugPrint('========== INICIO AGENDAMIENTO ==========');

    if (_sesionesSeleccionadas.isEmpty) {
      _mostrarMensaje('Selecciona al menos un horario.');
      return;
    }

    if (_citasSeleccionadasCount != widget.cantidadMaxima) {
      _mostrarMensaje(
        'Debes seleccionar ${widget.cantidadMaxima} citas.',
      );
      return;
    }

    try {
      final List<Map<String, dynamic>> selecciones = [];

      for (final sesion in _sesionesSeleccionadas) {
        final citasSesion = [
          sesion.primero.registro,
          sesion.segundo.registro,
        ];

        for (final cita in citasSesion) {
          final fechaHora = _fechaHora(cita);

          if (fechaHora == null) {
            throw Exception(
              'Una cita no tiene fecha u hora válida: $cita',
            );
          }

          final idCita = _obtenerIdCita(cita);
          final examen = _obtenerIdExamen(cita);
          final oficina = _obtenerIdOficina(cita);

          if (idCita.isEmpty ||
              examen == null ||
              examen.toString().trim().isEmpty ||
              oficina == null ||
              oficina.toString().trim().isEmpty) {
            debugPrint('IDENTIFICADORES INCOMPLETOS');
            debugPrint('REGISTRO: $cita');
            debugPrint('ID CITA: $idCita');
            debugPrint('ID EXAMEN: $examen');
            debugPrint('ID OFICINA: $oficina');

            throw Exception(
              'Faltan identificadores en una cita. '
              'Consulta el registro original en la consola.',
            );
          }

          final seleccion = <String, dynamic>{
            'cita': idCita,
            'exam': examen,
            'idof': oficina,
            'fecha':
                '${fechaHora.year}-'
                '${fechaHora.month.toString().padLeft(2, '0')}-'
                '${fechaHora.day.toString().padLeft(2, '0')}',
            'hora':
                '${fechaHora.hour.toString().padLeft(2, '0')}:'
                '${fechaHora.minute.toString().padLeft(2, '0')}',
            'profesional':
                cita['profesional'] ??
                cita['nameProfessional'] ??
                '',
            'examen':
                cita['examen'] ??
                cita['nameExam'] ??
                '',

            'sede':
                cita['sala'] ??
                cita['nameOffice'] ??
                '',    
            
            'direccion':  widget.direccionsede,
            'nombre_sede': widget.sedeSeleccionada,
          };

          selecciones.add(seleccion);

          debugPrint(
            'CITA ${selecciones.length}: $seleccion',
          );
        }
      }

      if (selecciones.length != widget.cantidadMaxima) {
        throw Exception(
          'Se prepararon ${selecciones.length} citas, '
          'pero se requieren ${widget.cantidadMaxima}.',
        );
      }

      // Conserva los datos generales recibidos de la pantalla anterior.
      final datos = Map<String, dynamic>.from(
        widget.datosAgendamiento,
      );

      final informacion = <String, dynamic>{
        ...datos,
        'tipo_servicio': widget.tipoServicio,
        'selecciones': selecciones,
      };

      const camposObligatorios = [
        'usuario_id',
        'autorizacion_id',
        'numero_autorizacion',
        'documentPatient',
        'documentType',
        'email',
        'cellPhone',
        'codeContract',
        'codePlan',
        'codeRegime',
        'codeTypeAffiliate',
        'codeLevelAffiliate',
      ];

      final camposFaltantes = camposObligatorios.where((campo) {
        final valor = informacion[campo];

        return valor == null ||
            valor.toString().trim().isEmpty;
      }).toList();

      if (camposFaltantes.isNotEmpty) {
        debugPrint('CAMPOS FALTANTES: $camposFaltantes');

        _mostrarMensaje(
          'Faltan datos para agendar. Consulta la consola.',
        );
        return;
      }

      debugPrint('TOTAL DE CITAS: ${selecciones.length}');
      debugPrint('TIPO SERVICIO: ${widget.tipoServicio}');
      debugPrint(
        'CLAVES DATOS GENERALES: ${datos.keys.toList()}',
      );
      debugPrint('DATOS DE LAS SELECCIONES:');

      for (var i = 0; i < selecciones.length; i++) {
        debugPrint('CITA ${i + 1}: ${selecciones[i]}');
      }

      if (!mounted) return;

      setState(() {
        _enviandoCitas = true;
      });

      debugPrint('ENVIANDO SOLICITUD A CONFIRMAR CITAS...');

      final respuesta = await _authService.confirmarCitas(
        informacion: informacion,
      );

      debugPrint('RESPUESTA RECIBIDA DE LA API: $respuesta');

      if (!mounted) return;

      final dynamic fallidas = respuesta['citas_fallidas'];

      final bool hayFallidas = fallidas is List
          ? fallidas.isNotEmpty
          : fallidas is num
              ? fallidas > 0
              : false;

      final bool success =
          respuesta['success'] == true && !hayFallidas;

      debugPrint('SUCCESS: $success');
      debugPrint('HTTP STATUS: ${respuesta['http_status']}');
      debugPrint('CITAS AGENDADAS: ${respuesta['citas_agendadas']}');
      debugPrint('CITAS FALLIDAS: $fallidas');
      /*
      if (success) {
        _mostrarMensaje(
          respuesta['message']?.toString() ??
              'Agendamiento completado.',
        );

        Navigator.pop(context, respuesta);
      } */
        if (success) {
          debugPrint('AGENDAMIENTO CORRECTO');
          debugPrint('RESPUESTA COMPLETA: $respuesta');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AgendamientoExitosoScreen(
                respuesta: respuesta,
                citasAgendadas: selecciones,
              ),
            ),
          );
        } else {
        _mostrarMensaje(
          respuesta['message']?.toString() ??
              'No fue posible confirmar las citas.',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('========== ERROR AL AGENDAR ==========');
      debugPrint('TIPO: ${e.runtimeType}');
      debugPrint('ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        _mostrarMensaje(
          'Error al agendar. Revisa la consola.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _enviandoCitas = false;
        });
      }

      debugPrint('=========== FIN AGENDAMIENTO ==========');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sesiones = _selectedDay == null
        ? <_SesionDoble>[]
        : _sesionesDelDia(_selectedDay!);

    final fechasConAgenda = _sesionesDisponibles
        .map((sesion) => sesion.inicio)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar citas'),
        backgroundColor: azul,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _nombreServicio,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: TableCalendar<DateTime>(
                        locale: 'es_CO',
                        firstDay: DateTime.now().subtract(
                          const Duration(days: 1),
                        ),
                        lastDay: DateTime.now().add(
                          const Duration(days: 365),
                        ),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            _selectedDay != null &&
                            _mismaFecha(day, _selectedDay!),
                        eventLoader: (day) {
                          return fechasConAgenda.where(
                            (fecha) => _mismaFecha(fecha, day),
                          ).toList();
                        },
                        calendarFormat: CalendarFormat.month,
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Mes',
                        },
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        calendarStyle: const CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Color(0x553693EB),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: azul,
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: verde,
                            shape: BoxShape.circle,
                          ),
                          markersMaxCount: 3,
                          outsideDaysVisible: false,
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        onDaySelected: (selected, focused) {
                          setState(() {
                            _selectedDay = selected;
                            _focusedDay = focused;
                          });
                        },
                        onPageChanged: (focused) {
                          _focusedDay = focused;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    _selectedDay == null
                        ? 'Horarios disponibles'
                        : 'Horarios del ${_fechaTexto(_selectedDay!)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (sesiones.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'No hay horarios disponibles para este día.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  else
                    ...sesiones.map(_construirSesion),

                  const SizedBox(height: 16),

                  if (_sesionesSeleccionadas.isNotEmpty) ...[
                    const Text(
                      'Tu selección',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ..._sesionesSeleccionadas.map((sesion) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.check_circle,
                          color: verde,
                        ),
                        title: Text(
                          '${_fechaHoraInicial(sesion.primero.inicio)}'
                          ' y ${_intervalo(sesion.segundo.inicio, 30)}',
                        ),
                        subtitle: Text(
                          'IDs: ${_obtenerIdCita(sesion.primero.registro)}'
                          ' / ${_obtenerIdCita(sesion.segundo.registro)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _enviandoCitas
                              ? null
                              : () {
                                  setState(() {
                                    _sesionesSeleccionadas.removeWhere(
                                      (item) =>
                                          item.clave == sesion.clave,
                                    );
                                  });
                                },
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 6,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Citas seleccionadas: '
                    '$_citasSeleccionadasCount / ${widget.cantidadMaxima}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          widget.cantidadMaxima > 0 &&
                                  _citasSeleccionadasCount ==
                                      widget.cantidadMaxima &&
                                  !_enviandoCitas
                              ? _confirmarSeleccion
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: azul,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                      child: Text(
                        _enviandoCitas
                            ? 'Agendando citas...'
                            : 'Confirmar selección',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirSesion(_SesionDoble sesion) {
    final seleccionada = _sesionSeleccionada(sesion);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _enviandoCitas
            ? null
            : () => _seleccionarSesion(sesion),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: seleccionada
                ? azul.withValues(alpha: 0.08)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: seleccionada ? azul : verde,
                width: 4,
              ),
            ),
          ),
          child: Column(
            children: [
              if (seleccionada)
                const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.check_circle,
                    color: azul,
                  ),
                ),

              _construirHorarioIndividual(sesion.primero),

              const SizedBox(height: 8),

              _construirHorarioIndividual(sesion.segundo),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirHorarioIndividual(_GrupoHorario horario) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.schedule,
            color: azul,
            size: 22,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _hora(horario.inicio),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),

                Text(
                  _intervalo(horario.inicio, 30),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// AGENDAMIENTO CORRECTO ////////////////////////////////////////
class AgendamientoExitosoScreen extends StatelessWidget {
  final Map<String, dynamic> respuesta;
  final List<Map<String, dynamic>> citasAgendadas;

  const AgendamientoExitosoScreen({
    super.key,
    required this.respuesta,
    required this.citasAgendadas,
  });

  String texto(dynamic valor) {
    return valor?.toString().trim() ?? '';
  }

  String fechaBonita(dynamic valor) {
    final fecha = texto(valor);
    final partes = fecha.split('-');

    if (partes.length == 3 && partes[0].length == 4) {
      return '${partes[2]}/${partes[1]}/${partes[0]}';
    }

    return fecha;
  }

  @override
  Widget build(BuildContext context) {
    final azul = const Color(0xFF0D6EFD);
    final verde = const Color(0xFF00A54F);

    // Si la API devuelve una lista de citas confirmadas,
    // utiliza esa lista; de lo contrario, muestra las
    // selecciones enviadas que fueron confirmadas exitosamente.
    final dynamic citasRespuesta = respuesta['citas_agendadas'];

    final List<Map<String, dynamic>> citas = citasRespuesta is List &&
            citasRespuesta.isNotEmpty &&
            citasRespuesta.every((item) => item is Map)
        ? citasRespuesta
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList()
        : citasAgendadas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamiento confirmado'),
        backgroundColor: azul,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 20),

                  Icon(
                    Icons.check_circle,
                    size: 90,
                    color: verde,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    '¡Agendamiento exitoso!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Tus citas fueron agendadas correctamente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 24),

                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.event_available,
                        color: verde,
                        size: 35,
                      ),
                      title: const Text('Citas agendadas'),
                      subtitle: Text(
                        'Total: ${citas.length}',
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Detalle de tus citas',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...citas.asMap().entries.map((entrada) {
                    final indice = entrada.key;
                    final cita = entrada.value;

                    final fecha = cita['fecha'] ??
                        cita['fecha_cita'] ??
                        cita['date'];

                    final hora = cita['hora'] ??
                        cita['hora_cita'] ??
                        cita['time'];

                    final examen = cita['examen'] ??
                        cita['nameExam'] ??
                        cita['servicio'] ??
                        cita['exam'] ??
                        'Cita ${indice + 1}';

                    final profesional = cita['profesional'] ??
                        cita['nameProfessional'] ??
                        cita['profesional_nombre'];

                    final direccion = cita['direccion']?.toString() ?? '';
                    final sede = cita['nombre_sede']?.toString() ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: verde,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Cita ${indice + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Divider(),

                            Text('Servicio: ${texto(examen)}'),

                            const SizedBox(height: 8),

                            if (texto(fecha).isNotEmpty)
                              Text(
                                'Fecha: ${fechaBonita(fecha)}',
                              ),

                            if (texto(hora).isNotEmpty)
                              Text('Hora: ${texto(hora)}'),

                            if (texto(profesional).isNotEmpty)
                              Text(
                                'Profesional: ${texto(profesional)}',
                              ),
                            
                            if (texto(sede).isNotEmpty)
                              Text(
                                'Sede: ${texto(sede)}',
                              ),

                            if (direccion.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Color(0xFF0D6EFD),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text('Dirección: $direccion'),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const InicioScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Volver al inicio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: azul,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

*/