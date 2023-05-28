import 'dart:math' as math;
import 'dart:math';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'package:flutter_game_firebase/Components/Enemy/Enemy_Manager.dart';
import 'package:hive/hive.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

import 'package:flutter_game_firebase/Components/Parallax.dart';
import 'Components/Character.dart';

void main() {
  runApp(
    GameWidget(
      game: MyGame(),
      overlayBuilderMap: {
        'Ground': (context, game) {
          double width = MediaQuery.of(context).size.width;
          return Positioned(
            bottom: 0,
            height: 115,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  child: Image.asset(
                    "assets/images/parallax/plx-6.png",
                    repeat: ImageRepeat.repeat,
                    fit: BoxFit.fitHeight,
                    width: width,
                    height: 35,
                  ),
                ),
                Container(
                  child: Image.asset(
                    "assets/images/parallax/ground.png",
                    repeat: ImageRepeat.repeat,
                    fit: BoxFit.fitHeight,
                    width: width,
                    height: 77,
                  ),
                ),
              ],
            ),
          );
        },
      },
    ),
  );
}

class MyGame extends FlameGame with TapDetector,KeyboardEvents,HasCollisionDetection{

  static const _imageAssets = [
    'char/move.png',
    'char/male/olaf/base/hurt.png',
    'char/DinoSprites - vita.png',
    'enemies/Rino/Run (52x34).png',
    'enemies/AngryPig/Walk (36x30).png',
    'enemies/Bat/Flying (46x30).png'
  ];

  double speedY = 0.0;
  double yMax = 0.0;

  double GRAVITY = 1000;

  late Character _char;
  late EnemyManager _enemyManager;

  late double screenWidth;
  late double screenHeight;
  
  @override
  Future<void> onLoad() async {
    // add(Character());
    super.onLoad();

    await images.loadAll(_imageAssets);

    overlays.add('Ground');
    add(MyParallaxComponent());

    _char = Character(images.fromCache('char/DinoSprites - vita.png'));
    // if (Character.isHit == true) {
    //   _char = Character(images.fromCache('char/male/olaf/base/hurt.png'));
    //   print('object');
    // } 
    _enemyManager = EnemyManager();
    
    add(_char);
    add(_enemyManager);

  }
  
  // @override
  // void update(double dt){
  //   super.update(dt);
  // }

  // bool isOnGround(){
  //   return (playerY >= yMax);
  // }

  // Future<SpriteAnimationComponent> Character(double sizeY,String action) async {
  //   final sprite;
  //   final amountImage;
    
  //   switch (action) {
  //     case 'move':
  //       sprite = await images.load('char/move.png');
  //       amountImage = 6;
  //       break;
  //     case 'jump':
  //       sprite = await images.load('char/jump.png');
  //       amountImage = 6;
  //       jump();
  //       break;
  //     default:
  //     sprite = await images.load('char/move.png');
  //     amountImage = 6;
  //   }
    
  //   final data = SpriteAnimationData.sequenced(
  //     textureSize: Vector2(24,24),
  //     amount: amountImage,
  //     stepTime: .1,
  //   );
  //   var playerAnimation = SpriteAnimation.fromFrameData(
  //     sprite,
  //     data,
  //   );
  //   _player = SpriteAnimationComponent()
  //   ..animation = playerAnimation
  //   ..size = Vector2(24 , 24) * playerScale
  //   ..position = Vector2(50,sizeY - playerY);

  //   return _player;
  // }

  @override
  Future<void> onTapDown(TapDownInfo info) async {
    if (_char.isOnGround) {
      _char.jump();
    }

    super.onTapDown(info);
  }
  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is RawKeyDownEvent;

    final isSpace = keysPressed.contains(LogicalKeyboardKey.space);

    if (isSpace && isKeyDown) {
      if (_char.isOnGround) {
        _char.jump();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
  
  void jump(){
    speedY = -600;
  }

}
