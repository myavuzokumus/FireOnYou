class Score {
  final String userName;
  final int score;
  final int id;

  Score({required this.userName, required this.score, required this.id});

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      id: json['id'] as int,
      score: json['score'] as int,
      userName: json['userName'] as String,

    );
  }
}
