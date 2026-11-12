import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oficina_virtual_movil/services/api_service.dart';
import 'crear_autorizacion_screen.dart';
import '../../services/auth_service.dart';
import 'calendario_screen.dart';
import '../../services/app_data.dart';

class ConvenioScreen extends StatefulWidget {
  final Map<String, dynamic> respuestaApi;
  final String tipoServicio;

  const ConvenioScreen({
    super.key,
    required this.respuestaApi,
    required this.tipoServicio,
  });

  @override
  State<ConvenioScreen> createState() => _ConvenioScreenState();
}

class _ConvenioScreenState extends State<ConvenioScreen> {
  // AUTORIZACIÓN EXISTE //

  //bool get ocultarFiltroPiscina => especialidadSeleccionada == '36';

  String? _sedeFijadaId;
  String? _sedeFijadaNombre;
  String? _sedeFijadaDireccion;
  String? _ciudadFijada;
  DateTime? _fechaMinimaSiguienteExamen;

  bool get sedeBloqueada => _sedeFijadaId != null;

  bool get ocultarFiltroPiscina => ['36', '19'].contains(especialidadSeleccionada);

  bool get autorizacionExiste { return widget.respuestaApi['autorizacion_encontrada'] == true; }

  // CAMBIO: detectar correctamente la autorización pendiente.
  bool get autorizacionExistePendiente {
    return autorizacionExiste && widget.respuestaApi['aprobada'] == false; }

  // CAMBIO: detectar autorización aprobada.
  bool get autorizacionAprobada {
    return autorizacionExiste &&
        widget.respuestaApi['aprobada'] == true;
  }

  List<Map<String, dynamic>> piscinas = [];
  bool cargandoPiscinas = false;
  String? piscinaSeleccionada;

