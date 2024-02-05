import 'package:flutter/material.dart';
import 'package:music_palette/login_service.dart';

class Mypage extends StatefulWidget {
  MusicUser user;
  Mypage({super.key, required this.user});

  @override
  State<Mypage> createState() => _MypageState();
}

class _MypageState extends State<Mypage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            children: [
              Container(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.arrow_back_ios_sharp)),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              !(widget.user.isLogin)
                  ? OutlinedButton.icon(
                      onPressed: () async {
                        await widget.user.signInWithGoogle();
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
                    )
                  : Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: SizedBox(
                            height: 200,
                            width: 200,
                            child: Image.network(widget.user.userImage),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          widget.user.userName,
                          style: const TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          widget.user.userEmail,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white60,
                          ),
                        ),
                        const Divider(),
                        InkWell(
                          child: Container(
                            color: Colors.deepPurple,
                            height: 60,
                            width: 60,
                          ),
                          onTap: () {},
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
