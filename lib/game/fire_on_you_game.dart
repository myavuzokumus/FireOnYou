import 'dart:math';
import 'dart:async' as timer;
import 'package:fire_on_you/game/model/fire_type.dart';
import 'package:fire_on_you/menu/game_over_menu.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'fire_component.dart';

class FireOnYouGame extends FlameGame with TapDetector {
  late List<FireComponent> fires;
  int score = 0;
  int lives = 3;
  late AudioPlayer audioPlayer;
  Random random = Random();
  final BuildContext context;

  FireOnYouGame(this.context);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    audioPlayer = AudioPlayer();
    fires = [];
    spawnFires();
  }

  void spawnFires() {
    timer.Timer.periodic(Duration(seconds: random.nextInt(3) + 1), (timer) {
      if (lives <= 0) {
        timer.cancel();
        return;
      }
      final position = Vector2(
        random.nextDouble() * (size.x - 64),
        random.nextDouble() * (size.y - 64),
      );
      final fireInfo = getRandomFireInfo(); // Yangın türünü ve şiddetini al
      final fire = FireComponent(position: position, timeLimit: random.nextInt(5) + 3, fireInfo: fireInfo);
      add(fire);
      fires.add(fire);
    });
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Puanı ve hakları ekranda göster
    TextPaint tp = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
      ),
    );
    tp.render(canvas, 'Score: $score', Vector2(10, 10));
    tp.render(canvas, 'Lives: $lives', Vector2(10, 40));
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Eğer haklar biterse oyun sona erecek
    if (lives <= 0) {
      pauseEngine();
      showGameOverScreen();
    }
  }

  void showGameOverScreen() {
    // Oyun bittiğinde skorun gösterileceği ekran
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameOverMenu(game: this, score: score),
      ),
    );
  }

  @override
  void onTapDown(TapDownInfo info) {
    for (var fire in fires) {
      if (fire.containsPoint(info.eventPosition.global)) {
        fire.extinguish();
        if (fire.fireInfo.intensity <= 0) {
          score += 100;
          audioPlayer.play(AssetSource('sounds/fire_extinguish.wav'));
        }
        break;
      }
    }
  }

  void decreaseLife() {
    lives--;
  }

  // Oyunu sıfırla
  void resetGame() {
    score = 0;
    lives = 3;
    fires.forEach((fire) => fire.removeFromParent());
    fires.clear();
    resumeEngine();
    spawnFires();
  }
}
