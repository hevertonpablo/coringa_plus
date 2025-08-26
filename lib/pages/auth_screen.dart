import 'package:flutter/material.dart';

import '../controller/login_controller.dart';
import '../locator.dart'; // para pegar o LoginController via getIt
import 'selfie_capture_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController controller;

  final TextEditingController loginController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  List<DropdownMenuItem<String>> perfilItems = [];
  String? selectedPerfil;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Pega a instância do controller via getIt
    controller = getIt<LoginController>();

    loginController.text = "31103074563";
    senhaController.text = "311030";

    _loadPerfis();
  }

  Future<void> _loadPerfis() async {
    setState(() {
      isLoading = true;
    });

    try {
      final perfisMap = await controller.loadPerfis();

      final items = perfisMap.entries
          .map(
            (entry) => DropdownMenuItem<String>(
              value: entry.value,
              child: Text(entry.key),
            ),
          )
          .toList();

      setState(() {
        perfilItems = items;
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar perfis: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _login() async {
    final login = loginController.text.trim();
    final senha = senhaController.text.trim();
    final database = selectedPerfil;

    if (database == null) {
      _showMessage('Selecione um perfil.');
      return;
    }

    try {
      final user = await controller.login(
        login: login,
        senha: senha,
        database: database,
      );

      _showMessage('Bem-vindo, ${user.nome}');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SelfieCaptureScreen()),
      );
    } catch (e) {
      _showMessage(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.teal),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.teal),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              children: [
                Image.asset('assets/images/3836025.jpg', height: 200),
                const SizedBox(height: 150),
                Image.asset('assets/images/logo.png', height: 60),
                const SizedBox(height: 32),
                TextFormField(
                  controller: loginController,
                  decoration: _inputDecoration('Matrícula'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: senhaController,
                  obscureText: true,
                  decoration: _inputDecoration('Senha'),
                ),
                const SizedBox(height: 16),
                isLoading
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                        decoration: _inputDecoration('Selecione o perfil'),
                        items: perfilItems,
                        value: selectedPerfil,
                        onChanged: (value) {
                          setState(() {
                            selectedPerfil = value;
                          });
                        },
                      ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _login,
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
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
