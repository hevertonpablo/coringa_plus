# Analise da logica atual de plantao com virada de dia

Data da analise: 2026-07-09

## Escopo e limite da analise

Esta analise foi feita a partir do codigo Flutter disponivel neste workspace e da documentacao local de endpoints em `docs/endpoints.md`.

Nao ha codigo-fonte da API/backend neste repositorio. Portanto, queries SQL, repositories, use cases e datasources do servidor nao puderam ser inspecionados diretamente. Quando este documento fala sobre comportamento da API, ele se baseia apenas nos contratos documentados e no comportamento esperado pelo app.

## Componentes envolvidos

### App Flutter

- `lib/pages/selfie_capture_screen.dart`
  - Tela principal de registro.
  - Inicializa camera, detector facial, `PlantaoController` e `RegistroService`.
  - Decide se o botao mostra `Iniciar plantao` ou `Finalizar plantao`.
  - Executa o fluxo de registro em `_captureImage()`.

- `lib/controller/plantao_controller.dart`
  - Busca plantoes do usuario.
  - Mantem `_plantaoAtual` e `_plantoes`.
  - Decide qual plantao sera considerado atual em `_encontrarProximoPlantao()`.
  - Valida geolocalizacao usando `LocationValidatorController`.

- `lib/helper/tolerance_validator.dart`
  - Decide se a entrada esta dentro da janela permitida.
  - Decide se a saida e permitida.
  - Decide o tipo de registro: `E` para entrada ou `S` para saida.
  - Gera mensagens de status.

- `lib/services/plantao_service.dart`
  - Chama `GET /v1/plantoes/{userId}/{baseId}`.
  - Converte a lista retornada pela API para `Plantao`.

- `lib/services/registro_service.dart`
  - Monta o payload de registro.
  - Envia `PUT /v1/registro`.
  - Envia `plantaoId`, `dataHora`, `tipo`, `database`, coordenadas e selfie em base64.

- `lib/model/plantao_model.dart`
  - Modelo local de plantao.
  - Mapeia `dt_entrada`, `dt_saida`, `dt_entrada_ponto`, `dt_saida_ponto`, tolerancias e dados da unidade.
  - Nao mapeia `data_plantao`, apesar desse campo aparecer na documentacao do endpoint.

- `lib/pages/historico_registros_screen.dart`
  - Consulta os mesmos plantoes via `PlantaoController.listarPlantoes()`.
  - Classifica visualmente como `Realizado`, `Em andamento`, `Nao Realizado` ou `Futuro`.

### Endpoints documentados

- `GET /v1/plantoes/{userId}/{baseId}`
  - Documentado em `docs/endpoints.md`, linhas aproximadas 64-77.
  - Retorna plantoes agendados para usuario/base.
  - A propria documentacao afirma que, por padrao, sao retornados os plantoes do dia atual, podendo incluir proximos dependendo da configuracao.

- `PUT /v1/registro`
  - Documentado em `docs/endpoints.md`, linhas aproximadas 173-190.
  - Usado tanto para entrada quanto para saida.
  - O campo `tipo` diferencia `E` de entrada e `S` de saida.

## Campos usados pelo app

O modelo `Plantao` declara os principais campos em `lib/model/plantao_model.dart`, linhas aproximadas 1-20:

```dart
final int plantaoId;
final DateTime dtEntrada;
final DateTime dtSaida;
final DateTime? dtEntradaPonto;
final DateTime? dtSaidaPonto;
final int? toleranciaAntecipada;
final int? toleranciaAtraso;
final bool permiteRegistroAtraso;
```

O parser do JSON usa estes nomes da API em `lib/model/plantao_model.dart`, linhas aproximadas 44-71:

