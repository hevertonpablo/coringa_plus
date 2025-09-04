# Product Requirements Document (PRD)
## Coringa Plus - Sistema de Gestão de Plantões Médicos

### 1. Visão Geral do Produto

**Nome do Produto:** Coringa Plus  
**Versão:** 1.0.0  
**Plataforma:** Flutter (iOS, Android, Web, Desktop)  
**Tipo:** Aplicativo móvel para gestão de plantões médicos  

### 2. Objetivo do Produto

O Coringa Plus é um sistema de gestão de plantões médicos que permite aos profissionais de saúde:
- Autenticar-se no sistema com diferentes perfis/bases de dados
- Visualizar seus plantões agendados
- Registrar entrada/saída através de selfie com validação de geolocalização
- Controlar presença em unidades de saúde

### 3. Público-Alvo

**Usuários Primários:**
- Médicos plantonistas
- Enfermeiros
- Técnicos de enfermagem
- Outros profissionais de saúde

**Usuários Secundários:**
- Administradores de unidades de saúde
- Gestores de RH hospitalar
- Coordenadores médicos

### 4. Funcionalidades Principais

#### 4.1 Autenticação e Perfis
- **Login multi-base:** Sistema suporta múltiplas bases de dados/perfis
- **Validação de credenciais:** Matrícula e senha
- **Seleção de perfil:** Dropdown dinâmico carregado da API
- **Persistência de sessão:** Dados do usuário salvos localmente

#### 4.2 Gestão de Plantões
- **Listagem de plantões:** Visualização dos plantões do usuário
- **Próximo plantão:** Identificação automática do próximo plantão baseado em data/hora
- **Informações detalhadas:**
  - Unidade de saúde
  - Endereço da unidade
  - Horário de entrada e saída
  - Especialidade e setor
  - Duração do plantão

#### 4.3 Registro de Presença
- **Captura de selfie:** Câmera frontal para registro
- **Validação geográfica:** Verificação se o usuário está dentro do raio permitido da unidade
- **Controle temporal:** Registro de entrada e saída com timestamp
- **Interface de calendário:** Seleção de datas para visualização histórica

#### 4.4 Validação de Localização
- **GPS/Geolocalização:** Obtenção da posição atual do usuário
- **Cálculo de distância:** Validação se está dentro do raio permitido
- **Coordenadas da unidade:** Latitude e longitude configuráveis por unidade
- **Raio personalizável:** Distância permitida configurável (padrão: 50m)

### 5. Requisitos Técnicos

#### 5.1 Arquitetura
- **Padrão:** MVC (Model-View-Controller)
- **Injeção de Dependência:** GetIt para gerenciamento de dependências
- **Estado:** StatefulWidget para gerenciamento de estado local
- **Comunicação:** HTTP REST API

#### 5.2 Dependências Principais
```yaml
dependencies:
  flutter: sdk
  camera: ^0.11.1          # Captura de imagens
  geolocator: ^14.0.2      # Geolocalização
  http: ^1.4.0             # Requisições HTTP
  shared_preferences: ^2.5.3 # Persistência local
  get_it: ^8.0.3           # Injeção de dependência
  intl: ^0.20.2            # Formatação de datas
```

#### 5.3 API Endpoints
- `GET /v1/dbase` - Buscar perfis/bases disponíveis
- `POST /v1/login` - Autenticação do usuário
- `GET /v1/plantoes/{userId}/{baseId}` - Buscar plantões do usuário

### 6. Fluxo de Usuário

#### 6.1 Fluxo de Login
1. Usuário abre o aplicativo
2. Insere matrícula e senha
3. Sistema carrega perfis disponíveis
4. Usuário seleciona perfil
5. Sistema valida credenciais
6. Redirecionamento para tela principal

#### 6.2 Fluxo de Registro
1. Usuário acessa tela de registro
2. Sistema identifica próximo plantão
3. Valida localização do usuário
4. Se dentro do raio: permite captura de selfie
5. Se fora do raio: exibe alerta de localização
6. Registro salvo com timestamp e coordenadas

