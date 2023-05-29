import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game_firebase/Components/Firebase/FirebaseAuthService.dart';
import 'package:flutter_game_firebase/Components/Settings/player_data.dart';
import 'package:flutter_game_firebase/Components/UI/Hud.dart';
import 'package:flutter_game_firebase/Components/UI/LeaderBoard.dart';
import 'package:flutter_game_firebase/Components/UI/SettingsMenu.dart';
import 'package:flutter_game_firebase/main.dart';
import 'package:provider/provider.dart';


// This represents the main menu overlay.
class MainMenu extends StatefulWidget {
  // An unique identified for this overlay.
  static const id = 'MainMenu';

  // Reference to parent game.
  final MyGame gameRef;

  const MainMenu(this.gameRef,{super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  bool onHoverPlay = false;
  
  @override
  Widget build(BuildContext context) {
    
  // print(FirebaseAuth.instance.currentUser);
    return ChangeNotifierProvider.value(
      value: widget.gameRef.playerData,
      child: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.only(bottom: 100),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                        margin: EdgeInsets.only(bottom: 30),
                          child: Column(
                            children: [
                              Icon(
                                Icons.emoji_events_rounded,
                                size: 40,
                                color: Colors.white70,
                              ),
                              Selector<PlayerData, int>(
                                selector: (_, playerData) => playerData.highScore,
                                builder: (_, score, __) {
                                  return Text(
                                    '$score',
                                    style: const TextStyle(fontSize: 24, color: Colors.white),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          'Dino Run',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 65,
                            fontFamily: 'Audiowide',
                            fontWeight: FontWeight.w900
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 25),
                        decoration: BoxDecoration(
                          color: onHoverPlay == true ? Colors.black54 : Colors.black45,
                          borderRadius: BorderRadius.circular(100)
                        ),
                        width: 150,
                        height: 150,
                        child: TextButton(
                          onPressed: () {
                            widget.gameRef.startGamePlay();
                            widget.gameRef.overlays.remove(MainMenu.id);
                            widget.gameRef.overlays.add(Hud.id);
                          },
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: onHoverPlay == true ? Colors.white54 : Colors.black54 ,
                            size: 70,
                          ),
                          onHover: (value) {
                            setState(() {
                              onHoverPlay = value;
                            });
                          },
                        ),
                      ),
                      // ElevatedButton(
                      //   onPressed: ()async{
                      //     await FirebaseAuthService().signInWithGoogle();
                      //   },
                      //   child: Text('Login Gmail')
                      // ),
                      FirebaseAuth.instance.currentUser != null ? Container() :
                      Container(
                        margin: EdgeInsets.only(top: 15),
                        child: Column(
                          children: [
                            Text(
                              'Login With',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                // fontFamily: 'Audiowide',
                                fontWeight: FontWeight.w400
                              ),
                            ),
                            Container(
                              width: 35,
                              margin: EdgeInsets.only(top: 10),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50)
                              ),
                              child: GestureDetector(
                                onTap: ()async{
                                  await FirebaseAuthService().signInWithGoogle();

                                  final snapshot = await FirebaseDatabase.instance
                                  .ref()
                                  .child('LeaderBoard')
                                  .child(FirebaseAuth.instance.currentUser!.uid)
                                  .get();
                                  final Map<String,dynamic> data = snapshot.value as Map<String,dynamic>; 
                                  
                                  widget.gameRef.playerData.highScore = data['highScore'];

                                  widget.gameRef.overlays.remove(MainMenu.id);
                                  widget.gameRef.overlays.add(MainMenu.id);
                                },
                                child: Image.asset(
                                  'assets/images/Google.svg.png',
                                  width: 35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 10,
                  child: TextButton(
                    child: Icon(
                      Icons.settings,
                      color: Colors.white70,
                      size: 50,
                    ),
                    onPressed: (){
                      widget.gameRef.overlays.remove(MainMenu.id);
                      widget.gameRef.overlays.add(SettingsMenu.id);
                    },
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 10,
                  child: TextButton(
                    child: Icon(
                      Icons.emoji_events_sharp,
                      color: Colors.white70,
                      size: 50,
                    ),
                    onPressed: (){
                      widget.gameRef.overlays.remove(MainMenu.id);
                      widget.gameRef.overlays.add(LeaderBoard.id);
                    },
                  ),
                )
              ],
            ),
          ),
          // child: Card(
          //   shape:
          //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          //   color: Colors.black.withAlpha(100),
          //   child: FittedBox(
          //     fit: BoxFit.scaleDown,
          //     child: Padding(
          //       padding:
          //           const EdgeInsets.symmetric(vertical: 20, horizontal: 100),
          //       child: Wrap(
          //         direction: Axis.vertical,
          //         crossAxisAlignment: WrapCrossAlignment.center,
          //         spacing: 10,
          //         children: [
          //           const Text(
          //             'Dino Run',
          //             style: TextStyle(
          //               fontSize: 50,
          //               color: Colors.white,
          //             ),
          //           ),
          //           ElevatedButton(
          //             onPressed: () {
          //               gameRef.startGamePlay();
          //               gameRef.overlays.remove(MainMenu.id);
          //               gameRef.overlays.add(Hud.id);
          //             },
          //             child: const Text(
          //               'Play',
          //               style: TextStyle(
          //                 fontSize: 30,
          //               ),
          //             ),
          //           ),
          //           ElevatedButton(
          //             onPressed: () {
          //               gameRef.overlays.remove(MainMenu.id);
          //               gameRef.overlays.add(SettingsMenu.id);
          //             },
          //             child: const Text(
          //               'Settings',
          //               style: TextStyle(
          //                 fontSize: 30,
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ),
      ),
    );
  }
}