```dart
plantaoId: json['plantao_id'],
dtEntrada: DateTime.parse(json['dt_entrada']),
dtSaida: DateTime.parse(json['dt_saida']),
dtEntradaPonto: json['dt_entrada_ponto'] != null
    ? DateTime.tryParse(json['dt_entrada_ponto'])
    : null,
dtSaidaPonto: json['dt_saida_ponto'] != null
    ? DateTime.tryParse(json['dt_saida_ponto'])
    : null,
```

Na documentacao do endpoint aparece tambem `data_plantao`, em `docs/endpoints.md`, linhas aproximadas 84-86 e 105-107. Esse campo parece ser o equivalente mais proximo a uma data de referencia da escala, mas ele nao e mapeado pelo app Flutter.

Nao foram encontrados no app campos com nomes como `data_referencia`, `data_competencia`, `dia_escala` ou `escala_data`.

## Consulta de status atual do profissional

O app nao possui um endpoint especifico de "status atual". O status e derivado localmente a partir da lista retornada por `GET /v1/plantoes/{userId}/{baseId}`.

O fluxo comeca em `PlantaoController.inicializar()`, em `lib/controller/plantao_controller.dart`, linhas aproximadas 41-50:

```dart
final plantoes = await listarPlantoes();
plantoes.sort((a, b) => a.dtEntrada.compareTo(b.dtEntrada));
_plantoes = List.unmodifiable(plantoes);
_plantaoAtual = _encontrarProximoPlantao(plantoes);
```

`listarPlantoes()` carrega o usuario local e chama o service, em `lib/controller/plantao_controller.dart`, linhas aproximadas 30-37:

```dart
_usuario = (await AuthService.getUser())!;
final plantaoService = getIt<PlantaoService>();
final plantoes = await plantaoService.buscarPlantoesDoUsuario(
  _usuario.id,
  int.parse(_usuario.database),
);
```

O service chama diretamente o endpoint em `lib/services/plantao_service.dart`, linhas aproximadas 9-15:

```dart
final endpoint = '/v1/plantoes/$userId/$baseId';
final response = await http.get(endpoint);
final List<dynamic> plantaoList = response['data'];
return plantaoList.map((item) => Plantao.fromJson(item)).toList();
```

## Como o app escolhe o plantao atual

A escolha do plantao atual acontece em `_encontrarProximoPlantao()`, em `lib/controller/plantao_controller.dart`, linhas aproximadas 53-85.

A regra atual:

1. Captura `agora = DateTime.now()`.
2. Ordena os plantoes por `dtEntrada`.
3. Filtra plantoes disponiveis agora usando `_isPlantaoDisponivelParaRegistroAgora()`.
4. Se houver disponiveis, retorna o mais recente por `dtEntrada`.
5. Se nao houver disponiveis, retorna o proximo plantao futuro.
6. Se nao houver futuro, retorna o ultimo plantao da lista.

Trecho relevante, linhas aproximadas 54-70:

```dart
final agora = DateTime.now();

plantoes.sort((a, b) {
  final aDt = a.dtEntrada;
  final bDt = b.dtEntrada;
  return aDt.compareTo(bDt);
});

final plantoesDisponiveisAgora = plantoes
    .where((p) => _isPlantaoDisponivelParaRegistroAgora(p, agora))
    .toList()
  ..sort((a, b) => b.dtEntrada.compareTo(a.dtEntrada));

if (plantoesDisponiveisAgora.isNotEmpty) {
  return plantoesDisponiveisAgora.first;
}
```

A disponibilidade e calculada em `lib/controller/plantao_controller.dart`, linhas aproximadas 88-108:

```dart
final tipoRegistro = ToleranceValidator.determinarTipoRegistro(
  dtEntradaPonto: plantao.dtEntradaPonto,
  dtSaidaPonto: plantao.dtSaidaPonto,
);

if (tipoRegistro == 'E') {
  return ToleranceValidator.isEntradaPermitida(...);
}

return ToleranceValidator.isSaidaPermitida(
  agora: agora,
  horarioEntradaRegistrada: plantao.dtEntradaPonto,
);
```

