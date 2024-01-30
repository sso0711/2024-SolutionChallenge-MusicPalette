class MyMusic {
  String name;
  String singer;
  late List<Map<Duration, String>> lrc;
  bool like = false;

  MyMusic({
    required this.name,
    required this.singer,
  });
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
