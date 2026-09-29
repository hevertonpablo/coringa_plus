import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controller/plantao_controller.dart';
import '../locator.dart';
import '../model/plantao_model.dart';
import '../services/auth_service.dart';
import '../services/connectivity_service.dart';
import '../services/pending_registro_queue.dart';
import '../services/sync_manager.dart';
import 'auth_screen.dart';
import 'pending_registros_screen.dart';
import 'selfie_capture_screen.dart';

class MeusPlantoesScreen extends StatefulWidget {
  const MeusPlantoesScreen({super.key});

  @override
  State<MeusPlantoesScreen> createState() => _MeusPlantoesScreenState();
}

class _MeusPlantoesScreenState extends State<MeusPlantoesScreen>
    with WidgetsBindingObserver {
  late final PlantaoController _plantaoController;
  List<Plantao> _plantoes = [];
  List<Plantao> _historico = [];
  bool _isLoading = true;
  bool _isLoadingHistorico = false;
  bool _historicoCarregado = false;
  String _nomeUsuarioLogado = '';
  String _abaSelecionada = 'hoje'; // hoje, proximos, historico
  bool _dadosDesatualizados = false;
  DateTime? _dadosAtualizadosEm;
  int _pendentesCount = 0;
  StreamSubscription<bool>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _plantaoController = PlantaoController();
    _loadUsuarioLogado();
    _carregarPlantoes();
    _atualizarContagemPendentes();
    _dispararSincronizacao();
    _connectivitySubscription = getIt<ConnectivityService>()
        .onConnectivityChanged
        .listen((online) {
      if (online) _dispararSincronizacao();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _dispararSincronizacao();
    }
  }

  Future<void> _dispararSincronizacao() async {
    await SyncManager.shared.syncPendingRegistros();
    await _atualizarContagemPendentes();
  }

  Future<void> _atualizarContagemPendentes() async {
    final user = await AuthService.getUser();
    if (!mounted || user == null) return;
    final count = getIt<PendingRegistroQueue>().countPending(
      database: user.database,
      userId: user.id,
    );
    setState(() {
      _pendentesCount = count;
    });
  }

  Future<void> _loadUsuarioLogado() async {
    final user = await AuthService.getUser();
    if (!mounted || user == null) return;
    setState(() {
      _nomeUsuarioLogado = user.nome;
    });
  }

  Future<void> _carregarPlantoes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final plantoes = await _plantaoController.listarPlantoes()
        ..sort((a, b) => a.dtEntrada.compareTo(b.dtEntrada));
      if (!mounted) return;
      setState(() {
        _plantoes = plantoes;
        _isLoading = false;
        _dadosDesatualizados = _plantaoController.isUltimaListaDoCache;
        _dadosAtualizadosEm = _plantaoController.ultimaListaCacheadaEm;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar plantões: $e')),
      );
    }
  }

  Future<void> _carregarHistorico() async {
    setState(() {
      _isLoadingHistorico = true;
    });

    try {
      final historico = await _plantaoController.listarHistoricoPlantoes()
        ..sort((a, b) => b.dtEntrada.compareTo(a.dtEntrada));
      if (!mounted) return;
      setState(() {
        _historico = historico;
        _historicoCarregado = true;
        _isLoadingHistorico = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingHistorico = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar histórico: $e')),
      );
    }
  }

  void _selecionarAba(String aba) {
    setState(() => _abaSelecionada = aba);
    if (aba == 'historico' && !_historicoCarregado) {
      _carregarHistorico();
    }
  }

  Future<void> _refresh() async {
    await Future.wait([
      _carregarPlantoes(),
      if (_abaSelecionada == 'historico') _carregarHistorico(),
    ]);
  }

  Future<void> _handleLogout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente fazer logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _abrirRegistro(Plantao plantao) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SelfieCaptureScreen(plantaoSelecionado: plantao),
      ),
    );
    if (!mounted) return;
    _carregarPlantoes();
    _atualizarContagemPendentes();
  }

  bool _isRealizado(Plantao p) =>
      p.dtEntradaPonto != null && p.dtSaidaPonto != null;

  bool _isNaoRealizado(Plantao p) {
    return p.dtEntradaPonto == null && p.dtSaida.isBefore(DateTime.now());
  }

  /// Já passou do horário de entrada, ainda dentro do plantão, mas o
  /// profissional ainda não registrou entrada.
  bool _isNaoIniciado(Plantao p) {
    final agora = DateTime.now();
    return p.dtEntradaPonto == null &&
        p.dtEntrada.isBefore(agora) &&
        p.dtSaida.isAfter(agora);
  }

  /// Plantão aberto cujo horário previsto de saída já passou, mas a saída
  /// ainda não foi registrada.
  bool _isAtrasadoParaEncerrar(Plantao p) {
    return PlantaoController.isPlantaoAberto(p) &&
        p.dtSaida.isBefore(DateTime.now());
  }

  ({String texto, Color bg, Color texto2}) _statusVisual(Plantao p) {
    if (_isRealizado(p)) {
      return (
        texto: 'Realizado',
        bg: const Color(0xFFE8F5E9),
        texto2: const Color(0xFF2E7D32),
      );
    } else if (PlantaoController.isPlantaoAberto(p)) {
      return (
        texto: 'Em andamento',
        bg: const Color(0xFFE3F2FD),
        texto2: const Color(0xFF1565C0),
      );
    } else if (_isNaoRealizado(p)) {
      return (
        texto: 'Não realizado',
        bg: const Color(0xFFFFEBEE),
        texto2: const Color(0xFFC62828),
      );
    } else if (_isNaoIniciado(p)) {
      return (
        texto: 'Não iniciado',
        bg: const Color(0xFFFFEBEE),
        texto2: const Color(0xFFC62828),
      );
    } else {
      return (
        texto: 'Futuro',
        bg: const Color(0xFFFFF3E0),
        texto2: const Color(0xFFEF6C00),
      );
    }
  }

  Plantao? get _plantaoEmAndamento {
    final abertos = _plantoes.where(PlantaoController.isPlantaoAberto).toList()
      ..sort((a, b) => b.dtEntrada.compareTo(a.dtEntrada));
    return abertos.isEmpty ? null : abertos.first;
  }

  /// Plantão pendente cujo horário de entrada já passou (mais urgente que
  /// um plantão futuro, por isso tem prioridade no card de destaque).
  Plantao? get _plantaoNaoIniciado {
    final atrasados = _plantoes.where(_isNaoIniciado).toList()
      ..sort((a, b) => a.dtEntrada.compareTo(b.dtEntrada));
    return atrasados.isEmpty ? null : atrasados.first;
  }

  Plantao? get _proximoPlantao {
    final agora = DateTime.now();
    final pendentesFuturos = _plantoes
        .where(PlantaoController.isPlantaoPendente)
        .where((p) => p.dtEntrada.isAfter(agora))
        .toList()
      ..sort((a, b) => a.dtEntrada.compareTo(b.dtEntrada));
    return pendentesFuturos.isEmpty ? null : pendentesFuturos.first;
  }

  List<Plantao> _plantoesDaAba(String aba) {
    final agora = DateTime.now();

    switch (aba) {
      case 'proximos':
        return _plantoes
            .where(PlantaoController.isPlantaoPendente)
            .where((p) => p.dtEntrada.isAfter(agora))
            .toList();
      case 'historico':
        return _historico;
      case 'hoje':
      default:
        final hoje = DateTime(agora.year, agora.month, agora.day);
        final amanha = hoje.add(const Duration(days: 1));
        return _plantoes.where((p) {
          final entradaHoje =
              !p.dtEntrada.isBefore(hoje) && p.dtEntrada.isBefore(amanha);
          return entradaHoje && p.dtEntradaPonto == null;
        }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final plantoesDaAba = _plantoesDaAba(_abaSelecionada);
    final emAndamento = _plantaoEmAndamento;
    final atrasadoParaEncerrar =
        emAndamento != null && _isAtrasadoParaEncerrar(emAndamento);
    final naoIniciado = _plantaoNaoIniciado;
    final destaqueSecundario = naoIniciado ?? _proximoPlantao;
    final isAtrasado = naoIniciado != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF5F8FB),
        foregroundColor: Colors.black87,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_nomeUsuarioLogado.isNotEmpty)
              Text(
                'Olá, ${_nomeUsuarioLogado.split(' ').first}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const Text(
              'Meus Plantões',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('$_pendentesCount'),
              isLabelVisible: _pendentesCount > 0,
              child: const Icon(Icons.cloud_upload_outlined),
            ),
            tooltip: 'Registros pendentes de sincronização',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PendingRegistrosScreen(),
                ),
              );
              if (!mounted) return;
              _atualizarContagemPendentes();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: _refresh,
          ),
          IconButton(
            icon: const CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFFE8F4F4),
              child: Icon(Icons.person, color: Color(0xFF00897B), size: 18),
            ),
            tooltip: 'Sair',
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  if (_dadosDesatualizados) _buildBannerDesatualizado(),
                  if (emAndamento != null)
                    _buildDestaqueCard(
                      plantao: emAndamento,
                      rotulo: 'Plantão em andamento',
                      rotuloIcone: Icons.circle,
                      rotuloCor: atrasadoParaEncerrar
                          ? const Color(0xFFFF8F00)
                          : Colors.blue,
                      mostrarBadge: false,
                      mostrarChevron: false,
                      detalheCompleto: true,
                      botaoTexto: 'Encerrar plantão',
                      botaoCor: atrasadoParaEncerrar
                          ? const Color(0xFFFF8F00)
                          : Colors.blue,
                    ),
                  if (destaqueSecundario != null)
                    _buildDestaqueCard(
                      plantao: destaqueSecundario,
                      rotulo: isAtrasado
                          ? 'Plantão não iniciado'
                          : 'Próximo plantão',
                      rotuloIcone: Icons.circle,
                      rotuloCor:
                          isAtrasado ? const Color(0xFFC62828) : Colors.teal,
                      mostrarBadge: false,
                      mostrarChevron: true,
                      detalheCompleto: false,
                      botaoTexto: 'Iniciar plantão',
                      botaoCor:
                          isAtrasado ? const Color(0xFFC62828) : Colors.teal,
                    ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildAbas(),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _tituloAba(_abaSelecionada),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_abaSelecionada == 'historico' && _isLoadingHistorico)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (plantoesDaAba.isEmpty)
                    _buildEmptyState()
                  else
                    ...plantoesDaAba.map((p) => _buildPlantaoCard(p)),
                ],
              ),
            ),
    );
  }

  Widget _buildBannerDesatualizado() {
    final atualizadoEm = _dadosAtualizadosEm;
    final horario = atualizadoEm != null
        ? DateFormat('dd/MM HH:mm').format(atualizadoEm)
        : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 18, color: Color(0xFFEF6C00)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              horario != null
                  ? 'Sem conexão — mostrando dados de $horario'
                  : 'Sem conexão — mostrando os últimos dados salvos',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFEF6C00),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbas() {
    final abas = const [
      ('hoje', 'Hoje'),
      ('proximos', 'Próximos'),
      ('historico', 'Histórico'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: abas.map((aba) {
          final selecionada = _abaSelecionada == aba.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => _selecionarAba(aba.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selecionada ? Colors.teal : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  aba.$2,
                  style: TextStyle(
                    color: selecionada ? Colors.white : Colors.black54,
                    fontWeight:
                        selecionada ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _tituloAba(String aba) {
    switch (aba) {
      case 'proximos':
        return 'Próximos plantões';
      case 'historico':
        return 'Histórico';
      case 'hoje':
      default:
        return 'Hoje, ${DateFormat('dd/MM').format(DateTime.now())}';
    }
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.calendar_today, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhum plantão encontrado',
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestaqueCard({
    required Plantao plantao,
    required String rotulo,
    required IconData rotuloIcone,
    required Color rotuloCor,
    required bool mostrarBadge,
    required bool mostrarChevron,
    required bool detalheCompleto,
    required String botaoTexto,
    required Color botaoCor,
  }) {
    final status = _statusVisual(plantao);

    final botaoIcone =
        botaoTexto.startsWith('Iniciar') ? Icons.play_arrow : Icons.stop;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _abrirRegistro(plantao),
        child: Container(
          padding: EdgeInsets.all(detalheCompleto ? 16 : 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border(left: BorderSide(color: rotuloCor, width: 4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      rotuloIcone == Icons.circle
                          ? _buildBolinhaPulsante(rotuloCor)
                          : Icon(rotuloIcone, size: 14, color: rotuloCor),
                      const SizedBox(width: 6),
                      Text(
                        rotulo,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: rotuloCor,
                        ),
                      ),
                    ],
                  ),
                  if (mostrarBadge)
                    _buildStatusBadge(status)
                  else if (mostrarChevron)
                    const Icon(Icons.chevron_right, color: Colors.black38),
                ],
              ),
              SizedBox(height: detalheCompleto ? 10 : 8),
              if (detalheCompleto) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.local_hospital,
                      size: 15,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      plantao.unidade,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildInfoPlantao(plantao),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _abrirRegistro(plantao),
                    icon: Icon(botaoIcone, size: 18),
                    label: Text(botaoTexto),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: botaoCor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoLinha(
                            Icons.calendar_today,
                            _formatarDataHora(plantao, usarHoje: true),
                            cor: Colors.black87,
                            negrito: true,
                            tamanhoIcone: 18,
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: Text(
                              '${plantao.unidade} • '
                              '${_capitalizarPalavras(plantao.especialidade)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _abrirRegistro(plantao),
                      icon: Icon(botaoIcone, size: 16),
                      label: Text(
                        botaoTexto,
                        style: const TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: botaoCor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlantaoCard(Plantao plantao) {
    final status = _statusVisual(plantao);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _abrirRegistro(plantao),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F4F4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.monitor_heart,
                  color: Color(0xFF00897B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            plantao.unidade,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildStatusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildInfoPlantao(plantao),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }

  /// Bolinha com halo (efeito "pulso") usada nos rótulos de destaque.
  Widget _buildBolinhaPulsante(Color cor) {
    return SizedBox(
      width: 16,
      height: 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cor.withValues(alpha: 0.15),
            ),
          ),
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cor.withValues(alpha: 0.3),
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: cor),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(({String texto, Color bg, Color texto2}) status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.texto,
        style: TextStyle(
          color: status.texto2,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Formata data e horário do plantão; usa "Hoje" no lugar da data
  /// quando a entrada cai no dia atual (usado nos cards condensados).
  String _formatarDataHora(Plantao plantao, {bool usarHoje = false}) {
    final agora = DateTime.now();
    final mesmoDia = usarHoje &&
        plantao.dtEntrada.year == agora.year &&
        plantao.dtEntrada.month == agora.month &&
        plantao.dtEntrada.day == agora.day;
    final dataTexto = mesmoDia
        ? 'Hoje'
        : DateFormat('dd/MM/yyyy').format(plantao.dtEntrada);
    return '$dataTexto • '
        '${DateFormat('HH:mm').format(plantao.dtEntrada)} às '
        '${DateFormat('HH:mm').format(plantao.dtSaida)}';
  }

  String _capitalizarPalavras(String texto) {
    return texto.trim().toLowerCase().split(' ').map((palavra) {
      if (palavra.isEmpty) return palavra;
      return palavra[0].toUpperCase() + palavra.substring(1);
    }).join(' ');
  }

  Widget _buildInfoPlantao(Plantao plantao) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoLinha(Icons.calendar_today, _formatarDataHora(plantao)),
        const SizedBox(height: 4),
        _infoLinha(
          Icons.business_center,
          _capitalizarPalavras(plantao.especialidade),
        ),
        const SizedBox(height: 4),
        _infoLinha(Icons.work_outline, 'Setor: ${plantao.setor}'),
        if (plantao.dtEntradaPonto != null ||
            plantao.dtSaidaPonto != null) ...[
          const SizedBox(height: 6),
          if (plantao.dtEntradaPonto != null)
            _infoLinha(
              Icons.access_time,
              'Entrada registrada: '
              '${DateFormat('dd/MM/yyyy HH:mm').format(plantao.dtEntradaPonto!)}',
              cor: const Color(0xFF2E7D32),
              negrito: true,
            ),
          if (plantao.dtSaidaPonto != null)
            _infoLinha(
              Icons.access_time,
              'Saída registrada: '
              '${DateFormat('dd/MM/yyyy HH:mm').format(plantao.dtSaidaPonto!)}',
              cor: const Color(0xFF2E7D32),
              negrito: true,
            ),
        ],
      ],
    );
  }

  Widget _infoLinha(
    IconData icone,
    String texto, {
    Color cor = Colors.black54,
    bool negrito = false,
    double tamanhoIcone = 13,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, size: tamanhoIcone, color: cor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 13,
              color: cor,
              fontWeight: negrito ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
