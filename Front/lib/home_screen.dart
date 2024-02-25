import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:music_palette/all_music_page.dart';
import 'package:music_palette/api_sevice.dart';
import 'package:music_palette/like_musics_page.dart';
import 'package:music_palette/login_service.dart';
import 'package:music_palette/music_data.dart';
import 'package:music_palette/musicpage.dart';
import 'package:music_palette/mypage.dart';
import 'package:text_scroll/text_scroll.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<MyMusic>> allMusics = ApiService.getAllMusics();

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
          child: user.isLogin ? menuList(context) : logInButton(),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: const Icon(
          Icons.music_note,
          color: Colors.white,
        ),
        title: const Text(
          "Music Palette",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
          child: !user.isLogin
              ? logInButton()
              : Column(
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
                    FutureBuilder(
                      future: allMusics,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Expanded(
                            child: makeMusicList(snapshot),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  ListView menuList(BuildContext context) {
    return ListView(
      children: [
        profile(context),
        const SizedBox(
          height: 10,
        ),
        const Divider(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (BuildContext context) {
                      return AllMusicPage(
                        allMusics: allMusics,
                        user: user,
                      );
                    },
                  ),
                );
              },
              child: const Text(
                "전체 노래",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (BuildContext context) {
                      return LikeMusicPage(allMusics: allMusics, user: user);
                    },
                  ),
                );
              },
              child: const Text(
                "내가 찜한 노래",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget logInButton() {
    return ListView(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.black54,
            height: 100,
            child: OutlinedButton.icon(
              onPressed: () async {
                await user.signInWithGoogle();

                //print("3");

                setState(() {
                  //setAllLike();
                });
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
        )
      ],
    );
  }

  ListView makeMusicList(AsyncSnapshot<List<MyMusic>> snapshots) {
    for (int i = 0; i < snapshots.data!.length; i++) {
      snapshots.data![i].like = user.likeList[i + 1];
    }
    List randomIndex = [];
    List snapshot = [];
    while (true) {
      var i = Random().nextInt(snapshots.data!.length);
      if (!randomIndex.contains(i)) {
        randomIndex.add(i);
        snapshot.add(snapshots.data![i]);
      }
      if (randomIndex.length >= 10) break;
    }

    return ListView.separated(
      scrollDirection: Axis.vertical,
      itemCount: 10,
      itemBuilder: (context, index) {
        return Music(
          music: snapshot[index],
          user: user,
        );
      },
      separatorBuilder: (context, index) => const SizedBox(
        height: 2,
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
  MusicUser user;

  Music({
    super.key,
    required this.music,
    required this.user,
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
                music: music,
                user: user,
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
                color: Colors.white,
                child: Image.network(ApiService.getCoverImageString(
                    encodedtitle: music.encodedtitle)),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextScroll(
                    music.title,
                    delayBefore: const Duration(seconds: 2),
                    pauseBetween: const Duration(seconds: 2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
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
