import 'package:hive/hive.dart';

import 'local_profile.dart';

/// TypeAdapter escrito à mão, mesma convenção de [PlantaoAdapter]/
/// [PendingRegistroAdapter] (typeId 0 e 1) — sem build_runner.
class LocalProfileAdapter extends TypeAdapter<LocalProfile> {
  @override
  final int typeId = 2;

  @override
  LocalProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return LocalProfile(
      database: fields[0] as String,
      userId: fields[1] as int,
      nome: fields[2] as String,
      nomeSocial: fields[3] as String?,
      cpf: fields[4] as String,
      email: fields[5] as String,
      baseDisplayName: fields[6] as String,
      preparedAt: fields[7] as DateTime,
      lastValidatedAt: fields[8] as DateTime,
      status: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LocalProfile obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.database)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.nome)
      ..writeByte(3)
      ..write(obj.nomeSocial)
      ..writeByte(4)
      ..write(obj.cpf)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.baseDisplayName)
      ..writeByte(7)
      ..write(obj.preparedAt)
      ..writeByte(8)
      ..write(obj.lastValidatedAt)
      ..writeByte(9)
      ..write(obj.status);
  }
}
