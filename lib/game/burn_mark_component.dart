import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

class BurnMarkComponent extends PositionComponent with HasGameRef {
  late SpriteComponent burnSprite;
  late Paint circlePaint;
  final Vector2 markerPosition;

  BurnMarkComponent(this.markerPosition) {
    position = markerPosition;
    size = Vector2(64, 64); // Yanma izinin boyutu

    // Turuncu daire için Paint ayarları
    circlePaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    burnSprite = SpriteComponent()
      ..sprite = await gameRef.loadSprite('burn_mark.png') // Yanma izi sprite’ı
      ..size = size;

    add(burnSprite);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Yanma izini çiz
    burnSprite.render(canvas);

    // Turuncu daireyi çiz
    canvas.drawCircle(
      size.toOffset() / 2, // Dairenin merkezi
      size.x / 2 + 10, // Dairenin yarıçapı, yanma izinin yarıçapına ek olarak 10 piksel
      circlePaint,
    );
  }
}
