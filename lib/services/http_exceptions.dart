/// Exceções tipadas para distinguir "sem internet" de "o servidor
/// respondeu e rejeitou a chamada" — necessário para não confundir falha
/// de rede com acesso revogado/credenciais inválidas na revalidação
/// multi-tenant (ver `PlantaoRepository.revalidarAutorizacao`).
sealed class AppHttpException implements Exception {
  final String message;
  const AppHttpException(this.message);

  @override
  String toString() => message;
}

/// Nenhuma resposta chegou do servidor: sem sinal, timeout, DNS, etc. Por
/// definição, uma falha *antes* de obter uma resposta nunca é uma rejeição
/// do servidor.
///
/// A mensagem é propositalmente amigável (sem embutir `cause`, que pode ser
/// um `SocketException`/`ClientException` técnico) porque esta exceção
/// costuma ser mostrada direto ao usuário via `.toString()`; o detalhe
/// técnico já vai para o Crashlytics separadamente (`recordApiError`).
class NetworkUnavailableException extends AppHttpException {
  final Object cause;
  NetworkUnavailableException(this.cause)
      : super('Sem conexão com a internet. Verifique sua conexão e tente novamente.');
}

/// Uma resposta chegou, mas o status HTTP não é 2xx.
class ApiRejectedException extends AppHttpException {
  final int statusCode;
  final String? responseBody;
  ApiRejectedException(this.statusCode, this.responseBody)
      : super('Erro $statusCode do servidor');

  /// CORINGA-15: distingue "acesso revogado" (o token global ou a
  /// autorização da base não vale mais — profile inteiro some do
  /// seletor) de "erro de validação desta batida" (400/404 — só esta
  /// tentativa falhou, o profile continua válido).
  ///
  /// Heurística verificada via curl real (out/2026) no backend
  /// `app.coringaplus.com`:
  ///   - 401 → body `{"status":"error","data":"Erro de autorização"}`
  ///   - 403 → (convenção HTTP; aceito defensivamente)
  ///   - 400/404/422 → body
  ///     `{"status":"success","data":{"error":{"code":404,...}}}`
  ///     (erro de negócio, NÃO de auth)
  ///
  /// Usado em:
  ///   - `RegistroRepository._isAccessRevoked` → decide se marca
  ///     o profile como `'revoked'` no Hive
  ///   - `SelfieCaptureScreen._isAccessRevoked` → decide se mostra
  ///     o modal "Acesso revogado" + `popUntil(isFirst)` ou o snackbar
  ///     genérico
  bool get isAccessRevoked {
    if (statusCode == 401 || statusCode == 403) return true;
    // Defesa em profundidade: alguns backends embrulham a falha de
    // auth num 200/400 com `status:"error"` no body. Se o body
    // contiver "autoriza" (Erro de autorização / Unauthorized / ...),
    // ainda tratamos como revoked.
    final body = responseBody ?? '';
    return body.contains('"status":"error"') && body.contains('autoriza');
  }
}
