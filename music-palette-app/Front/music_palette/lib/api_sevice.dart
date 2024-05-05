import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:music_palette/music_data.dart';
import 'package:audioplayers/audioplayers.dart';

class ApiService {
  static const String baseUrl = "http://music-palette.shop";

  //1. 찜목록 불러오기
  static Future<List<bool>> getLikeMusics(String uID) async {
    Map<String, String> headers = {
      "Authorization": uID,
    };

    List<bool> musicInstances = [];
    final url = Uri.parse('$baseUrl/user/like');
    final response = await http.get(url, headers: headers);

    //print(response.statusCode);

    if (response.statusCode == 200) {
      //print("test");
      final Map<String, dynamic> likeId = jsonDecode(response.body);

      musicInstances = json.decode(likeId["likes"]).cast<bool>();

      //print("전체찜");
      //print(musicInstances);

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

      //musicInstances.shuffle();

      return musicInstances;
    }
    throw Error();
  }

  //3. 음악 정보 불러오기
  static Future<List> getMusicInfo({required int musicId}) async {
    List lrc = [];
    List vib = [];
    var url = Uri.parse('$baseUrl/musics/$musicId');
    //var queryParams = {'music_id': musicId};
    //url = url.replace(queryParameters: queryParams);

    var response = await http.get(url);
    //print(response.statusCode);

    if (response.statusCode == 200) {
      //print("test");
      final Map<String, dynamic> infos = jsonDecode(response.body);

      final List<dynamic> lyrics = infos["lyrics"];
      //print(lyrics);
      final List<dynamic> vibrations = infos["vibrations"];
      //print(vibrations);
      final int duration = infos["duration"];
      // ms단위로
      //print(duration);
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
        Duration dur = Duration(
            milliseconds: double.parse(vibration["time"]).toInt() * 1000);
        vib.add([dur, double.parse(vibration["strength"])]);
      }

      return [lrc, vib, duration];
    }
    throw Error();
  }

  //4. 찜 추가
  static Future<List<bool>> addLike(
      {required String uID, required int musicId}) async {
    List<bool> musicInstances = [];
    Map<String, String> headers = {
      "Authorization": uID,
    };

    var url = Uri.parse('$baseUrl/user/like/$musicId');
    //print('$baseUrl/user/like/$musicId');
    //var queryParams = {'music_id': musicId};
    //url = url.replace(queryParameters: queryParams);

    var response = await http.post(url, headers: headers);

    //print(uID);

    if (response.statusCode == 200) {
      //print("test");
      final Map<String, dynamic> likeId = jsonDecode(response.body);

      musicInstances = json.decode(likeId["likes"]).cast<bool>();

      //print("찜추가");
      //print(musicInstances);

      return musicInstances;
    }
    throw Error();
  }

  //5. 찜 삭제 -> 찜 추가와 동일
  static Future<List<bool>> deleteLike(
      {required String uID, required int musicId}) async {
    List<bool> musicInstances = [];
    Map<String, String> headers = {
      "Authorization": uID,
    };

    var url = Uri.parse('$baseUrl/user/like/$musicId');
    //print('$baseUrl/user/like/$musicId');
    //var queryParams = {'music_id': musicId};
    //url = url.replace(queryParameters: queryParams);

    var response = await http.delete(url, headers: headers);

    //print(uID);

    if (response.statusCode == 200) {
      //print("test del");
      final Map<String, dynamic> likeId = jsonDecode(response.body);

      musicInstances = json.decode(likeId["likes"]).cast<bool>();

      //print("찜삭제");
      //print(musicInstances);

      return musicInstances;
    }
    throw Error();
  }

  //6. 로그인

  //7. 앨범 커버 사진 http 주소
  static String getCoverImageString({required String encodedtitle}) {
    final url = '$baseUrl/images/cover-image/$encodedtitle.jpg';
    return url;
  }

  //8. 생성된 이미지파일 http주소
  static String getAiImageUri({required String encodedtitle}) {
    final url = '$baseUrl/images/made-image/$encodedtitle.jpg';
    // Todo
    return url;
  }

  //9. Mp3파일 http 주소
  static UrlSource getMp3FileUri({required String encodedtitle}) {
    final url = UrlSource('$baseUrl/musics/mp3-file/$encodedtitle.mp3');
    return url;
  }

  //10. mp3파일 업로드
  static Future<bool> uploadfile(File file) async {
    dynamic sendData = file.path;
    var formData =
        FormData.fromMap({'mp3file': await MultipartFile.fromFile(sendData)});

    var dio = Dio();
    try {
      dio.options.contentType = 'multipart/form-data';
      dio.options.maxRedirects.isFinite;

      //dio.options.headers = {'token': token};
      var response = await dio.post(
        '$baseUrl/musics/upload-mp3',
        data: formData,
      );

      if (response.statusCode == 200) {
        //print("test del");
        final Map<String, dynamic> likeId = jsonDecode(response.data);

        bool result = json.decode(likeId["isSuccess"]).cast<bool>();

        //print("찜삭제");
        //print(musicInstances);

        return result;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<List<Testapi>> testgetMusics() async {
    List<Testapi> musicInstances = [];
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> webtoons = jsonDecode(response.body);

      final instance = Testapi.fromJson(webtoons);
      //print("test");
      //print(instance.testst);
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
