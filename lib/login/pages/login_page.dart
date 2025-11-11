import 'package:flutter/material.dart';
import '../services/login_service.dart';
import '../services/captcha_widget.dart';
import '/residente/pages/dashboard_residente.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _captchaValue = '';
  String _captchaId = '';
  bool _isCaptchaValid = false;

  @override
  void initState() {
    super.initState();
    _testConnection();
    _testAuth();
    // Inicializar valores del CAPTCHA
    _captchaValue = '';
    _captchaId = '';
    _isCaptchaValid = false;
  }

  Future<void> _testAuth() async {
    print('🧪 Probando endpoint de auth...');
    await LoginService.testAuth();
  }

  Future<void> _testConnection() async {
    await LoginService.testConnection();
  }

  Future<void> _login() async {
    print('🔐 Intentando login...');
    print('📧 Email: ${_emailController.text}');
    print('🔑 Password: ${_passwordController.text}');
    print('📝 CAPTCHA Value: $_captchaValue');
    print('🆔 CAPTCHA ID: $_captchaId');
    print('✅ CAPTCHA Válido: $_isCaptchaValid');

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      print('❌ Campos vacíos');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isCaptchaValid) {
      print('❌ CAPTCHA no válido');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa el CAPTCHA correctamente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userLogin = UserLogin(
        correo: _emailController.text,
        password: _passwordController.text,
        captcha: _captchaValue,
        captchaId: _captchaId,
      );

      print('🔄 Llamando a LoginService.login...');
      final response = await LoginService.login(userLogin);

      print('🔍 Login response recibida: $response');

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (response['success'] == true) {
        print('✅ Login exitoso en Flutter');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Login exitoso'),
            backgroundColor: const Color(0xFF7A8C6E),
          ),
        );

        final userData = response['user'];
        if (userData != null) {
          print('🔄 Redirigiendo por rol: ${userData['id_rol']}');
          _redirectByRole(userData['id_rol']);
        } else {
          print('❌ User data es null');
        }
      } else {
        print('❌ Login falló: ${response['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Error desconocido'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error en _login: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _redirectByRole(int idRol) {
    String route;
    String roleName;

    switch (idRol) {
      case 1:
        route = '/admin/dashboard';
        roleName = 'Administrador';
        break;
      case 2:
        route = '/empleados/dashboard';
        roleName = 'Empleado';
        break;
      case 3:
        route =
            '/residente/dashboard'; // ← CORREGIDO: de '/residentes/dashboard' a '/residente/dashboard'
        roleName = 'Residente';
        break;
      default:
        route = '/login';
        roleName = 'Desconocido';
    }

    print('📍 Navegando a: $route');

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, route);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bienvenido - Rol: $roleName'),
        backgroundColor: const Color(0xFF7A8C6E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF264653),
              Color(0xFFA3C8D6),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.apartment,
                    size: 60,
                    color: Color(0xFF264653),
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Text(
                          'BIENVENIDO',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF264653),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sistema de Edificio Inteligente',
                          style: TextStyle(
                            color: Color(0xFF7A8C6E),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email_outlined),
                            hintText: 'usuario@gmail.com',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF264653),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // WIDGET CAPTCHA INTEGRADO
                        CaptchaWidget(
                          onCaptchaVerified: (captchaValue, captchaId) {
                            setState(() {
                              _captchaValue = captchaValue;
                              _captchaId = captchaId;
                            });
                          },
                          onValidityChanged: (isValid) {
                            setState(() {
                              _isCaptchaValid = isValid;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: (_isLoading || !_isCaptchaValid)
                                ? null
                                : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF264653),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'INGRESAR',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/seleccionar_registro');
                      },
                      child: const Text(
                        'Crear cuenta',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Recuperar contraseña - En desarrollo'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
