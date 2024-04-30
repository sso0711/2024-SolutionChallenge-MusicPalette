import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_palette/home_screen.dart';
import 'package:music_palette/login_service.dart';

class Search_Page extends StatefulWidget {
  Search_Page({super.key, required this.musics, required this.user});
  List musics;
  MusicUser user;

  @override
  State<Search_Page> createState() => _Search_PageState();
}

class _Search_PageState extends State<Search_Page> {
  final _textcontroller = TextEditingController();
  String searchtext = "";
  void search_music(String title) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorLight,
        leading: IconButton(
            onPressed: () {
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
            SearchBar(
              controller: _textcontroller,
              leading: const Icon(Icons.search),
              trailing: [
                IconButton(
                    onPressed: () {
                      _textcontroller.clear();
                    },
                    icon: const Icon(Icons.close))
              ],
              backgroundColor:
                  MaterialStatePropertyAll(Theme.of(context).primaryColorLight),
              elevation: const MaterialStatePropertyAll(1),
              shape: MaterialStateProperty.all(
                ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              hintText: "검색어를 입력하세요",
              onSubmitted: (value) {
                setState(() {
                  //search_music(value);
                  searchtext = value;
                  FocusScope.of(context).unfocus();
                });
              },
              onChanged: (value) {
                //FocusScope.of(context).unfocus();
                setState(() {
                  searchtext = value;
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: widget.musics.length,
                itemBuilder: (context, index) {
                  if (searchtext.isNotEmpty) {
                    if (widget.musics[index].title
                        .toLowerCase()
                        .contains(searchtext.toLowerCase())) {
                      return Music(
                          music: widget.musics[index], user: widget.user);
                    }
                  } else {
                    return Music(
                        music: widget.musics[index], user: widget.user);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
