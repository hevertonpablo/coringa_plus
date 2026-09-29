import 'package:coringa_plus/model/pending_registro.dart';
import 'package:coringa_plus/services/sync_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('groupPendingByTenant', () {
    PendingRegistro registro({
      required String id,
      required String database,
      required int userId,
      required int plantaoId,
      DateTime? createdAt,
    }) {
      return PendingRegistro(
        id: id,
        plantaoId: plantaoId,
        tipo: 'E',
        dataHora: DateTime(2026, 1, 1),
        database: database,
        userId: userId,
        selfiePath: '/tmp/$id.jpg',
        createdAt: createdAt ?? DateTime(2026, 1, 1),
      );
    }

    test('agrupa por (database, userId), nunca misturando tenants', () {
      final pendentes = [
        registro(id: 'a1', database: '1', userId: 9, plantaoId: 100),
        registro(id: 'a2', database: '1', userId: 9, plantaoId: 101),
        registro(id: 'b1', database: '99', userId: 9, plantaoId: 200),
        registro(id: 'c1', database: '1', userId: 42, plantaoId: 300),
      ];

      final grupos = groupPendingByTenant(pendentes);

      expect(grupos.length, 3);
      expect(grupos[('1', 9)]?.map((r) => r.id).toList(), ['a1', 'a2']);
      expect(grupos[('99', 9)]?.map((r) => r.id).toList(), ['b1']);
      expect(grupos[('1', 42)]?.map((r) => r.id).toList(), ['c1']);
    });

    test('mesmo database com userId diferente nunca cai no mesmo grupo '
        '(isolamento por usuário, não só por base)', () {
      final pendentes = [
        registro(id: 'x', database: '1', userId: 1, plantaoId: 1),
        registro(id: 'y', database: '1', userId: 2, plantaoId: 1),
      ];

      final grupos = groupPendingByTenant(pendentes);

      expect(grupos.length, 2);
      expect(grupos[('1', 1)]!.single.id, 'x');
      expect(grupos[('1', 2)]!.single.id, 'y');
    });

    test('lista vazia retorna mapa vazio', () {
      expect(groupPendingByTenant([]), isEmpty);
    });
  });
}
