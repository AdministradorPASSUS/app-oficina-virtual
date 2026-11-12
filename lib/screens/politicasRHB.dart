import 'package:flutter/material.dart';

class PoliticasRHB extends StatefulWidget {
  const PoliticasRHB({super.key});

  @override
  State<PoliticasRHB> createState() => _PoliticasRHBState();
}

class _PoliticasRHBState extends State<PoliticasRHB> {
  final TextEditingController _buscarController = TextEditingController();

  List<Map<String, dynamic>> grupos = [
    {
      'titulo': 'Requisitos Administrativos para Acceder al Servicio',
      'icono': Icons.list_alt,
      'color': Color(0xFF00A54F),
      'preguntas': [
        {
          'titulo': '1. Autorización de la EPS.',
          'contenido':
              'Para recibir los servicios del programa de rehabilitación, el paciente debe contar con una autorización vigente de su EPS, de acuerdo con las condiciones establecidas para la prestación del servicio.\n\n'
              'La autorización debe ser entregada al líder de sede o al auxiliar administrativo.\n\n'
              'Para garantizar la continuidad del tratamiento, es importante verificar oportunamente la vigencia de las autorizaciones y realizar los trámites de renovación cuando corresponda.\n\n'
              'La autorización entregada por la EPS debe:\n'
              '• Estar vigente.\n'
              '• Contener los datos completos del paciente.\n'
              '• Presentarse en el documento correspondiente.\n'
              '• No presentar enmendaduras.\n'
              '• Estar dirigida a PASSUS TALLER PSICOMOTRIZ IPS.',
        },
        {
          'titulo': '2. Copagos y cuotas moderadoras.',
          'contenido':
              'Cuando la autorización de la EPS contemple copago o cuota moderadora, este deberá ser cancelado de acuerdo con las condiciones establecidas antes de recibir la atención correspondiente.\n\n'
              'La familia puede consultar al personal administrativo de la sede si requiere orientación sobre estos pagos.',
        },
        {
          'titulo': '3. Renovación de órdenes y autorizaciones.',
          'contenido':
              'Para evitar interrupciones en el tratamiento, recomendamos a las familias gestionar con anticipación las citas de control médico requeridas para la renovación de las órdenes de servicio.\n\n'
              'PASSUS recomienda realizar estas gestiones aproximadamente 60 días antes del vencimiento de las órdenes, de manera que exista tiempo suficiente para realizar los trámites correspondientes ante la EPS.',
        },
        {
          'titulo': '4. ¿Quién debe realizar el trámite?',
          'contenido':
              'Dependiendo de la EPS, la gestión de las órdenes y autorizaciones puede realizarla PASSUS o directamente el acudiente ante la EPS y/o el médico tratante.\n\n'
              'Famisanar: PASSUS\n'
              'Compensar: PASSUS\n'
              'Nueva EPS: PASSUS\n'
              'Sanitas: Acudiente / EPS\n'
              'Aliansalud: Acudiente / EPS\n'
              'Asmet Salud: PASSUS\n'
              'Sura: PASSUS\n'
              'Cafam: PASSUS\n\n'
              'Importante: si la EPS modifica el procedimiento de autorización, la familia deberá seguir las instrucciones vigentes informadas por la EPS y PASSUS.',
        },
      ],
    },

    {
      'titulo': 'Antes de Iniciar el Proceso de Rehabilitación',
      'icono': Icons.edit_document,
      'color': Color(0xFF1D7CCA),
      'preguntas': [
        {
          'titulo': '1. Materiales terapéuticos',
          'contenido':
              'Antes de iniciar el programa, la familia recibirá la lista de materiales requeridos para el proceso terapéutico.\n\n'
              'Los materiales deberán:\n'
              '• Ser entregados antes de iniciar el programa.\n'
              '• Estar debidamente marcados con el nombre del paciente.\n'
              '• Renovarse aproximadamente cada seis meses, de acuerdo con las necesidades del proceso.\n\n'
              'Estos elementos hacen parte de las herramientas necesarias para desarrollar adecuadamente las actividades terapéuticas.',
        },
        {
          'titulo': '2. Información clínica',
          'contenido':
              'Para brindar una atención integral y segura, el acudiente deberá suministrar la información solicitada durante la apertura o actualización de la historia clínica.\n\n'
              'También deberá aportar, cuando corresponda, copias de las evaluaciones realizadas en otras instituciones durante los últimos seis meses.\n\n'
              'Es importante informar al equipo tratante cualquier cambio relevante en la condición del paciente.',
        },
        {
          'titulo': '3. Consentimiento informado',
          'contenido':
              'Antes de iniciar las intervenciones, el acudiente deberá leer y comprender el consentimiento informado del programa de rehabilitación, en el cual se explican los beneficios, condiciones y posibles riesgos asociados a las intervenciones terapéuticas.\n\n'
              'Cuando se requiera atención mediante telemedicina, se dispondrá adicionalmente del consentimiento informado correspondiente.',
        },
      ],
    },

    {
      'titulo': 'Recomendaciones para Asistir a las Sesiones',
      'icono': Icons.checklist,
      'color': Color(0xFFF2C500),
      'preguntas': [
        {
          'titulo': '1. Recomendaciones para Asistir a las Sesiones',
          'contenido':
              'Para favorecer el desarrollo de las actividades y el bienestar del paciente, recomendamos tener en cuenta las siguientes condiciones:\n\n'
              'ALIMENTACIÓN\n'
              'El paciente debe asistir en condiciones adecuadas de alimentación que le permitan participar y concentrarse durante las actividades.\n\n'
              'No se deben ingresar alimentos al programa, excepto cuando el equipo terapéutico los requiera como parte de una intervención. En estos casos, la familia será informada previamente.\n\n'
              'HIGIENE\n'
              'Los pacientes que utilizan pañal deben ingresar en adecuadas condiciones de higiene para evitar interrupciones durante el proceso terapéutico.\n\n'
              'VESTUARIO\n'
              'Se recomienda asistir con:\n'
              '• Ropa cómoda.\n'
              '• Sudadera o prendas que faciliten el movimiento.\n'
              '• Tenis seguros, preferiblemente con amarre o velcro.\n'
              '• Uñas cortas.\n'
              '• Cabello recogido cuando su longitud pueda interferir con las actividades.\n\n'
              'ELEMENTOS PERSONALES\n'
              'Recomendamos no enviar al paciente con:\n'
              '• Joyas.\n'
              '• Dinero u objetos de valor.\n'
              '• Dispositivos electrónicos que no sean necesarios para la terapia.\n\n'
              'PASSUS recomienda a las familias evitar el ingreso de elementos que no sean necesarios para el proceso terapéutico.\n\n'
              'TULA O BOLSO\n'
              'Únicamente se recomienda enviar una tula pequeña, ecológica o de tela, debidamente marcada, para transportar los elementos autorizados por la institución.',
        },
      ],
    },

    {
      'titulo': 'Participación de la Familia',
      'icono': Icons.groups,
      'color': Color(0xFF7C3AED),
      'preguntas': [
        {
          'titulo': '1. Participación de la Familia',
          'contenido':
              'La participación de la familia es fundamental para alcanzar los objetivos terapéuticos.\n\n'
              'PASSUS cuenta con espacios de Escuela de Padres, diseñados para brindar herramientas que permitan fortalecer el proceso terapéutico y apoyar las actividades que se realizan en casa.\n\n'
              'La familia podrá recibir ejercicios, recomendaciones y planes caseros orientados a fortalecer habilidades, capacidades y destrezas del paciente.\n\n'
              'Los planes caseros y el informe de evolución se entregarán aproximadamente de manera semestral.',
        },
      ],
    },

    {
      'titulo': 'Asistencia y Puntualidad',
      'icono': Icons.access_time,
      'color': Color(0xFF00A54F),
      'preguntas': [
        {
          'titulo': '1. Asistencia y Puntualidad',
          'contenido':
              'La asistencia regular y puntual es fundamental para favorecer la continuidad y los resultados del proceso terapéutico.\n\n'
              'LLEGADA A LA SEDE\n'
              'Solicitamos presentarse 10 minutos antes de la hora programada, tanto para el ingreso como para el proceso de salida.\n\n'
              'LLEGADAS TARDE\n'
              'Si el paciente llega con un retraso de 10 minutos o más, se deberá validar con el responsable de la sede si existe disponibilidad en una franja posterior que permita realizar la atención.\n\n'
              'Si no existe disponibilidad, la sesión se registrará como inasistencia y no podrá ser reemplazada.\n\n'
              'INASISTENCIAS\n'
              'Las sesiones a las que el paciente no asista sin una incapacidad médica que justifique la ausencia no podrán ser reemplazadas.\n\n'
              'Cuando se presenten inasistencias reiteradas, PASSUS podrá realizar un ajuste en la frecuencia de las sesiones, de acuerdo con el seguimiento del proceso terapéutico.\n\n'
              'Si la inasistencia continúa y afecta la adherencia al programa, podrá realizarse el egreso del paciente y la correspondiente notificación a la EPS.',
        },
      ],
    },

    {
      'titulo': 'Cuando el Paciente Presenta Enfermedad',
      'icono': Icons.sick,
      'color': Color(0xFF1D7CCA),
      'preguntas': [
        {
          'titulo': '1. Cuando el Paciente Presenta Enfermedad',
          'contenido':
              'Si el paciente presenta una enfermedad infectocontagiosa, como gripe, COVID-19, sarampión, varicela u otra condición que pueda representar riesgo para él o para otras personas, la familia deberá informar oportunamente al personal administrativo.\n\n'
              'En estos casos, el paciente no deberá asistir a las instalaciones mientras se encuentre en condiciones que puedan afectar su bienestar o el de otros usuarios.\n\n'
              'Cuando exista una incapacidad médica y se cumplan las condiciones establecidas, las sesiones podrán ser reprogramadas.',
        },
      ],
    },

    {
      'titulo': 'Seguridad y Manejo de Situaciones Durante la Terapia',
      'icono': Icons.security,
      'color': Color(0xFFF2C500),
      'preguntas': [
        {
          'titulo': '1. Seguridad y Manejo de Situaciones Durante la Terapia',
          'contenido':
              'Debido a las características individuales de algunos pacientes, durante las intervenciones pueden presentarse episodios de autoagresividad o heteroagresividad.\n\n'
              'PASSUS cuenta con protocolos, recursos y personal capacitado para atender estas situaciones de manera humanizada, segura y adecuada, buscando proteger al paciente, a los demás usuarios y al equipo interdisciplinario.\n\n'
              'EN CASO DE UN INCIDENTE\n'
              'Si durante una sesión ocurre un incidente que requiera atención, el líder de sede se comunicará con los padres o acudientes para informar lo sucedido y coordinar las acciones correspondientes.\n\n'
              'Cuando se requiera atención médica inmediata, el personal capacitado podrá brindar primeros auxilios básicos y activar el servicio de área protegida contratado por PASSUS.\n\n'
              'DAÑOS OCASIONADOS DURANTE LA PRESTACIÓN DEL SERVICIO\n'
              'Durante la atención, esperamos que todos los pacientes y sus familias contribuyan al cuidado de las instalaciones, equipos, materiales y mobiliario, así como al respeto y bienestar de los demás pacientes y colaboradores.',
        },
      ],
    },

    {
      'titulo': 'Entrega Segura del Paciente',
      'icono': Icons.shield,
      'color': Color(0xFF7C3AED),
      'preguntas': [
        {
          'titulo': '1. Entrega Segura del Paciente',
          'contenido':
              'Para proteger la seguridad del niño, niña o adolescente, la familia deberá informar claramente:\n\n'
              '• Nombre completo de las personas autorizadas para recogerlo.\n'
              '• Número de documento de identificación.\n'
              '• Datos de contacto correspondientes.\n\n'
              'El paciente únicamente será entregado a las personas previamente registradas y autorizadas en el ingreso administrativo.',
        },
      ],
    },

    {
      'titulo': 'Información para Casos de Emergencia',
      'icono': Icons.phone_in_talk,
      'color': Color(0xFF00A54F),
      'preguntas': [
        {
          'titulo': '1. Información para Casos de Emergencia',
          'contenido':
              'La familia deberá suministrar números de contacto actualizados para situaciones de emergencia.\n\n'
              'Cuando alguno de estos datos cambie, deberá informarse oportunamente al personal administrativo de la sede.\n\n'
              'Mantener esta información actualizada es fundamental para actuar de manera rápida y adecuada ante cualquier eventualidad.',
        },
      ],
    },

    {
      'titulo': 'Circuito Cerrado de Televisión',
      'icono': Icons.videocam,
      'color': Color(0xFF1D7CCA),
      'preguntas': [
        {
          'titulo': '1. Circuito Cerrado de Televisión',
          'contenido':
              'PASSUS cuenta con circuito cerrado de televisión en sus instalaciones como herramienta de apoyo para la seguridad y verificación de los procesos institucionales.\n\n'
              'Las imágenes son administradas de acuerdo con las condiciones técnicas del sistema y las disposiciones aplicables sobre protección de datos personales y privacidad.',
        },
      ],
    },

    {
      'titulo': 'Registro de la Atención',
      'icono': Icons.medical_information,
      'color': Color(0xFFF2C500),
      'preguntas': [
        {
          'titulo': '1. Registro de la Atención',
          'contenido':
              'Como soporte de la prestación del servicio, el acudiente deberá realizar las firmas o confirmaciones correspondientes a las intervenciones terapéuticas recibidas por el paciente.\n\n'
              'Estas confirmaciones permiten dejar constancia de la atención realizada.',
        },
      ],
    },

    {
      'titulo': 'Modelo de Atención y Seguimiento',
      'icono': Icons.local_hospital,
      'color': Color(0xFF7C3AED),
      'preguntas': [
        {
          'titulo': '1. Modelo de Atención y Seguimiento',
          'contenido':
              'Al ingresar al programa, la familia participará en una reunión virtual de orientación en la que se socializará el modelo de atención y se explicarán aspectos relevantes del proceso.\n\n'
              'Posteriormente, el equipo terapéutico realizará la valoración correspondiente y definirá el plan terapéutico de acuerdo con las condiciones y necesidades del paciente.\n\n'
              'El plan terapéutico será compartido con la familia dentro de los primeros 30 días desde el inicio del programa.',
        },
      ],
    },

    {
      'titulo': 'Sesión Abierta',
      'icono': Icons.groups,
      'color': Color(0xFF00A54F),
      'preguntas': [
        {
          'titulo': '1. Sesión Abierta',
          'contenido':
              'De manera semestral, el acudiente podrá participar en una sesión abierta, cuyo objetivo es permitirle conocer directamente parte del proceso de intervención terapéutica del paciente.\n\n'
              'Este espacio también permite fortalecer la comunicación entre la familia y el equipo tratante.',
        },
      ],
    },

    {
      'titulo': 'Informes de Evolución',
      'icono': Icons.description,
      'color': Color(0xFF1D7CCA),
      'preguntas': [
        {
          'titulo': '1. Informes de Evolución',
          'contenido':
              'El informe de evolución del tratamiento será enviado al correo electrónico registrado por la familia aproximadamente de manera semestral.\n\n'
              'La asistencia a las reuniones de seguimiento establecidas por PASSUS es importante para conocer los avances, recomendaciones y aspectos relevantes del proceso.',
        },
      ],
    },

    {
      'titulo': 'Hidroterapia',
      'icono': Icons.pool,
      'color': Color(0xFFF2C500),
      'preguntas': [
        {
          'titulo': '1. Hidroterapia',
          'contenido':
              'El servicio de hidroterapia no se encuentra incluido dentro del programa de rehabilitación.\n\n'
              'Si la familia está interesada en acceder a este servicio, podrá solicitar información sobre disponibilidad, condiciones y tarifas al profesional encargado de la sede.',
        },
      ],
    },

    {
      'titulo': 'Parqueadero',
      'icono': Icons.local_parking,
      'color': Color(0xFF7C3AED),
      'preguntas': [
        {
          'titulo': '1. Parqueadero',
          'contenido':
              'PASSUS no cuenta con servicio de parqueadero propio.\n\n'
              'Por esta razón, recomendamos utilizar los parqueaderos públicos disponibles en los alrededores de cada sede.\n\n'
              'Los vehículos estacionados en espacios externos a la institución permanecen bajo responsabilidad de sus propietarios.',
        },
      ],
    },

    {
      'titulo': 'Derechos y Deberes',
      'icono': Icons.balance,
      'color': Color(0xFF00A54F),
      'preguntas': [
        {
          'titulo': '1. Derechos y Deberes',
          'contenido':
              'La familia deberá conocer los derechos y deberes de los usuarios, disponibles en el área administrativa de cada sede y en los canales institucionales de PASSUS.\n\n'
              'Conocer esta información permite fortalecer una relación basada en el respeto, la corresponsabilidad y la adecuada comunicación entre la familia y la institución.',
        },
      ],
    },

    {
      'titulo': 'Canales de Comunicación',
      'icono': Icons.chat,
      'color': Color(0xFF1D7CCA),
      'preguntas': [
        {
          'titulo': '1. Canales de Comunicación',
          'contenido':
              'Si la familia requiere una reunión con el profesional administrativo de la sede, podrá solicitarla previamente para coordinar fecha y hora.\n\n'
              'Cada sede cuenta además con responsables encargados de atender las inquietudes y solicitudes de los usuarios.\n\n'
              'También pueden utilizarse los canales institucionales disponibles en la página web de PASSUS, en la opción “Contáctenos”.',
        },
      ],
    },

    {
      'titulo': 'Compromiso de la Familia',
      'icono': Icons.people_alt,
      'color': Color(0xFFF2C500),
      'preguntas': [
        {
          'titulo': '1. Compromiso de la Familia',
          'contenido':
              'El adecuado desarrollo del proceso de rehabilitación requiere el compromiso conjunto de PASSUS, el paciente y su familia.\n\n'
              'Por ello, invitamos a los acudientes a:\n\n'
              '• Mantener actualizada la información administrativa y clínica.\n'
              '• Cumplir oportunamente los trámites requeridos ante la EPS.\n'
              '• Garantizar la asistencia y puntualidad.\n'
              '• Informar oportunamente cualquier novedad.\n'
              '• Participar en los espacios de orientación y seguimiento.\n'
              '• Apoyar las recomendaciones terapéuticas en casa.\n'
              '• Mantener una comunicación respetuosa y permanente con el equipo PASSUS.',
        },
      ],
    },
  ];