### 7. Regras de Negócio

#### 7.1 Validação de Plantão
- Apenas plantões futuros ou em andamento são considerados "próximos"
- Ordenação por data de entrada (mais próximo primeiro)
- Plantão atual = primeiro plantão cuja data de saída ainda não passou

#### 7.2 Validação Geográfica
- Usuário deve estar dentro do raio configurado da unidade
- Cálculo baseado em coordenadas GPS
- Raio padrão: 50 metros (configurável por unidade)

#### 7.3 Registro de Ponto
- Selfie obrigatória para registro
- Validação de localização obrigatória
- Timestamp automático no momento do registro
- Histórico de registros por data

### 8. Interface do Usuário

#### 8.1 Tela de Login
- Logo da aplicação
- Campos: Matrícula, Senha, Perfil
- Botão de login
- Design clean com cores corporativas (teal)

#### 8.2 Tela Principal
- Preview da câmera (formato quadrado)
- Informações do plantão atual
- Seletor de datas (horizontal scroll)
- Botão de registro
- Bottom navigation (Registrar/Plantões)

#### 8.3 Paleta de Cores
- **Primária:** Teal (#009688)
- **Background:** Light Gray (#F5F8FB, #EFF2F7)
- **Texto:** Black87, White
- **Bordas:** Teal outline

### 9. Segurança e Privacidade

#### 9.1 Autenticação
- Token de API fixo (deve ser migrado para OAuth)
- Credenciais não armazenadas em texto plano
- Sessão persistente com SharedPreferences

#### 9.2 Dados Sensíveis
- Localização GPS coletada apenas durante uso
- Imagens de selfie processadas localmente
- CPF e dados pessoais protegidos

### 10. Métricas e Analytics

#### 10.1 KPIs Sugeridos
- Taxa de login bem-sucedido
- Frequência de uso por usuário
- Precisão de localização
- Tempo médio de registro
- Taxa de registros fora do raio permitido

### 11. Roadmap e Melhorias Futuras

#### 11.1 Versão 1.1
- [ ] Notificações push para lembretes de plantão
- [ ] Histórico completo de registros
- [ ] Relatórios de frequência

#### 11.2 Versão 1.2
- [ ] Integração com sistemas hospitalares (HIS)
- [ ] Reconhecimento facial para validação
- [ ] Dashboard web para gestores

#### 11.3 Versão 2.0
- [ ] Troca de plantões entre profissionais
- [ ] Chat interno
- [ ] Integração com folha de pagamento

### 12. Critérios de Aceitação

#### 12.1 Login
- ✅ Sistema deve carregar perfis dinamicamente da API
- ✅ Validação de campos obrigatórios
- ✅ Redirecionamento após login bem-sucedido
- ✅ Tratamento de erros de autenticação

#### 12.2 Geolocalização
- ✅ Solicitação de permissão de localização
- ✅ Cálculo preciso de distância
- ✅ Bloqueio de registro fora do raio
- ✅ Feedback visual para usuário

#### 12.3 Câmera
- ✅ Acesso à câmera frontal
- ✅ Preview em tempo real
- ✅ Captura e salvamento de imagem
- ✅ Tratamento de permissões

### 13. Considerações Técnicas

#### 13.1 Performance
- Carregamento assíncrono de dados
- Cache local de informações frequentes
- Otimização de imagens capturadas

#### 13.2 Offline
- Dados básicos do usuário salvos localmente
- Sincronização quando conectividade retornar
- Feedback de status de conexão

#### 13.3 Multiplataforma
- Código compartilhado Flutter
- Adaptações específicas por plataforma
- Testes em diferentes dispositivos e versões

---

**Documento criado em:** Setembro 2024  
**Versão do documento:** 1.0  
**Próxima revisão:** Dezembro 2024
