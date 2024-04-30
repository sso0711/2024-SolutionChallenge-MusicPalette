import 'package:flutter/material.dart';
import 'package:music_palette/api_sevice.dart';
import 'package:music_palette/login_service.dart';
import 'package:music_palette/music_data.dart';
import 'package:music_palette/musicpage.dart';
import 'package:text_scroll/text_scroll.dart';

class AllMusicPage extends StatefulWidget {
  AllMusicPage({
    super.key,
    required this.allMusics,
    required this.user,
  });
  Future<List<MyMusic>> allMusics;
  MusicUser user;

  @override
  State<AllMusicPage> createState() => _AllMusicPageState();
}

class _AllMusicPageState extends State<AllMusicPage> {
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
          "전체 노래",
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
    //snapshot.data!.shuffle();
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
        childAspectRatio: 1 / 1.3, //item 의 가로 1, 세로 1 의 비율
        mainAxisSpacing: 10, //수평 Padding
        crossAxisSpacing: 10, //수직 Padding
      ),
      itemCount: snapshot.data!.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (BuildContext context) {
                  return MusicPage(
                    music: snapshot.data![index],
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
                    encodedtitle: snapshot.data![index].encodedtitle)),
              ),
              TextScroll(
                snapshot.data![index].title,
                delayBefore: const Duration(seconds: 2),
                pauseBetween: const Duration(seconds: 2),
                style: TextStyle(
                  color: Theme.of(context).focusColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextScroll(
                snapshot.data![index].artist,
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
