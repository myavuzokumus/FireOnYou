import 'dart:convert';

import 'package:fire_on_you/const.dart';
import 'package:flutter/material.dart';
import '../game/fire_on_you_game.dart';
import 'package:http/http.dart' as http;

class GameOverMenu extends StatelessWidget {
  final FireOnYouGame game;
  final int score;
  final int playerId;

  const GameOverMenu({super.key, required this.game, required this.score, required this.playerId});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, result) async {
        game.resetGame();
      },
      child: Scaffold(
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
              FutureBuilder(
                future: sendScoreToBackend(score),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  return ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Restart")
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendScoreToBackend(int score) async {
    try {
      final response = await http.post(
        headers: {
          'Content-Type': 'application/json',
        },
        Uri.parse('$SERVER_URL/api/scores'),
        body: jsonEncode({
          'userId': playerId,
          'score': score,
        }),
      );

      if (response.statusCode == 200) {
        print('Score submitted successfully');
      } else {
        throw('Failed to submit score #${response.statusCode}');
      }
    } catch (e) {
      throw('Error sending score: $e');
    }
  }
}