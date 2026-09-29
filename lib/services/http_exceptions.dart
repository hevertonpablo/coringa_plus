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
class NetworkUnavailableException extends AppHttpException {
  final Object cause;
  NetworkUnavailableException(this.cause)
      : super('Sem conexão ou tempo esgotado: $cause');
}

/// Uma resposta chegou, mas o status HTTP não é 2xx.
class ApiRejectedException extends AppHttpException {
  final int statusCode;
  final String? responseBody;
  ApiRejectedException(this.statusCode, this.responseBody)
      : super('Erro $statusCode do servidor');
}
