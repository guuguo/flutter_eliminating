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
const kBlockAnimDuration =  200;
const kBlockElimintateAnimDuration = 400;
const kAnimReadyDuration = 20;
enum BlockAnimState{
  no,
  ready,
  anim,
}
class GameController extends GetxController {
  GameController() {
    generateBlocks();
  }

  var board = [
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
  ];
  Point<int>? currentFocus;
  Point<int>? targetBlock;
  ///交换动画 状态
  var blockSwitchAnim=BlockAnimState.no;

  List<List<int>>? eliminateMarkResult;
  ///消除动画 状态
  var eliminateAnim=BlockAnimState.no;

  Offset? downLocalPosition;

  generateBlocks() async {
    for (var i = 0; i < board.length; i++) {
      for (var j = 0; j < board[i].length; j++) {
        if (board[i][j] & kB != 0) {
          continue;
        }
        board[i][j] = board[i][j]& kBlockStateInfo  | (Random().nextInt(6) + 1);
      }
    }
    var times=1;
    while(await eliminateAll()){
      print("初始消除，消除${times}次");
      times++;
    }
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
  Future<bool> focusBlock(Offset localPosition)async {
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
        targetBlock=Point(i, j);
        ///交换
        await swapWithAnim(currentFocus!, targetBlock!);
        ///消除
        await delay(10);
        bool canEliminate = await eliminateAll(true);
        ///无法消除的话再换回来
        if (!canEliminate) {
          final temp=currentFocus;
          currentFocus = targetBlock;
          targetBlock = temp;
          update();
          await delay(10);
          await swapWithAnim(currentFocus!,targetBlock!);
          currentFocus = null;
          targetBlock = null;
          update();
          return false;
        }
        currentFocus = null;
        targetBlock = null;
        update();
        return true;
      }
      board[currentFocus!.x][currentFocus!.y] ^= kFlagFocuse;
    }
    currentFocus = Point(i, j);
    downLocalPosition = localPosition;
    update();
    return false;
  }

  Future<void> swapWithAnim(Point<int> focusBlock,Point<int> targetBlock) async {
    blockSwitchAnim=BlockAnimState.ready;
    update();
    await delay(kAnimReadyDuration);
    blockSwitchAnim=BlockAnimState.anim;
    update();
    await delay(kBlockAnimDuration);
    swap(currentFocus!, targetBlock);
    blockSwitchAnim=BlockAnimState.no;
  }

  ///消除应该消除的并重新随机
  ///如果成功消除了  返回true，失败了 返账false
  ///是否用户触发的消除，用户触发的需要动画，并在后期计算分值
  Future<bool> eliminateAll([bool byUser = false]) async {
    eliminateMarkResult  = markNeedEliminate(board);
    if(eliminateMarkResult==null) return false;
    ///等待消除动画
    if(byUser){
      eliminateAnim=BlockAnimState.ready;
      update();
      await delay(kAnimReadyDuration);
      eliminateAnim =  BlockAnimState.anim;
      update();
      await delay(kBlockElimintateAnimDuration);
      eliminateAnim =  BlockAnimState.no;
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
        final node= list.removeFirst();
        if(node==-1){
          board[i][j] = board[i][j]& kBlockStateInfo | (Random().nextInt(6) + 1);
        }else{
          board[i][j] = node;
        }
      }
    }
    return true;
  }

  List<List<int>>? markNeedEliminate(List<List<int>> board) {
    var canEliminate=false;
    var eliminateResult = List.generate(
        board.length, (i) => List.generate(board[0].length, (i) => 0));

    ///标记需要删除的
    for (var i = 0; i < board.length; i++) {
      for (var j = 0; j < board[i].length; j++) {
        ///如果是墙壁，不看了
        if (board[i][j] & kB != 0) {
          continue;
        }
        if(eliminateResult[i][j]!=0) continue;
        final type=getTypeWithXY(i,j);
        ///如果不是正常的方块，下一步
        if(type==0) continue;
        if(board[i].length-j>=2&&getTypeWithXY(i,j+1)==type&&getTypeWithXY(i,j+2)==type){
          eliminateResult[i][j]=1;
          eliminateResult[i][j+1]=1;
          eliminateResult[i][j+2]=1;
          canEliminate=true;
        }
        if(board.length-i>=2&&getTypeWithXY(i+1,j)==type&&getTypeWithXY(i+2,j)==type){
          eliminateResult[i][j]=1;
          eliminateResult[i+1][j]=1;
          eliminateResult[i+2][j]=1;
          canEliminate=true;
        }
      }
    }
    if(canEliminate) return eliminateResult;
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
