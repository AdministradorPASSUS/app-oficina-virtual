import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oficina_virtual_movil/screens/inicio_screen.dart';
import '../../services/app_data.dart';

class LoginValidarToken extends StatefulWidget {
  final String documento;
  final String correo;

  const LoginValidarToken({
    super.key,
    required this.documento,
    required this.correo,
  });

  @override
  State<LoginValidarToken> createState() => _LoginValidarTokenState();
}

class _LoginValidarTokenState extends State<LoginValidarToken> {
  final TextEditingController _codigoController = TextEditingController();

  bool _cargando = false;

  Future<void> _validarCodigo() async {
    final codigo = _codigoController.text.trim();

    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingrese el código de acceso.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      final url = Uri.parse(
        //'http://10.0.2.2/passus-oficina-virtual-2.0/api/auth/verificar_codigoApi.php', //LOCAL
        'https://test-ofvirtual2.passusips.com/api/auth/verificar_codigoApi.php', // TEST
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'documento_identidad': widget.documento,
          'codigo': codigo,
        }),
      );

/*
      final response = await http.post(
        url,
        headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        },
        body: jsonEncode({
        'documento_identidad': widget.documento,
        'codigo': codigo,
        }),
        );
        print('STATUS => ${response.statusCode}');
        print('BODY => ${response.body}');

      if (response.body.trim().startsWith('<')) {
      throw Exception(
      'La API devolvió HTML:\n${response.body}',
      );
      }
      */

      final data = jsonDecode(response.body);

      //final data = jsonDecode(response.body);

      if (!mounted) return;

      if (data['success'] == true) {
        
        // Captura la info de la api
          AppData.idPaciente = data['usuario']['idpaciente']?.toString() ?? '';
          AppData.tipoDocumento = data['usuario']['tipo_documento']?.toString() ?? '';
          AppData.documentoIdentidad = data['usuario']['documento']?.toString() ?? '';
          AppData.nombrePaciente = data['usuario']['nombre']?.toString() ?? '';
          AppData.correoElectronico = data['usuario']['correo']?.toString() ?? '';
          AppData.celular = data['usuario']['celular']?.toString() ?? '';
          AppData.perfil = data['usuario']['perfil']?.toString() ?? '';
          AppData.eps = data['usuario']['eps']?.toString() ?? '';
          AppData.ciudad = data['usuario']['ciudad']?.toString() ?? '';
          AppData.sede = data['usuario']['sede']?.toString() ?? '';

        Navigator.pushReplacement(
           context,
           MaterialPageRoute(
              builder: (_) => const InicioScreen(),
           ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? 'El código no es válido.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error de conexión: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo_passus.png',
                  height: 90,
                ),

                const SizedBox(height: 40),

                const Text(
                  'Iniciar sesión',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Ingresa el código de acceso que enviamos '
                  'al correo electrónico registrado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  widget.correo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 25),

                TextField(
                  controller: _codigoController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'Código de acceso',
                    hintText: 'Ingrese el código',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  onSubmitted: (_) => _validarCodigo(),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _validarCodigo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D6EFD),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _cargando
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Validar',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  height: 55,
                  child: OutlinedButton(
                    onPressed: _cargando
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    child: const Text(
                      'Regresar',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}