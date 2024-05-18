import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class MainGameWidget extends StatelessWidget {
  const MainGameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: game,
      overlayBuilderMap: const {
        "PauseMenu": _pauseMenuBuilder,
      },
    );
  }
}

Game game = Game();

List<Component> components = [];
List<UFO> ufos = [];

double sH = 0;
double sW = 0;

Vector2 gunSize = Vector2(500 / 4, 750 / 4);
Vector2 bulletSize = Vector2(125 / 3, 250 / 3);

Vector2 lastPointPosition = Vector2.zero();
Vector2 lastPointDirection = Vector2.zero();

int killedEnemies = 0;
int passedEnemies = 0;
int everyNEnemiesAddLevel = 10;
int enemiesToLose = 10;

int currentLevel = 1;

TextComponent textComponent = TextComponent(
    text: "Level: " + currentLevel.toString(),
    anchor: Anchor.center,
    position: Vector2(sW / 2, 50),
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.black,
        fontSize: 35,
      ),
    ));

TextComponent passedEnemiesText = TextComponent(
    text: "HP: " + (enemiesToLose - passedEnemies).toString(),
    anchor: Anchor.center,
    position: Vector2(sW / 2, 80),
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.black,
        fontSize: 25,
      ),
    ));

class Game extends FlameGame with TapCallbacks, HasCollisionDetection {
  void destroy(Component component) {
    components.forEach((element) {
      if (element == component) {
        remove(element);
      }
    });
  }

  @override
  void onTapDown(TapDownEvent event) {
    lastPointPosition = event.localPosition;
    lastPointDirection = lastPointPosition - gun.transform.position;
  }

  @override
  void onTapUp(TapUpEvent event) {
    shoot();
  }

  SpriteComponent bg = SpriteComponent();
  Gun gun = Gun();

  @override
  Future<void> onLoad() async {
    super.onLoad();

    sW = size[0];
    sH = size[1];

    await images.load('bullet.png');
    await images.load('explosion.png');

    bg
      ..sprite = await loadSprite("background.png")
      ..size = Vector2(sW, sH);
    add(bg);

    gun
      ..sprite = await loadSprite("gun.png")
      ..anchor = Anchor.bottomCenter
      ..size = gunSize
      ..position = Vector2(sW / 2, sH)
      ..priority = 2;

    add(gun);

    for (int i = 0; i < 5; i++) {
      UFO u = UFO();
      u
        ..sprite = await loadSprite("ufo.png")
        ..size = Vector2(100, 100)
        ..anchor = Anchor.center
        ..position = Vector2(-100, Random.secure().nextDouble() * (sH / 3));

      add(u);
      ufos.add(u);
    }

    add(textComponent);
    add(passedEnemiesText);
  }

  void shoot() {
    double deg = lookAt(gun.transform.position, lastPointPosition);
    deg =
        clampDouble(lookAt(gun.transform.position, lastPointPosition), -89, 89);

    final bulletSprite = Sprite(images.fromCache('bullet.png'));
    Bullet bullet = Bullet();
    bullet
      ..sprite = bulletSprite
      ..size = bulletSize
      ..anchor = Anchor.center
      ..position = gun.transform.position
      ..transform.angleDegrees = deg
      ..priority = 1;

    bullet.direction = lastPointDirection;

    add(bullet);
    components.add(bullet);
  }

  void addExplosion(Vector2 pos) {
    Explosion explosion = Explosion();
    explosion
      ..sprite = Sprite(images.fromCache('explosion.png'))
      ..size = Vector2(100, 100)
      ..anchor = Anchor.center
      ..position = pos
      ..priority = 2;

    killedEnemies++;
    currentLevel = (killedEnemies / everyNEnemiesAddLevel).ceil();
    textComponent.text = "Level: " + currentLevel.toString();

    add(explosion);
    components.add(explosion);
  }

  void Lose() {
    overlays.add('PauseMenu');
    pauseEngine();
  }

  void Restart() {
    overlays.remove('PauseMenu');
    resumeEngine();

    killedEnemies = 0;
    passedEnemies = 0;
    currentLevel = 1;

    ufos.forEach((element) {
      element.reset();
    });

    passedEnemiesText.text =
        "HP: " + (enemiesToLose - passedEnemies).toString();
  }
}

class Explosion extends SpriteComponent {
  bool isExploded = false;
  double op = 1;

  @override
  void onLoad() {
    scale = Vector2(0, 0);
  }

  @override
  void update(double dt) {
    if (isExploded == false) {
      if (scale.x < 1) {
        scale += Vector2(dt, dt) * 8;
      } else {
        isExploded = true;
      }
    } else {
      if (opacity > 0.1) {
        op -= dt * 5;
        op = clampDouble(op, 0.05, 1);
        opacity = op;
      } else {
        game.destroy(this);
      }
    }
  }
}

