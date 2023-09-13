import 'dart:math' as math;

class Constants{
  static const int appId = 2014461749;
  static const String appSign = '57dd685b00f8f2bbd6d3b723ac47fe05f775aef47bbd227f65b573cf07d3f5f9';
}


/// Note that the userID needs to be globally unique,
final String localUserID = math.Random().nextInt(10000).toString();