import 'dart:math';

enum FireType {
  forest,
  factory,
  house,
  workplace
}

class FireInfo {
  final FireType type;
  int intensity;

  FireInfo(this.type, this.intensity);
}

FireInfo getRandomFireInfo() {
  final random = Random();
  const fireTypes = FireType.values;
  final fireType = fireTypes[random.nextInt(fireTypes.length)];
  int intensity;

  switch (fireType) {
    case FireType.forest:
      intensity = random.nextInt(3) + 3; // 3 ile 5 arasında bir şiddet
      break;
    case FireType.factory:
      intensity = random.nextInt(3) + 2; // 2 ile 4 arasında bir şiddet
      break;
    case FireType.house:
      intensity = random.nextInt(3) + 1; // 1 ile 3 arasında bir şiddet
      break;
    case FireType.workplace:
      intensity = random.nextInt(3) + 2; // 2 ile 4 arasında bir şiddet
      break;
  }

  return FireInfo(fireType, intensity);
}
