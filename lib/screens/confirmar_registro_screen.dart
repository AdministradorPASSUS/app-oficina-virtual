import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ConfirmaRegistroScreen extends StatefulWidget {
  const ConfirmaRegistroScreen({super.key});

  @override
  State<ConfirmaRegistroScreen> createState() =>
      _RegisterConfirmScreenState();
}

class _RegisterConfirmScreenState
    extends State<ConfirmaRegistroScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // CONTROLLERS //

  final TextEditingController numeroDocumentoController =
      TextEditingController();

  final TextEditingController primerNombreController =
      TextEditingController();

  final TextEditingController segundoNombreController =
      TextEditingController();

  final TextEditingController primerApellidoController =
      TextEditingController();

  final TextEditingController segundoApellidoController =
      TextEditingController();

  final TextEditingController fechaNacimientoController =
      TextEditingController();

  final TextEditingController celularController =
      TextEditingController();

  final TextEditingController telefonoController =
      TextEditingController();

  final TextEditingController correoController =
      TextEditingController();

  final TextEditingController direccionController =
      TextEditingController();

  // SELECTORES //

  String? tipoDocumento;
  String? lugarNacimiento;
  String? zonaResidencia;
  String? barrio;
  String? ciudad;
  String? sexo;
  String? estadoCivil;
  String? religion;
  String? grupoEtnico;
  String? paisOrigen;
  String? ocupacion;
  String? remitente;
  String? eps;

  bool aceptaPolitica = false;
  bool aceptaTerminos = false;

  @override
  void dispose() {
    numeroDocumentoController.dispose();
    primerNombreController.dispose();
    segundoNombreController.dispose();
    primerApellidoController.dispose();
    segundoApellidoController.dispose();
    fechaNacimientoController.dispose();
    celularController.dispose();
    telefonoController.dispose();
    correoController.dispose();
    direccionController.dispose();

    super.dispose();
  }

  // REGISTRAR // 

  void _registrarUsuario() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!aceptaPolitica || !aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debe aceptar la Política de tratamiento de datos '
            'y los Términos y Condiciones.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Datos válidos. Próximamente se conectará el registro.',
        ),
      ),
    );
  }

  // DATE PICKER //

  Future<void> _seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'CO'),
    );

    if (fecha != null) {
      setState(() {
        fechaNacimientoController.text =
            '${fecha.year.toString().padLeft(4, '0')}-'
            '${fecha.month.toString().padLeft(2, '0')}-'
            '${fecha.day.toString().padLeft(2, '0')}';
      });
    }
  }

  // INPUT // 

  Widget _campoTexto({
    required String label,
    required TextEditingController controller,
    bool obligatorio = false,
    bool soloLectura = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: soloLectura,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(
              color: Color(0xFFD5D5D5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(
              color: Color(0xFF00A54F),
              width: 2,
            ),
          ),
        ),
        validator: obligatorio
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Este campo es obligatorio';
                }

                return null;
              }
            : null,
      ),
    );
  }

  // SELECT //

  Widget _selector({
    required String label,
    required String? value,
    required List<String> opciones,
    required ValueChanged<String?> onChanged,
    bool obligatorio = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(
              color: Color(0xFFD5D5D5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(
              color: Color(0xFF00A54F),
              width: 2,
            ),
          ),
        ),
        items: opciones.map((opcion) {
          return DropdownMenuItem<String>(
            value: opcion,
            child: Text(opcion),
          );
        }).toList(),
        onChanged: onChanged,
        validator: obligatorio
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Seleccione una opción';
                }

                return null;
              }
            : null,
      ),
    );
  }

  // TITULO SECCION //

  Widget _tituloSeccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 14,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          titulo,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ),
    );
  }

  // AUTORIZACION // 

  Widget _autorizacion({
    required bool valor,
    required ValueChanged<bool?> onChanged,
    required String texto,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: CheckboxListTile(
        value: valor,
        onChanged: onChanged,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          texto,
          style: const TextStyle(
            fontSize: 13,
            height: 1.45,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Row(
          children: [

            // PANEL PRINCIPAL // 

            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // HEADER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/images/logo_passus.png',
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // FORMULARIO
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 15,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 950,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const Text(
                                'Confirmación de datos',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                'Por favor diligencia la información '
                                'solicitada para finalizar el proceso '
                                'de registro.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.5,
                                  color: Colors.black54,
                                ),
                              ),

                              const SizedBox(height: 28),

                              // INFORMACION PERSONAL //

                              _tituloSeccion(
                                'Información personal',
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: _selector(
                                      label: 'Tipo de documento',
                                      value: tipoDocumento,
                                      opciones: const [
                                        'Cédula de ciudadanía',
                                        'Cédula de extranjería',
                                        'Pasaporte',
                                        'Tarjeta de identidad',
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          tipoDocumento = value;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _campoTexto(
                                      label: 'Número de documento',
                                      controller:
                                          numeroDocumentoController,
                                      obligatorio: true,
                                      soloLectura: true,
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: _campoTexto(
                                      label: 'Primer nombre',
                                      controller:
                                          primerNombreController,
                                      obligatorio: true,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _campoTexto(
                                      label: 'Segundo nombre',
                                      controller:
                                          segundoNombreController,
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: _campoTexto(
                                      label: 'Primer apellido',
                                      controller:
                                          primerApellidoController,
                                      obligatorio: true,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _campoTexto(
                                      label: 'Segundo apellido',
                                      controller:
                                          segundoApellidoController,
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _selector(
                                      label: 'Lugar de nacimiento',
                                      value: lugarNacimiento,
                                      opciones: const [
                                        'Bogotá',
                                        'Medellín',
                                        'Cali',
                                        'Ibagué',
                                        'Florencia',
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          lugarNacimiento = value;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _seleccionarFecha,
                                      child: AbsorbPointer(
                                        child: _campoTexto(
                                          label: 'Fecha de nacimiento',
                                          controller:
                                              fechaNacimientoController,
                                          obligatorio: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // UBICACION Y CONTACTO // 

                              _tituloSeccion(
                                'Información de ubicación y contacto',
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: _campoTexto(
                                      label: 'Celular',
                                      controller: celularController,
                                      obligatorio: true,
                                      keyboardType:
                                          TextInputType.phone,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _campoTexto(
                                      label: 'Teléfono',
                                      controller: telefonoController,
                                      keyboardType:
                                          TextInputType.phone,
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: _campoTexto(
                                      label: 'Correo',
                                      controller: correoController,
                                      obligatorio: true,
                                      soloLectura: true,
                                      keyboardType:
                                          TextInputType.emailAddress,
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _campoTexto(
                                      label: 'Dirección de residencia',
                                      controller:
                                          direccionController,
                                      obligatorio: true,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _selector(
                                      label: 'Tipo de zona',
                                      value: zonaResidencia,
                                      opciones: const [
                                        'Urbana',
                                        'Rural',
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          zonaResidencia = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: _selector(
                                      label: 'Barrio',
                                      value: barrio,
                                      opciones: const [
                                        'Centro',
                                        'Chapinero',
                                        'Suba',
                                        'Engativá',
                                        'Usaquén',
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          barrio = value;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _selector(
                                      label: 'Ciudad de residencia',
                                      value: ciudad,
                                      opciones: const [
                                        'Bogotá',
                                        'Medellín',
                                        'Cali',
                                        'Ibagué',
                                        'Florencia',
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          ciudad = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              // INFORMACION SOCIODEMOGRAFICA // 

                              _tituloSeccion(
                                'Información sociodemográfica',
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: _selector(
                                      label: 'Sexo al nacer',
                                      value: sexo,
                                      opciones: const [
                                        'Femenino',
                                        'Masculino',
                                        'Intersexual',
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          sexo = value;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _selector(
                                      label: 'Estado civil',
                                      value: estadoCivil,
                                      opciones: const [
                                        'Soltero(a)',
                                        'Casado(a)',
                                        'Unión libre',
                                        'Separado(a)',
                                        'Divorciado(a)',
                                        'Viudo(a)',
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          estadoCivil = value;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _selector(
                                      label: 'Religión',
                                      value: religion,
                                      opciones: const [
                                        'Católica',
                                        'Cristiana',
                                        'Otra',
                                        'No aporta',
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          religion = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: _selector(
                                      label: 'Grupo étnico',
                                      value: grupoEtnico,
                                      opciones: const [
                                        'Gitano (Población Room)',
                                        'Indígena',
                                        'Mestizo',
                                        'Afrocolombiano',
                                        'Raizal',
                                        'Palenquero',
                                        'Comunidades negras',
                                        'Otro Grupo',
                                        'Ninguna de las anteriores',
                                        'No aporta',
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          grupoEtnico = value;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _selector(
                                      label: 'País de origen',
                                      value: paisOrigen,
                                      opciones: const [
                                        'Colombia',
                                        'Venezuela',
                                        'Ecuador',
                                        'Perú',
                                        'Otro',
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          paisOrigen = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              _selector(
                                label: 'Ocupación',
                                value: ocupacion,
                                opciones: const [
                                  'Empleado',
                                  'Independiente',
                                  'Estudiante',
                                  'Pensionado',
                                  'Desempleado',
                                  'Otra',
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    ocupacion = value;
                                  });
                                },
                              ),

                              // INFORMACION DE SERVICIO //

                              _tituloSeccion(
                                'Información de servicio',
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: _selector(
                                      label: 'Remitente',
                                      value: remitente,
                                      opciones: const [
                                        'EPS-ARL',
                                        'Particular',
                                        'Divertido',
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          remitente = value;

                                          if (value != 'EPS-ARL') {
                                            eps = null;
                                          }
                                        });
                                      },
                                    ),
                                  ),

                                  if (remitente == 'EPS-ARL') ...[
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: _selector(
                                        label: 'EPS-ARL',
                                        value: eps,
                                        opciones: const [
                                          'EPS SURA',
                                          'Nueva EPS',
                                          'Sanitas',
                                          'Compensar',
                                          'ARL',
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            eps = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              const SizedBox(height: 8),

                              // POLITICA DE DATOS// 

                              _autorizacion(
                                valor: aceptaPolitica,
                                onChanged: (value) {
                                  setState(() {
                                    aceptaPolitica = value ?? false;
                                  });
                                },
                                texto:
                                    'Confirmo que he leído, entiendo y '
                                    'autorizo la Política de tratamiento '
                                    'de datos personales de PASSUS, la '
                                    'cual se encuentra registrada en '
                                    'nuestra página web.',
                              ),

                              _autorizacion(
                                valor: aceptaTerminos,
                                onChanged: (value) {
                                  setState(() {
                                    aceptaTerminos = value ?? false;
                                  });
                                },
                                texto:
                                    'Declaro que he leído y aceptado '
                                    'los Términos y Condiciones de la '
                                    'oficina virtual, autorizando ser '
                                    'contactado exclusivamente para '
                                    'fines relacionados con mi atención '
                                    'y los servicios brindados por PASSUS.',
                              ),

                              const SizedBox(height: 12),

                              // BOTONES //

                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: _registrarUsuario,
                                  icon: const Icon(
                                    Icons.person_add_alt_1,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Registrar usuario',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF00A54F),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFDC3545),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // FOOTER
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      'Copyright 2024-${DateTime.now().year} | '
                      'Todos los derechos reservados | Passus IPS',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
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
}
