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
}
