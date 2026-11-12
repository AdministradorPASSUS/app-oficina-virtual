import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:oficina_virtual_movil/screens/registro_screen.dart';
import 'screens/login_screen.dart';
//import 'screens/inicio_screen.dart';
//import 'screens/registro_screen.dart';
//import 'screens/confirmar_registro_screen.dart';
//import 'screens/certificados_screen.dart';
//import 'screens/citas_agendadas_screen.dart';
//import 'screens/crear_autorizacion_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es_CO', null);

  runApp(const PassusApp());
}

class PassusApp extends StatelessWidget {
  const PassusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PASSUS',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Open Sans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D6EFD),
          
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

/*
class PassusApp extends StatelessWidget {
  const PassusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PASSUS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const InicioScreen(),
    );
  }
}
*/
/*
class PassusApp extends StatelessWidget {
  const PassusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PASSUS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const RegistroScreen(),
    );
  }
}
*/
/*
class PassusApp extends StatelessWidget {
  const PassusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PASSUS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const ConfirmaRegistroScreen(),
    );
  }
}
*/
/*
class PassusApp extends StatelessWidget {
  const PassusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PASSUS',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Open Sans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D6EFD),
        ),
      ),
      home: const CertificadoScreen(),
    );
  }
}
*/
/*
class PassusApp extends StatelessWidget {
  const PassusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PASSUS',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Open Sans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D6EFD),
        ),
      ),
      home: const CitasAgendadasScreen(),
    );
  }
}
*/
/*
class PassusApp extends StatelessWidget {
  const PassusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PASSUS',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Open Sans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D6EFD),
        ),
      ),
      home: const AutorizacionScreen(
        tipoServicio: 'EPS-ARL',
      ),
    );
  }
}
*/

