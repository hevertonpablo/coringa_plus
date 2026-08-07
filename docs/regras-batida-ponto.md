# Regras de batida de ponto no app

Data da analise: 2026-08-07

## Escopo

Este documento consolida as regras de batida de ponto implementadas no app Flutter a partir do codigo atual.

Fontes principais analisadas:

- `lib/controller/plantao_controller.dart`
- `lib/helper/tolerance_validator.dart`
- `lib/controller/location_validator_controller.dart`
- `lib/pages/selfie_capture_screen.dart`
- `lib/pages/meus_plantoes_screen.dart`
- `lib/services/plantao_service.dart`
- `lib/services/registro_service.dart`
- `lib/model/plantao_model.dart`
- `test/plantao_controller_test.dart`
- `docs/endpoints.md`

Observacao importante:

- Este repositorio contem o app Flutter e a documentacao local dos endpoints.
- O backend nao esta presente aqui.
- Regras de negocio descritas abaixo refletem o comportamento do app e o contrato documentado da API, nao uma inspecao direta da implementacao do servidor.

## Objetos e campos usados na batida

O app trata cada registro de ponto a partir de um `Plantao`.

Campos relevantes do modelo:

- `plantaoId`: identificador do plantao usado no registro.
- `dtEntrada`: horario planejado de entrada.
- `dtSaida`: horario planejado de saida.
- `dtEntradaPonto`: horario real da entrada ja registrada.
- `dtSaidaPonto`: horario real da saida ja registrada.
- `toleranciaAntecipada`: quantos minutos antes da entrada o app aceita iniciar.
- `toleranciaAtraso`: quantos minutos apos a entrada o app ainda aceita iniciar, quando atraso e permitido.
- `permiteRegistroAtraso`: flag que habilita ou bloqueia entrada apos o horario de entrada.
- `unidadeLatitude`, `unidadeLongitude`, `unidadeRaio`: usados para validar a localizacao.
- `unidadeEndereco` e `unidade`: usados para exibicao e contexto do plantao.

Campos documentados pela API, mas nao mapeados pelo modelo atual:

- `data_plantao`

## Endpoints usados pelo app

### Consulta de plantoes correntes

- Endpoint: `GET /v1/plantoes/{userId}/{baseId}`
- Uso: carregar os plantoes que o app considera para iniciar ou finalizar ponto.
- Observacao de contrato: a documentacao informa que, por padrao, esse endpoint retorna os plantoes do dia atual, podendo incluir plantoes proximos conforme configuracao do sistema.

### Consulta de historico

- Endpoint: `GET /v1/plantoesHistorico/{userId}/{baseId}`
- Uso: abastecer a aba de historico em `Meus Plantões`.

### Registro de ponto

- Endpoint: `PUT /v1/registro`
- Uso: registrar tanto entrada quanto saida.
- Payload enviado pelo app:
  - `plantaoId`
  - `dataHora`
  - `tipo`
  - `database`
  - `longitude`
  - `latitude`
  - `selfie`

## Como o app escolhe o plantao que sera usado

O plantao usado na batida nao e descoberto diretamente no clique. Ele e definido antes, pelo `PlantaoController`.

Regra de prioridade em `PlantaoController.selecionarPlantaoAtual`:

1. Ordenar todos os plantoes por `dtEntrada` crescente.
2. Procurar plantoes abertos.
3. Se existir ao menos um aberto, escolher o mais recente por `dtEntrada`.
4. Se nao houver aberto, procurar plantoes pendentes que estejam dentro da janela permitida para entrada agora.
5. Se houver varios disponiveis para entrada, escolher o mais recente por `dtEntrada`.
6. Se ainda nao houver escolhido, pegar o primeiro plantao pendente futuro.
7. Se nada disso resolver, usar o ultimo plantao da lista como fallback.

Isso faz com que o app priorize finalizar um plantao em aberto antes de permitir iniciar outro.

### Definicoes de estado do plantao

O app nao usa um campo explicito de status. O estado e inferido assim:

- Plantao aberto: `dtEntradaPonto != null && dtSaidaPonto == null`
- Plantao pendente: `dtEntradaPonto == null && dtSaidaPonto == null`
- Plantao finalizado: `dtEntradaPonto != null && dtSaidaPonto != null`

### Regra para multiplos plantoes abertos

Se a lista da API trouxer mais de um plantao aberto, o app:

- nao bloqueia a tela automaticamente
- registra um `debugPrint` de alerta
- seleciona o plantao aberto mais recente

Ou seja, existe uma estrategia de desempate local, nao uma rejeicao de inconsistencia.

## Regra para decidir se a batida e entrada ou saida

O tipo do registro e calculado pelo app com base apenas no estado do plantao atual:

- Se `dtEntradaPonto == null`, o tipo enviado e `E`.
- Se `dtEntradaPonto != null` e `dtSaidaPonto == null`, o tipo enviado e `S`.
- Se entrada e saida ja existem, o app considera o plantao completamente registrado e nao deveria registrar novamente.

O app nao consulta um endpoint separado para descobrir se a proxima batida deve ser entrada ou saida.

