import 'package:flutter/material.dart';
import '../game/fire_on_you_game.dart';

class GameOverMenu extends StatelessWidget {
  final FireOnYouGame game;
  final int score;

  const GameOverMenu({super.key, required this.game, required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Over'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Game Over!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(
              'Your Score: $score',
              style: const TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                game.resetGame(); // Oyunu sıfırla ve yeniden başlat
              },
              child: const Text("Restart"),
            ),
          ],
        ),
      ),
    );
  }
}
