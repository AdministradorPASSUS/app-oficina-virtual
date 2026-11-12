import 'package:flutter/material.dart';
import 'package:oficina_virtual_movil/screens/convenio_vista.dart';
import '../../services/auth_service.dart';
import 'package:oficina_virtual_movil/screens/certificados_screen.dart';
import 'package:oficina_virtual_movil/screens/citas_agendadas_screen.dart';
import 'package:oficina_virtual_movil/screens/crear_autorizacion_screen.dart';
import 'package:oficina_virtual_movil/screens/politicasRHB.dart';
import 'package:oficina_virtual_movil/screens/preguntas_frecuentes.dart';
import '../../services/app_data.dart';
import 'login_screen.dart';

// VARIABLES DEL PACIENTE

   final idPaciente = AppData.idPaciente;
   final eps = AppData.eps;
   final documentopaciente = AppData.documentoIdentidad;
   final tipodocumentopaciente = AppData.tipoDocumento;
   final nonmbrePaciente = AppData.nombrePaciente;

//
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
 
      // MENÚ LATERAL //
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // ENCABEZADO DEL MENÚ
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_circle,
                      size: 45,
                      color: Color(0xFF0D6EFD),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppData.nombrePaciente,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),
              // PREGUNTAS FRECUENTES
              ListTile(
                leading: const Icon(
                  Icons.help_outline,
                  color: Color(0xFF3693EB),
                ),
                title: const Text(
                  'Preguntas Frecuentes',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // cierra el Drawer
                
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PreguntasFrecuentesScreen(),
                      ),
                  );
                },
              ),

              // CERTIFICADOS
              /*
              ListTile(
                leading: const Icon(
                  Icons.file_download_outlined,
                  color: Color(0xFF00A54F),
                ),
                title: const Text(
                    'Certificados de Asistencia',
                    style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                    Navigator.pop(context); // cierra el Drawer
                  
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CertificadoScreen(),
                        ),
                    );
                  },
                ),
              */ 

              // POLÍTICAS REHABILITACIÓN
              ListTile(
                leading: const Icon(
                  Icons.menu_book_outlined,
                  color: Color(0xFF4F46E5),
                ),
                title: const Text(
                  'Políticas Programa de Rehabilitación',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // cierra el Drawer
                
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PoliticasRHB(),
                      ),
                  );
                },
              ),

              // POLÍTICAS HIDROTERAPIA //
              /*ListTile(
                leading: const Icon(
                  Icons.menu_book_outlined,
                  color: Color(0xFF4F46E5),
                ),
                title: const Text(
                  'Políticas Programa de Hidroterapia',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              */
              const Spacer(),
              const Divider(),

              // CERRAR SESIÓN
              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title: const Text('Cerrar sesión'),
                onTap: () async {
                  // Cerrar sesión y limpiar información.
                  await AuthService().cerrarSesion();

                  if (!context.mounted) return;

                  // Eliminar el historial de navegación y regresar al Login.
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),

      // APP BAR //
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Image.asset(
          'assets/images/logo_passus.png',
          height: 45,
          errorBuilder: (context, error, stackTrace) {
            return const Text(
              'PASSUS IPS',
              style: TextStyle(
                color: Color(0xFF00A54F),
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: Color(0xFF333333),
            ),
          ),


        ],
      ),

      // CONTENIDO // 
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // BANNER DE BIENVENIDA //
              Container(
                margin: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [

                      // IMAGEN DE FONDO
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/quienes_somos_banner2.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFEAF4FC),
                            );
                          },
                        ),
                      ),

                      // CAPA BLANCA
                      Positioned.fill(
                        child: Container(
                          color: Colors.white.withOpacity(0.82),
                        ),
                      ),

                      // CONTENIDO
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Bienvenido a nuestra\n',
                                  ),
                                  TextSpan(
                                    text: 'Oficina',
                                    style: TextStyle(
                                      color: Color(0xFF1D7CCA),
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' Virtual',
                                    style: TextStyle(
                                      color: Color(0xFF00A54F),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            const Text(
                              'Aquí puedes agendar fácilmente tus citas de Hidroterapia, consultas especializadas, ingreso a programa de rehabilitación y programas de bienestar.',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // TITULO SERVICIOS //
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nuestros servicios',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ),

              // TARJETAS // 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Expanded(
                          child: _tarjetaServicio(
                            icono: Icons.calendar_month,
                            titulo: 'Citas Agendadas',
                            color: const Color(0xFF0049E8),
                            onPressed: () async {
                              final authService = AuthService();
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF0D6EFD),
                                    ),
                                  );
                                },
                              );
                              try {
                                final respuesta = await authService.consultarCitasAgendadas(
                                  tipoDocumento: AppData.tipoDocumento,
                                  documento: AppData.documentoIdentidad,
                                );
                                if (!context.mounted) return;
                                Navigator.of(context, rootNavigator: true).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CitasAgendadasScreen(
                                      respuestaInicial: respuesta,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                Navigator.of(context, rootNavigator: true).pop();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error al consultar las citas: $e',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        ),

                        const SizedBox(width: 12),
                        Expanded(
                          child: _tarjetaServicio(
                            icono: Icons.local_hospital,
                            titulo: 'Línea de SALUD',
                            color: const Color(0xFF00A54F),
                            onPressed: () async {
                              final authService = AuthService();
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF0D6EFD),
                                    ),
                                  );
                                },
                              );

                              try {
                                final respuesta = await authService.identificarAutorizacion(
                                  tipo_servicio: 'EPS-ARL',
                                  eps: eps,
                                  id_paciente: idPaciente,
                                  documentopaciente: documentopaciente,
                                  tipodocumentopaciente: tipodocumentopaciente
                                );

                                if (!context.mounted) return;
                                Navigator.of(context, rootNavigator: true).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ConvenioScreen(
                                      tipoServicio: 'EPS-ARL',
                                      respuestaApi: respuesta,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error al consultar la autorización: $e',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Expanded(
                          child: _tarjetaServicio(
                            icono: Icons.house_outlined,
                            titulo: 'Particulares IPS',
                            color: const Color(0xFF3693EB),
                            onPressed: () async {
                              final authService = AuthService();
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF0D6EFD),
                                    ),
                                  );
                                },
                              );

                              try {
                                final respuesta = await authService.identificarAutorizacion(
                                  tipo_servicio: 'Particular',
                                  eps:  eps,
                                  id_paciente: idPaciente,
                                  documentopaciente: documentopaciente,
                                  tipodocumentopaciente: tipodocumentopaciente
                                );

                                if (!context.mounted) return;
                                Navigator.of(context, rootNavigator: true).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ConvenioScreen(
                                      tipoServicio: 'Particular',
                                      respuestaApi: respuesta,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error al consultar la autorización: $e',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _tarjetaServicio(
                            icono: Icons.sentiment_very_satisfied,
                            titulo: 'Particular Divertido',
                            color: const Color(0xFF3693EB),
                            onPressed: () async {
                              final authService = AuthService();
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF0D6EFD),
                                    ),
                                  );
                                },
                              );
                              
                              try {
                                final respuesta = await authService.identificarAutorizacion(
                                  tipo_servicio: 'Divertido',
                                  eps: eps,
                                  id_paciente: idPaciente,
                                  documentopaciente: documentopaciente,
                                  tipodocumentopaciente: tipodocumentopaciente
                                );

                                if (!context.mounted) return;
                                Navigator.of(context, rootNavigator: true).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ConvenioScreen(
                                      tipoServicio: 'Divertido',
                                      respuestaApi: respuesta,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error al consultar la autorización: $e',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // INFORMACIÓN INFERIOR //
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    _informacionItem(
                      icono: Icons.lock_outline,
                      titulo: 'Seguro y confiable',
                      descripcion:
                          'Tu información está protegida con los más altos estándares.',
                      color: const Color(0xFF0D6EFD),
                    ),

                    const Divider(height: 28),

                    _informacionItem(
                      icono: Icons.access_time,
                      titulo: 'Ahorra tiempo',
                      descripcion:
                          'Gestiona tus citas y servicios de forma rápida y fácil.',
                      color: const Color(0xFF00A54F),
                    ),
                    /*
                    const Divider(height: 28),

                    _informacionItem(
                      icono: Icons.play_circle_outline,
                      titulo: '¿Necesitas ayuda?',
                      descripcion:
                          'Estamos aquí para apoyarte en lo que necesites.',
                      color: Colors.red,
                    ),
                    
                    const Divider(height: 28),

                    _informacionItem(
                      icono: Icons.email_outlined,
                      titulo: 'Contáctanos',
                      descripcion:
                          'Déjanos tus felicitaciones o sugerencias.',
                      color: const Color(0xFF00A54F),
                    ),*/
                  ],
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  // TARJETA DE SERVICIO // 
  static Widget _tarjetaServicio({
    required IconData icono,
    required String titulo,
    //required String descripcion,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [

          // ICONO
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icono,
              color: color,
              size: 30,
            ),
          ),

          const SizedBox(height: 12),

          // TITULO
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          // BOTÓN
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ingresar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    Icons.chevron_right,
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // INFORMACIÓN INFERIOR //
  static Widget _informacionItem({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Icon(
          icono,
          color: color,
          size: 30,
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                titulo,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                descripcion,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
