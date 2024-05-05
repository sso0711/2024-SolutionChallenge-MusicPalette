import 'package:flutter/material.dart';
import 'package:music_palette/api_sevice.dart';
import 'package:music_palette/login_service.dart';
import 'package:music_palette/music_data.dart';
import 'package:music_palette/musicpage.dart';
import 'package:text_scroll/text_scroll.dart';

class LikeMusicPage extends StatefulWidget {
  LikeMusicPage({super.key, required this.allMusics, required this.user});
  Future<List<MyMusic>> allMusics;
  MusicUser user;
  List<MyMusic> likeMusics = [];

  @override
  State<LikeMusicPage> createState() => _LikeMusicPageState();
}

class _LikeMusicPageState extends State<LikeMusicPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios_sharp)),
        title: Text(
          "내가 찜한 노래",
          style: TextStyle(
            color: Theme.of(context).focusColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
            children: [
              const Divider(),
              FutureBuilder(
                future: widget.allMusics,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<MyMusic>? musicss = snapshot.data;
                    for (var m in musicss!) {
                      //print("test ${m.like}");
                      if (m.like) {
                        //print("test2");
                        widget.likeMusics.add(m);
                      }
                    }

                    return Expanded(
                      child: makeMusicLists(snapshot),
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

  Widget makeMusicLists(AsyncSnapshot<List<MyMusic>> snapshot) {
    //widget.likeMusics.shuffle();
    //getLikeMusicList();
    //print(widget.likeMusics);
    //print("test2");
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
        childAspectRatio: 1 / 1.3, //item 의 가로 1, 세로 1 의 비율
        mainAxisSpacing: 10, //수평 Padding
        crossAxisSpacing: 10, //수직 Padding
      ),
      itemCount: widget.likeMusics.length,
      itemBuilder: (context, index) {
        //print(widget.user.likeList[widget.likeMusics[index].id]);

        //print("test");
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (BuildContext context) {
                  return MusicPage(
                    music: widget.likeMusics[index],
                    user: widget.user,
                  );
                },
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(ApiService.getCoverImageString(
                    encodedtitle: widget.likeMusics[index].encodedtitle)),
              ),
              TextScroll(
                widget.likeMusics[index].title,
                delayBefore: const Duration(seconds: 2),
                pauseBetween: const Duration(seconds: 2),
                style: TextStyle(
                  color: Theme.of(context).focusColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextScroll(
                widget.likeMusics[index].artist,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).focusColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
