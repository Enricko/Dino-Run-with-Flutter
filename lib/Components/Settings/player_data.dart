import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import "package:firebase_database/firebase_database.dart";


part 'player_data.g.dart';

// This class stores the player progress presistently.
@HiveType(typeId: 0)
class PlayerData extends ChangeNotifier with HiveObjectMixin {
  @HiveField(1)
  int highScore = 0;

  int _lives = 5;

  int get lives => _lives;
  set lives(int value) {
    if (value <= 5 && value >= 0) {
      _lives = value;
      notifyListeners();
    }
  }

  int _currentScore = 0;

  int get currentScore => _currentScore;
  set currentScore(int value) {
    _currentScore = value;

    if (highScore < _currentScore) {
      highScore = _currentScore;
      
      if(FirebaseAuth.instance.currentUser != null){
        try {
          FirebaseDatabase.instance
          .ref()
          .child('LeaderBoard')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .set({
            'highScore':highScore,
            'name': FirebaseAuth.instance.currentUser!.displayName,
            'image':FirebaseAuth.instance.currentUser!.photoURL,
          });
        } catch (e) {
          print(e);
        }
      }
    }

    notifyListeners();
    save();
  }

  int _scoreUntilHeal = 0;

  int get scoreUntilHeal => _scoreUntilHeal;
  set scoreUntilHeal(int value) {
    _scoreUntilHeal = value;

    if (_scoreUntilHeal >= 10) {
      _scoreUntilHeal = 0;
      if(lives < 5) {
        lives += 1;
      }
    }

    notifyListeners();
    save();
  }
}