Conceitualmente, o app nao faz uma busca explicita do tipo "primeiro encontre plantao aberto do profissional". Ele calcula disponibilidade por plantao retornado pela API. Se o plantao aberto nao vier na lista da API, o app nao tem como finaliza-lo.

## Decisao entre entrada e saida

O tipo de registro e determinado exclusivamente por `dtEntradaPonto` e `dtSaidaPonto`, em `lib/helper/tolerance_validator.dart`, linhas aproximadas 48-62:

```dart
if (dtEntradaPonto == null) {
  return 'E';
} else if (dtSaidaPonto == null) {
  return 'S';
} else {
  throw Exception(
    'Plantao ja foi completamente registrado (entrada e saida)',
  );
}
```

Assim, para o app:

- Plantao sem entrada registrada: `dtEntradaPonto == null` -> entrada.
- Plantao com entrada e sem saida: `dtEntradaPonto != null && dtSaidaPonto == null` -> saida.
- Plantao com entrada e saida: finalizado.

Nao existe campo explicito `ABERTO`, `FINALIZADO`, `EM_ANDAMENTO` ou `PENDENTE` no modelo do app.

O botao da tela usa uma regra ainda mais simples em `lib/pages/selfie_capture_screen.dart`, linhas aproximadas 672-683:

```dart
final plantao = _plantaoController.plantaoAtual;
if (plantao == null) return 'Iniciar plantao';

if (plantao.dtEntradaPonto != null) {
  return 'Finalizar plantao';
}

return 'Iniciar plantao';
```

Importante: o botao nao procura um plantao aberto globalmente. Ele olha apenas para o `plantaoAtual` previamente escolhido pelo `PlantaoController`.

## Fluxo atual de entrada

O fluxo de entrada ocorre em `_captureImage()`, em `lib/pages/selfie_capture_screen.dart`, linhas aproximadas 546-657.

Passo a passo:

1. A tela verifica se ja esta registrando.
2. Se o texto do botao for `Iniciar plantao`, exige rosto posicionado.
3. Aguarda inicializacao da camera.
4. Para o stream de deteccao facial.
5. Obtem `plantaoAtual`.
6. Valida geolocalizacao contra a unidade.
7. Captura `agora = DateTime.now()`.
8. Chama `ToleranceValidator.determinarTipoRegistro()`.
9. Se o tipo for `E`, valida janela de entrada com tolerancia.
10. Captura selfie.
11. Busca usuario local.
12. Envia `PUT /v1/registro` com `tipo: 'E'`.
13. Se a API retornar `status == 'success'`, recarrega plantoes.

Trechos relevantes:

`lib/pages/selfie_capture_screen.dart`, linhas aproximadas 566-574:

```dart
final plantao = _plantaoController.plantaoAtual;
if (plantao == null) {
  _showMessage('Nenhum plantao encontrado', isError: true);
  return;
}

final validacaoLocalizacao =
    await _plantaoController.validarLocalizacaoUsuarioDetalhada();
```

`lib/pages/selfie_capture_screen.dart`, linhas aproximadas 587-602:

```dart
final agora = DateTime.now();
final tipoRegistro = ToleranceValidator.determinarTipoRegistro(
  dtEntradaPonto: plantao.dtEntradaPonto,
  dtSaidaPonto: plantao.dtSaidaPonto,
);

if (tipoRegistro == 'E') {
  horarioPermitido = ToleranceValidator.isEntradaPermitida(...);
}
```

`lib/pages/selfie_capture_screen.dart`, linhas aproximadas 628-637:

```dart
final response = await _registroService.registrarPonto(
  plantaoId: plantao.plantaoId,
  dataHora: agora,
  tipo: tipoRegistro,
  database: user.database,
  longitude: position.longitude,
  latitude: position.latitude,
  selfieFile: File(image.path),
);
```

No service, o payload e montado em `lib/services/registro_service.dart`, linhas aproximadas 34-44:

