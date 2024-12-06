import 'package:flutter/services.dart';

class AssetsProvider{

  ///本地图片路径
  static String imagePath(String name,{String type = 'png'}){
    return 'assets/images/$name.$type';
  }

  static String iconPath(String name,{String type = 'png'}){
    return 'assets/icons/$name.$type';
  }

  ///本地json动画
  static String lottiePath(String name){
    return 'assets/json/$name.json';
  }

  /// 本地视频
  static String loadVideo(String name, {String type = 'mp4'}){
    return 'assets/video/$name.$type';
  }

  /// 本地音频
  static String loadAudio(String name, {String type = 'mp3'}){
    return 'assets/audio/$name.$type';
  }

  /// 本地音效
  static String loadBeep(String name, {String type = 'ogg'}){
    return 'assets/audio/$name.$type';
  }

  /// svg
  static String svgPath(String name, {String type = 'svg'}){
    return 'assets/svg/$name.$type';
  }

  /// 本地 json 数据
  static Future<String> loadMock(String fileName) async{
    String json = await rootBundle.loadString('assets/mock/$fileName.json');
    return json;
  }
}
