import 'package:flutter/material.dart';
import 'login/pages/login_page.dart';
import 'admin/pages/dashboard_admin.dart';
import 'empleado/pages/dashboard_empleado.dart';
import 'residente/pages/dashboard_residente.dart';
import 'login/pages/seleccionar_registro_page.dart';
import 'login/pages/verification_code_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema Edificio Inteligente',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF264653), // AZUL PROFUNDO
          secondary: Color(0xFFE3A78C), // DURAZNO SUAVE
          surface: Color(0xFFF5F5F5), // GRIS CLARO
          onPrimary: Colors.white,
          onSecondary: Color(0xFF2F241F), // MARRON OSCURO
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // GRIS CLARO
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF264653), // AZUL PROFUNDO
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFFA3C8D6)), // CELESTE CLARO
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF264653)), // AZUL PROFUNDO
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF264653), // AZUL PROFUNDO
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF264653), // AZUL PROFUNDO
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
  routes: {
  '/login': (context) => const LoginPage(),
  '/admin/dashboard': (context) => const DashboardAdmin(),
  '/verificacion_codigo': (context) {
    // ✅ MÁS SEGURO AÚN
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is String) {
      return VerificacionCodePage(rol: arguments);
    }
    // Si no hay argumentos o no son String, redirige al login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/login');
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  },
},
    );
  }
}