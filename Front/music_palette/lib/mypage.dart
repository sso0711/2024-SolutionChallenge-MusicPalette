import 'package:flutter/material.dart';

class Mypage extends StatelessWidget {
  const Mypage({super.key});

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
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  height: 200,
                  width: 200,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "이름",
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
              const Text(
                "이메일",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white60,
                ),
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
