import 'package:flutter/material.dart';
import 'package:bcrypt/bcrypt.dart';
import '../data/models/users.dart';
import '../data/repositories/users_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  late Usuario _user;
  final UsersRepository _usersRepo = UsersRepository();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _user = ModalRoute.of(context)!.settings.arguments as Usuario;

    _nameController.text = _user.name;
    _emailController.text = _user.email;
  }

  Future<void> _updateProfile() async {
    String newName = _nameController.text.trim();
    String newEmail = _emailController.text.trim();
    String newPassword = _passwordController.text.trim();

    if (newName.isEmpty || newEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nome e email não podem ficar vazios")),
      );
      return;
    }

    String hashedPassword = _user.password;

    if (newPassword.isNotEmpty) {
      hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
    }

    Usuario updatedUser = Usuario(
      id: _user.id,
      name: newName,
      email: newEmail,
      password: hashedPassword,
    );

    await _usersRepo.updateUser(updatedUser);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso!')),
    );

    Navigator.pushReplacementNamed(context, '/home', arguments: updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      appBar: AppBar(
        title: const Text("Editar Perfil"),
        backgroundColor: Colors.purple[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.person, size: 80, color: Color(0xFFBA68C8)),
                const SizedBox(height: 20),
                const Text(
                  'Atualizar Dados',
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: 450,
                  child: TextField(
                    controller: _nameController,
                    cursorColor: Colors.purple[300],
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: 450,
                  child: TextField(
                    controller: _emailController,
                    cursorColor: Colors.purple[300],
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: 450,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    cursorColor: Colors.purple[300],
                    decoration: InputDecoration(
                      labelText: 'Nova senha (opcional)',
                      labelStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 25),

                SizedBox(
                  width: 450,
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.purple[300],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Salvar Alterações"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
