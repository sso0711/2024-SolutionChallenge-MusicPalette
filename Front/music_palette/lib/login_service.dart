import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:music_palette/api_sevice.dart';

class MusicUser {
  late GoogleSignInAccount googleUser;
  FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  late String userImage;
  late String userName;
  late String userEmail;
  late String userId;
  bool isLogin = false;

  late List<bool> likeList;

  void updateuser(
      {required GoogleSignInAccount googleaccount, required String uID}) {
    userImage = googleaccount.photoUrl!;
    userName = googleaccount.displayName!;
    userEmail = googleaccount.email;
    userId = uID;
    isLogin = true;
  }

  Future<void> setLike(Future<List<bool>> futureLikeList) async {
    List<bool> returnList = [];
    returnList = await futureLikeList;

    likeList = returnList;
    //print(likeList);
  }

  Future<void> signInWithGoogle() async {
    //googleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleuser = await GoogleSignIn().signIn();
    if (googleuser == null) {
      //print("error");
      return;
    }
    GoogleSignInAuthentication authentication = await googleuser.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: authentication.accessToken,
      idToken: authentication.idToken,
    );

    UserCredential authresult =
        await FirebaseAuth.instance.signInWithCredential(credential);
    //User authUser = authresult.user!;

    if (authresult.user != null) {
      //print(authresult.user!.uid);
      Future<List<bool>> futurelikeList =
          ApiService.getLikeMusics(authresult.user!.uid);
      //print("test");
      await setLike(futurelikeList);
    }

    updateuser(googleaccount: googleuser, uID: authresult.user!.uid);
  }
}
