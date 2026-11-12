
import 'dart:async';
import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> confirmarCitas({
    required Map<String, dynamic> informacion,
  }) async {
    try {
      final api = ApiService();

      print('====================================');
      print('CONFIRMANDO CITAS');
      print('INFORMACION: $informacion');
      print('====================================');

      final datos = await api
          .post(
            'services/confirmar_citaApi.php',
            informacion,
          )
          .timeout(
            const Duration(seconds: 60),
          );

      print('====================================');
      print('RESULTADO CONFIRMACION DE CITAS');
      print('RESPUESTA: $datos');
      print('====================================');

      // Asegurar que la respuesta tenga el formato esperado.
      datos.putIfAbsent(
        'citas_agendadas',
        () => [],
      );

      datos.putIfAbsent(
        'citas_fallidas',
        () => [],
      );

      datos.putIfAbsent(
        'message',
        () => datos['success'] == true
            ? 'Las citas fueron procesadas.'
            : 'No fue posible confirmar las citas.',
      );  

      // La API puede responder HTTP 200 y reportar fallos
      // individuales dentro del JSON.
      if (datos['success'] != true) {
        datos['success'] = false;
      }

      return datos;
    } on TimeoutException catch (e) {
      print('ERROR: TIEMPO DE ESPERA AGOTADO');
      print(e);

      return {
        'success': false,
        'message':
            'La solicitud tardó demasiado. Verifica el resultado antes de volver a intentar.',
        'detalle': e.toString(),
        'citas_agendadas': [],
        'citas_fallidas': [],
      };
    } catch (e) {
      print('====================================');
      print('ERROR CONFIRMANDO CITAS');
      print(e);
      print('====================================');

      return {
        'success': false,
        'message':
            'Ocurrió un inconveniente al confirmar las citas.',
        'detalle': e.toString(),
        'citas_agendadas': [],
        'citas_fallidas': [],
      };
    }
  }
}
