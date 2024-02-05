import 'package:flutter/material.dart';
import 'package:music_palette/login_service.dart';
import 'package:music_palette/music_data.dart';
import 'package:music_palette/musicpage.dart';
import 'package:music_palette/mypage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MyMusic> testdata = [
    MyMusic(
        id: 1,
        title: "05 Bad Liar",
        encodedtitle: "encoded_title",
        artist: "artist"),
    MyMusic(
        id: 2,
        title: "bad guy",
        encodedtitle: "encoded_title",
        artist: "artist"),
    MyMusic(
        id: 3,
        title: "Blueming",
        encodedtitle: "encoded_title",
        artist: "artist"),
    MyMusic(
        id: 4,
        title: "Don't Call Me",
        encodedtitle: "encoded_title",
        artist: "artist"),
    MyMusic(
        id: 5,
        title: "dreams",
        encodedtitle: "encoded_title",
        artist: "artist"),
    MyMusic(
        id: 6, title: "hey", encodedtitle: "encoded_title", artist: "artist"),
    MyMusic(
        id: 7,
        title: "LOVE ME RIGHT",
        encodedtitle: "encoded_title",
        artist: "artist"),
    MyMusic(
        id: 8,
        title: "onrepeat",
        encodedtitle: "encoded_title",
        artist: "artist"),
    MyMusic(
        id: 9,
        title: "Blueming",
        encodedtitle: "encoded_title",
        artist: "artist"),
    MyMusic(
        id: 10,
        title: "Blueming",
        encodedtitle: "encoded_title",
        artist: "artist"),
    MyMusic(
        id: 11,
        title: "Blueming",
        encodedtitle: "encoded_title",
        artist: "artist"),
    MyMusic(
        id: 12,
        title: "Blueming",
        encodedtitle: "encoded_title",
        artist: "artist"),
    MyMusic(
        id: 13,
        title: "Blueming",
        encodedtitle: "encoded_title",
        artist: "artist"),
  ];

  MusicUser user = MusicUser();
  //LoginService user = LoginService();

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
              user.isLogin
                  ? profile(context)
                  : Container(
                      padding: const EdgeInsets.all(20),
                      height: 100,
                      color: Colors.black45,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await user.signInWithGoogle();
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.login_outlined,
                          size: 18,
                          color: Colors.white60,
                        ),
                        label: const Text(
                          "로그인이 필요합니다.",
                          style: TextStyle(color: Colors.white60),
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
                            return Mypage(
                              user: user,
                            );
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

  ClipRRect profile(BuildContext context) {
    return ClipRRect(
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
                      return Mypage(
                        user: user,
                      );
                    },
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 90,
                  width: 90,
                  child: Image.network(user.userImage),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    user.userEmail,
                    style: const TextStyle(
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
                name: music.title,
                singer: music.artist,
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
                  music.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  music.artist,
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
