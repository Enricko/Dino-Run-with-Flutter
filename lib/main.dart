import 'dart:html';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_game_firebase/Components/Enemy/Enemy_Manager.dart';
import 'package:flutter_game_firebase/Components/Settings/Audio_Manager.dart';
import 'package:flutter_game_firebase/Components/Settings/player_data.dart';
import 'package:flutter_game_firebase/Components/Settings/settings.dart';
import 'package:flutter_game_firebase/Components/UI/GameOverMenus.dart';
import 'package:flutter_game_firebase/Components/UI/Hud.dart';
import 'package:flutter_game_firebase/Components/UI/LeaderBoard.dart';
import 'package:flutter_game_firebase/Components/UI/MainMenu.dart';
import 'package:flutter_game_firebase/Components/UI/PauseMenu.dart';
import 'package:flutter_game_firebase/Components/UI/SettingsMenu.dart';
import 'package:flutter_game_firebase/firebase_options.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

import 'package:flutter_game_firebase/Components/Parallax.dart';
import 'Components/Character.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initHive();

  runApp(
    GameWidget(
      game: MyGame(),
      initialActiveOverlays: const [MainMenu.id],
      overlayBuilderMap: {
        MainMenu.id: (_, MyGame gameRef) => MainMenu(gameRef),
        PauseMenu.id: (_, MyGame gameRef) => PauseMenu(gameRef),
        Hud.id: (_, MyGame gameRef) => Hud(gameRef,),
        GameOverMenus.id: (_, MyGame gameRef) => GameOverMenus(gameRef),
        SettingsMenu.id: (_, MyGame gameRef) => SettingsMenu(gameRef),
        LeaderBoard.id: (_, MyGame gameRef) => LeaderBoard(gameRef),
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
Future<void> initHive() async {
  // For web hive does not need to be initialized.
  if (!kIsWeb) {
    var dir = Directory.current;
    Hive.init(dir.path);
  }

  Hive.registerAdapter<PlayerData>(PlayerDataAdapter()); 
  Hive.registerAdapter<Settings>(SettingsAdapter());
}
class MyGame extends FlameGame with TapDetector,KeyboardEvents, HasCollisionDetection,WidgetsBindingObserver {
  // List of all the image assets.
  static const _imageAssets = [
    'char/DinoSprites - vita.png',
    'enemies/AngryPig/Walk (36x30).png',
    'enemies/Bat/Flying (46x30).png',
    'enemies/Rino/Run (52x34).png',
    'parallax/plx-1.png',
    'parallax/plx-2.png',
    'parallax/plx-3.png',
    'parallax/plx-4.png',
    'parallax/plx-5.png',
    'parallax/plx-6.png',
  ];

  // List of all the audio assets.
  static const _audioAssets = [
    '8BitPlatformerLoop.wav',
    'hurt7.wav',
    'jump14.wav',
  ];

  late Char _char;
  late Settings settings;
  late PlayerData playerData;
  late EnemyManager _enemyManager;

  // This method get called while flame is preparing this game.
  @override
  Future<void> onLoad() async {
    /// Read [PlayerData] and [Settings] from hive.
    playerData = await _readPlayerData();
    settings = await _readSettings();

    /// Initilize [AudioManager].
    await AudioManager.instance.init(_audioAssets, settings);
    await images.loadAll(_imageAssets);

    add(MyParallaxComponent());
    overlays.add('Ground');
    

    return super.onLoad();
  }

  /// This method add the already created [Dino]
  /// and [EnemyManager] to this game.
  Future<void> startGamePlay() async {

    _char = Char(images.fromCache('char/DinoSprites - vita.png'), playerData);
    _enemyManager = EnemyManager();

    AudioManager.instance.startBgm('8BitPlatformerLoop.wav');

    add(_char);
    add(_enemyManager);
    if (FirebaseAuth.instance.currentUser != null) {
      
      final snapshot = await FirebaseDatabase.instance
      .ref()
      .child('LeaderBoard')
      .child(FirebaseAuth.instance.currentUser!.uid)
      .get();
      final Map<String,dynamic> data = snapshot.value as Map<String,dynamic>; 
      
      playerData.highScore = data['highScore'];
    }
    
  }

  // This method remove all the actors from the game.
  void _disconnectActors() {
    _char.removeFromParent();
    _enemyManager.removeAllEnemies();
    _enemyManager.removeFromParent();
  }

  // This method reset the whole game world to initial state.
  Future<void> reset() async {
    // First disconnect all actions from game world.
    _disconnectActors();

    // Reset player data to inital values.
    playerData.scoreUntilHeal = 0;
    playerData.currentScore = 0;
    playerData.lives = 5;
    if (FirebaseAuth.instance.currentUser != null) {
      
      final snapshot = await FirebaseDatabase.instance
      .ref()
      .child('LeaderBoard')
      .child(FirebaseAuth.instance.currentUser!.uid)
      .get();
      final Map<String,dynamic> data = snapshot.value as Map<String,dynamic>; 
      
      playerData.highScore = data['highScore'];
    }
  }

  // This method gets called for each tick/frame of the game.
  @override
  Future<void> update(double dt) async {
    if (kIsWeb) {
      window.addEventListener('focus', onFocus);
      window.addEventListener('blur', onBlur);
    } else {
      WidgetsBinding.instance.addObserver(this);
    }
    
    // If number of lives is 0 or less, game is over.
    if (playerData.lives <= 0) {
      // print('object');
      overlays.add(GameOverMenus.id);
      overlays.remove(Hud.id);
      pauseEngine();
      AudioManager.instance.pauseBgm();
    }
    super.update(dt);
  }

  void onFocus(Event e) {
    lifecycleStateChange(AppLifecycleState.resumed);
  }

  void onBlur(Event e) {
    lifecycleStateChange(AppLifecycleState.paused);
  }

  // This will get called for each tap on the screen.
  @override
  void onTapDown(TapDownInfo info) {
    // Make dino jump only when game is playing.
    // When game is in playing state, only Hud will be the active overlay.
    if (overlays.isActive(Hud.id)) {
      _char.jump();
    }
    super.onTapDown(info);
  }

  /// This method reads [PlayerData] from the hive box.
  Future<PlayerData> _readPlayerData() async {
    final playerDataBox =
        await Hive.openBox<PlayerData>('MyGame.PlayerDataBox');
    final playerData = playerDataBox.get('MyGame.PlayerData');

    // If data is null, this is probably a fresh launch of the game.
    if (playerData == null) {
      // In such cases store default values in hive.
      await playerDataBox.put('MyGame.PlayerData', PlayerData());
    }

    // Now it is safe to return the stored value.
    return playerDataBox.get('MyGame.PlayerData')!;
  }

  /// This method reads [Settings] from the hive box.
  Future<Settings> _readSettings() async {
    final settingsBox = await Hive.openBox<Settings>('MyGame.SettingsBox');
    final settings = settingsBox.get('MyGame.Settings');

    // If data is null, this is probably a fresh launch of the game.
    if (settings == null) {
      // In such cases store default values in hive.
      await settingsBox.put(
        'MyGame.Settings',
        Settings(bgm: true, sfx: true),
      );
    }

    // Now it is safe to return the stored value.
    return settingsBox.get('MyGame.Settings')!;
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // On resume, if active overlay is not PauseMenu,
        // resume the engine (lets the parallax effect play).
        if (!(overlays.isActive(PauseMenu.id)) &&
            !(overlays.isActive(GameOverMenus.id))) {
          resumeEngine();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        // If game is active, then remove Hud and add PauseMenu
        // before pausing the game.
        if (overlays.isActive(Hud.id)) {
          overlays.remove(Hud.id);
          overlays.add(PauseMenu.id);
        }
        pauseEngine();
        break;
    }
    super.lifecycleStateChange(state);
  }

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
}

