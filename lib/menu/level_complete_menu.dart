import 'package:flutter/material.dart';
import 'package:fire_on_you/game/fire_on_you_game.dart';

class LevelCompleteMenu extends StatelessWidget {
  final FireOnYouGame game;
  final int score;

  const LevelCompleteMenu({super.key, required this.game, required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level Complete'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Level Complete!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(
              'Score: $score',
              style: const TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                game.loadLevel(game.currentLevel);
              },
              child: const Text('Next Level'),
            ),
          ],
        ),
      ),
    );
  }
}
