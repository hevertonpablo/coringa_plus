## Endpoints

### GET /v1/dbase
- Esse endpoint tem como objetivo listar as bases de dados disponíveis, onde cada base corresponde a uma empresa específica. Ele permite identificar e selecionar a base de dados de uma empresa por meio de seu ID ou nome.

URL: https://app.coringaplus.com/v1/dbase
Método: GET
Autenticação: Obrigatória
Header:
    Authorization: Basic <token>

Response:

```json
{
    "status": "success",
    "data": [
        {
            "HealthCare": 1,
            "Grupo PRC": 2,
            "ForSaude": 3,
            "APP": 99
        }
    ]
}
```

### POST /v1/login
- Esse endpoint é utilizado para autenticar o usuário no aplicativo.
- No momento do login, o usuário deve informar em qual base de dados está cadastrado, garantindo que as credenciais sejam verificadas corretamente e que as informações retornadas pertençam à empresa correta.

URL: https://app.coringaplus.com/v1/login
Método: POST
Autenticação: Obrigatória
Header:
    Authorization: Basic <token>

Body:

```json
{
  "login": "1235654899",
  "pwd": "369875",
  "database": "99"
}

```

Response:

```json
{
    "status": "success",
    "data": {
        "user_id": 9,
        "nome": "Rita de cácia Santos",
        "nome_social": null,
        "cpf": "31103074563",
        "email": "jmalafaia@gmail.com"
    }
}

```
### GET /v1/plantoes/{userId}/{baseId}
- Esse endpoint retorna a lista de plantões agendados para o usuário em uma determinada base de dados.
- Por padrão, são retornados os plantões do dia atual, mas o resultado pode incluir plantões próximos, dependendo da configuração do sistema.

URL: https://app.coringaplus.com/v1/plantoes/{userId}/{baseId}
Método: GET
Autenticação: Obrigatória
Header:
    Authorization: Basic <token>

#### Parâmetros de Rota

userId: ID do usuário (médico/profissional).
baseId: ID da base de dados (empresa), obtido via /v1/dbase.

```json
{
    "status": "success",
    "data": [
        {
            "plantao_id": 2183,
            "data_plantao": "2025-09-04",
            "unidade": "UPA 1",
            "unidade_longitude": "-42.85126060846283",
            "unidade_latitude": "-22.732155329366655",
            "unidade_raio": 20,
            "tolerancia_antecipada_entrada": 5,
            "tolerancia_atraso_entrada": 10,
            "unidade_endereco": "Avenida Carlos Lacerda, 1433, Apto 207 - Areal - Itaboraí",
            "nome": "Rita de cácia Santos",
            "nome_social": null,
            "especialidade": "CLÍNICA MÉDICA",
            "setor": "UPA",
            "horas_plantao": 12,
            "turno": "Diurno",
            "dt_entrada": "2025-09-04 07:00:00",
            "dt_saida": "2025-09-04 19:00:00",
            "dt_entrada_ponto": null,
            "dt_saida_ponto": null
        },
        {
            "plantao_id": 2187,
            "data_plantao": "2025-09-05",
            "unidade": "UPA 1",
            "unidade_longitude": "-42.85126060846283",
            "unidade_latitude": "-22.732155329366655",
            "unidade_raio": 20,
            "tolerancia_antecipada_entrada": 5,
            "tolerancia_atraso_entrada": 10,
            "unidade_endereco": "Avenida Carlos Lacerda, 1433, Apto 207 - Areal - Itaboraí",
            "nome": "Rita de cácia Santos",
            "nome_social": null,
            "especialidade": "CLÍNICA MÉDICA",
            "setor": "UPA",
            "horas_plantao": 12,
            "turno": "Diurno",
            "dt_entrada": "2025-09-05 07:00:00",
            "dt_saida": "2025-09-05 19:00:00",
            "dt_entrada_ponto": null,
            "dt_saida_ponto": null
        }
    ]
}
```

### Campo `offline` (offline-first)

> **Adicionado em 2026-10-09 — task CORINGA-12.**
> Documentação retroativa: o app depende deste campo desde a feature
> de offline-first multi-tenant (commit `4c91135`).

O campo `offline` controla se a unidade onde o plantão ocorre permite
que o profissional bata ponto **sem internet e sem GPS**. É uma flag
**por unidade** — qualquer profissional alocado numa unidade com
`offline = "S"` herda o direito, independente de horário, perfil ou
cargo.

**Quando usar `"S"`:** unidades em locais sem cobertura de celular ou
GPS (presídios, órgãos públicos com blindagem eletromagnética,
subsolos de hospitais), ou unidades atrás de firewall corporativo
que bloqueia o domínio do backend.

**Valores aceitos pelo cliente** (`lib/model/plantao_model.dart:_parseOffline`):

| Valor da API | Interpretado como |
|--------------|-------------------|
| `"S"` | `true` (offline permitido) |
| `"N"` | `false` (offline proibido) |
| `"1"` | `true` |
| `"true"` (case-insensitive) | `true` |
| `true` (boolean nativo) | `true` |
| Ausente / `null` | **`false`** (opt-in — silêncio = sem offline) |
| Qualquer outro valor | `false` (fallback seguro) |

