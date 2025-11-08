import 'package:flutter/material.dart';
import 'login/pages/login_page.dart';

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
          background: Color(0xFFF5F5F5), // GRIS CLARO
          surface: Color(0xFFEDE6E0), // BEIGE SUAVE
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
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/seleccionar_registro': (context) => const SimpleSeleccionarRegistro(),
        '/forgot_password': (context) => const SimpleForgotPassword(),
      },
    );
  }
}

// Páginas temporales simples
class SimpleSeleccionarRegistro extends StatelessWidget {
  const SimpleSeleccionarRegistro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar Registro')),
      body: const Center(child: Text('Seleccionar Registro - En desarrollo')),
    );
  }
}

class SimpleForgotPassword extends StatelessWidget {
  const SimpleForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Contraseña')),
      body: const Center(child: Text('Recuperar Contraseña - En desarrollo')),
    );
  }
}
