import 'package:hive/hive.dart';

import 'plantao_model.dart';

/// TypeAdapter do Hive escrito à mão (sem build_runner/hive_generator, para
/// seguir a convenção do projeto de não usar codegen). Serializa cada campo
/// por índice fixo; `offline` foi adicionado por último para preservar a
/// posição dos campos já existentes.
class PlantaoAdapter extends TypeAdapter<Plantao> {
  @override
  final int typeId = 0;

  @override
  Plantao read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Plantao(
      plantaoId: fields[0] as int,
      unidade: fields[1] as String,
      unidadeLongitude: fields[2] as String,
      unidadeLatitude: fields[3] as String,
      unidadeRaio: fields[4] as int,
      unidadeEndereco: fields[5] as String,
      nome: fields[6] as String,
      nomeSocial: fields[7] as String?,
      especialidade: fields[8] as String,
      setor: fields[9] as String,
      horasPlantao: fields[10] as int,
      turno: fields[11] as String,
      dtEntrada: fields[12] as DateTime,
      dtSaida: fields[13] as DateTime,
      dtEntradaPonto: fields[14] as DateTime?,
      dtSaidaPonto: fields[15] as DateTime?,
      toleranciaAntecipada: fields[16] as int?,
      toleranciaAtraso: fields[17] as int?,
      permiteRegistroAtraso: fields[18] as bool,
      offline: fields[19] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Plantao obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.plantaoId)
      ..writeByte(1)
      ..write(obj.unidade)
      ..writeByte(2)
      ..write(obj.unidadeLongitude)
      ..writeByte(3)
      ..write(obj.unidadeLatitude)
      ..writeByte(4)
      ..write(obj.unidadeRaio)
      ..writeByte(5)
      ..write(obj.unidadeEndereco)
      ..writeByte(6)
      ..write(obj.nome)
      ..writeByte(7)
      ..write(obj.nomeSocial)
      ..writeByte(8)
      ..write(obj.especialidade)
      ..writeByte(9)
      ..write(obj.setor)
      ..writeByte(10)
      ..write(obj.horasPlantao)
      ..writeByte(11)
      ..write(obj.turno)
      ..writeByte(12)
      ..write(obj.dtEntrada)
      ..writeByte(13)
      ..write(obj.dtSaida)
      ..writeByte(14)
      ..write(obj.dtEntradaPonto)
      ..writeByte(15)
      ..write(obj.dtSaidaPonto)
      ..writeByte(16)
      ..write(obj.toleranciaAntecipada)
      ..writeByte(17)
      ..write(obj.toleranciaAtraso)
      ..writeByte(18)
      ..write(obj.permiteRegistroAtraso)
      ..writeByte(19)
      ..write(obj.offline);
  }
}
