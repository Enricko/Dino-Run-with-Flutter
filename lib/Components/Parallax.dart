import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game_firebase/main.dart';

class MyParallaxComponent extends ParallaxComponent<MyGame> {
  @override
  Future<void> onLoad() async {
    final images = [
      gameRef.loadParallaxImage('parallax/plx-1.png',),
      gameRef.loadParallaxImage('parallax/plx-2.png',),
      gameRef.loadParallaxImage('parallax/plx-3.png',),
      gameRef.loadParallaxImage('parallax/plx-4.png',),
      gameRef.loadParallaxImage('parallax/plx-5.png',),
    ];
    final layers = images.map((image) async => ParallaxLayer(await image, velocityMultiplier: Vector2.all(images.indexOf(image) * 2.0)));
    // parallax = ParallaxComponent.load(
      
    parallax = Parallax(
      await Future.wait(layers),
      baseVelocity: Vector2(35, 0),
      size: Vector2(800, 600)
      
    );
    // );
  }
}
