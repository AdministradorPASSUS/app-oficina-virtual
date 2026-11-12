
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:oficina_virtual_movil/screens/inicio_screen.dart';
import '../../services/auth_service.dart';
import '../../services/app_data.dart';

class AutorizacionScreen extends StatefulWidget {
  final String tipoServicio;

  const AutorizacionScreen({
    super.key,
    required this.tipoServicio,
  });

  @override
  State<AutorizacionScreen> createState() =>
      _AutorizacionScreenState();
}

  final correo_notificacion = AppData.correoElectronico;
  final id_paciente = AppData.idPaciente;
  final epsPaciente = AppData.eps;

class _AutorizacionScreenState extends State<AutorizacionScreen> {

  final TextEditingController numeroController =
      TextEditingController();

  String? epsSeleccionada;
  String? tipoAfiliacionSeleccionada;
  String? categoriaSeleccionada;

  PlatformFile? documento;
  PlatformFile? documentoOrden;

  bool documentoEnviado = false;
  bool cargando = false;

  final List<String> eps = [
    'FAMISANAR - CONTRIBUTIVO',
    'FAMISANAR - SUBSIDIADO',
    'ALIANSALUD EPS',
    'NUEVA EPS - CONTRIBUTIVO',
    'NUEVA EPS - SUBSIDIADO',
    'COMPENSAR - CONTRIBUTIVO',
    'COMPENSAR - SUBSIDIADO',
    'SURA - CONTRIBUTIVO', 
    'SURA - SUBSIDIADO',
    'COLMEDICA MEDICINA PREPAGADA',
    'FOMAG',
    'SANITAS - CONTRIBUTIVO',
    'SANITAS - SUBSIDIADO',
    'SEGUROS BOLIVAR',
    'CAFAM - CONTRIBUTIVO',
    'CAFAM - SUBSIDIADO',
    'POSITIVA COMPAÑÍA DE SEGUROS S.A',
    'PARTICULAR HIDROTERAPIA',
    'PARTICULAR REHABILITACION',
    'PASSUS DIVERTIDO'
  ];

  final Map<String, List<String>> tiposAfiliacion = {
    'EPS SURA': [
      'Contributivo'
    ],
    'EPS Sanitas': [
      'Subsidiado',
    ],
    'Nueva EPS': [
      'Contributivo',
      'Subsidiado',
    ],
    'Particular': [
      'Particular',
    ],
    'FAMISANAR - CONTRIBUTIVO':[
      'Contributivo'
    ],
    'FAMISANAR - SUBSIDIADO':[
      'Subsidiado',
    ],
    'ALIANSALUD EPS':[
      'Contributivo'
    ],
    'NUEVA EPS - CONTRIBUTIVO':[
      'Contributivo'
    ],
    'NUEVA EPS - SUBSIDIADO':[
      'Subsidiado',
    ],
    'COMPENSAR - CONTRIBUTIVO':[
      'Contributivo'
    ],
    'COMPENSAR - SUBSIDIADO':[
      'Subsidiado',
    ],
    'SURA - CONTRIBUTIVO':[
      'Contributivo'
    ],
    'SURA - SUBSIDIADO':[
      'Subsidiado',
    ],
    'COLMEDICA MEDICINA PREPAGADA':[
      'Contributivo'
    ],
    'FOMAG':[
      'Especial'
    ],
    'SANITAS - CONTRIBUTIVO':[
      'Contributivo'
    ],
    'SANITAS - SUBSIDIADO':[
      'Subsidiado',
    ],
    'SEGUROS BOLIVAR':[
      'Contributivo'
    ],
    'CAFAM - CONTRIBUTIVO':[
      'Contributivo'
    ],
    'CAFAM - SUBSIDIADO':[
      'Subsidiado',
    ],
    'POSITIVA COMPAÑÍA DE SEGUROS S.A':[
      'Contributivo'
    ],
    'PARTICULAR HIDROTERAPIA':[
      'Particular',
    ],
    'PARTICULAR REHABILITACION':[
      'Particular',
    ],
    'PASSUS DIVERTIDO':[
      'Particular',
    ],
  };

