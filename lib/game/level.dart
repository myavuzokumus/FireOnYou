import 'package:flame/components.dart';
import 'package:flame/game.dart';

class Level {
  final List<Vector2> firePositions;

  Level(this.firePositions);

  static List<Level> getLevels() {
    return [
      Level([Vector2(100, 100), Vector2(200, 200)]),
      Level([Vector2(50, 50), Vector2(150, 150), Vector2(250, 250)]),
      // Daha fazla seviye ekleyebilirsiniz
    ];
  }
}
