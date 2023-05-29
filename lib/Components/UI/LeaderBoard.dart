import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter_game_firebase/Components/Settings/Audio_Manager.dart';
// import 'package:flutter_game_firebase/Components/Settings/player_data.dart';
// import 'package:flutter_game_firebase/Components/UI/Hud.dart';
import 'package:flutter_game_firebase/Components/UI/MainMenu.dart';
import 'package:flutter_game_firebase/main.dart';
import 'package:image_network/image_network.dart' as imgNet;
import 'package:provider/provider.dart';

class LeaderBoard extends StatelessWidget {
  static const id = 'LeaderBoard';
  final MyGame gameRef;
  LeaderBoard(this.gameRef,{super.key});

  // final Future<DataSnapshot> dbRef = FirebaseDatabase.instance.ref().child('LeaderBoard').get();
  // final snapshot = await FirebaseDatabase.instance
  //                                 .ref()
  //                                 .child('LeaderBoard')
  //                                 .child(FirebaseAuth.instance.currentUser!.uid)
  //                                 .get();
  // final Map<String,dynamic> data = dbRef.value; 

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
            child: Container(
              width: MediaQuery.of(context).size.width * 0.88,
              height: MediaQuery.of(context).size.height * 0.88,
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 5,
                    child: TextButton(
                      onPressed: () {
                        gameRef.overlays.remove(LeaderBoard.id);
                        gameRef.overlays.add(MainMenu.id);
                      },
                      child: const Icon(Icons.arrow_back_ios_rounded,color: Colors.white70,size: 40,),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.7,
                      color: Colors.black54,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Table(
                            //   columnWidths: {
                            //     0: const FixedColumnWidth(50.0),// fixed to 100 width
                            //     1: const FlexColumnWidth(),
                            //     2: const FlexColumnWidth(),//fixed to 100 width
                            //   },
                            //   border: TableBorder.all(
                            //     // color: const Color.fromARGB(255, 143, 143, 143),
                            //     width: 3
                            //   ),
                            //   children: [
                            //     TableRow(
                            //       children: [
                            //         TableCell(
                            //           child: Text(
                            //             '#',
                            //             style: TextStyle(
                            //               fontSize: 20,
                            //               fontFamily: 'AudioWide',
                            //               fontWeight: FontWeight.w800,
                            //               color: Colors.white
                            //             ),
                            //           ),
                            //         ),
                            //         TableCell(
                            //           child: Text(
                            //             'Name',
                            //             style: TextStyle(
                            //               fontSize: 20,
                            //               fontFamily: 'AudioWide',
                            //               fontWeight: FontWeight.w800,
                            //               color: Colors.white
                            //             ),
                            //           ),
                            //         ),
                            //         TableCell(
                            //           child: Text(
                            //             'HighScore',
                            //             textAlign: TextAlign.start,
                            //             style: TextStyle(
                            //               fontSize: 20,
                            //               fontFamily: 'AudioWide',
                            //               fontWeight: FontWeight.w800,
                            //               color: Colors.white
                            //             ),
                            //           ),
                            //         )
                            //       ]
                            //     )
                            //   ],
                            // ),
                            Container(
                              child: Row(
                                children: [
                                  // Container(
                                  //   decoration: BoxDecoration(
                                  //     border: Border.all(color: Colors.white)
                                  //   ),
                                  //   width: MediaQuery.of(context).size.width * 0.07,
                                  //   child: Text(
                                  //     '#',
                                  //     textAlign: TextAlign.center,
                                  //     style: TextStyle(
                                  //       fontSize: 20,
                                  //       fontFamily: 'AudioWide',
                                  //       fontWeight: FontWeight.w800,
                                  //       color: Colors.white
                                  //     ),
                                  //   ),
                                  // ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white)
                                    ),
                                    width: MediaQuery.of(context).size.width * 0.47,
                                    child: Text(
                                      'Name',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'AudioWide',
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white)
                                    ),
                                    width: MediaQuery.of(context).size.width * 0.23,
                                    child: Text(
                                      'HighScore',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'AudioWide',
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            FirebaseAnimatedList(
                              query: FirebaseDatabase.instance.ref().child('LeaderBoard').orderByChild('highScore'),
                              shrinkWrap: true,
                              reverse: true,
                              itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) { 
                                Map lead = snapshot.value as Map;
                                lead['key'] = snapshot.key;
                                return Row(
                                  children: [
                                    // Container(
                                    //   decoration: BoxDecoration(
                                    //     border: Border.all(color: Colors.white)
                                    //   ),
                                    //   width: MediaQuery.of(context).size.width * 0.07,
                                    //   child: Text(
                                    //     '${index}',
                                    //     textAlign: TextAlign.center,
                                    //     style: TextStyle(
                                    //       fontSize: 20,
                                    //       fontFamily: 'AudioWide',
                                    //       fontWeight: FontWeight.w800,
                                    //       color: Colors.white
                                    //     ),
                                    //   ),
                                    // ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white)
                                      ),
                                      width: MediaQuery.of(context).size.width * 0.47,
                                      child: Text(
                                        '${lead['name']}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'AudioWide',
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white)
                                      ),
                                      width: MediaQuery.of(context).size.width * 0.23,
                                      child: Text(
                                        '${lead['highScore']}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'AudioWide',
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              }, 
                  
                            ),
                          ],
                        ),
                        // child: Selector<dbRef>(
                        //   selector: (_, playerData) => playerData.highScore,
                        //   builder: (_, score, __)
                        // ),
                        // child: FirebaseDatabaseQueryBuilder(
                        //   query: FirebaseDatabase.instance.ref().child('LeaderBoard'),
                        //   builder: (context, snapshot, _) {
                        //     if (snapshot.hasData) {
                  
                        //       var data = snapshot.docs;
                        //       return Container(
                        //         child: Text('${data.length}'),
                        //       );
                        //     }else{
                        //       return Center(
                        //         child: CircularProgressIndicator(),
                        //       );
                        //     }
                        //   }
                        // ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}