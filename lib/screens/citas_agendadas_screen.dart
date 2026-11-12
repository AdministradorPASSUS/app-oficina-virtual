import 'package:flutter/material.dart';

class CitasAgendadasScreen extends StatefulWidget {
  final Map<String, dynamic> respuestaInicial;

  const CitasAgendadasScreen({
    super.key,
    required this.respuestaInicial,
  });

  @override
  State<CitasAgendadasScreen> createState() =>
      _CitasAgendadasScreenState();
}

class _CitasAgendadasScreenState
    extends State<CitasAgendadasScreen> {

  int currentStep = 0;

  bool cargandoAgenda = true;
  bool cargandoHistorial = false;

  final String nombreUsuario = 'Usuario PASSUS';

  List<Map<String, dynamic>> citasSolicitadas = [];
  List<Map<String, dynamic>> citasHistorial = [];

  @override
  void initState() {
    super.initState();

    final respuesta = widget.respuestaInicial;

    final solicitadas = respuesta['citas_solicitadas'] as List? ?? [];
    final historial = respuesta['citas_historial'] as List? ?? [];

    citasSolicitadas = solicitadas
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    citasHistorial = historial
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    cargandoAgenda = false;
    cargandoHistorial = false;
  }

  void irAlPaso(int paso) {
    if (paso < 0 || paso > 1) return;

    setState(() {
      currentStep = paso;
    });

    if (paso == 0) {
      cargarMiAgenda();
    } else {
      cargarHistorial();
    }
  }  

  Widget _buildTarjetaCita(Map<String, dynamic> cita) {

    final profesional = [ cita['firstGNameProfessional'], cita['secondGNameProfessional'], cita['firstFNameProfessional'], cita['secondFNameProfessional'],
    ].where((nombre) => nombre != null && nombre.toString().trim().isNotEmpty)
    .join(' ');
    final nameExam = cita['nameExam']?.toString() ?? '';
    final nameOffice = cita['nameOffice']?.toString() ?? '';
    final fecha = cita['dateAppointment']?.toString() ?? '';
    final hora = cita['timeAppointment']?.toString() ?? '';
    final estado = cita['nameState']?.toString() ?? '';

    Color colorEstado;

    switch (estado.toLowerCase().trim()) {
      case 'asistida':
        colorEstado = const Color(0xff00a54f);
        break;

      case 'no asistida':
        colorEstado = Colors.red;
        break;

      default:
        colorEstado = const Color(0xff0d6efd);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xffe0e0e0),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                color: Color(0xff0d6efd),
              ),
              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'Detalle de la cita',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colorEstado.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  estado,
                  style: TextStyle(
                    color: colorEstado,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 10),
          _filaDato(
            Icons.medical_services,
            'Cita',
            fecha.isEmpty ? 'No disponible' : nameExam,
          ),

          const Divider(height: 10),
          _filaDato(
            Icons.event,
            'Fecha',
            fecha.isEmpty ? 'No disponible' : fecha,
          ),

          const SizedBox(height: 10),
          _filaDato(
            Icons.access_time,
            'Hora',
            hora.isEmpty ? 'No disponible' : hora,
          ),

          const Divider(height: 10),
          _filaDato(
            Icons.home,
            'Sede',
            fecha.isEmpty ? 'No disponible' : nameOffice,
          ),

        ],
      ),
    );
  }

  Widget _filaDato(
    IconData icono,
    String titulo,
    String valor,
  ) {
    return Row(
      children: [
        Icon(
          icono,
          size: 18,
          color: Colors.grey,
        ),
        const SizedBox(width: 10),
        Text(
          '$titulo: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildSinRegistros(
    IconData icono,
    String mensaje,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xffe0e0e0),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icono,
            size: 45,
            color: const Color(0xff0d6efd),
          ),
          const SizedBox(height: 12),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> cargarMiAgenda() async {
    setState(() {
      cargandoAgenda = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 800),
    );

    if (!mounted) return;

    setState(() {
      cargandoAgenda = false;
    });
  }

  Future<void> cargarHistorial() async {
    setState(() {
      cargandoHistorial = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 800),
    );

    if (!mounted) return;

    setState(() {
      cargandoHistorial = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,

        centerTitle: true,

        title: const Text(
          'Citas Agendadas',
          style: TextStyle(
            color: Color(0xff0d6efd),
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Color(0xff0d6efd),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [

              const Text(
                'Citas Agendadas',
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Citas agendadas y programadas de EPS o Convenio, '
                'Particular o Passus Divertido',

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 22),

              Container(
                width: double.infinity,

                decoration: BoxDecoration(
                  color: Colors.white,

                  border: Border.all(
                    color: const Color(0xffe0e0e0),
                  ),

                  borderRadius:
                      BorderRadius.circular(10),
                ),

                child: Column(
                  children: [

                    // ------------------------------------------
                    // PASOS
                    // ------------------------------------------

                    _buildWizardSteps(),

                    // ------------------------------------------
                    // CONTENIDO
                    // ------------------------------------------

                    Padding(
                      padding: const EdgeInsets.all(16),

                      child: currentStep == 0
                          ? _buildMisCitas()
                          : _buildHistorial(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWizardSteps() {
    return Container(
      padding: const EdgeInsets.all(8),

      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xffdddddd),
          ),
        ),
      ),

      child: Row(
        children: [

          Expanded(
            child: _buildStep(
              index: 0,
              icon: Icons.calendar_month,
              title: 'Mis citas',
              subtitle: 'Citas programadas',
            ),
          ),

          Expanded(
            child: _buildStep(
              index: 1,
              icon: Icons.history,
              title: 'Historial',
              subtitle: 'Historial de citas',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final bool activo = currentStep == index;

    final bool completado =
        currentStep > index;

    Color color;

    if (activo || completado) {
      color = const Color(0xff0d6efd);
    } else {
      color = Colors.grey;
    }

    return InkWell(
      onTap: () {
        irAlPaso(index);
      },

      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 250),

        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 8,
        ),

        decoration: BoxDecoration(
          color: activo
              ? const Color(0xfff0f8ff)
              : Colors.transparent,

          border: Border(
            bottom: BorderSide(
              color: activo
                  ? const Color(0xff007bff)
                  : completado
                      ? const Color(0xff00a54f)
                      : Colors.transparent,

              width: 3,
            ),
          ),
        ),

        child: Row(
          children: [

            Container(
              width: 42,
              height: 42,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: completado
                    ? const Color(0xff00a54f)
                    : activo
                        ? const Color(0xff007bff)
                        : Colors.grey.shade400,

                border: Border.all(
                  color: completado
                      ? const Color(0xff00a54f)
                      : activo
                          ? const Color(0xff007bff)
                          : Colors.grey.shade400,

                  width: 2,
                ),
              ),

              child: Icon(
                icon,
                color: Colors.white,
                size: 21,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    title,

                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: activo || completado
                          ? color
                          : Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,

                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
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

  Widget _buildMisCitas() {
      if (citasSolicitadas.isEmpty) {
        return _buildSinRegistros(
          Icons.calendar_month_outlined,
          'No hay citas para mostrar.',
        );
      }

      return Column(
        children: [
          ...citasSolicitadas.map(
            (cita) => _buildTarjetaCita(cita),
          ),
        ],
      );
    }

    Widget _buildHistorial() {
    if (citasHistorial.isEmpty) {
      return _buildSinRegistros(
        Icons.history,
        'No hay historial para mostrar.',
      );
    }

    return Column(
      children: [
        ...citasHistorial.map(
          (cita) => _buildTarjetaCita(cita),
        ),
      ],
    );
  }

  Widget _buildLoading(String mensaje) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 40,
      ),

      child: Column(
        children: [

          const CircularProgressIndicator(
            color: Color(0xff0d6efd),
          ),

          const SizedBox(height: 15),

          Text(
            mensaje,

            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

