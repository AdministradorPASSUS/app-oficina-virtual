import 'api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'app_data.dart';

class AuthService {

  final ApiService api = ApiService();

  Future<Map<String, dynamic>> login({
    required String documento,
    required String correo,
  }) async {

    return await api.post(
      'auth/loginApi.php',
      {
        'documento_identidad': documento,
        'correo_electronico': correo,
      },
    );
  }

  Future<Map<String, dynamic>> crearAutorizacion({
    required String numero_autorizacion,
    required String linea_pago,
    required PlatformFile soporte_autorizacion, PlatformFile? soporte_orden_medica,
    required String tipo_servicio,
    required String eps,
    required String id_paciente,
    required String correo_notificacion,
  }) async {
    return await api.postMultipart(
      'services/crear_autorizacionApi.php',
      {
        'numero_autorizacion': numero_autorizacion,
        'linea_pago': 'SN02|03|01|Coti|Grupo A|SANITAS - SUBSIDIADO|',
        'tipo_servicio': tipo_servicio,
        'eps': eps,
        'id_paciente': id_paciente,
        'correo_notificacion': correo_notificacion
      },
      files: {
        'soporte_autorizacion': soporte_autorizacion,
        if (soporte_orden_medica != null)
          'soporte_orden_medica': soporte_orden_medica,
      },
    );
  }

  Future<Map<String, dynamic>> identificarAutorizacion({
    required String tipo_servicio,
    required String eps,
    required String id_paciente,
    required String documentopaciente,
    required String tipodocumentopaciente
  }) async {  
    return await api.post(
      'services/identificador_autorizacionApi.php',
      {
        'tipo_servicio': tipo_servicio,
        'eps': eps,
        'id_paciente': id_paciente,
        'documentopaciente': documentopaciente,
        'tipodocumentopaciente': tipodocumentopaciente
      }
    );
  }

  Future<Map<String, dynamic>> filtroPiscina({
    required String tipo_servicio,
    required String especialidad,
    required String oficina,
  }) async {  
    return await api.post(
      'services/filtros_Api.php',
      {
        'tipo_servicio': tipo_servicio,
        'especialidad': especialidad,
        'oficina': oficina,
      }
    );
  }

  // CONSULTAR AGENDA DISPONIBLE
  Future<Map<String, dynamic>> consultarAgendaDisponible({
    required String tipoServicio,
    required String especialidad,
    required String oficina,
    String profesor = '',
    required String ciudad,
    required String sede,
    required String fechadeseada,
    required String piscina,
    String? fechafinal,
    String? fecha,
  }) async {
    return await api.post(
      'services/agenda_disponibleApi.php',
      {
        'tipo_servicio': tipoServicio,
        'especialidad': especialidad,
        'oficina': oficina,
        'profesor': profesor,
        'ciudad': ciudad,
        'sede': sede,
        'piscina': piscina,
        'fechafinal': fechafinal,
        'fechadeseada': fechadeseada,
        if (fecha != null && fecha.isNotEmpty)
          'fnext': fecha,
      },
    );
  }

  
  Future<Map<String, dynamic>> confirmarCitas({
    required Map<String, dynamic> informacion,
  }) async {
    debugPrint('[AuthService] Iniciando confirmarCitas');
    debugPrint('[AuthService] Información: $informacion');

    try {
      final respuesta = await api.post(
        'services/confirmar_AgendaAPi.php',
        informacion,
      );

      debugPrint('[AuthService] Respuesta: $respuesta');

      return respuesta;
    } catch (e, stackTrace) {
      debugPrint('[AuthService] ERROR: $e');
      debugPrint('[AuthService] Tipo: ${e.runtimeType}');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // HISTORIAL DE CITAS

  Future<Map<String, dynamic>> consultarCitasAgendadas({
    required String tipoDocumento,
    required String documento,
  }) async {

    debugPrint('[AuthService] Consultando citas agendadas');

    try {

      final respuesta = await api.post(
        'services/historico_citasApi.php',
        {
          'tipoDocumento': tipoDocumento,
          'documento': documento,
        },
      );

      debugPrint('[AuthService] Respuesta citas: $respuesta');

      return respuesta;

    } catch (e, stackTrace) {

      debugPrint('[AuthService] ERROR consultando citas: $e');

      debugPrintStack(stackTrace: stackTrace);

      rethrow;
    }
  }

  // CIERRE DE SESION

  Future<void> cerrarSesion() async {

    AppData.limpiarSesion();

    debugPrint('Cierre de sesión completado.');
  }

/*  Future<Map<String, dynamic>> confirmarCitas({
    required Map<String, dynamic> informacion,
  }) async {
    return await api.post(
      'services/confirmar_AgendaAPi.php',
      informacion,
    );
  }

}
*/
}
