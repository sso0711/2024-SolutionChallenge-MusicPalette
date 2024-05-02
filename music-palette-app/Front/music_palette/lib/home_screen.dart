import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:music_palette/all_music_page.dart';
import 'package:music_palette/api_sevice.dart';
import 'package:music_palette/bottom.dart';
import 'package:music_palette/like_musics_page.dart';
import 'package:music_palette/login_service.dart';
import 'package:music_palette/music_data.dart';
import 'package:music_palette/musicpage.dart';
import 'package:music_palette/mypage.dart';
import 'package:music_palette/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_scroll/text_scroll.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static Future<List<MyMusic>> allMusics = ApiService.getAllMusics();

  MusicUser user = MusicUser();
  late TabController tabController = TabController(length: 3, vsync: this);

  String searchtext = '';

  Future<void> testlogin() async {
    User? testuser = FirebaseAuth.instance.currentUser;
    if (testuser != null) {
      // login
      await user.autoLogin(testuser);
      setState(() {});
    }
  }

  static void update_allmusic() {
    allMusics = ApiService.getAllMusics();
  }

  Future<void> search_music(String title) async {
    List musics = await allMusics;
    for (int i = 0; i < musics.length; i++) {}
  }

  @override
  void initState() {
    FlutterNativeSplash.remove();
    // TODO: implement initState
    super.initState();
    testlogin();
    tabController.index = 1;
  }

  @override
  Widget build(BuildContext context) {
    return !user.isLogin
        ? Scaffold(
            body: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColorLight,
                    Theme.of(context).primaryColor,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: logInButton(),
              ),
            ),
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColorLight,
              leading: Image.asset('assets/image/logo.png'),
              title: Text(
                "Music Palette",
                style: TextStyle(
                  color: Theme.of(context).focusColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            bottomNavigationBar: Bottom(
              tabController: tabController,
            ),
            body: TabBarView(
              controller: tabController,
              children: [
                const MusicUpload(),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColorLight,
                        Theme.of(context).primaryColor,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "추천 노래",
                              style: TextStyle(
                                fontSize: 40,
                                color: Theme.of(context).focusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    List musics = await allMusics;
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        fullscreenDialog: true,
                                        builder: (BuildContext context) {
                                          return Search_Page(
                                            musics: musics,
                                            user: user,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.search,
                                    color: Theme.of(context).focusColor,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    Icons.replay,
                                    color: Theme.of(context).focusColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColorLight,
                        Theme.of(context).primaryColor,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: menuList(context),
                ),
              ],
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
              child: Text(
                "My Page",
                style: TextStyle(
                  color: Theme.of(context).focusColor,
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
              child: Text(
                "전체 노래",
                style: TextStyle(
                  color: Theme.of(context).focusColor,
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
              child: Text(
                "내가 찜한 노래",
                style: TextStyle(
                  color: Theme.of(context).focusColor,
                  fontSize: 20,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await user.logout();
                setState(() {});
              },
              child: Text(
                "로그아웃",
                style: TextStyle(
                  color: Theme.of(context).focusColor,
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
        Column(
          children: [
            Image.asset(
              'assets/image/logo.png',
              height: 140,
            ),
            Image.asset(
              'assets/image/logotext.png',
              height: 80,
            )
          ],
        ),
        const Text("로그인이 필요합니다."),
        const SizedBox(
          height: 20,
        ),
        InkWell(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Colors.black26,
                style: BorderStyle.solid,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(10),
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/image/loginlogo/google.png',
                    ),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Google 로그인",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          onTap: () async {
            //print("2");
            await user.signInWithGoogle();

            //print("3");

            setState(() {
              //setAllLike();
              tabController.index = 1;
            });
          },
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

class MusicUpload extends StatefulWidget {
  const MusicUpload({
    super.key,
  });

  @override
  State<MusicUpload> createState() => _MusicUploadState();
}

class _MusicUploadState extends State<MusicUpload> {
  bool isupload = false;
  late File file;
  String fileName = "";

  void popUp(bool result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        if (result) {
          return AlertDialog(
            title: const Text("파일 업로드 완료!"),
            content: SizedBox(
              height: 70,
              child: Column(
                children: [
                  Text("file : $fileName"),
                  const Text("노래가 변환되었습니다!"),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("확인"),
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: const Text("파일 업로드 실패!"),
            content: SizedBox(
              height: 70,
              child: Column(
                children: [
                  Text("file : $fileName"),
                  const Text("파일 변환에 실패했습니다."),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("확인"),
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColorLight,
            Theme.of(context).primaryColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const Text(
            "노래 올리기",
            style: TextStyle(
              fontSize: 30,
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("mp3 파일만 업로드 가능합니다."),
              Text("정식 음원파일이 아닌경우 업로드에 실패할 수 있습니다."),
              Text("정상적으로 업로드된 음원은"),
              Text("확인 메시지 이후 전체노래 목록에서 확인할 수 있습니다."),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['mp3'],
              );

              if (result != null && result.files.isNotEmpty) {
                //print("성공");
                file = File(result.files.single.path!);

                setState(() {
                  fileName = result.files.first.name;
                  isupload = true;
                });
                //print(fileName);
              } else {
                // User canceled the picker
                //print("실패");
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.5),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              padding: const EdgeInsets.all(15),
              height: 60,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isupload
                      ? Icon(
                          Icons.file_copy_outlined,
                          color: Theme.of(context).focusColor,
                        )
                      : Icon(
                          Icons.file_upload,
                          color: Theme.of(context).focusColor,
                        ),
                  const SizedBox(
                    width: 10,
                  ),
                  isupload
                      ? Text(
                          fileName,
                          style: TextStyle(
                            color: Theme.of(context).focusColor,
                          ),
                        )
                      : const Text("여기를 눌러 파일을 선택하세요"),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 0.5),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            padding: const EdgeInsets.all(15),
            width: MediaQuery.of(context).size.width * 0.9,
            child: !isupload
                ? const Text("선택한 파일이 없습니다")
                : Column(
                    children: [
                      TextButton.icon(
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).focusColor,
                        ),
                        label: Text(
                          "노래 업로드",
                          style: TextStyle(color: Theme.of(context).focusColor),
                        ),
                        onPressed: () async {
                          // api들어가면 될것같음..
                          // 근데 노래파일을 어떻게 보내야하는지,,,,,,
                          bool result = await ApiService.uploadfile(file);
                          popUp(result);
                          setState(() {
                            isupload = false;
                            if (result) {
                              _HomeScreenState.update_allmusic();
                            }
                          });
                        },
                      ),
                    ],
                  ),
          )
        ],
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
                    style: TextStyle(
                      color: Theme.of(context).focusColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  music.artist,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).focusColor.withOpacity(0.7),
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