```dart
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
```

## Fluxo atual de saida

O fluxo de saida usa o mesmo `_captureImage()` e o mesmo endpoint `PUT /v1/registro`.

A diferenca e que o tipo calculado passa a ser `S` quando o `plantaoAtual` ja possui `dtEntradaPonto` e ainda nao possui `dtSaidaPonto`.

Passo a passo:

1. A tela usa o `plantaoAtual` escolhido pelo controller.
2. O botao mostra `Finalizar plantao` se `plantaoAtual.dtEntradaPonto != null`.
3. Ao clicar, valida geolocalizacao.
4. Chama `determinarTipoRegistro()`.
5. Como `dtEntradaPonto != null && dtSaidaPonto == null`, o tipo vira `S`.
6. Valida saida com `isSaidaPermitida()`.
7. Captura selfie.
8. Envia `PUT /v1/registro` com `tipo: 'S'` e o mesmo `plantaoId`.
9. Recarrega plantoes apos sucesso.

Validacao de saida em `lib/helper/tolerance_validator.dart`, linhas aproximadas 36-46:

```dart
if (horarioEntradaRegistrada == null) {
  return false;
}

return agora.isAfter(horarioEntradaRegistrada);
```

Essa regra permite saida em qualquer momento posterior a entrada registrada. Ela nao prende a saida ao mesmo dia calendario.

Mensagem de status para saida em `lib/helper/tolerance_validator.dart`, linhas aproximadas 99-109:

```dart
if (agora.isBefore(horarioSaida)) {
  return 'Saida permitida em ...';
} else {
  return 'Saida permitida agora';
}
```

Observacao: a mensagem considera `horarioSaida`, mas a validacao efetiva usada no clique considera apenas se `agora` e depois de `dtEntradaPonto`.

## Filtros e comparacoes com data atual

Foram encontrados estes usos relevantes de `DateTime.now()` e comparacoes temporais:

- `PlantaoController._encontrarProximoPlantao()`
  - `lib/controller/plantao_controller.dart`, linha aproximada 55.
  - Usa `agora` para escolher plantao atual.

- `PlantaoController.getNextPlantao()`
  - `lib/controller/plantao_controller.dart`, linhas aproximadas 168-179.
  - Compara `entrada.year/month/day` com `agora.year/month/day` apenas para formatar exibicao.

- `SelfieCaptureScreen._updateStatusMessage()`
  - `lib/pages/selfie_capture_screen.dart`, linhas aproximadas 389-399.
  - Usa `agora` para gerar mensagem de status.

- `SelfieCaptureScreen._isPlantaoFuturo()`
  - `lib/pages/selfie_capture_screen.dart`, linhas aproximadas 412-416.
  - Usa `plantao.dtEntrada.isAfter(DateTime.now())`.

- `SelfieCaptureScreen._captureImage()`
  - `lib/pages/selfie_capture_screen.dart`, linha aproximada 588.
  - Usa `agora` como data/hora real enviada ao endpoint.

- `SelfieCaptureScreen._getProximoPlantaoDiasText()`
  - `lib/pages/selfie_capture_screen.dart`, linhas aproximadas 705-713.
  - Normaliza hoje e proximo plantao para comparar dias de calendario apenas na exibicao.

- `HistoricoRegistrosScreen`
  - `lib/pages/historico_registros_screen.dart`, linhas aproximadas 50-66 e 72-97.
  - Usa `DateTime.now()` para filtros visuais: realizados, nao realizados e futuros.

No app Flutter nao foi encontrado filtro explicito do tipo `WHERE data = hoje`, `startOfDay`, `endOfDay`, `CURRENT_DATE` ou `GETDATE`, porque essas consultas pertencem ao backend e nao estao neste repositorio.

Porem, a documentacao do endpoint `GET /v1/plantoes/{userId}/{baseId}` afirma que, por padrao, retorna os plantoes do dia atual. Isso indica que o filtro por dia provavelmente existe no backend/API.

