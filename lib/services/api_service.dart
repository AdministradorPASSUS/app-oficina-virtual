import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      //'http://10.0.2.2/passus-oficina-virtual-2.0/api'; // LOCAL
      'https://test-ofvirtual2.passusips.com/api'; // TEST

/*
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(data),
    );

    return _procesarRespuesta(response);
  }
*/

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    print('====================================');
    print('POST REQUEST');
    print('URL: $url');
    print('DATA: $data');
    print('====================================');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(data),
    );

    print('====================================');
    print('POST RESPONSE');
    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');
    print('====================================');

    return _procesarRespuesta(response);
  }

  Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    Map<String, dynamic> data, {
    required Map<String, PlatformFile> files,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    final request = http.MultipartRequest(
      'POST',
      url,
    );

    request.headers['Accept'] = 'application/json';

    // Campos normales
    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Archivos
    for (final entry in files.entries) {
      final nombreCampo = entry.key;
      final archivo = entry.value;

      if (archivo.path == null) {
        throw Exception(
          'No se pudo obtener la ruta del archivo: ${archivo.name}',
        );
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          nombreCampo,
          archivo.path!,
          filename: archivo.name,
        ),
      );
    }

    print('====================================');
    print('MULTIPART REQUEST');
    print('URL: $url');
    print('CAMPOS: ${request.fields}');
    print('ARCHIVOS: ${request.files.map((e) => e.filename).toList()}');
    print('====================================');

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    print('====================================');
    print('MULTIPART RESPONSE');
    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');
    print('====================================');

    return _procesarRespuesta(response);
  }

  Map<String, dynamic> _procesarRespuesta(
    http.Response response,
  ) {
    print('====================================');
    print('PROCESANDO RESPUESTA');
    print('STATUS CODE: ${response.statusCode}');
    print('BODY RAW: ${response.body}');
    print('====================================');

    try {
      final resultado = jsonDecode(response.body);

      print('JSON DECODIFICADO: $resultado');
      print('TIPO: ${resultado.runtimeType}');

      if (resultado is Map<String, dynamic>) {
        return resultado;
      }

      throw Exception(
        'La API no devolvió un objeto JSON válido.',
      );
    } catch (e) {
      print('ERROR JSON: $e');

      throw Exception(
        'Respuesta inválida del servidor: ${response.body}',
      );
    }
  }

}
/*
  Map<String, dynamic> _procesarRespuesta(
    http.Response response,
  ) {
    try {
      final resultado = jsonDecode(response.body);

      if (resultado is Map<String, dynamic>) {
        return resultado;
      }

      throw Exception(
        'La API no devolvió un objeto JSON válido.',
      );
    } catch (e) {
      throw Exception(
        'Respuesta inválida del servidor: ${response.body}',
      );
    }
  }
}
*/



/*
      //'http://localhost/passus-oficina-virtual-2.0/api';
      //'http://oficinavirtual/passus-oficina-virtual-2.0/api' */