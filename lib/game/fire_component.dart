import 'package:fire_on_you/game/model/fire_type.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flame/extensions.dart';
import 'fire_on_you_game.dart';

class FireComponent extends PositionComponent with HasGameRef<FireOnYouGame> {
  late SpriteComponent fireSprite;
  late double timeLeft;
  final double timeLimit;
  FireInfo fireInfo;

  FireComponent({
    required Vector2 position,
    required this.timeLimit,
    required this.fireInfo,
  }) {
    this.position = position;
    size = Vector2(64, 64);
    timeLeft = timeLimit;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Yangın türüne göre farklı sprite'lar yüklenebilir
    String spritePath = '';
    switch (fireInfo.type) {
      case FireType.forest:
        spritePath = 'forest_fire.png';
        break;
      case FireType.factory:
        spritePath = 'factory_fire.png';
        break;
      case FireType.house:
        spritePath = 'house_fire.png';
        break;
      case FireType.workplace:
        spritePath = 'workplace_fire.png';
        break;
    }

    fireSprite = SpriteComponent()
      ..sprite = await gameRef.loadSprite(spritePath)
      ..size = size;

    add(fireSprite);
  }

  @override
  void update(double dt) {
    super.update(dt);
    timeLeft -= dt;
    if (timeLeft <= 0) {
      removeFromParent();
      gameRef.decreaseLife();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Circular Progress Indicator çizimi
    final Paint progressPaint = BasicPalette.white.paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    final double progress = timeLeft / timeLimit;
    canvas.drawArc(
      Rect.fromCenter(center: size.toOffset() / 2, width: size.x, height: size.y),
      -1.5,
      progress * 6.28,
      false,
      progressPaint,
    );

    // Şiddet Gücünü Göster
    TextPaint textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.red,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );

    textPaint.render(
      canvas,
      'x${fireInfo.intensity}',
      Vector2(size.x - 20, 30),
    );
  }

  void extinguish() {
    fireInfo.intensity--;
    if (fireInfo.intensity <= 0) {
      removeFromParent();
    }
  }
}
