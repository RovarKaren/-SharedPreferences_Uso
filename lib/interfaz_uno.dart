import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'estilos/estilo_uno.dart';

class InterfazUno extends StatefulWidget {
  final String username;
  final VoidCallback onLogout;

  const InterfazUno({
    Key? key,
    required this.username,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<InterfazUno> createState() => _InterfazUnoState();
}

class _InterfazUnoState extends State<InterfazUno> {
  Color _color = Colors.blue;
  String _font = 'Roboto';
  String _previewText = 'Este texto refleja los cambios de color y fuente.';
  Map<String, String> _users = {};

  final List<Color> colores = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.black,
    Colors.cyanAccent,
    Colors.pink
  ];

  final List<String> fuentes = [
    'Roboto',
    'Times New Roman',
    'Arial',
    'Courier New',
    'Georgia',
    'Verdana',
    'Serif',
    'Sans-serif',
    'Monospace',
  ];

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
    _cargarUsuarios();
  }

  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _color = Color(prefs.getInt('main_color') ?? Colors.blue.value);
      _font = prefs.getString('main_font') ?? 'Roboto';
      _previewText = prefs.getString('preview_text') ??
          'Este texto refleja los cambios de color y fuente.';
    });
  }

  Future<void> _guardarPreferencias(Color color, String font, String previewText) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('main_color', color.value);
    await prefs.setString('main_font', font);
    await prefs.setString('preview_text', previewText);
  }

  Future<void> _cargarUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString('users');
    setState(() {
      _users = usersJson != null
          ? Map<String, String>.from(json.decode(usersJson))
          : {};
    });
  }

  Future<void> _actualizarUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('users', json.encode(_users));
    _cargarUsuarios();
  }

  void _eliminarUsuario(String usuario) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Deseas eliminar a "$usuario"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _users.remove(usuario);
      });
      await _actualizarUsuarios();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuario "$usuario" eliminado.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarEditor(String user) {
    final txtUser = TextEditingController(text: user);
    final txtPass = TextEditingController(text: _users[user]);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: txtUser,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: txtPass,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final nu = txtUser.text.trim();
              final np = txtPass.text.trim();
              if (nu.isEmpty || np.isEmpty) return;
              setState(() {
                _users.remove(user);
                _users[nu] = np;
              });
              _actualizarUsuarios();
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: estiloUno(
        primaryColor: _color,
        fontFamily: _font,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Bienvenido, ${widget.username}'),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('logged');
                await prefs.remove('user_name');
                await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Sesión cerrada'),
                    content: const Text('Tu sesión se ha cerrado.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Aceptar'),
                      ),
                    ],
                  ),
                );
                widget.onLogout();
              },
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildSectionTitle('Selecciona un color'),
              Wrap(
                spacing: 10,
                children: colores.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _color = color;
                        _guardarPreferencias(_color, _font, _previewText);
                      });
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _color == color
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Selecciona una fuente'),
              DropdownButton<String>(
                value: _font,
                isExpanded: true,
                items: fuentes
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (f) {
                  if (f != null) {
                    setState(() {
                      _font = f;
                      _guardarPreferencias(_color, _font, _previewText);
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Vista previa'),
              Card(
                elevation: 2,
                color: _color.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _previewText,
                    style: TextStyle(fontSize: 18, fontFamily: _font),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(labelText: 'Texto de vista previa'),
                style: TextStyle(fontFamily: _font),
                onChanged: (v) {
                  setState(() => _previewText = v);
                  _guardarPreferencias(_color, _font, v);
                },
              ),
              const Divider(height: 40),
              _buildSectionTitle('Usuarios registrados'),
              ..._users.entries.map(
                    (e) => Card(
                  elevation: 1,
                  child: ListTile(
                    title: Text(e.key),
                    subtitle: const Text('••••••••'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _mostrarEditor(e.key),
                        ),
                        if (e.key != widget.username)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _eliminarUsuario(e.key),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
