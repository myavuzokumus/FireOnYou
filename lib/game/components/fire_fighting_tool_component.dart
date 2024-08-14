// lib/game/fire_fighting_tool_component.dart

import 'package:fire_on_you/game/fire_on_you_game.dart';
import 'package:fire_on_you/game/models/fire_fighting_tool.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class FireFightingToolComponent extends SpriteComponent with HasGameRef<FireOnYouGame> {

  final FireFightingTool tool;
  bool isSelected = false;
  late final Vector2 defaultPosition;
  late Rect cooldownRect;

  FireFightingToolComponent({
    required this.tool,
    required this.defaultPosition,
  }) : super(size: Vector2(64, 64), position: defaultPosition);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite('${tool.name.toLowerCase().replaceAll(' ', '_')}.png');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (tool.isInCooldown) {
      // Cooldown süresi boyunca gri barı göster
      double cooldownProgress = 1 - (tool.cooldownEnd!.difference(DateTime.now()).inMilliseconds / tool.cooldown.inMilliseconds);
      cooldownRect = Rect.fromLTWH(0, size.y * cooldownProgress, size.x, size.y * (1 - cooldownProgress));
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (tool.isInCooldown) {
      final Paint cooldownPaint = Paint()..color = Colors.grey.withOpacity(0.7);
      canvas.drawRect(cooldownRect, cooldownPaint);
    }
  }

  void onSelected() {
    if (!tool.isInCooldown) {
      isSelected = true;
    }
  }

  void resetPosition() {
    position = defaultPosition;
  }

  void reset() {
    isSelected = false;
  }
}