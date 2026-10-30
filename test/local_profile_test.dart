import 'package:coringa_plus/model/local_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalProfile.effectiveStatus', () {
    LocalProfile perfil({required DateTime lastValidatedAt, String status = 'active'}) {
      return LocalProfile(
        database: '99',
        userId: 9,
        nome: 'Profissional Teste',
        cpf: '12345678900',
        email: 'teste@example.com',
        baseDisplayName: 'APP',
        preparedAt: lastValidatedAt,
        lastValidatedAt: lastValidatedAt,
        status: status,
      );
    }

    test('dentro da janela de 30 dias continua active', () {
      final agora = DateTime(2026, 1, 31);
      final p = perfil(lastValidatedAt: agora.subtract(const Duration(days: 29, hours: 23)));
      expect(p.effectiveStatus(agora), 'active');
    });

    test('exatamente 30 dias ainda é active (limite inclusivo)', () {
      final agora = DateTime(2026, 1, 31);
      final p = perfil(lastValidatedAt: agora.subtract(const Duration(days: 30)));
      expect(p.effectiveStatus(agora), 'active');
    });

    test('mais de 30 dias sem revalidação vira locked_stale', () {
      final agora = DateTime(2026, 1, 31);
      final p = perfil(
        lastValidatedAt: agora.subtract(const Duration(days: 30, minutes: 1)),
      );
      expect(p.effectiveStatus(agora), 'locked_stale');
    });

    test('status revoked sempre vence, mesmo recém-validado', () {
      final agora = DateTime(2026, 1, 31);
      final p = perfil(lastValidatedAt: agora, status: 'revoked');
      expect(p.effectiveStatus(agora), 'revoked');
    });

    test('revoked vence mesmo com lastValidatedAt muito antigo', () {
      final agora = DateTime(2026, 1, 31);
      final p = perfil(
        lastValidatedAt: agora.subtract(const Duration(days: 400)),
        status: 'revoked',
      );
      expect(p.effectiveStatus(agora), 'revoked');
    });
  });

  group('LocalProfile.copyWith', () {
    test('preserva database/userId/cpf/preparedAt (identidade do perfil)', () {
      final preparedAt = DateTime(2026, 1, 1);
      final original = LocalProfile(
        database: '99',
        userId: 9,
        nome: 'Nome Original',
        cpf: '12345678900',
        email: 'a@a.com',
        baseDisplayName: 'APP',
        preparedAt: preparedAt,
        lastValidatedAt: preparedAt,
      );

      final atualizado = original.copyWith(
        status: 'revoked',
        lastValidatedAt: DateTime(2026, 2, 1),
      );

      expect(atualizado.database, '99');
      expect(atualizado.userId, 9);
      expect(atualizado.cpf, '12345678900');
      expect(atualizado.preparedAt, preparedAt);
      expect(atualizado.status, 'revoked');
      expect(atualizado.lastValidatedAt, DateTime(2026, 2, 1));
    });
  });
}