## Regras para registrar entrada

Para registrar entrada, o plantao precisa estar pendente e dentro da janela aceita.

### Janela de entrada

A entrada e permitida quando `agora` estiver entre:

- `dtEntrada - toleranciaAntecipada`
- `dtEntrada + toleranciaAtraso`, se `permiteRegistroAtraso == true`
- `dtEntrada`, se `permiteRegistroAtraso == false`

Em termos de regra booleana:

- o app aceita entrada se `agora` nao for antes do inicio permitido
- e tambem nao for depois do fim permitido

### Defaults usados quando a API nao informar tolerancia

Quando o plantao nao trouxer esses valores, o app usa:

- `toleranciaAntecipada = 5`
- `toleranciaAtraso = 10`
- `permiteRegistroAtraso = true`

### Mensagens de status da entrada

Enquanto a entrada ainda nao foi registrada, o app exibe uma das mensagens abaixo:

- `Entrada permitida agora`
- `Entrada permitida em X`
- `Prazo para entrada expirado`

## Regras para registrar saida

Para registrar saida, o plantao precisa estar aberto.

### Validacao efetiva de saida

A validacao efetiva da saida no clique e simples:

- `dtEntradaPonto` precisa existir
- `agora` precisa ser maior que `dtEntradaPonto`

O app nao exige que `agora` seja maior ou igual a `dtSaida` para concluir a saida.

### Diferenca entre mensagem de status e validacao real

Existe uma diferenca importante entre o que o app mostra e o que ele realmente bloqueia:

- a mensagem de status usa `dtSaida` para dizer `Saida permitida em X` ou `Saida permitida agora`
- a validacao do clique usa apenas `dtEntradaPonto`

Na pratica, a interface pode sugerir que a saida ainda esta "em breve", mas o clique sera aceito assim que a entrada ja tiver sido registrada e o horario atual for posterior a essa entrada.

## Regras de geolocalizacao

Toda batida passa por validacao de localizacao antes de capturar a selfie e enviar o registro.

### Regras aplicadas

1. O servico de localizacao do aparelho precisa estar ativo.
2. O usuario precisa conceder permissao de localizacao.
3. Se a permissao estiver bloqueada permanentemente, o app interrompe o fluxo com erro.
4. O app tenta obter a posicao atual com alta precisao e limite de 30 segundos.
5. Se houver timeout, tenta usar a ultima posicao conhecida.
6. A ultima posicao conhecida so e aceita se tiver no maximo 5 minutos.
7. A distancia entre usuario e unidade precisa ser menor ou igual ao raio configurado no plantao.

### Mensagens de erro de localizacao

Mensagens relevantes disparadas pelo app:

- `Ative a localizacao do aparelho para registrar o ponto`
- `Permissao de localizacao negada`
- `Permissao de localizacao bloqueada. Libere nas configuracoes do aparelho`
- `Nao foi possivel obter sua localizacao em tempo habil...`
- `Voce esta fora do raio permitido (...)`

## Regras de selfie

O registro sempre envia uma selfie para a API, em base64 com prefixo MIME.

Regras observadas:

- o arquivo da selfie e convertido para base64 antes do `PUT /v1/registro`
- o app detecta o MIME pela extensao do arquivo
- o fallback de MIME e `image/jpeg`

Regra adicional da interface:

- para `Iniciar plantao`, o app exige que o rosto esteja corretamente posicionado no circulo antes de permitir a captura
- para `Finalizar plantao`, essa exigencia especifica de enquadramento facial nao e aplicada da mesma forma no inicio do fluxo

## Fluxo completo de batida

Fluxo principal em `SelfieCaptureScreen`:

1. Impede duplo clique enquanto `_isRegistering` estiver ativo.
2. Se for inicio de plantao, exige rosto posicionado.
3. Aguarda inicializacao da camera.
4. Para temporariamente o stream de deteccao facial.
5. Recupera o `plantaoAtual` ja escolhido pelo controller.
6. Valida geolocalizacao.
7. Calcula `agora = DateTime.now()`.
8. Determina `tipo` como `E` ou `S`.
9. Valida horario permitido para aquele tipo.
10. Captura a selfie.
11. Recupera o usuario autenticado.
12. Envia `PUT /v1/registro`.
13. Em caso de sucesso, mostra mensagem e recarrega os plantoes.
14. Ao final, reinicia o stream de deteccao facial e libera a tela para nova interacao.

## Texto do botao principal

O texto do botao depende do estado do `plantaoAtual`:

- Sem plantao atual: `Nenhum plantao`
- Plantao aberto: `Finalizar plantao`
- Plantao finalizado: `Plantao finalizado`
- Qualquer outro caso elegivel: `Iniciar plantao`

O app considera registravel o plantao atual quando ele estiver:

- aberto, ou
- pendente

## Regra especial para plantao consecutivo

Ao registrar uma saida com sucesso, o app tenta identificar se existe um proximo plantao que ja pode ser iniciado imediatamente.

### Condicoes para o proximo plantao ser elegivel

O proximo plantao precisa:

