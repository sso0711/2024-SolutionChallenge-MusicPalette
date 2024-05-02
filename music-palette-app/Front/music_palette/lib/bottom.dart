import 'package:flutter/material.dart';

class Bottom extends StatelessWidget {
  Bottom({super.key, required this.tabController});
  late TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SizedBox(
        height: 50,
        child: TabBar(
          controller: tabController,
          labelColor: Colors.white,
          unselectedLabelColor: const Color.fromARGB(237, 91, 106, 114),
          indicatorColor: Colors.white,
          dividerColor: Colors.black,
          tabs: const <Widget>[
            Tab(
              iconMargin: EdgeInsets.only(bottom: 5),
              icon: Icon(
                Icons.music_note,
                size: 18,
              ),
              child: Text(
                '노래올리기',
                style: TextStyle(
                  fontSize: 9,
                ),
              ),
            ),
            Tab(
              iconMargin: EdgeInsets.only(bottom: 5),
              icon: Icon(
                Icons.home,
                size: 18,
              ),
              child: Text(
                '홈',
                style: TextStyle(
                  fontSize: 9,
                ),
              ),
            ),
            Tab(
              iconMargin: EdgeInsets.only(bottom: 5),
              icon: Icon(
                Icons.menu,
                size: 18,
              ),
              child: Text(
                '메뉴',
                style: TextStyle(
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
