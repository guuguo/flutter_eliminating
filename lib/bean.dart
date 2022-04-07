import 'package:eliminating/res.dart';

abstract class IBlock{
  ///类型 小鸡小狗
  String getName();
  String? img();
  int backgroundType=1;
}
class NULLBlock extends IBlock{
  @override
  String getName()=> "NULL";
  @override
  String? img()=> null;
  @override
  String? background()=> null;
  @override
  int get backgroundType => 0;
}
class DogBlock extends IBlock{
  @override
  String getName()=>"手机";
  @override
  String img()=> Res.shouji;
}
