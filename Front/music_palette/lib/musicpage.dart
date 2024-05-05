import 'dart:async';
import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:music_palette/api_sevice.dart';
import 'package:music_palette/login_service.dart';
import 'package:music_palette/music_data.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:vibration/vibration.dart';
import 'package:http/http.dart' as http;

class MusicPage extends StatefulWidget {
  MyMusic music;
  MusicUser user;
  //late Future<List> musicInfo = ApiService.getMusicInfo(musicId: music.id);
  MusicPage({
    super.key,
    required this.music,
    required this.user,
  });

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  final player = AudioPlayer();
  late Duration duration = const Duration();
  late Duration now_position = const Duration();
  late int dura;
  StreamController<Duration> position = StreamController<Duration>();

  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener =
      ScrollOffsetListener.create();

  //late List testlrc = getlrc();
  //late List vive = getvive();
  late Future<List> musicInfo;
  late List lyric;
  late List vive;
  late String now_lrc = "";
  late String next_lrc = "";
  int now = 0;
  int nowvive = 0;

  bool play = true;
  bool isEx = false;

  Future<void> playMusic() async {
    final url =
        ApiService.getMp3FileUri(encodedtitle: widget.music.encodedtitle);
    //print("--------------------------test");
    await player.play(url);
  }

  Future<void> resumeMusic() async {
    await player.resume();
  }

  Future<void> pauseMusic() async {
    await player.pause();
  }

  Future<void> stopMusic() async {
    await player.stop();
  }

