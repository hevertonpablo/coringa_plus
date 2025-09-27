import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../controller/location_validator_controller.dart';
import '../controller/plantao_controller.dart';

class LocationDebugScreen extends StatefulWidget {
  const LocationDebugScreen({super.key});

  @override
  State<LocationDebugScreen> createState() => _LocationDebugScreenState();
}

class _LocationDebugScreenState extends State<LocationDebugScreen> {
  String _debugInfo = 'Iniciando debug...';
  PlantaoController? _plantaoController;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initializeDebug();
  }

  Future<void> _initializeDebug() async {
    try {
      setState(() {
        _debugInfo = 'Inicializando controller...';
      });

      _plantaoController = PlantaoController();
      await _plantaoController!.inicializar();

      await _debugLocationValidation();
    } catch (e) {
      setState(() {
        _debugInfo = 'Erro durante inicialização: $e';
      });
    }
  }

  Future<void> _debugLocationValidation() async {
    final plantao = _plantaoController!.plantaoAtual;

    if (plantao == null) {
      setState(() {
        _debugInfo += '\n❌ Nenhum plantão encontrado!';
      });
      return;
    }

    setState(() {
      _debugInfo += '\n✅ Plantão encontrado:';
      _debugInfo += '\n  ID: ${plantao.plantaoId}';
      _debugInfo += '\n  Unidade: ${plantao.unidade}';
      _debugInfo += '\n  Latitude: ${plantao.unidadeLatitude}';
      _debugInfo += '\n  Longitude: ${plantao.unidadeLongitude}';
      _debugInfo += '\n  Raio: ${plantao.unidadeRaio}m';
      _debugInfo += '\n  Endereço: ${plantao.unidadeEndereco}';
    });

    // Testar permissões
    setState(() {
      _debugInfo += '\n\n🔍 Verificando permissões GPS...';
    });

    LocationPermission permission = await Geolocator.checkPermission();
    setState(() {
      _debugInfo += '\n  Status: $permission';
    });

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      setState(() {
        _debugInfo += '\n  Nova permissão: $permission';
      });
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _debugInfo += '\n❌ Permissões negadas permanentemente!';
      });
      return;
    }

    // Obter localização atual
    setState(() {
      _debugInfo += '\n\n📍 Obtendo localização atual...';
    });

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _debugInfo += '\n✅ Localização obtida:';
        _debugInfo += '\n  Latitude: ${_currentPosition!.latitude}';
        _debugInfo += '\n  Longitude: ${_currentPosition!.longitude}';
        _debugInfo += '\n  Precisão: ${_currentPosition!.accuracy}m';
      });

      // Calcular distância
      final double unidadeLatitude = double.parse(plantao.unidadeLatitude);
      final double unidadeLongitude = double.parse(plantao.unidadeLongitude);
      final double raio = plantao.unidadeRaio.toDouble();

      final double distancia = Geolocator.distanceBetween(
        unidadeLatitude,
        unidadeLongitude,
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      setState(() {
        _debugInfo += '\n\n📏 Cálculo de distância:';
        _debugInfo += '\n  Distância: ${distancia.toStringAsFixed(2)}m';
        _debugInfo += '\n  Raio permitido: ${raio}m';
        _debugInfo +=
            '\n  Dentro do raio: ${distancia <= raio ? "✅ SIM" : "❌ NÃO"}';
      });

      // Testar com LocationValidatorController
      setState(() {
        _debugInfo += '\n\n🧪 Testando LocationValidatorController...';
      });

      final validador = LocationValidatorController(
        unidadeLatitude: unidadeLatitude,
        unidadeLongitude: unidadeLongitude,
        raioPermitidoEmMetros: raio,
      );

      final bool dentrodoRaio = await validador.isDentroDoRaio();
      setState(() {
        _debugInfo +=
            '\n  Resultado: ${dentrodoRaio ? "✅ DENTRO DO RAIO" : "❌ FORA DO RAIO"}';
      });

      // Testar com PlantaoController
      setState(() {
        _debugInfo +=
            '\n\n🧪 Testando PlantaoController.validarLocalizacaoUsuario()...';
      });

      final bool validacaoController = await _plantaoController!
          .validarLocalizacaoUsuario();
      setState(() {
        _debugInfo +=
            '\n  Resultado: ${validacaoController ? "✅ VÁLIDO" : "❌ INVÁLIDO"}';
      });
    } catch (e) {
      setState(() {
        _debugInfo += '\n❌ Erro ao obter localização: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug de Localização'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _debugInfo = 'Reiniciando debug...';
              });
              _initializeDebug();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _debugInfo,
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_currentPosition != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Localização Atual',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Latitude: ${_currentPosition!.latitude}'),
                      Text('Longitude: ${_currentPosition!.longitude}'),
                      Text('Precisão: ${_currentPosition!.accuracy}m'),
                      Text('Altitude: ${_currentPosition!.altitude}m'),
                      Text('Velocidade: ${_currentPosition!.speed}m/s'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
