import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controller/login_controller.dart';
import '../helper/cpf_formatter.dart';
import '../locator.dart'; // para pegar o LoginController via getIt
import '../services/app_bootstrap_service.dart';
import '../services/auth_service.dart';
import 'selfie_capture_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController controller;

  final TextEditingController cpfController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController perfilController = TextEditingController();

  Map<String, String> perfisMap = {};
  String? selectedPerfilValue;
  bool isLoadingPerfis = false;

  @override
  void initState() {
    super.initState();
    controller = getIt<LoginController>();

    // Escuta mudanças no ValueNotifier de perfis
    AppBootstrapService.instance.perfisNotifier.addListener(_onPerfisLoaded);
    
    // Verifica se perfis já foram carregados
    final cachedPerfis = AppBootstrapService.instance.cachedPerfis;
    
    if (cachedPerfis != null && cachedPerfis.isNotEmpty) {
      // Perfis já estão disponíveis
      _setPerfisSync(cachedPerfis);
    } else {
      // Fallback: se após 2s ainda não carregou, faz request direto
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && perfisMap.isEmpty) {
          _loadPerfis();
        }
      });
    }

    // Carrega o último perfil selecionado
    _loadLastSelectedProfile();
  }

  void _onPerfisLoaded() {
    final perfis = AppBootstrapService.instance.perfisNotifier.value;
    if (perfis != null && perfis.isNotEmpty && mounted) {
      _setPerfisSync(perfis);
    }
  }

  void _setPerfisSync(Map<String, String> newPerfisMap) {
    setState(() {
      perfisMap = newPerfisMap;
      isLoadingPerfis = false;
      if (kDebugMode) {
        print('[LoginScreen] Perfis carregados: ${perfisMap.keys.join(", ")}');
      }
    });
  }

  Future<void> _loadPerfis() async {
    if (mounted) {
      setState(() {
        isLoadingPerfis = true;
      });
    }

    try {
      final loadedPerfisMap = await controller.loadPerfis();
      if (mounted) {
        _setPerfisSync(loadedPerfisMap);
      }
    } catch (e) {
      if (kDebugMode) {
        print('[LoginScreen] Erro ao carregar perfis: $e');
      }
      if (mounted) {
        setState(() {
          isLoadingPerfis = false;
        });
      }
    }
  }

  Future<void> _loadLastSelectedProfile() async {
    final lastProfile = await AuthService.getLastSelectedProfile();
    if (lastProfile != null && perfisMap.isNotEmpty && mounted) {
      // Encontra o nome do perfil pelo valor
      final profileName = perfisMap.entries
          .firstWhere(
            (entry) => entry.value == lastProfile,
            orElse: () => const MapEntry('', ''),
          )
          .key;
      
      if (profileName.isNotEmpty) {
        setState(() {
          perfilController.text = profileName;
          selectedPerfilValue = lastProfile;
        });
      }
    }
  }

  void _selectPerfil(String perfilName, String perfilValue) {
    setState(() {
      perfilController.text = perfilName;
      selectedPerfilValue = perfilValue;
    });
    FocusScope.of(context).unfocus(); // Fecha o teclado
    // Salva a seleção para próximas vezes
    AuthService.saveLastSelectedProfile(perfilValue);
    if (kDebugMode) {
      print('[LoginScreen] Perfil selecionado: $perfilName ($perfilValue)');
    }
  }

  @override
  void dispose() {
    AppBootstrapService.instance.perfisNotifier.removeListener(_onPerfisLoaded);
    cpfController.dispose();
    senhaController.dispose();
    perfilController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final cpf = CpfFormatter.removeFormatting(cpfController.text.trim());
    final senha = senhaController.text.trim();
    final database = selectedPerfilValue;

    if (cpf.isEmpty) {
      _showMessage('Por favor, insira seu CPF.');
      return;
    }

    if (senha.isEmpty) {
      _showMessage('Por favor, insira sua senha.');
      return;
    }

    if (database == null || database.isEmpty) {
      _showMessage('Selecione um perfil.');
      return;
    }

    try {
      final user = await controller.login(
        login: cpf,
        senha: senha,
        database: database,
      );

      _showMessage('Bem-vindo, ${user.nome}');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SelfieCaptureScreen()),
      );
    } catch (e) {
      _showMessage(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                // Campo de CPF com máscara
                TextFormField(
                  controller: cpfController,
                  inputFormatters: [CpfFormatter()],
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('CPF'),
                ),
                const SizedBox(height: 16),
                // Campo de Senha
                TextFormField(
                  controller: senhaController,
                  obscureText: true,
                  decoration: _inputDecoration('Senha'),
                ),
                const SizedBox(height: 16),
                // Campo de Perfil com Autocomplete
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty || perfisMap.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    final query = textEditingValue.text.toLowerCase();
                    return perfisMap.entries
                        .where((entry) =>
                            entry.key.toLowerCase().contains(query))
                        .map((entry) => entry.key)
                        .toList();
                  },
                  onSelected: (String selection) {
                    final perfilValue =
                        perfisMap[selection]; // Pega o valor (database ID)
                    if (perfilValue != null) {
                      _selectPerfil(selection, perfilValue);
                    }
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode,
                      onFieldSubmitted) {
                    // Sincroniza o controller do Autocomplete com o perfilController
                    perfilController.text = textEditingController.text;
                    textEditingController.addListener(() {
                      if (perfilController.text != textEditingController.text) {
                        perfilController.text = textEditingController.text;
                      }
                    });

                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: _inputDecoration('Selecione o perfil'),
                      readOnly: perfisMap.isEmpty && !isLoadingPerfis,
                      onChanged: (value) {
                        // Limpar a seleção se o usuário está editando o texto
                        if (value != perfilController.text) {
                          selectedPerfilValue = null;
                        }
                      },
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Material(
                      elevation: 4,
                      color: const Color(0xFFEFF2F7),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final optionText = options.elementAt(index);
                          return ListTile(
                            title: Text(optionText),
                            onTap: () {
                              onSelected(optionText);
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
                // Status de carregamento
                if (isLoadingPerfis)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Carregando perfis...'),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
                // Botão de Login
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
