import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repository/house_repository.dart';

enum HouseStatus { loading, noHouse, hasHouse }

class HouseState {
  final HouseStatus status;
  final String? houseId;
  final String? houseName;
  final String? inviteCode;
  final String? displayName;
  final String? error;

  const HouseState({
    required this.status,
    this.houseId,
    this.houseName,
    this.inviteCode,
    this.displayName,
    this.error,
  });

  HouseState copyWith({
    HouseStatus? status,
    String? houseId,
    String? houseName,
    String? inviteCode,
    String? displayName,
    String? error,
  }) => HouseState(
    status: status ?? this.status,
    houseId: houseId ?? this.houseId,
    houseName: houseName ?? this.houseName,
    inviteCode: inviteCode ?? this.inviteCode,
    displayName: displayName ?? this.displayName,
    error: error ?? this.error,
  );
}

class HouseNotifier extends StateNotifier<HouseState> {
  final HouseRepository _repo;

  HouseNotifier(this._repo) : super(const HouseState(status: HouseStatus.loading)) {
    _init();
  }

  Future<void> _init() async {
    try {
      await _repo.signInAnonymously();
      final savedId = await _repo.getSavedHouseId();
      if (savedId != null) {
        final info = await _repo.getHouseInfo(savedId);
        if (info != null) {
          final displayName = await _repo.getSavedDisplayName();
          state = HouseState(
            status: HouseStatus.hasHouse,
            houseId: savedId,
            houseName: info['name'] as String?,
            inviteCode: info['invite_code'] as String?,
            displayName: displayName,
          );
          return;
        }
      }
      state = const HouseState(status: HouseStatus.noHouse);
    } catch (e) {
      state = HouseState(status: HouseStatus.noHouse, error: e.toString());
    }
  }

  Future<void> createHouse(String name, String displayName) async {
    state = state.copyWith(status: HouseStatus.loading);
    try {
      final houseId = await _repo.createHouse(name, displayName);
      final info = await _repo.getHouseInfo(houseId);
      state = HouseState(
        status: HouseStatus.hasHouse,
        houseId: houseId,
        houseName: info?['name'] as String?,
        inviteCode: info?['invite_code'] as String?,
        displayName: displayName.trim(),
      );
    } catch (e) {
      final msg = e.toString().contains('houses_name_unique')
          ? 'Já existe uma geladeira com esse nome. Escolha outro.'
          : 'Erro ao criar casa. Tente novamente.';
      state = HouseState(status: HouseStatus.noHouse, error: msg);
    }
  }

  Future<void> joinHouse(String code, String displayName) async {
    state = state.copyWith(status: HouseStatus.loading);
    try {
      final houseId = await _repo.joinHouse(code, displayName);
      final info = await _repo.getHouseInfo(houseId);
      state = HouseState(
        status: HouseStatus.hasHouse,
        houseId: houseId,
        houseName: info?['name'] as String?,
        inviteCode: info?['invite_code'] as String?,
        displayName: displayName.trim(),
      );
    } catch (e) {
      state = HouseState(status: HouseStatus.noHouse, error: 'Código inválido ou erro de conexão');
    }
  }

  Future<void> renameHouse(String newName) async {
    final houseId = state.houseId;
    if (houseId == null) return;
    await _repo.renameHouse(houseId, newName.trim());
    state = state.copyWith(houseName: newName.trim());
  }

  Future<void> deleteHouse() async {
    final houseId = state.houseId;
    if (houseId == null) return;
    await _repo.deleteHouse(houseId);
    state = const HouseState(status: HouseStatus.noHouse);
  }
}
