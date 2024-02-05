import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:music_palette/music_data.dart';

class ApiService {
  static const String baseUrl = "http://34.22.104.89";

  //1. 찜목록 불러오기
  static Future<List<int>> getLikeMusics() async {
    List<int> musicInstances = [];
    final url = Uri.parse('$baseUrl/user/like/:u_id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<int> likeId = jsonDecode(response.body);

      musicInstances = likeId;

      return musicInstances;
    }
    throw Error();
  }

  //2. 전체노래 목록 불러오기
  static Future<List<MyMusic>> getAllMusics() async {
    List<MyMusic> musicInstances = [];
    final url = Uri.parse('$baseUrl/musics');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> musics = jsonDecode(response.body);

      for (var music in musics) {
        musicInstances.add(MyMusic.fromJson(music));
      }

      return musicInstances;
    }
    throw Error();
  }

  //3. 음악 정보 불러오기
  Future<List> getMusicInfo({required int musicId}) async {
    List lrc = [];
    List vib = [];
    var url = Uri.parse('$baseUrl/musics');
    var queryParams = {'music_id': musicId};
    url = url.replace(queryParameters: queryParams);

    var response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> infos = jsonDecode(response.body);

      final List<dynamic> lyrics = infos["lyrics"];
      final List<dynamic> vibrations = infos["vibrations"];
      final int status = infos["status"];

      // lyrics
      for (var lyric in lyrics) {
        var min = int.parse(lyric["time"].split(":")[0]);
        var sec =
            int.parse(lyric["time"].split(":")[1].split(".")[0]) + (min * 60);
        var mili =
            (int.parse(lyric["time"].split(":")[1].split(".")[1])) * 100 +
                (sec * 1000);

        Duration dur = Duration(milliseconds: mili);

        lrc.add([dur, lyric["lyric"]]);
      }

      //vibration
      for (var vibration in vibrations) {
        Duration dur = Duration(milliseconds: vibration["time"] * 1000);
        vib.add([dur, vibration["vibration"]]);
      }

      return [lrc, vib, status];
    }
    throw Error();
  }

  //4. 찜 추가
  Future<void> addLike({required String userId, required int musicId}) async {
    var url = Uri.parse('$baseUrl/user/like');
    var queryParams = {'u_id': userId, 'music_id': musicId};
    url = url.replace(queryParameters: queryParams);

    var response = await http.get(url);
  }

  //5. 찜 삭제 -> 찜 삭제와 동일
  Future<void> deleteLike(
      {required String userId, required int musicId}) async {
    var url = Uri.parse('$baseUrl/user/like');
    var queryParams = {'u_id': userId, 'music_id': musicId};
    url = url.replace(queryParameters: queryParams);

    var response = await http.get(url);
  }

  //6. 로그인

  //7. 앨범 커버 사진 http 주소
  static Uri getCoverImageUri({required String encodedtitle}) {
    final url = Uri.parse('$baseUrl/images/cover-image/$encodedtitle.jpg');
    return url;
  }

  //8. 생성된 이미지파일 http주소
  static Uri getAiImageUri({required String encodedtitle}) {
    final url = Uri.parse('');
    // Todo
    return url;
  }

  //9. Mp3파일 http 주소
  static Uri getMp3FileUri({required String encodedtitle}) {
    final url = Uri.parse('$baseUrl/musics/mp3-file/$encodedtitle.mp3');
    return url;
  }

  static Future<List<Testapi>> testgetMusics() async {
    List<Testapi> musicInstances = [];
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> webtoons = jsonDecode(response.body);

      final instance = Testapi.fromJson(webtoons);
      //print("test");
      print(instance.testst);
      return musicInstances;
    }
    throw Error();
  }

  Future<void> reqtest() async {
    var url = Uri.parse("http://34.22.104.89/app/title");
    var queryParams = {'artist': 'value1', 'title': 'value2'};
    url = url.replace(queryParameters: queryParams);

    var response = await http.get(
      url,
      headers: {'artist': 'application/json', 'title': 'application/json'},
    );

    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');
  }
}
