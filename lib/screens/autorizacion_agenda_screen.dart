import 'package:flutter/material.dart';

class AgendamientoScreen extends StatefulWidget {
  final String tipoServicio;

  const AgendamientoScreen({
    super.key,
    required this.tipoServicio,
  });

  @override
  State<AgendamientoScreen> createState() => _AgendamientoScreenState();
}

class _AgendamientoScreenState extends State<AgendamientoScreen> {
  int currentStep = 0;

  // DATOS DEL AGENDAMIENTO //

  String? ciudadSeleccionada;
  String? sedeSeleccionada;
  String? profesionalSeleccionado;
  DateTime? fechaSeleccionada;

  bool cargando = false;
  bool bloqueoSalida = false;

  int sesionesAutorizadas = 8;

  static const int maxSesionesSemana = 6;

  final Map<String, List<String>> seleccionesPorFecha = {};

  // DATOS TEMPORALES //

  final List<String> ciudades = [
    'Bogotá',
    'Ibagué',
    'Florencia',
  ];

  final List<String> sedes = [
    'Norte',
    'Sur Occidente',
    'Centro',
  ];

  final List<String> profesionales = [
    'Profesional 1',
    'Profesional 2',
    'Profesional 3',
  ];

  final List<String> horas = [
    '07:30',
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
  ];

  // INFORMACIÓN DEL SERVICIO //

  bool get esParticular =>
      widget.tipoServicio == 'Particular';

  bool get esDivertido =>
      widget.tipoServicio == 'Divertido';

  bool get esHidroterapia =>
      widget.tipoServicio == 'EPS-ARL';

  bool get necesitaProfesional {

    return false;
  }

  bool get necesitaPiscina {
    return false;
  }

  String get tituloPaso1 {
    if (esParticular || esDivertido) {
      return 'Soporte de pago';
    }

    return 'Autorización';
  }

  String get subtituloPaso1 {
    if (esParticular || esDivertido) {
      return 'Servicios pagados';
    }

    return 'Servicios autorizados';
  }

  // WIZARD //

  void siguientePaso() {
    if (currentStep < 3) {
      setState(() {
        currentStep++;
      });
    }
  }

  void pasoAnterior() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  void irAlPaso(int paso) {
    if (paso >= 0 && paso <= 3) {
      setState(() {
        currentStep = paso;
      });
    }
  }

  // PASO 1 //