1. ser diferente do plantao finalizado
2. estar pendente
3. ter `dtEntrada >= dtSaida` do plantao finalizado
4. estar dentro da janela local configurada para inicio imediato

Janela local usada nessa busca:

- ate 15 minutos antes do `dtEntrada`
- ate 30 minutos depois do `dtEntrada`

Se houver candidato elegivel, o app mostra um dialog perguntando se o usuario deseja iniciar o novo plantao.

### Consequencias do aceite

Se o usuario aceitar:

- o app reaproveita a mesma selfie da saida anterior
- envia um novo `PUT /v1/registro` com `tipo: 'E'`
- usa o `plantaoId` do proximo plantao
- usa a mesma `dataHora`, latitude e longitude da operacao anterior

Se falhar, o app informa que o plantao anterior foi finalizado, mas o proximo nao foi iniciado.

## Regras de virada de dia

O codigo atual trata virada de dia melhor do que a analise antiga do repositorio sugeria.

### Comportamento implementado hoje

- Se existir um plantao aberto iniciado no dia anterior, ele tem prioridade sobre um plantao novo do dia atual.
- O app nao escolhe um novo plantao enquanto houver um plantao anterior aberto na lista recebida.
- Se houver mais de um aberto, o mais recente e selecionado.

Essas regras estao cobertas por testes unitarios em `test/plantao_controller_test.dart`.

### Limite real dessa regra

Essa protecao depende da lista retornada por `GET /v1/plantoes/{userId}/{baseId}`.

Se o backend nao devolver o plantao aberto que atravessou a meia-noite, o app nao tem como prioriza-lo, porque a selecao trabalha apenas sobre os plantoes recebidos.

## Regras de classificacao visual em "Meus Plantões"

Na tela de listagem, o app usa regras visuais adicionais para destacar o estado dos plantoes.

### Status visuais por item

- `Realizado`: entrada e saida preenchidas.
- `Em andamento`: plantao aberto.
- `Nao realizado`: sem entrada registrada e com `dtSaida` no passado.
- `Nao iniciado`: sem entrada registrada, com `dtEntrada` no passado e `dtSaida` ainda no futuro.
- `Futuro`: qualquer plantao restante que ainda nao entrou nas regras acima.

### Card de destaque

A tela prioriza a exibicao desta forma:

1. se existir plantao em andamento, ele vira o destaque principal
2. senao, se existir plantao nao iniciado, ele ganha prioridade como destaque mais urgente
3. senao, o destaque secundario passa a ser o proximo plantao futuro

### Regras por aba

Aba `hoje`:

- mostra apenas plantoes cuja `dtEntrada` cai no dia atual
- e que ainda nao tiveram entrada registrada

Aba `proximos`:

- mostra plantoes pendentes com `dtEntrada` no futuro

Aba `historico`:

- mostra dados vindos de `GET /v1/plantoesHistorico/{userId}/{baseId}`

## Regras temporais e fuso

O app usa `DateTime.now()` do dispositivo para:

- selecionar o plantao atual
- validar janelas de entrada e saida
- montar `dataHora` do payload de registro
- classificar estados visuais na UI

Implicacoes:

- o fuso efetivo depende do relogio do aparelho
- qualquer divergencia entre horario do dispositivo e horario do backend pode afetar a experiencia

## Regras que ficam implicitamente delegadas ao backend

O app envia o tipo e o `plantaoId`, mas nao garante sozinho toda a consistencia global. Ainda dependem do backend regras como:

- rejeitar entrada para plantao indevido
- rejeitar saida para plantao nao aberto no servidor
- impedir duplicidade de registro
- decidir quais plantoes devem ser devolvidos em `GET /v1/plantoes`
- aplicar validacoes complementares que nao existam no app

## Riscos e observacoes relevantes

### 1. Divergencia entre mensagem de saida e bloqueio real

Hoje a mensagem de status da saida usa `dtSaida`, mas o clique aceita a saida logo apos a entrada. Isso pode gerar comportamento aparentemente incoerente para o usuario.

### 2. Dependencia da lista retornada pela API

Toda a inteligencia de selecao depende dos plantoes recebidos do backend. Se um plantao aberto nao vier na resposta, o app nao o enxerga.

### 3. `data_plantao` nao e usado no app

Embora documentado na API, esse campo nao participa das regras locais atuais.

### 4. Inicio automatico de plantao consecutivo reutiliza a mesma selfie

Isso simplifica o fluxo, mas e uma regra funcional importante que precisa ser conhecida por produto e backend.

## Resumo executivo das regras atuais

- O app sempre tenta resolver a batida sobre um `plantaoAtual` escolhido previamente.
- Plantao aberto tem prioridade maxima sobre qualquer novo inicio.
- Entrada depende de janela com tolerancia antecipada e atraso.
- Saida depende apenas de existir entrada registrada e o horario atual ser posterior a ela.
- Geolocalizacao dentro do raio e obrigatoria para qualquer batida.
- Selfie e obrigatoria em qualquer batida.
- Ao finalizar um plantao, o app pode oferecer iniciar o seguinte imediatamente.
- Virada de dia funciona no app desde que o backend devolva o plantao aberto na listagem.