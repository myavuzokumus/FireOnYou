import 'dart:convert';

import 'package:fire_on_you/const.dart';
import 'package:fire_on_you/game/fire_on_you_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NameInputMenu extends StatelessWidget {

  NameInputMenu({super.key});

  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Your Name'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String playerName = nameController.text.trim();
                if (playerName.isNotEmpty) {
                  // İsmi oyuna başlat ve ismi bir sonraki ekrana ilet

                  int id = await createUser(playerName);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameWidget(
                        game: FireOnYouGame(context, playerId: id),
                      ),
                    ),
                  );
                } else {
                  // Boş isim girildiğinde uyarı göster
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid name')),
                  );
                }
              },
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }

  Future<int> createUser(String playerName) async {
    try {
      final response = await http.post(
        headers: {
          'Content-Type': 'application/json',
        },
        Uri.parse('$SERVER_URL/api/users'),
        body: jsonEncode({
          'userName': playerName, // Kullanıcı adı, backend'de bir ID ile ilişkilendirilecek
        }),
      );

      if (response.statusCode == 201) {
        print('Name submitted successfully');
        return int.parse(response.body);
      } else {
        throw('Failed to submit name #${response.statusCode}');
      }
    } catch (e) {
      throw('Error sending name: $e');
    }
  }

}