  Widget construirPasoAutorizacion() {
    return Column(
      children: [
        const SizedBox(height: 10),

        if (esParticular)
          construirTarifasParticular(),

        if (esDivertido)
          construirTarifasDivertido(),

        if (!esParticular && !esDivertido)
          construirAutorizacion(),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.home),
              label: const Text('Ir al inicio'),
            ),
          ],
        ),
      ],
    );
  }

  Widget construirAutorizacion() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.verified,
              size: 60,
              color: Color(0xFF00A54F),
            ),

            const SizedBox(height: 15),

            const Text(
              'Autorización registrada',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            const Text(
              'Puedes continuar con la selección de tus citas.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed: () {
                irAlPaso(1);
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text('Continuar con la agenda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TARIFAS PARTICULAR // 

  Widget construirTarifasParticular() {
    final tarifas = [
      {
        'id': 'ibague',
        'nombre': 'Ibagué y Florencia',
        'primera':
            'Valoración inicial por Fisioterapia.\n8 sesiones de Hidroterapia.\nEntrega de informe final.',
        'siguientes':
            '10 sesiones de Hidroterapia.\nEntrega de informe final.',
        'valor': '\$ 242.000',
      },
      {
        'id': 'norte',
        'nombre': 'Norte',
        'primera':
            'Valoración inicial por Fisioterapia.\n8 sesiones de Hidroterapia.\nEntrega de informe final.',
        'siguientes':
            '10 sesiones de Hidroterapia.\nEntrega de informe final.',
        'valor': '\$ 368.000',
      },
      {
        'id': 'sur',
        'nombre': 'Sur Occidente y Centro',
        'primera':
            'Valoración inicial por Fisioterapia.\n8 sesiones de Hidroterapia.\nEntrega de informe final.',
        'siguientes':
            '10 sesiones de Hidroterapia.\nEntrega de informe final.',
        'valor': '\$ 305.000',
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'TARIFAS PARTICULARES HIDROTERAPIA 2026',
              style: TextStyle(
                color: Color(0xFF0D6EFD),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 15),

            ...tarifas.map(
              (tarifa) => construirTarjetaTarifa(
                nombre: tarifa['nombre']!,
                detalle: tarifa['primera']!,
                valor: tarifa['valor']!,
                onTap: () {
                  mostrarDetalleTarifa(
                    tarifa['nombre']!,
                    tarifa['valor']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TARIFAS DIVERTIDO // 

  Widget construirTarifasDivertido() {
    final tarifas = [
      {
        'nombre': '4 clases - Individuales',
        'valor': '\$ 225.400',
      },
      {
        'nombre': '4 clases - Grupales',
        'valor': '\$ 196.000',
      },
      {
        'nombre': '8 clases - Individuales',
        'valor': '\$ 450.800',
      },
      {
        'nombre': '8 clases - Grupales',
        'valor': '\$ 392.000',
      },
      {
        'nombre': '12 clases - Individuales',
        'valor': '\$ 676.200',
      },
      {
        'nombre': '12 clases - Grupales',
        'valor': '\$ 588.000',
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'TARIFAS DIVERTIDO - CLASES DE NATACIÓN',
              style: TextStyle(
                color: Color(0xFF0D6EFD),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 15),

            ...tarifas.map(
              (tarifa) => construirTarjetaTarifa(
                nombre: tarifa['nombre']!,
                detalle: '',
                valor: tarifa['valor']!,
                onTap: () {
                  mostrarDetalleTarifa(
                    tarifa['nombre']!,
                    tarifa['valor']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget construirTarjetaTarifa({
    required String nombre,
    required String detalle,
    required String valor,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D6EFD).withOpacity(.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.business,
                  color: Color(0xFF0D6EFD),
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    if (detalle.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        detalle,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    Text(
                      valor,
                      style: const TextStyle(
                        color: Color(0xFF0D6EFD),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Color(0xFF0D6EFD),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // DETALLE TARIFA //

  void mostrarDetalleTarifa(
    String nombre,
    String valor,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Información de pago',
            style: TextStyle(
              color: Color(0xFF0D6EFD),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.receipt_long,
                size: 60,
                color: Color(0xFF00A54F),
              ),

              const SizedBox(height: 15),

              Text(
                nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                valor,
                style: const TextStyle(
                  color: Color(0xFF0D6EFD),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'No olvides enviarnos tu comprobante de pago.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              const Text(
                'Puedes realizar el pago mediante transferencia a la cuenta de ahorro o escaneando el código QR.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FCF8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Banco Davivienda',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '450800252030',
                      style: TextStyle(
                        color: Color(0xFF00A54F),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text('Cuenta de ahorro'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Volver'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Aquí posteriormente:
                // Navigator.push(... AutorizacionScreen ...)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.black,
              ),
              child: const Text(
                'Registrar soporte',
              ),
            ),
          ],
        );
      },
    );
  }

  // PASO 2 - AGENDA // 

  Widget construirAgenda() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona tus citas',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Selecciona ciudad, sede y fecha para consultar la agenda disponible.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 25),

        DropdownButtonFormField<String>(
          value: ciudadSeleccionada,
          decoration: const InputDecoration(
            labelText: 'Ciudad',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_city),
          ),
          items: ciudades
              .map(
                (ciudad) => DropdownMenuItem(
                  value: ciudad,
                  child: Text(ciudad),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              ciudadSeleccionada = value;
              sedeSeleccionada = null;
              profesionalSeleccionado = null;
              fechaSeleccionada = null;
            });

            cargarSedes(value);
          },
        ),

        const SizedBox(height: 20),

        DropdownButtonFormField<String>(
          value: sedeSeleccionada,
          decoration: const InputDecoration(
            labelText: 'Sede',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business),
          ),
          items: ciudadSeleccionada == null
              ? []
              : sedes
                  .map(
                    (sede) => DropdownMenuItem(
                      value: sede,
                      child: Text(sede),
                    ),
                  )
                  .toList(),
          onChanged: ciudadSeleccionada == null
              ? null
              : (value) {
                  setState(() {
                    sedeSeleccionada = value;
                    fechaSeleccionada = null;
                  });

                  validarSede(value);
                },
        ),

        const SizedBox(height: 20),

        if (necesitaProfesional) ...[
          DropdownButtonFormField<String>(
            value: profesionalSeleccionado,
            decoration: const InputDecoration(
              labelText: 'Profesional',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            items: profesionales
                .map(
                  (profesional) => DropdownMenuItem(
                    value: profesional,
                    child: Text(profesional),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                profesionalSeleccionado = value;
                fechaSeleccionada = null;
              });
            },
          ),

          const SizedBox(height: 20),
        ],

        InkWell(
          onTap: sedeSeleccionada == null
              ? null
              : seleccionarFecha,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Fecha',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.calendar_month),
              enabled: sedeSeleccionada != null,
            ),
            child: Text(
              fechaSeleccionada == null
                  ? 'Seleccionar fecha'
                  : formatearFecha(fechaSeleccionada!),
            ),
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: puedeBuscarAgenda
                ? especialidadAgenda
                : null,
            icon: const Icon(Icons.search),
            label: const Text('Buscar agenda'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A54F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
            ),
          ),
        ),

        const SizedBox(height: 25),

        construirListaAgenda(),
      ],
    );
  }

  bool get puedeBuscarAgenda {
    return ciudadSeleccionada != null &&
        sedeSeleccionada != null &&
        fechaSeleccionada != null;
  }

  // CIUDAD / SEDE //

  void cargarSedes(String? ciudad) {
    if (ciudad == null) return;
  }

  void validarSede(String? sede) {
    if (sede == null) return;
  }

  // FECHA //

  Future<void> seleccionarFecha() async {
    final hoy = DateTime.now();

    final fecha = await showDatePicker(
      context: context,
      initialDate: hoy,
      firstDate: hoy,
      lastDate: hoy.add(
        const Duration(days: 30),
      ),
    );

    if (fecha == null) return;

    setState(() {
      fechaSeleccionada = fecha;
    });
  }

  String formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  // AGENDA //

  void especialidadAgenda() {
    if (!puedeBuscarAgenda) return;

    setState(() {
      cargando = true;
    });

    Future.delayed(
      const Duration(seconds: 1),
      () {
        if (!mounted) return;

        setState(() {
          cargando = false;
        });
      },
    );
  }

  Widget construirListaAgenda() {
    if (cargando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 15),
              Text(
                '¡Cargando, por favor espere!',
              ),
            ],
          ),
        ),
      );
    }

    if (!puedeBuscarAgenda) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agenda disponible',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 15),

            Text(
              '${ciudadSeleccionada ?? ''} - '
              '${sedeSeleccionada ?? ''}',
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: horas
                  .map(
                    (hora) => construirBotonHora(
                      hora,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget construirBotonHora(String hora) {
    final fecha = fechaSeleccionada == null
        ? ''
        : fechaParaApi(fechaSeleccionada!);

    final seleccionada =
        seleccionesPorFecha[fecha]?.contains(hora) ?? false;

    return ElevatedButton(
      onPressed: () {
        seleccionarHora(
          fecha,
          hora,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: seleccionada
            ? const Color(0xFF00A54F)
            : Colors.white,
        foregroundColor: seleccionada
            ? Colors.white
            : const Color(0xFF0D6EFD),
        side: const BorderSide(
          color: Color(0xFF0D6EFD),
        ),
      ),
      child: Text(hora),
    );
  }

  // SELECCIÓN DE CITAS //

  void seleccionarHora(
    String fecha,
    String hora,
  ) {
    if (fecha.isEmpty) return;

    final lista =
        seleccionesPorFecha.putIfAbsent(
      fecha,
      () => [],
    );

    // Toggle
    if (lista.contains(hora)) {
      lista.remove(hora);

      if (lista.isEmpty) {
        seleccionesPorFecha.remove(fecha);
      }

      setState(() {});
      return;
    }

    // Máximo 2 por día
    if (lista.length >= 2) {
      mostrarAlerta(
        'Solo puedes seleccionar hasta 2 sesiones por día.',
      );
      return;
    }

    // Máximo semanal
    final sesionesSemana =
        contarSesionesSemana(fecha);

    if (sesionesSemana + 1 >
        maxSesionesSemana) {
      final rango =
          obtenerRangoSemana(fecha);

      mostrarAlerta(
        'No puedes seleccionar más de '
        '$maxSesionesSemana sesiones en la semana '
        'del ${rango['inicio']} al ${rango['fin']}.',
      );

      return;
    }

    // Máximo total autorizado
    final total =
        contarTotalSesiones();

    if (total + 1 > sesionesAutorizadas) {
      mostrarAlerta(
        'Has alcanzado el máximo de '
        '$sesionesAutorizadas sesiones autorizadas.',
      );

      return;
    }

    lista.add(hora);

    setState(() {});

    // Si se completó el paquete
    if (contarTotalSesiones() ==
        sesionesAutorizadas) {
      mostrarModalConfirmacion();
    }
  }

  // CONTADORES //

  int contarSesionesDia(String fecha) {
    return seleccionesPorFecha[fecha]?.length ?? 0;
  }

  int contarTotalSesiones() {
    int total = 0;

    for (final lista
        in seleccionesPorFecha.values) {
      total += lista.length;
    }

    return total;
  }

  int contarSesionesSemana(String fechaBase) {
    final semana =
        obtenerSemana(fechaBase);

    int total = 0;

    for (final entrada
        in seleccionesPorFecha.entries) {
      if (obtenerSemana(entrada.key) ==
          semana) {
        total += entrada.value.length;
      }
    }

    return total;
  }

  int obtenerSemana(String fecha) {
    final date = DateTime.parse(fecha);

    final firstDay =
        DateTime(date.year, 1, 1);

    final difference =
        date.difference(firstDay).inDays;

    return ((difference +
                firstDay.weekday) /
            7)
        .ceil();
  }

  Map<String, String> obtenerRangoSemana(
    String fecha,
  ) {
    final date = DateTime.parse(fecha);

    final lunes = date.subtract(
      Duration(
        days: date.weekday - 1,
      ),
    );

    final domingo = lunes.add(
      const Duration(days: 6),
    );

    return {
      'inicio': fechaParaApi(lunes),
      'fin': fechaParaApi(domingo),
    };
  }

  String fechaParaApi(DateTime fecha) {
    return '${fecha.year}-'
        '${fecha.month.toString().padLeft(2, '0')}-'
        '${fecha.day.toString().padLeft(2, '0')}';
  }

  // CONFIRMACIÓN DE SELECCIONES //

  void mostrarModalConfirmacion() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final duracion =
            esDivertido ? '45 minutos' : '30 minutos';

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: Color(0xFF00A54F),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Confirma tus citas',
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 65,
                color: Color(0xFF00A54F),
              ),

              const SizedBox(height: 15),

              const Text(
                '¡Ya casi terminas!',
                style: TextStyle(
                  color: Color(0xFF00A54F),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Has seleccionado todas las sesiones '
                'autorizadas ($sesionesAutorizadas).',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FCF8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF00A54F),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Recuerde que las sesiones '
                        'tienen una duración de $duracion.',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Al confirmar, podrás revisar el resumen completo de tus citas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actionsAlignment:
              MainAxisAlignment.center,
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                continuarSeleccion();
              },
              icon: const Icon(
                Icons.chevron_right,
              ),
              label: const Text(
                'Continuar agendando',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF00A54F),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  // ENVIAR SELECCIONES //

  void continuarSeleccion() {
    setState(() {
      cargando = true;
    });

    Future.delayed(
      const Duration(seconds: 1),
      () {
        if (!mounted) return;

        setState(() {
          cargando = false;
          currentStep = 2;
          bloqueoSalida = true;
        });
      },
    );
  }

  // PASO 3 // 

  Widget construirConfirmacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirmación',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Información de agendamiento',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 20),

        if (seleccionesPorFecha.isEmpty)
          const Text(
            'No hay citas seleccionadas.',
          )
        else
          ...seleccionesPorFecha.entries.map(
            (entry) {
              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.calendar_month,
                    color: Color(0xFF0D6EFD),
                  ),
                  title: Text(entry.key),
                  subtitle: Text(
                    entry.value.join(' - '),
                  ),
                ),
              );
            },
          ),

        const SizedBox(height: 25),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: confirmarCita,
            icon: const Icon(Icons.check),
            label: const Text(
              'Confirmar citas',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF00A54F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // CONFIRMAR CITA //

  void confirmarCita() {
    setState(() {
      cargando = true;
    });

    Future.delayed(
      const Duration(seconds: 1),
      () {
        if (!mounted) return;

        setState(() {
          cargando = false;
          currentStep = 3;
          bloqueoSalida = false;
        });
      },
    );
  }

  // PASO 4 //

  Widget construirResultado() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 30),

          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F7EE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 60,
              color: Color(0xFF00A54F),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            '¡Agendamiento realizado!',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00A54F),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          const Text(
            'Tus citas han sido registradas correctamente.',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 30),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.home),
            label: const Text(
              'Ir al inicio',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF0D6EFD),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ALERTA //

  void mostrarAlerta(String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: Colors.orange,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Restricción de selección',
                ),
              ),
            ],
          ),
          content: Text(mensaje),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // BLOQUEO DE SALIDA // 

  Future<bool> confirmarSalida() async {
    if (!bloqueoSalida) {
      return true;
    }

    final salir = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: Colors.orange,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Agendamiento incompleto',
                ),
              ),
            ],
          ),
          content: const Text(
            '¿Deseas salir sin completar el agendamiento?\n\n'
            'Tienes sesiones de hidroterapia pendientes '
            'por programar. Si sales ahora, debes iniciar '
            'nuevamente el proceso para completar tus citas.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Continuar agendando',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );

    if (salir == true) {
      bloqueoSalida = false;
      return true;
    }

    return false;
  }

  // BUILD //

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !bloqueoSalida,
      onPopInvokedWithResult:
          (didPop, result) async {
        if (didPop) return;

        final puedeSalir =
            await confirmarSalida();

        if (puedeSalir && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Agendamiento',
          ),
          backgroundColor:
              const Color(0xFF0D6EFD),
          foregroundColor: Colors.white,
        ),

        body: SafeArea(
          child: Column(
            children: [
              construirWizard(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _construirContenidoPaso(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIZARD VISUAL // 

  Widget construirWizard() {
    final pasos = [
      {
        'titulo': tituloPaso1,
        'subtitulo': subtituloPaso1,
      },
      {
        'titulo': 'Agenda',
        'subtitulo': 'Selecciona tus citas',
      },
      {
        'titulo': 'Confirmación',
        'subtitulo': 'Información de agendamiento',
      },
      {
        'titulo': 'Listo',
        'subtitulo': 'Resultado del agendamiento',
      },
    ];

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            pasos.length,
            (index) {
              final activo =
                  currentStep == index;

              final completado =
                  currentStep > index;

              return GestureDetector(
                onTap: () {
                  // Solo permitir volver a pasos anteriores.
                  if (index <= currentStep) {
                    irAlPaso(index);
                  }
                },
                child: Container(
                  width: 180,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: completado
                              ? const Color(
                                  0xFF00A54F,
                                )
                              : const Color(
                                  0xFF0D6EFD,
                                ),
                        ),
                        alignment: Alignment.center,
                        child: completado
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                              )
                            : Text(
                                '${index + 1}',
                                style:
                                    const TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              pasos[index]
                                  ['titulo']!,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              pasos[index]
                                  ['subtitulo']!,
                              style:
                                  const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _construirContenidoPaso() {
    switch (currentStep) {
      case 0:
        return construirPasoAutorizacion();

      case 1:
        return construirAgenda();

      case 2:
        return construirConfirmacion();

      case 3:
        return construirResultado();

      default:
        return const SizedBox.shrink();
    }
  }
}