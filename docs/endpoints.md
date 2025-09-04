## Endpoints

### GET /v1/dbase
- Buscar base de dados

Exemplo: https://app.coringaplus.com/v1/dbase

no header

Authorization: Basic <token>


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
- Autenticação do usuário

Exemplo: https://app.coringaplus.com/v1/login

no header

Authorization: Basic <token>

no body

```json
{
  "login": "1235654899",
  "pwd": "369875",
  "database": "99"
}

```

response

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
- Buscar plantões do usuário

Exemplo: https://app.coringaplus.com/v1/plantoes/9/99

no header

Authorization: Basic <token>

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

## GET /v1/plantao/{userId}/{baseId}
- Buscar plantão do usuário

Exemplo: https://app.coringaplus.com/v1/plantao/1875/99

no header

Authorization: Basic <token>

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


## PUT /v1/registro
- Registrar entrada/saída

Exemplo: https://app.coringaplus.com/v1/registro

no header

Authorization: Basic <token>

no body

```json
{
    "plantaoId": "32", 
    "dataHora": "2025-06-28 06:50", 
    "tipo": "E",
    "database": "99",
    "longitude": "0.120000000",
    "latitude": "0.32000000",
    "selfie": "jkijdkaaderrw$$5jdfiejifdejrifji43e444..."
}
```

response

```json
{
    "status": "success",
    "data": {
        "retorno": "Registro Plantão: 32 Atualizado com sucesso!"
    }
}
```


## PUT /v1/cadastroexterno
- Registrar entrada/saída

Exemplo: https://app.coringaplus.com/v1/cadastroexterno

no header

Authorization: Basic <token>

no body

```json
{
    "nome": "José ROberto", 
    "nome_social": "", 
    "cpf": "1234567890120",
    "data_nascimento": "1969-08-19",
    "graduacao": "Médico",
    "conselho_numero": "325621",
    "conselho_uf": "RJ",
    "conselho_orgao": "CRM",
    "rg_numero": "123456",
    "rg_orgao": "Detran",
    "rg_data_emissao": "1995-05-13",
    "rg_uf": "RJ",
    "nacionalidade": "Brasileiro",
    "naturalidade": "Bom Jesus do Itabapoana",
    "pai": "Francisco",
    "mae": "Rita",
    "database": "99"	
}
```

response

```json
{
    "status": "success",
    "data": {
        "retorno": "Cadastro: José ROberto Feito com sucesso!"
    }
}
```




