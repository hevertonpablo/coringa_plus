# Checklist MVP - Coringa Plus
## Status de Implementação das Funcionalidades

### 📊 Resumo Executivo

**Status Geral do MVP:** 🟡 **Parcialmente Implementado (70%)**

| Categoria | Status | Progresso |
|-----------|--------|-----------|
| Tela de Login | ✅ Implementado | 90% |
| Registro de Presença | 🟡 Parcial | 60% |
| Tela de Plantões | 🟡 Parcial | 40% |
| Splash Screen | ❌ Não Implementado | 0% |

---

## ✅ FUNCIONALIDADES IMPLEMENTADAS

### 🔐 Tela de Login
- ✅ **Campos de entrada:** Matrícula e senha
- ✅ **Select de empresa/base:** Dropdown dinâmico carregado da API `/v1/dbase`
- ✅ **Validação de credenciais:** Integração com endpoint `/v1/login`
- ✅ **Múltiplas bases de dados:** Suporte completo para médico em várias empresas
- ✅ **Persistência de sessão:** Dados salvos com SharedPreferences
- ✅ **Tratamento de erros:** Feedback visual para falhas de login
- ✅ **Design responsivo:** Interface limpa com tema teal
- ✅ **Redirecionamento:** Navegação automática após login bem-sucedido

**Arquivos relacionados:**
- `lib/pages/auth_screen.dart`
- `lib/controller/login_controller.dart`
- `lib/services/auth_service.dart`

### 📸 Registro de Presença (Parcial)
- ✅ **Captura de selfie:** Câmera frontal funcionando
- ✅ **Preview da câmera:** Interface com preview em tempo real
- ✅ **Validação de localização:** GPS e cálculo de distância implementado
- ✅ **Verificação de raio:** Bloqueio quando fora da área permitida
- ✅ **Informações do plantão:** Exibição de unidade e endereço
- ✅ **Interface de calendário:** Seletor horizontal de datas
- ✅ **Identificação do próximo plantão:** Lógica implementada
- ✅ **Bottom navigation:** Navegação entre Registrar/Plantões

**Arquivos relacionados:**
- `lib/pages/selfie_capture_screen.dart`
- `lib/controller/plantao_controller.dart`
- `lib/controller/location_validator_controller.dart`

### 📅 Gestão de Plantões (Básica)
- ✅ **Busca de plantões:** Integração com `/v1/plantoes/{userId}/{baseId}`
- ✅ **Listagem básica:** Exibição dos plantões do usuário
- ✅ **Próximo plantão:** Identificação automática baseada em data/hora
- ✅ **Informações detalhadas:** Unidade, endereço, horários, especialidade
- ✅ **Ordenação por data:** Plantões ordenados cronologicamente

**Arquivos relacionados:**
- `lib/services/plantao_service.dart`
- `lib/model/plantao_model.dart`
- `lib/pages/register_screen.dart`

### 🏗️ Arquitetura e Infraestrutura
- ✅ **Padrão MVC:** Separação clara de responsabilidades
- ✅ **Injeção de dependência:** GetIt configurado
- ✅ **Modelos de dados:** UserModel e PlantaoModel implementados
- ✅ **Serviços HTTP:** HttpService com interface
- ✅ **Configuração de dependências:** Locator configurado
- ✅ **Tratamento de erros:** Try/catch em operações críticas

---

## ❌ FUNCIONALIDADES FALTANTES PARA MVP

### 🎬 Splash Screen (Crítico)
- ❌ **Tela inicial:** Criar splash screen antes do login
- ❌ **Animações:** Implementar animações leves e atrativas
- ❌ **Logo animado:** Animação do logo da empresa
- ❌ **Loading state:** Indicador de carregamento inicial
- ❌ **Transição suave:** Animação para tela de login

**Prioridade:** 🔴 **ALTA** - Essencial para experiência do usuário

### 📸 Registro de Presença (Melhorias Críticas)
- ✅ **Envio do registro:** Integração com endpoint `PUT /v1/registro`
- ✅ **Validação de tolerância:** Implementar tolerância de entrada (5min antecipada, 10min atraso)
- ✅ **Controle entrada/saída:** Distinção entre registro de entrada (E) e saída (S)
- ✅ **Timestamp preciso:** Validação de horário baseado em tolerâncias
- ✅ **Feedback de sucesso:** Confirmação visual após registro
- ✅ **Histórico de registros:** Visualização de pontos já registrados

**Prioridade:** 🔴 **ALTA** - Funcionalidade core do sistema

### 📅 Tela de Plantões (Melhorias Essenciais)
- ✅ **Interface dedicada:** Criar tela específica para listagem de plantões
- ✅ **Status com cores:**
  - 🟢 Verde → Plantões realizados (com `dt_entrada_ponto` e `dt_saida_ponto`)
  - 🔴 Vermelho → Plantões não realizados (sem registros de ponto)
  - 🟠 Laranja → Plantões futuros (data > hoje)
- ✅ **Filtros por status:** Opção de filtrar por realizado/não realizado/futuro
- ✅ **Detalhes expandidos:** Visualização completa de informações do plantão
- ✅ **Histórico completo:** Plantões passados, presentes e futuros

