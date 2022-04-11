import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'dart:math';
import 'dart:ui';

import 'package:eliminating/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'game_board.dart';

const double kBlockSize = 40;
const kBlockAnimDuration = 200;
const kBlockElimintateAnimDuration = 400;
const kAnimReadyDuration = 20;
enum BlockAnimState {
  no,
  ready,
  anim,
}

///预测消除的检查方向
enum CheckFromDirect { left, top, right, bottom }

class GameController extends GetxController {
  GameController(this.board) {
    generateBlocksAndUpdate();
  }

  var encouragement="".obs;
  List<List<int>> board;
  Point<int>? currentFocus;
  Point<int>? targetBlock;

  ///交换动画 状态
  var blockSwitchAnim = BlockAnimState.no;

  ///如果不能消除，点位值为0，能横向消除，点位值为1，能纵向消除，点位值为2
  List<List<int>>? eliminateMarkResult;

  ///消除动画 状态
  var eliminateAnim = BlockAnimState.no;

  Offset? downLocalPosition;

  generateBlocks() async {
    print("随机棋盘");
    for (var i = 0; i < board.length; i++) {
      for (var j = 0; j < board[i].length; j++) {
        if (board[i][j] & kB != 0) {
          continue;
        }
        board[i][j] = board[i][j] & kBlockStateInfo | (Random().nextInt(6) + 1);
      }
    }
    var times = 1;
    while (await eliminateAll()) {
      print("当前棋盘需要消除，消除第${times}次");
      times++;
    }

    ///如果无法消除，重新随机
    if (!detectCanEliminate()) {
      print("当前棋盘无法被消除");
      await generateBlocks();
    }
  }

  generateBlocksAndUpdate() async {
    await generateBlocks();
    update();
  }

  static bool isBorder(int type) {
    return type & kB != 0;
  }

  bool isBorderWithXY(int i, int j) {
    if (i < 0 || i >= board.length) return true;
    if (j < 0 || j >= board[0].length) return true;
    return isBorder(board[i][j]);
  }

  int getTypeWithXY(int i, int j) {
    if (i < 0 || i >= board.length) return 0;
    if (j < 0 || j >= board[0].length) return 0;
    return board[i][j] & kBlockType;
  }

  void swap(Point<int> from, Point<int> target) {
    final temp = board[from.x][from.y];
    board[from.x][from.y] = board[target.x][target.y];
    board[target.x][target.y] = temp;
  }

  ///返回是否交换
  Future<bool> focusBlock(Offset localPosition) async {
    final i = localPosition.dy ~/ kBlockSize;
    final j = localPosition.dx ~/ kBlockSize;
    if (isBorderWithXY(i, j)) return false;

    ///当选在之前选中块的边上，交换
    ///当距离太远，更新选中块
    if (currentFocus != null) {
      if ((i - currentFocus!.x).abs() == 1 &&
              (j - currentFocus!.y).abs() == 0 ||
          ((i - currentFocus!.x).abs() == 0 &&
              (j - currentFocus!.y).abs() == 1)) {
        targetBlock = Point(i, j);

        ///交换
        await swapWithAnim(currentFocus!, targetBlock!);

        ///消除
        await delay(10);

        ///消除
        if (await eliminateAll(byUser: true,beforeEliminate:(){
          encouragement.value ="棒棒哒";
        })) {
          currentFocus = null;
          targetBlock = null;
          ///消除完成后的棋盘，消除到不可消除为止
          var time=1;
          while (await eliminateAll(
              byUser: true,
              beforeEliminate: () {
                time++;
                encouragement.value = "精彩，连续消除第${time}次";
              })) {}

          ///消除完成后如果新的棋盘无法消除，重新随机
          if (!detectCanEliminate()) {
            await generateBlocks();
          }
          encouragement.value="";
          update();
          return true;
        }

        ///无法消除取消交换
        else {
          await swapBack();
          return false;
        }
      }
      board[currentFocus!.x][currentFocus!.y] ^= kFlagFocuse;
    }
    currentFocus = Point(i, j);
    downLocalPosition = localPosition;
    update();
    return false;
  }

  ///重新更换回来
  Future swapBack() async {
    final temp = currentFocus;
    currentFocus = targetBlock;
    targetBlock = temp;
    update();
    await delay(10);
    await swapWithAnim(currentFocus!, targetBlock!);
    currentFocus = null;
    targetBlock = null;
    update();
  }

  Future<void> swapWithAnim(
      Point<int> focusBlock, Point<int> targetBlock) async {
    blockSwitchAnim = BlockAnimState.ready;
    update();
    await delay(kAnimReadyDuration);
    blockSwitchAnim = BlockAnimState.anim;
    update();
    await delay(kBlockAnimDuration);
    swap(currentFocus!, targetBlock);
    blockSwitchAnim = BlockAnimState.no;
  }

