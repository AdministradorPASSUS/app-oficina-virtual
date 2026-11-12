import 'package:flutter/material.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegistroScreen> {
  final TextEditingController documentoController =
      TextEditingController();

  final TextEditingController correoController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    documentoController.dispose();
    correoController.dispose();
    super.dispose();
  }

  void _continuar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Datos válidos. Próximamente se conectará el registro.'),
      ),
    );
  }

  void _cancelar() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Row(
          children: [

            // PANEL IZQUIERDO //
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // HEADER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
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

                  // CONTENIDO
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 24,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 460,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // TÍTULO
                                const Text(
                                  'Registro de usuario',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF222222),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // DESCRIPCIÓN
                                const Text(
                                  'Ingresa tu documento de identidad y dirección '
                                  'de correo electrónico y enviaremos un enlace '
                                  'para realizar el proceso de registro.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                    color: Colors.black54,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // DOCUMENTO
                                TextFormField(
                                  controller: documentoController,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: 'Número de documento',
                                    hintText: 'Ingrese número de documento',
                                    prefixIcon: const Icon(
                                      Icons.badge_outlined,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFD5D5D5),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF00A54F),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Ingrese su número de documento';
                                    }
                                  
                                    final documento = value.trim();

                                    final valido = RegExp(
                                      r'^[A-Za-z0-9]+$',
                                    ).hasMatch(documento);

                                    if (!valido) {
                                      return 'Solo se permiten letras y números';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 18),

                                // CORREO
                                TextFormField(
                                  controller: correoController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    labelText: 'Correo electrónico',
                                    hintText: 'Ingrese correo electrónico',
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFD5D5D5),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF00A54F),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Ingrese su correo electrónico';
                                    }

                                    final correo = value.trim();

                                    final valido = RegExp(
                                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                    ).hasMatch(correo);

                                    if (!valido) {
                                      return 'Ingrese un correo electrónico válido';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 24),

                                // CAPTCHA
                                Container(
                                  width: double.infinity,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F8F8),
                                    border: Border.all(
                                      color: const Color(0xFFD8D8D8),
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.verified_user_outlined,
                                        color: Color(0xFF777777),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Verificación CAPTCHA',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // CONTINUAR
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton.icon(
                                    onPressed: _continuar,
                                    icon: const Icon(
                                      Icons.login,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Continuar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF00A54F),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // CANCELAR
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _cancelar,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFFDC3545),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: const Text(
                                      'Cancelar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
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
                  ),

                  // FOOTER
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
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

            // PANEL DERECHO //
            if (MediaQuery.of(context).size.width >= 700)
              Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF3693EB),
                        Color(0xFF00A54F),
                      ],
                    ),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Oficina Virtual\nAgendamiento Web',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),

                            const SizedBox(height: 22),

                            const Text(
                              'Asigna tus citas de Hidroterapia - '
                              'Ingreso a programa de Rehabilitación - '
                              'Clases de Natación.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 40),

                            Image.asset(
                              'assets/images/clinic-doctor-login.png',
                              width: 320,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

