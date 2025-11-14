// lib/main.dart - VERSIÓN CORREGIDA CON TICKETS
import 'package:flutter/material.dart';
import 'login/pages/login_page.dart';
import 'admin/pages/dashboard_admin.dart';
import 'empleado/pages/dashboard_empleado.dart';
import 'residente/pages/dashboard_residente.dart';
import 'residente/pages/politicas_residente.dart';
import 'residente/pages/reservas_residente.dart';
import 'residente/pages/tickets_residente.dart' as tickets; // ✅ USAR ALIAS
import 'residente/pages/perfil_residente.dart';

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
          primary: Color(0xFF264653),
          secondary: Color(0xFFE3A78C),
          surface: Color(0xFFF5F5F5),
          onPrimary: Colors.white,
          onSecondary: Color(0xFF2F241F),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF264653),
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
            borderSide: const BorderSide(color: Color(0xFFA3C8D6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF264653)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF264653),
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
            foregroundColor: const Color(0xFF264653),
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/admin/dashboard': (context) => const DashboardAdmin(),
        '/empleados/dashboard': (context) => const DashboardEmpleado(),

        // RUTAS PARA RESIDENTE - CORREGIDAS
        '/residente/dashboard': (context) => const DashboardResidentePage(),
        '/residente/tickets': (context) =>
            const tickets.TicketsResidentePage(), // ✅ USAR ALIAS
        '/residente/tickets/crear': (context) =>
            const tickets.CrearTicketPage(), // ✅ USAR ALIAS
        '/residente/reservas': (context) =>
            const ReservasResidentePage(), // ✅ ESTA ESTÁ BIEN
        '/residente/facturacion': (context) =>
            _buildPlaceholderPage('Facturación'),
        '/residente/politicas': (context) => const PoliticaResidentePage(),
        '/residente/perfil': (context) => const PerfilResidenteScreen(),
      },
      // Agregar manejo de rutas para tickets con parámetros
      onGenerateRoute: (settings) {
        // Manejar rutas con parámetros para tickets
        if (settings.name == '/residente/tickets/detalle') {
          final ticketId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) =>
                tickets.DetalleTicketPage(ticketId: ticketId), // ✅ USAR ALIAS
          );
        }

        // Si no coincide con ninguna ruta especial, usar el manejador por defecto
        return null;
      },
      // Agregar manejo de rutas desconocidas para debug
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Error de Ruta'),
              backgroundColor: Colors.red,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Ruta no encontrada: ${settings.name}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false),
                    child: const Text('Volver al Login'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildPlaceholderPage(String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF264653),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.orange[400],
            ),
            const SizedBox(height: 16),
            Text(
              '$title - En Desarrollo',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF264653),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta funcionalidad estará disponible pronto',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
