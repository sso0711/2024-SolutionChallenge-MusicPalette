import 'package:flutter/material.dart';
import 'package:music_palette/music_data.dart';
import 'package:music_palette/musicpage.dart';
import 'package:music_palette/mypage.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  List<MyMusic> testdata = [
    MyMusic(name: "bad guy", singer: "singer1"),
    MyMusic(name: "Blueming", singer: "singer2"),
    MyMusic(name: "05 Bad Liar", singer: "singer3"),
    MyMusic(name: "LOVE ME RIGHT", singer: "singer4"),
    MyMusic(name: "Don't Call Me", singer: "singer5"),
    MyMusic(name: "hey", singer: "singer6"),
    MyMusic(name: "Blueming", singer: "singer7"),
    MyMusic(name: "onrepeat", singer: "singer8"),
    MyMusic(name: "hey", singer: "singer9"),
    MyMusic(name: "dreams", singer: "singer10"),
  ];

  //Future<List<Testapi>> musics = ApiService.getMusics();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        backgroundColor: Theme.of(context).primaryColorLight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  height: 200,
                  color: Colors.black45,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (BuildContext context) {
                                return const Mypage();
                              },
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 90,
                            width: 90,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "정우서",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              "dddd@gmail.com",
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              ButtonBar(
                alignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (BuildContext context) {
                            return const Mypage();
                          },
                        ),
                      );
                    },
                    child: const Text(
                      "My Page",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leadingWidth: 10,
        leading: const Icon(
          Icons.music_note,
          color: Colors.amber,
        ),
        title: const Text(
          "연진",
          style: TextStyle(
            color: Colors.amberAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).focusColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "추천 노래",
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Music(music: testdata[index]);
                  },
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Music extends StatelessWidget {
  final MyMusic music;

  const Music({
    super.key,
    required this.music,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (BuildContext context) {
              return MusicPage(
                name: music.name,
                singer: music.singer,
              );
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 60,
                width: 60,
                color: Colors.amber,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  music.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  music.singer,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white60,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
