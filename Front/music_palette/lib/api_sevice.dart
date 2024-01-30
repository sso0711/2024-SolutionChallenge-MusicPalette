import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:music_palette/music_data.dart';

class ApiService {
  static const String baseUrl = "http://34.22.104.89/app/test";
  static const String today = "today";

  static Future<List<Testapi>> getMusics() async {
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

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}