class Bullet extends SpriteComponent with CollisionCallbacks {
  double minDist = 80;
  Vector2 direction = Vector2.zero();
  double t = 0;

  @override
  void onLoad() {}

  @override
  void update(double dt) {
    transform.position += direction.normalized() * dt * 1500;
    t += dt;
    if (t >= 2) {
      game.destroy(this);
    }

    ufos.forEach((element) {
      if (distance(position, element.position) <= minDist) {
        game.addExplosion(element.position);
        element.reset();
        game.destroy(this);
      }
    });
  }
}

class Gun extends SpriteComponent {
  @override
  void update(double dt) {
    double deg = lookAt(position, lastPointPosition);
    deg = clampDouble(lookAt(position, lastPointPosition), -89, 89);
    transform.angleDegrees = deg;
  }
}

class UFO extends SpriteComponent with CollisionCallbacks {
  double speed = getMultiper();

  @override
  void update(double dt) {
    super.update(dt);
    x += dt * speed;

    if (x >= (sW + 50)) {
      reset();

      passedEnemies++;
      passedEnemiesText.text =
          "HP: " + (enemiesToLose - passedEnemies).toString();
      print("SAD");
      if (passedEnemies >= enemiesToLose) game.Lose();
    }
  }

  void reset() {
    x = -100;
    y = Random.secure().nextDouble() * (sH / 1.5);
    speed = getMultiper();
  }

  
}

Widget _pauseMenuBuilder(BuildContext buildContext, Game game) {
  return Center(
    child: Stack(
      children: [
        Container(color: Colors.black.withOpacity(.75)),
        Container(
            margin: EdgeInsets.symmetric(vertical: 225, horizontal: 50),
            padding: EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.deepOrangeAccent,
                borderRadius: BorderRadius.all(Radius.circular(25)),
                border: Border.all(color: Colors.black, width: 3)),
            child: Wrap(
              children: [
                Column(
                  children: [
                    Text(
                      "You lose!",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                          decoration: TextDecoration.none),
                    ),
                    Padding(padding: EdgeInsets.all(20)),
                    Text("Killed enemies: " + killedEnemies.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          decoration: TextDecoration.none,
                        )),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(
                      "Maximum level: " + currentLevel.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(20)),
                    Container(
                      width: 250,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => {game.Restart()},
                        child: Text(
                          "Restart",
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent),
                      ),
                    )
                  ],
                )
              ],
            )),
      ],
    ),
  );
}

Widget overlayBuilder() {
  return GameWidget<Game>(
    game: Game()..paused = true,
    overlayBuilderMap: const {
      'PauseMenu': _pauseMenuBuilder,
    },
    initialActiveOverlays: const ['PauseMenu'],
  );
}

double distance(Vector2 v1, Vector2 v2) {
  return sqrt(pow(v1.x - v2.x, 2) + pow(v1.y - v2.y, 2));
}

double lookAt(Vector2 a, Vector2 b) {
  Vector2 dir = a - b;
  return -degrees(atan2(dir.x, dir.y));
}

int getRandomInt(int min, int max) {
  final random = Random();
  return min + random.nextInt(max - min + 1);
}

double getMultiper() {
    if (currentLevel <= 15) {
      switch (currentLevel) {
        case 1:
          {
            return getRandomInt(50, 75).toDouble();
          }
        case 2:
          {
            return getRandomInt(50, 85).toDouble();
          }
        case 3:
          {
            return getRandomInt(50, 100).toDouble();
          }
        case 4:
          {
            return getRandomInt(60, 110).toDouble();
          }
        case 5:
          {
            return getRandomInt(70, 120).toDouble();
          }
        case 6:
          {
            return getRandomInt(80, 150).toDouble();
          }
        case 7:
          {
            return getRandomInt(90, 175).toDouble();
          }
        case 8:
          {
            return getRandomInt(100, 200).toDouble();
          }
        case 9:
          {
            return getRandomInt(125, 225).toDouble();
          }
        case 10:
          {
            return getRandomInt(150, 250).toDouble();
          }
        case 11:
          {
            return getRandomInt(200, 300).toDouble();
          }
        case 12:
          {
            return getRandomInt(235, 325).toDouble();
          }
        case 13:
          {
            return getRandomInt(275, 380).toDouble();
          }
        case 14:
          {
            return getRandomInt(325, 450).toDouble();
          }
        case 15:
          {
            return getRandomInt(350, 500).toDouble();
          }
          default:{
            return getRandomInt(450, 600).toDouble();
          }
      }
    }
    else
    {
      return getRandomInt(450, 600).toDouble();
    }
  }