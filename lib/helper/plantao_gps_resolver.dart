import '../model/plantao_model.dart';

/// Decide se o GPS deve ser validado ao iniciar um plantão.
///
/// Regra de negócio: a flag de offline é **por unidade**. Cada plantão
/// carrega a flag da própria unidade; o profissional herda a permissão
/// de offline da unidade em que está batendo, não da anterior.
///
/// Esta função é uma decisão pura: extraída para ser testável sem
/// depender de `Geolocator` (platform channel). A validação em si é
/// feita por `LocationValidatorController`, que já tem testes próprios.
///
/// Contexto do bug (CORINGA-10): se um profissional termina um plantão
/// em unidade offline e emenda um plantão consecutivo em unidade online,
/// o app não pode herdar `null` nas coordenadas — o novo plantão
/// EXIGE GPS. Esta função garante que a decisão é tomada por plantão.
bool deveValidarGpsParaInicio(Plantao plantao) {
  return !plantao.offline;
}