## Data real, data de escala e status

O app diferencia parcialmente os conceitos:

- Data/hora planejada de entrada: `dt_entrada` -> `Plantao.dtEntrada`.
- Data/hora planejada de saida: `dt_saida` -> `Plantao.dtSaida`.
- Data/hora real de entrada: `dt_entrada_ponto` -> `Plantao.dtEntradaPonto`.
- Data/hora real de saida: `dt_saida_ponto` -> `Plantao.dtSaidaPonto`.
- Data/hora real do registro enviado: `dataHora`, gerado com `DateTime.now()` no clique.

O app nao mapeia uma data de referencia da escala. A documentacao mostra `data_plantao`, mas `Plantao.fromJson()` ignora esse campo.

O status e inferido:

- Aberto/em andamento: `dtEntradaPonto != null && dtSaidaPonto == null`.
- Finalizado/realizado: `dtEntradaPonto != null && dtSaidaPonto != null`.
- Pendente/entrada: `dtEntradaPonto == null`.

Nao ha status explicito no modelo.

## Trava contra dois plantoes abertos

No app Flutter nao ha uma trava global que procure todos os plantoes retornados e bloqueie caso qualquer um esteja aberto.

O comportamento atual depende do `plantaoAtual` escolhido:

- Se o `plantaoAtual` tem `dtEntradaPonto != null`, o botao vira `Finalizar plantao`.
- Se o `plantaoAtual` tem `dtEntradaPonto == null`, o botao vira `Iniciar plantao`.

Se existir um plantao aberto no backend mas ele nao vier no `GET /v1/plantoes/{userId}/{baseId}`, o app nao consegue detectar esse plantao aberto.

Tambem nao foi possivel confirmar se o backend impede dois plantoes abertos simultaneos, pois o codigo da API nao esta disponivel neste workspace.

## Onde o problema conceitual pode acontecer

O ponto mais sensivel esta na combinacao entre:

1. O endpoint de consulta documentado como retornando, por padrao, plantoes do dia atual.
2. O app decidir tudo a partir da lista retornada por esse endpoint.
3. O app escolher `plantaoAtual` localmente sem uma etapa anterior de "buscar plantao aberto".
4. O botao decidir entrada/saida apenas olhando o `dtEntradaPonto` do `plantaoAtual`.

Exemplo de risco com plantao 08 18:00 -> 09 06:00:

1. No dia 08, a API retorna o plantao do dia 08.
2. O app registra entrada no `plantaoId` correto.
3. No dia 09, ao abrir o app, `GET /v1/plantoes/{userId}/{baseId}` pode retornar apenas os plantoes do dia 09.
4. Se o plantao iniciado no dia 08 nao vier nessa lista, o app nao enxerga `dtEntradaPonto != null && dtSaidaPonto == null`.
5. O `PlantaoController` escolhe outro plantao como `plantaoAtual`.
6. Se esse outro plantao estiver sem `dtEntradaPonto`, o botao mostra `Iniciar plantao`.
7. Ao clicar, o app envia `tipo: 'E'` para um novo `plantaoId`, em vez de enviar `tipo: 'S'` para o plantao aberto do dia 08.

Se a API retornasse o plantao aberto do dia anterior, a logica local provavelmente conseguiria finalizar, porque `_isPlantaoDisponivelParaRegistroAgora()` considera saida permitida quando `dtEntradaPonto` existe e `dtSaidaPonto` e nulo.

O risco principal, portanto, nao parece estar na regra local de saida atravessando meia-noite. A regra local de saida nao bloqueia virada de dia. O risco esta em o app depender de uma lista possivelmente filtrada pelo dia atual antes de verificar se existe plantao aberto.

## Hipotese do problema

A hipotese mais forte e que a logica atual esta presa ao dia do calendario na consulta de plantoes da API.

