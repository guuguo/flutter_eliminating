import 'dart:math';

import 'package:eliminating/page/game_board.dart';
import 'package:eliminating/res.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'model.dart';

class GameBlockWidget extends StatefulWidget {
  const GameBlockWidget(this.type, this.point, {Key? key}) : super(key: key);

  final int type;
  final Point<int> point;

  @override
  _GameBlockWidgetState createState() => _GameBlockWidgetState();
}

class _GameBlockWidgetState extends State<GameBlockWidget> {
  @override
  Widget build(BuildContext context) {
    Widget? child;
    if (widget.type & kB == 0) {
      final blockType = widget.type & kBlockType;
      String asset;
      if (blockType == 1) {
        ///水壶
        asset = Res.shuihu;
      } else if (blockType == 2) {
        ///花束
        asset = Res.huashu;
      } else if (blockType == 3) {
        ///沙发
        asset = Res.shafa;
      } else if (blockType == 4) {
        ///手机
        asset = Res.shouji;
      } else if (blockType == 5) {
        ///水晶球
        asset = Res.shuijingqiu;
      } else if (blockType == 6) {
        ///小熊
        asset = Res.xiaoxiong;
      } else {
        asset = Res.shuihu;
      }
      child = Image.asset(asset);
    }
    final container = Container(
        height: kBlockSize,
        width: kBlockSize,
        padding: const EdgeInsets.all(5),
        foregroundDecoration: getMaskDecoration(),
        child: child);

    return wrapWithAnim(container);;
  }

 Widget wrapWithAnim(Widget child) {
    var controller = Get.find<GameController>();
    if(controller.blockSwitchAnim!=BlockAnimState.no) {
      int slidDx = 0;
      int slidDy = 0;
        if (controller.targetBlock == widget.point) {
          slidDx = widget.point.x - controller.currentFocus!.x;
          slidDy = widget.point.y - controller.currentFocus!.y;
        } else if (controller.currentFocus == widget.point) {
          slidDx = widget.point.x - controller.targetBlock!.x;
          slidDy = widget.point.y - controller.targetBlock!.y;
        }
      if (slidDx!=0 || slidDy!=0) {
        return AnimatedSlide(
            offset: controller.blockSwitchAnim==BlockAnimState.ready?Offset.zero:Offset(-slidDy.toDouble(), -slidDx.toDouble()),
            duration: const Duration(milliseconds: kBlockAnimDuration),
            curve: Curves.bounceIn,
            child: child);
      }
    }
    else if(controller.eliminateAnim != BlockAnimState.no){
      if(controller.eliminateMarkResult![widget.point.x][widget.point.y]==1) {
        return AnimatedScale(
          duration: const Duration(milliseconds: kBlockElimintateAnimDuration),
          curve: Curves.bounceOut,
          scale:controller.eliminateAnim == BlockAnimState.ready? 1:0,
          child: child);
      }
    }

    return child;
  }

  Decoration? getMaskDecoration() {
    var controller = Get.find<GameController>();
    if(widget.point==controller.currentFocus) {
      return BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(10));
    }
    return null;
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("didChangeDependencies");
  }
}
