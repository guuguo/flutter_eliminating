import 'dart:math';

import 'package:collection/collection.dart';
import 'package:eliminating/res.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'game_block.dart';
import 'model.dart';

class GameBoardWidget extends StatefulWidget {
  const GameBoardWidget({Key? key}) : super(key: key);

  @override
  _GameBoardWidgetState createState() => _GameBoardWidgetState();
}

///墙壁flag
final kB = 0x100;
///未初始化的正常棋盘
final kN = 0;
///方块的正常样式
final kBlockType = 0xFF;
///方块的状态信息
final kBlockStateInfo = 0xFF00;



class _GameBoardWidgetState extends State<GameBoardWidget> {
  _GameBoardWidgetState();

  Offset? downLocalPosition;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(Res.bg_wood), fit: BoxFit.cover)),
      alignment: Alignment.center,
      child: Stack(
        children: [
          buildBoardBG(),
          GestureDetector(
            onTapDown: (detail)async  {
              var controller = Get.find<GameController>();
              bool swap=await controller.focusBlock(detail.localPosition);
            },
            onTapUp: (detail) {
              var controller = Get.find<GameController>();
              controller.tapUp(detail.localPosition);
            },
            child: GetBuilder<GameController>(builder: (logic) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: logic.board
                    .mapIndexed((i, row) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: row
                              .mapIndexed((j, e) => GameBlockWidget(
                                    e,
                                    Point(i, j),
                                  ))
                              .toList(),
                        ))
                    .toList(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget buildBoardBG() {
    var controller = Get.find<GameController>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: controller.board
          .mapIndexed((i, row) =>
          Row(
            mainAxisSize: MainAxisSize.min,
            children:
            row.mapIndexed((j, e) => genBgFromType(i, j, e)).toList(),
          ))
          .toList(),
    );
  }


  Widget genBgFromType(int i, int j, int type) {
    var controller = Get.find<GameController>();
    BoxDecoration? decoration;
    if (!GameController.isBorder(type)) {
      decoration = const BoxDecoration(color: Color(0xFF3c4077));
    } else {
      bool right = !controller.isBorderWithXY(i, j + 1);
      bool bottom = !controller.isBorderWithXY(i + 1, j);
      bool top = !controller.isBorderWithXY(i - 1, j);
      bool left = !controller.isBorderWithXY(i, j - 1);
      const side = BorderSide(color: Color(0xFF718fbf), width: 3);
      decoration = BoxDecoration(
          border: Border(
            top: top ? side : BorderSide.none,
            left: left ? side : BorderSide.none,
            bottom: bottom ? side : BorderSide.none,
            right: right ? side : BorderSide.none,
          ));
    }
    return Container(
      height: kBlockSize,
      width: kBlockSize,
      decoration: decoration,
    );
  }
}
