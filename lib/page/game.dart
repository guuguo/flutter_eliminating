import 'package:eliminating/page/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'game_board.dart';

class Game extends StatefulWidget {
  const Game({Key? key}) : super(key: key);

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Get.put(GameController());
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Stack(
                  children: [
                    Positioned(
                        child: Text(
                          "分数",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        bottom: 0),
                    Positioned(
                        child: Text(
                          "设置",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        right: 0),
                    Positioned(
                        child: Center(
                          child: Container(
                            width: 100,
                            height: 150,
                            color: Colors.green,
                          ),
                        ),
                        right: 0,
                        left: 0,
                        bottom: 0),
                  ],
                ),
              ),
            ),
            const GameBoardWidget()
          ],
        ),
      ),
    );
  }
}
