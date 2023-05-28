import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:flutter/material.dart';

import 'package:flutter_game_firebase/Components/Enemy/EnemyData.dart';
import 'package:flutter_game_firebase/main.dart';

class Enemy extends SpriteAnimationComponent
  with CollisionCallbacks, HasGameRef<MyGame>{

  final EnemyData enemyData;

  Enemy(this.enemyData) {
    animation = SpriteAnimation.fromFrameData(
      enemyData.image,
      SpriteAnimationData.sequenced(
        amount: enemyData.nFrames,
        stepTime: enemyData.stepTime,
        textureSize: enemyData.textureSize,
      ),
    );
  }

  @override
  void onMount() {
    // Reduce the size of enemy as they look too
    // big compared to the dino.
    size *= 0.6 * 3; 

    // Add a hitbox for this enemy.
    add(
      RectangleHitbox.relative(
        Vector2.all(0.8),
        parentSize: size,
        position: Vector2(size.x * 0.2, size.y * 0.2) / 2,
      ),
    );
    super.onMount();
  }

  @override
  void update(double dt) {
    position.x -= enemyData.speedX * dt;

    // Remove the enemy and increase player score
    // by 1, if enemy has gone past left end of the screen.
    if (position.x < -enemyData.textureSize.x) {
      removeFromParent();
      // gameRef.playerData.currentScore += 1;
    }

    super.update(dt);
  }
}