**Prioridade:** 🟡 **MÉDIA** - Importante para gestão completa

### 🔧 Melhorias Técnicas
- ❌ **Tratamento offline:** Comportamento quando sem internet
- ❌ **Cache inteligente:** Armazenamento local de plantões
- ❌ **Sincronização:** Upload de registros quando conectar
- ❌ **Validação de formulários:** Melhor UX nos campos de entrada
- ❌ **Loading states:** Indicadores visuais durante operações
- ❌ **Error handling:** Tratamento mais robusto de erros de API

**Prioridade:** 🟡 **MÉDIA** - Qualidade e robustez

---

## 🔍 GAPS IDENTIFICADOS NA IMPLEMENTAÇÃO ATUAL

### 1. **Registro de Presença Incompleto**
**Problema:** A captura de selfie está implementada, mas não há integração com o endpoint de registro.

**Impacto:** Funcionalidade principal não funcional.

**Solução:** Implementar chamada para `PUT /v1/registro` com:
```json
{
    "plantaoId": "32", 
    "dataHora": "2025-06-28 06:50", 
    "tipo": "E", // E=Entrada, S=Saída
    "database": "99",
    "longitude": "0.120000000",
    "latitude": "0.32000000",
    "selfie": "base64_image_string"
}
```

### 2. **Falta de Validação de Tolerância**
**Problema:** Não há validação das tolerâncias de entrada (`tolerancia_antecipada_entrada` e `tolerancia_atraso_entrada`).

**Impacto:** Registros podem ser feitos fora do horário permitido.

**Solução:** Implementar validação baseada nos campos da API:
- Entrada permitida: `dt_entrada - tolerancia_antecipada_entrada` até `dt_entrada + tolerancia_atraso_entrada`
- Saída: Apenas após `dt_entrada` (sem tolerância)

### 3. **Tela de Plantões Rudimentar**
**Problema:** Existe apenas uma referência básica, sem interface dedicada.

**Impacto:** Usuário não consegue visualizar histórico completo.

**Solução:** Criar `PlantoesList` com status coloridos e filtros.

### 4. **Ausência de Splash Screen**
**Problema:** App inicia diretamente na tela de login.

**Impacto:** Experiência do usuário menos profissional.

**Solução:** Criar `SplashScreen` com animações e carregamento inicial.

---

## 📋 PLANO DE IMPLEMENTAÇÃO PARA MVP COMPLETO

### Sprint 1 - Funcionalidades Críticas (1-2 semanas)
1. **Implementar Splash Screen**
   - Criar `SplashScreen` widget
   - Adicionar animações do logo
   - Configurar timer para transição
   - Integrar no fluxo principal

2. **Completar Registro de Presença**
   - Implementar chamada para `PUT /v1/registro`
   - Adicionar conversão de imagem para base64
   - Implementar validação de tolerâncias
   - Adicionar feedback de sucesso/erro

### Sprint 2 - Interface e UX (1 semana)
3. **Criar Tela de Plantões Completa**
   - Desenvolver `PlantoesList` widget
   - Implementar sistema de cores por status
   - Adicionar filtros por status
   - Criar cards expandíveis para detalhes

4. **Melhorias de UX**
   - Adicionar loading states
   - Melhorar tratamento de erros
   - Implementar validações de formulário
   - Otimizar transições entre telas

### Sprint 3 - Polimento e Testes (1 semana)
5. **Testes e Validação**
   - Testes unitários para controllers
   - Testes de integração com API
   - Validação em dispositivos diferentes
   - Correção de bugs identificados

---

## ✅ CRITÉRIOS DE ACEITAÇÃO PARA MVP

### Tela de Login
- [ ] Usuário consegue selecionar empresa/base de dados
- [ ] Login funciona com credenciais válidas
- [ ] Erro é exibido para credenciais inválidas
- [ ] Sessão é mantida após fechar o app

### Registro de Presença
- [ ] Selfie é capturada com sucesso
- [ ] Localização é validada corretamente
- [ ] Registro é enviado para API com sucesso
- [ ] Tolerâncias de horário são respeitadas
- [ ] Feedback visual é exibido após registro

### Tela de Plantões
- [ ] Plantões são listados com cores corretas
- [ ] Status é calculado corretamente (realizado/não realizado/futuro)
- [ ] Detalhes do plantão são exibidos
- [ ] Filtros funcionam adequadamente

### Splash Screen
- [ ] Animação é exibida por tempo adequado
- [ ] Transição para login é suave
- [ ] Logo e branding estão corretos

---

## 📊 MÉTRICAS DE SUCESSO

- **Funcionalidade:** 100% das features MVP implementadas
- **Performance:** App carrega em menos de 3 segundos
- **Usabilidade:** Fluxo completo sem erros críticos
- **Compatibilidade:** Funciona em Android 5.0+ e iOS 11.0+

---

**Documento criado em:** Setembro 2024  
**Última atualização:** Setembro 2024  
**Próxima revisão:** Após implementação do Sprint 1