  List<Map<String, dynamic>> get gruposFiltrados {
    final texto = _buscarController.text
        .toLowerCase()
        .trim();

    if (texto.isEmpty) {
      return grupos;
    }

    return grupos.where((grupo) {
      final titulo = grupo['titulo'].toString().toLowerCase();

      final preguntas = grupo['preguntas'] as List;

      final contenido = preguntas.any((pregunta) {
        return pregunta['titulo']
                .toString()
                .toLowerCase()
                .contains(texto) ||
            pregunta['contenido']
                .toString()
                .toLowerCase()
                .contains(texto);
      });

      return titulo.contains(texto) || contenido;
    }).toList();
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Oficina Virtual',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [

            // Encabezado
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [

                  const SizedBox(height: 15),

                    Image.asset(
                      'assets/images/logo_passus.png',
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                
                  const SizedBox(height: 8),

                  const Text(
                    'Políticas y Condiciones Para la Prestación del Servicio de Programa de Rehabilitación',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D6EFD),
                    ),
                  ),

                  
                ],
              ),
            ),

            // Buscador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _buscarController,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Buscar una pregunta o palabra clave...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _buscarController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _buscarController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Contenido
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                itemCount: gruposFiltrados.length,
                itemBuilder: (context, index) {
                  final grupo = gruposFiltrados[index];

                  return _buildGrupo(
                    titulo: grupo['titulo'],
                    icono: grupo['icono'],
                    color: grupo['color'],
                    preguntas: grupo['preguntas'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrupo({
    required String titulo,
    required IconData icono,
    required Color color,
    required List preguntas,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        childrenPadding: const EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 10,
        ),

        leading: Container(
          width: 45,
          height: 45,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icono,
            color: color,
            size: 25,
          ),
        ),

        title: Text(
          titulo,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        children: preguntas.map<Widget>((pregunta) {
          return _buildPregunta(
            pregunta['titulo'],
            pregunta['contenido'],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPregunta(
    String titulo,
    String contenido,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          titulo,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        childrenPadding: const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ),

        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              contenido,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

