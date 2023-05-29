import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_game_firebase/Components/Settings/Audio_Manager.dart';
import 'package:flutter_game_firebase/Components/Settings/settings.dart';
import 'package:flutter_game_firebase/Components/UI/MainMenu.dart';
import 'package:flutter_game_firebase/main.dart';
import 'package:provider/provider.dart';

class SettingsMenu extends StatelessWidget {
  static const id = 'SettingsMenu';
  final MyGame gameRef;

  const SettingsMenu(this.gameRef,{super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: gameRef.settings,
      child: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              color: Colors.black.withAlpha(100),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: (MediaQuery.of(context).size.width <= 425 ? 10 : 80)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Selector<Settings, bool>(
                          selector: (_, settings) => settings.bgm,
                          builder: (context, bgm, __) {
                            return SwitchListTile(
                              activeColor: Colors.grey,
                              title: const Text(
                                'Music',
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                ),
                              ),
                              value: bgm,
                              onChanged: (bool value) {
                                Provider.of<Settings>(context, listen: false).bgm =
                                    value;
                                if (value) {
                                  AudioManager.instance
                                      .startBgm('8BitPlatformerLoop.wav');
                                } else {
                                  AudioManager.instance.stopBgm();
                                }
                              },
                            );
                          },
                        ),
                        Selector<Settings, bool>(
                          selector: (_, settings) => settings.sfx,
                          builder: (context, sfx, __) {
                            return SwitchListTile(
                              activeColor: Colors.grey,
                              title: const Text(
                                'Effects',
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                ),
                              ),
                              value: sfx,
                              onChanged: (bool value) {
                                Provider.of<Settings>(context, listen: false).sfx =
                                    value;
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 5,
                    child: TextButton(
                      onPressed: () {
                        gameRef.overlays.remove(SettingsMenu.id);
                        gameRef.overlays.add(MainMenu.id);
                      },
                      child: const Icon(Icons.arrow_back_ios_rounded,color: Colors.white70,size: 40,),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}