  ///消除应该消除的并重新随机
  ///如果成功消除了  返回true，失败了 返账false
  ///是否用户触发的消除，用户触发的需要动画，并在后期计算分值
  Future<bool> eliminateAll({bool byUser = false,VoidCallback? beforeEliminate}) async {
    eliminateMarkResult = markNeedEliminate(board);
    if (eliminateMarkResult == null) return false;
    beforeEliminate?.call();
    ///等待消除动画
    if (byUser) {
      eliminateAnim = BlockAnimState.ready;
      update();
      await delay(kAnimReadyDuration);
      eliminateAnim = BlockAnimState.anim;
      update();
      await delay(kBlockElimintateAnimDuration);
      eliminateAnim = BlockAnimState.no;
    }
    Queue<int> list = Queue();
    for (var j = 0; j < board[0].length; j++) {
      ///消除方格
      for (var i = 0; i < board.length; i++) {
        ///如果是墙壁，不看了
        if (board[i][j] & kB != 0) {
          continue;
        }

        if (eliminateMarkResult![i][j] == 0) {
          list.addLast(board[i][j]);
        } else {
          ///插入应该填充的标志
          list.addFirst(-1);
        }
      }
      for (var i = 0; i < board.length; i++) {
        ///如果是墙壁，不看了
        if (board[i][j] & kB != 0) {
          continue;
        }
        final node = list.removeFirst();
        if (node == -1) {
          board[i][j] =
              board[i][j] & kBlockStateInfo | (Random().nextInt(6) + 1);
        } else {
          board[i][j] = node;
        }
      }
    }
    return true;
  }

  ///检测当前棋盘是否可被消除(棋盘需要是消除过的状态，不能当前就可消除)
  bool detectCanEliminate() {
    ///[fromDirect]消除来源方向 0 左，1 上，2 右，3下
    bool checkSurround(
        int targetType, int i, int j, CheckFromDirect fromDirect) {
      ///边界外直接返回false
      if (i < 0 || i >= board.length || j < 0 || j >= board.length) {
        return false;
      }

      if (fromDirect != CheckFromDirect.left &&
          getTypeWithXY(i, j - 1) == targetType) {
        return true;
      }
      if (fromDirect != CheckFromDirect.top &&
          getTypeWithXY(i - 1, j) == targetType) {
        return true;
      }
      if (fromDirect != CheckFromDirect.right &&
          getTypeWithXY(i, j + 1) == targetType) {
        return true;
      }
      if (fromDirect != CheckFromDirect.bottom &&
          getTypeWithXY(i + 1, j) == targetType) {
        return true;
      }
      return false;
    }

    ///检测该格子可否被预测消除
    for (var i = 0; i < board.length; i++) {
      for (var j = 0; j < board[i].length; j++) {
        ///如果是墙壁，不看了
        if (board[i][j] & kB != 0) {
          continue;
        }
        final type = getTypeWithXY(i, j);

        ///如果不是正常的方块，下一步
        if (type == 0) continue;

        ///如果横向二连了，检查首尾周围有无同类
        if (getTypeWithXY(i, j + 1) == type) {
          if (checkSurround(type, i, j - 1, CheckFromDirect.right)) {
            return true;
          }
          if (checkSurround(type, i, j + 2, CheckFromDirect.left)) {
            return true;
          }
        }
        if (getTypeWithXY(i + 1, j) == type) {
          if (checkSurround(type, i - 1, j, CheckFromDirect.bottom)) {
            return true;
          }
          if (checkSurround(type, i + 2, j, CheckFromDirect.top)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  ///标记所有需要删除的方块
  List<List<int>>? markNeedEliminate(List<List<int>> board) {
    var canEliminate = false;
    var eliminateResult = List.generate(
        board.length, (i) => List.generate(board[0].length, (i) => 0));

    ///标记需要删除的
    for (var i = 0; i < board.length; i++) {
      for (var j = 0; j < board[i].length; j++) {
        ///如果是墙壁，不看了
        if (board[i][j] & kB != 0) {
          continue;
        }
        final type = getTypeWithXY(i, j);

        ///如果不是正常的方块，下一步
        if (type == 0) continue;
        if (board[i].length - j >= 2 &&
            getTypeWithXY(i, j + 1) == type &&
            getTypeWithXY(i, j + 2) == type) {
          eliminateResult[i][j] = 1;
          eliminateResult[i][j + 1] = 1;
          eliminateResult[i][j + 2] = 1;
          canEliminate = true;
        }
        if (board.length - i >= 2 &&
            getTypeWithXY(i + 1, j) == type &&
            getTypeWithXY(i + 2, j) == type) {
          eliminateResult[i][j] = 2;
          eliminateResult[i + 1][j] = 2;
          eliminateResult[i + 2][j] = 2;
          canEliminate = true;
        }
      }
    }
    if (canEliminate) return eliminateResult;
    return null;
  }

  void tapUp(Offset localPosition) {
    if (downLocalPosition == null) return;
    if (currentFocus == null) return;
    final dy = localPosition.dy - downLocalPosition!.dy;
    final dx = localPosition.dx - downLocalPosition!.dx;
    var targetI = currentFocus!.x;
    var targetJ = currentFocus!.y;
    if (dy.abs() > dx.abs()) {
      targetI += dy > 0 ? 1 : -1;
    } else {
      targetJ += dx > 0 ? 1 : -1;
    }
    if (isBorderWithXY(targetI, targetJ)) {
      return;
    } else {}
  }
}

class EliminateAnim {
  var blocks = HashSet();
}
