import 'package:fire_on_you/game/model/fire_type.dart';

class FireFightingTool {
  final String name;
  final FireType effectiveAgainst;
  final Duration cooldown;
  bool _isCoolingDown = false;
  DateTime? _cooldownEnd;

  FireFightingTool({
    required this.name,
    required this.effectiveAgainst,
    required this.cooldown,
  });

  void startCooldown() {
    _isCoolingDown = true;
    _cooldownEnd = DateTime.now().add(cooldown);

    // Cooldown tamamlandığında, yeniden kullanılabilir hale getirin
    Future.delayed(cooldown, () {
      _isCoolingDown = false;
    });
  }

  bool get isInCooldown {
    if (!_isCoolingDown) return false;
    if (_cooldownEnd != null && DateTime.now().isAfter(_cooldownEnd!)) {
      _isCoolingDown = false; // Eğer cooldown süresi dolduysa, soğuma durumunu kaldır
    }
    return _isCoolingDown;
  }

  DateTime get cooldownEnd {
    return _cooldownEnd ?? DateTime.now();
  }

}
