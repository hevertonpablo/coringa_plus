import 'package:hive/hive.dart';

import 'pending_registro.dart';

/// TypeAdapter escrito à mão, mesma convenção de [PlantaoAdapter]
/// (ver lib/model/plantao_model_adapter.dart) — sem build_runner.
class PendingRegistroAdapter extends TypeAdapter<PendingRegistro> {
  @override
  final int typeId = 1;

  @override
  PendingRegistro read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return PendingRegistro(
      id: fields[0] as String,
      plantaoId: fields[1] as int,
      tipo: fields[2] as String,
      dataHora: fields[3] as DateTime,
      database: fields[4] as String,
      userId: fields[5] as int,
      selfiePath: fields[6] as String,
      status: fields[7] as String,
      attempts: fields[8] as int,
      createdAt: fields[9] as DateTime,
      lastErrorMessage: fields[10] as String?,
      syncedAt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PendingRegistro obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.plantaoId)
      ..writeByte(2)
      ..write(obj.tipo)
      ..writeByte(3)
      ..write(obj.dataHora)
      ..writeByte(4)
      ..write(obj.database)
      ..writeByte(5)
      ..write(obj.userId)
      ..writeByte(6)
      ..write(obj.selfiePath)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.attempts)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.lastErrorMessage)
      ..writeByte(11)
      ..write(obj.syncedAt);
  }
}
