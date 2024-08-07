import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../menu/level_complete_menu.dart';
import 'level.dart';

class FireOnYouGame extends FlameGame with TapDetector {
  late List<Level> levels;
  int currentLevel = 0;
  late List<SpriteComponent> fires;
  int score = 0;
  late AudioPlayer audioPlayer;
  final BuildContext context;

  FireOnYouGame(this.context);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    levels = Level.getLevels();
    audioPlayer = AudioPlayer();
    await loadLevel(currentLevel);
  }

  Future<void> loadLevel(int levelIndex) async {
    fires = [];
    for (var position in levels[levelIndex].firePositions) {
      final fire = SpriteComponent()
        ..sprite = await loadSprite('fire.png')
        ..size = Vector2(64, 64)
        ..position = position;
      add(fire);
      fires.add(fire);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Puanı ekranda göster
    TextPaint tp = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
      ),
    );
    tp.render(canvas, 'Score: $score', Vector2(10, 10));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (fires.isEmpty) {
      // Tüm yangınlar söndürüldü, bir sonraki seviyeye geç
      currentLevel = (currentLevel + 1) % levels.length;
      pauseEngine();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LevelCompleteMenu(game: this, score: score),
        ),
      );
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    for (var fire in fires) {
      if (fire.containsPoint(info.eventPosition.global)) {
        fire.removeFromParent();
        fires.remove(fire);
        score += 100; // Yangın söndürme puanı
        // Ses efekti oynat
        audioPlayer.play(AssetSource('sounds/fire_extinguish.wav'));
        break;
      }
    }
  }
}
