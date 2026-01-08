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

### Build de Release (Play Store) com FVM

Para envio na **Google Play Store**, gere o **Android App Bundle (`.aab`)**:

```bash
fvm flutter clean
fvm flutter pub get
fvm flutter build appbundle --release
```

O arquivo gerado fica em:

```text
build/app/outputs/bundle/release/app-release.aab
```

Se você usa **flavors**, exemplo:

```bash
fvm flutter build appbundle --release --flavor prod -t lib/main_prod.dart
```

Para gerar **APK** (útil para testes, não recomendado para publicação na Play Store):

```bash
fvm flutter build apk --release
```

### Assinatura Android (Keystore) para Release

Para publicar na **Google Play Store**, o app precisa ser gerado em modo **release** e **assinado** com um keystore (normalmente a **upload key**, usando o recurso **Play App Signing** do Google).

Observações sobre o `applicationId`:

- O formato é um identificador no estilo “domínio reverso” (ex.: `com.coringaplus.app`).
- **Não é obrigatório** terminar com `.br`. O requisito é ser **único** na Play Store e seguir as regras de nome de pacote.
- Depois de publicar, **evite trocar** o `applicationId`, pois isso cria um “novo app” (não atualiza o antigo).

1. **Gere o keystore (upload key)**

No Windows (com JDK instalado), rode:

```bash
keytool -genkey -v -keystore android/upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

Se o comando `keytool` não for reconhecido, você precisa:

- Instalar um **JDK** e adicionar `%JAVA_HOME%\\bin` no `PATH`, ou
- Usar o `keytool.exe` que vem com o **Android Studio** (exemplo no PowerShell):

```powershell
& "<CAMINHO_DO_KEYTOOL>" -genkey -v -storetype JKS -keystore android/upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

Exemplos de `<CAMINHO_DO_KEYTOOL>`:

```text
C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe
C:\Program Files\Android\Android Studio1\jbr\bin\keytool.exe
C:\Program Files\Android\jdk\jdk-8.0.302.8-hotspot\jdk8u302-b08\bin\keytool.exe
```

Importante:

- Execute esse comando **direto no PowerShell** (não prefixe com `powershell ...`).
- Se você estiver no **CMD**, rode sem o `&`:

```bat
"<CAMINHO_DO_KEYTOOL>" -genkey -v -storetype JKS -keystore android\upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

Isso vai criar o arquivo `android/upload-keystore.jks` (não commitar).

Você vai informar:

- **Senha do keystore** (store password)
- **Senha da chave** (key password)
- Dados do certificado (CN/OU/O/L/ST/C)

2. **Crie o arquivo `android/key.properties`**

Crie o arquivo `android/key.properties` (não commitar) com o conteúdo:

```properties
storePassword=SUA_STORE_PASSWORD
keyPassword=SUA_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
```

3. **Gere o AAB assinado com FVM**

```bash
fvm flutter clean
fvm flutter pub get
fvm flutter build appbundle --release
```

Se `android/key.properties` existir e estiver correto, o Gradle vai assinar o build de `release` automaticamente.

4. **Envie para a Play Console**

Faça upload do arquivo:

```text
build/app/outputs/bundle/release/app-release.aab
```

Importante:

- **Não perca o keystore e as senhas**. Sem isso você pode perder a capacidade de atualizar o app.
- **Não commite** `android/key.properties` nem arquivos `.jks` no Git.

### � Permissões Necessárias

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
