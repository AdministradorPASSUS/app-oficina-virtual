import 'package:flutter/material.dart';

class CertificadoScreen extends StatefulWidget {
  const CertificadoScreen({super.key});

  @override
  State<CertificadoScreen> createState() => _CertificadoScreenState();
}

class _CertificadoScreenState extends State<CertificadoScreen> {
  DateTime? fechaInicio;
  DateTime? fechaFin;

  bool mostrarRango = false;
  bool cargando = false;

  // Datos temporales.
  // Posteriormente los reemplazaremos por los datos reales de la API.
  final String nombreUsuario = 'Usuario PASSUS';
  final String tipoDocumento = 'CC';
  final String documento = '0000000000';
  final String correo = 'usuario@correo.com';

  Future<void> seleccionarFecha(bool inicio) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'CO'),
    );

    if (fecha == null) return;

    setState(() {
      if (inicio) {
        fechaInicio = fecha;
      } else {
        fechaFin = fecha;
      }
    });
  }

  void seleccionarHoy() {
    final hoy = DateTime.now();

    setState(() {
      fechaInicio = hoy;
      fechaFin = hoy;
      mostrarRango = false;
    });

    consultarCertificado();
  }

  void seleccionarRango() {
    setState(() {
      mostrarRango = true;
      fechaInicio = null;
      fechaFin = null;
    });
  }

  Future<void> consultarCertificado() async {
    if (fechaInicio == null || fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Seleccione la fecha de inicio y la fecha de fin.',
          ),
        ),
      );
      return;
    }

    if (fechaFin!.isBefore(fechaInicio!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La fecha fin no puede ser anterior a la fecha inicio.',
          ),
        ),
      );
      return;
    }

    setState(() {
      cargando = true;
    });

    // Aquí posteriormente conectaremos:
    //
    // POST certificado/citas-certificado
    //
    // enviando:
    // fecha_inicio
    // fecha_fin

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      cargando = false;
    });
  }

  Future<void> generarCertificado() async {
    setState(() {
      cargando = true;
    });

    // Posteriormente conectaremos:
    //
    // certificado/generar-certificado

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      cargando = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Certificado generado correctamente.'),
      ),
    );
  }

  String formatoFecha(DateTime? fecha) {
    if (fecha == null) return 'Seleccionar fecha';

    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
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
          'Certificado de asistencia',
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

              // ==========================================
              // INFORMACIÓN DEL USUARIO
              // ==========================================

              Card(
                elevation: 1,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),

                  child: Row(
                    children: [

                      Container(
                        width: 65,
                        height: 65,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xfff1f3f5),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xff0d6efd),
                          size: 38,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Text(
                              nombreUsuario,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Row(
                              children: [
                                const Icon(
                                  Icons.badge_outlined,
                                  size: 18,
                                  color: Color(0xff0d6efd),
                                ),

                                const SizedBox(width: 6),

                                Text(
                                  '$tipoDocumento $documento',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Row(
                              children: [
                                const Icon(
                                  Icons.email_outlined,
                                  size: 18,
                                  color: Color(0xff0d6efd),
                                ),

                                const SizedBox(width: 6),

                                Expanded(
                                  child: Text(
                                    correo,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      Image.asset(
                        'assets/images/logo_passus.png',
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ==========================================
              // CARD PRINCIPAL
              // ==========================================

              Card(
                elevation: 1,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(18),

                  child: Column(
                    children: [

                      const Text(
                        'Solicita tu certificado de asistencia',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff0d6efd),
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Selecciona una opción para continuar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ==================================
                      // OPCIÓN CITA DE HOY
                      // ==================================

                      _opcionCertificado(
                        icono: Icons.calendar_today,
                        titulo: 'Citas de hoy',
                        descripcion:
                            'Solicita el certificado de las citas que tienes programadas para hoy.',
                        onTap: seleccionarHoy,
                      ),

                      const SizedBox(height: 12),

                      // ==================================
                      // OPCIÓN RANGO
                      // ==================================

                      _opcionCertificado(
                        icono: Icons.date_range,
                        titulo: 'Rango personalizado de citas',
                        descripcion:
                            'Selecciona un rango de fechas para solicitar tu certificado.',
                        onTap: seleccionarRango,
                      ),

                      // ==================================
                      // FECHAS
                      // ==================================

                      if (mostrarRango) ...[

                        const SizedBox(height: 20),

                        const Divider(),

                        const SizedBox(height: 10),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Seleccione las fechas para generar el certificado',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [

                            Expanded(
                              child: _campoFecha(
                                titulo: 'Fecha inicio',
                                fecha: fechaInicio,
                                onTap: () {
                                  seleccionarFecha(true);
                                },
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: _campoFecha(
                                titulo: 'Fecha fin',
                                fecha: fechaFin,
                                onTap: () {
                                  seleccionarFecha(false);
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                cargando
                                    ? null
                                    : consultarCertificado,

                            icon: const Icon(
                              Icons.search,
                            ),

                            label: const Text(
                              'Consultar citas',
                            ),

                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xff0d6efd),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 13,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ==================================
                      // LISTADO DE CITAS
                      // ==================================

                      if (cargando)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text(
                                'Cargando, por favor espere...',
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          constraints:
                              const BoxConstraints(
                            minHeight: 100,
                          ),

                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(
                                0xffe0e0e0,
                              ),
                            ),
                            borderRadius:
                                BorderRadius.circular(8),
                          ),

                          padding:
                              const EdgeInsets.all(16),

                          child: const Center(
                            child: Text(
                              'Aquí aparecerán las citas consultadas.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 18),

                      // ==================================
                      // GENERAR CERTIFICADO
                      // ==================================

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton.icon(
                          onPressed:
                              cargando
                                  ? null
                                  : generarCertificado,

                          icon: const Icon(
                            Icons.picture_as_pdf,
                          ),

                          label: const Text(
                            'Generar certificado',
                          ),

                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xff00a54f),
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 13,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================
  // OPCIÓN DE CERTIFICADO
  // ======================================================

  Widget _opcionCertificado({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xffd8e5f7),
          ),
          borderRadius: BorderRadius.circular(12),
        ),

        child: Row(
          children: [

            Container(
              width: 55,
              height: 55,

              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffeef5ff),
              ),

              child: Icon(
                icono,
                color: const Color(0xff0d6efd),
                size: 25,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Color(0xff0d6efd),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    descripcion,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: Color(0xff0d6efd),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // CAMPO FECHA
  // ======================================================

  Widget _campoFecha({
    required String titulo,
    required DateTime? fecha,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      child: InputDecorator(
        decoration: InputDecoration(
          labelText: titulo,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          suffixIcon: const Icon(
            Icons.calendar_month,
            color: Color(0xff0d6efd),
          ),
        ),

        child: Text(
          formatoFecha(fecha),
          style: TextStyle(
            color:
                fecha == null
                    ? Colors.grey
                    : Colors.black87,
          ),
        ),
      ),
    );
  }
}