  final Map<String, List<String>> categorias = {
    'Contributivo': [
      'Cotizante',
      'Beneficiario',
    ],
    'Subsidiado': [
      'Nivel 1',
      'Nivel 2',
      'Nivel 3',
    ],
    'Particular': [
      'Particular',
    ],
    'Especial': [
      'Especial',
    ],
  };

  bool get esParticular =>
      widget.tipoServicio == 'Particular' ||
      widget.tipoServicio == 'Divertido';

  bool get esEPSARL =>
      widget.tipoServicio == 'EPS-ARL';

  String get tituloPaso1 {
    if (esParticular) {
      return 'Soporte de pago';
    }

    return 'Autorización';
  }

  String get subtituloPaso1 {
    if (esParticular) {
      return 'Servicios pagados';
    }

    return 'Servicios autorizados';
  }

  String get tituloPrincipal {
    switch (widget.tipoServicio) {
      case 'EPS-ARL':
        return 'EPS o ARL';

      case 'Particular':
        return 'Particulares IPS';

      case 'Divertido':
        return 'Particular Divertido';

      default:
        return 'Autorización';
    }
  }

  String get descripcionPrincipal {
    switch (widget.tipoServicio) {
      case 'EPS-ARL':
        return 'Por favor carga la autorización para Hidroterapia o ingreso a Programa de Rehabilitación.';

      case 'Particular':
        return 'Por favor carga el soporte de pago para Hidroterapia u otros servicios particulares.';

      case 'Divertido':
        return 'Por favor carga el soporte de pago para clases de Natación y programas de bienestar.';

      default:
        return '';
    }
  }

  String get textoDocumento {
    if (esParticular) {
      return 'Adjunte el soporte de pago en formato PDF, PNG, JPG o JPEG (Máx. 10Mb)';
    }

    return 'Adjunte el soporte de autorización en formato PDF, PNG, JPG o JPEG (Máx. 10Mb)';
  }

  String get textoNumero {
    if (esParticular) {
      return 'Número de transacción';
    }

    return 'Número de autorización';
  }

