import 'package:flutter/material.dart';
import 'login/pages/login_page.dart';
import 'admin/pages/dashboard_admin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; 
import 'login/services/login_service.dart'; // ✅ IMPORTAR EL SERVICIO

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
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/admin/dashboard': (context) => const DashboardAdmin(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // ✅ MÉTODO ACTUALIZADO: INICIALIZAR APP Y COOKIES
  Future<void> _initializeApp() async {
    try {
      // ✅ INICIALIZAR COOKIES ANTES DE VERIFICAR AUTH
      await LoginService.initialize();
      await _checkAuthStatus();
    } catch (e) {
      print('❌ Error inicializando app: $e');
      _navigateToLogin();
    }
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final userData = prefs.getString('user_data');

      print('🔍 Estado de autenticación: isLoggedIn=$isLoggedIn, userData=${userData != null}');
      print('🔍 Cookie activa: ${LoginService.sessionCookie != null}');

      // Esperar un frame para asegurar que el contexto esté disponible
      await Future.delayed(Duration.zero);

      // ✅ VERIFICAR TANTO LA SESIÓN COMO LA COOKIE
      if (isLoggedIn && userData != null && LoginService.sessionCookie != null) {
        final userMap = json.decode(userData);
        final role = userMap['id_rol'];
        
        print('🎯 Usuario autenticado: ${userMap['nombre']}, Rol: $role');
        print('🍪 Cookie disponible: ${LoginService.sessionCookie!.substring(0, 30)}...');
        
        if (role == 1 && mounted) { // Administrador
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
          return;
        }
      } else {
        print('⚠️  Faltan credenciales: '
            'isLoggedIn=$isLoggedIn, '
            'userData=${userData != null}, '
            'cookie=${LoginService.sessionCookie != null}');
      }
      
      // Si no hay sesión válida, ir al login
      _navigateToLogin();
    } catch (e) {
      print('❌ Error verificando auth: $e');
      _navigateToLogin();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF264653)),
            ),
            const SizedBox(height: 20),
            Text(
              'Verificando sesión...',
              style: TextStyle(
                color: const Color(0xFF264653),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            if (!_isLoading) ...[
              const SizedBox(height: 10),
              Text(
                'Redirigiendo al login...',
                style: TextStyle(
                  color: const Color(0xFF264653).withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}