import 'dart:ffi';

class MyMusic {
  int id;
  String title;
  String encodedtitle;
  String artist;
  String imageEx;
  late List<Map<Duration, String>> lrc;
  late List<Map<Duration, Float>> vibrations;
  bool like = false;

  MyMusic({
    required this.id,
    required this.title,
    required this.encodedtitle,
    required this.artist,
    required this.imageEx,
  });

  MyMusic.fromJson(Map<String, dynamic> json)
      : id = json["song_id"],
        title = json["title"],
        encodedtitle = json["encoded_title"],
        artist = json["artist"],
        imageEx = json["image_explain"];
}

class Testapi {
  bool suc;
  int testint;
  String testst;

  Testapi.fromJson(Map<String, dynamic> json)
      : suc = json['isSuccess'],
        testint = json['code'],
        testst = json['message'];
}
