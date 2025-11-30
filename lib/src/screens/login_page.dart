import 'package:flutter/material.dart';
import '../data/repositories/users_repository.dart';
import 'package:bcrypt/bcrypt.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    final repo = UsersRepository();
    final user = await repo.getUserByEmail(email);

    if (user != null && BCrypt.checkpw(password, user.password)) {
      // Login válido, redireciona para home
      Navigator.pushReplacementNamed(context, '/home', arguments: user);
    } else {
      // Usuário ou senha incorretos
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail ou senha inválidos')),
      );
    }
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
                  'Bem vindo ao To-Do-App !',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                SizedBox(
                    width: 450,
                    child: TextField(
                        controller: _emailController,
                        cursorColor: Colors.purple[300],
                        decoration: const InputDecoration(
                            labelText: 'E-mail',
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                            ),
                            labelStyle: const TextStyle(
                                color: Colors.grey,
                            ),
                        ),
                        style: TextStyle(color: Colors.white)
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
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.purple[300],
                            foregroundColor: Colors.white,
                        ),
                        child: const Text('Entrar'),
                    ),
                ),
                const SizedBox(height: 50),
                SizedBox(
                    width: 450,
                    child: const Divider(
                        color: Colors.grey,
                        thickness: 1, 
                    ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                    width: 450,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            const Text(
                                'Não tem uma conta?',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                ),
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/signup');
                                },
                                    style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.withOpacity(0.4),
                                    foregroundColor: Colors.white,
                                ),
                                child: const Text("Comece Por Aqui"),
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