  Future<void> seekMusic(Duration newPosition) async {
    await player.seek(newPosition);

    //print("-------------test");

    bool flag = true;

    int i = 0;
    int j = 0;
    //print("new : ${newPosition.inMilliseconds}");
    // for lrc
    if (lyric[3][0].inMilliseconds == const Duration().inMilliseconds) {
    } else {
      flag = false;
    }
    while (flag) {
      //print(i);
      if (i >= lyric.length - 1) {
        break;
      } else if (newPosition.inMilliseconds <= lyric[0][0].inMilliseconds) {
        break;
      } else if (lyric[i][0].inMilliseconds <= newPosition.inMilliseconds &&
          newPosition.inMilliseconds <= lyric[i + 1][0].inMilliseconds) {
        break;
      } else {
        //print("testi : ${lyric[i][0].inMilliseconds}");
        i = i + 1;
      }
    }
    // for vive
    while (true) {
      //print(i);
      if (j >= vive.length) {
        break;
      } else if (newPosition.inMilliseconds <= vive[0][0].inMilliseconds) {
        break;
      } else if (vive[j][0].inMilliseconds <= newPosition.inMilliseconds &&
          newPosition.inMilliseconds <= vive[j + 1][0].inMilliseconds) {
        break;
      } else {
        //print("testi : ${lyric[i][0].inMilliseconds}");
        j = j + 1;
      }
    }

    //print("set - $i");
    setState(() {
      if (lyric[3][0].inMilliseconds == const Duration().inMilliseconds) {
      } else {
        now = i;
        now_lrc = lyric[now][1];
        if (now >= lyric.length - 1) {
          next_lrc = " ";
        } else {
          next_lrc = lyric[now + 1][1];
        }
        nowvive = j;
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //print("dispose??");
  }

  void startMusic() {
    //print(lyric[3][0].inMilliseconds);
    //print(const Duration().inMilliseconds);
    if (lyric[3][0].inMilliseconds == const Duration().inMilliseconds) {
      now_lrc = "전체가사 보기";
      next_lrc = "";
    } else {
      now_lrc = lyric[now][1];
      if (now >= lyric.length - 1) {
        next_lrc = " ";
      } else {
        next_lrc = lyric[now + 1][1];
      }
    }

    player.onPositionChanged.listen((Duration p) {
      //print("-------------test");
      setState(() {
        now_position = p;
        position.add(p);
        if (lyric[3][0].inMilliseconds == const Duration().inMilliseconds) {
        } else {
          if (!(now >= lyric.length - 1)) {
            //print("---------test");
            if (lyric[now + 1][0].inMilliseconds < p.inMilliseconds) {
              //print("-----test");
              now = now + 1;
              //now_lrc = lyric[now][1];
              if (now >= (lyric.length - 1)) {
                //print("test");
                //next_lrc = "";
              } else {
                //next_lrc = lyric[now + 1][1];
              }
            }
          }
        }
        if (nowvive < vive.length) {
          if (vive[nowvive][0].inMilliseconds < p.inMilliseconds) {
            if (vive[nowvive][1] > 0.75) {
              Vibration.vibrate(amplitude: 128, duration: dura);
              //print('test');
            } else if (vive[nowvive][1] > 0.5) {
              Vibration.vibrate(amplitude: 98, duration: dura);
            } else if (vive[nowvive][1] > 0.25) {
              Vibration.vibrate(amplitude: 68, duration: dura);
            } else if (vive[nowvive][1] > 0.0) {
              Vibration.vibrate(amplitude: 38, duration: dura);
            }
            nowvive = nowvive + 1;
            //print(nowvive);
          }
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    musicInfo = ApiService.getMusicInfo(musicId: widget.music.id);

    playMusic();
    player.onDurationChanged.listen((Duration d) {
      setState(() {
        duration = d;
      });
    });
  }

  void downloadImage(String url) async {
    var status = await Permission.storage.status;

    http.Response response = await http.get(
      Uri.parse(url),
    );

    if (Platform.isAndroid) {
      final plugin = DeviceInfoPlugin();
      final android = await plugin.androidInfo;
      PermissionStatus result;
      if (android.version.sdkInt >= 33) {
        //print("test 33");
        //popUptest();
        result = await Permission.photos.request();
        //popUptest();
      } else {
        //print("test !!33");
        result = await Permission.storage.request();
      }
      if (result.isGranted) {
        try {
          await ImageGallerySaver.saveImage(
            Uint8List.fromList(response.bodyBytes),
            quality: 100,
            name: (DateTime.now().millisecondsSinceEpoch.toString()),
          );

          popUp();
        } catch (e) {
          print("실패");
        }
      }
    } else {
      if (status.isDenied) {
        await Permission.storage.request();
      } else {
        try {
          await ImageGallerySaver.saveImage(
            Uint8List.fromList(response.bodyBytes),
            quality: 100,
            name: (DateTime.now().millisecondsSinceEpoch.toString()),
          );

          //print(response.bodyBytes);

          popUp();
        } catch (e) {
          print("실패");
        }
      }
    }
  }

  void popUptest() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("확인용 팝업"),
          content: const Text("확인용"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  void popUp() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("생성한 이미지 다운로드"),
          content: const Text("이미지 다운로드가 완료되었습니다."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorLight,
        leading: IconButton(
            onPressed: () {
              //stopMusic();
              player.dispose();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios_sharp)),
        title: Text(
          "Music Palette",
          style: TextStyle(
            color: Theme.of(context).focusColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
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
        child: FutureBuilder(
          future: musicInfo,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              lyric = snapshot.data![0];
              vive = snapshot.data![1];
              dura = snapshot.data![2];
              startMusic();
              return makeMusicPage(context);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Center makeMusicPage(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    isEx = !isEx;
                  });
                },
                child: isEx
                    ? Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          image: DecorationImage(
                            opacity: 0.3,
                            fit: BoxFit.fitWidth,
                            image: NetworkImage(
                              ApiService.getAiImageUri(
                                  encodedtitle: widget.music.encodedtitle),
                            ),
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              widget.music.imageEx,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    : Image.network(
                        ApiService.getAiImageUri(
                            encodedtitle: widget.music.encodedtitle),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.width * 0.9),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
                onPressed: () {
                  downloadImage(
                    ApiService.getAiImageUri(
                        encodedtitle: widget.music.encodedtitle),
                  );
                },
                icon: const Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  "생성한 이미지 다운로드 받기",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 43,
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        backgroundColor: Colors.black87,
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.9,
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(50),
                              image: DecorationImage(
                                  image: NetworkImage(
                                    ApiService.getCoverImageString(
                                        encodedtitle:
                                            widget.music.encodedtitle),
                                  ),
                                  fit: BoxFit.cover,
                                  opacity: 0.3),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 35, 20, 15),
                              child: StreamBuilder(
                                stream: player.onPositionChanged,
                                builder: (context, snapshot) {
                                  return ListView.separated(
                                    scrollDirection: Axis.vertical,
                                    itemCount: lyric.length,
                                    itemBuilder: (context, index) {
                                      return Text(
                                        lyric[index][1],
                                        style: TextStyle(
                                          fontSize: (now == index) ? 20 : 14,
                                          color: Colors.white,
                                          fontWeight: (now == index)
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(
                                      height: 10,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        now_lrc,
                        style: TextStyle(
                            fontSize: 17,
                            color: Theme.of(context).focusColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      next_lrc,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).focusColor.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: TextScroll(
                      widget.music.title,
                      numberOfReps: 1,
                      fadeBorderSide: FadeBorderSide.right,
                      fadedBorder: true,
                      style: TextStyle(
                          fontSize: 30,
                          color: Theme.of(context).focusColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    widget.music.artist,
                    style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).focusColor.withOpacity(0.6)),
                  ),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  splashColor: Colors.white.withOpacity(0.3),
                  splashFactory: InkRipple.splashFactory,
                  onTap: () {
                    setState(() {
                      widget.music.like = !widget.music.like;
                      widget.user.likeList[widget.music.id] = widget.music.like;
                      if (!widget.music.like) {
                        widget.user.setLike(ApiService.deleteLike(
                            uID: widget.user.userId, musicId: widget.music.id));
                      } else {
                        widget.user.setLike(ApiService.addLike(
                            uID: widget.user.userId, musicId: widget.music.id));
                      }
                      //print(widget.user.likeList);
                    });
                  },
                  child: widget.music.like
                      ? Icon(
                          Icons.favorite,
                          color: Theme.of(context).focusColor,
                          size: 40,
                        )
                      : Icon(
                          Icons.favorite_border,
                          color: Theme.of(context).focusColor,
                          size: 40,
                        ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          StreamBuilder(
            stream: position.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ProgressBar(
                  baseBarColor: Theme.of(context).focusColor.withOpacity(0.38),
                  progressBarColor:
                      Theme.of(context).focusColor.withOpacity(0.7),
                  thumbColor: const Color.fromARGB(255, 117, 157, 190),
                  timeLabelTextStyle:
                      TextStyle(color: Theme.of(context).focusColor),
                  progress: snapshot.data!,
                  total: duration,
                  onSeek: (newDuration) {
                    seekMusic(newDuration);
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (now_position.inSeconds <= 10) {
                          seekMusic(Duration.zero);
                        } else {
                          seekMusic(
                              Duration(seconds: now_position.inSeconds - 10));
                        }
                      });
                    },
                    child: Icon(
                      Icons.skip_previous_rounded,
                      color: Theme.of(context).focusColor.withOpacity(0.6),
                      size: 60,
                    ),
                  ),
                  Text(
                    "skip prev 10s",
                    style: TextStyle(
                      color: Theme.of(context).focusColor.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 50,
              ),
              InkWell(
                onTap: () {
                  if (play) {
                    setState(() {
                      play = !play;
                      //print(play);
                    });
                    pauseMusic();
                  } else {
                    setState(() {
                      play = !play;
                      //print(play);
                    });
                    resumeMusic();
                  }
                },
                child: play
                    ? Icon(
                        Icons.pause_circle_filled_rounded,
                        color: Theme.of(context).focusColor,
                        size: 80,
                      )
                    : Icon(
                        Icons.play_circle,
                        color: Theme.of(context).focusColor,
                        size: 80,
                      ),
              ),
              const SizedBox(
                width: 50,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (duration.inSeconds - now_position.inSeconds <= 10) {
                          stopMusic();
                        } else {
                          seekMusic(
                              Duration(seconds: now_position.inSeconds + 10));
                        }
                      });
                    },
                    child: Icon(
                      Icons.skip_next_rounded,
                      color: Theme.of(context).focusColor.withOpacity(0.6),
                      size: 60,
                    ),
                  ),
                  Text(
                    "skip next 10s",
                    style: TextStyle(
                      color: Theme.of(context).focusColor.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
