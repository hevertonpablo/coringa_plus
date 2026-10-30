import 'package:flutter/material.dart';

import '../model/local_profile.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';
import 'meus_plantoes_screen.dart';

/// Lista os perfis (base + usuário) já preparados neste aparelho —
/// "Disponíveis offline" — e permite trocar entre eles sem internet, ou
/// entrar em uma base nova/reconectar uma base travada (exige internet).
class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() =>
      _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  List<LocalProfile> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _isLoading = true);
    final profiles = await AuthService.listPreparedProfiles();
    if (!mounted) return;
    setState(() {
      _profiles = profiles;
      _isLoading = false;
    });
  }

  Future<void> _abrirPerfil(LocalProfile profile) async {
    final status = profile.effectiveStatus(DateTime.now());

    if (status != 'active') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            prefillCpf: profile.cpf,
            prefillDatabase: profile.database,
            prefillBaseDisplayName: profile.baseDisplayName,
          ),
        ),
      );
      if (mounted) _carregar();
      return;
    }

    await AuthService.activateProfile(
      database: profile.database,
      userId: profile.userId,
    );
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MeusPlantoesScreen()),
      (route) => false,
    );
  }

  Future<void> _entrarEmOutraBase() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    if (mounted) _carregar();
  }

  Future<void> _gerenciarPerfil(LocalProfile profile) async {
    final acao = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Remover perfil deste aparelho'),
              onTap: () => Navigator.pop(context, 'remover'),
            ),
          ],
        ),
      ),
    );

    if (acao == 'remover') await _removerPerfil(profile);
  }

  Future<void> _removerPerfil(LocalProfile profile) async {
    final resultado = await AuthService.removeProfile(
      database: profile.database,
      userId: profile.userId,
    );

    if (!resultado.blocked) {
      if (mounted) _carregar();
      return;
    }

    if (!mounted) return;
    final decisao = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remoção bloqueada'),
        content: Text(
          'Este perfil tem ${resultado.pendingCount} registro(s) de ponto '
          'ainda não sincronizado(s). Conecte-se à internet para sincronizar, '
          'ou descarte-os permanentemente para poder remover o perfil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'descartar'),
            child: const Text(
              'Descartar e remover',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (decisao != 'descartar') return;

    if (!mounted) return;
    final confirmarDescarte = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar registros pendentes?'),
        content: Text(
          'Isso vai descartar permanentemente ${resultado.pendingCount} '
          'registro(s) de ponto não sincronizado(s). Essa ação não pode ser '
          'desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Descartar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmarDescarte != true) return;

    await AuthService.discardPendingFor(
      database: profile.database,
      userId: profile.userId,
    );
    await AuthService.removeProfile(
      database: profile.database,
      userId: profile.userId,
    );
    if (mounted) _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8FB),
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('Disponíveis offline'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ..._profiles.map(_buildCard),
                if (_profiles.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'Nenhuma base preparada neste aparelho ainda.',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _entrarEmOutraBase,
                  icon: const Icon(Icons.add),
                  label: const Text('Entrar em outra base'),
                ),
              ],
            ),
    );
  }

  Widget _buildCard(LocalProfile profile) {
    final status = profile.effectiveStatus(DateTime.now());
    final ativo = status == 'active';
    final subtitulo = switch (status) {
      'locked_stale' => 'Reconecte para continuar',
      'revoked' => 'Acesso revogado — fale com o suporte',
      _ => profile.baseDisplayName,
    };
    final corSubtitulo = ativo ? Colors.black54 : const Color(0xFFC62828);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: ativo
              ? const Color(0xFFE8F4F4)
              : const Color(0xFFFFEBEE),
          child: Icon(
            Icons.person,
            color: ativo ? const Color(0xFF00897B) : const Color(0xFFC62828),
          ),
        ),
        title: Text(profile.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitulo, style: TextStyle(color: corSubtitulo)),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _gerenciarPerfil(profile),
        ),
        onTap: () => _abrirPerfil(profile),
      ),
    );
  }
}
