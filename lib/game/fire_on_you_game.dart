import 'dart:async' as timer;
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:fire_on_you/game/components/burn_mark_component.dart';
import 'package:fire_on_you/game/components/fire_component.dart';
import 'package:fire_on_you/game/components/fire_fighting_tool_component.dart';
import 'package:fire_on_you/game/models/fire_fighting_tool.dart';
import 'package:fire_on_you/game/models/fire_type.dart';
import 'package:fire_on_you/menu/game_over_menu.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';


class FireOnYouGame extends FlameGame with TapDetector, PanDetector {
  late List<FireComponent> fires;
  late List<FireFightingToolComponent> tools; // Eklenecek araçlar
  FireFightingToolComponent? selectedTool; // Seçili aracı takip etmek için
  int score = 0;
  int lives = 3;
  late AudioPlayer audioPlayer;
  Random random = Random();
  final BuildContext context;
  final int playerId;

  // Söndürülemeyen ateşlerin konumlarını saklayan liste
  final List<BurnMarkComponent> burnMarks = [];

  FireOnYouGame(this.context, {required this.playerId});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    audioPlayer = AudioPlayer();
    fires = [];
    spawnFires();
    addTools();
  }

  void spawnFires() {
    timer.Timer.periodic(Duration(seconds: _getSpawnInterval()), (timer) {
      if (lives <= 0) {
        timer.cancel();
        return;
      }

      Vector2 position;
      do {
        position = Vector2(
          random.nextDouble() * (size.x - 64),
          random.nextDouble() * (size.y - 64),
        );
      } while (_isTooCloseToFailedFires(position)); // Yeni ateşin uzaklığını kontrol et

      final fireInfo = getRandomFireInfo(); // Yangın türünü ve şiddetini al
      final fire = FireComponent(firePosition: position, fireInfo: fireInfo);
      add(fire);
      fires.add(fire);
    });
  }

  // Skora bağlı olarak ateşlerin çıkma sıklığını belirleme
  int _getSpawnInterval() {
    const int scoreThreshold = 500; // Skor eşiği
    const int minInterval = 1; // Minimum zaman aralığı (saniye)
    const int maxInterval = 4; // Maksimum zaman aralığı (saniye)

    // Skora bağlı olarak zaman aralığını belirle
    double interval = maxInterval - (score / scoreThreshold) * (maxInterval - minInterval);
    return interval.clamp(minInterval.toDouble(), maxInterval.toDouble()).toInt();
  }

  bool _isTooCloseToFailedFires(Vector2 newPosition) {
    const double safeDistance = 100.0; // Güvenli mesafe (örneğin 100 piksel)
    for (var failedPosition in burnMarks) {
      if (failedPosition.markerPosition.distanceTo(newPosition) < safeDistance) {
        return true; // Eğer yeni ateş konumu herhangi bir başarısız konuma çok yakınsa, true döndür
      }
    }
    return false; // Uzaksa, false döndür
  }

  void addTools() {
    // Araçları tanımlama ve ekleme
    tools = [
      FireFightingToolComponent(
        tool: FireFightingTool(
          name: 'Water Hose',
          effectiveAgainst: FireType.house,
          cooldown: const Duration(seconds: 5),
        ),
        defaultPosition: Vector2(50, size.y - 100),
      ),
      FireFightingToolComponent(
        tool: FireFightingTool(
          name: 'Fire Extinguisher',
          effectiveAgainst: FireType.workplace,
          cooldown: const Duration(seconds: 5),
        ),
        defaultPosition: Vector2(150, size.y - 100),
      ),
      FireFightingToolComponent(
        tool: FireFightingTool(
          name: 'Fire Truck',
          effectiveAgainst: FireType.factory,
          cooldown: const Duration(seconds: 7),
        ),
        defaultPosition: Vector2(250, size.y - 100),
      ),
      FireFightingToolComponent(
        tool: FireFightingTool(
          name: 'Fire Plane',
          effectiveAgainst: FireType.forest,
          cooldown: const Duration(seconds: 10),
        ),
        defaultPosition: Vector2(350, size.y - 100),
      ),
    ];

    for (var tool in tools) {
      add(tool);
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (selectedTool != null && !selectedTool!.tool.isInCooldown) {
      selectedTool!.position += info.delta.global;
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (selectedTool != null) {
      bool toolUsed = false;
      for (var fire in fires) {
        if (fire.toRect().overlaps(selectedTool!.toRect())) {
          if (fire.fireInfo.type == selectedTool!.tool.effectiveAgainst) {
            // Doğru araç doğru yangın için kullanıldı
            fire.extinguishImmediately();
            toolUsed = true;
          } else {
            // Yanlış araç kullanıldı, süreyi azalt
            fire.reduceTimeByHalf();
          }
          break;
        }
      }
      if (toolUsed) {
        selectedTool!.tool.startCooldown(); // Aracı soğuma süresine sok
      }
      selectedTool!.resetPosition(); // Aracı eski konumuna getir
      selectedTool = null; // Seçili aracı temizle
    }
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
        builder: (context) => GameOverMenu(
          game: this,
          score: score,
          playerId: playerId// Pass the resetGame method as the callback
        ),
      ),
    );
  }

  @override
  void onTapDown(TapDownInfo info) {

    for (var tool in tools) {
      if (tool.containsPoint(info.eventPosition.global)) {
        tool.onSelected(); // Araç seçildiğinde
        break;
      }
    }

    for (var fire in fires) {
      if (fire.containsPoint(info.eventPosition.global)) {
        fire.extinguish();
        if (fire.fireInfo.intensity <= 0) {
          fire.extinguishImmediately();
        }
        break;
      }
    }

    for (var tool in tools) {
      if (tool.containsPoint(info.eventPosition.global)) {
        selectedTool = tool;
        tool.onSelected();
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
    burnMarks.forEach((mark) => mark.removeFromParent()); // BurnMark'ları temizle
    burnMarks.clear();
    fires.clear();
    tools.forEach((tool) => tool.reset());
    resumeEngine();
    spawnFires();
  }
}
