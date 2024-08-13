import 'package:fire_on_you/game/burn_mark_component.dart';
import 'package:fire_on_you/game/model/fire_type.dart';
import 'package:fire_on_you/game/sounds.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flame/extensions.dart';
import 'fire_on_you_game.dart';
import 'dart:math';

class FireComponent extends PositionComponent with HasGameRef<FireOnYouGame> {
  late SpriteComponent fireSprite;
  late double timeLeft;
  late final double timeLimit;
  FireInfo fireInfo;
  final Vector2 firePosition;

  FireComponent({
    required this.firePosition,
    required this.fireInfo,
  }) {
    position = firePosition;
    size = Vector2(64, 64);
    timeLimit = _getTimeLimitForFireType(fireInfo.type);
    timeLeft = timeLimit;
  }

  // Yangın türüne göre süre belirleme
  double _getTimeLimitForFireType(FireType type) {
    switch (type) {
      case FireType.forest:
        return Random().nextInt(5) + 5; // Orman yangınları için daha uzun süre
      case FireType.factory:
        return Random().nextInt(3) + 5;
      case FireType.house:
        return Random().nextInt(3) + 3; // Ev yangınları için daha kısa süre
      case FireType.workplace:
        return Random().nextInt(4) + 3;
      default:
        return 5.0;
    }
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

      BurnMarkComponent mark = BurnMarkComponent(firePosition);
      gameRef.add(mark); // Yan
      gameRef.burnMarks.add(mark);

      removeFromParent();
      gameRef.decreaseLife();
      gameRef.fires.remove(this);

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

  void extinguishImmediately() {
    gameRef.score += 100;
    gameRef.audioPlayer.play(soundMap[Sound.fireExtinguish]!);
    // Yangını anında söndür
    removeFromParent();
    // Eğer oyun içerisinde yangın listesi varsa, buradan da kaldırın
    gameRef.fires.remove(this);
  }

  void reduceTimeByHalf() {
    // Yangının kalan süresini yarıya indir
    timeLeft = timeLeft / 2;
  }

  void extinguish() {
    fireInfo.intensity--;
    if (fireInfo.intensity <= 0) {
      removeFromParent();
    }
  }
}