O endpoint `GET /v1/plantoes/{userId}/{baseId}` e documentado como retornando por padrao os plantoes do dia atual. Em plantoes que atravessam a meia-noite, o plantao aberto pertence a data de referencia do dia anterior, por exemplo `data_plantao = 2026-07-08`, mas a tentativa de saida acontece em `2026-07-09`.

Se a API filtra por `data_plantao = hoje`, `dt_entrada` entre inicio/fim do dia atual, ou regra equivalente, ela deixa de retornar o plantao aberto iniciado no dia anterior. Como o app so decide `Finalizar plantao` quando o `plantaoAtual` retornado tem `dtEntradaPonto != null`, ele passa a selecionar um plantao do dia 09 sem entrada registrada e mostra `Iniciar plantao`.

Em resumo: a falha provavel nao e o app nao saber enviar saida. Ele sabe enviar `tipo: 'S'`. A falha provavel e o plantao aberto correto nao chegar ao app quando a data vira.

## Pontos que precisam ser validados antes da correcao

1. Confirmar no backend a query real de `GET /v1/plantoes/{userId}/{baseId}`.

2. Verificar se a API filtra por `data_plantao = CURRENT_DATE`, `dt_entrada BETWEEN inicio_do_dia AND fim_do_dia`, `created_at`, `data_referencia`, `data_competencia` ou regra similar.

3. Confirmar se `data_plantao` e a data de referencia da escala e se deve continuar sendo a data do inicio do plantao em escalas que viram o dia.

4. Confirmar se existe no banco um campo de status explicito ou se o estado aberto e realmente derivado de `dt_entrada_ponto IS NOT NULL AND dt_saida_ponto IS NULL`.

5. Confirmar se o backend permite dois plantoes abertos para o mesmo profissional/base.

6. Confirmar qual deve ser a prioridade da consulta: primeiro plantao aberto, depois plantao disponivel para entrada, depois futuro.

7. Confirmar se o endpoint de listagem deve sempre incluir plantao aberto, mesmo que ele pertença a `data_plantao` anterior.

8. Confirmar se existe mais de uma escala simultanea possivel para o mesmo profissional e como desempatar.

9. Confirmar regra de saida antes do horario previsto. O app hoje permite saida assim que `agora.isAfter(dtEntradaPonto)`, embora a mensagem de status use `dt_saida`.

10. Confirmar se o registro de saida deve validar tolerancia em torno de `dt_saida` ou permitir qualquer saida apos entrada.

11. Confirmar se a API confia no `tipo` enviado pelo app ou recalcula entrada/saida pelo estado do plantao no banco.

12. Confirmar se a API valida que `tipo: 'S'` so pode ser aplicado ao mesmo `plantaoId` que possui entrada aberta.

13. Confirmar se `PUT /v1/registro` deveria rejeitar `tipo: 'E'` quando ja houver qualquer plantao aberto para o profissional.

14. Confirmar timezone usado por app, API e banco. O app usa `DateTime.now()` local do dispositivo; a API/banco podem usar outro timezone.

15. Confirmar se a resposta de `GET /v1/plantoes` deveria trazer tambem `data_plantao` para o modelo do app, caso essa data precise ser exibida ou usada em regras futuras.

## Conclusao

A logica Flutter atual considera plantao aberto quando `dtEntradaPonto != null && dtSaidaPonto == null`, mas essa verificacao so acontece sobre o `plantaoAtual` escolhido a partir da lista retornada pela API.

Para plantoes que atravessam a meia-noite, o comportamento correto depende de a API retornar o plantao aberto iniciado no dia anterior. Se o backend filtra a listagem pelo dia atual antes de incluir plantoes abertos, o app pode selecionar um plantao novo e iniciar outra entrada.

Antes de corrigir, o ponto mais importante e validar a query da API de listagem e garantir que "plantao aberto do profissional" tenha prioridade sobre "plantao do dia atual".
