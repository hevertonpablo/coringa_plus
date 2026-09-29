import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../locator.dart';
import '../model/pending_registro.dart';
import '../services/auth_service.dart';
import '../services/pending_registro_queue.dart';
import '../services/sync_manager.dart';

/// Lista os registros de ponto capturados offline (plantões com
/// `offline == true`) que ainda não foram confirmados pela API, agrupados
/// por status, com ação manual de sincronizar/tentar novamente/descartar.
class PendingRegistrosScreen extends StatefulWidget {
  const PendingRegistrosScreen({super.key});

  @override
  State<PendingRegistrosScreen> createState() =>
      _PendingRegistrosScreenState();
}

class _PendingRegistrosScreenState extends State<PendingRegistrosScreen> {
  final _queue = getIt<PendingRegistroQueue>();
  List<PendingRegistro> _registros = [];
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _isLoading = true);
    final user = await AuthService.getUser();
    if (!mounted) return;
    setState(() {
      _registros = user == null
          ? []
          : (_queue.pendingFor(database: user.database, userId: user.id)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
      _isLoading = false;
    });
  }

  Future<void> _sincronizarAgora() async {
    setState(() => _isSyncing = true);
    try {
      await SyncManager.shared.syncPendingRegistros();
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
        await _carregar();
      }
    }
  }

  Future<void> _tentarNovamente(PendingRegistro registro) async {
    await _queue.save(
      registro.copyWith(status: 'pending', attempts: 0, clearError: true),
    );
    await _sincronizarAgora();
  }

  Future<void> _descartar(PendingRegistro registro) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar registro?'),
        content: const Text(
          'Este registro de ponto não será enviado. Essa ação não pode ser '
          'desfeita e pode ter impacto no seu controle de ponto.',
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

    if (confirmar != true) return;
    await _queue.remove(registro.id);
    await _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros pendentes'),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            tooltip: 'Sincronizar agora',
            onPressed: _isSyncing ? null : _sincronizarAgora,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _registros.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _carregar,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _registros.length,
                    itemBuilder: (context, index) =>
                        _buildItem(_registros[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_done, size: 56, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhum registro pendente',
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(PendingRegistro registro) {
    final (texto, cor) = _statusVisual(registro.status);
    final tipoTexto = registro.tipo == 'E' ? 'Entrada' : 'Saída';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$tipoTexto — Plantão #${registro.plantaoId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: cor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    texto,
                    style: TextStyle(
                      color: cor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(registro.dataHora),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            if (registro.status == 'failed' &&
                registro.lastErrorMessage != null) ...[
              const SizedBox(height: 6),
              Text(
                registro.lastErrorMessage!,
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
            if (registro.status == 'failed') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _tentarNovamente(registro),
                    child: const Text('Tentar novamente'),
                  ),
                  TextButton(
                    onPressed: () => _descartar(registro),
                    child: const Text(
                      'Descartar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  (String, Color) _statusVisual(String status) {
    switch (status) {
      case 'synced':
        return ('Sincronizado', const Color(0xFF2E7D32));
      case 'syncing':
        return ('Sincronizando', const Color(0xFF1565C0));
      case 'failed':
        return ('Falhou', const Color(0xFFC62828));
      case 'pending':
      default:
        return ('Pendente', const Color(0xFFEF6C00));
    }
  }
}
