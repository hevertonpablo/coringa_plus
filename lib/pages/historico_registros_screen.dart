import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controller/plantao_controller.dart';
import '../model/plantao_model.dart';

class HistoricoRegistrosScreen extends StatefulWidget {
  const HistoricoRegistrosScreen({super.key});

  @override
  State<HistoricoRegistrosScreen> createState() => _HistoricoRegistrosScreenState();
}

class _HistoricoRegistrosScreenState extends State<HistoricoRegistrosScreen> {
  late final PlantaoController _plantaoController;
  List<Plantao> _plantoes = [];
  bool _isLoading = true;
  String _filtroStatus = 'todos'; // todos, realizados, nao_realizados, futuros

  @override
  void initState() {
    super.initState();
    _plantaoController = PlantaoController();
    _carregarPlantoes();
  }

  Future<void> _carregarPlantoes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final plantoes = await _plantaoController.listarPlantoes();
      setState(() {
        _plantoes = plantoes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar plantões: $e')),
      );
    }
  }

  List<Plantao> _filtrarPlantoes() {
    final agora = DateTime.now();
    
    switch (_filtroStatus) {
      case 'realizados':
        return _plantoes.where((p) => 
          p.dtEntradaPonto != null && p.dtSaidaPonto != null
        ).toList();
      case 'nao_realizados':
        return _plantoes.where((p) => 
          p.dtSaida.isBefore(agora) && 
          (p.dtEntradaPonto == null || p.dtSaidaPonto == null)
        ).toList();
      case 'futuros':
        return _plantoes.where((p) => 
          p.dtEntrada.isAfter(agora)
        ).toList();
      default:
        return _plantoes;
    }
  }

  Color _getStatusColor(Plantao plantao) {
    final agora = DateTime.now();
    
    if (plantao.dtEntradaPonto != null && plantao.dtSaidaPonto != null) {
      return Colors.green; // Realizado
    } else if (plantao.dtSaida.isBefore(agora)) {
      return Colors.red; // Não realizado
    } else {
      return Colors.orange; // Futuro
    }
  }

  String _getStatusText(Plantao plantao) {
    final agora = DateTime.now();
    
    if (plantao.dtEntradaPonto != null && plantao.dtSaidaPonto != null) {
      return 'Realizado';
    } else if (plantao.dtSaida.isBefore(agora)) {
      return 'Não Realizado';
    } else {
      return 'Futuro';
    }
  }

  Widget _buildPlantaoCard(Plantao plantao) {
    final statusColor = _getStatusColor(plantao);
    final statusText = _getStatusText(plantao);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Data: ${DateFormat('dd/MM/yyyy').format(plantao.dtEntrada)}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Horário: ${DateFormat('HH:mm').format(plantao.dtEntrada)} - ${DateFormat('HH:mm').format(plantao.dtSaida)}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Especialidade: ${plantao.especialidade}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Setor: ${plantao.setor}',
              style: const TextStyle(fontSize: 14),
            ),
            if (plantao.dtEntradaPonto != null || plantao.dtSaidaPonto != null) ...[
              const SizedBox(height: 8),
              const Divider(),
              const Text(
                'Registros de Ponto:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (plantao.dtEntradaPonto != null)
                Text(
                  'Entrada: ${DateFormat('dd/MM/yyyy HH:mm').format(plantao.dtEntradaPonto!)}',
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              if (plantao.dtSaidaPonto != null)
                Text(
                  'Saída: ${DateFormat('dd/MM/yyyy HH:mm').format(plantao.dtSaidaPonto!)}',
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plantoesFiltrados = _filtrarPlantoes();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      appBar: AppBar(
        title: const Text('Histórico de Plantões'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarPlantoes,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todos', 'todos'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Realizados', 'realizados'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Não Realizados', 'nao_realizados'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Futuros', 'futuros'),
                ],
              ),
            ),
          ),
          // Lista de plantões
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : plantoesFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum plantão encontrado',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _carregarPlantoes,
                        child: ListView.builder(
                          itemCount: plantoesFiltrados.length,
                          itemBuilder: (context, index) {
                            return _buildPlantaoCard(plantoesFiltrados[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filtroStatus == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filtroStatus = value;
        });
      },
      selectedColor: Colors.teal.withOpacity(0.3),
      checkmarkColor: Colors.teal,
    );
  }
}
