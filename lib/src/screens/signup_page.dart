import 'package:flutter/material.dart';
import '../data/repositories/users_repository.dart';
import '../data/models/users.dart';
import 'package:bcrypt/bcrypt.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final UsersRepository _usersRepo = UsersRepository();

  void _signup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    // Criar usuário no banco
    final user = Usuario(name: name, email: email, password: hashedPassword);
    await _usersRepo.createUser(user);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conta criada com sucesso!')),
    );

    // Redirecionar para a página de login
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.task_alt, size: 80, color: Color(0xFFBA68C8)),
                const SizedBox(height: 20),
                const Text(
                  'Crie sua conta',
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
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: TextStyle(color: Colors.grey),
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
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 450,
                  child: TextField(
                    controller: _passwordController,
                    cursorColor: Colors.purple[300],
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      labelStyle: const TextStyle(color: Colors.grey),
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
                const SizedBox(height: 20),
                SizedBox(
                  width: 450,
                  child: ElevatedButton(
                    onPressed: _signup,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.purple[300],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Criar Conta'),
                  ),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: 450,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Já tem uma conta?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.withOpacity(0.4),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Faça Login"),
                      ),
                    ],
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
