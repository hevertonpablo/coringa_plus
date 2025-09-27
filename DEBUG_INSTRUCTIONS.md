# DEBUG - Problema "Fora do Raio Permitido"

## 📋 ANÁLISE INICIAL

Com base no objeto fornecido:
- **Plantão ID**: 1875
- **Unidade**: UPA 1
- **Coordenadas**: -22.732155329366655, -42.85126060846283
- **Raio permitido**: 50 metros
- **Endereço**: Avenida Carlos Lacerda, 1433, Apto 207 - Areal - Itaboraí

## 🔍 POSSÍVEIS CAUSAS IDENTIFICADAS

1. **Localização atual**: Usuário pode estar mais de 50m da unidade
2. **Precisão do GPS**: Baixa precisão pode causar erro de localização
3. **Permissões**: GPS desabilitado ou permissões negadas
4. **Conversão de dados**: Problema na conversão string → double do raio
5. **Algoritmo de cálculo**: Possível erro no cálculo de distância

## 🧪 COMO TESTAR O DEBUG

### Opção 1: Usar a tela de debug criada
```bash
# 1. Substitua temporariamente o main.dart:
cp lib/main_debug.dart lib/main.dart

# 2. Execute o app:
flutter run

# 3. Clique em "🧪 Debug de Localização"
# 4. Clique em "🧪 Testar Validação de Localização"
# 5. Observe os logs detalhados no console e na tela
```

### Opção 2: Verificar logs no console
```bash
# Execute o app e observe os logs que começam com:
# 🔍, 📍, ✅, ❌, 📏, etc.
flutter run --verbose
```

## 📊 O QUE O DEBUG VAI MOSTRAR

1. **Dados do plantão**: Confirmar se as coordenadas estão corretas
2. **Permissões GPS**: Status das permissões de localização
3. **Localização atual**: Coordenadas precisas do usuário
4. **Cálculo de distância**: Distância exata entre usuário e unidade
5. **Validação final**: Se está dentro ou fora do raio

## 🎯 LOCALIZAÇÕES PARA TESTE

### Coordenadas da UPA 1:
- **Latitude**: -22.732155329366655
- **Longitude**: -42.85126060846283

### Para simular "dentro do raio" (usando GPS falso):
- **25m ao norte**: -22.731955, -42.85126060846283
- **25m ao leste**: -22.732155329366655, -42.850960

### Para simular "fora do raio":
- **75m ao norte**: -22.731485, -42.85126060846283
- **100m ao leste**: -22.732155329366655, -42.850160

## 🔧 SOLUÇÕES POTENCIAIS

### Se o problema for precisão do GPS:
```dart
// No LocationValidatorController, ajustar configurações:
final Position posicaoAtual = await Geolocator.getCurrentPosition(
  locationSettings: const LocationSettings(
    accuracy: LocationAccuracy.best,  // Mudar para 'best'
    distanceFilter: 1,                 // Adicionar filtro
  ),
);
```

### Se o problema for o raio muito pequeno:
- Considerar aumentar para 75-100m
- Ou verificar se as coordenadas da unidade estão corretas

### Se o problema for conversão de tipos:
```dart
// Verificar se está correto no PlantaoController:
final double raio = double.tryParse(_plantaoAtual!.unidadeRaio.toString()) ?? 50;
```

## 📱 INSTRUÇÕES DE TESTE

1. **Teste em local conhecido**: Vá até o endereço da UPA 1 se possível
2. **Use GPS falso**: Configure coordenadas específicas no emulador
3. **Verifique permissões**: Certifique-se de que o GPS está habilitado
4. **Observe logs**: Acompanhe todos os logs no console

## 🚨 PRÓXIMOS PASSOS

Depois de executar o debug:

1. **Cole os logs aqui** para análise detalhada
2. **Informe sua localização atual** durante o teste
3. **Teste em diferentes locais** (próximo e longe da unidade)
4. **Verifique se o problema é sempre o mesmo** ou varia

---

**IMPORTANTE**: Lembre-se de restaurar o main.dart original após os testes:
```bash
git checkout lib/main.dart
```
