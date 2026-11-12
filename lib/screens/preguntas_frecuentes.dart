import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PreguntasFrecuentesScreen extends StatefulWidget {
  const PreguntasFrecuentesScreen({super.key});

  @override
  State<PreguntasFrecuentesScreen> createState() =>
      _PreguntasFrecuentesScreenState();
}

class _PreguntasFrecuentesScreenState
    extends State<PreguntasFrecuentesScreen> {
  final TextEditingController buscarController = TextEditingController();

  String busqueda = '';

  final List<Map<String, dynamic>> grupos = [
    {
      'titulo': 'Agendamiento de Citas',
      'descripcion':
          'Todo lo que necesitas saber para programar, consultar, cancelar o reprogramar tus citas',
      'color': Color(0xFF00A54F),
      'fondo': Color(0xFFEAF7EF),
      'icono': Icons.calendar_month,
      'preguntas': [
        {
          'titulo': '1. ¿Qué necesito para programar mi cita?',
          'contenido': '''
Debe tener a mano:

• Autorización vigente de su EPS.

• Orden médica o remisión (si aplica).

• Correo electrónico y número de celular actualizados.
''',
        },
        {
          'titulo': '2. ¿Puedo agendar sin autorización?',
          'contenido':
              'Todos los servicios que se prestan en Passus requiere Autorización de su EPS, pero si desea tomar los servicios como particular tambien lo puede realizar ingresando por la Opcion Servicios Particulares salud o tambien puede interesarle los servicios particulares de Bienestar.',
        },
        {
          'titulo': '3. Soy paciente nuevo, ¿qué debo programar?',
          'contenido': '''
Debe agendar su paquete completo de atención, el cual incluye:

✔ Valoración inicial virtual.

✔ Sesiones de hidroterapia en bloques de 30 minutos continuos.
''',
        },
        {
          'titulo': '4. ¿Cómo puedo cancelar o reprogramar una cita?',
          'contenido': '''
En PASSUS IPS, las solicitudes de cancelación o reprogramación deben realizarse con mínimo 24 horas de anticipación a la cita programada o durante el mismo día en que esta fue asignada.

Para realizar su solicitud, ingrese a www.passusips.com, opción Contáctanos, Solicitudes y seleccione Cancelación o Reprogramación de Citas.

Le recomendamos consultar la Política de Cancelación y Reprogramación de Citas disponible en nuestra página web para conocer las condiciones y lineamientos aplicables.

LINK DE POLITICAS.
''',
        },
        {
          'titulo': '5. ¿Qué debo hacer si no puedo asistir?',
          'contenido': '''
Le recomendamos cancelar o reprogramar su cita con anticipación para evitar afectar su tratamiento y permitir que otro usuario utilice el cupo.

lINK DE POLITICAS:
''',
        },
        {
          'titulo': '6. ¿Cómo sé si mi cita quedó programada?',
          'contenido':
              'Al finalizar el proceso recibirá una confirmación en pantalla y también llegará notificación por correo electrónico o mensaje de texto.',
        },
        {
          'titulo': '7. ¿Cómo puedo consultar mis citas?',
          'contenido':
              'Ingresando a la Oficina Virtual - Agendamiento web en la opción Citas Agendadas.',
        },
      ],
    },

    {
      'titulo': 'Autorizaciones',
      'descripcion':
          'Resuleve tus dudas sobre la vigencia, validación y aceptación de autorización',
      'color': Color(0xFF1D7CCA),
      'fondo': Color(0xFFF2F8FF),
      'icono': Icons.description,
      'preguntas': [
        {
          'titulo': '1. ¿Qué hago si mi autorización está vencida?',
          'contenido':
              'Debe solicitar una nueva autorización a su EPS antes de continuar con el agendamiento, cargue solo la Autorización vigente.',
        },
        {
          'titulo':
              '2. ¿Qué significa que el código de mi autorización es incorrecto?',
          'contenido': '''
El código registrado en su autorización no corresponde al procedimiento descrito y contratado por su EPS.

Para continuar con el proceso de agendamiento, es necesario que solicite a su EPS o ARL la corrección de la autorización, incluyendo el código 933301, correspondiente al servicio de Hidroterapia.

Una vez cuente con la autorización corregida, podrá cargar nuevamente el documento y continuar con su proceso de agendamiento.
''',
        },
        {
          'titulo':
              '3. ¿Por qué mi autorización fue rechazada por tener menos de 4 sesiones?',
          'contenido':
              'En PASSUS IPS no se programan autorizaciones con menos de 4 sesiones, ya que una cantidad inferior no permite evidenciar una mejoría significativa en la condición clínica del paciente.',
        },
      ],
    },

    {
      'titulo': 'Sesiones y Tratamiento',
      'descripcion':
          'Conoce las reglas y recomendaciones para la programación de sesiones y tratamiento.',
      'color': Color(0xFFF2EB00),
      'fondo': Color(0xFFFFF8DC),
      'icono': Icons.medical_services,
      'preguntas': [
        {
          'titulo':
              '1. ¿Por qué no puedo programar un número impar de sesiones?',
          'contenido': '''
En PASSUS IPS las sesiones se programan únicamente en número par.

Cada cita corresponde a una hora de atención continua, compuesta por dos terapias consecutivas de 30 minutos cada una. Nuestro modelo terapéutico contempla una fase inicial, una fase media y una fase final, por lo que no se programan sesiones individuales de 30 minutos dentro del proceso de hidroterapia.
''',
        },
        {
          'titulo': '2. ¿Por qué no puedo programar más de 20 sesiones?',
          'contenido': '''
En PASSUS IPS no es posible programar una cantidad mayor, ya que podría generarse sobre ejercitación muscular.

Una vez finalice las sesiones programadas, deberá asistir a control con su médico tratante, quien evaluará su evolución y determinará si es necesario continuar con el tratamiento.
''',
        },
        {
          'titulo':
              '3. ¿Cuánto tiempo antes debo llegar a las citas de Hidroterapia?',
          'contenido': '''
Se recomienda llegar 30 minutos antes de la hora programada para realizar los procesos administrativos y estar listo con vestido de baño para el ingreso a la piscina.

Tenga en cuenta que el ingreso a la piscina se realiza de manera puntual. Si llega a la hora exacta de la cita o con retraso, es posible que no pueda ser atendido, ya que el tiempo de calentamiento previo forma parte integral del tratamiento y es fundamental para garantizar la seguridad, el aprovechamiento terapéutico y la efectividad de la sesión.
''',
        },
        {
          'titulo': '4. ¿Qué incluye el paquete de Hidroterapia?',
          'contenido': '''
• Valoración inicial virtual, necesaria para conocer sus condiciones de salud y garantizar una adecuada prestación del servicio. (Solo para pacientes Nuevos o que llevan mas de 6 meses sin recibir una valoración).

• Sesiones de hidroterapia, las cuales se realizan en bloques de una hora continua, equivalentes a dos sesiones consecutivas de 30 minutos.

• Informe Final para definir mejoría y plan de tratamiento.
''',
        },
      ],
    },

    {
      'titulo': 'Problemas Técnicos',
      'descripcion':
          'Soluciones a errores o inconvenientes al usar la plataforma',
      'color': Color(0xFFFF5959),
      'fondo': Color(0xFFFFE5E5),
      'icono': Icons.build,
      'preguntas': [
        {
          'titulo': '1. El sistema muestra un error al agendar. ¿Qué hago?',
          'contenido':
              'Intente nuevamente después de unos minutos. Si el inconveniente continúa, ingrese a www.passusips.com, opción Contáctanos, Solicitudes',
        },
      ],
    },
  ];

  @override
  void dispose() {
    buscarController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> preguntasFiltradas(
    List<Map<String, dynamic>> preguntas,
  ) {
    if (busqueda.trim().isEmpty) {
      return preguntas;
    }

    final texto = busqueda.toLowerCase().trim();

    return preguntas.where((pregunta) {
      final titulo =
          pregunta['titulo'].toString().toLowerCase();

      final contenido =
          pregunta['contenido'].toString().toLowerCase();

      return titulo.contains(texto) ||
          contenido.contains(texto);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        iconTheme: const IconThemeData(
          color: Colors.black,
        ),

        title: const Text(
          'Preguntas Frecuentes',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _encabezado(),

            const SizedBox(height: 16),

            _buscador(),

            const SizedBox(height: 16),

            ...grupos.map(
              (grupo) {
                final preguntas =
                    preguntasFiltradas(
                  List<Map<String, dynamic>>.from(
                    grupo['preguntas'],
                  ),
                );

                if (busqueda.isNotEmpty &&
                    preguntas.isEmpty) {
                  return const SizedBox.shrink();
                }

                return _grupo(
                  grupo,
                  preguntas,
                );
              },
            ),

            if (busqueda.isNotEmpty &&
                grupos.every(
                  (grupo) =>
                      preguntasFiltradas(
                        List<Map<String, dynamic>>.from(
                          grupo['preguntas'],
                        ),
                      ).isEmpty,
                ))
              _sinResultados(),

            const SizedBox(height: 10),

            _contacto(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Oficina virtual',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Preguntas Frecuentes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D6EFD),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Encuentra respuestas rápidas a las dudas más comunes.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 18),

          Center(
            child: Image.asset(
              'assets/images/logo_passus.png',
              height: 65,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buscador() {
    return TextField(
      controller: buscarController,

      onChanged: (value) {
        setState(() {
          busqueda = value;
        });
      },

      decoration: InputDecoration(
        hintText:
            'Buscar una pregunta o palabra clave...',

        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF0D6EFD),
        ),

        suffixIcon: busqueda.isNotEmpty
            ? IconButton(
                onPressed: () {
                  buscarController.clear();

                  setState(() {
                    busqueda = '';
                  });
                },
                icon: const Icon(Icons.clear),
              )
            : null,

        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF0D6EFD),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _grupo(
    Map<String, dynamic> grupo,
    List<Map<String, dynamic>> preguntas,
  ) {
    final Color color = grupo['color'];
    final Color fondo = grupo['fondo'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(15),

        border: Border.all(
          color: color,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),

        child: ExpansionTile(
          initiallyExpanded: busqueda.isNotEmpty,

          tilePadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),

          childrenPadding:
              const EdgeInsets.only(bottom: 8),

          leading: Container(
            width: 50,
            height: 50,

            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),

            child: Icon(
              grupo['icono'],
              color: color,
              size: 27,
            ),
          ),

          title: Text(
            grupo['titulo'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              grupo['descripcion'],
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ),

          children: preguntas.map(
            (pregunta) {
              return _pregunta(pregunta);
            },
          ).toList(),
        ),
      ),
    );
  }

  Widget _pregunta(
    Map<String, dynamic> pregunta,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        12,
        0,
        12,
        8,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
          ),
        ],
      ),

      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 2,
        ),

        title: Text(
          pregunta['titulo'],
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              18,
            ),

            child: Align(
              alignment: Alignment.centerLeft,

              child: Text(
                pregunta['contenido'],
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sinResultados() {
    return Container(
      padding: const EdgeInsets.all(30),

      child: const Column(
        children: [
          Icon(
            Icons.search_off,
            size: 55,
            color: Colors.grey,
          ),

          SizedBox(height: 12),

          Text(
            'No encontramos resultados.',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 6),

          Text(
            'Intenta con otra palabra o pregunta.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contacto() {
    return Container(
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        children: [
          Image.asset(
            'assets/images/preguntas.png',
            height: 180,
            fit: BoxFit.contain,

            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return const Icon(
                Icons.support_agent,
                size: 100,
                color: Color(0xFF0D6EFD),
              );
            },
          ),

          const SizedBox(height: 12),

          const Text(
            '¿No encuentras lo que buscas?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Estamos aquí para ayudarte.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 18),

          ElevatedButton.icon(
            onPressed: () async {
              final Uri url = Uri.parse(
                'https://passusips.com/contactanos',
              );

              if (await canLaunchUrl(url)) {
                await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                );
              }
            },

            icon: const Icon(
              Icons.comment,
            ),

            label: const Text(
              'Contáctanos',
            ),

            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF0D6EFD),

              foregroundColor: Colors.white,

              padding: const EdgeInsets.symmetric(
                horizontal: 35,
                vertical: 14,
              ),

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}