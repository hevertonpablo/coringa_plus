import 'dart:math';

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371000; // Raio da Terra em metros

  final double lat1Rad = lat1 * (pi / 180);
  final double lat2Rad = lat2 * (pi / 180);
  final double deltaLatRad = (lat2 - lat1) * (pi / 180);
  final double deltaLonRad = (lon2 - lon1) * (pi / 180);

  final double a =
      sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
      cos(lat1Rad) * cos(lat2Rad) * sin(deltaLonRad / 2) * sin(deltaLonRad / 2);

  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}

void main() {
  // Dados do objeto fornecido pelo usuário
  final unidadeLongitude = "-42.85126060846283";
  final unidadeLatitude = "-22.732155329366655";
  final unidadeRaio = 50;

  // Coordenadas da unidade (como doubles)
  final double latitude = double.parse(unidadeLatitude);
  final double longitude = double.parse(unidadeLongitude);

  print('=== DEBUG VALIDAÇÃO DE LOCALIZAÇÃO ===');
  print('Unidade Latitude: $latitude');
  print('Unidade Longitude: $longitude');
  print('Raio permitido: $unidadeRaio metros');
  print('');

  // Testar diferentes cenários
  print('=== CENÁRIOS DE TESTE ===');

  // Cenário 1: Exatamente na unidade
  final dist1 = calculateDistance(latitude, longitude, latitude, longitude);
  print(
    '1. Exatamente na unidade: ${dist1.toStringAsFixed(2)}m - ${dist1 <= unidadeRaio ? "PERMITIDO" : "NEGADO"}',
  );

  // Cenário 2: 25 metros de distância (ao norte)
  final lat2 = latitude + 0.0002; // Aproximadamente 25m ao norte
  final dist2 = calculateDistance(latitude, longitude, lat2, longitude);
  print(
    '2. ~25m ao norte: ${dist2.toStringAsFixed(2)}m - ${dist2 <= unidadeRaio ? "PERMITIDO" : "NEGADO"}',
  );

  // Cenário 3: 75 metros de distância (fora do raio)
  final lat3 = latitude + 0.0007; // Aproximadamente 75m ao norte
  final dist3 = calculateDistance(latitude, longitude, lat3, longitude);
  print(
    '3. ~75m ao norte: ${dist3.toStringAsFixed(2)}m - ${dist3 <= unidadeRaio ? "PERMITIDO" : "NEGADO"}',
  );

  // Cenário 4: 25 metros de distância (ao leste)
  final lon4 = longitude + 0.0003; // Aproximadamente 25m ao leste
  final dist4 = calculateDistance(latitude, longitude, latitude, lon4);
  print(
    '4. ~25m ao leste: ${dist4.toStringAsFixed(2)}m - ${dist4 <= unidadeRaio ? "PERMITIDO" : "NEGADO"}',
  );

  // Cenário 5: 60 metros de distância (fora do raio)
  final lat5 = latitude + 0.0005; // Aproximadamente 60m ao norte
  final dist5 = calculateDistance(latitude, longitude, lat5, longitude);
  print(
    '5. ~60m ao norte: ${dist5.toStringAsFixed(2)}m - ${dist5 <= unidadeRaio ? "PERMITIDO" : "NEGADO"}',
  );

  print('');
  print('=== ANÁLISE DO PROBLEMA ===');
  print('Com base nos dados fornecidos:');
  print('- Coordenadas da unidade: $unidadeLatitude, $unidadeLongitude');
  print('- Raio permitido: $unidadeRaio metros');
  print(
    '- Endereço: Avenida Carlos Lacerda, 1433, Apto 207 - Areal - Itaboraí',
  );
  print('');
  print('POSSÍVEIS CAUSAS DO ERRO "fora do raio permitido":');
  print('1. Localização atual do usuário está mais de 50m da unidade');
  print('2. GPS com baixa precisão ou erro de localização');
  print('3. Coordenadas da unidade incorretas na API');
  print('4. Problema na conversão do raio (int vs double)');
  print('5. Permissões de localização negadas ou desabilitadas');

  print('');
  print('=== DEBUGGING STEPS ===');
  print('1. Verificar localização atual do usuário no momento do erro');
  print('2. Verificar se o GPS está ativado e com boa precisão');
  print('3. Testar com mock de localização próxima à unidade');
  print('4. Verificar se plantao.unidadeRaio está chegando como 50');
}