  Future<void> seleccionarDocumento({
    required bool orden,
  }) async {
    final archivos = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'png',
        'jpg',
        'jpeg',
      ],
    );

    if (archivos.isEmpty) {
      return;
    }

    final archivo = archivos.first;

    const maxBytes = 10 * 1024 * 1024;

    final tamano = await archivo.length();

    if (tamano != null && tamano > maxBytes) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El archivo supera el tamaño permitido (máx. 10 MB).',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      if (orden) {
        documentoOrden = archivo;
      } else {
        documento = archivo;
      }
    });
  }

  void eliminarDocumento({
    required bool orden,
  }) {
    setState(() {
      if (orden) {
        documentoOrden = null;
      } else {
        documento = null;
      }
    });
  }

  String convertirTamano(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  void cambiarEPS(String? value) {
    setState(() {
      epsSeleccionada = value;
      tipoAfiliacionSeleccionada = null;
      categoriaSeleccionada = null;
    });
  }

  void cambiarTipoAfiliacion(String? value) {
    setState(() {
      tipoAfiliacionSeleccionada = value;
      categoriaSeleccionada = null;
    });
  }

Future<void> enviarDocumento() async {

  // VALIDACIONES // 

  if (numeroController.text.trim().isEmpty) {
    mostrarError('Por favor ingresa $textoNumero.');
    return;
  }

  if (epsSeleccionada == null) {
    mostrarError('Por favor selecciona una EPS o servicio.');
    return;
  }

  if (tipoAfiliacionSeleccionada == null) {
    mostrarError('Por favor selecciona el tipo de afiliación.');
    return;
  }

  if (categoriaSeleccionada == null) {
    mostrarError('Por favor selecciona el nivel de afiliación.');
    return;
  }

  if (documento == null) {
    mostrarError('Por favor adjunta el documento soporte.');
    return;
  }

  if (esEPSARL && documentoOrden == null) {
    mostrarError('Por favor adjunta la orden médica.');
    return;
  }

  // ACTIVAR CARGANDO //

  setState(() {
    cargando = true;
  });

  try {
    final AuthService authService = AuthService();

    // PREPARAR DOCUMENTOS //

    final resultado = await authService.crearAutorizacion(
      numero_autorizacion: numeroController.text.trim(),
      linea_pago: '',
      soporte_autorizacion: documento!,
      soporte_orden_medica: esEPSARL ? documentoOrden : null,
      tipo_servicio: widget.tipoServicio,
      eps: epsPaciente,
      id_paciente: id_paciente,
      correo_notificacion : correo_notificacion,
    );

    if (!mounted) return;

    // RESPUESTA DE LA API //

    if (resultado['success'] == true) {
      setState(() {
        cargando = false;
        documentoEnviado = true;
      });

    } else {
      setState(() {
        cargando = false;
      });

      mostrarError(
        resultado['message'] ??
            'No fue posible crear la autorización.',
      );
    }
  } catch (e) {
    debugPrint('==============================');
    debugPrint('ERROR CREAR AUTORIZACION');
    debugPrint('ERROR: $e');
    //debugPrint('STACKTRACE: $stackTrace');
    debugPrint('==============================');

    if (!mounted) return;

    setState(() {
      cargando = false;
    });

    mostrarError(
      e.toString().replaceFirst('Exception: ', ''),
    );
  }
}

  void mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    numeroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      appBar: AppBar(
        title: const Text(
          'PASSUS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF222222),
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (!documentoEnviado) ...[
                _buildWizard(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTitulo(),
                      const SizedBox(height: 20),
                      _buildFormulario(),
                      const SizedBox(height: 20),
                      _buildBotones(),
                    ],
                  ),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildConfirmacion(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWizard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        0,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE0E0E0),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildPaso(
              numero: '1',
              titulo: tituloPaso1,
              subtitulo: subtituloPaso1,
              activo: true,
            ),

            _buildPaso(
              numero: '2',
              titulo: 'Agenda',
              subtitulo: 'Selecciona tus citas',
            ),

            _buildPaso(
              numero: '3',
              titulo: 'Confirmación',
              subtitulo: 'Información de agendamiento',
            ),

            _buildPaso(
              numero: '4',
              titulo: 'Listo',
              subtitulo: 'Resultado del agendamiento',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaso({
    required String numero,
    required String titulo,
    required String subtitulo,
    bool activo = false,
  }) {
    return Container(
      width: 230,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: activo
            ? const Color(0xFFF0F8FF)
            : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: activo
                ? const Color(0xFF007BFF)
                : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF007BFF),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF007BFF),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              numero,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  subtitulo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitulo() {
    return Column(
      children: [
        Text(
          tituloPrincipal,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          descripcionPrincipal,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFormulario() {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              esParticular
                  ? 'Información soporte de pago'
                  : 'Información autorización',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: numeroController,
              decoration: InputDecoration(
                labelText: textoNumero,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(
                  Icons.confirmation_number_outlined,
                ),
              ),
            ),

            const SizedBox(height: 18),

            _buildDropdown(
              label: esParticular
                  ? 'Seleccione su Servicio'
                  : 'Seleccione su EPS',
              value: epsSeleccionada,
              items: eps,
              onChanged: cambiarEPS,
            ),

            const SizedBox(height: 18),

            _buildDropdown(
              label: 'Tipo de Afiliación',
              value: tipoAfiliacionSeleccionada,
              items: epsSeleccionada == null
                  ? []
                  : tiposAfiliacion[
                          epsSeleccionada!] ??
                      [],
              onChanged:
                  cambiarTipoAfiliacion,
            ),

            const SizedBox(height: 18),

            _buildDropdown(
              label: 'Nivel de Afiliación',
              value: categoriaSeleccionada,
              items:
                  tipoAfiliacionSeleccionada ==
                          null
                      ? []
                      : categorias[
                              tipoAfiliacionSeleccionada!] ??
                          [],
              onChanged: (value) {
                setState(() {
                  categoriaSeleccionada =
                      value;
                });
              },
            ),

            const SizedBox(height: 24),

            const Divider(),

            const SizedBox(height: 12),

            const Text(
              'Documento soporte',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              textoDocumento,
              style: const TextStyle(
                color: Colors.red,
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 15),

            _buildSelectorArchivo(
              archivo: documento,
              orden: false,
            ),

            if (esEPSARL) ...[
              const SizedBox(height: 20),

              const Text(
                'Orden médica',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Adjunte el soporte de la orden médica en formato PDF, PNG, JPG o JPEG (Máx. 10Mb)',
                style: TextStyle(
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 12),

              _buildSelectorArchivo(
                archivo: documentoOrden,
                orden: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue:
          items.contains(value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map(
        (item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        },
      ).toList(),
      onChanged:
          items.isEmpty ? null : onChanged,
    );
  }

  Widget _buildSelectorArchivo({
    required PlatformFile? archivo,
    required bool orden,
  }) {
    if (archivo == null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            seleccionarDocumento(
              orden: orden,
            );
          },
          icon: const Icon(
            Icons.upload_file,
          ),
          label: const Text(
            'Seleccionar documento',
          ),
          style: OutlinedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(
              vertical: 18,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF8F0),
            borderRadius:
                BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF00A54F),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF00A54F),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      archivo.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    FutureBuilder<int?>(
                      future: archivo.length(),
                      builder:
                          (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text(
                            'Calculando tamaño...',
                          );
                        }

                        return Text(
                          convertirTamano(
                            snapshot.data!,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              IconButton(
                tooltip: 'Eliminar',
                onPressed: () {
                  eliminarDocumento(
                    orden: orden,
                  );
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        _buildVistaPrevia(archivo),
      ],
    );
  }

  Widget _buildVistaPrevia(
    PlatformFile archivo,
  ) {
    final extension =
        archivo.extension?.toLowerCase();

    if ([
      'jpg',
      'jpeg',
      'png',
    ].contains(extension)) {
      return FutureBuilder<List<int>>(
        future: archivo.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Container(
              width: double.infinity,
              height: 180,
              alignment: Alignment.center,
              child:
                  const CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError ||
              !snapshot.hasData) {
            return Container(
              width: double.infinity,
              height: 180,
              alignment: Alignment.center,
              child: const Text(
                'No se pudo mostrar la vista previa.',
              ),
            );
          }

          return Container(
            width: double.infinity,
            constraints:
                const BoxConstraints(
              maxHeight: 450,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
              ),
              borderRadius:
                  BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(8),
              child: Image.memory(
                Uint8List.fromList(
                  snapshot.data!,
                ),
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      );
    }

    if (extension == 'pdf') {
      return Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius:
              BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 60,
              color: Colors.red,
            ),

            SizedBox(height: 10),

            Text(
              'Documento PDF seleccionado',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildBotones() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(
              color: Colors.red,
            ),
            padding:
                const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 16,
            ),
          ),
          child: const Text(
            'Cancelar',
          ),
        ),

        const SizedBox(width: 10),

        ElevatedButton(
          onPressed: cargando
              ? null
              : enviarDocumento,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFF00A54F),
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 16,
            ),
          ),
          child: cargando
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Enviar documento',
                ),
        ),
      ],
    );
  }

  Widget _buildConfirmacion() {
    final bool esSoportePago = esParticular;

    final String titulo = esSoportePago
        ? '¡Soporte de pago recibido con éxito!'
        : '¡Soporte de autorización recibido con éxito!';

    final String descripcion = esSoportePago
        ? 'Hemos recibido correctamente tu comprobante de pago.'
        : 'Hemos recibido correctamente tu soporte de autorización.';

    final String mensaje = esSoportePago
        ? 'En las próximas 24 horas hábiles validaremos la información y, una vez aprobada, podrás continuar con el agendamiento de tus citas.'
        : 'En las próximas 24 horas hábiles validaremos la información. Una vez sea aprobada, recibirás una confirmación en tu correo electrónico y podrás continuar con el agendamiento de tus citas.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E8E3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),

          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFFE6F7ED),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 58,
              color: Color(0xFF00A54F),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF198754),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            descripcion,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD6E8FF),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 32,
                  color: Color(0xFF0D6EFD),
                ),

                const SizedBox(height: 12),

                Text(
                  mensaje,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const InicioScreen(),
                    ),
                      (route) => false,
                    );
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