  // AUTORIZACIÓN //
  Map<String, dynamic> get datosAutorizacion {
    final data = widget.respuestaApi['autorizacion'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {};
  }

  void almacenarDatosAutorizacion() {
    final autorizacion = datosAutorizacion;

    AppData.autorizacionId =
        (autorizacion['id_autorizacion'] ?? '').toString();

    AppData.numeroAutorizacion =
        (autorizacion['numero_autorizacion'] ?? '').toString();

    AppData.fechaInicio =
        autorizacion['fecha_inicio']?.toString();

    AppData.fechaFinal =
        autorizacion['fecha_fin']?.toString();

    AppData.fechaInicior = autorizacion['fecha_inicio_r']?.toString();

    AppData.fechaFinalr =autorizacion['fecha_fin_r']?.toString();

    AppData.sede_agenda = autorizacion['sede']?.toString();

    final contratoRaw = widget.respuestaApi['contrato'];

    final Map<String, dynamic> contrato =
        contratoRaw is Map<String, dynamic>
            ? contratoRaw
            : <String, dynamic>{};

    AppData.codeContract = contrato['codeContract']?.toString() ?? '';
    AppData.codePlan = contrato['codePlan']?.toString() ?? '';
    AppData.codeRegimen = contrato['codeRegime']?.toString() ?? '';
    AppData.codeTypeAffiliate =
        contrato['codeTypeAffiliate']?.toString() ?? '';
    AppData.codeLevelAffiliate =
        contrato['codeLevelAffiliate']?.toString() ?? '';

    final paqueteRaw = widget.respuestaApi['paquetes'];

    if (paqueteRaw is List && paqueteRaw.isNotEmpty) {
      final primerPaquete = paqueteRaw.first;

      if (primerPaquete is Map) {
        AppData.examen =
            primerPaquete['id_examen']?.toString() ?? '';
      }
    } else if (paqueteRaw is Map) {
      AppData.examen =
          paqueteRaw['id_examen']?.toString() ?? '';
    } else {
      AppData.examen = '';
    }

    debugPrint('========== APPDATA AUTORIZACIÓN ==========');
    debugPrint('ID autorización: ${AppData.autorizacionId}');
    debugPrint('Número: ${AppData.numeroAutorizacion}');
    debugPrint('Fecha inicio: ${AppData.fechaInicio}');
    debugPrint('Fecha fin: ${AppData.fechaFinal}');
    debugPrint('Contrato: ${AppData.codeContract}');
    debugPrint('Plan: ${AppData.codePlan}');
    debugPrint('Régimen: ${AppData.codeRegimen}');
    debugPrint('Tipo afiliado: ${AppData.codeTypeAffiliate}');
    debugPrint('Nivel afiliado: ${AppData.codeLevelAffiliate}');
    debugPrint('Paquetes: ${AppData.paquete}');
    debugPrint('==========================================');
  }

  void inicializarPaquetes() {
  final data = widget.respuestaApi['paquetes'];

  if (data is List) {
    _paquetesTrabajo = data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  avanzarPaqueteDisponible();
}

void inicializarFechaMinimaSiguienteExamen() {
  final citasRaw = widget.respuestaApi['citas'];

  if (citasRaw is! List || citasRaw.isEmpty) {
    debugPrint('La autorización no tiene citas previas.');
    return;
  }

  final fechas = citasRaw
      .whereType<Map>()
      .where((cita) => cita['dateAppointment'] != null)
      .map((cita) => DateTime.tryParse(
            cita['dateAppointment'].toString(),
          ))
      .whereType<DateTime>()
      .toList();

  if (fechas.isEmpty) return;

  // Obtener la fecha cronológicamente más antigua.
  fechas.sort();

  final primeraFecha = fechas.first;

  // La siguiente cita debe ser desde el día siguiente.
  _fechaMinimaSiguienteExamen = DateTime(
    primeraFecha.year,
    primeraFecha.month,
    primeraFecha.day,
  ).add(const Duration(days: 1));

  debugPrint('========== CONTROL DE FECHAS ==========');
  debugPrint('Primera cita: $primeraFecha');
  debugPrint('Fecha mínima siguiente examen: '
      '$_fechaMinimaSiguienteExamen');
  debugPrint('=======================================');
}

void avanzarPaqueteDisponible() {
    while (paqueteActualIndex < _paquetesTrabajo.length) {
      final disponible = int.tryParse(
            _paquetesTrabajo[paqueteActualIndex]
                        ['cantidad_disponible']
                    ?.toString() ??
                '0',
          ) ??
          0;

      if (disponible > 0) break;

      paqueteActualIndex++;
    }
  }

  Future<void> procesarResultadoPaquete(
    Map<String, dynamic> resultado,
  ) async {
    if (resultado['success'] != true) return;

    final citas = resultado['citasAgendadas'];

    if (citas is! List || citas.isEmpty) return;

    final citasConfirmadas = citas
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();


    if (_fechaMinimaSiguienteExamen == null &&
        citasConfirmadas.isNotEmpty) {

      final primeraCita = citasConfirmadas.first;

      final fechaTexto = primeraCita['fecha'] ??
          primeraCita['fecha_cita'] ??
          primeraCita['date'];

      if (fechaTexto != null) {
        final fechaPrimeraCita =
          DateTime.tryParse(fechaTexto.toString());

        if (fechaPrimeraCita != null) {
          _fechaMinimaSiguienteExamen =
              fechaPrimeraCita.add(const Duration(days: 1));
        }    

        debugPrint(
          'FECHA MÍNIMA PARA LOS SIGUIENTES EXÁMENES: '
          '$_fechaMinimaSiguienteExamen',
        );
      }
    }

    final paquete = paqueteActual;

    if (paquete == null) return;

    final cantidadAgendada = citasConfirmadas.length;

    final cantidadAnterior = int.tryParse(
          paquete['cantidad_disponible']?.toString() ?? '0',
        ) ??
        0;

    final cantidadRealizadaAnterior = int.tryParse(
          paquete['cantidad_realizada']?.toString() ?? '0',
        ) ??
        0;

    if (!sedeBloqueada) {
      _ciudadFijada = ciudadController.text.trim();
      _sedeFijadaId = sedeController.text.trim();
      _sedeFijadaNombre = nombreSedeSeleccionada;
      _sedeFijadaDireccion = direccionSedeSeleccionada;
    }    

    setState(() {
      paquete['cantidad_disponible'] =
          (cantidadAnterior - cantidadAgendada).clamp(0, cantidadAnterior);

      paquete['cantidad_realizada'] =
          cantidadRealizadaAnterior + cantidadAgendada;

      _todasLasCitasAgendadas.addAll(citasConfirmadas);

      paqueteActualIndex++;

      avanzarPaqueteDisponible();

      mostrarFiltrosAgenda = false;
      consultandoAgenda = false;

      ciudadController.text = ciudadController.text;

      if (sedeBloqueada) {
        ciudadController.text = _ciudadFijada!;
        sedeController.text = _sedeFijadaId!;
      }

      piscinaController.clear();
      piscinaSeleccionada = null;
      piscinas = [];
      fechaSeleccionada = null;

/*
      ciudadController.clear();
      sedeController.clear();
      piscinaController.clear();
      piscinaSeleccionada = null;
      piscinas = [];
      fechaSeleccionada = null;*/
    });

    if (paqueteActual == null) {
      final respuestaFinal = <String, dynamic>{
        'success': true,
        'citas_agendadas': _todasLasCitasAgendadas,
      };

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AgendamientoExitosoScreen(
            respuesta: respuestaFinal,
            citasAgendadas: _todasLasCitasAgendadas,
          ),
        ),
      );

      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Paquete completado. Continúa con el servicio '
          '${paqueteActualIndex + 1} de ${_paquetesTrabajo.length}.',
        ),
      ),
    );
  }

  // PAQUETES //
  List<Map<String, dynamic>> get paquetes {
    if (_paquetesTrabajo.isNotEmpty) {
      return _paquetesTrabajo;
    }

    final data = widget.respuestaApi['paquetes'];

    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  final AuthService authService = AuthService();
  bool consultandoAgenda = false;

  List<Map<String, dynamic>> _paquetesTrabajo = [];

    int paqueteActualIndex = 0;

    final List<Map<String, dynamic>> _todasLasCitasAgendadas = [];

    Map<String, dynamic>? get paqueteActual {
      if (_paquetesTrabajo.isEmpty ||
          paqueteActualIndex >= _paquetesTrabajo.length) {
        return null;
      }

      return _paquetesTrabajo[paqueteActualIndex];
    }

    String get especialidadSeleccionada {
      return paqueteActual?['id_examen']?.toString() ?? '';
    }

    int get cantidadDisponiblePaquete {
      return int.tryParse(
            paqueteActual?['cantidad_disponible']?.toString() ?? '0',
          ) ??
          0;
    }

    int get cantidadRealizadaPaquete {
      return int.tryParse(
            paqueteActual?['cantidad_realizada']?.toString() ?? '0',
          ) ??
          0;
    }

  // Filtros para la consulta de disponibilidad.
  bool mostrarFiltrosAgenda = false;
  final TextEditingController ciudadController = TextEditingController();
  final TextEditingController sedeController = TextEditingController();
  final TextEditingController piscinaController = TextEditingController();
  DateTime? fechaSeleccionada;

  // Ciudades y sedes equivalentes a la función PHP filtros_ciudad().
  final Map<String, String> ciudades = {
    'BOG': 'Bogotá D.C.',
    'CHI': 'Chía',
    'FLO': 'Florencia',
    'IBA': 'Ibagué',
  };

  final Map<String, String> sedesPorCiudad = {
    '1': 'BOG',
    '2': 'CHI',
    '3': 'BOG',
    '4': 'BOG',
    '5': 'FLO',
    '6': 'IBA',
    '7': 'BOG',
  };
/*
  String get sedeAutorizacion {
    return (datosAutorizacion['sede'] ?? '').toString().trim();
  }
*/

  String get sedeAutorizacion {
    return (AppData.sede_agenda ?? '').toString().trim();
  }

  bool sedeCoincide(Map<String, String> sede, String codigo) {
    final valor = codigo.trim();

    if (valor.isEmpty) return false;

    return sede['codeOffice'] == valor ||
        sede['idOffice'] == valor;
  }

  String get ciudadSedeAutorizacion {
    final codigo = sedeAutorizacion;

    if (codigo.isEmpty) return '';

    if (servicio.trim().toUpperCase() == 'DIVERTIDO') {
      return (codigo == '01' || codigo == '8') ? 'BOG' : '';
    }

    for (final entrada in sedesPorCiudadL.entries) {
      if (entrada.value.any((sede) => sedeCoincide(sede, codigo))) {
        return entrada.key;
      }
    }

    return '';
  }

  List<MapEntry<String, String>> get ciudadesDisponibles {
    final tipo = servicio.trim().toUpperCase();

    if (tipo == 'DIVERTIDO') {
      if (sedeAutorizacion.isNotEmpty &&
          ciudadSedeAutorizacion != 'BOG') {
        return [];
      }

      return [
        MapEntry('BOG', 'Bogotá D.C.'),
      ];
    }

    if (sedeAutorizacion.isNotEmpty) {
      final ciudad = ciudadSedeAutorizacion;

      if (ciudad.isEmpty) return [];

      return [
        MapEntry(ciudad, ciudades[ciudad]!),
      ];
    }

    return ciudades.entries.toList();
  }

/*
  List<MapEntry<String, String>> get ciudadesDisponibles {
    final tipo = servicio.trim().toUpperCase();
    final sede = sedeAutorizacion;

    if (tipo == 'DIVERTIDO') {
      if (sede.isNotEmpty && sede != '1') {
        return [];
      }

      return [
        MapEntry('BOG', 'Bogotá D.C.'),
      ];
    }

    if (sede.isNotEmpty) {
      final codigoCiudad = sedesPorCiudad[sede];

      if (codigoCiudad == null) {
        return [];
      }

      return [
        MapEntry(
          codigoCiudad,
          ciudades[codigoCiudad]!,
        ),
      ];
    }

    return ciudades.entries.toList();
  }
*/
  final Map<String, List<Map<String, String>>> sedesPorCiudadL = {
    'CHI': [
      {
        'idOffice': '2',
        'codeOffice': '002',
        'nameOffice': 'RHB - CHIA',
        'direccion': 'Calle 10 # 8-37',
      },
    ],
    'FLO': [
      {
        'idOffice': '5',
        'codeOffice': '005',
        'nameOffice': 'RHB - FLORENCIA',
        'direccion': 'Diagonal 10 # 17-77',
      },
    ],
    'IBA': [
      {
        'idOffice': '6',
        'codeOffice': '006',
        'nameOffice': 'RHB - IBAGUÉ',
        'direccion': 'Calle 35 # 4B-15',
      },
    ],
    'BOG': [
      {
        'idOffice': '1',
        'codeOffice': '001',
        'nameOffice': 'HDT - BGTA NORTE',
        'direccion': 'Calle 142 # 16A-52',
      },
      {
        'idOffice': '3',
        'codeOffice': '003',
        'nameOffice': 'HDT - BGTA SUR OCCIDENTE',
        'direccion': 'Calle 5A # 71B-27',
      },
      {
        'idOffice': '4',
        'codeOffice': '004',
        'nameOffice': 'RHB - BGTA SUR OCCIDENTE',
        'direccion': 'Calle 6 # 71A-31',
      },
      {
        'idOffice': '7',
        'codeOffice': '007',
        'nameOffice': 'HDT - BOGOTÁ CENTRO',
        'direccion': 'Carrera 32B # 4-27',
      },
    ],
  };

  List<Map<String, String>> get sedesDisponibles {
    final ciudad = ciudadController.text.trim();

    if (ciudad.isEmpty) {
      return [];
    }

    if (servicio.trim().toUpperCase() == 'DIVERTIDO') {
      if (ciudad != 'BOG') {
        return [];
      }

      final sedesDivertido = <Map<String, String>>[
        {
          'idOffice': '8',
          'codeOffice': '01',
          'nameOffice': 'CEDRITOS',
          'direccion': 'Calle 142 No 16A-52',
        },
      ];

      if (sedeAutorizacion.isNotEmpty) {
        return sedesDivertido
            .where((sede) => sedeCoincide(sede, sedeAutorizacion))
            .toList();
      }

      return sedesDivertido;
    }

    final sedes = sedesPorCiudadL[ciudad] ?? [];

    if (sedeAutorizacion.isNotEmpty) {
      return sedes
          .where((sede) => sedeCoincide(sede, sedeAutorizacion))
          .toList();
    }

    return sedes;
  }

/*
  List<Map<String, String>> get sedesDisponibles {
    final ciudad = ciudadController.text.trim();

    if (ciudad.isEmpty) {
      return [];
    }

    if (servicio == 'Divertido') {
      if (ciudad != 'BOG') {
        return [];
      }

      final sedesDivertido = <Map<String, String>>[
        {
          'idOffice': '8',
          'codeOffice': '01',
          'nameOffice': 'CEDRITOS',
        },
      ];

      if (sedeAutorizacion.isNotEmpty) {
        return sedesDivertido
            .where((sede) =>
                sede['idOffice'] == sedeAutorizacion)
            .toList();
      }

      return sedesDivertido;
    }

    final sedes = sedesPorCiudadL[ciudad] ?? [];

    if (sedeAutorizacion.isNotEmpty) {
      return sedes
          .where((sede) =>
              sede['idOffice'] == sedeAutorizacion)
          .toList();
    }

    return sedes;
  }
*/
  Future<void> cargarPiscinas() async {
    if (!mounted) return;

    setState(() {
      cargandoPiscinas = true;
      piscinas = [];
      piscinaSeleccionada = null;
      piscinaController.clear();
    });

    try {
      debugPrint('TIPO SERVICIO: $servicio');
      debugPrint('EXAMEN: ${AppData.examen}');
      debugPrint('OFICINA: ${sedeController.text}');

      final respuesta = await authService.filtroPiscina(
        tipo_servicio: servicio,
        //especialidad: AppData.examen,
        especialidad: especialidadSeleccionada,
        oficina: sedeController.text.trim(),
      );

      debugPrint('RESPUESTA API PISCINA: $respuesta');

      if (!mounted) return;

      if (respuesta['success'] == true) {
        final opciones = respuesta['opciones'];

        if (opciones is List) {
          setState(() {
            piscinas = opciones
                .map<Map<String, dynamic>>(
                  (opcion) => {
                    'id': opcion.toString(),
                    'nombre': opcion.toString(),
                  },
                )
                .toList();
          });

          debugPrint('Piscinas cargadas: ${piscinas.length}');
        } else {
          debugPrint('La respuesta no contiene una lista en "opciones".');
        }
      } else {
        debugPrint(
          'Error consultando piscinas: ${respuesta['message']}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('ERROR AL CONSULTAR PISCINAS: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) {
        setState(() {
          cargandoPiscinas = false;
        });
      }
    }
  }

  void mostrarFiltros() {
    // CAMBIO: no permitir abrir filtros si está pendiente.
    if (!autorizacionAprobada) return;

    setState(() {
      mostrarFiltrosAgenda = true;
    });
  }

  Future<void> seleccionarFecha() async {
    final DateTime hoy = DateTime.now();
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada ?? hoy,
      firstDate: DateTime(hoy.year, hoy.month, hoy.day),
      lastDate: hoy.add(const Duration(days: 365)),
      helpText: 'Seleccionar fecha de la cita',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (fecha != null && mounted) {
      setState(() {
        fechaSeleccionada = fecha;
      });
    }
  }

  String get fechaFiltro {
    if (fechaSeleccionada == null) return '';
    final fecha = fechaSeleccionada!;
    return '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    ciudadController.dispose();
    sedeController.dispose();
    piscinaController.dispose();
    super.dispose();
  }

  Future<void> abrirAgenda() async {
    if (!autorizacionAprobada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tienes una autorización pendiente de verificación. '
            'Una vez sea validada, recibirás la notificación en tu '
            'correo electrónico, para que puedas continuar con el '
            'proceso de agendamiento.',
          ),
        ),
      );
      return;
    }

    final paquete = paqueteActual;

    if (paquete == null || cantidadDisponiblePaquete <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay paquetes pendientes por agendar.'),
        ),
      );
      return;
    }

    setState(() {
      consultandoAgenda = true;
    });

    try {
      final String tipoServicio = servicio;
      final String especialidad = especialidadSeleccionada;
      final String oficina = sedeController.text.trim();
      final String profesor = piscinaController.text.trim();

      AppData.examen = especialidad;

      debugPrint('========== CONSULTA DE AGENDA ==========');
      debugPrint('PAQUETE: ${paqueteActualIndex + 1}');
      debugPrint('ESPECIALIDAD: $especialidad');
      debugPrint('CANTIDAD DISPONIBLE: $cantidadDisponiblePaquete');
      debugPrint('OFICINA: $oficina');
      debugPrint('PISCINA: $profesor');

      final respuesta = await authService.consultarAgendaDisponible(
        tipoServicio: tipoServicio,
        especialidad: especialidad,
        oficina: oficina,
        profesor: profesor,
        ciudad: ciudadController.text.trim(),
        sede: oficina,
        piscina: profesor,
        fechadeseada: fechaFiltro,
        fechafinal: AppData.fechaFinal,
      );

      debugPrint('RESPUESTA AGENDA: $respuesta');

      if (!mounted) return;

      final hayAgenda = respuesta['agenda_disponible'] == true;
      final dataAgenda = respuesta['agenda'];

      final List<Map<String, dynamic>> citas = dataAgenda is List
          ? dataAgenda
              .whereType<Map>()
              .map((cita) => Map<String, dynamic>.from(cita))
              .toList()
          : [];

      if (!hayAgenda || citas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              respuesta['message']?.toString() ??
                  'No hay citas disponibles.',
            ),
          ),
        );
        return;
      }

      final resultado = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => SeleccionarCitasScreen(
            tipoServicio: tipoServicio,
            especialidad: especialidad,
            oficina: oficina,
            profesor: profesor,
            respuestaApi: respuesta,
            datosAgendamiento: {
              'usuario_id': AppData.idPaciente,
              'autorizacion_id': AppData.autorizacionId,
              'numero_autorizacion': AppData.numeroAutorizacion,
              'documentPatient': AppData.documentoIdentidad,
              'documentType': AppData.tipoDocumento,
              'email': AppData.correoElectronico,
              'cellPhone': AppData.celular,
              'codeContract': AppData.codeContract,
              'codePlan': AppData.codePlan,
              'codeRegime': AppData.codeRegimen,
              'codeTypeAffiliate': AppData.codeTypeAffiliate,
              'codeLevelAffiliate': AppData.codeLevelAffiliate,
            },
            citas: citas,
            cantidadMaxima: cantidadDisponiblePaquete,
            sedeSeleccionada: nombreSedeSeleccionada,
            direccionsede: direccionSedeSeleccionada,
            fechaMinima: _fechaMinimaSiguienteExamen,
          ),
        ),
      );

      if (!mounted) return;

      if (resultado != null && resultado['success'] == true) {
        await procesarResultadoPaquete(resultado);
      }
    } catch (e, stackTrace) {
      debugPrint('ERROR CONSULTANDO AGENDA: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error consultando agenda: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          consultandoAgenda = false;
        });
      }
    }
  }

  String get direccionSedeSeleccionada {
    final ciudad = ciudadController.text.trim();
    final codigoSede = sedeController.text.trim();

    final sedes = sedesDisponibles;

    final sedeSeleccionada = sedes.firstWhere(
      (sede) => sede['codeOffice'] == codigoSede,
      orElse: () => <String, String>{},
    );

    return sedeSeleccionada['direccion'] ?? '';
  }

  String get nombreSedeSeleccionada {
    final codigoSede = sedeController.text.trim();

    final sede = sedesDisponibles.firstWhere(
      (sede) => sede['codeOffice'] == codigoSede,
      orElse: () => <String, String>{},
    );

    return sede['nameOffice'] ?? '';
  }

  // CANTIDAD AUTORIZADA //
  int get cantidadAutorizada {
    int total = 0;
    for (final paquete in paquetes) { 
      final cantidad =
          int.tryParse(
            paquete['cantidad_autorizada']?.toString() ?? '0',
          ) ??
          0;
      total += cantidad;
    }
    return total;
  }

  // CANTIDAD AGENDADA //
  int get cantidadAgendada {
    int total = 0;
    for (final paquete in paquetes) {
      final cantidad =
          int.tryParse(
            paquete['control_citas']?.toString() ?? '0',
          ) ??
          0;
      total += cantidad;
    }
    return total;
  }

  // CANTIDAD REALIZADA / CITAS AGENDADAS //
  int get cantidadRealizada {
    final cantidad = widget.respuestaApi['conteo_citas'];
    return int.tryParse(
          cantidad?.toString() ?? '0',
        ) ??
        0;
  }

  // CANTIDAD DISPONIBLE //
  int get cantidadDisponible {
    int total = 0;
    for (final paquete in paquetes) {
      final cantidad =
          int.tryParse(
            paquete['cantidad_disponible']?.toString() ?? '0',
          ) ??
          0;
      total += cantidad;
    }
    return total;
  }

  // SERVICIO //
  String get servicio {
    final tipo = datosAutorizacion['tipo']?.toString() ?? '';
    if (tipo.isEmpty) {
      return widget.tipoServicio;
    }
    return tipo;
  }

  // ABRIR CREAR AUTORIZACIÓN //
  void abrirCrearAutorizacion() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AutorizacionScreen(
          tipoServicio: widget.tipoServicio,
        ),
      ),
    );
  }

  // SELECCION DE SEDEEEE

  void inicializarSedeAgenda() {
    final codigo = sedeAutorizacion;

    if (codigo.isEmpty) return;

    final ciudad = ciudadSedeAutorizacion;

    if (ciudad.isEmpty) {
      debugPrint('No se encontró ciudad para sede_agenda: $codigo');
      return;
    }

    ciudadController.text = ciudad;

    final sedes = sedesPorCiudadL[ciudad] ?? [];

    final sede = sedes.firstWhere(
      (item) => sedeCoincide(item, codigo),
      orElse: () => <String, String>{},
    );

    if (sede.isNotEmpty) {
      // Siempre guardar el código de oficina.
      sedeController.text = sede['codeOffice'] ?? '';

      debugPrint('========== SEDE DE AUTORIZACIÓN ==========');
      debugPrint('Sede recibida: $codigo');
      debugPrint('Ciudad: $ciudad');
      debugPrint('ID oficina: ${sede['idOffice']}');
      debugPrint('Código oficina: ${sede['codeOffice']}');
      debugPrint('Nombre: ${sede['nameOffice']}');
      debugPrint('==========================================');
    }
  }

  // TEXTO DEL CONVENIO //
  String get tituloConvenio {
    switch (widget.tipoServicio.toUpperCase()) {
      case 'EPS-ARL':
        return 'EPS / ARL';
      case 'PARTICULAR':
        return 'PARTICULAR';
      case 'DIVERTIDO':
        return 'DIVERTIDO';
      default:
        return widget.tipoServicio;
    }
  }

  // DESCRIPCIÓN DEL CONVENIO //
  String get descripcionConvenio {
    switch (widget.tipoServicio.toUpperCase()) {
      case 'EPS-ARL':
        return 'Registra una autorización de EPS o ARL.';
      case 'PARTICULAR':
        return 'Registra una autorización para atención particular.';
      case 'DIVERTIDO':
        return 'Registra una autorización para el programa Divertido.';
      default:
        return 'Registra una nueva autorización.';
    }
  }

  // INIT //
  @override
  void initState() {
    super.initState();

    if (autorizacionExiste) {
      almacenarDatosAutorizacion();

      inicializarFechaMinimaSiguienteExamen();

      inicializarSedeAgenda();

      inicializarPaquetes();

      AppData.examen = especialidadSeleccionada;
    }

    debugPrint('==========================================');
    debugPrint('TIPO CONVENIO: ${widget.tipoServicio}');
    debugPrint('SEDE_AGENDA: ${AppData.sede_agenda}');
    debugPrint('SEDE SELECCIONADA: ${sedeController.text}');
    debugPrint('CIUDAD SELECCIONADA: ${ciudadController.text}');
    debugPrint('AUTORIZACIÓN ENCONTRADA: $autorizacionExiste');
    debugPrint('AUTORIZACIÓN PENDIENTE: $autorizacionExistePendiente');
    debugPrint('AUTORIZACIÓN APROBADA: $autorizacionAprobada');
    debugPrint('CITAS AGENDADAS: $cantidadRealizada');
    debugPrint('CANTIDAD AUTORIZADA: $cantidadAutorizada');
    debugPrint('CANTIDAD DISPONIBLE: $cantidadDisponible');
    debugPrint('RESPUESTA API: ${widget.respuestaApi}');
    debugPrint('==========================================');
  }
  
  /*
  @override
  void initState() {
    super.initState();

    if (autorizacionExiste) {
      almacenarDatosAutorizacion();
      inicializarPaquetes();

      AppData.examen = especialidadSeleccionada;
    }

    debugPrint('==========================================');
    debugPrint('TIPO CONVENIO: ${widget.tipoServicio}');
    debugPrint('AUTORIZACIÓN ENCONTRADA: $autorizacionExiste');
    debugPrint('AUTORIZACIÓN PENDIENTE: $autorizacionExistePendiente');
    debugPrint('AUTORIZACIÓN APROBADA: $autorizacionAprobada');
    debugPrint('CITAS AGENDADAS: $cantidadRealizada');
    debugPrint('CANTIDAD AUTORIZADA: $cantidadAutorizada');
    debugPrint('CANTIDAD DISPONIBLE: $cantidadDisponible');
    debugPrint('RESPUESTA API: ${widget.respuestaApi}');
    debugPrint('==========================================');
  }
*/
  // BUILD //
  @override
  Widget build(BuildContext context) {
    final existe = autorizacionExiste;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Autorizaciones',
          style: TextStyle(
            color: Color(0xFF222222),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF333333),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Autorizaciones',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                existe
                    ? 'Hemos encontrado una autorización para tu servicio.'
                    : 'No encontramos una autorización registrada.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF777777),
                ),
              ),
              const SizedBox(height: 28),

              if (existe)
                _mostrarAutorizacion()
              else
                _mostrarSinAutorizacion(),
            ],
          ),
        ),
      ),
    );
  }

  // MOSTRAR AUTORIZACIÓN //
  Widget _mostrarAutorizacion() {
    final numero =
        datosAutorizacion['numero']?.toString() ?? '';
    final estado =
        datosAutorizacion['estado']?.toString() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF0D6EFD),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.accessibility_new,
                color: Color(0xFF4285F4),
                size: 30,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  servicio.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4285F4),
                  ),
                ),
              ),
            ],
          ),

          // CAMBIO: mensaje para autorización pendiente.
          if (autorizacionExistePendiente) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                border: Border.all(
                  color: const Color(0xFFFFD666),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF856404),
                    size: 25,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tienes una autorización pendiente de verificación. '
                      'Una vez sea validada, recibirás la notificación en tu '
                      'correo electrónico, para que puedas continuar con el '
                      'proceso de agendamiento.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF856404),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
              _mostrarPaquetes(),
            /*
            const SizedBox(height: 15),
            Text(
              'Citas agendadas: '
              '$cantidadRealizada de $cantidadAutorizada',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4285F4),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Disponibles: $cantidadDisponible',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),*/
          ],

          if (numero.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              'Autorización: $numero',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF777777),
              ),
            ),
          ],

          if (estado.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              'Estado: $estado',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF777777),
              ),
            ),
          ],

          // CAMBIO: los filtros solo se muestran si está aprobada.
          if (mostrarFiltrosAgenda && autorizacionAprobada) ...[
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: ciudadesDisponibles.any(
                (ciudad) => ciudad.key == ciudadController.text,
              )
                  ? ciudadController.text
                  : null,
              decoration: const InputDecoration(
                labelText: 'Ciudad',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(),
              ),
              hint: const Text('Seleccione una ciudad'),
              isExpanded: true,
              items: ciudadesDisponibles.map((ciudad) {
                return DropdownMenuItem<String>(
                  value: ciudad.key,
                  child: Text(ciudad.value),
                );
              }).toList(),
              onChanged: sedeBloqueada
                ? null
                : (codigo) {
                  setState(() {
                    ciudadController.text = codigo ?? '';
                    sedeController.clear();
                  });

                debugPrint('Ciudad seleccionada: $codigo');
              },
            ),

            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: sedesDisponibles.any(
                (sede) => sede['codeOffice'] == sedeController.text,
              )
                  ? sedeController.text
                  : null,
              decoration: const InputDecoration(
                labelText: 'Sede',
                border: OutlineInputBorder(),
              ),
              items: sedesDisponibles.map((sede) {
                return DropdownMenuItem<String>(
                  value: sede['codeOffice'],
                  child: Text(
                    sede['nameOffice']!,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (codigo) async {
                setState(() {
                  sedeController.text = codigo ?? '';
                  piscinaController.clear();
                  piscinaSeleccionada = null;
                  piscinas = [];
                });

                debugPrint('Sede seleccionada: ${sedeController.text}');

                if (codigo != null && codigo.isNotEmpty) {
                  await cargarPiscinas();
                }
              },
            ),

            if (!ocultarFiltroPiscina) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: piscinaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Piscina',
                  prefixIcon: Icon(Icons.pool),
                  border: OutlineInputBorder(),
                ),
                hint: Text(
                  cargandoPiscinas
                      ? 'Consultando piscinas...'
                      : 'Seleccione una piscina',
                ),
                isExpanded: true,
                items: piscinas.map((piscina) {
                  final valor = piscina['id']?.toString() ?? '';
                  final nombre = piscina['nombre']?.toString() ?? '';

                  return DropdownMenuItem<String>(
                    value: valor,
                    child: Text(nombre),
                  );
                }).toList(),
                onChanged: cargandoPiscinas
                    ? null
                    : (valor) {
                        setState(() {
                          piscinaSeleccionada = valor;
                          piscinaController.text = valor ?? '';
                        });

                        debugPrint('Piscina seleccionada: $valor');
                      },
              ),
            ],
            const SizedBox(height: 12),
            InkWell(
              onTap: seleccionarFecha,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  prefixIcon: Icon(Icons.calendar_month),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  fechaSeleccionada == null
                      ? 'Seleccionar fecha'
                      : fechaFiltro,
                ),
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: consultandoAgenda ? null : abrirAgenda,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A54F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  consultandoAgenda
                      ? 'Consultando agenda...'
                      : 'Consultar disponibilidad',
                ),
              ),
            ),
          ],

          // CAMBIO: ocultar botón de agendamiento si está pendiente.
          if (autorizacionAprobada) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: cantidadDisponiblePaquete > 0 && !consultandoAgenda
                    ? mostrarFiltros
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                  child: Text(
                    consultandoAgenda
                        ? 'Consultando agenda...'
                        : paqueteActual == null
                            ? 'Todas las citas agendadas'
                            : 'Agendar citas',
                  ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _mostrarPaquetes() {
    if (paquetes.isEmpty) {
      return const Text(
        'No hay paquetes asociados a esta autorización.',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF777777),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Paquetes de la autorización',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 10),

        ...paquetes.asMap().entries.map((entry) {
          // Primero obtenemos el índice y el paquete.
          final indice = entry.key;
          final paquete = entry.value;

          // Información del paquete.
          final examen =
              paquete['id_examen']?.toString() ?? 'Sin identificar';

          final autorizadas =
              paquete['cantidad_autorizada']?.toString() ?? '0';

          final realizadas =
              paquete['cantidad_realizada']?.toString() ?? '0';

          final disponibles =
              paquete['cantidad_disponible']?.toString() ?? '0';

          // Estado del paquete.
          final cantidadDisponible =
              int.tryParse(disponibles) ?? 0;

          final bool completado = cantidadDisponible <= 0;
          final bool esActual = indice == paqueteActualIndex;

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  AppData.nombreServicio(paquete['id_examen']).isNotEmpty
                      ? AppData.nombreServicio(paquete['id_examen'])
                      : 'Servicio $examen',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  completado
                      ? 'Estado: Completado'
                      : esActual
                          ? 'Estado: Pendiente de agendamiento'
                          : 'Estado: En espera',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: completado
                        ? Colors.green
                        : esActual
                            ? const Color(0xFF0D6EFD)
                            : Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                  Text(
                    'Citas agendadas: $realizadas de $autorizadas',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF555555),
                    ),
                  ),
                /*const SizedBox(height: 4),
                Text('Cantidad disponible: $disponibles'),*/
              ],
            ),
          );
        }),
      ],
    );
  }

  // SIN AUTORIZACIÓN //
  Widget _mostrarSinAutorizacion() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF0D6EFD),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_outlined,
                color: Color(0xFF4285F4),
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No hay autorización',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tipo de convenio: $tituloConvenio',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            descripcionConvenio,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: abrirCrearAutorizacion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A54F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              child: Text(
                'Registrar $tituloConvenio',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oficina_virtual_movil/services/api_service.dart';
import 'crear_autorizacion_screen.dart';
import '../../services/auth_service.dart';
import 'calendario_screen.dart';
import '../../services/app_data.dart';


class ConvenioScreen extends StatefulWidget {
  final Map<String, dynamic> respuestaApi;

  final String tipoServicio;
  const ConvenioScreen({
    super.key,
    required this.respuestaApi,
    required this.tipoServicio,
  });
  @override
  State<ConvenioScreen> createState() => _ConvenioScreenState();
}

class _ConvenioScreenState extends State<ConvenioScreen> {

  // AUTORIZACIÓN EXISTE //
  bool get autorizacionExiste {
    return widget.respuestaApi['autorizacion_encontrada'] == true;
  }

  bool get autorizacionExistePendiente {
    return widget.respuestaApi['aprobada'] == false;
  }

    List<Map<String, dynamic>> piscinas = [];
    bool cargandoPiscinas = false;
    String? piscinaSeleccionada;

  // AUTORIZACIÓN //
  Map<String, dynamic> get datosAutorizacion {
    final data = widget.respuestaApi['autorizacion'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {};
  }

  void almacenarDatosAutorizacion() {
    final autorizacion = datosAutorizacion;

    // Datos principales de la autorización.
    AppData.autorizacionId =
        (autorizacion['id_autorizacion'] ?? '').toString();

    AppData.numeroAutorizacion =
        (autorizacion['numero_autorizacion'] ?? '').toString();

    AppData.fechaInicio =
        autorizacion['fecha_inicio']?.toString();

    AppData.fechaFinal =
        autorizacion['fecha_fin']?.toString();

    AppData.fechaInicior =
        autorizacion['fecha_inicio_r']?.toString();

    AppData.fechaFinalr =
        autorizacion['fecha_fin_r']?.toString();

    // Datos del contrato: están en la sección "contrato".
    final contratoRaw = widget.respuestaApi['contrato'];

    final Map<String, dynamic> contrato =
        contratoRaw is Map<String, dynamic>
            ? contratoRaw
            : <String, dynamic>{};

    AppData.codeContract = contrato['codeContract']?.toString() ?? '';
    AppData.codePlan = contrato['codePlan']?.toString() ?? '';
    AppData.codeRegimen = contrato['codeRegime']?.toString() ?? '';
    AppData.codeTypeAffiliate = contrato['codeTypeAffiliate']?.toString() ?? '';
    AppData.codeLevelAffiliate = contrato['codeLevelAffiliate']?.toString() ?? '';

    final paqueteRaw = widget.respuestaApi['paquetes'];

      if (paqueteRaw is List && paqueteRaw.isNotEmpty) {
        final primerPaquete = paqueteRaw.first;

        if (primerPaquete is Map) {
          AppData.examen =
              primerPaquete['id_examen']?.toString() ?? '';
        }
      } else if (paqueteRaw is Map) {
        AppData.examen =
            paqueteRaw['id_examen']?.toString() ?? '';
      } else {
        AppData.examen = '';
      }


    // Verificar los datos almacenados.
    debugPrint('========== APPDATA AUTORIZACIÓN ==========');
    debugPrint('ID autorización: ${AppData.autorizacionId}');
    debugPrint('Número: ${AppData.numeroAutorizacion}');
    debugPrint('Fecha inicio: ${AppData.fechaInicio}');
    debugPrint('Fecha fin: ${AppData.fechaFinal}');
    debugPrint('Contrato: ${AppData.codeContract}');
    debugPrint('Plan: ${AppData.codePlan}');
    debugPrint('Régimen: ${AppData.codeRegimen}');
    debugPrint('Tipo afiliado: ${AppData.codeTypeAffiliate}');
    debugPrint('Nivel afiliado: ${AppData.codeLevelAffiliate}');
    debugPrint('Paquetes: ${AppData.paquete}');
    debugPrint('==========================================');
  }

  // PAQUETES // 
  List<Map<String, dynamic>> get paquetes {
    final data = widget.respuestaApi['paquetes'];
    if (data is! List) {
      return [];
    }
    return data
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }
  final AuthService authService = AuthService();
    bool consultandoAgenda = false;

  // Filtros para la consulta de disponibilidad.
  bool mostrarFiltrosAgenda = false;
  final TextEditingController ciudadController = TextEditingController();
  final TextEditingController sedeController = TextEditingController();
  final TextEditingController piscinaController = TextEditingController();
  DateTime? fechaSeleccionada;

  ////////////////////////////////////////////////////////////////////////
  // Ciudades y sedes equivalentes a la función PHP filtros_ciudad().
  final Map<String, String> ciudades = {
    'BOG': 'Bogotá D.C.',
    'CHI': 'Chía',
    'FLO': 'Florencia',
    'IBA': 'Ibagué',
  };

  final Map<String, String> sedesPorCiudad = {
    '1': 'BOG',
    '2': 'CHI',
    '3': 'BOG',
    '4': 'BOG',
    '5': 'FLO',
    '6': 'IBA',
    '7': 'BOG',
  };

  String get sedeAutorizacion {
    return (datosAutorizacion['sede'] ?? '').toString().trim();
  }

  List<MapEntry<String, String>> get ciudadesDisponibles {
    final tipo = servicio.trim().toUpperCase();
    final sede = sedeAutorizacion;

    if (tipo == 'Divertido') {
      if (sede.isNotEmpty && sede != '1') {
        return [];
      }

      return [
        MapEntry('BOG', 'Bogotá D.C.'),
      ];
    }

    if (sede.isNotEmpty) {
      final codigoCiudad = sedesPorCiudad[sede];

      if (codigoCiudad == null) {
        return [];
      }

      return [
        MapEntry(
          codigoCiudad,
          ciudades[codigoCiudad]!,
        ),
      ];
    }

    return ciudades.entries.toList();
  }

//////////////////////////////////////////////////////////////////////

  final Map<String, List<Map<String, String>>> sedesPorCiudadL = {
    'CHI': [
      {
        'idOffice': '2',
        'codeOffice': '002',
        'nameOffice': 'RHB - CHIA',
        'direccion': 'Calle 10 # 8-37',
      },
    ],
    'FLO': [
      {
        'idOffice': '5',
        'codeOffice': '005',
        'nameOffice': 'RHB - FLORENCIA',
        'direccion': 'Diagonal 10 # 17-77',
      },
    ],
    'IBA': [
      {
        'idOffice': '6',
        'codeOffice': '006',
        'nameOffice': 'RHB - IBAGUÉ',
        'direccion': 'Calle 35 # 4B-15',
      },
    ],
    'BOG': [
      {
        'idOffice': '1',
        'codeOffice': '001',
        'nameOffice': 'HDT - BGTA NORTE',
        'direccion': 'Calle 142 # 16A-52',
      },
      {
        'idOffice': '3',
        'codeOffice': '003',
        'nameOffice': 'HDT - BGTA SUR OCCIDENTE',
        'direccion': 'Calle 5A # 71B-27',
      },
      {
        'idOffice': '4',
        'codeOffice': '004',
        'nameOffice': 'RHB - BGTA SUR OCCIDENTE',
        'direccion': 'Calle 6 # 71A-31',
      },
      {
        'idOffice': '7',
        'codeOffice': '007',
        'nameOffice': 'HDT - BOGOTÁ CENTRO',
        'direccion': 'Carrera 32B # 4-27',
      },
    ],
  };

  List<Map<String, String>> get sedesDisponibles {
    final ciudad = ciudadController.text.trim();

    if (ciudad.isEmpty) {
      return [];
    }

    if (servicio == 'Divertido') {
      if (ciudad != 'BOG') {
        return [];
      }

      final sedesDivertido = <Map<String, String>>[
        {
          'idOffice': '8',
          'codeOffice': '01',
          'nameOffice': 'CEDRITOS',
        },
      ];

      if (sedeAutorizacion.isNotEmpty) {
        return sedesDivertido
            .where((sede) =>
                sede['idOffice'] == sedeAutorizacion)
            .toList();
      }

      return sedesDivertido;
    }

    final sedes = sedesPorCiudadL[ciudad] ?? [];

    if (sedeAutorizacion.isNotEmpty) {
      return sedes
          .where((sede) =>
              sede['idOffice'] == sedeAutorizacion)
          .toList();
    }

    return sedes;
  }

///////////////////////////////////////////////////////////////////////

  Future<void> cargarPiscinas() async {
    if (!mounted) return;

    setState(() {
      cargandoPiscinas = true;
      piscinas = [];
      piscinaSeleccionada = null;
      piscinaController.clear();
    });

    try {

      debugPrint('TIPO SERVICIO: $servicio');
      debugPrint('EXAMEN: ${AppData.examen}');
      debugPrint('OFICINA: ${sedeController.text}');  

      final respuesta = await authService.filtroPiscina(
        tipo_servicio: servicio,
        especialidad: AppData.examen,
        oficina: sedeController.text.trim(),
      );

      debugPrint('RESPUESTA API PISCINA: $respuesta');

      if (!mounted) return;

      if (respuesta['success'] == true) {
        final opciones = respuesta['opciones'];

        if (opciones is List) {
          setState(() {
            piscinas = opciones
                .map<Map<String, dynamic>>(
                  (opcion) => {
                    'id': opcion.toString(),
                    'nombre': opcion.toString(),
                  },
                )
                .toList();
          });

          debugPrint('Piscinas cargadas: ${piscinas.length}');
        } else {
          debugPrint('La respuesta no contiene una lista en "opciones".');
        }
      } else {
        debugPrint(
          'Error consultando piscinas: ${respuesta['message']}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('ERROR AL CONSULTAR PISCINAS: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) {
        setState(() {
          cargandoPiscinas = false;
        });
      }
    }
  }

//////////////////////////////////////////////////////////////////////////////

  void mostrarFiltros() {
    setState(() {
      mostrarFiltrosAgenda = true;
    });
  }

  Future<void> seleccionarFecha() async {
    final DateTime hoy = DateTime.now();
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada ?? hoy,
      firstDate: DateTime(hoy.year, hoy.month, hoy.day),
      lastDate: hoy.add(const Duration(days: 365)),
      helpText: 'Seleccionar fecha de la cita',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (fecha != null && mounted) {
      setState(() {
        fechaSeleccionada = fecha;
      });
    }
  }

  String get fechaFiltro {
    if (fechaSeleccionada == null) return '';
    final fecha = fechaSeleccionada!;
    return '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    ciudadController.dispose();
    sedeController.dispose();
    piscinaController.dispose();
    super.dispose();
  }
    Future<void> abrirAgenda() async {
  setState(() {
    consultandoAgenda = true;
  });
  try {
    // Valores enviados a la API
    final String tipoServicio = servicio;
    final String especialidad = '11';
    final String oficina =  sedeController.text.trim();
    final String profesor = piscinaController.text.trim();
    final respuesta = await authService.consultarAgendaDisponible(
        tipoServicio: tipoServicio,
        especialidad: especialidad,
        oficina: oficina,
        profesor: profesor,
        ciudad: ciudadController.text.trim(),
        sede: oficina,
        piscina: profesor,
        fechadeseada: fechaFiltro,
      );
      debugPrint('RESPUESTA AGENDA: $respuesta');
      if (!mounted) return;
      final hayAgenda = respuesta['agenda_disponible'] == true;
      final dataAgenda = respuesta['agenda'];
      final List<Map<String, dynamic>> citas = dataAgenda is List
          ? dataAgenda
              .whereType<Map>()
              .map((cita) => Map<String, dynamic>.from(cita))
              .toList()
          : [];
      if (!hayAgenda || citas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              respuesta['message']?.toString() ??
                  'No hay citas disponibles.',
            ),
          ),
        );
        return;
      }
    // Pasar los cuatro valores y la respuesta a la siguiente pantalla
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeleccionarCitasScreen(
            tipoServicio: tipoServicio,
            especialidad: especialidad,
            oficina: oficina,
            profesor: profesor,
            respuestaApi: respuesta,
            datosAgendamiento: {
              'usuario_id': AppData.idPaciente,
              'autorizacion_id': AppData.autorizacionId,
              'numero_autorizacion': AppData.numeroAutorizacion,
              'documentPatient': AppData.documentoIdentidad,
              'documentType': AppData.tipoDocumento,
              'email': AppData.correoElectronico,
              'cellPhone': AppData.celular,
              'codeContract': AppData.codeContract,
              'codePlan': AppData.codePlan,
              'codeRegime': AppData.codeRegimen,
              'codeTypeAffiliate': AppData.codeTypeAffiliate,
              'codeLevelAffiliate': AppData.codeLevelAffiliate
              },
            citas: citas,
            cantidadMaxima: cantidadDisponible,
            sedeSeleccionada: nombreSedeSeleccionada,
            direccionsede: direccionSedeSeleccionada,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error consultando agenda: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          consultandoAgenda = false;
        });
      }
    }
  }

  String get direccionSedeSeleccionada {
    final ciudad = ciudadController.text.trim();
    final codigoSede = sedeController.text.trim();

    final sedes = sedesDisponibles;

    final sedeSeleccionada = sedes.firstWhere(
      (sede) => sede['codeOffice'] == codigoSede,
      orElse: () => <String, String>{},
    );

    return sedeSeleccionada['direccion'] ?? '';
  }

  String get nombreSedeSeleccionada {
    final codigoSede = sedeController.text.trim();

    final sede = sedesDisponibles.firstWhere(
      (sede) => sede['codeOffice'] == codigoSede,
      orElse: () => <String, String>{},
    );

    return sede['nameOffice'] ?? '';
  }

  // CANTIDAD AUTORIZADA // 
  int get cantidadAutorizada {
    int total = 0;
    for (final paquete in paquetes) {
      final cantidad =
          int.tryParse(
            paquete['cantidad_autorizada']?.toString() ?? '0',
          ) ??
          0;
      total += cantidad;
    }
    return total;
  }

  // CANTIDAD AGENDADA //
  int get cantidadAgendada {
    int total = 0;
    for (final paquete in paquetes) {
      final cantidad =
          int.tryParse(
            paquete['control_citas']?.toString() ?? '0',
          ) ??
          0;
      total += cantidad;
    }
    return total;
  }

  // CANTIDAD REALIZADA / CITAS AGENDADAS //
  int get cantidadRealizada {
    final cantidad =
        widget.respuestaApi['conteo_citas'];
    return int.tryParse(
          cantidad?.toString() ?? '0',
        ) ??
        0;
  }
  /*
  Map<String, List<String>> get controlCitas {
    final data = widget.respuestaApi['control_citas'];
    if (data is! Map) {
      return {};
    }
    final resultado = <String, List<String>>{};
    data.forEach((key, value) {
      if (value is List) {
        resultado[key.toString()] = value
            .map((fecha) => fecha.toString())
            .toList();
      }
    });
    return resultado;
  }
  */

  // CANTIDAD DISPONIBLE // 
  int get cantidadDisponible {
    int total = 0;
    for (final paquete in paquetes) {
      final cantidad =
          int.tryParse(
            paquete['cantidad_disponible']?.toString() ?? '0',
          ) ??
          0;
      total += cantidad;
    }
    return total;
  }

  // SERVICIO // 
  String get servicio {
    final tipo =
        datosAutorizacion['tipo']?.toString() ?? '';
    if (tipo.isEmpty) {
      return widget.tipoServicio;
    }
    return tipo;
  }

  // ABRIR CREAR AUTORIZACIÓN //
  void abrirCrearAutorizacion() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AutorizacionScreen(
          tipoServicio: widget.tipoServicio,
        ),
      ),
    );
  }

  // TEXTO DEL CONVENIO //
  String get tituloConvenio {
    switch (widget.tipoServicio.toUpperCase()) {
      case 'EPS-ARL':
        return 'EPS / ARL';
      case 'PARTICULAR':
        return 'PARTICULAR';
      case 'DIVERTIDO':
        return 'DIVERTIDO';
      default:
        return widget.tipoServicio;
    }
  }

  // DESCRIPCIÓN DEL CONVENIO //
  String get descripcionConvenio {
    switch (widget.tipoServicio.toUpperCase()) {
      case 'EPS-ARL':
        return 'Registra una autorización de EPS o ARL.';
      case 'PARTICULAR':
        return 'Registra una autorización para atención particular.';
      case 'DIVERTIDO':
        return 'Registra una autorización para el programa Divertido.';
      default:
        return 'Registra una nueva autorización.';
    }
  }

  // INIT //
  @override
  void initState() {
    super.initState();

    if (autorizacionExiste) {
      almacenarDatosAutorizacion();
    }

    debugPrint(
      '==========================================',
    );
    debugPrint(
      'TIPO CONVENIO: ${widget.tipoServicio}',
    );
    debugPrint(
      'AUTORIZACIÓN ENCONTRADA: $autorizacionExiste',
    );
    debugPrint(
      'AUTORIZACIÓN APROBADA: $autorizacionExistePendiente',
    );
    debugPrint(
      'CITAS AGENDADAS: $cantidadRealizada',
    );
    debugPrint(
      'CANTIDAD AUTORIZADA: $cantidadAutorizada',
    );
    debugPrint(
      'CANTIDAD DISPONIBLE: $cantidadDisponible',
    );
    debugPrint(
      'RESPUESTA API: ${widget.respuestaApi}',
    );
    debugPrint(
      '==========================================',
    );
  }

  // BUILD //
  @override
  Widget build(BuildContext context) {
    final existe = autorizacionExiste;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Autorizaciones',
          style: TextStyle(
            color: Color(0xFF222222),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF333333),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              const Text(
                'Autorizaciones',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                existe
                    ? 'Hemos encontrado una autorización para tu servicio.'
                    : 'No encontramos una autorización registrada.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF777777),
                ),
              ),
              const SizedBox(height: 28),

              // EXISTE AUTORIZACIÓN // 
              if (existe)
                _mostrarAutorizacion()

              // NO EXISTE AUTORIZACIÓN // 
              else
                _mostrarSinAutorizacion(),
            ],
          ),
        ),
      ),
    );
  }

  // MOSTRAR AUTORIZACIÓN // 
  Widget _mostrarAutorizacion() {
    final numero =
        datosAutorizacion['numero']
            ?.toString() ??
        '';
    final estado =
        datosAutorizacion['estado']
            ?.toString() ??
        '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF0D6EFD),
        ),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.accessibility_new,
                color: Color(0xFF4285F4),
                size: 30,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  servicio.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4285F4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Citas agendadas: '
            '$cantidadRealizada de '
            '$cantidadAutorizada',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4285F4),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Disponibles: $cantidadDisponible',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          if (numero.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              'Autorización: $numero',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF777777),
              ),
            ),
          ],
          if (estado.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              'Estado: $estado',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF777777),
              ),
            ),
          ],

          if (mostrarFiltrosAgenda) ...[
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: ciudadesDisponibles.any(
                (ciudad) => ciudad.key == ciudadController.text,
              )
                  ? ciudadController.text
                  : null,
              decoration: const InputDecoration(
                labelText: 'Ciudad',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(),
              ),
              hint: const Text('Seleccione una ciudad'),
              isExpanded: true,
              items: ciudadesDisponibles.map((ciudad) {
                return DropdownMenuItem<String>(
                  value: ciudad.key,
                  child: Text(ciudad.value),
                );
              }).toList(),
              onChanged: (codigo) {
                setState(() {
                  ciudadController.text = codigo ?? '';
                  sedeController.clear();
                });

                debugPrint('Ciudad seleccionada: $codigo');
              },
            ),

            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: sedesDisponibles.any(
                (sede) => sede['codeOffice'] == sedeController.text,
              )
                  ? sedeController.text
                  : null,
              decoration: const InputDecoration(
                labelText: 'Sede',
                border: OutlineInputBorder(),
              ),
              items: sedesDisponibles.map((sede) {
                return DropdownMenuItem<String>(
                  value: sede['codeOffice'],
                  child: Text(
                    sede['nameOffice']!,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (codigo) async {
                setState(() {
                  sedeController.text = codigo ?? '';
                  piscinaController.clear();
                  piscinaSeleccionada = null;
                  piscinas = [];
                });

                debugPrint('Sede seleccionada: ${sedeController.text}');

                if (codigo != null && codigo.isNotEmpty) {
                  await cargarPiscinas();
                }

              },
            ),
            
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: piscinaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Piscina',
                prefixIcon: Icon(Icons.pool),
                border: OutlineInputBorder(),
              ),
              hint: Text(
                cargandoPiscinas
                    ? 'Consultando piscinas...'
                    : 'Seleccione una piscina',
              ),
              isExpanded: true,
              items: piscinas.map((piscina) {
                // Estos nombres son ejemplos; deben coincidir con el JSON real.
                final valor = piscina['id']?.toString() ?? '';
                final nombre = piscina['nombre']?.toString() ?? '';

                return DropdownMenuItem<String>(
                  value: valor,
                  child: Text(nombre),
                );
              }).toList(),
              onChanged: cargandoPiscinas
                  ? null
                  : (valor) {
                      setState(() {
                        piscinaSeleccionada = valor;
                        piscinaController.text = valor ?? '';
                      });

                      debugPrint('Piscina seleccionada: $valor');
                    },
            ),

            const SizedBox(height: 12),
            InkWell(
              onTap: seleccionarFecha,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  prefixIcon: Icon(Icons.calendar_month),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  fechaSeleccionada == null
                      ? 'Seleccionar fecha'
                      : fechaFiltro,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: consultandoAgenda ? null : abrirAgenda,
                child: Text(
                  consultandoAgenda
                      ? 'Consultando agenda...'
                      : 'Consultar disponibilidad',
                ),
              ),
            ),
          ],

          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  cantidadDisponible > 0 && !consultandoAgenda
                    ? mostrarFiltros
                    : null,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFDC3545),
                foregroundColor:
                    Colors.white,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 12,
                ),
              ),
              child: Text(
                consultandoAgenda
                    ? 'Consultando agenda...'
                    : 'Continúa Agendando',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SIN AUTORIZACIÓN // 
  Widget _mostrarSinAutorizacion() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF0D6EFD),
        ),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_outlined,
                color: Color(0xFF4285F4),
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No hay autorización',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF4285F4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tipo de convenio: $tituloConvenio',
                      style: const TextStyle(
                        fontSize: 14,
                        color:
                            Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            descripcionConvenio,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  abrirCrearAutorizacion,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF00A54F),
                foregroundColor:
                    Colors.white,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              child: Text(
                'Registrar $tituloConvenio',
                style: const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

*/