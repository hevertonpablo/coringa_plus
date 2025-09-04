import 'dart:convert';
import 'dart:io';

import '../interfaces/http_interfaces.dart';

class RegistroService {
  final IHttpService http;

  RegistroService(this.http);

  /// Registra entrada ou saída do plantão
  Future<Map<String, dynamic>> registrarPonto({
    required int plantaoId,
    required DateTime dataHora,
    required String tipo, // 'E' para entrada, 'S' para saída
    required String database,
    required double longitude,
    required double latitude,
    required File selfieFile,
  }) async {
    // Converte a imagem para base64
    final bytes = await selfieFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    // Formata a data/hora no formato esperado pela API
    final dataHoraFormatada = 
        "${dataHora.year.toString().padLeft(4, '0')}-"
        "${dataHora.month.toString().padLeft(2, '0')}-"
        "${dataHora.day.toString().padLeft(2, '0')} "
        "${dataHora.hour.toString().padLeft(2, '0')}:"
        "${dataHora.minute.toString().padLeft(2, '0')}";

    final body = {
      'plantaoId': plantaoId.toString(),
      'dataHora': dataHoraFormatada,
      'tipo': tipo,
      'database': database,
      'longitude': longitude.toString(),
      'latitude': latitude.toString(),
      'selfie': base64Image,
    };

    final response = await http.put('/v1/registro', body);
    return response;
  }
}
