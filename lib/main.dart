import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'estilos/estilo_login.dart';
import 'interfaz_uno.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _logged = false;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('logged') ?? false;
    String? name = prefs.getString('user_name');

    // Asegurar que el usuario admin existe
    String? usersJson = prefs.getString('users');
    Map<String, String> users = {};

    if (usersJson != null) {
      users = Map<String, String>.from(json.decode(usersJson));
    }

    if (!users.containsKey('admin')) {
      users['admin'] = '123';
      await prefs.setString('users', json.encode(users));
    }

    setState(() {
      _logged = loggedIn;
      _username = name;
    });
  }

  Future<void> _attemptLogin(
      String username, String password, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString('users');
    Map<String, String> users = {};

    if (usersJson != null) {
      users = Map<String, String>.from(json.decode(usersJson));
    }

    if (!users.containsKey(username)) {
      _showSnackBar(context, 'Usuario no registrado');
      return;
    }

    if (users[username] != password) {
      _showSnackBar(context, 'Contraseña incorrecta');
      return;
    }

    await prefs.setBool('logged', true);
    await prefs.setString('user_name', username);
    setState(() {
      _logged = true;
      _username = username;
    });

    _showSnackBar(context, 'Inicio de sesión exitoso', isError: false);
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged');
    await prefs.remove('user_name');
    setState(() {
      _logged = false;
      _username = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Login',
      debugShowCheckedModeBanner: false,
      theme: estiloLogin(),
      home: _logged
          ? InterfazUno(
        username: _username ?? 'Usuario',
        onLogout: _logout,
      )
          : LoginPage(onLogin: _attemptLogin),
    );
  }
}

class LoginPage extends StatefulWidget {
  final Function(String, String, BuildContext) onLogin;

  const LoginPage({Key? key, required this.onLogin}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Usuario'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final username = _usernameController.text.trim();
                  final password = _passwordController.text;

                  if (username.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, completa todos los campos'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  widget.onLogin(username, password, context);
                },
                child: const Text('Ingresar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterPage()),
                  );
                },
                child: const Text('¿No tienes cuenta? Regístrate aquí'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString('users');
    Map<String, String> users = {};

    if (usersJson != null) {
      users = Map<String, String>.from(json.decode(usersJson));
    }

    if (users.containsKey(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El usuario ya existe'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    users[username] = password;
    await prefs.setString('users', json.encode(users));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registro exitoso. Ahora puedes iniciar sesión.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
