import 'package:audioplayers/audioplayers.dart';

final fireExtinguish = AssetSource('sounds/fire_extinguish.wav');

enum Sound {
  fireExtinguish,
}

Map<Sound, AssetSource> soundMap = {
  Sound.fireExtinguish: fireExtinguish,
};