import 'dart:math';

import 'package:collection/collection.dart';
import 'package:eliminating/page/game.dart';
import 'package:eliminating/res.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'game_block.dart';
import 'game_board.dart';
import 'model.dart';

class StageListWidget extends StatefulWidget {
  const StageListWidget({Key? key}) : super(key: key);

  @override
  _StageListWidgetState createState() => _StageListWidgetState();
}

class _StageListWidgetState extends State<StageListWidget> {
  _StageListWidgetState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body : Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(Res.bg_wood), fit: BoxFit.cover)),
        alignment: Alignment.center,
        child: ButtonTheme(
          textTheme: ButtonTextTheme.primary,
          child: Column(
            mainAxisSize:MainAxisSize.min,
            children: [
              ElevatedButton(
                child: Text("第一关"),
                onPressed: () {
                  Get.to(() => Game(board: [
                        [kB, kB, kB, kB, kB, kB, kB, kB, kB],
                        [kB, kB, kB, kB, kB, kB, kB, kB, kB],
                        [kB, kB, kB, kB, kN, kB, kB, kB, kB],
                        [kB, kB, kB, kN, kN, kN, kB, kB, kB],
                        [kB, kB, kN, kN, kN, kN, kN, kB, kB],
                        [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                        [kB, kB, kN, kN, kN, kN, kN, kB, kB],
                        [kB, kB, kB, kN, kN, kN, kB, kB, kB],
                        [kB, kB, kB, kB, kN, kB, kB, kB, kB],
                        [kB, kB, kB, kB, kB, kB, kB, kB, kB],
                        [kB, kB, kB, kB, kB, kB, kB, kB, kB],
                      ]));
                },
              ),
              ElevatedButton(
                child: Text("第二关"),
                onPressed: () {
                  Get.to(() => Game(board: [
                    [kB, kB, kB, kB, kB, kB, kB, kB, kB],
                    [kB, kB, kB, kB, kB, kB, kB, kB, kB],
                    [kB, kB, kB, kB, kN, kB, kB, kB, kB],
                    [kB, kB, kB, kN, kN, kN, kB, kB, kB],
                    [kB, kB, kN, kN, kN, kN, kN, kB, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kB, kB, kB, kB, kB, kB, kB, kB],
                  ]));
                },
              ),
              ElevatedButton(
                child: Text("第三关"),
                onPressed: () {
                  Get.to(() => Game(board: [
                    [kB, kB, kB, kB, kB, kB, kB, kB, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kB, kB, kB, kB, kB, kB, kB, kB],
                  ]));
                },
              ),
              ElevatedButton(
                child: Text("第四关"),
                onPressed: () {
                  Get.to(() => Game(board: [
                    [kB, kB, kB, kB, kB, kB, kB, kB, kB],
                    [kB, kB, kN, kN, kN, kN, kN, kB, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kN, kN, kN, kN, kN, kN, kN, kB],
                    [kB, kB, kN, kN, kN, kN, kN, kB, kB],
                    [kB, kB, kB, kB, kB, kB, kB, kB, kB],
                  ]));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
