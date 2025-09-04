# Coringa Plus
## Sistema de Gestão de Plantões Médicos

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.8.1-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-Private-red.svg)]()

O **Coringa Plus** é um aplicativo móvel desenvolvido em Flutter para gestão de plantões médicos, permitindo que profissionais de saúde registrem sua presença através de selfie com validação de geolocalização.

## 📱 Funcionalidades Principais

### 🔐 Autenticação
- Login com matrícula e senha
- Suporte a múltiplas bases de dados/perfis
- Seleção dinâmica de perfil via API
- Persistência de sessão local

### 📅 Gestão de Plantões
- Visualização de plantões agendados
- Identificação automática do próximo plantão
- Informações detalhadas da unidade de saúde
- Controle de horários de entrada e saída

### 📸 Registro de Presença
- Captura de selfie com câmera frontal
- Validação de geolocalização em tempo real
- Verificação de raio permitido por unidade
- Registro com timestamp automático

### 🗓️ Interface Intuitiva
- Navegação por abas (Registrar/Plantões)
- Seletor de datas horizontal
- Design responsivo e moderno
- Feedback visual para todas as ações

## 🏗️ Arquitetura

O projeto segue o padrão **MVC (Model-View-Controller)** com injeção de dependências:

```
lib/
├── controller/          # Lógica de negócio
├── model/              # Modelos de dados
├── pages/              # Telas da aplicação
├── services/           # Serviços e APIs
├── interfaces/         # Contratos e interfaces
└── helper/            # Utilitários
```

### 🔧 Principais Dependências

```yaml
dependencies:
  camera: ^0.11.1          # Captura de imagens
  geolocator: ^14.0.2      # Geolocalização GPS
  http: ^1.4.0             # Requisições HTTP
  shared_preferences: ^2.5.3 # Persistência local
  get_it: ^8.0.3           # Injeção de dependência
  intl: ^0.20.2            # Formatação de datas
```

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK 3.8.1+
- Dart SDK 3.8.1+
- Android Studio / VS Code
- Dispositivo físico ou emulador

### Instalação

1. **Clone o repositório:**
```bash
git clone <repository-url>
cd coringa_plus
```

2. **Instale as dependências:**
```bash
flutter pub get
```

3. **Configure as permissões:**
   - **Android:** Permissões já configuradas no `android/app/src/main/AndroidManifest.xml`
   - **iOS:** Permissões já configuradas no `ios/Runner/Info.plist`

4. **Execute o aplicativo:**
```bash
flutter run
```

### 📱 Permissões Necessárias

O aplicativo requer as seguintes permissões:
- **Câmera:** Para captura de selfies
- **Localização:** Para validação geográfica
- **Internet:** Para comunicação com API
- **Armazenamento:** Para cache de dados

## 🔌 API Endpoints

O aplicativo se comunica com a API através dos seguintes endpoints:

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/v1/dbase` | Buscar perfis/bases disponíveis |
| `POST` | `/v1/login` | Autenticação do usuário |
| `GET` | `/v1/plantoes/{userId}/{baseId}` | Buscar plantões do usuário |

**Base URL:** `https://app.coringaplus.com`

## 🎨 Design System

### Paleta de Cores
- **Primária:** Teal (#009688)
- **Background:** Light Gray (#F5F8FB, #EFF2F7)
- **Texto:** Black87, White
- **Bordas:** Teal outline

### Componentes
- Botões com bordas arredondadas (8px)
- Campos de input com outline teal
- Cards com sombra sutil
- Bottom navigation com ícones intuitivos

## 🔒 Segurança

- Validação de localização obrigatória
- Token de API para autenticação
- Dados sensíveis protegidos localmente
- Comunicação HTTPS com backend

## 📊 Fluxo de Usuário

1. **Login:** Usuário insere credenciais e seleciona perfil
2. **Dashboard:** Visualiza próximo plantão e informações da unidade
3. **Validação:** Sistema verifica localização do usuário
4. **Registro:** Captura selfie se dentro do raio permitido
5. **Confirmação:** Registro salvo com timestamp

## 🧪 Testes

```bash
# Executar testes unitários
flutter test

# Executar testes de integração
flutter drive --target=test_driver/app.dart
```

## 📱 Plataformas Suportadas

- ✅ Android 5.0+ (API 21+)
- ✅ iOS 11.0+
- ✅ Web (PWA)
- ✅ Windows Desktop
- ✅ macOS Desktop
- ✅ Linux Desktop

## 📋 Roadmap

### Versão 1.1
- [ ] Notificações push para lembretes
- [ ] Histórico completo de registros
- [ ] Relatórios de frequência

### Versão 1.2
- [ ] Integração com sistemas hospitalares
- [ ] Reconhecimento facial
- [ ] Dashboard web para gestores

### Versão 2.0
- [ ] Troca de plantões entre profissionais
- [ ] Chat interno
- [ ] Integração com folha de pagamento

## 📚 Documentação Adicional

- [📋 PRD - Product Requirements Document](./PRD.md)
- [👥 Windsurf Roles - Papéis da Equipe](./windsurfroles.md)
- [🏗️ Arquitetura Técnica](./docs/architecture.md)
- [🎨 Design Guidelines](./docs/design.md)

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto é propriedade privada. Todos os direitos reservados.

## 📞 Suporte

Para suporte técnico ou dúvidas sobre o projeto:
- 📧 Email: suporte@coringaplus.com
- 🌐 Website: https://app.coringaplus.com
- 📱 WhatsApp: +55 (11) 9999-9999

---

**Desenvolvido com ❤️ pela equipe Coringa Plus**
