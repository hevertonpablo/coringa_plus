import 'package:flutter/material.dart';

import '../controller/plantao_controller.dart';
import '../helper/utils.dart';
import '../model/plantao_model.dart';

class PlantoesPage extends StatefulWidget {
  const PlantoesPage({super.key});

  @override
  State<PlantoesPage> createState() => _PlantoesPageState();
}

class _PlantoesPageState extends State<PlantoesPage> {
  final PlantaoController _controller = PlantaoController();
  late Future<List<Plantao>> _futurePlantoes;

  @override
  void initState() {
    super.initState();
    _futurePlantoes = _controller.listarPlantoes();
    _inicializarController();
  }

  Future<void> _inicializarController() async {
    await _controller.inicializar();
    if (!mounted) return;
    setState(() {}); // Atualiza a UI após carregar plantões
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xF5F8FBFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: FutureBuilder<List<Plantao>>(
            future: _futurePlantoes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar plantões: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final plantoes = snapshot.data ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Plantões",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text("Dr. Malafaia", style: TextStyle(fontSize: 16)),
                  const Text(
                    "099337365335",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),

                  // Lista dinâmica de plantões
                  Expanded(
                    child: ListView.separated(
                      itemCount: plantoes.length,
                      separatorBuilder: (_, __) =>
                          const Divider(thickness: 1, color: Colors.black12),
                      itemBuilder: (context, index) {
                        final plantao = plantoes[index];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatarHorarioCompleto(
                                plantao.dtEntrada,
                                plantao.dtSaida,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              plantao.unidade,
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              plantao.unidadeEndereco,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
