import 'package:flutter/material.dart';
import 'package:oficina_virtual_movil/screens/login_validar_token.dart';
import '../../services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController documentoController =
      TextEditingController();

  final TextEditingController correoController =
      TextEditingController();

  final AuthService authService = AuthService();

  bool cargando = false;

  @override
  void dispose() {
    documentoController.dispose();
    correoController.dispose();
    super.dispose();
  }

  Future<void> iniciarSesion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      final resultado = await authService.login(
        documento: documentoController.text.trim(),
        correo: correoController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      if (resultado['success'] == true) {


/*
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              resultado['message'] ??
                  'Código de acceso generado correctamente.',
            ),
          ),
        );*/
      
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginValidarToken(
              documento: documentoController.text.trim(),
              correo: correoController.text.trim(),
            ),
          ),
        );
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              resultado['message'] ??
                  'No fue posible generar el código de acceso.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });
/*
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No fue posible conectarse con el servidor.',
          ),
          backgroundColor: Colors.red,
        ),
      );*/
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error de conexión:\n$e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // LOGO //

                  Image.asset(
                    'assets/images/logo_passus.png',
                    height: 90,

                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return const Icon(
                        Icons.local_hospital,
                        size: 80,
                        color: Color(0xFF0D6EFD),
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  // TITULO //


                  const Text(
                    'Iniciar sesión',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // DESCRIPCIÓN //

                  const Text(
                    'Ingresa tu número de identidad y el correo electrónico registrado.',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // DOCUMENTO //

                  TextFormField(
                    controller: documentoController,

                    keyboardType: TextInputType.text,

                    decoration: InputDecoration(
                      labelText: 'Documento de identidad',
                      hintText: 'Ingrese su documento',

                      prefixIcon: const Icon(
                        Icons.person_outline,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    validator: (value) {

                      if (value == null ||
                          value.trim().isEmpty) {

                        return 'Ingrese su documento';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // CORREO //

                  TextFormField(
                    controller: correoController,

                    keyboardType:
                        TextInputType.emailAddress,

                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      hintText: 'ejemplo@correo.com',

                      prefixIcon: const Icon(
                        Icons.email_outlined,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    validator: (value) {

                      if (value == null ||
                          value.trim().isEmpty) {

                        return 'Ingrese su correo electrónico';
                      }

                      final correo = value.trim();

                      final regex = RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      );

                      if (!regex.hasMatch(correo)) {

                        return 'Ingrese un correo electrónico válido';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  // BOTÓN INGRESAR //

                  SizedBox(
                    height: 52,

                    child: ElevatedButton(
                      onPressed:
                          cargando ? null : iniciarSesion,

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF0D6EFD),

                        foregroundColor:
                            Colors.white,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),

                      child: cargando

                          ? const SizedBox(
                              width: 24,
                              height: 24,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )

                          : const Text(
                              'Ingresar',

                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // REGISTRO //

                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),

                        children: [

                          const TextSpan(
                            text:
                                '¿No tienes una cuenta? ',
                          ),

                          TextSpan(
                            text: 'Crear una cuenta',
                            style: const TextStyle(
                              color: Color(0xFF0D6EFD),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final Uri url = Uri.parse(
                                  'https://oficinavirtual.passusips.com/login/register',
                                );

                                try {
                                  await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } catch (e) {
                                  debugPrint('Error al abrir la página: $e');
                                }
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