**Exemplo de payload atualizado:**

```json
{
    "plantao_id": 2183,
    "unidade": "Penitenciária Central",
    "unidade_longitude": "-42.85126060846283",
    "unidade_latitude": "-22.732155329366655",
    "unidade_raio": 500,
    "offline": "S",
    ...
}
```

**Comportamento do app quando `offline = "S"`:**

1. Não exige GPS — pula `validarLocalizacaoUsuarioDetalhada()`
2. Não exige internet — se `isOnline()` for `false` ou se a chamada
   HTTP falhar por instabilidade, enfileira em `PendingRegistroQueue`
3. Envia coordenadas como `"0"` (sentinela, ver `lib/services/registro_service.dart:43-44`)

**Risco se o backend remover ou renomear a chave:** todos os
plantões caem no fallback `false` e o modo offline some silenciosamente,
sem erro visível ao usuário ou ao time. Mudanças neste campo DEVEM
ser combinadas com release do app e comunicação ao suporte.

## GET /v1/plantao/{plantaoId}/{baseId}
- Esse endpoint retorna os detalhes completos de um plantão específico do usuário, identificado pelo ID do plantão.
- Funciona como a visualização individual (show) de um plantão.

URL: https://app.coringaplus.com/v1/plantao/1875/99
Método: GET
Autenticação: Obrigatória
Header:
    Authorization: Basic <token>

Parâmetros de Rota:
    plantaoId: 1875
    baseId: 99

Response:
```json
{
    "status": "success",
    "data": [
        {
            "plantao_id": 1875,
            "unidade": "UPA 1",
            "unidade_longitude": "-42.85126060846283",
            "unidade_latitude": "-22.732155329366655",
            "unidade_raio": 20,
            "tolerancia_antecipada_entrada": 5,
            "tolerancia_atraso_entrada": 10,
            "endereco": "Avenida Carlos Lacerda, 1433, Apto 207 - Areal - Itaboraí",
            "nome": "Rita de cácia Santos",
            "nome_social": null,
            "especialidade": "CLÍNICA MÉDICA",
            "setor": "UPA",
            "horas_plantao": 12,
            "turno": "Diurno",
            "dt_entrada": "2025-06-30 07:00:00",
            "dt_saida": "2025-06-30 18:00:00",
            "dt_entrada_ponto": null,
            "dt_saida_ponto": null
        }
    ]
}
```


### GET /v1/plantoesHistorico/{userId}/{baseId}
- Esse endpoint retorna o histórico de plantões do usuário em uma determinada base de dados, usado na aba "Histórico" do app.

URL: https://app.coringaplus.com/v1/plantoesHistorico/{userId}/{baseId}
Método: GET
Autenticação: Obrigatória
Header:
    Authorization: Basic <token>

#### Parâmetros de Rota

userId: ID do usuário (médico/profissional).
baseId: ID da base de dados (empresa), obtido via /v1/dbase.

```json
{
    "status": "success",
    "data": [
        {
            "plantao_id": 6263,
            "data_plantao": "2026-05-29",
            "unidade": "UPA ",
            "unidade_longitude": "-42.85180283821939",
            "unidade_latitude": "-22.73270661803669",
            "unidade_raio": 500,
            "tolerancia_antecipada_entrada": 30,
            "tolerancia_atraso_entrada": 999,
            "unidade_endereco": "Avenida Carlos Lacerda,1433   - Areal - Itaboraí - RJ",
            "nome": "USUÁRIO TESTE - NÃO ALTERAR",
            "nome_social": null,
            "especialidade": "Clínica médica",
            "setor": "UPA",
            "horas_plantao": 12,
            "turno": "Dia",
            "dt_entrada": "2026-05-29 15:00:00",
            "dt_saida": "2026-05-29 19:00:00",
            "dt_entrada_ponto": "2026-05-29 16:38:00",
            "dt_saida_ponto": "2026-05-29 16:44:00",
            "permite_registro_atraso": "S"
        }
    ]
}
```

## PUT /v1/registro
- Esse endpoint é responsável pelo registro de ponto dos profissionais, tanto na entrada quanto na saída do plantão.
- O registro é validado com base na geolocalização do usuário em relação à unidade hospitalar, respeitando as regras de tolerância de entrada/saída.
- Além disso, é necessário o envio de uma selfie como comprovação do registro.

URL: https://app.coringaplus.com/v1/registro
Método: PUT
Autenticação: Obrigatória
Header:
    Authorization: Basic <token>

Body:

```json
{
    "plantaoId": "32", 
    "dataHora": "2025-06-28 06:50", 
    "tipo": "E", // E=Entrada, S=Saída
    "database": "99",
    "longitude": "0.120000000",
    "latitude": "0.32000000",
    "selfie": "jkijdkaaderrw$$5jdfiejifdejrifji43e444..."
}
```

Response:

```json
{
    "status": "success",
    "data": {
        "retorno": "Registro Plantão: 32 Atualizado com sucesso!"
    }
}
```