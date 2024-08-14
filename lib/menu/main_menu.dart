import 'package:fire_on_you/const.dart';
import 'package:fire_on_you/menu/name_input_menu.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/score.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  List<Score> scores = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchScores();
  }

  Future<void> fetchScores() async {

    setState(() {
      isLoading = true; // Yükleme göstergesi için isLoading'i true yap
    });

    try {
      final response = await http.get(Uri.parse('$SERVER_URL/api/scores'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          scores = data.map((json) => Score.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load scores');
      }
    } catch (e) {
      print('Error fetching scores: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fire On You'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NameInputMenu(),
                  ),
                );
              },
              child: const Text('Start Game'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchScores, // Yenileme butonuna tıklandığında verileri yeniden yükle
              child: const Text('Refresh Scores'),
            ),
            isLoading
                ? const CircularProgressIndicator()
                : Expanded(
              child: RefreshIndicator(
                onRefresh: fetchScores, // Yukarıdan çekildiğinde çağrılacak
                child: scores.isNotEmpty
                    ? ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(), // Her zaman kaydırılabilir
                  shrinkWrap: true, // ListView içeriği kadar yer kaplar
                  itemCount: scores.length,
                  itemBuilder: (context, index) {
                    final score = scores[index];
                    return ListTile(
                      title: Text(score.userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      trailing: Text(score.score.toString()),
                    );
                  },
                )
                    : ListView(
                  children: const [
                    Center(child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No scores available'),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
