import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_game_firebase/Components/Settings/Audio_Manager.dart';
import 'package:flutter_game_firebase/Components/Settings/player_data.dart';
import 'package:flutter_game_firebase/Components/UI/Hud.dart';
import 'package:flutter_game_firebase/Components/UI/MainMenu.dart';
import 'package:flutter_game_firebase/main.dart';
import 'package:provider/provider.dart';

class GameOverMenus extends StatelessWidget {
  static const id = 'GameOverMenus';
  final MyGame gameRef;
  const GameOverMenus(this.gameRef,{super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: gameRef.playerData,
      child: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.black.withAlpha(100),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 100),
                child: Wrap(
                  direction: Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    const Text(
                      'Game Over',
                      style: TextStyle(fontSize: 40, color: Colors.white),
                    ),
                    Selector<PlayerData, int>(
                      selector: (_, playerData) => playerData.currentScore,
                      builder: (_, score, __) {
                        return Text(
                          'You Score: $score',
                          style: const TextStyle(
                              fontSize: 40, color: Colors.white),
                        );
                      },
                    ),
                    ElevatedButton(
                      child: const Text(
                        'Restart',
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                      onPressed: () {
                        try{
                          gameRef.overlays.remove(GameOverMenus.id);
                          gameRef.overlays.add(Hud.id);
                          gameRef.resumeEngine();
                          gameRef.reset();
                          gameRef.startGamePlay();
                          AudioManager.instance.resumeBgm();
                        }catch (e){
                          print(e);
                          print('asdad');
                        }
                      },
                    ),
                    ElevatedButton(
                      child: const Text(
                        'Exit',
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                      onPressed: () {
                        gameRef.overlays.remove(GameOverMenus.id);
                        gameRef.overlays.add(MainMenu.id);
                        gameRef.resumeEngine();
                        gameRef.reset();
                        AudioManager.instance.resumeBgm();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}